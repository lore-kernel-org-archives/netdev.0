From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Queue with wait-free enqueue, blocking dequeue, splice
Date: Mon, 20 Oct 2014 16:02:37 +0200
Message-ID: <20141020160237.302aa17c@redhat.com>
References: <1311316954.11157.1413631325000.JavaMail.zimbra@efficios.com>
	<412768308.11171.1413632892841.JavaMail.zimbra@efficios.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23907 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752220AbaJTODM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Oct 2014 10:03:12 -0400
In-Reply-To: <412768308.11171.1413632892841.JavaMail.zimbra@efficios.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sat, 18 Oct 2014 11:48:12 +0000 (UTC) Mathieu Desnoyers <mathieu.desnoyers@efficios.com> wrote:

> Following our LPC discussion on lock-free queue algorithms
> for qdisc, here is some info on the wfcqueue implementation
> found in Userspace RCU. See http://urcu.so for info and
> git repository.

Thank for following up on our very interesting discussions.

I've started with the more simple variant "urcu/static/wfqueue.h" to
understand the concepts.  And I'm now reading wfcqueue.h, which I guess
it replacing wfqueue.h.

 
> Here is the wfcqueue ported to the Linux kernel I sent last
> year as RFC:
> https://lkml.org/lkml/2013/3/14/289
> 
> I'm very interested to learn if it fits well for your
> use-case,

Does this wfcqueue API support bulk dequeue?  (A feature needed for the
lock-less qdisc implementation, else it cannot compete with our new
bulk dequeue strategy).

AFAIK your queue implementation is a CAS-based, Wait-Free on enqueue,
but Lock-Free on dequeue with the potential for waiting/blocking on
a enqueue processes.
 I'm not 100% sure, that we want this behavior for the qdisc system.

I can certainly use the wfcq_empty() check, but I guess I need to
maintain a separate counter to maintain the qdisc limit, right?
(I would use the approximate/split counter API percpu_counter to keep
this scalable, and wfcq_empty() would provide an accurate empty check)


I think, we/I should start micro benchmarking the different approaches.
As our time budget is only 67.2ns 
 http://netoptimizer.blogspot.dk/2014/05/the-calculations-10gbits-wirespeed.html
(or bulking tricks artificially "increase" this budget)


The motivation behind this lockless qdisc is, the current qdisc locking
cost 48ns, see slide 9/16 titled "Qdisc locking is nasty":
 http://people.netfilter.org/hawk/presentations/LinuxPlumbers2014/performance_tx_qdisc_bulk_LPC2014.pdf

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
