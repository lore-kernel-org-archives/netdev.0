From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH v3 net-next 3/3] openvswitch: Fix skb->protocol for vlan frames.
Date: Sun, 4 Dec 2016 16:58:29 -0800
Message-ID: <CAOrHB_CBcFHh0S3s3JQy0fdXSmpucTe9QC3Rk1yJM2yhdZqDtQ@mail.gmail.com>
References: <1480462253-114713-1-git-send-email-jarno@ovn.org>
 <1480462253-114713-3-git-send-email-jarno@ovn.org> <20161130153041.7a9590ef@griffin>
 <CAOrHB_CAR8G=BF6X_+HgkRRnb=Erc6CYpCL4EnJfDRe7qBR2vg@mail.gmail.com> <20161202104202.426b2c80@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jarno Rajahalme <jarno@ovn.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Garver <e@erig.me>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:51608 "EHLO
        relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751070AbcLEA6h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2016 19:58:37 -0500
Received: from mfilter6-d.gandi.net (mfilter6-d.gandi.net [217.70.178.135])
        by relay3-d.mail.gandi.net (Postfix) with ESMTP id C8754A80C6
        for <netdev@vger.kernel.org>; Mon,  5 Dec 2016 01:58:33 +0100 (CET)
Received: from relay3-d.mail.gandi.net ([IPv6:::ffff:217.70.183.195])
        by mfilter6-d.gandi.net (mfilter6-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id 4GZhwxdCn6DX for <netdev@vger.kernel.org>;
        Mon,  5 Dec 2016 01:58:32 +0100 (CET)
Received: from mail-io0-f177.google.com (mail-io0-f177.google.com [209.85.223.177])
        (Authenticated sender: pshelar@ovn.org)
        by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id 58A98A80CD
        for <netdev@vger.kernel.org>; Mon,  5 Dec 2016 01:58:31 +0100 (CET)
Received: by mail-io0-f177.google.com with SMTP id j65so571845489iof.0
        for <netdev@vger.kernel.org>; Sun, 04 Dec 2016 16:58:31 -0800 (PST)
In-Reply-To: <20161202104202.426b2c80@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 2, 2016 at 1:42 AM, Jiri Benc <jbenc@redhat.com> wrote:
> On Thu, 1 Dec 2016 12:31:09 -0800, Pravin Shelar wrote:
>> On Wed, Nov 30, 2016 at 6:30 AM, Jiri Benc <jbenc@redhat.com> wrote:
>> > I'm not opposed to changing this but I'm afraid it needs much deeper
>> > review. Because with this in place, no core kernel functions that
>> > depend on skb->protocol may be called from within openvswitch.
>> >
>> Can you give specific example where it does not work?
>
> I can't, I haven't reviewed the usage. I'm just saying that the stack
> does not expect skb->protocol being ETH_P_8021Q for e.g. IPv4 packets.
> It may not be relevant for the calls used by openvswitch but we should
> be sure about that. Especially defragmentation and conntrack is worth
> looking at.
>
> Again, I'm not saying this is wrong nor that there is an actual
> problem. I'm just pointing out that openvswitch has different
> expectations about skb wrt. vlans than the rest of the kernel and we
> should be reasonably sure the behavior is correct when passing between
> the two.
>
I agree that conntrack does not expect skb-protocol to be vlan
protocol. We could accelerate vlan if there is vlan header in packet
itself. That would make the packet consistent across upcalls.

>> skb-protocol value is set by the caller, so it should not be
>> arbitrary. is it missing in any case?
>
> It's not set exactly by the caller, because that's what this patch is
> removing. It is set by whoever handed over the packet to openvswitch.
> The point is we don't know *what* it is set to. It may as well be
> ETH_P_8021Q, breaking the conditions here. It should not happen in
> practice but still, it seems weird to depend on the fact that the
> packet coming to ovs has never skb->protocol equal to ETH_P_8021Q nor
> ETH_P_8021AD.
>

We are kind of dependent on this atleast for L3 packets injected back
by vswitchd. For rest of entry points I think we have to trust the
networking stack would set skb-protocol to correct value. If that is
not true in some case, it is bug and we will need to fix it.
