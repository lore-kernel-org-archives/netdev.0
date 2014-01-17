From: Steffen Hurrle <steffen@hurrle.net>
Subject: [PATCH net-next] net: add build-time checks for msg->msg_name size
Date: Fri, 17 Jan 2014 22:53:15 +0100
Message-ID: <20140117215314.GC7562@noise.didjital.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hermes.didjital.de ([213.165.74.220]:41568 "EHLO
	mail.didjital.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753086AbaAQWBy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 17:01:54 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a follow-up patch to f3d3342602f8bc ("net: rework recvmsg
handler msg_name and msg_namelen logic").

DECLARE_SOCKADDR validates that the structure we use for writing the
name information to is not larger than the buffer which is reserved
for msg->msg_name (which is 128 bytes). Also use DECLARE_SOCKADDR
consistently in sendmsg code paths.

Signed-off-by: Steffen Hurrle <steffen@hurrle.net>
Suggested-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
connect()/bind() calls will be migrated by a separate patch.

 drivers/isdn/mISDN/socket.c    | 5 ++---
 net/appletalk/ddp.c            | 4 ++--
 net/ax25/af_ax25.c             | 4 ++--
 net/bluetooth/l2cap_sock.c     | 2 +-
 net/can/bcm.c                  | 4 ++--
 net/can/raw.c                  | 4 ++--
 net/decnet/af_decnet.c         | 3 ++-
 net/ieee802154/dgram.c         | 4 +---
 net/ipv4/ip_sockglue.c         | 3 +--
 net/ipv4/ping.c                | 7 +++----
 net/ipv4/raw.c                 | 4 ++--
 net/ipv4/udp.c                 | 4 ++--
 net/ipv6/datagram.c            | 6 ++----
 net/ipv6/ping.c                | 2 +-
 net/ipv6/raw.c                 | 4 ++--
 net/ipv6/udp.c                 | 6 ++----
 net/ipx/af_ipx.c               | 4 ++--
 net/irda/af_irda.c             | 2 +-
 net/l2tp/l2tp_ip.c             | 4 ++--
 net/l2tp/l2tp_ip6.c            | 5 ++---
 net/llc/af_llc.c               | 4 ++--
 net/netlink/af_netlink.c       | 4 ++--
 net/netrom/af_netrom.c         | 4 ++--
 net/nfc/llcp_sock.c            | 8 ++++----
 net/packet/af_packet.c         | 7 ++++---
 net/phonet/datagram.c          | 6 +++---
 net/rds/recv.c                 | 3 +--
 net/rds/send.c                 | 2 +-
 net/rose/af_rose.c             | 5 +++--
 net/rxrpc/ar-output.c          | 4 ++--
 net/tipc/socket.c              | 6 +++---
 net/unix/af_unix.c             | 4 ++--
 net/vmw_vsock/vmci_transport.c | 4 +---
 net/x25/af_x25.c               | 4 ++--
 34 files changed, 68 insertions(+), 78 deletions(-)

diff --git a/drivers/isdn/mISDN/socket.c b/drivers/isdn/mISDN/socket.c
index 5cefb47..1be8228 100644
--- a/drivers/isdn/mISDN/socket.c
+++ b/drivers/isdn/mISDN/socket.c
@@ -135,7 +135,7 @@ mISDN_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 		return err;
 
 	if (msg->msg_name) {
-		struct sockaddr_mISDN *maddr = msg->msg_name;
+		DECLARE_SOCKADDR(struct sockaddr_mISDN *, maddr, msg->msg_name);
 
 		maddr->family = AF_ISDN;
 		maddr->dev = _pms(sk)->dev->id;
@@ -179,7 +179,6 @@ mISDN_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
 	struct sock		*sk = sock->sk;
 	struct sk_buff		*skb;
 	int			err = -ENOMEM;
-	struct sockaddr_mISDN	*maddr;
 
 	if (*debug & DEBUG_SOCKET)
 		printk(KERN_DEBUG "%s: len %d flags %x ch %d proto %x\n",
@@ -214,7 +213,7 @@ mISDN_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
 
 	if (msg->msg_namelen >= sizeof(struct sockaddr_mISDN)) {
 		/* if we have a address, we use it */
-		maddr = (struct sockaddr_mISDN *)msg->msg_name;
+		DECLARE_SOCKADDR(struct sockaddr_mISDN *, maddr, msg->msg_name);
 		mISDN_HEAD_ID(skb) = maddr->channel;
 	} else { /* use default for L2 messages */
 		if ((sk->sk_protocol == ISDN_P_LAPD_TE) ||
diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index 7d424ac..02806c6 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -1566,7 +1566,7 @@ static int atalk_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr
 {
 	struct sock *sk = sock->sk;
 	struct atalk_sock *at = at_sk(sk);
-	struct sockaddr_at *usat = (struct sockaddr_at *)msg->msg_name;
+	DECLARE_SOCKADDR(struct sockaddr_at *, usat, msg->msg_name);
 	int flags = msg->msg_flags;
 	int loopback = 0;
 	struct sockaddr_at local_satalk, gsat;
@@ -1764,7 +1764,7 @@ static int atalk_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr
 	err = skb_copy_datagram_iovec(skb, offset, msg->msg_iov, copied);
 
 	if (!err && msg->msg_name) {
-		struct sockaddr_at *sat = msg->msg_name;
+		DECLARE_SOCKADDR(struct sockaddr_at *, sat, msg->msg_name);
 		sat->sat_family      = AF_APPLETALK;
 		sat->sat_port        = ddp->deh_sport;
 		sat->sat_addr.s_node = ddp->deh_snode;
diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index 7bb1605..c35c3f4 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -1435,7 +1435,7 @@ out:
 static int ax25_sendmsg(struct kiocb *iocb, struct socket *sock,
 			struct msghdr *msg, size_t len)
 {
-	struct sockaddr_ax25 *usax = (struct sockaddr_ax25 *)msg->msg_name;
+	DECLARE_SOCKADDR(struct sockaddr_ax25 *, usax, msg->msg_name);
 	struct sock *sk = sock->sk;
 	struct sockaddr_ax25 sax;
 	struct sk_buff *skb;
@@ -1640,7 +1640,7 @@ static int ax25_recvmsg(struct kiocb *iocb, struct socket *sock,
 		ax25_digi digi;
 		ax25_address src;
 		const unsigned char *mac = skb_mac_header(skb);
-		struct sockaddr_ax25 *sax = msg->msg_name;
+		DECLARE_SOCKADDR(struct sockaddr_ax25 *, sax, msg->msg_name);
 
 		memset(sax, 0, sizeof(struct full_sockaddr_ax25));
 		ax25_addr_parse(mac + 1, skb->data - mac - 1, &src, NULL,
diff --git a/net/bluetooth/l2cap_sock.c b/net/bluetooth/l2cap_sock.c
index 20ef748..d58f76b 100644
--- a/net/bluetooth/l2cap_sock.c
+++ b/net/bluetooth/l2cap_sock.c
@@ -1413,7 +1413,7 @@ static void l2cap_sock_destruct(struct sock *sk)
 static void l2cap_skb_msg_name(struct sk_buff *skb, void *msg_name,
 			       int *msg_namelen)
 {
-	struct sockaddr_l2 *la = (struct sockaddr_l2 *) msg_name;
+	DECLARE_SOCKADDR(struct sockaddr_l2 *, la, msg_name);
 
 	memset(la, 0, sizeof(struct sockaddr_l2));
 	la->l2_family = AF_BLUETOOTH;
diff --git a/net/can/bcm.c b/net/can/bcm.c
index 46f20bf..3fc737b 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -1256,8 +1256,7 @@ static int bcm_sendmsg(struct kiocb *iocb, struct socket *sock,
 
 	if (!ifindex && msg->msg_name) {
 		/* no bound device as default => check msg_name */
-		struct sockaddr_can *addr =
-			(struct sockaddr_can *)msg->msg_name;
+		DECLARE_SOCKADDR(struct sockaddr_can *, addr, msg->msg_name);
 
 		if (msg->msg_namelen < sizeof(*addr))
 			return -EINVAL;
@@ -1568,6 +1567,7 @@ static int bcm_recvmsg(struct kiocb *iocb, struct socket *sock,
 	sock_recv_ts_and_drops(msg, sk, skb);
 
 	if (msg->msg_name) {
+		__sockaddr_check_size(sizeof(struct sockaddr_can));
 		msg->msg_namelen = sizeof(struct sockaddr_can);
 		memcpy(msg->msg_name, skb->cb, msg->msg_namelen);
 	}
diff --git a/net/can/raw.c b/net/can/raw.c
index 641e1c8..07d72d8 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -675,8 +675,7 @@ static int raw_sendmsg(struct kiocb *iocb, struct socket *sock,
 	int err;
 
 	if (msg->msg_name) {
-		struct sockaddr_can *addr =
-			(struct sockaddr_can *)msg->msg_name;
+		DECLARE_SOCKADDR(struct sockaddr_can *, addr, msg->msg_name);
 
 		if (msg->msg_namelen < sizeof(*addr))
 			return -EINVAL;
@@ -775,6 +774,7 @@ static int raw_recvmsg(struct kiocb *iocb, struct socket *sock,
 	sock_recv_ts_and_drops(msg, sk, skb);
 
 	if (msg->msg_name) {
+		__sockaddr_check_size(sizeof(struct sockaddr_can));
 		msg->msg_namelen = sizeof(struct sockaddr_can);
 		memcpy(msg->msg_name, skb->cb, msg->msg_namelen);
 	}
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index dd4d506..2954dcb 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -1808,6 +1808,7 @@ out:
 		rv = (flags & MSG_PEEK) ? -sk->sk_err : sock_error(sk);
 
 	if ((rv >= 0) && msg->msg_name) {
+		__sockaddr_check_size(sizeof(struct sockaddr_dn));
 		memcpy(msg->msg_name, &scp->peer, sizeof(struct sockaddr_dn));
 		msg->msg_namelen = sizeof(struct sockaddr_dn);
 	}
@@ -1914,7 +1915,7 @@ static int dn_sendmsg(struct kiocb *iocb, struct socket *sock,
 	int err = 0;
 	size_t sent = 0;
 	int addr_len = msg->msg_namelen;
-	struct sockaddr_dn *addr = (struct sockaddr_dn *)msg->msg_name;
+	DECLARE_SOCKADDR(struct sockaddr_dn *, addr, msg->msg_name);
 	struct sk_buff *skb = NULL;
 	struct dn_skb_cb *cb;
 	size_t len;
diff --git a/net/ieee802154/dgram.c b/net/ieee802154/dgram.c
index 1865fdf..1846c1f 100644
--- a/net/ieee802154/dgram.c
+++ b/net/ieee802154/dgram.c
@@ -291,9 +291,7 @@ static int dgram_recvmsg(struct kiocb *iocb, struct sock *sk,
 	size_t copied = 0;
 	int err = -EOPNOTSUPP;
 	struct sk_buff *skb;
-	struct sockaddr_ieee802154 *saddr;
-
-	saddr = (struct sockaddr_ieee802154 *)msg->msg_name;
+	DECLARE_SOCKADDR(struct sockaddr_ieee802154 *, saddr, msg->msg_name);
 
 	skb = skb_recv_datagram(sk, flags, noblock, &err);
 	if (!skb)
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index a9fc435..22f15eb 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -390,7 +390,7 @@ int ip_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
 {
 	struct sock_exterr_skb *serr;
 	struct sk_buff *skb, *skb2;
-	struct sockaddr_in *sin;
+	DECLARE_SOCKADDR(struct sockaddr_in *, sin, msg->msg_name);
 	struct {
 		struct sock_extended_err ee;
 		struct sockaddr_in	 offender;
@@ -416,7 +416,6 @@ int ip_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
 
 	serr = SKB_EXT_ERR(skb);
 
-	sin = (struct sockaddr_in *)msg->msg_name;
 	if (sin) {
 		sin->sin_family = AF_INET;
 		sin->sin_addr.s_addr = *(__be32 *)(skb_network_header(skb) +
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index cae5262..e09e883 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -700,7 +700,7 @@ static int ping_v4_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *m
 	 */
 
 	if (msg->msg_name) {
-		struct sockaddr_in *usin = (struct sockaddr_in *)msg->msg_name;
+		DECLARE_SOCKADDR(struct sockaddr_in *, usin, msg->msg_name);
 		if (msg->msg_namelen < sizeof(*usin))
 			return -EINVAL;
 		if (usin->sin_family != AF_INET)
@@ -873,7 +873,7 @@ int ping_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 
 	/* Copy the address and add cmsg data. */
 	if (family == AF_INET) {
-		struct sockaddr_in *sin = (struct sockaddr_in *)msg->msg_name;
+		DECLARE_SOCKADDR(struct sockaddr_in *, sin, msg->msg_name);
 
 		if (sin) {
 			sin->sin_family = AF_INET;
@@ -890,8 +890,7 @@ int ping_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	} else if (family == AF_INET6) {
 		struct ipv6_pinfo *np = inet6_sk(sk);
 		struct ipv6hdr *ip6 = ipv6_hdr(skb);
-		struct sockaddr_in6 *sin6 =
-			(struct sockaddr_in6 *)msg->msg_name;
+		DECLARE_SOCKADDR(struct sockaddr_in6 *, sin6, msg->msg_name);
 
 		if (sin6) {
 			sin6->sin6_family = AF_INET6;
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 81e6cfd..c04518f 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -493,7 +493,7 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	 */
 
 	if (msg->msg_namelen) {
-		struct sockaddr_in *usin = (struct sockaddr_in *)msg->msg_name;
+		DECLARE_SOCKADDR(struct sockaddr_in *, usin, msg->msg_name);
 		err = -EINVAL;
 		if (msg->msg_namelen < sizeof(*usin))
 			goto out;
@@ -690,7 +690,7 @@ static int raw_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	struct inet_sock *inet = inet_sk(sk);
 	size_t copied = 0;
 	int err = -EOPNOTSUPP;
-	struct sockaddr_in *sin = (struct sockaddr_in *)msg->msg_name;
+	DECLARE_SOCKADDR(struct sockaddr_in *, sin, msg->msg_name);
 	struct sk_buff *skb;
 
 	if (flags & MSG_OOB)
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 3d3141f..77bd16f 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -902,7 +902,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	 *	Get and verify the address.
 	 */
 	if (msg->msg_name) {
-		struct sockaddr_in *usin = (struct sockaddr_in *)msg->msg_name;
+		DECLARE_SOCKADDR(struct sockaddr_in *, usin, msg->msg_name);
 		if (msg->msg_namelen < sizeof(*usin))
 			return -EINVAL;
 		if (usin->sin_family != AF_INET) {
@@ -1226,7 +1226,7 @@ int udp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		size_t len, int noblock, int flags, int *addr_len)
 {
 	struct inet_sock *inet = inet_sk(sk);
-	struct sockaddr_in *sin = (struct sockaddr_in *)msg->msg_name;
+	DECLARE_SOCKADDR(struct sockaddr_in *, sin, msg->msg_name);
 	struct sk_buff *skb;
 	unsigned int ulen, copied;
 	int peeked, off = 0;
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 6983058..bce73cb 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -322,7 +322,7 @@ int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct sock_exterr_skb *serr;
 	struct sk_buff *skb, *skb2;
-	struct sockaddr_in6 *sin;
+	DECLARE_SOCKADDR(struct sockaddr_in6 *, sin, msg->msg_name);
 	struct {
 		struct sock_extended_err ee;
 		struct sockaddr_in6	 offender;
@@ -348,7 +348,6 @@ int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
 
 	serr = SKB_EXT_ERR(skb);
 
-	sin = (struct sockaddr_in6 *)msg->msg_name;
 	if (sin) {
 		const unsigned char *nh = skb_network_header(skb);
 		sin->sin6_family = AF_INET6;
@@ -429,8 +428,8 @@ int ipv6_recv_rxpmtu(struct sock *sk, struct msghdr *msg, int len,
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct sk_buff *skb;
-	struct sockaddr_in6 *sin;
 	struct ip6_mtuinfo mtu_info;
+	DECLARE_SOCKADDR(struct sockaddr_in6 *, sin, msg->msg_name);
 	int err;
 	int copied;
 
@@ -452,7 +451,6 @@ int ipv6_recv_rxpmtu(struct sock *sk, struct msghdr *msg, int len,
 
 	memcpy(&mtu_info, IP6CBMTU(skb), sizeof(mtu_info));
 
-	sin = (struct sockaddr_in6 *)msg->msg_name;
 	if (sin) {
 		sin->sin6_family = AF_INET6;
 		sin->sin6_flowinfo = 0;
diff --git a/net/ipv6/ping.c b/net/ipv6/ping.c
index 15d23b8..cd71f3a 100644
--- a/net/ipv6/ping.c
+++ b/net/ipv6/ping.c
@@ -103,7 +103,7 @@ int ping_v6_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		return err;
 
 	if (msg->msg_name) {
-		struct sockaddr_in6 *u = (struct sockaddr_in6 *) msg->msg_name;
+		DECLARE_SOCKADDR(struct sockaddr_in6 *, u, msg->msg_name);
 		if (msg->msg_namelen < sizeof(struct sockaddr_in6) ||
 		    u->sin6_family != AF_INET6) {
 			return -EINVAL;
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 5f10b7e..b452311 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -457,7 +457,7 @@ static int rawv6_recvmsg(struct kiocb *iocb, struct sock *sk,
 		  int noblock, int flags, int *addr_len)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
-	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)msg->msg_name;
+	DECLARE_SOCKADDR(struct sockaddr_in6 *, sin6, msg->msg_name);
 	struct sk_buff *skb;
 	size_t copied;
 	int err;
@@ -734,7 +734,7 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 		   struct msghdr *msg, size_t len)
 {
 	struct ipv6_txoptions opt_space;
-	struct sockaddr_in6 * sin6 = (struct sockaddr_in6 *) msg->msg_name;
+	DECLARE_SOCKADDR(struct sockaddr_in6 *, sin6, msg->msg_name);
 	struct in6_addr *daddr, *final_p, final;
 	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index fa9d988..233c3ab 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -460,9 +460,7 @@ try_again:
 
 	/* Copy the address. */
 	if (msg->msg_name) {
-		struct sockaddr_in6 *sin6;
-
-		sin6 = (struct sockaddr_in6 *) msg->msg_name;
+		DECLARE_SOCKADDR(struct sockaddr_in6 *, sin6, msg->msg_name);
 		sin6->sin6_family = AF_INET6;
 		sin6->sin6_port = udp_hdr(skb)->source;
 		sin6->sin6_flowinfo = 0;
@@ -1041,7 +1039,7 @@ int udpv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 	struct udp_sock *up = udp_sk(sk);
 	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
-	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *) msg->msg_name;
+	DECLARE_SOCKADDR(struct sockaddr_in6 *, sin6, msg->msg_name);
 	struct in6_addr *daddr, *final_p, final;
 	struct ipv6_txoptions *opt = NULL;
 	struct ip6_flowlabel *flowlabel = NULL;
diff --git a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
index e096025..994e28b 100644
--- a/net/ipx/af_ipx.c
+++ b/net/ipx/af_ipx.c
@@ -1707,7 +1707,7 @@ static int ipx_sendmsg(struct kiocb *iocb, struct socket *sock,
 {
 	struct sock *sk = sock->sk;
 	struct ipx_sock *ipxs = ipx_sk(sk);
-	struct sockaddr_ipx *usipx = (struct sockaddr_ipx *)msg->msg_name;
+	DECLARE_SOCKADDR(struct sockaddr_ipx *, usipx, msg->msg_name);
 	struct sockaddr_ipx local_sipx;
 	int rc = -EINVAL;
 	int flags = msg->msg_flags;
@@ -1774,7 +1774,7 @@ static int ipx_recvmsg(struct kiocb *iocb, struct socket *sock,
 {
 	struct sock *sk = sock->sk;
 	struct ipx_sock *ipxs = ipx_sk(sk);
-	struct sockaddr_ipx *sipx = (struct sockaddr_ipx *)msg->msg_name;
+	DECLARE_SOCKADDR(struct sockaddr_ipx *, sipx, msg->msg_name);
 	struct ipxhdr *ipx = NULL;
 	struct sk_buff *skb;
 	int copied, rc;
diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index 73baf9b..54747c2 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -1652,7 +1652,7 @@ static int irda_sendmsg_ultra(struct kiocb *iocb, struct socket *sock,
 
 	/* Check if an address was specified with sendto. Jean II */
 	if (msg->msg_name) {
-		struct sockaddr_irda *addr = (struct sockaddr_irda *) msg->msg_name;
+		DECLARE_SOCKADDR(struct sockaddr_irda *, addr, msg->msg_name);
 		err = -EINVAL;
 		/* Check address, extract pid. Jean II */
 		if (msg->msg_namelen < sizeof(*addr))
diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index da1a1ce..0b44d85 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -403,7 +403,7 @@ static int l2tp_ip_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *m
 
 	/* Get and verify the address. */
 	if (msg->msg_name) {
-		struct sockaddr_l2tpip *lip = (struct sockaddr_l2tpip *) msg->msg_name;
+		DECLARE_SOCKADDR(struct sockaddr_l2tpip *, lip, msg->msg_name);
 		rc = -EINVAL;
 		if (msg->msg_namelen < sizeof(*lip))
 			goto out;
@@ -512,7 +512,7 @@ static int l2tp_ip_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *m
 	struct inet_sock *inet = inet_sk(sk);
 	size_t copied = 0;
 	int err = -EOPNOTSUPP;
-	struct sockaddr_in *sin = (struct sockaddr_in *)msg->msg_name;
+	DECLARE_SOCKADDR(struct sockaddr_in *, sin, msg->msg_name);
 	struct sk_buff *skb;
 
 	if (flags & MSG_OOB)
diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index 29487a8..aab5f74 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -481,8 +481,7 @@ static int l2tp_ip6_sendmsg(struct kiocb *iocb, struct sock *sk,
 			    struct msghdr *msg, size_t len)
 {
 	struct ipv6_txoptions opt_space;
-	struct sockaddr_l2tpip6 *lsa =
-		(struct sockaddr_l2tpip6 *) msg->msg_name;
+	DECLARE_SOCKADDR(struct sockaddr_l2tpip6 *, lsa, msg->msg_name);
 	struct in6_addr *daddr, *final_p, final;
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct ipv6_txoptions *opt = NULL;
@@ -652,7 +651,7 @@ static int l2tp_ip6_recvmsg(struct kiocb *iocb, struct sock *sk,
 			    int flags, int *addr_len)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
-	struct sockaddr_l2tpip6 *lsa = (struct sockaddr_l2tpip6 *)msg->msg_name;
+	DECLARE_SOCKADDR(struct sockaddr_l2tpip6 *, lsa, msg->msg_name);
 	size_t copied = 0;
 	int err = -EOPNOTSUPP;
 	struct sk_buff *skb;
diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index c71b699..0080d2b 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -707,7 +707,7 @@ out:
 static int llc_ui_recvmsg(struct kiocb *iocb, struct socket *sock,
 			  struct msghdr *msg, size_t len, int flags)
 {
-	struct sockaddr_llc *uaddr = (struct sockaddr_llc *)msg->msg_name;
+	DECLARE_SOCKADDR(struct sockaddr_llc *, uaddr, msg->msg_name);
 	const int nonblock = flags & MSG_DONTWAIT;
 	struct sk_buff *skb = NULL;
 	struct sock *sk = sock->sk;
@@ -884,7 +884,7 @@ static int llc_ui_sendmsg(struct kiocb *iocb, struct socket *sock,
 {
 	struct sock *sk = sock->sk;
 	struct llc_sock *llc = llc_sk(sk);
-	struct sockaddr_llc *addr = (struct sockaddr_llc *)msg->msg_name;
+	DECLARE_SOCKADDR(struct sockaddr_llc *, addr, msg->msg_name);
 	int flags = msg->msg_flags;
 	int noblock = flags & MSG_DONTWAIT;
 	struct sk_buff *skb;
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 34a656d9..fdf5135 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2222,7 +2222,7 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	struct sock_iocb *siocb = kiocb_to_siocb(kiocb);
 	struct sock *sk = sock->sk;
 	struct netlink_sock *nlk = nlk_sk(sk);
-	struct sockaddr_nl *addr = msg->msg_name;
+	DECLARE_SOCKADDR(struct sockaddr_nl *, addr, msg->msg_name);
 	u32 dst_portid;
 	u32 dst_group;
 	struct sk_buff *skb;
@@ -2353,7 +2353,7 @@ static int netlink_recvmsg(struct kiocb *kiocb, struct socket *sock,
 	err = skb_copy_datagram_iovec(data_skb, 0, msg->msg_iov, copied);
 
 	if (msg->msg_name) {
-		struct sockaddr_nl *addr = (struct sockaddr_nl *)msg->msg_name;
+		DECLARE_SOCKADDR(struct sockaddr_nl *, addr, msg->msg_name);
 		addr->nl_family = AF_NETLINK;
 		addr->nl_pad    = 0;
 		addr->nl_pid	= NETLINK_CB(skb).portid;
diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index 53c19a3..b74aa07 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -1028,7 +1028,7 @@ static int nr_sendmsg(struct kiocb *iocb, struct socket *sock,
 {
 	struct sock *sk = sock->sk;
 	struct nr_sock *nr = nr_sk(sk);
-	struct sockaddr_ax25 *usax = (struct sockaddr_ax25 *)msg->msg_name;
+	DECLARE_SOCKADDR(struct sockaddr_ax25 *, usax, msg->msg_name);
 	int err;
 	struct sockaddr_ax25 sax;
 	struct sk_buff *skb;
@@ -1137,7 +1137,7 @@ static int nr_recvmsg(struct kiocb *iocb, struct socket *sock,
 		      struct msghdr *msg, size_t size, int flags)
 {
 	struct sock *sk = sock->sk;
-	struct sockaddr_ax25 *sax = (struct sockaddr_ax25 *)msg->msg_name;
+	DECLARE_SOCKADDR(struct sockaddr_ax25 *, sax, msg->msg_name);
 	size_t copied;
 	struct sk_buff *skb;
 	int er;
diff --git a/net/nfc/llcp_sock.c b/net/nfc/llcp_sock.c
index 69fbc8d..3e0841d 100644
--- a/net/nfc/llcp_sock.c
+++ b/net/nfc/llcp_sock.c
@@ -770,8 +770,8 @@ static int llcp_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
 	lock_sock(sk);
 
 	if (sk->sk_type == SOCK_DGRAM) {
-		struct sockaddr_nfc_llcp *addr =
-			(struct sockaddr_nfc_llcp *)msg->msg_name;
+		DECLARE_SOCKADDR(struct sockaddr_nfc_llcp *, addr,
+				 msg->msg_name);
 
 		if (msg->msg_namelen < sizeof(*addr)) {
 			release_sock(sk);
@@ -843,8 +843,8 @@ static int llcp_sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 
 	if (sk->sk_type == SOCK_DGRAM && msg->msg_name) {
 		struct nfc_llcp_ui_cb *ui_cb = nfc_llcp_ui_skb_cb(skb);
-		struct sockaddr_nfc_llcp *sockaddr =
-			(struct sockaddr_nfc_llcp *) msg->msg_name;
+		DECLARE_SOCKADDR(struct sockaddr_nfc_llcp *, sockaddr,
+				 msg->msg_name);
 
 		msg->msg_namelen = sizeof(struct sockaddr_nfc_llcp);
 
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 12f2f72..d711ecb 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1584,7 +1584,7 @@ static int packet_sendmsg_spkt(struct kiocb *iocb, struct socket *sock,
 			       struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
-	struct sockaddr_pkt *saddr = (struct sockaddr_pkt *)msg->msg_name;
+	DECLARE_SOCKADDR(struct sockaddr_pkt *, saddr, msg->msg_name);
 	struct sk_buff *skb = NULL;
 	struct net_device *dev;
 	__be16 proto = 0;
@@ -2196,7 +2196,7 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 	__be16 proto;
 	int err, reserve = 0;
 	void *ph;
-	struct sockaddr_ll *saddr = (struct sockaddr_ll *)msg->msg_name;
+	DECLARE_SOCKADDR(struct sockaddr_ll *, saddr, msg->msg_name);
 	bool need_wait = !(msg->msg_flags & MSG_DONTWAIT);
 	int tp_len, size_max;
 	unsigned char *addr;
@@ -2346,7 +2346,7 @@ static struct sk_buff *packet_alloc_skb(struct sock *sk, size_t prepad,
 static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 {
 	struct sock *sk = sock->sk;
-	struct sockaddr_ll *saddr = (struct sockaddr_ll *)msg->msg_name;
+	DECLARE_SOCKADDR(struct sockaddr_ll *, saddr, msg->msg_name);
 	struct sk_buff *skb;
 	struct net_device *dev;
 	__be16 proto;
@@ -2922,6 +2922,7 @@ static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
 		 * in, we fill it in now.
 		 */
 		if (sock->type == SOCK_PACKET) {
+			__sockaddr_check_size(sizeof(struct sockaddr_pkt));
 			msg->msg_namelen = sizeof(struct sockaddr_pkt);
 		} else {
 			struct sockaddr_ll *sll = &PACKET_SKB_CB(skb)->sa.ll;
diff --git a/net/phonet/datagram.c b/net/phonet/datagram.c
index 38946b2..290352c 100644
--- a/net/phonet/datagram.c
+++ b/net/phonet/datagram.c
@@ -86,7 +86,7 @@ static int pn_init(struct sock *sk)
 static int pn_sendmsg(struct kiocb *iocb, struct sock *sk,
 			struct msghdr *msg, size_t len)
 {
-	struct sockaddr_pn *target;
+	DECLARE_SOCKADDR(struct sockaddr_pn *, target, msg->msg_name);
 	struct sk_buff *skb;
 	int err;
 
@@ -94,13 +94,12 @@ static int pn_sendmsg(struct kiocb *iocb, struct sock *sk,
 				MSG_CMSG_COMPAT))
 		return -EOPNOTSUPP;
 
-	if (msg->msg_name == NULL)
+	if (target == NULL)
 		return -EDESTADDRREQ;
 
 	if (msg->msg_namelen < sizeof(struct sockaddr_pn))
 		return -EINVAL;
 
-	target = (struct sockaddr_pn *)msg->msg_name;
 	if (target->spn_family != AF_PHONET)
 		return -EAFNOSUPPORT;
 
@@ -160,6 +159,7 @@ static int pn_recvmsg(struct kiocb *iocb, struct sock *sk,
 	rval = (flags & MSG_TRUNC) ? skb->len : copylen;
 
 	if (msg->msg_name != NULL) {
+		__sockaddr_check_size(sizeof(sa));
 		memcpy(msg->msg_name, &sa, sizeof(sa));
 		*addr_len = sizeof(sa);
 	}
diff --git a/net/rds/recv.c b/net/rds/recv.c
index de339b2..bd82522 100644
--- a/net/rds/recv.c
+++ b/net/rds/recv.c
@@ -402,7 +402,7 @@ int rds_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 	struct rds_sock *rs = rds_sk_to_rs(sk);
 	long timeo;
 	int ret = 0, nonblock = msg_flags & MSG_DONTWAIT;
-	struct sockaddr_in *sin;
+	DECLARE_SOCKADDR(struct sockaddr_in *, sin, msg->msg_name);
 	struct rds_incoming *inc = NULL;
 
 	/* udp_recvmsg()->sock_recvtimeo() gets away without locking too.. */
@@ -479,7 +479,6 @@ int rds_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 
 		rds_stats_inc(s_recv_delivered);
 
-		sin = (struct sockaddr_in *)msg->msg_name;
 		if (sin) {
 			sin->sin_family = AF_INET;
 			sin->sin_port = inc->i_hdr.h_sport;
diff --git a/net/rds/send.c b/net/rds/send.c
index 88eace5..a82fb66 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -922,7 +922,7 @@ int rds_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 {
 	struct sock *sk = sock->sk;
 	struct rds_sock *rs = rds_sk_to_rs(sk);
-	struct sockaddr_in *usin = (struct sockaddr_in *)msg->msg_name;
+	DECLARE_SOCKADDR(struct sockaddr_in *, usin, msg->msg_name);
 	__be32 daddr;
 	__be16 dport;
 	struct rds_message *rm = NULL;
diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index d080eb4..c2cca2e 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -1051,7 +1051,7 @@ static int rose_sendmsg(struct kiocb *iocb, struct socket *sock,
 {
 	struct sock *sk = sock->sk;
 	struct rose_sock *rose = rose_sk(sk);
-	struct sockaddr_rose *usrose = (struct sockaddr_rose *)msg->msg_name;
+	DECLARE_SOCKADDR(struct sockaddr_rose *, usrose, msg->msg_name);
 	int err;
 	struct full_sockaddr_rose srose;
 	struct sk_buff *skb;
@@ -1253,7 +1253,8 @@ static int rose_recvmsg(struct kiocb *iocb, struct socket *sock,
 
 	if (msg->msg_name) {
 		struct sockaddr_rose *srose;
-		struct full_sockaddr_rose *full_srose = msg->msg_name;
+		DECLARE_SOCKADDR(struct full_sockaddr_rose *, full_srose,
+				 msg->msg_name);
 
 		memset(msg->msg_name, 0, sizeof(struct full_sockaddr_rose));
 		srose = msg->msg_name;
diff --git a/net/rxrpc/ar-output.c b/net/rxrpc/ar-output.c
index e1ac183..d0e8f1c 100644
--- a/net/rxrpc/ar-output.c
+++ b/net/rxrpc/ar-output.c
@@ -152,8 +152,8 @@ int rxrpc_client_sendmsg(struct kiocb *iocb, struct rxrpc_sock *rx,
 	if (trans) {
 		service_id = rx->service_id;
 		if (msg->msg_name) {
-			struct sockaddr_rxrpc *srx =
-				(struct sockaddr_rxrpc *) msg->msg_name;
+			DECLARE_SOCKADDR(struct sockaddr_rxrpc *, srx,
+					 msg->msg_name);
 			service_id = htons(srx->srx_service);
 		}
 		key = rx->key;
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index eab17eb..aab4948 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -608,7 +608,7 @@ static int send_msg(struct kiocb *iocb, struct socket *sock,
 {
 	struct sock *sk = sock->sk;
 	struct tipc_port *tport = tipc_sk_port(sk);
-	struct sockaddr_tipc *dest = (struct sockaddr_tipc *)m->msg_name;
+	DECLARE_SOCKADDR(struct sockaddr_tipc *, dest, m->msg_name);
 	int needs_conn;
 	long timeo;
 	int res = -EINVAL;
@@ -736,7 +736,7 @@ static int send_packet(struct kiocb *iocb, struct socket *sock,
 {
 	struct sock *sk = sock->sk;
 	struct tipc_port *tport = tipc_sk_port(sk);
-	struct sockaddr_tipc *dest = (struct sockaddr_tipc *)m->msg_name;
+	DECLARE_SOCKADDR(struct sockaddr_tipc *, dest, m->msg_name);
 	int res = -EINVAL;
 	long timeo;
 
@@ -906,7 +906,7 @@ static int auto_connect(struct socket *sock, struct tipc_msg *msg)
  */
 static void set_orig_addr(struct msghdr *m, struct tipc_msg *msg)
 {
-	struct sockaddr_tipc *addr = (struct sockaddr_tipc *)m->msg_name;
+	DECLARE_SOCKADDR(struct sockaddr_tipc *, addr, m->msg_name);
 
 	if (addr) {
 		addr->family = AF_TIPC;
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 800ca61..29fc8be 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1450,7 +1450,7 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	struct sock *sk = sock->sk;
 	struct net *net = sock_net(sk);
 	struct unix_sock *u = unix_sk(sk);
-	struct sockaddr_un *sunaddr = msg->msg_name;
+	DECLARE_SOCKADDR(struct sockaddr_un *, sunaddr, msg->msg_name);
 	struct sock *other = NULL;
 	int namelen = 0; /* fake GCC */
 	int err;
@@ -1912,7 +1912,7 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 	struct scm_cookie tmp_scm;
 	struct sock *sk = sock->sk;
 	struct unix_sock *u = unix_sk(sk);
-	struct sockaddr_un *sunaddr = msg->msg_name;
+	DECLARE_SOCKADDR(struct sockaddr_un *, sunaddr, msg->msg_name);
 	int copied = 0;
 	int check_creds = 0;
 	int target;
diff --git a/net/vmw_vsock/vmci_transport.c b/net/vmw_vsock/vmci_transport.c
index 687360d..9bb63ff 100644
--- a/net/vmw_vsock/vmci_transport.c
+++ b/net/vmw_vsock/vmci_transport.c
@@ -1779,10 +1779,8 @@ static int vmci_transport_dgram_dequeue(struct kiocb *kiocb,
 		goto out;
 
 	if (msg->msg_name) {
-		struct sockaddr_vm *vm_addr;
-
 		/* Provide the address of the sender. */
-		vm_addr = (struct sockaddr_vm *)msg->msg_name;
+		DECLARE_SOCKADDR(struct sockaddr_vm *, vm_addr, msg->msg_name);
 		vsock_addr_init(vm_addr, dg->src.context, dg->src.resource);
 		msg->msg_namelen = sizeof(*vm_addr);
 	}
diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index c8a8297..6177479 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -1082,7 +1082,7 @@ static int x25_sendmsg(struct kiocb *iocb, struct socket *sock,
 {
 	struct sock *sk = sock->sk;
 	struct x25_sock *x25 = x25_sk(sk);
-	struct sockaddr_x25 *usx25 = (struct sockaddr_x25 *)msg->msg_name;
+	DECLARE_SOCKADDR(struct sockaddr_x25 *, usx25, msg->msg_name);
 	struct sockaddr_x25 sx25;
 	struct sk_buff *skb;
 	unsigned char *asmptr;
@@ -1258,7 +1258,7 @@ static int x25_recvmsg(struct kiocb *iocb, struct socket *sock,
 {
 	struct sock *sk = sock->sk;
 	struct x25_sock *x25 = x25_sk(sk);
-	struct sockaddr_x25 *sx25 = (struct sockaddr_x25 *)msg->msg_name;
+	DECLARE_SOCKADDR(struct sockaddr_x25 *, sx25, msg->msg_name);
 	size_t copied;
 	int qbit, header_len;
 	struct sk_buff *skb;
-- 
1.8.3.2
