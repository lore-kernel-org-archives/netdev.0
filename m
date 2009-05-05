From: Alexandre Cassen <acassen@freebox.fr>
Subject: [PATCH] IPv6: 6rd iproute2 support
Date: Tue, 5 May 2009 12:50:50 +0200
Message-ID: <20090505105050.GA2598@lnxos.staff.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1-g21.free.fr ([212.27.42.1]:34028 "EHLO smtp1-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932375AbZEEKu6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 May 2009 06:50:58 -0400
Received: from smtp1-g21.free.fr (localhost [127.0.0.1])
	by smtp1-g21.free.fr (Postfix) with ESMTP id C278B9400DB
	for <netdev@vger.kernel.org>; Tue,  5 May 2009 12:50:53 +0200 (CEST)
Received: from mail.lnxos.net (lnxos.staff.proxad.net [213.228.1.83])
	by smtp1-g21.free.fr (Postfix) with ESMTP id EEBEC940148
	for <netdev@vger.kernel.org>; Tue,  5 May 2009 12:50:50 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6 rapid deployment (6rd) builds upon mechanisms of 6to4 (RFC3056)
to enable a service provider to rapidly deploy IPv6 unicast service
to IPv4 sites to which it provides customer premise equipment.  Like
6to4, it utilizes stateless IPv6 in IPv4 encapsulation in order to
transit IPv4-only network infrastructure.  Unlike 6to4, a 6rd service
provider uses an IPv6 prefix of its own in place of the fixed 6to4
prefix. more info at http://tools.ietf.org/html/draft-despres-6rd-03.

Signed-off-by: Alexandre Cassen <acassen@freebox.fr>
---
 include/linux/if_tunnel.h |    5 +++++
 ip/iptunnel.c             |   16 +++++++++++++++-
 2 files changed, 20 insertions(+), 1 deletions(-)

diff --git a/include/linux/if_tunnel.h b/include/linux/if_tunnel.h
index 2918c6f..00092e0 100644
--- a/include/linux/if_tunnel.h
+++ b/include/linux/if_tunnel.h
@@ -30,6 +30,11 @@ struct ip_tunnel_parm
 	__be16			o_flags;
 	__be32			i_key;
 	__be32			o_key;
+
+	/* 6rd matching params */
+	struct in6_addr		ip6rd_zone;
+	__u8			ip6rd_prefix;
+
 	struct iphdr		iph;
 };
 
diff --git a/ip/iptunnel.c b/ip/iptunnel.c
index 7bee162..8e08872 100644
--- a/ip/iptunnel.c
+++ b/ip/iptunnel.c
@@ -40,7 +40,7 @@ static void usage(void)
 {
 	fprintf(stderr, "Usage: ip tunnel { add | change | del | show } [ NAME ]\n");
 	fprintf(stderr, "          [ mode { ipip | gre | sit | isatap } ] [ remote ADDR ] [ local ADDR ]\n");
-	fprintf(stderr, "          [ [i|o]seq ] [ [i|o]key KEY ] [ [i|o]csum ]\n");
+	fprintf(stderr, "          [ [i|o]seq ] [ [i|o]key KEY ] [ 6rd_zone ADDR ] [ [i|o]csum ]\n");
 	fprintf(stderr, "          [ ttl TTL ] [ tos TOS ] [ [no]pmtudisc ] [ dev PHYS_DEV ]\n");
 	fprintf(stderr, "\n");
 	fprintf(stderr, "Where: NAME := STRING\n");
@@ -156,6 +156,13 @@ static int parse_args(int argc, char **argv, int cmd, struct ip_tunnel_parm *p)
 			p->i_flags |= GRE_CSUM;
 		} else if (strcmp(*argv, "ocsum") == 0) {
 			p->o_flags |= GRE_CSUM;
+		} else if (strcmp(*argv, "6rd_zone") == 0) {
+			inet_prefix zone;
+			NEXT_ARG();
+			if (get_prefix(&zone, *argv, AF_INET6))
+				invarg("invalid 6rd_zone\n", *argv);
+			memcpy(&p->ip6rd_zone, zone.data, 16);
+			p->ip6rd_prefix = zone.bitlen;
 		} else if (strcmp(*argv, "nopmtudisc") == 0) {
 			p->iph.frag_off = 0;
 		} else if (strcmp(*argv, "pmtudisc") == 0) {
@@ -348,6 +355,13 @@ static void print_tunnel(struct ip_tunnel_parm *p)
 	if (!(p->iph.frag_off&htons(IP_DF)))
 		printf(" nopmtudisc");
 
+	if (p->ip6rd_prefix) {
+		char buf[128];
+		printf(" 6rd_zone %s/%u ",
+		       inet_ntop(AF_INET6, &p->ip6rd_zone, buf, 128),
+		       p->ip6rd_prefix);
+	}
+
 	if ((p->i_flags&GRE_KEY) && (p->o_flags&GRE_KEY) && p->o_key == p->i_key)
 		printf(" key %s", s3);
 	else if ((p->i_flags|p->o_flags)&GRE_KEY) {
-- 
1.5.6.3

