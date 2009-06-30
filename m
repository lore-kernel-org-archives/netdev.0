From: Andreas Jaggi <aj@open.ch>
Subject: Re: [PATCH] gre: copy ToS/DiffServ bits to outer IP header
Date: Tue, 30 Jun 2009 11:06:49 +0200
Message-ID: <4A49D5A9.1060409@open.ch>
References: <4A48BC82.6040801@open.ch> <4A48C643.5030709@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, davem@davemloft.net,
	linux-kernel@vger.kernel.org, shemminger@osdl.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail6.open.ch ([213.156.224.131]:9661 "EHLO mail6.open.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750893AbZF3JGm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jun 2009 05:06:42 -0400
In-Reply-To: <4A48C643.5030709@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

And the corresponding patch for iproute2.

>> When tunneling IP traffic with GRE this patch makes it possible to 
>> export the ToS/DiffServ information to the outer IP header.
>> This is particularly useful in a scenario with ESP/AH where the inner 
>> IP header is encrypted but the packet priority/DiffServ information
>> should still be respected by the transporting routers (for example in 
>> an MPLS backbone network).
>>
>> The feature is disabled by default and can be enabled on a 
>> per-interface basis (/proc/sys/net/ipv4/conf/ethX/gre_copy_tos).
>>
>> Also does this bring Linux back in the game, as JunOS/IOS provide this 
>> for quite some time:
>> http://www.cisco.com/en/US/docs/ios/11_3/feature/guide/greqos.html
>> http://www.juniper.net/techpubs/software/junos/junos94/swconfig-services/configuring-a-gre-tunnel-to-copy-tos-bits-to-the-outer-ip-header.html 

diff -urN iproute2-2.6.29-1/include/linux/if_tunnel.h iproute2-2.6.29-1-gre-dev/include/linux/if_tunnel.h
--- iproute2-2.6.29-1/include/linux/if_tunnel.h	2009-03-24 23:40:54.000000000 +0100
+++ iproute2-2.6.29-1-gre-dev/include/linux/if_tunnel.h	2009-06-30 08:39:18.000000000 +0200
@@ -31,6 +31,7 @@
 	__be32			i_key;
 	__be32			o_key;
 	struct iphdr		iph;
+	__u8			copy_tos;
 };
 
 /* SIT-mode i_flags */
@@ -60,6 +61,7 @@
 	IFLA_GRE_REMOTE,
 	IFLA_GRE_TTL,
 	IFLA_GRE_TOS,
+	IFLA_GRE_COPY_TOS,
 	IFLA_GRE_PMTUDISC,
 	__IFLA_GRE_MAX,
 };
diff -urN iproute2-2.6.29-1/ip/iptunnel.c iproute2-2.6.29-1-gre-dev/ip/iptunnel.c
--- iproute2-2.6.29-1/ip/iptunnel.c	2009-03-24 23:40:54.000000000 +0100
+++ iproute2-2.6.29-1-gre-dev/ip/iptunnel.c	2009-06-30 10:31:19.000000000 +0200
@@ -41,7 +41,7 @@
 	fprintf(stderr, "Usage: ip tunnel { add | change | del | show } [ NAME ]\n");
 	fprintf(stderr, "          [ mode { ipip | gre | sit | isatap } ] [ remote ADDR ] [ local ADDR ]\n");
 	fprintf(stderr, "          [ [i|o]seq ] [ [i|o]key KEY ] [ [i|o]csum ]\n");
-	fprintf(stderr, "          [ ttl TTL ] [ tos TOS ] [ [no]pmtudisc ] [ dev PHYS_DEV ]\n");
+	fprintf(stderr, "          [ ttl TTL ] [ tos TOS ] [ [no]pmtudisc ] [ [no]copytos ] [ dev PHYS_DEV ]\n");
 	fprintf(stderr, "\n");
 	fprintf(stderr, "Where: NAME := STRING\n");
 	fprintf(stderr, "       ADDR := { IP_ADDRESS | any }\n");
@@ -160,6 +160,10 @@
 			p->iph.frag_off = 0;
 		} else if (strcmp(*argv, "pmtudisc") == 0) {
 			p->iph.frag_off = htons(IP_DF);
+		} else if (strcmp(*argv, "nocopytos") == 0) {
+			p->copy_tos = 0;
+		} else if (strcmp(*argv, "copytos") == 0) {
+			p->copy_tos = 1;
 		} else if (strcmp(*argv, "remote") == 0) {
 			NEXT_ARG();
 			if (strcmp(*argv, "any"))
@@ -353,6 +357,9 @@
 	if (!(p->iph.frag_off&htons(IP_DF)))
 		printf(" nopmtudisc");
 
+	if (p->copy_tos)
+		printf(" copytos");
+
 	if ((p->i_flags&GRE_KEY) && (p->o_flags&GRE_KEY) && p->o_key == p->i_key)
 		printf(" key %s", s3);
 	else if ((p->i_flags|p->o_flags)&GRE_KEY) {
diff -urN iproute2-2.6.29-1/ip/link_gre.c iproute2-2.6.29-1-gre-dev/ip/link_gre.c
--- iproute2-2.6.29-1/ip/link_gre.c	2009-03-24 23:40:54.000000000 +0100
+++ iproute2-2.6.29-1-gre-dev/ip/link_gre.c	2009-06-30 10:31:48.000000000 +0200
@@ -29,7 +29,7 @@
 	fprintf(stderr, "Usage: ip link { add | set | change | replace | del } NAME\n");
 	fprintf(stderr, "          type { gre | gretap } [ remote ADDR ] [ local ADDR ]\n");
 	fprintf(stderr, "          [ [i|o]seq ] [ [i|o]key KEY ] [ [i|o]csum ]\n");
-	fprintf(stderr, "          [ ttl TTL ] [ tos TOS ] [ [no]pmtudisc ] [ dev PHYS_DEV ]\n");
+	fprintf(stderr, "          [ ttl TTL ] [ tos TOS ] [ [no]pmtudisc ] [ [no]copytos ] [ dev PHYS_DEV ]\n");
 	fprintf(stderr, "\n");
 	fprintf(stderr, "Where: NAME := STRING\n");
 	fprintf(stderr, "       ADDR := { IP_ADDRESS | any }\n");
@@ -61,6 +61,7 @@
 	__u8 pmtudisc = 1;
 	__u8 ttl = 0;
 	__u8 tos = 0;
+	__u8 copy_tos = 0;
 	int len;
 
 	if (!(n->nlmsg_flags & NLM_F_CREATE)) {
@@ -125,6 +126,9 @@
 		if (greinfo[IFLA_GRE_TOS])
 			tos = *(__u8 *)RTA_DATA(greinfo[IFLA_GRE_TOS]);
 
+		if (greinfo[IFLA_GRE_COPY_TOS])
+			copy_tos = *(__u8 *)RTA_DATA(greinfo[IFLA_GRE_COPY_TOS]);
+
 		if (greinfo[IFLA_GRE_LINK])
 			link = *(__u8 *)RTA_DATA(greinfo[IFLA_GRE_LINK]);
 	}
@@ -196,6 +200,10 @@
 			pmtudisc = 0;
 		} else if (!matches(*argv, "pmtudisc")) {
 			pmtudisc = 1;
+		} else if (!matches(*argv, "nocopytos")) {
+			copy_tos = 0;
+		} else if (!matches(*argv, "copytos")) {
+			copy_tos = 1;
 		} else if (!matches(*argv, "remote")) {
 			NEXT_ARG();
 			if (strcmp(*argv, "any"))
@@ -262,6 +270,7 @@
 		addattr32(n, 1024, IFLA_GRE_LINK, link);
 	addattr_l(n, 1024, IFLA_GRE_TTL, &ttl, 1);
 	addattr_l(n, 1024, IFLA_GRE_TOS, &tos, 1);
+	addattr_l(n, 1024, IFLA_GRE_COPY_TOS, &copy_tos, 1);
 
 	return 0;
 }
@@ -325,6 +334,10 @@
 	    !*(__u8 *)RTA_DATA(tb[IFLA_GRE_PMTUDISC]))
 		fputs("nopmtudisc ", f);
 
+	if (tb[IFLA_GRE_COPY_TOS] &&
+	    *(__u8 *)RTA_DATA(tb[IFLA_GRE_COPY_TOS]))
+		fputs("copytos ", f);
+
 	if (tb[IFLA_GRE_IFLAGS])
 		iflags = *(__u16 *)RTA_DATA(tb[IFLA_GRE_IFLAGS]);
 
