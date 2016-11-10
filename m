From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next v2 6/7] vxlan: simplify vxlan xmit
Date: Wed, 9 Nov 2016 19:35:00 -0800
Message-ID: <CAOrHB_DneqHEg7Hi3SH0GebeN7TUoeKDevbwTatuhGgXrZOTbA@mail.gmail.com>
References: <1478371557-71888-1-git-send-email-pshelar@ovn.org>
 <1478371557-71888-7-git-send-email-pshelar@ovn.org> <20161109175902.01e096ad@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:38421 "EHLO
        relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752870AbcKJDfF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 22:35:05 -0500
Received: from mfilter28-d.gandi.net (mfilter28-d.gandi.net [217.70.178.159])
        by relay3-d.mail.gandi.net (Postfix) with ESMTP id C51C8A80CD
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 04:35:03 +0100 (CET)
Received: from relay3-d.mail.gandi.net ([IPv6:::ffff:217.70.183.195])
        by mfilter28-d.gandi.net (mfilter28-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id R06DajEnsELh for <netdev@vger.kernel.org>;
        Thu, 10 Nov 2016 04:35:02 +0100 (CET)
Received: from mail-it0-f54.google.com (mail-it0-f54.google.com [209.85.214.54])
        (Authenticated sender: pshelar@ovn.org)
        by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id 61231A80CF
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 04:35:02 +0100 (CET)
Received: by mail-it0-f54.google.com with SMTP id q124so10603813itd.1
        for <netdev@vger.kernel.org>; Wed, 09 Nov 2016 19:35:02 -0800 (PST)
In-Reply-To: <20161109175902.01e096ad@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 9, 2016 at 8:59 AM, Jiri Benc <jbenc@redhat.com> wrote:
> On Sat,  5 Nov 2016 11:45:56 -0700, Pravin B Shelar wrote:
>> @@ -2006,11 +2004,34 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
>>       info = skb_tunnel_info(skb);
>>
>>       if (rdst) {
>> +             dst = &rdst->remote_ip;
>> +             if (vxlan_addr_any(dst)) {
>> +                     if (did_rsc) {
>> +                             /* short-circuited back to local bridge */
>> +                             vxlan_encap_bypass(skb, vxlan, vxlan);
>> +                             return;
>> +                     }
>> +                     goto drop;
>> +             }
>> +
>>               dst_port = rdst->remote_port ? rdst->remote_port : vxlan->cfg.dst_port;
>>               vni = rdst->remote_vni;
>> -             dst = &rdst->remote_ip;
>>               src = &vxlan->cfg.saddr;
>>               dst_cache = &rdst->dst_cache;
>> +             md->gbp = skb->mark;
>> +             ttl = vxlan->cfg.ttl;
>> +             if (!ttl && vxlan_addr_multicast(dst))
>> +                     ttl = 1;
>> +
>> +             tos = vxlan->cfg.tos;
>> +             if (tos == 1)
>> +                     tos = ip_tunnel_get_dsfield(old_iph, skb);
>
> Uninitialized old_iph.
>
It is initialized in begining of this function.

> Besides, you can't do this, having TOS, TTL, etc. specified is
> perfectly legal for lwtunnel interfaces, too.
>

TOS and TTL is initialized for LWT just else block. so I do not see
any changes compared to current implementation.

Can you elaborate on your concerns?
