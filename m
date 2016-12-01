From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH v3 net-next 3/3] openvswitch: Fix skb->protocol for vlan frames.
Date: Thu, 1 Dec 2016 12:31:09 -0800
Message-ID: <CAOrHB_CAR8G=BF6X_+HgkRRnb=Erc6CYpCL4EnJfDRe7qBR2vg@mail.gmail.com>
References: <1480462253-114713-1-git-send-email-jarno@ovn.org>
 <1480462253-114713-3-git-send-email-jarno@ovn.org> <20161130153041.7a9590ef@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jarno Rajahalme <jarno@ovn.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Garver <e@erig.me>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:33873 "EHLO
        relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758776AbcLAUbQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 15:31:16 -0500
Received: from mfilter26-d.gandi.net (mfilter26-d.gandi.net [217.70.178.154])
        by relay6-d.mail.gandi.net (Postfix) with ESMTP id 35438FB88B
        for <netdev@vger.kernel.org>; Thu,  1 Dec 2016 21:31:15 +0100 (CET)
Received: from relay6-d.mail.gandi.net ([IPv6:::ffff:217.70.183.198])
        by mfilter26-d.gandi.net (mfilter26-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id eu8_oIp3O_r1 for <netdev@vger.kernel.org>;
        Thu,  1 Dec 2016 21:31:13 +0100 (CET)
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
        (Authenticated sender: pshelar@ovn.org)
        by relay6-d.mail.gandi.net (Postfix) with ESMTPSA id B134BFB8B9
        for <netdev@vger.kernel.org>; Thu,  1 Dec 2016 21:31:13 +0100 (CET)
Received: by mail-io0-f170.google.com with SMTP id c21so405771067ioj.1
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 12:31:13 -0800 (PST)
In-Reply-To: <20161130153041.7a9590ef@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 30, 2016 at 6:30 AM, Jiri Benc <jbenc@redhat.com> wrote:
> On Tue, 29 Nov 2016 15:30:53 -0800, Jarno Rajahalme wrote:
>> Do not always set skb->protocol to be the ethertype of the L3 header.
>> For a packet with non-accelerated VLAN tags skb->protocol needs to be
>> the ethertype of the outermost non-accelerated VLAN ethertype.
>
> Well, the current handling of skb->protocol matches what used to be the
> handling of the kernel net stack before Jiri Pirko cleaned up the vlan
> code.
>
> I'm not opposed to changing this but I'm afraid it needs much deeper
> review. Because with this in place, no core kernel functions that
> depend on skb->protocol may be called from within openvswitch.
>
Can you give specific example where it does not work?

>> @@ -361,6 +362,11 @@ static int parse_vlan(struct sk_buff *skb, struct sw_flow_key *key)
>>       if (res <= 0)
>>               return res;
>>
>> +     /* If the outer vlan tag was accelerated, skb->protocol should
>> +      * refelect the inner vlan type. */
>> +     if (!eth_type_vlan(skb->protocol))
>> +             skb->protocol = key->eth.cvlan.tpid;
>
> This should not depend on the current value in skb->protocol which
> could be arbitrary at this point (from the point of view of how this
> patch understands the skb->protocol values). It's easy to fix, though -
> just add a local bool variable tracking whether the skb->protocol has
> been set.
>
skb-protocol value is set by the caller, so it should not be
arbitrary. is it missing in any case?
