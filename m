From: Jarno Rajahalme <jarno@ovn.org>
Subject: Re: [PATCH net-next 1/7] openvswitch: Use inverted tuple in ovs_ct_find_existing() if NATted.
Date: Tue, 7 Feb 2017 13:29:28 -0800
Message-ID: <4954688E-16C4-4474-B3A2-69443E6E2FB6@ovn.org>
References: <1486084206-109903-1-git-send-email-jarno@ovn.org> <20170205.172824.848224453582586032.davem@davemloft.net> <CAOrHB_AWB7MFEHpeuKcG21s9QWjMHKC2zWNmXQLDo_5KZrnY6w@mail.gmail.com> <20170206.121512.1686451353447088557.davem@davemloft.net> <CAOrHB_AOYrzDVZBST-TDZo2ZtrBqQiv6+0eHNDJuukGUDYGZFQ@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35985 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752869AbdBGV3b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 16:29:31 -0500
Received: by mail-pg0-f68.google.com with SMTP id 75so13098051pgf.3
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 13:29:31 -0800 (PST)
In-Reply-To: <CAOrHB_AOYrzDVZBST-TDZo2ZtrBqQiv6+0eHNDJuukGUDYGZFQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Feb 7, 2017, at 9:14 AM, Pravin Shelar <pshelar@ovn.org> wrote:
> 
> On Mon, Feb 6, 2017 at 9:15 AM, David Miller <davem@davemloft.net> wrote:
>> From: Pravin Shelar <pshelar@ovn.org>
>> Date: Mon, 6 Feb 2017 09:06:29 -0800
>> 
>>> On Sun, Feb 5, 2017 at 2:28 PM, David Miller <davem@davemloft.net> wrote:
>>>> From: Jarno Rajahalme <jarno@ovn.org>
>>>> Date: Thu,  2 Feb 2017 17:10:00 -0800
>>>> 
>>>>> This does not match either of the conntrack tuples above.  Normally
>>>>> this does not matter, as the conntrack lookup was already done using
>>>>> the tuple (B,A), but if the current packet does not match any flow in
>>>>> the OVS datapath, the packet is sent to userspace via an upcall,
>>>>> during which the packet's skb is freed, and the conntrack entry
>>>>> pointer in the skb is lost.
>>>> 
>>>> This is the real bug.
>>>> 
>>>> If the metadata for a packet is important, as it obviously is here,
>>>> then upcalls should preserve that metadata across the upcall.  This
>>>> is exactly how NF_QUEUE handles this problem and so should OVS.
>>> 
>>> OVS kernel datapath serializes skb context and sends it along with skb
>>> during upcall via genetlink parameters. userspace echoes same
>>> information back to kernel modules. This way OVS does maintains
>>> metadata across upcall.
>> 
>> Then the conntrack state looked up before the NAT operation done in
>> the upcall should be maintained and therefore this bug should not
>> exist.
> 

We already maintain enough metadata across the userspace upcall, but so far we have failed to use it correctly in the case of NATted packets. The NAT flags are there, based on which we (now) know that we have to do inverted lookup to locate the conntrack entry. Conntrack NAT by design only stores tuples for the incoming packets, and there are various instances of tuple inversions in netfilter code for this reason (see, for example, net/netfilter/nf_nat_core.c:nf_nat_used_tuple()). I’ll make the commit message clearer about this for the v2 of the series.

> I think it fails because after upcall OVS is performing lookup for
> nonexistent conntrack entry. This is due to the fact that the packet
> is already Nat-ed. So one could argue that there is already enough
> context available in OVS to lookup original conntract entry after the
> upcall as shown in this patch.
> But I am also fine with using original context to lookup the conntract
> entry as Joe has suggested.

For expected (i.e., related) connection, using the master’s original direction 5-tuple added to the flow meta-data in patch 5 would find the master connection, not the related connection, so it would not work.

  Jarno
