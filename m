From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH V4 net 2/2] net: fix tcp reset packet flowlabel for ipv6
Date: Tue, 1 Aug 2017 14:17:58 -0700
Message-ID: <CAM_iQpWiw6CJOr2+zvxdoCht1DRERmZfZCCZiE36_6RiumEOVA@mail.gmail.com>
References: <cover.1501539150.git.shli@fb.com> <373e23f5295ee4cb725109a9e58152451a9fb4cc.1501539150.git.shli@fb.com>
 <CAM_iQpXOaP4JmGW4-AcL6JYbzKq_Co_Z4pWiSh1B1i=4MsakEQ@mail.gmail.com> <20170731230002.ercfotm7qhfubbbv@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>, Shaohua Li <shli@fb.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Florent Fourcot <flo@fourcot.fr>
To: Shaohua Li <shli@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:37009 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751546AbdHAVSU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 17:18:20 -0400
Received: by mail-wm0-f66.google.com with SMTP id t138so4787900wmt.4
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2017 14:18:20 -0700 (PDT)
In-Reply-To: <20170731230002.ercfotm7qhfubbbv@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 31, 2017 at 4:00 PM, Shaohua Li <shli@kernel.org> wrote:
> On Mon, Jul 31, 2017 at 03:35:02PM -0700, Cong Wang wrote:
>> On Mon, Jul 31, 2017 at 3:19 PM, Shaohua Li <shli@kernel.org> wrote:
>> >  static inline __be32 ip6_make_flowlabel(struct net *net, struct sk_buff *skb,
>> >                                         __be32 flowlabel, bool autolabel,
>> > -                                       struct flowi6 *fl6)
>> > +                                       struct flowi6 *fl6, u32 hash)
>> >  {
>> > -       u32 hash;
>> > -
>> >         /* @flowlabel may include more than a flow label, eg, the traffic class.
>> >          * Here we want only the flow label value.
>> >          */
>> > @@ -788,7 +786,8 @@ static inline __be32 ip6_make_flowlabel(struct net *net, struct sk_buff *skb,
>> >              net->ipv6.sysctl.auto_flowlabels != IP6_AUTO_FLOW_LABEL_FORCED))
>> >                 return flowlabel;
>> >
>> > -       hash = skb_get_hash_flowi6(skb, fl6);
>> > +       if (skb)
>> > +               hash = skb_get_hash_flowi6(skb, fl6);
>>
>>
>> Why not just move skb_get_hash_flowi6() to its caller?
>> This check is not necessary. If you don't want to touch
>> existing callers, you can just introduce a wrapper:
>>
>>
>> static inline __be32 ip6_make_flowlabel(struct net *net, struct sk_buff *skb,
>>                                         __be32 flowlabel, bool autolabel,
>>                                         struct flowi6 *fl6)
>> {
>>   u32 hash = skb_get_hash_flowi6(skb, fl6);
>>   return __ip6_make_flowlabel(net, flowlabel, autolabel, hash);
>> }
>
> this will always call skb_get_hash_flowi6 for the fast path even auto flowlabel
> is disabled. I thought we should avoid this.

Yeah, but you can move the check out too,
something like:

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 6eac5cf8f1e6..18ffa824c00a 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -771,31 +771,22 @@ static inline void
iph_to_flow_copy_v6addrs(struct flow_keys *flow,

 #define IP6_DEFAULT_AUTO_FLOW_LABELS   IP6_AUTO_FLOW_LABEL_OPTOUT

-static inline __be32 ip6_make_flowlabel(struct net *net, struct sk_buff *skb,
-                                       __be32 flowlabel, bool autolabel,
-                                       struct flowi6 *fl6)
+static inline bool ip6_need_flowlabel(struct net *net, __be32
flowlabel, bool autolabel)
 {
-       u32 hash;
-
        /* @flowlabel may include more than a flow label, eg, the traffic class.
         * Here we want only the flow label value.
         */
-       flowlabel &= IPV6_FLOWLABEL_MASK;
-
-       if (flowlabel ||
+       if ((flowlabel & IPV6_FLOWLABEL_MASK) ||
            net->ipv6.sysctl.auto_flowlabels == IP6_AUTO_FLOW_LABEL_OFF ||
            (!autolabel &&
             net->ipv6.sysctl.auto_flowlabels != IP6_AUTO_FLOW_LABEL_FORCED))
-               return flowlabel;
-
-       hash = skb_get_hash_flowi6(skb, fl6);
+               return false;

-       /* Since this is being sent on the wire obfuscate hash a bit
-        * to minimize possbility that any useful information to an
-        * attacker is leaked. Only lower 20 bits are relevant.
-        */
-       rol32(hash, 16);
+       return true;
+}

+static inline __be32 __ip6_make_flowlabel(struct net *net, __be32
flowlabel, u32 hash)
+{
        flowlabel = (__force __be32)hash & IPV6_FLOWLABEL_MASK;

        if (net->ipv6.sysctl.flowlabel_state_ranges)
@@ -804,6 +795,19 @@ static inline __be32 ip6_make_flowlabel(struct
net *net, struct sk_buff *skb,
        return flowlabel;
 }

+static inline __be32 ip6_make_flowlabel(struct net *net, struct sk_buff *skb,
+                                       __be32 flowlabel, bool autolabel,
+                                       struct flowi6 *fl6)
+{
+       u32 hash;
+
+       if (!ip6_need_flowlabel(net, flowlabel, autolabel))
+               return flowlabel & IPV6_FLOWLABEL_MASK;
+
+       hash = skb_get_hash_flowi6(skb, fl6);
+       return __ip6_make_flowlabel(net, flowlabel, hash);
+}
+
 static inline int ip6_default_np_autolabel(struct net *net)
 {
        switch (net->ipv6.sysctl.auto_flowlabels) {
