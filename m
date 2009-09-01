From: Patrick McHardy <kaber@trash.net>
Subject: Re: H.245v10+ support in nf_conntrack_h323?
Date: Tue, 01 Sep 2009 14:20:51 +0200
Message-ID: <4A9D11A3.5070809@trash.net>
References: <20090901092910.GC11354@urbino.open.ch> <20090901100230.GA18651@sirena.org.uk> <4A9D04A2.60307@trash.net> <20090901121033.GA18731@urbino.open.ch>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000808010906080605050106"
Cc: Mark Brown <broonie@opensource.wolfsonmicro.com>,
	Jing Min Zhao <zhaojingmin@users.sourceforge.net>,
	netdev@vger.kernel.org
To: Andreas Jaggi <aj@open.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53114 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753837AbZIAMU5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 08:20:57 -0400
In-Reply-To: <20090901121033.GA18731@urbino.open.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000808010906080605050106
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Andreas Jaggi wrote:
> On Tue, Sep 01, 2009 at 01:25:22PM +0200, Patrick McHardy wrote:
>> Mark Brown wrote:
>>> I'd be surprised if the H.245 version were the source of your problems
>>> here - the new protocol versions are backwards compatible and I don't
>>> remember any changes in any of the stuff that's relevant for firewall
>>> transit.
>> Good point. The helper should also log packets dropped due to parsing
>> errors. If you don't get any messages, I'd suggest to use the iptables
>> TRACE target to figure out where the packets are dropped exactly.
> 
> I'm quite confident that the H.245 parsing/handling is involved in the
> packet dropping:
> 1. there are plenty of 'nf_ct_h245: packet dropped' messages
>    (but no nf_ct_q931 or nf_ct_ras messages)

Yes, that's the H.323 helper.

> 2. without nf_conntrack_h323 the videoconferencing works seamlessly
> 3. with nf_conntrack_h323 and a ...-j NOTRACK rule the videoconferencing
>    works too
> 
> In our setup there is a LOG rule preceding any DROP or ACCEPT rule, and
> there were no logentries for DROP rules showing up (only the nf_ct_h245:
> packet dropped messages).
> Would a TRACE rule provide more insight than this? (eg. by showing in
> which part of the nf_conntrack_h323 code a packet is dropped?)

No, it only shows the path of the packet through the ruleset.

> For me it looks like nf_conntrack_h323 is not only doing connection
> tracking, but also doing protocol enforcement (by dropping packets which
> do not correspond exactly to H.245v7).
> Perhaps there should be a config option to disable the protocol
> enforcement?

Its unfortunately necessary to drop packets in some cases after parsing
errors when the helper might have already (partially) mangled the
packet.

You could try this patch in combination with ulogd and the pcap output
plugin to capture the packets which are dropped by the helper for
analysis.

--------------000808010906080605050106
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit 74f7a6552c8d76ffc5e11eb8d9d6c07238b9ae77
Author: Patrick McHardy <kaber@trash.net>
Date:   Tue Aug 25 15:33:08 2009 +0200

    netfilter: nf_conntrack: log packets dropped by helpers
    
    Log packets dropped by helpers using the netfilter logging API. This
    is useful in combination with nfnetlink_log to analyze those packets
    in userspace for debugging.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 9ac2fdc..aa95bb8 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -26,6 +26,7 @@
 #include <net/netfilter/ipv4/nf_conntrack_ipv4.h>
 #include <net/netfilter/nf_nat_helper.h>
 #include <net/netfilter/ipv4/nf_defrag_ipv4.h>
+#include <net/netfilter/nf_log.h>
 
 int (*nf_nat_seq_adjust_hook)(struct sk_buff *skb,
 			      struct nf_conn *ct,
@@ -113,8 +114,11 @@ static unsigned int ipv4_confirm(unsigned int hooknum,
 
 	ret = helper->help(skb, skb_network_offset(skb) + ip_hdrlen(skb),
 			   ct, ctinfo);
-	if (ret != NF_ACCEPT)
+	if (ret != NF_ACCEPT) {
+		nf_log_packet(NFPROTO_IPV4, hooknum, skb, in, out, NULL,
+			      "nf_ct_%s: dropping packet", helper->name);
 		return ret;
+	}
 
 	if (test_bit(IPS_SEQ_ADJUST_BIT, &ct->status)) {
 		typeof(nf_nat_seq_adjust_hook) seq_adjust;
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index a7f4cd6..5f2ec20 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -27,6 +27,7 @@
 #include <net/netfilter/nf_conntrack_l3proto.h>
 #include <net/netfilter/nf_conntrack_core.h>
 #include <net/netfilter/ipv6/nf_conntrack_ipv6.h>
+#include <net/netfilter/nf_log.h>
 
 static bool ipv6_pkt_to_tuple(const struct sk_buff *skb, unsigned int nhoff,
 			      struct nf_conntrack_tuple *tuple)
@@ -176,8 +177,11 @@ static unsigned int ipv6_confirm(unsigned int hooknum,
 	}
 
 	ret = helper->help(skb, protoff, ct, ctinfo);
-	if (ret != NF_ACCEPT)
+	if (ret != NF_ACCEPT) {
+		nf_log_packet(NFPROTO_IPV6, hooknum, skb, in, out, NULL,
+			      "nf_ct_%s: dropping packet", helper->name);
 		return ret;
+	}
 out:
 	/* We've seen it coming out the other side: confirm it */
 	return nf_conntrack_confirm(skb);

--------------000808010906080605050106--
