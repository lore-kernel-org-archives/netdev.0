From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net] openvswitch: Fix skb leak in IPv6 reassembly.
Date: Tue, 29 Nov 2016 09:21:14 -0800
Message-ID: <CAOrHB_C77=Hgr1GFnM+kgDqiXOg9oFtROB-1UTA3YE93T1k4yg@mail.gmail.com>
References: <20161128234353.4262-1-diproiettod@ovn.org> <CAOrHB_BuRhQrsY5pRGOK9Zo-fEN149Ts9Jj2ADUTQzx84Xd9+A@mail.gmail.com>
 <CAExiqTKTbgOaXLjHMuvne__9hyNLT5kN72fOrEg2CF3VgFg3Cw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Florian Westphal <fw@strlen.de>, Joe Stringer <joe@ovn.org>
To: Daniele Di Proietto <diproiettod@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:51850 "EHLO
        relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934141AbcK2RVU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 12:21:20 -0500
Received: from mfilter48-d.gandi.net (mfilter48-d.gandi.net [217.70.178.179])
        by relay2-d.mail.gandi.net (Postfix) with ESMTP id 17F00C5A56
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 18:21:18 +0100 (CET)
Received: from relay2-d.mail.gandi.net ([IPv6:::ffff:217.70.183.194])
        by mfilter48-d.gandi.net (mfilter48-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id 3MV4CS8DkZu1 for <netdev@vger.kernel.org>;
        Tue, 29 Nov 2016 18:21:16 +0100 (CET)
Received: from mail-io0-f171.google.com (mail-io0-f171.google.com [209.85.223.171])
        (Authenticated sender: pshelar@ovn.org)
        by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id 900C7C5A43
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 18:21:16 +0100 (CET)
Received: by mail-io0-f171.google.com with SMTP id m5so163287505ioe.3
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 09:21:16 -0800 (PST)
In-Reply-To: <CAExiqTKTbgOaXLjHMuvne__9hyNLT5kN72fOrEg2CF3VgFg3Cw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 29, 2016 at 12:54 AM, Daniele Di Proietto
<diproiettod@ovn.org> wrote:
>
>
> 2016-11-28 23:39 GMT-08:00 Pravin Shelar <pshelar@ovn.org>:
>>
>> On Mon, Nov 28, 2016 at 3:43 PM, Daniele Di Proietto
>> <diproiettod@ovn.org> wrote:
>> > If nf_ct_frag6_gather() returns an error other than -EINPROGRESS, it
>> > means that we still have a reference to the skb.  We should free it
>> > before returning from handle_fragments, as stated in the comment above.
>> >
>> > Fixes: daaa7d647f81 ("netfilter: ipv6: avoid nf_iterate recursion")
>> > CC: Florian Westphal <fw@strlen.de>
>> > CC: Pravin B Shelar <pshelar@ovn.org>
>> > CC: Joe Stringer <joe@ovn.org>
>> > Signed-off-by: Daniele Di Proietto <diproiettod@ovn.org>
>> > ---
>> >  net/openvswitch/conntrack.c | 5 ++++-
>> >  1 file changed, 4 insertions(+), 1 deletion(-)
>> >
>> > diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
>> > index 31045ef..fecefa2 100644
>> > --- a/net/openvswitch/conntrack.c
>> > +++ b/net/openvswitch/conntrack.c
>> > @@ -370,8 +370,11 @@ static int handle_fragments(struct net *net, struct
>> > sw_flow_key *key,
>> >                 skb_orphan(skb);
>> >                 memset(IP6CB(skb), 0, sizeof(struct inet6_skb_parm));
>> >                 err = nf_ct_frag6_gather(net, skb, user);
>> > -               if (err)
>> > +               if (err) {
>> > +                       if (err != -EINPROGRESS)
>> > +                               kfree_skb(skb);
>> >                         return err;
>> > +               }
>> >
>>
>> This fixes the code. But the patch is adding yet another skb-kfree in
>> conntrack code. we could simplify it by reusing error handling in
>> do_execute_actions().
>> If you think that is too complicated for stable branch, I am fine with
>> this patch going in as it is.
>
>
> I thought it was simpler to handle this here rather than changing the
> interface of
> handle_fragments() and ovs_ct_execute(). Also this is more similar to the v4
> case,
> where ip_defrag() frees the skb in case of error.
>
> What do you think?

I agree this is simple enough for stable branch. I will check if ct
action error handling could be simplified bit.

Acked-by: Pravin B Shelar <pshelar@ovn.org>
