From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [RFC PATCH v2 5/5] Add sample for adding simple drop program to
 link
Date: Sat, 9 Apr 2016 13:27:03 -0400
Message-ID: <57093B67.1080604@mojatatu.com>
References: <1460090930-11219-1-git-send-email-bblanco@plumgrid.com>
 <1460090930-11219-5-git-send-email-bblanco@plumgrid.com>
 <57091625.1010206@mojatatu.com> <20160409164308.GA5750@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, tom@herbertland.com,
	alexei.starovoitov@gmail.com, ogerlitz@mellanox.com,
	daniel@iogearbox.net, brouer@redhat.com, eric.dumazet@gmail.com,
	ecree@solarflare.com, john.fastabend@gmail.com, tgraf@suug.ch,
	johannes@sipsolutions.net, eranlinuxmellanox@gmail.com,
	lorenzo@google.com
To: Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34640 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753884AbcDIR1L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Apr 2016 13:27:11 -0400
Received: by mail-io0-f193.google.com with SMTP id z133so20302237iod.1
        for <netdev@vger.kernel.org>; Sat, 09 Apr 2016 10:27:10 -0700 (PDT)
In-Reply-To: <20160409164308.GA5750@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-04-09 12:43 PM, Brenden Blanco wrote:
> On Sat, Apr 09, 2016 at 10:48:05AM -0400, Jamal Hadi Salim wrote:


>> Ok, sorry - should have looked this far before sending earlier email.
>> So when you run concurently you see about 5Mpps per core but if you
>> shoot all traffic at a single core you see 20Mpps?
> No, only sender is multiple, receiver is still single core. The flow is
> the same in all 4 of the send threads. Note that only ksoftirqd/6 is
> active.

Got it.
The sender was limited to the 20Mpps and you are able to keep up
if i understand correctly.


>>
>> Devil's advocate question:
>> If the bottleneck is the driver - is there an advantage in adding the
>> bpf code at all in the driver?
> Only by adding this hook into the driver has it become the bottleneck.
 >
> Prior to this, the bottleneck was later in the codepath, primarily in
> allocations.
>

Maybe useful in your commit log to show the prior and after.
Looking at both your and Daniel's profile you show in this email
mlx4_en_process_rx_cq() seems to be where the action is on both, no?

> If a packet is to be dropped, and a determination can be made with fewer
> cpu cycles spent, then there is more time for the goodput.
>

Agreed.

> Beyond that, even if the skb allocation gets 10x or 100x or whatever
> improvement, there is still a non-zero cost associated, and dropping bad
> packets with minimal time spent has value. The same argument holds for
> physical nic forwarding decisions.
>

I always go for the lowest hanging fruit.
It seemed it was the driver path in your case. When we removed
the driver overhead (as demoed at the tc workshop in netdev11) we saw
__netif_receive_skb_core() at the top of the profile.
So in this case seems it was mlx4_en_process_rx_cq() - thats why i
was saying the bottleneck is the driver.
Having said that: I agree that early drop is useful if not for anything
else to avoid the longer code path (but was worried after reading on
thread this was going to get into a messy stack-in-the-driver and i am
not sure it is avoidable either given a new ops interface is showing
  up).

>> I am curious than before to see the comparison for the same bpf code
>> running at tc level vs in the driver..
> Here is a perf report for drop in the clsact qdisc with direct-action,
> which Daniel earlier showed to have the best performance to-date. On my
> machine, this gets about 6.5Mpps drop single core. Drop due to failed
> IP lookup (not shown here) is worse @4.5Mpps.
>

Nice.
However, still for this to be orange/orange comparison you have to
run it on the _same receiver machine_ as opposed to Daniel doing
it on his for the one case. And two different kernels booted up
one patched  with your changes and another virgin without them.

cheers,
jamal
