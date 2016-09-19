From: pravin shelar <pshelar@ovn.org>
Subject: Re: [PATCH] net: skbuff: Fix length validation in skb_vlan_pop()
Date: Mon, 19 Sep 2016 13:46:10 -0700
Message-ID: <CAOrHB_Dy3osOea19e+iTxHFpCgJOYe1fUJJnaN-PB-hOq0-rmA@mail.gmail.com>
References: <1474193358-20133-1-git-send-email-shmulik.ladkani@gmail.com>
 <CAOrHB_D2ytTK9WjfCPL87E1QomeXg+2GfAvo8N8xCcJULhAC=w@mail.gmail.com> <20160919230454.08e58116@halley>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@mellanox.com>,
        "David S . Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:38142 "EHLO
        relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751579AbcISUqq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 16:46:46 -0400
Received: from mfilter14-d.gandi.net (mfilter14-d.gandi.net [217.70.178.142])
        by relay5-d.mail.gandi.net (Postfix) with ESMTP id 9505F41C08A
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 22:46:43 +0200 (CEST)
Received: from relay5-d.mail.gandi.net ([IPv6:::ffff:217.70.183.197])
        by mfilter14-d.gandi.net (mfilter14-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id axDXZvAvpPYC for <netdev@vger.kernel.org>;
        Mon, 19 Sep 2016 22:46:12 +0200 (CEST)
Received: from mail-it0-f42.google.com (mail-it0-f42.google.com [209.85.214.42])
        (Authenticated sender: pshelar@ovn.org)
        by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id 12F9141C087
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 22:46:11 +0200 (CEST)
Received: by mail-it0-f42.google.com with SMTP id 186so163530itf.0
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 13:46:11 -0700 (PDT)
In-Reply-To: <20160919230454.08e58116@halley>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 19, 2016 at 1:04 PM, Shmulik Ladkani
<shmulik.ladkani@gmail.com> wrote:
> Hi Pravin,
>
> On Sun, 18 Sep 2016 13:26:30 -0700 pravin shelar <pshelar@ovn.org> wrote:
>> > +++ b/net/core/skbuff.c
>> > @@ -4537,7 +4537,7 @@ int skb_vlan_pop(struct sk_buff *skb)
>> >         } else {
>> >                 if (unlikely((skb->protocol != htons(ETH_P_8021Q) &&
>> >                               skb->protocol != htons(ETH_P_8021AD)) ||
>> > -                            skb->len < VLAN_ETH_HLEN))
>> > +                            skb->mac_len < VLAN_ETH_HLEN))
>>
>> There is already check in __skb_vlan_pop() to validate skb for a vlan
>> header. So it is safe to drop this check entirely.
>
> Yep, I submitted a v2 with your suggestion, however I withdrew it, as
> there is a slight behavior difference noticable by 'skb_vlan_pop' callers.
>
> Suppose the rare case where skb->len is too small.
>
> pre:
>   skb_vlan_pop returns 0 (at least for the correct tx path).
>   Meaning, callers do not see it as a failure.
> post:
>   skb_ensure_writable fails (!pskb_may_pull), therefore -ENOMEM returned
>   to the callers of 'skb_vlan_pop'.
>
> For ovs, it means do_execute_actions's loop is terminated, no further
> actions are executed, and skb gets freed.
>
> For tc act vlan, it means skb gets dropped.
>
> This actually makes sense, but do we want to present this change?
>
I think this is correct behavior over existing code. And under memory
pressure chances of packet drop are higher even without the change
anyways.
