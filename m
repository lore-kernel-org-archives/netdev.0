From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: More info about lockless qdisc patch
Date: Sat, 7 Jan 2017 12:11:27 -0800
Message-ID: <58714B6F.5000301@gmail.com>
References: <D1B824B6-91C1-4049-8231-048FD900D160@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=gbk
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Xingjun Liu <yterrencelau@gmail.com>, john.r.fastabend@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36056 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936901AbdAGULp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Jan 2017 15:11:45 -0500
Received: by mail-pg0-f68.google.com with SMTP id 75so9210271pgf.3
        for <netdev@vger.kernel.org>; Sat, 07 Jan 2017 12:11:44 -0800 (PST)
In-Reply-To: <D1B824B6-91C1-4049-8231-048FD900D160@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-12-30 04:48 AM, Xingjun Liu wrote:
> Hi John,
> 
> I note you have a patch request last august about "support lockless qdisc¡±,
> 
> see: https://www.mail-archive.com/netdev@vger.kernel.org/msg124489.html

I have another set of patches that fixes a few bugs from the above.

> 
> We take an interest in it. Do you have any info/plan on this patch?
> 

The current state of the patches (the latest I have on my private tree) is
currently
I an issue with re-starting the driver when multiple cores do a dequeue but the
driver overruns the hardware descriptor ring so we push back into the qdisc. When
this happens the patches push the skb onto the gso_skb per cpu list.

Now the problem is how do we wake the correct gso_skb per cpu list up? The driver
will restart the qdisc at some future point but not necessarily from the same
cpu that
the per cpu enqueue happened on. So I tried to fix this by removing the driver
restart
logic and having the qdisc layer poll the driver. This sort of/kind of works
except its not
a very satisfying solution. Tom noted at one point with BQL the above case
should not
happen very much but it is still possible unfortunately under certain
conditions. And the
corner cases get ugly.

I've been kicking around another idea lately. To get rid of the gso_skb entirely
which
would certainly clean up the code and get rid of one of the uglier pieces of
qdisc struct
in my opinion. To make this work I want to add a tx_prep() ndo call the qdisc
could call
into the driver with to reserve "slots" in the driver. Once we have some # of
slots reserved
we can dequeue from the qdisc ring and send to driver "knowing" that the driver has
agreed to consume the packets. The trick here is sk_buffs do not map 1:1 with
descriptors
in the hardware always so a bit of driver magic needs to occur to get
calculations correct.

I'll try to rebase the current set of patches I have on net-next and post it
just so its
available. I can probably get to the above in a month or so. Maybe have something by
March.

Thanks,
John

> Thanks
> Xingjun
> 
