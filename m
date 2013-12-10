From: Christian Grothoff <grothoff@in.tum.de>
Subject: [PATCH] TCP: add option for silent port knocking with integrity protection
Date: Tue, 10 Dec 2013 19:35:36 +0100
Message-ID: <52A75EF8.3010308@in.tum.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="----enig2IVCQCAHKJKTVTBTXXDBW"
Cc: linux-kernel@vger.kernel.org, knock@gnunet.org,
	Jacob Appelbaum <jacob@appelbaum.net>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out1.informatik.tu-muenchen.de ([131.159.0.8]:51403 "EHLO
	smtp1.informatik.tu-muenchen.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752530Ab3LJSms (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 13:42:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
------enig2IVCQCAHKJKTVTBTXXDBW
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hi!

We've written a patch to add support for a modern variant of silent TCP
port knocking to Linux, and hope to convince you to include it in the
kernel by default.

The motivation is simple: given security services that stockpile
undisclosed exploits, running TCP services on a visible port is asking
for trouble.  Modern port scanners can scan IPv4 in less than an hour
from a single system.  Still, we need to run services, such as SSH or
VPN access on public IP addresses and make (some of) them available to
the global Internet.  Furthermore, even on the LAN it might be good to
have some additional protection against an insider attack.  Some
countries or ISPs may declare the use of certain software illegal, so
again hiding the fact that a service is running might offer some basic
protections.  The same is true for services like Tor bridges that
certain countries may try to enumerate and block.  Finally, if we use
port knocking to hide open ports, we need to guard against
man-in-the-middle attacks, as an adversary may permit and observe the
initial handshake and take over the TCP connection after the knocking
sequence has opened the path to the application.

Naturally, all of this should work with clients behind NAT, be hard to
observe using network analysis tools, and be easy to administer and
deploy.

Our patch does all of this.  TCP applications can activate knocking
using 'setsockopt' with a new TCP_STEALTH option. The knock is included
in the SQN field of the TCP SYN, making it indistinguishable from an
ordinary TCP handshake.  The knock can optionally include bits that
authenticate (!) the first packet of the TCP payload, thus preventing a
man-in-the-middle attack on the first bytes of the client's data stream.
A client sending its public key first and then continuing with encrypted
transmissions signed by that key can thus defeat devices that hijack
connections after the TCP handshake.

The patch is attached to this e-mail.  We've documented the method in
detail at https://gnunet.org/knock, including example client-server
applications and a detailed technical report (in PDF format).

Please let us know if we can do anything else to convince you to include
this patch, or to expedite its adaptation.


Happy hacking!

Maurice Leclair, Julian Kirsch & Christian Grothoff
knock@gnunet.org


Further details (from our website, for those prefering to read inline):


Background
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

Today, port scanners can scan all IPv4 addresses in less than one hour.
Port knocking is a method for making TCP servers less visible on the
Internet. The basic idea is to make a TCP server not respond
(positively) to a TCP SYN request unless a particular "knock" packet has
been sent first. This can be helpful for security, as an attacker that
cannot establish a TCP connection also cannot really attack the TCP
server. There are a bunch of existing user-space tools, such as Knock
Knock and knockd. Most of these implementations send some other traffic
(such as a UDP packet) to the target host to have it (briefly) open the
server port. A particularly noteworthy recent idea in this domain is the
SilentKnock, which adds the idea of integrating the knock secret in the
initial TCP SYN packet in the SQN field, which is a technique borrowed
from network steganography.


Features of Knock
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

* Knocking is stealthy: as in SilentKnock, the secret to open the port
is part of the TCP SYN packet's SQN, so there is not a single extra
packet on the wire (one Knock instead of KnockKnock). Thus, using Knock
is indistinguishable on the network from a standard TCP handshake.
Furthermore, as there is only one packet, there is no window of
opportunity for an attacker to use, as would be the case if a first
packet enables the server.
* Knocking is done in the Linux kernel. Applications can activate
Knock with a single additional setsockopt call (in both client and
server). Thus, once Linux has been patched, deployment will be much
simpler compared to other implementations. Also, as Knock operates in
the Kernel, timing attacks should be much harder to do.
* Our Knock optionally does not merely enable opening the connection,
but also can be used to protect the first N bytes of the TCP payload.
Thus, given a sane protocol being run above TCP (one begins with a key
exchange), an active attacker cannot simply take over the TCP connection
after the handshake without also being locked into sending the same TCP
payload. Thus, if the client begins by sending his public key and then
continues to send data that must be authenticated with that key, even an
active man-in-the-middle adversary cannot hijack the connection.
* Knock is designed to work with clients behind NAT. Only NAT
implementations that change the SQN are not supported (those should be
rare, but we have no hard data on this).
* The main disadvantage is that the SQN only has 32 bits, so a
brute-force attack can succeed against Knock. However, an attack
involving (on average) billions of packets is at least more likely to be
noticed. Not to mention that the adversary would still need to know
about the existence of the stealthy TCP server in the first place.
* Knock is free software and provided as a simple Kernel modification
(which should be easy to audit)


Further reading
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

A 3-page PDF with the full details on Knock is available at
  https://gnunet.org/sites/default/files/knock.pdf

Toy example programs are attached to
  https://gnunet.org/knock as well.



Acknowledgements
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

Knock was designed and implemented by Julian Kirsch, Maurice Leclaire
and Christian Grothoff. We thank Jacob Appelbaum for constructive
discussions on an earlier version of the design.



More comments about the patch:
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D

- The attached patch is against 3.12, but we also have one
  on the website against 3.10.
- All new code is #ifdef CONFIG_TCP_STEALTH



From: <knock@gnunet.org>


This patch adds three new TCP socket options to enable stealthy
TCP sockets using TCP SQN numbers derived from a shared secret.
The respective system calls store the information in new members
of the TCP socket struct.  If the SQN does not match expectations,
TCP SYN packets are rejected (RST).

New routines were added to check/compute the expected TCP
sequence number to accept connections to stealthy servers.
The expected sequence number is computed with MD5.

If integrity checking is enabled, the first bytes of
payload are hashed and checked against the payload as well.
If they do not match, the connection is dropped.

Signed-off-by: Christian Grothoff <christian@grothoff.org>
---
diff -urNp linux-3.12.4.old/include/linux/tcp.h
linux-3.12.4/include/linux/tcp.h
--- linux-3.12.4.old/include/linux/tcp.h	2013-12-08 17:18:58.000000000 +0=
100
+++ linux-3.12.4/include/linux/tcp.h	2013-12-10 15:47:18.000082837 +0100
@@ -20,6 +20,7 @@

 #include <linux/skbuff.h>
 #include <linux/dmaengine.h>
+#include <linux/cryptohash.h>
 #include <net/sock.h>
 #include <net/inet_connection_sock.h>
 #include <net/inet_timewait_sock.h>
@@ -314,6 +315,19 @@ struct tcp_sock {
 	struct tcp_md5sig_info	__rcu *md5sig_info;
 #endif

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
+	} stealth;
+#endif
+
 /* TCP fastopen related information */
 	struct tcp_fastopen_request *fastopen_req;
 	/* fastopen_rsk points to request_sock that resulted in this big
diff -urNp linux-3.12.4.old/include/net/secure_seq.h
linux-3.12.4/include/net/secure_seq.h
--- linux-3.12.4.old/include/net/secure_seq.h	2013-12-08
17:18:58.000000000 +0100
+++ linux-3.12.4/include/net/secure_seq.h	2013-12-10 15:47:18.004082863
+0100
@@ -10,8 +10,12 @@ extern u32 secure_ipv6_port_ephemeral(co
 				      __be16 dport);
 extern __u32 secure_tcp_sequence_number(__be32 saddr, __be32 daddr,
 					__be16 sport, __be16 dport);
+extern __u32 stealth_tcp_sequence_number(__be32 daddr, __be16 dport,
__u8 *secret,
+					 __u16 integrity);
 extern __u32 secure_tcpv6_sequence_number(const __be32 *saddr, const
__be32 *daddr,
 					  __be16 sport, __be16 dport);
+extern __u32 stealth_tcpv6_sequence_number(const __be32 *daddr, __be16
dport,
+					   __u8 *secret, __u16 integrity);
 extern u64 secure_dccp_sequence_number(__be32 saddr, __be32 daddr,
 				       __be16 sport, __be16 dport);
 extern u64 secure_dccpv6_sequence_number(__be32 *saddr, __be32 *daddr,
diff -urNp linux-3.12.4.old/include/net/tcp.h linux-3.12.4/include/net/tc=
p.h
--- linux-3.12.4.old/include/net/tcp.h	2013-12-08 17:18:58.000000000 +010=
0
+++ linux-3.12.4/include/net/tcp.h	2013-12-10 15:47:18.012082891 +0100
@@ -448,6 +448,7 @@ extern void tcp_parse_options(const stru
 			      struct tcp_options_received *opt_rx,
 			      int estab, struct tcp_fastopen_cookie *foc);
 extern const u8 *tcp_parse_md5sig_option(const struct tcphdr *th);
+extern int tcp_stealth_integrity(u16 *hash, u8 *secret, u8 *payload,
int len);

 /*
  *	TCP v4 functions exported for the inet6 API
diff -urNp linux-3.12.4.old/include/uapi/linux/tcp.h
linux-3.12.4/include/uapi/linux/tcp.h
--- linux-3.12.4.old/include/uapi/linux/tcp.h	2013-12-08
17:18:58.000000000 +0100
+++ linux-3.12.4/include/uapi/linux/tcp.h	2013-12-10 15:51:19.417279938
+0100
@@ -112,6 +112,9 @@ enum {
 #define TCP_FASTOPEN		23	/* Enable FastOpen on listeners */
 #define TCP_TIMESTAMP		24
 #define TCP_NOTSENT_LOWAT	25	/* limit number of unsent bytes in write
queue */
+#define TCP_STEALTH		26
+#define TCP_STEALTH_INTEGRITY	27
+#define TCP_STEALTH_INTEGRITY_LEN	28

 struct tcp_repair_opt {
 	__u32	opt_code;
diff -urNp linux-3.12.4.old/net/core/secure_seq.c
linux-3.12.4/net/core/secure_seq.c
--- linux-3.12.4.old/net/core/secure_seq.c	2013-12-08 17:18:58.000000000
+0100
+++ linux-3.12.4/net/core/secure_seq.c	2013-12-10 15:47:18.028082976 +010=
0
@@ -72,6 +72,26 @@ __u32 secure_tcpv6_sequence_number(const
 }
 EXPORT_SYMBOL(secure_tcpv6_sequence_number);

+#ifdef CONFIG_TCP_STEALTH
+__u32 stealth_tcpv6_sequence_number(const __be32 *daddr, __be16 dport,
+				    __u8 *secret, __u16 integrity)
+{
+	u32 hash[MD5_DIGEST_WORDS];
+	u32 sec[MD5_MESSAGE_BYTES / sizeof(u32)];
+	u32 i;
+
+	for (i =3D 0; i < MD5_DIGEST_WORDS; i++)
+		hash[i] =3D be32_to_cpu(daddr[i]);
+	hash[2] ^=3D (integrity << 16) | be16_to_cpu(dport);
+	for (i =3D 0; i < MD5_MESSAGE_BYTES / sizeof(u32); i++)
+		sec[i] =3D be32_to_cpu(((__be32 *)secret)[i]);
+
+	md5_transform(hash, sec);
+
+	return hash[0] ^ hash[1] ^ hash[2] ^ hash[3];
+}
+#endif
+
 u32 secure_ipv6_port_ephemeral(const __be32 *saddr, const __be32 *daddr,=

 			       __be16 dport)
 {
@@ -137,6 +157,29 @@ __u32 secure_tcp_sequence_number(__be32
 	return seq_scale(hash[0]);
 }

+#ifdef CONFIG_TCP_STEALTH
+__u32 stealth_tcp_sequence_number(__be32 daddr, __be16 dport, __u8 *secr=
et,
+				  __u16 integrity)
+{
+	u32 hash[MD5_DIGEST_WORDS];
+	u32 sec[MD5_MESSAGE_BYTES / sizeof(u32)];
+	u32 i;
+
+
+	hash[0] =3D be32_to_cpu(((__be32 *)secret)[10]);
+	hash[1] =3D be32_to_cpu(daddr);
+	hash[2] =3D (integrity << 16) | be16_to_cpu(dport);
+	hash[3] =3D be32_to_cpu(((__be32 *)secret)[15]);
+
+	for (i =3D 0; i < MD5_MESSAGE_BYTES / sizeof(u32); i++)
+		sec[i] =3D be32_to_cpu(((__be32 *)secret)[i]);
+
+	md5_transform(hash, sec);
+
+	return hash[0] ^ hash[1] ^ hash[2] ^ hash[3];
+}
+#endif
+
 u32 secure_ipv4_port_ephemeral(__be32 saddr, __be32 daddr, __be16 dport)=

 {
 	u32 hash[MD5_DIGEST_WORDS];
diff -urNp linux-3.12.4.old/net/ipv4/Kconfig linux-3.12.4/net/ipv4/Kconfi=
g
--- linux-3.12.4.old/net/ipv4/Kconfig	2013-12-08 17:18:58.000000000 +0100=

+++ linux-3.12.4/net/ipv4/Kconfig	2013-12-10 15:47:18.028082976 +0100
@@ -618,3 +618,13 @@ config TCP_MD5SIG
 	  on the Internet.

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
diff -urNp linux-3.12.4.old/net/ipv4/tcp.c linux-3.12.4/net/ipv4/tcp.c
--- linux-3.12.4.old/net/ipv4/tcp.c	2013-12-08 17:18:58.000000000 +0100
+++ linux-3.12.4/net/ipv4/tcp.c	2013-12-10 15:47:18.028082976 +0100
@@ -2380,6 +2380,43 @@ static int tcp_repair_options_est(struct
 	return 0;
 }

+#ifdef CONFIG_TCP_STEALTH
+int tcp_stealth_integrity(u16 *hash, u8 *secret, u8 *payload, int len)
+{
+	struct scatterlist sg[2];
+	struct crypto_hash *tfm;
+	struct hash_desc desc;
+	u16 h[MD5_DIGEST_WORDS * 2];
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
+	*hash =3D 0;
+	for (i =3D 0; i < MD5_DIGEST_WORDS * 2; i++)
+		*hash ^=3D h[i];
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
@@ -2410,6 +2447,65 @@ static int do_tcp_setsockopt(struct sock
 		release_sock(sk);
 		return err;
 	}
+#ifdef CONFIG_TCP_STEALTH
+	case TCP_STEALTH: {
+		u8 secret[MD5_MESSAGE_BYTES];
+
+		if (optlen < MD5_MESSAGE_BYTES)
+			return -EINVAL;
+
+		val =3D copy_from_user(secret, optval, MD5_MESSAGE_BYTES);
+		if (val !=3D 0)
+			return -EFAULT;
+
+		lock_sock(sk);
+		memcpy(tp->stealth.secret, secret, MD5_MESSAGE_BYTES);
+		tp->stealth.mode =3D TCP_STEALTH_MODE_AUTH;
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
@@ -2651,6 +2747,18 @@ static int do_tcp_setsockopt(struct sock
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
diff -urNp linux-3.12.4.old/net/ipv4/tcp_input.c
linux-3.12.4/net/ipv4/tcp_input.c
--- linux-3.12.4.old/net/ipv4/tcp_input.c	2013-12-08 17:18:58.000000000
+0100
+++ linux-3.12.4/net/ipv4/tcp_input.c	2013-12-10 15:47:18.028082976 +0100=

@@ -4293,6 +4293,31 @@ err:
 	return -ENOMEM;
 }

+#ifdef CONFIG_TCP_STEALTH
+static int tcp_stealth_integrity_check(struct sock *sk, struct sk_buff
*skb)
+{
+	struct tcphdr *th =3D tcp_hdr(skb);
+	struct tcp_sock *tp =3D tcp_sk(sk);
+	u16 hash;
+	u16 seq =3D TCP_SKB_CB(skb)->seq - 1;
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
+	if (seq !=3D hash)
+		return 1;
+
+	tp->stealth.mode &=3D ~TCP_STEALTH_MODE_INTEGRITY_LEN;
+	return 0;
+}
+#endif
+
 static void tcp_data_queue(struct sock *sk, struct sk_buff *skb)
 {
 	const struct tcphdr *th =3D tcp_hdr(skb);
@@ -4303,6 +4328,14 @@ static void tcp_data_queue(struct sock *
 	if (TCP_SKB_CB(skb)->seq =3D=3D TCP_SKB_CB(skb)->end_seq)
 		goto drop;

+#ifdef CONFIG_TCP_STEALTH
+	if (unlikely(tp->stealth.mode & TCP_STEALTH_MODE_INTEGRITY_LEN) &&
+	    tcp_stealth_integrity_check(sk, skb)) {
+		tcp_reset(sk);
+		goto drop;
+	}
+#endif
+
 	skb_dst_drop(skb);
 	__skb_pull(skb, th->doff * 4);

@@ -5157,6 +5190,15 @@ void tcp_rcv_established(struct sock *sk
 			int copied_early =3D 0;
 			bool fragstolen =3D false;

+#ifdef CONFIG_TCP_STEALTH
+			if (unlikely(tp->stealth.mode &
+				     TCP_STEALTH_MODE_INTEGRITY_LEN) &&
+			    tcp_stealth_integrity_check(sk, skb)) {
+				tcp_reset(sk);
+				goto discard;
+			}
+#endif
+
 			if (tp->copied_seq =3D=3D tp->rcv_nxt &&
 			    len - tcp_header_len <=3D tp->ucopy.len) {
 #ifdef CONFIG_NET_DMA
diff -urNp linux-3.12.4.old/net/ipv4/tcp_ipv4.c
linux-3.12.4/net/ipv4/tcp_ipv4.c
--- linux-3.12.4.old/net/ipv4/tcp_ipv4.c	2013-12-08 17:18:58.000000000 +0=
100
+++ linux-3.12.4/net/ipv4/tcp_ipv4.c	2013-12-10 15:47:18.028082976 +0100
@@ -235,6 +235,20 @@ int tcp_v4_connect(struct sock *sk, stru
 	sk->sk_gso_type =3D SKB_GSO_TCPV4;
 	sk_setup_caps(sk, &rt->dst);

+#ifdef CONFIG_TCP_STEALTH
+	if (!tp->write_seq && likely(!tp->repair) &&
+ 	    unlikely(tp->stealth.mode & TCP_STEALTH_MODE_AUTH)) {
+		tp->write_seq =3D stealth_tcp_sequence_number(inet->inet_daddr,
+							    usin->sin_port,
+							    tp->stealth.secret,
+							    tp->stealth.integrity_hash);
+		if (tp->stealth.mode & TCP_STEALTH_MODE_INTEGRITY) {
+			tp->write_seq &=3D (BIT(16) - 1) << 16;
+			tp->write_seq |=3D tp->stealth.integrity_hash;
+		}
+	}
+#endif
+
 	if (!tp->write_seq && likely(!tp->repair))
 		tp->write_seq =3D secure_tcp_sequence_number(inet->inet_saddr,
 							   inet->inet_daddr,
@@ -1776,6 +1790,8 @@ static __sum16 tcp_v4_checksum_init(stru
  */
 int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 {
+	struct tcp_sock *tp =3D tcp_sk(sk);
+	struct tcphdr *th =3D tcp_hdr(skb);
 	struct sock *rsk;
 #ifdef CONFIG_TCP_MD5SIG
 	/*
@@ -1806,6 +1822,32 @@ int tcp_v4_do_rcv(struct sock *sk, struc
 	if (skb->len < tcp_hdrlen(skb) || tcp_checksum_complete(skb))
 		goto csum_err;

+#ifdef CONFIG_TCP_STEALTH
+	if (sk->sk_state =3D=3D TCP_LISTEN && th->syn && !th->fin &&
+	    unlikely(tp->stealth.mode & TCP_STEALTH_MODE_AUTH)) {
+		u32 hash;
+		u32 seq =3D be32_to_cpu(th->seq);
+		if (tp->stealth.mode & TCP_STEALTH_MODE_INTEGRITY_LEN)
+			tp->stealth.integrity_hash =3D seq;
+		hash =3D stealth_tcp_sequence_number(ip_hdr(skb)->daddr,
+						   th->dest,
+						   tp->stealth.secret,
+						   tp->stealth.integrity_hash);
+		if (tp->stealth.mode & TCP_STEALTH_MODE_INTEGRITY_LEN) {
+			if ((seq & ((BIT(16) - 1) << 16)) !=3D
+			    (hash & ((BIT(16) - 1) << 16))) {
+				rsk =3D sk;
+				goto reset;
+			}
+		} else {
+			if (seq !=3D hash) {
+				rsk =3D sk;
+				goto reset;
+			}
+		}
+	}
+#endif
+
 	if (sk->sk_state =3D=3D TCP_LISTEN) {
 		struct sock *nsk =3D tcp_v4_hnd_req(sk, skb);
 		if (!nsk)
diff -urNp linux-3.12.4.old/net/ipv6/tcp_ipv6.c
linux-3.12.4/net/ipv6/tcp_ipv6.c
--- linux-3.12.4.old/net/ipv6/tcp_ipv6.c	2013-12-08 17:18:58.000000000 +0=
100
+++ linux-3.12.4/net/ipv6/tcp_ipv6.c	2013-12-10 15:47:18.032082996 +0100
@@ -296,6 +296,20 @@ static int tcp_v6_connect(struct sock *s
 	if (err)
 		goto late_failure;

+#ifdef CONFIG_TCP_STEALTH
+	if (!tp->write_seq && likely(!tp->repair) &&
+	    unlikely(tp->stealth.mode & TCP_STEALTH_MODE_AUTH)) {
+		tp->write_seq =3D stealth_tcpv6_sequence_number(np->daddr.s6_addr32,
+							      inet->inet_dport,
+							      tp->stealth.secret,
+							      tp->stealth.integrity_hash);
+		if (tp->stealth.mode & TCP_STEALTH_MODE_INTEGRITY) {
+			tp->write_seq &=3D (BIT(16) - 1) << 16;
+			tp->write_seq |=3D tp->stealth.integrity_hash;
+		}
+	}
+#endif
+
 	if (!tp->write_seq && likely(!tp->repair))
 		tp->write_seq =3D secure_tcpv6_sequence_number(np->saddr.s6_addr32,
 							     np->daddr.s6_addr32,
@@ -1305,7 +1319,8 @@ static __sum16 tcp_v6_checksum_init(stru
 static int tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 {
 	struct ipv6_pinfo *np =3D inet6_sk(sk);
-	struct tcp_sock *tp;
+	struct tcp_sock *tp =3D tcp_sk(sk);
+	struct tcphdr *th =3D tcp_hdr(skb);
 	struct sk_buff *opt_skb =3D NULL;

 	/* Imagine: socket is IPv6. IPv4 packet arrives,
@@ -1369,6 +1384,29 @@ static int tcp_v6_do_rcv(struct sock *sk
 	if (skb->len < tcp_hdrlen(skb) || tcp_checksum_complete(skb))
 		goto csum_err;

+#ifdef CONFIG_TCP_STEALTH
+	if (sk->sk_state =3D=3D TCP_LISTEN && th->syn && !th->fin &&
+	    tp->stealth.mode & TCP_STEALTH_MODE_AUTH) {
+		u32 hash;
+		u32 seq =3D be32_to_cpu(th->seq);
+		if (tp->stealth.mode & TCP_STEALTH_MODE_INTEGRITY_LEN)
+			tp->stealth.integrity_hash =3D seq;
+		hash =3D stealth_tcpv6_sequence_number(ipv6_hdr(skb)->
+						     daddr.s6_addr32,
+						     th->dest,
+						     tp->stealth.secret,
+						     tp->stealth.integrity_hash);
+	    	if (tp->stealth.mode & TCP_STEALTH_MODE_INTEGRITY_LEN) {
+			if ((seq & ((BIT(16) - 1) << 16)) !=3D
+			    (hash & ((BIT(16) - 1) << 16)))
+				goto reset;
+		} else {
+			if (seq !=3D hash)
+				goto reset;
+		}
+	}
+#endif
+
 	if (sk->sk_state =3D=3D TCP_LISTEN) {
 		struct sock *nsk =3D tcp_v6_hnd_req(sk, skb);
 		if (!nsk)



------enig2IVCQCAHKJKTVTBTXXDBW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlKnXvgACgkQv2Bwi0hCbH7KEACfVln6tJvRw4eHoofTODv1rp0G
ND0An1w847l9EAURlkB78KBglFZMiSsm
=TTLH
-----END PGP SIGNATURE-----

------enig2IVCQCAHKJKTVTBTXXDBW--
