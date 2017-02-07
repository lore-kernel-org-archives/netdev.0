From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next 1/7] openvswitch: Use inverted tuple in
 ovs_ct_find_existing() if NATted.
Date: Tue, 7 Feb 2017 09:14:26 -0800
Message-ID: <CAOrHB_AOYrzDVZBST-TDZo2ZtrBqQiv6+0eHNDJuukGUDYGZFQ@mail.gmail.com>
References: <1486084206-109903-1-git-send-email-jarno@ovn.org>
 <20170205.172824.848224453582586032.davem@davemloft.net> <CAOrHB_AWB7MFEHpeuKcG21s9QWjMHKC2zWNmXQLDo_5KZrnY6w@mail.gmail.com>
 <20170206.121512.1686451353447088557.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jarno Rajahalme <jarno@ovn.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:47395 "EHLO
        relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752160AbdBGROb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 12:14:31 -0500
Received: from mfilter15-d.gandi.net (mfilter15-d.gandi.net [217.70.178.143])
        by relay5-d.mail.gandi.net (Postfix) with ESMTP id 7D5C941C08F
        for <netdev@vger.kernel.org>; Tue,  7 Feb 2017 18:14:28 +0100 (CET)
Received: from relay5-d.mail.gandi.net ([IPv6:::ffff:217.70.183.197])
        by mfilter15-d.gandi.net (mfilter15-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id EOHDJMUPoV6n for <netdev@vger.kernel.org>;
        Tue,  7 Feb 2017 18:14:27 +0100 (CET)
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
        (Authenticated sender: pshelar@ovn.org)
        by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id 01EB941C080
        for <netdev@vger.kernel.org>; Tue,  7 Feb 2017 18:14:26 +0100 (CET)
Received: by mail-wm0-f54.google.com with SMTP id v186so20168924wmd.0
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 09:14:26 -0800 (PST)
In-Reply-To: <20170206.121512.1686451353447088557.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 6, 2017 at 9:15 AM, David Miller <davem@davemloft.net> wrote:
> From: Pravin Shelar <pshelar@ovn.org>
> Date: Mon, 6 Feb 2017 09:06:29 -0800
>
>> On Sun, Feb 5, 2017 at 2:28 PM, David Miller <davem@davemloft.net> wrote:
>>> From: Jarno Rajahalme <jarno@ovn.org>
>>> Date: Thu,  2 Feb 2017 17:10:00 -0800
>>>
>>>> This does not match either of the conntrack tuples above.  Normally
>>>> this does not matter, as the conntrack lookup was already done using
>>>> the tuple (B,A), but if the current packet does not match any flow in
>>>> the OVS datapath, the packet is sent to userspace via an upcall,
>>>> during which the packet's skb is freed, and the conntrack entry
>>>> pointer in the skb is lost.
>>>
>>> This is the real bug.
>>>
>>> If the metadata for a packet is important, as it obviously is here,
>>> then upcalls should preserve that metadata across the upcall.  This
>>> is exactly how NF_QUEUE handles this problem and so should OVS.
>>
>> OVS kernel datapath serializes skb context and sends it along with skb
>> during upcall via genetlink parameters. userspace echoes same
>> information back to kernel modules. This way OVS does maintains
>> metadata across upcall.
>
> Then the conntrack state looked up before the NAT operation done in
> the upcall should be maintained and therefore this bug should not
> exist.

I think it fails because after upcall OVS is performing lookup for
nonexistent conntrack entry. This is due to the fact that the packet
is already Nat-ed. So one could argue that there is already enough
context available in OVS to lookup original conntract entry after the
upcall as shown in this patch.
But I am also fine with using original context to lookup the conntract
entry as Joe has suggested.
