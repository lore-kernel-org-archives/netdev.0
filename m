From: Andreas Arnez <arnez@vnet.ibm.com>
Subject: ksoftirqd doesn't really become active
Date: Mon, 28 Jul 2008 19:20:24 +0200
Message-ID: <877ib60vtz.fsf@vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:4315 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760599AbYG1RUm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2008 13:20:42 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.8/8.13.8) with ESMTP id m6SHKPws177626
	for <netdev@vger.kernel.org>; Mon, 28 Jul 2008 17:20:25 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m6SHKP6n1913056
	for <netdev@vger.kernel.org>; Mon, 28 Jul 2008 19:20:25 +0200
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m6SHKOEm032572
	for <netdev@vger.kernel.org>; Mon, 28 Jul 2008 19:20:24 +0200
Received: from heureka (dyn-9-152-220-54.boeblingen.de.ibm.com [9.152.220.54])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id m6SHKOmb032569
	for <netdev@vger.kernel.org>; Mon, 28 Jul 2008 19:20:24 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While testing with arpflood, I stumbled across what looks like a
general flaw in the softirq processing: softirqs were keeping one CPU
busy; only 1% of this CPU capacity was left to other applications.
But still ksoftirqd didn't get scheduled much, most of the time
softirqs were processed in the context of irq_exit.  Hence the
scheduler didn't really influence the balancing between softirq
processing and other tasks, as probably intended.  This looks like a
general flaw which should affect every platform in one way or the
other.

Here's what seems to happen: an arp storm leads to the NAPI activating
softirqs all the time.  After 10 softirqs in a row the softirq
processing is suspended and ksoftirqd is woken up.  Now the scheduler
influences the remaining time until the next interrupt, after which 10
softirqs are processed in the context of irq_exit again.

Let
  s = average time spent on processing 10 softirqs;
  t = average time distance between hardirqs

If hardirqs come in regularly, then this CPU spends
ca. s/(t+t*int(s/t)) of its time on softirq processing in irq_exit
context:

                    s
   _________________/\________________
  /                                   \
  |=============|=============|=======>-----|
  \_____________/
         t

Once s approaches or exceeds t, the CPU is at least 50% busy
processing softirqs, regardless of the scheduler's decisions.

What are useful ways to increase the scheduler's influence?  One way
might be to suspend softirq processing in irq_exit context as long as
ksoftirqd feels responsible.  I made a test with a quick hack, and
this looks promising.  Are there other suggestions?  Or should the
whole issue be dealt with in a completely different way?
