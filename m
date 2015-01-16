From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net: rps: fix cpu unplug
Date: Thu, 15 Jan 2015 16:14:34 -0800
Message-ID: <1421367274.11734.105.camel@edumazet-glaptop2.roam.corp.google.com>
References: <75547b88b7e2d15b35339a6321c3a929.squirrel@www.codeaurora.org>
	 <1421305282.11734.38.camel@edumazet-glaptop2.roam.corp.google.com>
	 <4504851fe2f44615e67cde94286a2fdd.squirrel@www.codeaurora.org>
	 <1421350095.11734.88.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1421358383.11734.97.camel@edumazet-glaptop2.roam.corp.google.com>
	 <9d793ea2f58c16ec1ceca0124eed4d67.squirrel@www.codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Prasad Sodagudi <psodagud@codeaurora.org>, netdev@vger.kernel.org,
	Tom Herbert <therbert@google.com>
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:57734 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755859AbbAPAOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 19:14:36 -0500
Received: by mail-ie0-f180.google.com with SMTP id rp18so18078163iec.11
        for <netdev@vger.kernel.org>; Thu, 15 Jan 2015 16:14:36 -0800 (PST)
In-Reply-To: <9d793ea2f58c16ec1ceca0124eed4d67.squirrel@www.codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-01-15 at 22:29 +0000, subashab@codeaurora.org wrote:
> Thanks for the patch. I shall try it out and provide feedback soon.
> But we think the race condition issue is different. The crash was observed
> in the process_queue.


> 
> On the event of a CPU hotplug, the NAPI poll_list is copied over from the
> offline CPU to the CPU on which dev_cpu_callback() was called. These
> operations happens in  dev_cpu_callback() in the context of the notifier
> chain from hotplug framework.  Also in the same hotplug notifier context
> (dev_cpu_callback) the input_pkt_queue and  process_queue of the offline
> CPU are dequeued and sent up the network stack and this is where I think
> the race/problem is.
> 
> Context1: The online CPU starts processing the poll_list from
> net_rx_action since a
> softIRQ was raised in dev_cpu_callback(). process_backlog() draining the
> process queue
> 
> Context2: hotplug notifier dev_cpu_callback() draining the queues and
> calling netif_rx().
> 
> from dev_cpu_callback()
> 	/* Process offline CPU's input_pkt_queue */
> 	while ((skb = __skb_dequeue(&oldsd->process_queue))) {
> 		netif_rx(skb);
> 		input_queue_head_incr(oldsd);
> 	}
> 	while ((skb = __skb_dequeue(&oldsd->input_pkt_queue))) {
> 		netif_rx(skb);
> 		input_queue_head_incr(oldsd);
> 	}
> 
> Is this de-queuing(the above code snippet from dev_cpu_callback())
> actually necessary since the poll_list should already have the backlog
> napi struct of the old CPU? In this case when process_backlog()
> actually runs it should drain these two queues of older CPU.
> Let me know your thoughts.


input_pkt_queue and process_queue have nothing to do with NAPI
poll_list : They store skbs.

dev_cpu_callback() is called when the cpu we are offlining is no longer
running. No interrupts either serviced by this offline cpu.

You have the absolute guarantee No one is manipulating process_queue at
the same time than you.

It looks like you found another issue, not related to RPS, but due to
the fact that commit 264524d5e5195f6e
("net: cpu offline cause napi stall") did not exclude the percpu
backlog.

process_backlog() MUST be called by the owner cpu. Otherwise we would
need to add locking everywhere, as you did, and this is simply insane.

I'll send a V2
