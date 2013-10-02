From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next v5 1/3] flow_dissector: factor out the ports
 extraction in skb_flow_get_ports
Date: Wed, 2 Oct 2013 14:55:42 +0200
Message-ID: <20131002125542.GE6096@redhat.com>
References: <1380713966-3891-1-git-send-email-nikolay@redhat.com>
 <1380713966-3891-2-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, davem@davemloft.net, andy@greyhouse.net,
	fubar@us.ibm.com, eric.dumazet@gmail.com
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14806 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752945Ab3JBM5n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Oct 2013 08:57:43 -0400
Content-Disposition: inline
In-Reply-To: <1380713966-3891-2-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 02, 2013 at 01:39:24PM +0200, Nikolay Aleksandrov wrote:
>Factor out the code that extracts the ports from skb_flow_dissect and
>add a new function skb_flow_get_ports which can be re-used.
>
>Suggested-by: Veaceslav Falico <vfalico@redhat.com>
>Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>

Reviewed-by: Veaceslav Falico <vfalico@redhat.com>

>---
>v2: new patch
>v3: fix a bug in skb_flow_dissect where thoff didn't have poff added by
>    modifying thoff directly in skb_flow_get_ports as it's done anyway.
>    Also add the necessary export symbol for skb_flow_get_ports.
>v4: integrate the thoff fix in skb_flow_get_ports
>v5: disintegrate the thoff fix, and re-base on Eric's fix
>This seems like a good idea because there're other users that can re-use
>it later as well.
>
> include/net/flow_keys.h   |  1 +
> net/core/flow_dissector.c | 39 ++++++++++++++++++++++++++++-----------
> 2 files changed, 29 insertions(+), 11 deletions(-)
>
>diff --git a/include/net/flow_keys.h b/include/net/flow_keys.h
>index ac2439d..7e64bd8 100644
>--- a/include/net/flow_keys.h
>+++ b/include/net/flow_keys.h
>@@ -14,4 +14,5 @@ struct flow_keys {
> };
>
> bool skb_flow_dissect(const struct sk_buff *skb, struct flow_keys *flow);
>+__be32 skb_flow_get_ports(const struct sk_buff *skb, int thoff, u8 ip_proto);
> #endif
>diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
>index 8d7d0dd..f8e25ac 100644
>--- a/net/core/flow_dissector.c
>+++ b/net/core/flow_dissector.c
>@@ -25,9 +25,35 @@ static void iph_to_flow_copy_addrs(struct flow_keys *flow, const struct iphdr *i
> 	memcpy(&flow->src, &iph->saddr, sizeof(flow->src) + sizeof(flow->dst));
> }
>
>+/**
>+ * skb_flow_get_ports - extract the upper layer ports and return them
>+ * @skb: buffer to extract the ports from
>+ * @thoff: transport header offset
>+ * @ip_proto: protocol for which to get port offset
>+ *
>+ * The function will try to retrieve the ports at offset thoff + poff where poff
>+ * is the protocol port offset returned from proto_ports_offset
>+ */
>+__be32 skb_flow_get_ports(const struct sk_buff *skb, int thoff, u8 ip_proto)
>+{
>+	int poff = proto_ports_offset(ip_proto);
>+
>+	if (poff >= 0) {
>+		__be32 *ports, _ports;
>+
>+		ports = skb_header_pointer(skb, thoff + poff,
>+					   sizeof(_ports), &_ports);
>+		if (ports)
>+			return *ports;
>+	}
>+
>+	return 0;
>+}
>+EXPORT_SYMBOL(skb_flow_get_ports);
>+
> bool skb_flow_dissect(const struct sk_buff *skb, struct flow_keys *flow)
> {
>-	int poff, nhoff = skb_network_offset(skb);
>+	int nhoff = skb_network_offset(skb);
> 	u8 ip_proto;
> 	__be16 proto = skb->protocol;
>
>@@ -150,16 +176,7 @@ ipv6:
> 	}
>
> 	flow->ip_proto = ip_proto;
>-	poff = proto_ports_offset(ip_proto);
>-	if (poff >= 0) {
>-		__be32 *ports, _ports;
>-
>-		ports = skb_header_pointer(skb, nhoff + poff,
>-					   sizeof(_ports), &_ports);
>-		if (ports)
>-			flow->ports = *ports;
>-	}
>-
>+	flow->ports = skb_flow_get_ports(skb, nhoff, ip_proto);
> 	flow->thoff = (u16) nhoff;
>
> 	return true;
>-- 
>1.8.1.4
>
