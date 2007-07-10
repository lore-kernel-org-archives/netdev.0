From: Remi Denis-Courmont <rdenis@simphalempin.com>
Subject: [PATCH] IPv6: optionaly validate RAs on raw sockets
Date: Tue, 10 Jul 2007 21:11:17 +0300
Message-ID: <200707102111.18824@auguste.remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from poy.chewa.net ([194.242.114.73]:3951 "EHLO poy.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756013AbXGJSLW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2007 14:11:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ICMPv6 Router Advertisements may now contain informations that is
mostly of interest to userland. This currently mostly consists of
recursive DNS server addresses (though one should expect other
stuff to come).

This patch adds a setsockopt to ICMPv6 sockets to only deliver Router
Advertisements if they pass the same set of checks as the kernel
IPv6 autoconfiguration does, so that userland can parse attributes it
is interested safely (otherwise, it would get and parse advertisements
that the kernel rejected).

N.B.: not too sure about the option name though...

Signed-off-by: Remi Denis-Courmont <rdenis@simphalempin.com>

diff --git a/include/linux/icmpv6.h b/include/linux/icmpv6.h
index 7c5e981..8c96822 100644
--- a/include/linux/icmpv6.h
+++ b/include/linux/icmpv6.h
@@ -139,6 +139,7 @@ static inline struct icmp6hdr *icmp6_hdr(const stru=
ct sk_buff *skb)
  */
=20
 #define ICMPV6_FILTER			1
+#define ICMPV6_VALID_ADVERT		2
=20
 /*
  *	ICMPV6 filter
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 648bd1f..af72f02 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -343,7 +343,9 @@ struct ipv6_pinfo {
 struct raw6_sock {
 	/* inet_sock has to be the first member of raw6_sock */
 	struct inet_sock	inet;
-	__u32			checksum;	/* perform checksum */
+	__u16			unused;
+	__u8			valid_advert;	/* deliver valid RAs only */
+	__u8			checksum;	/* perform checksum */
 	__u32			offset;		/* checksum offset  */
 	struct icmp6_filter	filter;
 	/* ipv6_pinfo has to be the last member of raw6_sock, see inet6_sk_ge=
neric */
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index a58459a..da6cb50 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -127,12 +127,35 @@ static __inline__ int icmpv6_filter(struct sock *=
sk, struct sk_buff *skb)
=20
 	if (pskb_may_pull(skb, sizeof(struct icmp6hdr))) {
 		__u32 *data =3D &rp->filter.data[0];
-		int bit_nr;
+		int type;
=20
 		icmph =3D (struct icmp6hdr *) skb->data;
-		bit_nr =3D icmph->icmp6_type;
+		type =3D icmph->icmp6_type;
=20
-		return (data[bit_nr >> 5] & (1 << (bit_nr & 31))) !=3D 0;
+		if (data[type >> 5] & (1 << (type & 31)))
+			return 1;
+
+		/* Userland only wants valid router advertisements? */
+		if (type =3D=3D NDISC_ROUTER_ADVERTISEMENT &&
+		    rp->valid_advert) {
+			struct inet6_dev *idev;
+
+			if (!pskb_may_pull(skb, sizeof(struct ra_msg)) ||
+			    !(ipv6_addr_type(&ipv6_hdr(skb)->saddr) &
+			      IPV6_ADDR_LINKLOCAL))
+				return 1;
+
+		        idev =3D in6_dev_get(skb->dev);
+		        if (!idev)
+		                return 1;
+
+			/* Ignore RA when routing */
+			if (idev->cnf.forwarding || !idev->cnf.accept_ra) {
+				in6_dev_put(idev);
+				return 1;
+			}
+			in6_dev_put(idev);
+		}
 	}
 	return 0;
 }
@@ -877,13 +900,26 @@ do_confirm:
 static int rawv6_seticmpfilter(struct sock *sk, int level, int optname=
,
 			       char __user *optval, int optlen)
 {
+	struct raw6_sock *rp =3D raw6_sk(sk);
+
 	switch (optname) {
 	case ICMPV6_FILTER:
 		if (optlen > sizeof(struct icmp6_filter))
 			optlen =3D sizeof(struct icmp6_filter);
-		if (copy_from_user(&raw6_sk(sk)->filter, optval, optlen))
+		if (copy_from_user(&rp->filter, optval, optlen))
 			return -EFAULT;
 		return 0;
+	case ICMPV6_VALID_ADVERT: {
+		int val;
+
+		if (optlen !=3D sizeof(int))
+			return -EINVAL;
+		if (copy_from_user(&val, optval, sizeof(int)))
+			return -EFAULT;
+		/* -1 resets to default, which is actually 0 */
+		rp->valid_advert =3D (val > 0);
+		return 0;
+	}
 	default:
 		return -ENOPROTOOPT;
 	}
@@ -894,25 +930,38 @@ static int rawv6_seticmpfilter(struct sock *sk, i=
nt level, int optname,
 static int rawv6_geticmpfilter(struct sock *sk, int level, int optname=
,
 			       char __user *optval, int __user *optlen)
 {
+	struct raw6_sock *rp =3D raw6_sk(sk);
 	int len;
=20
+	if (get_user(len, optlen))
+		return -EFAULT;
+	if (len < 0)
+		return -EINVAL;
+
 	switch (optname) {
 	case ICMPV6_FILTER:
-		if (get_user(len, optlen))
-			return -EFAULT;
-		if (len < 0)
-			return -EINVAL;
 		if (len > sizeof(struct icmp6_filter))
 			len =3D sizeof(struct icmp6_filter);
-		if (put_user(len, optlen))
+		if (copy_to_user(optval, &rp->filter, len))
 			return -EFAULT;
-		if (copy_to_user(optval, &raw6_sk(sk)->filter, len))
+		break;
+	case ICMPV6_VALID_ADVERT: {
+		int val;
+
+		if (len < sizeof(int))
+			return -EINVAL;
+		val =3D rp->valid_advert;
+		len =3D sizeof(int);
+		if (copy_to_user(optval, &val, sizeof(int)))
 			return -EFAULT;
-		return 0;
+		break;
+	}
 	default:
 		return -ENOPROTOOPT;
 	}
=20
+	if (put_user(len, optlen))
+		return -EFAULT;
 	return 0;
 }
=20

--=20
R=C3=A9mi Denis-Courmont
http://www.remlab.net/
