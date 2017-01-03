From: Wolfgang Reiter <wr0112358@gmail.com>
Subject: Re: [PATCH] drop_monitor: consider inserted data in genlmsg_end
Date: Wed, 04 Jan 2017 00:09:45 +0100
Message-ID: <8737gzd9l2.fsf@lautreamont.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170103003910.8984-1-wr0112358@gmail.com> <20170103.095419.261470619535526723.davem@davemloft.net> <20170103160443.GC11735@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>,
        David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170103160443.GC11735@hmsreliant.think-freely.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Yes, genlmsg_end changes nlmsg_len field dependent on skb->tail.
After allocation in reset_per_cpu_data skb->tail is modified in
trace_drop_common via __nla_reserve_nohdr.

Best place for setting nlmsg_len to its final value is after being
swapped out in reset_per_cpu_data.

Neil Horman <nhorman@tuxdriver.com> writes:

> On Tue, Jan 03, 2017 at 09:54:19AM -0500, David Miller wrote:
>> From: Reiter Wolfgang <wr0112358@gmail.com>
>> Date: Tue,  3 Jan 2017 01:39:10 +0100
>> 
>> > Final nlmsg_len field update must reflect inserted net_dm_drop_point
>> > data.
>> > 
>> > This patch depends on previous patch:
>> > "drop_monitor: add missing call to genlmsg_end"
>> > 
>> > Signed-off-by: Reiter Wolfgang <wr0112358@gmail.com>
>> 
>> I don't understand why the current code doesn't work properly.
>> 
>> All over the tree, the pattern is:
>> 
>> 	x = genlmsg_put(skb, ...);
>> 	...
>> 	genlmsg_end(skb, x);
>> 
>> And that is exactly what the code is doing right now.
>> 
>
> Because reset_per_cpu_data should close the use of of the established skb
> that was being written to.  Without this patch we add the END tlv to the skb
> that is just getting started for use in the drop monitor, rather than for the
> skb that is getting returned for use in sending up to user space listeners.
>
> Or am I missing something?
