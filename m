From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG?] ixgbe: only num_online_cpus() of the tx queues are
 enabled
Date: Sat, 08 Mar 2014 19:37:38 -0800
Message-ID: <1394336258.20149.80.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAG+wggZOQ_VyAiLBuUUfW13=OqUun3g1vnYj5SEuWN+3hHreLg@mail.gmail.com>
	 <1394292461.20149.55.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1394294883.20149.70.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAG+wggbNpUqL12EAWdXxxxX6mGPj0+1HktDKJeeSxum6emBY_g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Erez Zadok <ezk@fsl.cs.sunysb.edu>,
	Dean Hildebrand <dhildeb@us.ibm.com>,
	Geoff Kuenning <geoff@cs.hmc.edu>
To: Ming Chen <v.mingchen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:63858 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752018AbaCIDhk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Mar 2014 22:37:40 -0500
Received: by mail-pd0-f172.google.com with SMTP id p10so5662085pdj.17
        for <netdev@vger.kernel.org>; Sat, 08 Mar 2014 19:37:40 -0800 (PST)
In-Reply-To: <CAG+wggbNpUqL12EAWdXxxxX6mGPj0+1HktDKJeeSxum6emBY_g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-03-08 at 19:53 -0500, Ming Chen wrote:
> Hi Eric,
> 
> We noticed many changes in the TCP stack, and a lot of them come from you :-)
> 
> Actually, we have a question about this patch you submitted
> (http://lwn.net/Articles/564979/) regarding an experiment we conducted
> in the 3.12.0 kernel. The results we observed in shown in the second
> figure of panel 6 in this poster at
> http://www.fsl.cs.sunysb.edu/~mchen/fast14poster-hashcast-portrait.pdf
> .  We have repeated the same experiment for 100 times, and observed
> that results like that appeared 4 times. For this experiment, we
> observed that all five flows are using dedicated tx queues.  But what
> makes a big difference is the average packet sizes of the flows.
> Client4 has an average packet size of around 3KB while all other
> clients generate packet sizes over 50KB. We suspect it might be caused
> by this TSO Packets Automatic Sizing feaure. Our reasoning is this: if
> a TCP flow starts slowly, this feature will assign it a small packet
> size. The packet size and the sending rate can somehow form a feedback
> loop, which can force the TCP flow's rate to stay low. What do you
> think about this?

I think nothing at all. TCP is not fair. TCP tries to steal whole
bandwidth by definition. One flow can have much more than the neighbour.

With FQ, you can force some fairness, but if you use multiqueue, there
is no guarantee at all, unless you make sure :

- no more than one flow per queue.
- Nic is able to provide fairness among all active TX queues.

Thats the ideal condition, and that is quite hard to meet.

The feedback loop you mention should be solved by the patch I sent
today : TCP Small queue make sure that you have no more than 2 packets
per flow on qdisc / TX queues. So on 'fast' flow cannot have 90% of the
packets in the qdisc. cwnd is maintained to very small values, assuming
receiver is behaving normally.
