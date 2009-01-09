From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Sat, 10 Jan 2009 00:34:40 +0100
Message-ID: <4967DF10.2010107@cosmosbay.com>
References: <20090108.135515.85489589.davem@davemloft.net> <4966F2F4.9080901@cosmosbay.com> <49677074.5090802@cosmosbay.com> <20090109185448.GA1999@1wt.eu> <4967B8C5.10803@cosmosbay.com> <20090109212400.GA3727@1wt.eu> <20090109220737.GA4111@1wt.eu> <4967CBB9.1060403@cosmosbay.com> <20090109221744.GA4819@1wt.eu> <4967D36E.6020207@cosmosbay.com> <20090109225309.GC4819@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, ben@zeus.com,
	jarkao2@gmail.com, mingo@elte.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com
To: Willy Tarreau <w@1wt.eu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760370AbZAIXix@vger.kernel.org>
In-Reply-To: <20090109225309.GC4819@1wt.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Willy Tarreau a =E9crit :
> On Fri, Jan 09, 2009 at 11:45:02PM +0100, Eric Dumazet wrote:
>> Only the (!timeo) can be above. Other conditions must be checked aft=
er
>> the release/lock.
>=20
> Yes that's what Evgeniy explained too. I smelled something like this
> but did not know.
>=20
> Care to redo the whole patch, since you already have all code parts
> at hand as well as some fragments of commit messages ? You can even
> add my Tested-by if you want. Finally it was nice that Dave asked
> for this explanation because it drove our nose to the fishy parts ;-)

Sure, here it is :


David, do you think we still must call __tcp_splice_read() only once
in tcp_splice_read() if SPLICE_F_NONBLOCK is set ?

With following patch, a splice() call is limited to 16 frames, typicall=
y
16*1460 =3D 23360 bytes. Removing the test as Willy did in its patch
could return the exact length requested by user (limited to 16 pages),
giving nice blocks if feeding a file on disk...

Thank you

=46rom: Willy Tarreau <w@1wt.eu>

[PATCH] tcp: splice as many packets as possible at once

As spotted by Willy Tarreau, current splice() from tcp socket to pipe i=
s not
optimal. It processes at most one segment per call.
This results in low performance and very high overhead due to syscall r=
ate
when splicing from interfaces which do not support LRO.

Willy provided a patch inside tcp_splice_read(), but a better fix
is to let tcp_read_sock() process as many segments as possible, so
that tcp_rcv_space_adjust() and tcp_cleanup_rbuf() are called less
often.

With this change, splice() behaves like tcp_recvmsg(), being able
to consume many skbs in one system call. With typical 1460 bytes
of payload per frame, that means splice(SPLICE_F_NONBLOCK) can return
16*1460 =3D 23360 bytes.

Signed-off-by: Willy Tarreau <w@1wt.eu>
Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index bd6ff90..1233835 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -522,8 +522,12 @@ static int tcp_splice_data_recv(read_descriptor_t =
*rd_desc, struct sk_buff *skb,
 				unsigned int offset, size_t len)
 {
 	struct tcp_splice_state *tss =3D rd_desc->arg.data;
+	int ret;
=20
-	return skb_splice_bits(skb, offset, tss->pipe, tss->len, tss->flags);
+	ret =3D skb_splice_bits(skb, offset, tss->pipe, rd_desc->count, tss->=
flags);
+	if (ret > 0)
+		rd_desc->count -=3D ret;
+	return ret;
 }
=20
 static int __tcp_splice_read(struct sock *sk, struct tcp_splice_state =
*tss)
@@ -531,6 +535,7 @@ static int __tcp_splice_read(struct sock *sk, struc=
t tcp_splice_state *tss)
 	/* Store TCP splice context information in read_descriptor_t. */
 	read_descriptor_t rd_desc =3D {
 		.arg.data =3D tss,
+		.count	  =3D tss->len,
 	};
=20
 	return tcp_read_sock(sk, &rd_desc, tcp_splice_data_recv);
@@ -611,11 +616,13 @@ ssize_t tcp_splice_read(struct socket *sock, loff=
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
