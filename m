From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH 00/16] Remove the ipv4 routing cache
Date: Wed, 25 Jul 2012 16:02:45 -0700
Message-ID: <CAKgT0UdcqE52WFCT-t2om0SN3Yq5GqiwN+JbwCcnBv4LDOB6BQ@mail.gmail.com>
References: <20120720.142502.1144557295933737451.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:35811 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750975Ab2GYXCq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2012 19:02:46 -0400
Received: by vbbff1 with SMTP id ff1so1102907vbb.19
        for <netdev@vger.kernel.org>; Wed, 25 Jul 2012 16:02:45 -0700 (PDT)
In-Reply-To: <20120720.142502.1144557295933737451.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 20, 2012 at 2:25 PM, David Miller <davem@davemloft.net> wrote:
>
> [ Ok I'm going to be a little bit cranky, and I think I deserve it.
>
>   I'm basically not going to go through the multi-hour rebase and
>   retest process again, as it's hit the point of diminishing returns
>   as NOBODY is giving me test results but I can guarentee that
>   EVERYONE will bitch and complain when I push this into net-next and
>   it breaks their favorite feature.  If you can't be bothered to test
>   these changes, I'm honestly going to tell people to take a hike and
>   fix it themselves.  I simply don't care if you don't care enough to
>   test changes of this magnitude to make sure your favorite setup
>   still works.
>
>   To say that I'm disappointed with the amount of testing feedback
>   after posting more than a dozen iterations of this delicate patch
>   set would be an understatement.  I can think of only one person who
>   actually tested one iteration of these patches and gave feedback.
>
>   And meanwhile I've personally reviewed, tested, and signed off on
>   everyone else's work WITHOUT DELAY during this entire process.
>
>   I've pulled 25 hour long hacking shifts to make that a reality, so
>   that my routing cache removal work absolutely would not impact or
>   delay the patch submissions of any other networking developer.  And
>   I can't even get a handful of testers with some feedback?  You
>   really have to be kidding me.. ]

Sorry for not responding sooner but I have been on vacation for the
last few days.

I had been testing the patches over the last couple of weeks but I
didn't really feel like I could provide any input of value since I
don't have a strong understanding of the routing stack internals, and
because my test case tends to focus on small packet routing with a
very artificial work flow.  I saw an overall drop in performance.  I
had attributed to the fact that with so few flows I was exploiting the
routing cache to it's maximum potential, and had not explored it much
further.

My test consists of a SmartBits w/ a 10Gb/s port connected back to
back with one port on an 82599 adapter.  I have the SmartBits
generating up to 16 64byte packet flows, each flow is filtered through
an ntuple filter to a specific queue, and each queue is pinned to a
specific CPU.  The flows all have a unique source address but the same
destination address.  The port doing the routing has two subnets.  We
receive packets on the first subnet and then transmit them back out on
the second.  I have set-up a static ARP entry for the destination
address in order to avoid the need for ARP address translation since
we are sending such a heavy packet load.  My kernel config is stripped
down and does not include netfilter support.

Since your patches are in I have started to re-run my tests. I am
seeing a significant drop in throughput with 8 flows which I expected,
however it looks like one of the biggest issues I am seeing is that
the dst_hold and dst_release calls seem to be causing some serious
cache thrash.  I was at 12.5Mpps w/ 8 flows before the patches, after
your patches it drops to 8.3Mpps.  If I increase the number of queues
I am using to 16 the throughput drops off to something like 3.3Mpps.
Prior to your patches being applied the top 3 CPU consumers were
ixgbe_poll at around 10%, ixgbe_xmit_frame_ring at around 5%, and
__netif_receive_skb at around 5%.  Below is the latest perf results
for 8 flows/queues after your patches:
    14.52%  [k] __write_lock_failed
    10.68%  [k] ip_route_input (75% of hits on dst_hold call)
    10.18%  [k] fib_table_lookup
     6.04%  [k] ixgbe_poll
     5.80%  [k] dst_release
     4.14%  [k] __netif_receive_skb
     3.55%  [k] _raw_spin_lock
     2.84%  [k] ip_forward
     2.58%  [k] ixgbe_xmit_frame_ring

I am also seeing routing fail periodically.  I will be moving at rates
listed above and suddenly drop to single digits packets per second.
When this occurs the trace completely changes and __write_lock_failed
jumps to over 90% of the CPU cycles.  It seems to occur more often if
I increase the number of CPUs in use while routing.  Below is the call
graph I recorded for the function from perf to show the function calls
that are leading to the issue:
    14.52%  [k] __write_lock_failed
            |
            |--99.92%-- _raw_write_lock_bh
            |          __neigh_event_send
            |          neigh_resolve_output
            |          ip_finish_output
            |          ip_output
            |          ip_forward
            |          ip_rcv
            |          __netif_receive_skb
            |          netif_receive_skb
            |          napi_skb_finish
            |          napi_gro_receive
            |          ixgbe_poll
            |          net_rx_action
            |          __do_softirq
            |          run_ksoftirqd
            |          kthread
            |          kernel_thread_helper
             --0.08%-- [...]

I am trying to figure out what can be done, but as I said I am not
that familiar with the internals of the IP routing stack itself.  If
you need more data let me know and I can see about performing whatever
test, or altering my configuration as needed.

Thanks,

Alex
