From: Andreas Jaggi <aj@open.ch>
Subject: Re: [PATCH] gre: copy ToS/DiffServ bits to outer IP header
Date: Tue, 30 Jun 2009 11:05:30 +0200
Message-ID: <4A49D55A.4050600@open.ch>
References: <4A48BC82.6040801@open.ch> <4A48C643.5030709@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, davem@davemloft.net,
	linux-kernel@vger.kernel.org, shemminger@osdl.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail6.open.ch ([213.156.224.131]:9624 "EHLO mail6.open.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756230AbZF3JFX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jun 2009 05:05:23 -0400
In-Reply-To: <4A48C643.5030709@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now using the rtnl_link interface.

>> When tunneling IP traffic with GRE this patch makes it possible to 
>> export the ToS/DiffServ information to the outer IP header.
>> This is particularly useful in a scenario with ESP/AH where the inner 
>> IP header is encrypted but the packet priority/DiffServ information
>> should still be respected by the transporting routers (for example in 
>> an MPLS backbone network).
>>
>> The feature is disabled by default and can be enabled on a 
>> per-interface basis.
>>
>> Also does this bring Linux back in the game, as JunOS/IOS provide this 
>> for quite some time:
>> http://www.cisco.com/en/US/docs/ios/11_3/feature/guide/greqos.html
>> http://www.juniper.net/techpubs/software/junos/junos94/swconfig-services/configuring-a-gre-tunnel-to-copy-tos-bits-to-the-outer-ip-header.html 

diff -urN vanilla-linux-2.6.29.4/include/linux/if_tunnel.h dev-gre/include/linux/if_tunnel.h
--- vanilla-linux-2.6.29.4/include/linux/if_tunnel.h	2009-05-19 01:52:34.000000000 +0200
+++ dev-gre/include/linux/if_tunnel.h	2009-06-30 08:22:52.000000000 +0200
@@ -34,6 +34,7 @@
 	__be32			i_key;
 	__be32			o_key;
 	struct iphdr		iph;
+	__u8			copy_tos;
 };
 
 /* SIT-mode i_flags */
@@ -63,6 +64,7 @@
 	IFLA_GRE_REMOTE,
 	IFLA_GRE_TTL,
 	IFLA_GRE_TOS,
+	IFLA_GRE_COPY_TOS,
 	IFLA_GRE_PMTUDISC,
 	__IFLA_GRE_MAX,
 };
diff -urN vanilla-linux-2.6.29.4/net/ipv4/ip_gre.c dev-gre/net/ipv4/ip_gre.c
--- vanilla-linux-2.6.29.4/net/ipv4/ip_gre.c	2009-05-19 01:52:34.000000000 +0200
+++ dev-gre/net/ipv4/ip_gre.c	2009-06-30 10:48:57.000000000 +0200
@@ -677,7 +677,7 @@
 	}
 
 	tos = tiph->tos;
-	if (tos&1) {
+	if (tunnel->parms.copy_tos || tos&1) {
 		if (skb->protocol == htons(ETH_P_IP))
 			tos = old_iph->tos;
 		tos &= ~1;
@@ -991,6 +991,7 @@
 				t->parms.iph.ttl = p.iph.ttl;
 				t->parms.iph.tos = p.iph.tos;
 				t->parms.iph.frag_off = p.iph.frag_off;
+				t->parms.copy_tos = p.copy_tos;
 				if (t->parms.link != p.link) {
 					t->parms.link = p.link;
 					dev->mtu = ipgre_tunnel_bind_dev(dev);
@@ -1383,6 +1384,9 @@
 	if (data[IFLA_GRE_TOS])
 		parms->iph.tos = nla_get_u8(data[IFLA_GRE_TOS]);
 
+	if (data[IFLA_GRE_COPY_TOS])
+		parms->copy_tos = nla_get_u8(data[IFLA_GRE_COPY_TOS]);
+
 	if (!data[IFLA_GRE_PMTUDISC] || nla_get_u8(data[IFLA_GRE_PMTUDISC]))
 		parms->iph.frag_off = htons(IP_DF);
 }
@@ -1536,6 +1540,8 @@
 		nla_total_size(1) +
 		/* IFLA_GRE_TOS */
 		nla_total_size(1) +
+		/* IFLA_GRE_COPY_TOS */
+		nla_total_size(1) +
 		/* IFLA_GRE_PMTUDISC */
 		nla_total_size(1) +
 		0;
@@ -1555,6 +1561,7 @@
 	NLA_PUT_BE32(skb, IFLA_GRE_REMOTE, p->iph.daddr);
 	NLA_PUT_U8(skb, IFLA_GRE_TTL, p->iph.ttl);
 	NLA_PUT_U8(skb, IFLA_GRE_TOS, p->iph.tos);
+	NLA_PUT_U8(skb, IFLA_GRE_COPY_TOS, p->copy_tos);
 	NLA_PUT_U8(skb, IFLA_GRE_PMTUDISC, !!(p->iph.frag_off & htons(IP_DF)));
 
 	return 0;
@@ -1573,6 +1580,7 @@
 	[IFLA_GRE_REMOTE]	= { .len = FIELD_SIZEOF(struct iphdr, daddr) },
 	[IFLA_GRE_TTL]		= { .type = NLA_U8 },
 	[IFLA_GRE_TOS]		= { .type = NLA_U8 },
+	[IFLA_GRE_COPY_TOS]	= { .type = NLA_U8 },
 	[IFLA_GRE_PMTUDISC]	= { .type = NLA_U8 },
 };
 
