From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Fri, 09 Jan 2009 23:12:09 +0100
Message-ID: <4967CBB9.1060403@cosmosbay.com>
References: <20090108173028.GA22531@1wt.eu> <49667534.5060501@zeus.com> <20090108.135515.85489589.davem@davemloft.net> <4966F2F4.9080901@cosmosbay.com> <49677074.5090802@cosmosbay.com> <20090109185448.GA1999@1wt.eu> <4967B8C5.10803@cosmosbay.com> <20090109212400.GA3727@1wt.eu> <20090109220737.GA4111@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, ben@zeus.com,
	jarkao2@gmail.com, mingo@elte.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:50330 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758511AbZAIWQF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 17:16:05 -0500
In-Reply-To: <20090109220737.GA4111@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Willy Tarreau a =E9crit :
> On Fri, Jan 09, 2009 at 10:24:00PM +0100, Willy Tarreau wrote:
>> On Fri, Jan 09, 2009 at 09:51:17PM +0100, Eric Dumazet wrote:
>> (...)
>>>> Also, in your second mail, you're saying that your change
>>>> might return more data than requested by the user. I can't
>>>> find why, could you please explain to me, as I'm still quite
>>>> ignorant in this area ?
>>> Well, I just tested various user programs and indeed got this
>>> strange result :
>>>
>>> Here I call splice() with len=3D1000 (0x3e8), and you can see
>>> it gives a result of 1460 at the second call.
>=20
> OK finally I could reproduce it and found why we have this. It's
> expected in fact.
>=20
> The problem when we loop in tcp_read_sock() is that tss->len is
> not decremented by the amount of bytes read, this one is done
> only in tcp_splice_read() which is outer.
>=20
> The solution I found was to do just like other callers, which means
> use desc->count to keep the remaining number of bytes we want to
> read. In fact, tcp_read_sock() is designed to use that one as a stop
> condition, which explains why you first had to hide it.
>=20
> Now with the attached patch as a replacement for my previous one,
> both issues are solved :
>   - I splice 1000 bytes if I ask to do so
>   - I splice as much as possible if available (typically 23 kB).
>=20
> My observed performances are still at the top of earlier results
> and IMHO that way of counting bytes makes sense for an actor called
> from tcp_read_sock().
>=20
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 35bcddf..51ff3aa 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -522,8 +522,12 @@ static int tcp_splice_data_recv(read_descriptor_=
t *rd_desc, struct sk_buff *skb,
>  				unsigned int offset, size_t len)
>  {
>  	struct tcp_splice_state *tss =3D rd_desc->arg.data;
> +	int ret;
> =20
> -	return skb_splice_bits(skb, offset, tss->pipe, tss->len, tss->flags=
);
> +	ret =3D skb_splice_bits(skb, offset, tss->pipe, rd_desc->count, tss=
->flags);
> +	if (ret > 0)
> +		rd_desc->count -=3D ret;
> +	return ret;
>  }
> =20
>  static int __tcp_splice_read(struct sock *sk, struct tcp_splice_stat=
e *tss)
> @@ -531,6 +535,7 @@ static int __tcp_splice_read(struct sock *sk, str=
uct tcp_splice_state *tss)
>  	/* Store TCP splice context information in read_descriptor_t. */
>  	read_descriptor_t rd_desc =3D {
>  		.arg.data =3D tss,
> +		.count =3D tss->len,
>  	};
> =20
>  	return tcp_read_sock(sk, &rd_desc, tcp_splice_data_recv);
>=20

OK, I came to a different patch. Please check other tcp_read_sock() cal=
lers in tree :)

diff --git a/drivers/scsi/iscsi_tcp.c b/drivers/scsi/iscsi_tcp.c
index 23808df..96b49e1 100644
--- a/drivers/scsi/iscsi_tcp.c
+++ b/drivers/scsi/iscsi_tcp.c
@@ -100,13 +100,11 @@ static void iscsi_sw_tcp_data_ready(struct sock *=
sk, int flag)
=20
 	/*
 	 * Use rd_desc to pass 'conn' to iscsi_tcp_recv.
-	 * We set count to 1 because we want the network layer to
-	 * hand us all the skbs that are available. iscsi_tcp_recv
-	 * handled pdus that cross buffers or pdus that still need data.
+	 * iscsi_tcp_recv handled pdus that cross buffers or pdus that
+	 * still need data.
 	 */
 	rd_desc.arg.data =3D conn;
-	rd_desc.count =3D 1;
-	tcp_read_sock(sk, &rd_desc, iscsi_sw_tcp_recv);
+	tcp_read_sock(sk, &rd_desc, iscsi_sw_tcp_recv, 65536);
=20
 	read_unlock(&sk->sk_callback_lock);
=20
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 218235d..b1facd1 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -490,7 +490,7 @@ extern void tcp_get_info(struct sock *, struct tcp_=
info *);
 typedef int (*sk_read_actor_t)(read_descriptor_t *, struct sk_buff *,
 				unsigned int, size_t);
 extern int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
-			 sk_read_actor_t recv_actor);
+			 sk_read_actor_t recv_actor, size_t tlen);
=20
 extern void tcp_initialize_rcv_mss(struct sock *sk);
=20
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index bd6ff90..fbbddf4 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -523,7 +523,7 @@ static int tcp_splice_data_recv(read_descriptor_t *=
rd_desc, struct sk_buff *skb,
 {
 	struct tcp_splice_state *tss =3D rd_desc->arg.data;
=20
-	return skb_splice_bits(skb, offset, tss->pipe, tss->len, tss->flags);
+	return skb_splice_bits(skb, offset, tss->pipe, len, tss->flags);
 }
=20
 static int __tcp_splice_read(struct sock *sk, struct tcp_splice_state =
*tss)
@@ -533,7 +533,7 @@ static int __tcp_splice_read(struct sock *sk, struc=
t tcp_splice_state *tss)
 		.arg.data =3D tss,
 	};
=20
-	return tcp_read_sock(sk, &rd_desc, tcp_splice_data_recv);
+	return tcp_read_sock(sk, &rd_desc, tcp_splice_data_recv, tss->len);
 }
=20
 /**
@@ -611,11 +611,13 @@ ssize_t tcp_splice_read(struct socket *sock, loff=
_t *ppos,
 		tss.len -=3D ret;
 		spliced +=3D ret;
=20
+		if (!timeo)
+			break;
 		release_sock(sk);
 		lock_sock(sk);
=20
 		if (sk->sk_err || sk->sk_state =3D=3D TCP_CLOSE ||
-		    (sk->sk_shutdown & RCV_SHUTDOWN) || !timeo ||
+		    (sk->sk_shutdown & RCV_SHUTDOWN) ||
 		    signal_pending(current))
 			break;
 	}
@@ -1193,7 +1195,7 @@ static inline struct sk_buff *tcp_recv_skb(struct=
 sock *sk, u32 seq, u32 *off)
  *	  (although both would be easy to implement).
  */
 int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
-		  sk_read_actor_t recv_actor)
+		  sk_read_actor_t recv_actor, size_t tlen)
 {
 	struct sk_buff *skb;
 	struct tcp_sock *tp =3D tcp_sk(sk);
@@ -1209,6 +1211,8 @@ int tcp_read_sock(struct sock *sk, read_descripto=
r_t *desc,
 			size_t len;
=20
 			len =3D skb->len - offset;
+			if (len > tlen)
+				len =3D tlen;
 			/* Stop reading if we hit a patch of urgent data */
 			if (tp->urg_data) {
 				u32 urg_offset =3D tp->urg_seq - seq;
@@ -1226,6 +1230,7 @@ int tcp_read_sock(struct sock *sk, read_descripto=
r_t *desc,
 				seq +=3D used;
 				copied +=3D used;
 				offset +=3D used;
+				tlen -=3D used;
 			}
 			/*
 			 * If recv_actor drops the lock (e.g. TCP splice
@@ -1243,7 +1248,7 @@ int tcp_read_sock(struct sock *sk, read_descripto=
r_t *desc,
 			break;
 		}
 		sk_eat_skb(sk, skb, 0);
-		if (!desc->count)
+		if (!tlen)
 			break;
 	}
 	tp->copied_seq =3D seq;
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 5cbb404..75f8e83 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1109,8 +1109,7 @@ static void xs_tcp_data_ready(struct sock *sk, in=
t bytes)
 	/* We use rd_desc to pass struct xprt to xs_tcp_data_recv */
 	rd_desc.arg.data =3D xprt;
 	do {
-		rd_desc.count =3D 65536;
-		read =3D tcp_read_sock(sk, &rd_desc, xs_tcp_data_recv);
+		read =3D tcp_read_sock(sk, &rd_desc, xs_tcp_data_recv, 65536);
 	} while (read > 0);
 out:
 	read_unlock(&sk->sk_callback_lock);


