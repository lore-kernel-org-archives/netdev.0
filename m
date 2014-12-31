From: Julian Kirsch <kirschju@sec.in.tum.de>
Subject: [PATCH] TCP: Add support for TCP Stealth
Date: Wed, 31 Dec 2014 22:54:59 +0100
Message-ID: <54A470B3.3010501@sec.in.tum.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050300000401010001010807"
Cc: Christian Grothoff <christian@grothoff.org>,
	Jacob Appelbaum <jacob@appelbaum.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.informatik.tu-muenchen.de ([131.159.0.99]:58839 "EHLO
	smtp1.informatik.tu-muenchen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751143AbaLaWAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2014 17:00:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050300000401010001010807
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hi,

one year ago [0] we tried to convince you to add support for a new
socket option to the linux kernel. Equipped with an improved version of
our patch we're back to accomplish this task today. :-)

TCP Stealth is a modern variant of port knocking which borrows
techniques from network steganography to enable clients to authenticate
themselves towards a server on TCP level. You can find technical details
in an rfc draft we wrote earlier this year [1] and in my master's thesis
[2]. In summary, TCP Stealth derives authentication information from a
pre-shared secret and embeds it into the ISN sent along with the first
SYN from the client.

Our motivation is simple: During this year we gained hard evidence on
secret services actively port scanning the internets followed by
exploitation of your services using 0-day exploits [3, 4]. We don't want
our machines to be turned into relays from where they continue to
cascade their attacks. TCP Stealth makes port scanning more expensive by
a factor of 2^31 (on average).

A copy of this patch as well as patches for several user space
applications can be found on the project's home page [5].

All the best for the upcoming year,
Julian & Christian



[0] https://lkml.org/lkml/2013/12/10/1155
[1] https://datatracker.ietf.org/doc/draft-kirsch-ietf-tcp-stealth/
[2] https://gnunet.org/kirsch2014knock
[3]
http://www.heise.de/ct/artikel/NSA-GCHQ-The-HACIENDA-Program-for-Internet-Colonization-2292681.html
[4]
https://firstlook.org/theintercept/2014/12/13/belgacom-hack-gchq-inside-story/
[5] https://gnunet.org/knock
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJUpHCvAAoJENwkOWttRRA4g10IALbJZU9/5Gp8tVdpXqbkOIMp
Kz+yOMyYULqYeM8yguSBZjZLbaz/VAS7SNpQxKGU+W0aAXa22FsSfVoUU7wqp3NT
3EGRuPkMaJkQ66IP8MtX+6/hSeWSh78tEaIFWVjyutihPyQGz0LefFc66gm54X4T
s8IYW7jKFhNmmROu9CXLTxq4B5t2v+Evv/qWqotZqR1t3IbIUmZAiKrlkMRd7dtM
SaS5JwFeiObxn+0M/7javQCAhfgPXYEOU0QKAGY55MXcPAner/5PuExIZdOJ41R3
XD9tgoLGhHEiQkxj0/bP2cs3Cl5xfJl9t2iecVfTIR7PytaTJ/kFuE4gNgWEcTA=
=T6/C
-----END PGP SIGNATURE-----

--------------050300000401010001010807
Content-Type: text/x-patch;
 name="tcp_stealth_3.18.diff"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="tcp_stealth_3.18.diff"

Signed-off-by: Julian Kirsch <kirschju@sec.in.tum.de>
diff -Nurp linux-3.18-rc3/include/linux/tcp.h linux-3.18-rc3-knock/includ=
e/linux/tcp.h
--- linux-3.18-rc3/include/linux/tcp.h	2014-11-03 00:01:51.000000000 +010=
0
+++ linux-3.18-rc3-knock/include/linux/tcp.h	2014-11-06 21:26:34.97601700=
1 +0100
@@ -19,6 +19,7 @@
=20
=20
 #include <linux/skbuff.h>
+#include <linux/cryptohash.h>
 #include <net/sock.h>
 #include <net/inet_connection_sock.h>
 #include <net/inet_timewait_sock.h>
@@ -309,6 +310,21 @@ struct tcp_sock {
 	struct tcp_md5sig_info	__rcu *md5sig_info;
 #endif
=20
+#ifdef CONFIG_TCP_STEALTH
+/* Stealth TCP socket configuration */
+	struct {
+		#define TCP_STEALTH_MODE_AUTH		BIT(0)
+		#define TCP_STEALTH_MODE_INTEGRITY	BIT(1)
+		#define TCP_STEALTH_MODE_INTEGRITY_LEN	BIT(2)
+		int mode;
+		u8 secret[MD5_MESSAGE_BYTES];
+		int integrity_len;
+		u16 integrity_hash;
+		struct skb_mstamp mstamp;
+		bool saw_tsval;
+	} stealth;
+#endif
+
 /* TCP fastopen related information */
 	struct tcp_fastopen_request *fastopen_req;
 	/* fastopen_rsk points to request_sock that resulted in this big
diff -Nurp linux-3.18-rc3/include/net/secure_seq.h linux-3.18-rc3-knock/i=
nclude/net/secure_seq.h
--- linux-3.18-rc3/include/net/secure_seq.h	2014-11-03 00:01:51.000000000=
 +0100
+++ linux-3.18-rc3-knock/include/net/secure_seq.h	2014-11-06 21:26:34.976=
017001 +0100
@@ -14,5 +14,10 @@ u64 secure_dccp_sequence_number(__be32 s
 				__be16 sport, __be16 dport);
 u64 secure_dccpv6_sequence_number(__be32 *saddr, __be32 *daddr,
 				  __be16 sport, __be16 dport);
+#ifdef CONFIG_TCP_STEALTH
+u32 tcp_stealth_do_auth(struct sock *sk, struct sk_buff *skb);
+u32 tcp_stealth_sequence_number(struct sock *sk, __be32 *daddr,
+				u32 daddr_size, __be16 dport);
+#endif
=20
 #endif /* _NET_SECURE_SEQ */
diff -Nurp linux-3.18-rc3/include/net/tcp.h linux-3.18-rc3-knock/include/=
net/tcp.h
--- linux-3.18-rc3/include/net/tcp.h	2014-11-03 00:01:51.000000000 +0100
+++ linux-3.18-rc3-knock/include/net/tcp.h	2014-11-06 21:26:34.976017001 =
+0100
@@ -439,6 +439,12 @@ void tcp_parse_options(const struct sk_b
 		       struct tcp_options_received *opt_rx,
 		       int estab, struct tcp_fastopen_cookie *foc);
 const u8 *tcp_parse_md5sig_option(const struct tcphdr *th);
+#ifdef CONFIG_TCP_STEALTH
+const bool tcp_parse_tsval_option(u32 *tsval, const struct tcphdr *th);
+int tcp_stealth_integrity(u16 *hash, u8 *secret, u8 *payload, int len);
+#define be32_isn_to_be16_av(x)	(((__be16 *)&x)[0])
+#define be32_isn_to_be16_ih(x)	(((__be16 *)&x)[1])
+#endif
=20
 /*
  *	TCP v4 functions exported for the inet6 API
diff -Nurp linux-3.18-rc3/include/uapi/linux/tcp.h linux-3.18-rc3-knock/i=
nclude/uapi/linux/tcp.h
--- linux-3.18-rc3/include/uapi/linux/tcp.h	2014-11-03 00:01:51.000000000=
 +0100
+++ linux-3.18-rc3-knock/include/uapi/linux/tcp.h	2014-11-06 21:26:34.976=
017001 +0100
@@ -112,6 +112,9 @@ enum {
 #define TCP_FASTOPEN		23	/* Enable FastOpen on listeners */
 #define TCP_TIMESTAMP		24
 #define TCP_NOTSENT_LOWAT	25	/* limit number of unsent bytes in write qu=
eue */
+#define TCP_STEALTH		26
+#define TCP_STEALTH_INTEGRITY	27
+#define TCP_STEALTH_INTEGRITY_LEN	28
=20
 struct tcp_repair_opt {
 	__u32	opt_code;
diff -Nurp linux-3.18-rc3/net/core/secure_seq.c linux-3.18-rc3-knock/net/=
core/secure_seq.c
--- linux-3.18-rc3/net/core/secure_seq.c	2014-11-03 00:01:51.000000000 +0=
100
+++ linux-3.18-rc3-knock/net/core/secure_seq.c	2014-11-24 14:31:20.227872=
751 +0100
@@ -8,7 +8,11 @@
 #include <linux/ktime.h>
 #include <linux/string.h>
 #include <linux/net.h>
+#include <linux/socket.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
=20
+#include <net/tcp.h>
 #include <net/secure_seq.h>
=20
 #if IS_ENABLED(CONFIG_IPV6) || IS_ENABLED(CONFIG_INET)
@@ -39,6 +43,103 @@ static u32 seq_scale(u32 seq)
 }
 #endif
=20
+#ifdef CONFIG_TCP_STEALTH
+u32 tcp_stealth_sequence_number(struct sock *sk, __be32 *daddr,
+				u32 daddr_size, __be16 dport)
+{
+	struct tcp_sock *tp =3D tcp_sk(sk);
+	struct tcp_md5sig_key *md5;
+
+	__u32 sec[MD5_MESSAGE_BYTES / sizeof(__u32)];
+	__u32 i;
+	__u32 tsval =3D 0;
+
+	__be32 iv[MD5_DIGEST_WORDS] =3D { 0 };
+	__be32 isn;
+
+	memcpy(iv, (const __u8 *)daddr,
+	       (daddr_size > sizeof(iv)) ? sizeof(iv) : daddr_size);
+
+#ifdef CONFIG_TCP_MD5SIG
+	md5 =3D tp->af_specific->md5_lookup(sk, sk);
+#else
+	md5 =3D NULL;
+#endif
+	if (likely(sysctl_tcp_timestamps && !md5) || tp->stealth.saw_tsval)
+		tsval =3D tp->stealth.mstamp.stamp_jiffies;
+
+	((__be16 *)iv)[2] ^=3D cpu_to_be16(tp->stealth.integrity_hash);
+	iv[2] ^=3D cpu_to_be32(tsval);
+	((__be16 *)iv)[6] ^=3D dport;
+
+	for (i =3D 0; i < MD5_DIGEST_WORDS; i++)
+		iv[i] =3D le32_to_cpu(iv[i]);
+	for (i =3D 0; i < MD5_MESSAGE_BYTES / sizeof(__le32); i++)
+		sec[i] =3D le32_to_cpu(((__le32 *)tp->stealth.secret)[i]);
+
+	md5_transform(iv, sec);
+
+	isn =3D cpu_to_be32(iv[0]) ^ cpu_to_be32(iv[1]) ^
+	      cpu_to_be32(iv[2]) ^ cpu_to_be32(iv[3]);
+
+	if (tp->stealth.mode & TCP_STEALTH_MODE_INTEGRITY)
+		be32_isn_to_be16_ih(isn) =3D
+			cpu_to_be16(tp->stealth.integrity_hash);
+
+	return be32_to_cpu(isn);
+}
+EXPORT_SYMBOL(tcp_stealth_sequence_number);
+
+u32 tcp_stealth_do_auth(struct sock *sk, struct sk_buff *skb)
+{
+	struct tcp_sock *tp =3D tcp_sk(sk);
+	struct tcphdr *th =3D tcp_hdr(skb);
+	__be32 isn =3D th->seq;
+	__be32 hash;
+	__be32 *daddr;
+	u32 daddr_size;
+
+	tp->stealth.saw_tsval =3D
+		tcp_parse_tsval_option(&tp->stealth.mstamp.stamp_jiffies, th);
+
+	if (tp->stealth.mode & TCP_STEALTH_MODE_INTEGRITY_LEN)
+		tp->stealth.integrity_hash =3D
+			be16_to_cpu(be32_isn_to_be16_ih(isn));
+
+	switch (tp->inet_conn.icsk_inet.sk.sk_family) {
+#if IS_ENABLED(CONFIG_IPV6)
+	case PF_INET6:
+		daddr_size =3D sizeof(ipv6_hdr(skb)->daddr.s6_addr32);
+		daddr =3D ipv6_hdr(skb)->daddr.s6_addr32;
+	break;
+#endif
+	case PF_INET:
+		daddr_size =3D sizeof(ip_hdr(skb)->daddr);
+		daddr =3D &ip_hdr(skb)->daddr;
+	break;
+	default:
+		pr_err("TCP Stealth: Unknown network layer protocol, stop!\n");
+		return 1;
+	}
+
+	hash =3D tcp_stealth_sequence_number(sk, daddr, daddr_size, th->dest);
+	cpu_to_be32s(&hash);
+
+	if (tp->stealth.mode & TCP_STEALTH_MODE_AUTH &&
+	    tp->stealth.mode & TCP_STEALTH_MODE_INTEGRITY_LEN &&
+	    be32_isn_to_be16_av(isn) =3D=3D be32_isn_to_be16_av(hash))
+		return 0;
+
+	if (tp->stealth.mode & TCP_STEALTH_MODE_AUTH &&
+	    !(tp->stealth.mode & TCP_STEALTH_MODE_INTEGRITY_LEN) &&
+	    isn =3D=3D hash)
+		return 0;
+
+	return 1;
+}
+EXPORT_SYMBOL(tcp_stealth_do_auth);
+#endif
+
 #if IS_ENABLED(CONFIG_IPV6)
 __u32 secure_tcpv6_sequence_number(const __be32 *saddr, const __be32 *da=
ddr,
 				   __be16 sport, __be16 dport)
diff -Nurp linux-3.18-rc3/net/ipv4/Kconfig linux-3.18-rc3-knock/net/ipv4/=
Kconfig
--- linux-3.18-rc3/net/ipv4/Kconfig	2014-11-03 00:01:51.000000000 +0100
+++ linux-3.18-rc3-knock/net/ipv4/Kconfig	2014-11-06 21:26:34.976017001 +=
0100
@@ -671,3 +671,13 @@ config TCP_MD5SIG
 	  on the Internet.
=20
 	  If unsure, say N.
+
+config TCP_STEALTH
+	bool "TCP: Stealth TCP socket support"
+	default n
+	---help---
+	  This option enables support for stealth TCP sockets. If you do not
+	  know what this means, you do not need it.
+
+	  If unsure, say N.
+
diff -Nurp linux-3.18-rc3/net/ipv4/tcp.c linux-3.18-rc3-knock/net/ipv4/tc=
p.c
--- linux-3.18-rc3/net/ipv4/tcp.c	2014-11-03 00:01:51.000000000 +0100
+++ linux-3.18-rc3-knock/net/ipv4/tcp.c	2014-11-24 11:44:39.700059516 +01=
00
@@ -2329,6 +2329,43 @@ static int tcp_repair_options_est(struct
 	return 0;
 }
=20
+#ifdef CONFIG_TCP_STEALTH
+int tcp_stealth_integrity(__be16 *hash, u8 *secret, u8 *payload, int len=
)
+{
+	struct scatterlist sg[2];
+	struct crypto_hash *tfm;
+	struct hash_desc desc;
+	__be16 h[MD5_DIGEST_WORDS * 2];
+	int i;
+	int err =3D 0;
+
+	tfm =3D crypto_alloc_hash("md5", 0, CRYPTO_ALG_ASYNC);
+	if (IS_ERR(tfm)) {
+		err =3D -PTR_ERR(tfm);
+		goto out;
+	}
+	desc.tfm =3D tfm;
+	desc.flags =3D 0;
+
+	sg_init_table(sg, 2);
+	sg_set_buf(&sg[0], secret, MD5_MESSAGE_BYTES);
+	sg_set_buf(&sg[1], payload, len);
+
+	if (crypto_hash_digest(&desc, sg, MD5_MESSAGE_BYTES + len, (u8 *)h)) {
+		err =3D -EFAULT;
+		goto out;
+	}
+
+	*hash =3D be16_to_cpu(h[0]);
+	for (i =3D 1; i < MD5_DIGEST_WORDS * 2; i++)
+		*hash ^=3D be16_to_cpu(h[i]);
+
+out:
+	crypto_free_hash(tfm);
+	return err;
+}
+#endif
+
 /*
  *	Socket option code for TCP.
  */
@@ -2359,6 +2396,67 @@ static int do_tcp_setsockopt(struct sock
 		release_sock(sk);
 		return err;
 	}
+#ifdef CONFIG_TCP_STEALTH
+	case TCP_STEALTH: {
+		u8 secret[MD5_MESSAGE_BYTES] =3D { 0 };
+
+		val =3D copy_from_user(secret, optval,
+				     min_t(unsigned int, optlen,
+					   MD5_MESSAGE_BYTES));
+
+		if (val !=3D 0)
+			return -EFAULT;
+
+		lock_sock(sk);
+		memcpy(tp->stealth.secret, secret, MD5_MESSAGE_BYTES);
+		tp->stealth.mode =3D TCP_STEALTH_MODE_AUTH;
+		tp->stealth.mstamp.v64 =3D 0;
+		tp->stealth.saw_tsval =3D false;
+		release_sock(sk);
+		return err;
+	}
+	case TCP_STEALTH_INTEGRITY: {
+		u8 *payload;
+
+		lock_sock(sk);
+
+		if (!(tp->stealth.mode & TCP_STEALTH_MODE_AUTH)) {
+			err =3D -EOPNOTSUPP;
+			goto stealth_integrity_out_1;
+		}
+
+		if (optlen < 1 || optlen > USHRT_MAX) {
+			err =3D -EINVAL;
+			goto stealth_integrity_out_1;
+		}
+
+		payload =3D vmalloc(optlen);
+		if (!payload) {
+			err =3D -ENOMEM;
+			goto stealth_integrity_out_1;
+		}
+
+		val =3D copy_from_user(payload, optval, optlen);
+		if (val !=3D 0) {
+			err =3D -EFAULT;
+			goto stealth_integrity_out_2;
+		}
+
+		err =3D tcp_stealth_integrity(&tp->stealth.integrity_hash,
+					    tp->stealth.secret, payload,
+					    optlen);
+		if (err)
+			goto stealth_integrity_out_2;
+
+		tp->stealth.mode |=3D TCP_STEALTH_MODE_INTEGRITY;
+
+stealth_integrity_out_2:
+		vfree(payload);
+stealth_integrity_out_1:
+		release_sock(sk);
+		return err;
+	}
+#endif
 	default:
 		/* fallthru */
 		break;
@@ -2600,6 +2698,18 @@ static int do_tcp_setsockopt(struct sock
 		tp->notsent_lowat =3D val;
 		sk->sk_write_space(sk);
 		break;
+#ifdef CONFIG_TCP_STEALTH
+	case TCP_STEALTH_INTEGRITY_LEN:
+		if (!(tp->stealth.mode & TCP_STEALTH_MODE_AUTH)) {
+			err =3D -EOPNOTSUPP;
+		} else if (val < 1 || val > USHRT_MAX) {
+			err =3D -EINVAL;
+		} else {
+			tp->stealth.integrity_len =3D val;
+			tp->stealth.mode |=3D TCP_STEALTH_MODE_INTEGRITY_LEN;
+		}
+		break;
+#endif
 	default:
 		err =3D -ENOPROTOOPT;
 		break;
diff -Nurp linux-3.18-rc3/net/ipv4/tcp_input.c linux-3.18-rc3-knock/net/i=
pv4/tcp_input.c
--- linux-3.18-rc3/net/ipv4/tcp_input.c	2014-11-03 00:01:51.000000000 +01=
00
+++ linux-3.18-rc3-knock/net/ipv4/tcp_input.c	2014-11-06 21:26:34.9760170=
01 +0100
@@ -77,6 +77,9 @@
 #include <linux/errqueue.h>
=20
 int sysctl_tcp_timestamps __read_mostly =3D 1;
+#ifdef CONFIG_TCP_STEALTH
+EXPORT_SYMBOL(sysctl_tcp_timestamps);
+#endif
 int sysctl_tcp_window_scaling __read_mostly =3D 1;
 int sysctl_tcp_sack __read_mostly =3D 1;
 int sysctl_tcp_fack __read_mostly =3D 1;
@@ -3715,6 +3718,47 @@ static bool tcp_fast_parse_options(const
 	return true;
 }
=20
+#ifdef CONFIG_TCP_STEALTH
+/* Parse only the TSVal field of the TCP Timestamp option header.
+ */
+const bool tcp_parse_tsval_option(u32 *tsval, const struct tcphdr *th)
+{
+	int length =3D (th->doff << 2) - sizeof(*th);
+	const u8 *ptr =3D (const u8 *)(th + 1);
+
+	/* If the TCP option is too short, we can short cut */
+	if (length < TCPOLEN_TIMESTAMP)
+		return false;
+
+	while (length > 0) {
+		int opcode =3D *ptr++;
+		int opsize;
+
+		switch (opcode) {
+		case TCPOPT_EOL:
+			return false;
+		case TCPOPT_NOP:
+			length--;
+			continue;
+		case TCPOPT_TIMESTAMP:
+			opsize =3D *ptr++;
+			if (opsize !=3D TCPOLEN_TIMESTAMP || opsize > length)
+				return false;
+			*tsval =3D get_unaligned_be32(ptr);
+			return true;
+		default:
+			opsize =3D *ptr++;
+			if (opsize < 2 || opsize > length)
+				return false;
+		}
+		ptr +=3D opsize - 2;
+		length -=3D opsize;
+	}
+	return false;
+}
+EXPORT_SYMBOL(tcp_parse_tsval_option);
+#endif
+
 #ifdef CONFIG_TCP_MD5SIG
 /*
  * Parse MD5 Signature option
@@ -4384,6 +4428,31 @@ err:
 	return -ENOMEM;
 }
=20
+#ifdef CONFIG_TCP_STEALTH
+static int __tcp_stealth_integrity_check(struct sock *sk, struct sk_buff=
 *skb)
+{
+	struct tcphdr *th =3D tcp_hdr(skb);
+	struct tcp_sock *tp =3D tcp_sk(sk);
+	u16 hash;
+	__be32 seq =3D cpu_to_be32(TCP_SKB_CB(skb)->seq - 1);
+	char *data =3D skb->data + th->doff * 4;
+	int len =3D skb->len - th->doff * 4;
+
+	if (len < tp->stealth.integrity_len)
+		return 1;
+
+	if (tcp_stealth_integrity(&hash, tp->stealth.secret, data,
+				  tp->stealth.integrity_len))
+		return 1;
+
+	if (be32_isn_to_be16_ih(seq) !=3D cpu_to_be16(hash))
+		return 1;
+
+	tp->stealth.mode &=3D ~TCP_STEALTH_MODE_INTEGRITY_LEN;
+	return 0;
+}
+#endif
+
 static void tcp_data_queue(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
@@ -4393,6 +4462,14 @@ static void tcp_data_queue(struct sock *
 	if (TCP_SKB_CB(skb)->seq =3D=3D TCP_SKB_CB(skb)->end_seq)
 		goto drop;
=20
+#ifdef CONFIG_TCP_STEALTH
+	if (unlikely(tp->stealth.mode & TCP_STEALTH_MODE_INTEGRITY_LEN) &&
+	    __tcp_stealth_integrity_check(sk, skb)) {
+		tcp_reset(sk);
+		goto drop;
+	}
+#endif
+
 	skb_dst_drop(skb);
 	__skb_pull(skb, tcp_hdr(skb)->doff * 4);
=20
@@ -5156,6 +5233,15 @@ void tcp_rcv_established(struct sock *sk
 			int eaten =3D 0;
 			bool fragstolen =3D false;
=20
+#ifdef CONFIG_TCP_STEALTH
+			if (unlikely(tp->stealth.mode &
+				     TCP_STEALTH_MODE_INTEGRITY_LEN) &&
+			    __tcp_stealth_integrity_check(sk, skb)) {
+				tcp_reset(sk);
+				goto discard;
+			}
+#endif
+
 			if (tp->ucopy.task =3D=3D current &&
 			    tp->copied_seq =3D=3D tp->rcv_nxt &&
 			    len - tcp_header_len <=3D tp->ucopy.len &&
diff -Nurp linux-3.18-rc3/net/ipv4/tcp_ipv4.c linux-3.18-rc3-knock/net/ip=
v4/tcp_ipv4.c
--- linux-3.18-rc3/net/ipv4/tcp_ipv4.c	2014-11-03 00:01:51.000000000 +010=
0
+++ linux-3.18-rc3-knock/net/ipv4/tcp_ipv4.c	2014-11-06 21:26:34.97601700=
1 +0100
@@ -75,6 +75,7 @@
 #include <net/secure_seq.h>
 #include <net/tcp_memcontrol.h>
 #include <net/busy_poll.h>
+#include <net/secure_seq.h>
=20
 #include <linux/inet.h>
 #include <linux/ipv6.h>
@@ -235,6 +236,21 @@ int tcp_v4_connect(struct sock *sk, stru
 	sk->sk_gso_type =3D SKB_GSO_TCPV4;
 	sk_setup_caps(sk, &rt->dst);
=20
+#ifdef CONFIG_TCP_STEALTH
+	/* If CONFIG_TCP_STEALTH is defined, we need to know the timestamp as
+	 * early as possible and thus move taking the snapshot of tcp_time_stam=
p
+	 * here.
+	 */
+	skb_mstamp_get(&tp->stealth.mstamp);
+
+	if (!tp->write_seq && likely(!tp->repair) &&
+	    unlikely(tp->stealth.mode & TCP_STEALTH_MODE_AUTH))
+		tp->write_seq =3D tcp_stealth_sequence_number(sk,
+					&inet->inet_daddr,
+					sizeof(inet->inet_daddr),
+					usin->sin_port);
+#endif
+
 	if (!tp->write_seq && likely(!tp->repair))
 		tp->write_seq =3D secure_tcp_sequence_number(inet->inet_saddr,
 							   inet->inet_daddr,
@@ -1423,6 +1439,8 @@ static struct sock *tcp_v4_hnd_req(struc
  */
 int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 {
+	struct tcp_sock *tp =3D tcp_sk(sk);
+	struct tcphdr *th =3D tcp_hdr(skb);
 	struct sock *rsk;
=20
 	if (sk->sk_state =3D=3D TCP_ESTABLISHED) { /* Fast path */
@@ -1443,6 +1461,15 @@ int tcp_v4_do_rcv(struct sock *sk, struc
 	if (skb->len < tcp_hdrlen(skb) || tcp_checksum_complete(skb))
 		goto csum_err;
=20
+#ifdef CONFIG_TCP_STEALTH
+	if (sk->sk_state =3D=3D TCP_LISTEN && th->syn && !th->fin &&
+	    unlikely(tp->stealth.mode & TCP_STEALTH_MODE_AUTH) &&
+	    tcp_stealth_do_auth(sk, skb)) {
+		rsk =3D sk;
+		goto reset;
+	}
+#endif
+
 	if (sk->sk_state =3D=3D TCP_LISTEN) {
 		struct sock *nsk =3D tcp_v4_hnd_req(sk, skb);
 		if (!nsk)
diff -Nurp linux-3.18-rc3/net/ipv4/tcp_output.c linux-3.18-rc3-knock/net/=
ipv4/tcp_output.c
--- linux-3.18-rc3/net/ipv4/tcp_output.c	2014-11-03 00:01:51.000000000 +0=
100
+++ linux-3.18-rc3-knock/net/ipv4/tcp_output.c	2014-11-24 14:29:25.380852=
760 +0100
@@ -915,6 +915,13 @@ static int tcp_transmit_skb(struct sock
 	tcb =3D TCP_SKB_CB(skb);
 	memset(&opts, 0, sizeof(opts));
=20
+#ifdef TCP_STEALTH
+	if (unlikely(tcb->tcp_flags & TCPHDR_SYN &&
+		     tp->stealth.mode & TCP_STEALTH_MODE_AUTH)) {
+		skb->skb_mstamp =3D tp->stealth.mstamp;
+	}
+#endif
+
 	if (unlikely(tcb->tcp_flags & TCPHDR_SYN))
 		tcp_options_size =3D tcp_syn_options(sk, skb, &opts, &md5);
 	else
@@ -3109,7 +3116,15 @@ int tcp_connect(struct sock *sk)
 	skb_reserve(buff, MAX_TCP_HEADER);
=20
 	tcp_init_nondata_skb(buff, tp->write_seq++, TCPHDR_SYN);
+#ifdef CONFIG_TCP_STEALTH
+	/* The timetamp was already made at the time the ISN was generated
+	 * as we need to know its value in the stealth_tcp_sequence_number()
+	 * function.
+	 */
+	tp->retrans_stamp =3D tp->stealth.mstamp.stamp_jiffies;
+#else
 	tp->retrans_stamp =3D tcp_time_stamp;
+#endif
 	tcp_connect_queue_skb(sk, buff);
 	tcp_ecn_send_syn(sk, buff);
=20
diff -Nurp linux-3.18-rc3/net/ipv6/tcp_ipv6.c linux-3.18-rc3-knock/net/ip=
v6/tcp_ipv6.c
--- linux-3.18-rc3/net/ipv6/tcp_ipv6.c	2014-11-03 00:01:51.000000000 +010=
0
+++ linux-3.18-rc3-knock/net/ipv6/tcp_ipv6.c	2014-11-06 21:26:34.97601700=
1 +0100
@@ -63,6 +63,7 @@
 #include <net/secure_seq.h>
 #include <net/tcp_memcontrol.h>
 #include <net/busy_poll.h>
+#include <net/secure_seq.h>
=20
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
@@ -297,6 +298,21 @@ static int tcp_v6_connect(struct sock *s
=20
 	ip6_set_txhash(sk);
=20
+#ifdef CONFIG_TCP_STEALTH
+	/* If CONFIG_TCP_STEALTH is defined, we need to know the timestamp as
+	 * early as possible and thus move taking the snapshot of tcp_time_stam=
p
+	 * here.
+	 */
+	skb_mstamp_get(&tp->stealth.mstamp);
+
+	if (!tp->write_seq && likely(!tp->repair) &&
+	    unlikely(tp->stealth.mode & TCP_STEALTH_MODE_AUTH))
+		tp->write_seq =3D tcp_stealth_sequence_number(sk,
+					sk->sk_v6_daddr.s6_addr32,
+					sizeof(sk->sk_v6_daddr),
+					inet->inet_dport);
+#endif
+
 	if (!tp->write_seq && likely(!tp->repair))
 		tp->write_seq =3D secure_tcpv6_sequence_number(np->saddr.s6_addr32,
 							     sk->sk_v6_daddr.s6_addr32,
@@ -1251,7 +1267,8 @@ out:
 static int tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 {
 	struct ipv6_pinfo *np =3D inet6_sk(sk);
-	struct tcp_sock *tp;
+	struct tcp_sock *tp =3D tcp_sk(sk);
+	struct tcphdr *th =3D tcp_hdr(skb);
 	struct sk_buff *opt_skb =3D NULL;
=20
 	/* Imagine: socket is IPv6. IPv4 packet arrives,
@@ -1310,6 +1327,13 @@ static int tcp_v6_do_rcv(struct sock *sk
 	if (skb->len < tcp_hdrlen(skb) || tcp_checksum_complete(skb))
 		goto csum_err;
=20
+#ifdef CONFIG_TCP_STEALTH
+	if (sk->sk_state =3D=3D TCP_LISTEN && th->syn && !th->fin &&
+	    tp->stealth.mode & TCP_STEALTH_MODE_AUTH &&
+	    tcp_stealth_do_auth(sk, skb))
+		goto reset;
+#endif
+
 	if (sk->sk_state =3D=3D TCP_LISTEN) {
 		struct sock *nsk =3D tcp_v6_hnd_req(sk, skb);
 		if (!nsk)

--------------050300000401010001010807
Content-Type: application/pgp-signature;
 name="tcp_stealth_3.18.diff.sig"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="tcp_stealth_3.18.diff.sig"

iQEcBAABAgAGBQJUpHCzAAoJENwkOWttRRA4xgUH/RU7PapjFex1kjfqN59XMpMNA+bNHmUs
koY1IIDu9mUWl+w7VCfrtqTpX/J6hOUNrF6pY1PONKF/1jAoMmy7YbgjSXKnOQgu2m8lNAOW
hYxVDIc0pkmR3qJmQY1IBt8ijF3RaSij5g3yMddD3wbq9m2STkVrHzD9WngaJipwIwXPqIN7
6M8t81rF2Gf+AcUISjPxJLshMk0QeW6xjUaSpQcCLjb6bW+SNNkTaCQ6Iy56jLmQkn71CUIy
kfdlu1dJJgblqU2eapDhCWJ/kb+l8gShO/O8WzwOYQZT4JF7ebdsInT3lvtEKzBa/0v3DrSS
a+5Mn9HK2gBEOlgjq1Eic2A=
--------------050300000401010001010807--
