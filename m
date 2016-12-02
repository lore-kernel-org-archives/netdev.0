From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next 2/2] net/sched: cls_flower: Support matching on
 ICMP type and code
Date: Fri, 2 Dec 2016 20:17:13 +0100
Message-ID: <20161202191712.GA32484@penelope.horms.nl>
References: <1480701951-3686-1-git-send-email-simon.horman@netronome.com>
 <1480701951-3686-3-git-send-email-simon.horman@netronome.com>
 <20161202183848.GF1883@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        Jay Vosburgh <j.vosburgh@gmail.com>,
        Veaceslav Falico <vfalico@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f179.google.com ([209.85.210.179]:33420 "EHLO
        mail-wj0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752286AbcLBTRi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 14:17:38 -0500
Received: by mail-wj0-f179.google.com with SMTP id xy5so240139343wjc.0
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 11:17:17 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20161202183848.GF1883@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 02, 2016 at 07:38:48PM +0100, Jiri Pirko wrote:
> Fri, Dec 02, 2016 at 07:05:51PM CET, simon.horman@netronome.com wrote:
> >Support matching on ICMP type and code.
> >
> >Example usage:
> >
> >tc qdisc add dev eth0 ingress
> >
> >tc filter add dev eth0 protocol ip parent ffff: flower \
> >	indev eth0 ip_proto icmp type 8 code 0 action drop
> >
> >tc filter add dev eth0 protocol ipv6 parent ffff: flower \
> >	indev eth0 ip_proto icmpv6 type 128 code 0 action drop
> >
> >Signed-off-by: Simon Horman <simon.horman@netronome.com>
> >---
> > include/net/flow_dissector.h | 24 ++++++++++++++++++++++--
> > include/uapi/linux/pkt_cls.h | 10 ++++++++++
> > net/sched/cls_flower.c       | 42 ++++++++++++++++++++++++++++++++++++++++++
> > 3 files changed, 74 insertions(+), 2 deletions(-)
> >
> >diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
> >index 8880025914e3..5540dfa18872 100644
> >--- a/include/net/flow_dissector.h
> >+++ b/include/net/flow_dissector.h
> >@@ -199,10 +199,30 @@ struct flow_keys_digest {
> > void make_flow_keys_digest(struct flow_keys_digest *digest,
> > 			   const struct flow_keys *flow);
> > 
> >+static inline bool flow_protos_are_icmpv4(__be16 n_proto, u8 ip_proto)
> >+{
> >+	return n_proto == htons(ETH_P_IP) && ip_proto == IPPROTO_ICMP;
> >+}
> >+
> >+static inline bool flow_protos_are_icmpv6(__be16 n_proto, u8 ip_proto)
> >+{
> >+	return n_proto == htons(ETH_P_IPV6) && ip_proto == IPPROTO_ICMPV6;
> >+}
> >+
> > static inline bool flow_protos_are_icmp_any(__be16 n_proto, u8 ip_proto)
> > {
> >-	return (n_proto == htons(ETH_P_IP) && ip_proto == IPPROTO_ICMP) ||
> >-		(n_proto == htons(ETH_P_IPV6) && ip_proto == IPPROTO_ICMPV6);
> >+	return flow_protos_are_icmpv4(n_proto, ip_proto) ||
> >+		flow_protos_are_icmpv6(n_proto, ip_proto);
> >+}
> >+
> >+static inline bool flow_basic_key_is_icmpv4(const struct flow_dissector_key_basic *basic)
> >+{
> >+	return flow_protos_are_icmpv4(basic->n_proto, basic->ip_proto);
> >+}
> >+
> >+static inline bool flow_basic_key_is_icmpv6(const struct flow_dissector_key_basic *basic)
> >+{
> >+	return flow_protos_are_icmpv6(basic->n_proto, basic->ip_proto);
> > }
> > 
> 
> This hunk looks like it should be squashed to the previous patch.

I included it in this patch as it is where these helpers are used
for the first time. I can shuffle it into the first patch if you prefer;
I agree it does make sense to put all the dissector changes there.
