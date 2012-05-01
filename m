From: James Chapman <jchapman@katalix.com>
Subject: [PATCH 1/2] iproute2: allow IPv6 addresses for l2tp local and remote parameters
Date: Tue,  1 May 2012 15:25:22 +0100
Message-ID: <1335882323-6219-2-git-send-email-jchapman@katalix.com>
References: <1335882323-6219-1-git-send-email-jchapman@katalix.com>
Cc: Chris Elston <celston@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:47480 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758021Ab2EAOZa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2012 10:25:30 -0400
In-Reply-To: <1335882323-6219-1-git-send-email-jchapman@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Elston <celston@katalix.com>

Adds support for parsing IPv6 addresses to the parameters local and
remote in the l2tp commands. Requires netlink attributes L2TP_ATTR_IP6_SADDR
and L2TP_ATTR_IP6_DADDR, added in a required kernel patch already submitted
to netdev.

Also enables printing of IPv6 addresses returned by the L2TP_CMD_TUNNEL_GET
request.

Signed-off-by: Chris Elston <celston@katalix.com>
Signed-off-by: James Chapman <jchapman@katalix.com>
---
 ip/ipl2tp.c |   59 +++++++++++++++++++++++++++++++++++++++++++++--------------
 1 files changed, 45 insertions(+), 14 deletions(-)

diff --git a/ip/ipl2tp.c b/ip/ipl2tp.c
index c5683f5..a05e1a3 100644
--- a/ip/ipl2tp.c
+++ b/ip/ipl2tp.c
@@ -50,8 +50,8 @@ struct l2tp_parm {
 	uint8_t cookie[8];
 	int peer_cookie_len;
 	uint8_t peer_cookie[8];
-	struct in_addr local_ip;
-	struct in_addr peer_ip;
+	inet_prefix local_ip;
+	inet_prefix peer_ip;
 
 	uint16_t pw_type;
 	uint16_t mtu;
@@ -97,6 +97,8 @@ static int create_tunnel(struct l2tp_parm *p)
 		struct genlmsghdr	g;
 		char   			buf[1024];
 	} req;
+	uint32_t local_attr = L2TP_ATTR_IP_SADDR;
+	uint32_t peer_attr = L2TP_ATTR_IP_DADDR;
 
 	memset(&req, 0, sizeof(req));
 	req.n.nlmsg_type = genl_family;
@@ -110,8 +112,14 @@ static int create_tunnel(struct l2tp_parm *p)
 	addattr8(&req.n, 1024, L2TP_ATTR_PROTO_VERSION, 3);
 	addattr16(&req.n, 1024, L2TP_ATTR_ENCAP_TYPE, p->encap);
 
-	addattr32(&req.n, 1024, L2TP_ATTR_IP_SADDR, p->local_ip.s_addr);
-	addattr32(&req.n, 1024, L2TP_ATTR_IP_DADDR, p->peer_ip.s_addr);
+	if (p->local_ip.family == AF_INET6)
+		local_attr = L2TP_ATTR_IP6_SADDR;
+	addattr_l(&req.n, 1024, local_attr, &p->local_ip.data, p->local_ip.bytelen);
+
+	if (p->peer_ip.family == AF_INET6)
+		peer_attr = L2TP_ATTR_IP6_DADDR;
+	addattr_l(&req.n, 1024, peer_attr, &p->peer_ip.data, p->peer_ip.bytelen);
+
 	if (p->encap == L2TP_ENCAPTYPE_UDP) {
 		addattr16(&req.n, 1024, L2TP_ATTR_UDP_SPORT, p->local_udp_port);
 		addattr16(&req.n, 1024, L2TP_ATTR_UDP_DPORT, p->peer_udp_port);
@@ -225,13 +233,14 @@ static void print_cookie(char *name, const uint8_t *cookie, int len)
 static void print_tunnel(const struct l2tp_data *data)
 {
 	const struct l2tp_parm *p = &data->config;
+	char buf[INET6_ADDRSTRLEN];
 
 	printf("Tunnel %u, encap %s\n",
 	       p->tunnel_id,
 	       p->encap == L2TP_ENCAPTYPE_UDP ? "UDP" :
 	       p->encap == L2TP_ENCAPTYPE_IP ? "IP" : "??");
-	printf("  From %s ", inet_ntoa(p->local_ip));
-	printf("to %s\n", inet_ntoa(p->peer_ip));
+	printf("  From %s ", inet_ntop(p->local_ip.family, p->local_ip.data, buf, sizeof(buf)));
+	printf("to %s\n", inet_ntop(p->peer_ip.family, p->peer_ip.data, buf, sizeof(buf)));
 	printf("  Peer tunnel %u\n",
 	       p->peer_tunnel_id);
 
@@ -315,10 +324,30 @@ static int get_response(struct nlmsghdr *n, void *arg)
 
 	if (attrs[L2TP_ATTR_RECV_TIMEOUT])
 		p->reorder_timeout = rta_getattr_u64(attrs[L2TP_ATTR_RECV_TIMEOUT]);
-	if (attrs[L2TP_ATTR_IP_SADDR])
-		p->local_ip.s_addr = rta_getattr_u32(attrs[L2TP_ATTR_IP_SADDR]);
-	if (attrs[L2TP_ATTR_IP_DADDR])
-		p->peer_ip.s_addr = rta_getattr_u32(attrs[L2TP_ATTR_IP_DADDR]);
+	if (attrs[L2TP_ATTR_IP_SADDR]) {
+		p->local_ip.family = AF_INET;
+		p->local_ip.data[0] = rta_getattr_u32(attrs[L2TP_ATTR_IP_SADDR]);
+		p->local_ip.bytelen = 4;
+		p->local_ip.bitlen = -1;
+	}
+	if (attrs[L2TP_ATTR_IP_DADDR]) {
+		p->peer_ip.family = AF_INET;
+		p->peer_ip.data[0] = rta_getattr_u32(attrs[L2TP_ATTR_IP_DADDR]);
+		p->peer_ip.bytelen = 4;
+		p->peer_ip.bitlen = -1;
+	}
+	if (attrs[L2TP_ATTR_IP6_SADDR]) {
+		p->local_ip.family = AF_INET6;
+		memcpy(&p->local_ip.data, RTA_DATA(attrs[L2TP_ATTR_IP6_SADDR]),
+			p->local_ip.bytelen = 16);
+		p->local_ip.bitlen = -1;
+	}
+	if (attrs[L2TP_ATTR_IP6_DADDR]) {
+		p->peer_ip.family = AF_INET6;
+		memcpy(&p->peer_ip.data, RTA_DATA(attrs[L2TP_ATTR_IP6_DADDR]),
+			p->peer_ip.bytelen = 16);
+		p->peer_ip.bitlen = -1;
+	}
 	if (attrs[L2TP_ATTR_UDP_SPORT])
 		p->local_udp_port = rta_getattr_u16(attrs[L2TP_ATTR_UDP_SPORT]);
 	if (attrs[L2TP_ATTR_UDP_DPORT])
@@ -529,10 +558,12 @@ static int parse_args(int argc, char **argv, int cmd, struct l2tp_parm *p)
 			p->ifname = *argv;
 		} else if (strcmp(*argv, "remote") == 0) {
 			NEXT_ARG();
-			p->peer_ip.s_addr = get_addr32(*argv);
+			if (get_addr(&p->peer_ip, *argv, AF_UNSPEC))
+				invarg("invalid remote address\n", *argv);
 		} else if (strcmp(*argv, "local") == 0) {
 			NEXT_ARG();
-			p->local_ip.s_addr = get_addr32(*argv);
+			if (get_addr(&p->local_ip, *argv, AF_UNSPEC))
+				invarg("invalid local address\n", *argv);
 		} else if ((strcmp(*argv, "tunnel_id") == 0) ||
 			   (strcmp(*argv, "tid") == 0)) {
 			__u32 uval;
@@ -648,10 +679,10 @@ static int do_add(int argc, char **argv)
 		missarg("peer_tunnel_id");
 
 	if (p.tunnel) {
-		if (p.local_ip.s_addr == 0)
+		if (p.local_ip.family == AF_UNSPEC)
 			missarg("local");
 
-		if (p.peer_ip.s_addr == 0)
+		if (p.peer_ip.family == AF_UNSPEC)
 			missarg("remote");
 
 		if (p.encap == L2TP_ENCAPTYPE_UDP) {
-- 
1.7.0.4
