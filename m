From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH] net/sched: sch_plug - Queue traffic until an explicit
 release command
Date: Tue, 20 Dec 2011 09:38:22 -0500
Message-ID: <1324391902.17751.227.camel@mojatatu>
References: <1324329752-28459-1-git-send-email-rshriram@cs.ubc.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Brendan Cully <brendan@cs.ubc.ca>
To: rshriram@cs.ubc.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:41136 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751900Ab1LTOi1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2011 09:38:27 -0500
Received: by vbbfc26 with SMTP id fc26so4935734vbb.19
        for <netdev@vger.kernel.org>; Tue, 20 Dec 2011 06:38:26 -0800 (PST)
In-Reply-To: <1324329752-28459-1-git-send-email-rshriram@cs.ubc.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Sorry - I didnt see your earlier CC. Cyberus.ca is probably the
worst service provider in Canada (maybe the world; i am sure there
are better ISPs in the middle of an ocean somewhere, deep underwater
probably).

On Mon, 2011-12-19 at 13:22 -0800, rshriram@cs.ubc.ca wrote:
> This qdisc can be used to implement output buffering, an essential
> functionality required for consistent recovery in checkpoint based
> fault tolerance systems. 

I am trying to figure where this qdisc runs - is it in the hypervisor?

> The qdisc supports two operations - plug and
> unplug. When the qdisc receives a plug command via netlink request,
> packets arriving henceforth are buffered until a corresponding unplug
> command is received.

Ok, so plug indicates "start of checkpoint" and unplug the end.
Seems all you want is at a certain point to throttle the qdisc and
later on unplug/unthrottle, correct?
Sounds to me like a generic problem that applies to all qdiscs?

> Its intention is to support speculative execution by allowing generated
> network traffic to be rolled back. It is used to provide network
> protection for domUs in the Remus high availability project, available as
> part of Xen. This module is generic enough to be used by any other
> system that wishes to add speculative execution and output buffering to
> its applications.

Should get a nice demo effect of showing a simple ping working with
zero drops, but: what is the effect of not even having this qdisc?
If you just switch the qdisc to a sleeping state from user space, all
packets arriving at that qdisc will be dropped during the checkpoint
phase (and the kernel code will be tiny or none). 
If you do nothing some packets will be buffered and a watchdog 
will recover them when conditions become right.
So does this qdisc add anything different?

[Note: In your case when arriving packets find the queue filled up 
you will drop lotsa packets - depending on traffic patterns; so
not much different than above]

> +
> +#define FIFO_BUF    (10*1024*1024)

Aha.
Technically - use tc to do this. Conceptually:
This is probably what makes you look good in a demo if you have one; 
huge freaking buffer. If you are doing a simple ping (or a simple
interactive session like ssh) and you can failover in 5 minutes you
still wont be able to fill that buffer!

Look at the other feedback given to you (Stephen and Dave responded).

If a qdisc is needed, should it not be a classful qdisc?

cheers,
jamal
