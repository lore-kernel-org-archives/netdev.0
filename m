From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: RE: [PATCH 2/2] qdisc_restart - couple of optimizations.
Date: Thu, 14 Jun 2007 09:48:09 +0530
Message-ID: <OF5152E488.5AFFE971-ON652572FA.0016B5B2-652572FA.0017A29C@in.ibm.com>
References: <D5C1322C3E673F459512FB59E0DDC3290306A777@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, herbert@gondor.apana.org.au, hadil@cyberus.ca,
	kaber@trash.net, kumarkr@linux.vnet.ibm.com,
	netdev@vger.kernel.org, tgraf@suug.ch
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:55110 "EHLO
	ausmtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750840AbXFNESV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jun 2007 00:18:21 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l5E4daDl257032
	for <netdev@vger.kernel.org>; Thu, 14 Jun 2007 14:39:36 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.250.242])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5E4LYq8207092
	for <netdev@vger.kernel.org>; Thu, 14 Jun 2007 14:21:38 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5E4HwuA000942
	for <netdev@vger.kernel.org>; Thu, 14 Jun 2007 14:18:02 +1000
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC3290306A777@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Peter,

Thanks for your feedback.

> > - netif_queue_stopped need not be called inside qdisc_restart as
> >   it has been called already in qdisc_run() before the first skb
> >   is sent, and in __qdisc_run() after each intermediate skb is
> >   sent (note : we are the only sender, so the queue cannot get
> >   stopped while the tx lock was got in the ~LLTX case).
>
> I somewhat disagree here.  The underlying driver can conceivably stop
> the device queue even if the stack holds the queue lock during an
> interrupt to clean Tx descriptors, and it finds it's out of them or
> needs to grab the device for whatever reason.  Granted this is a corner
> case, and the net effect would be a simple requeue of the skb, but
> checking the status of the queue at the last possible moment before
> entering the driver could alleviate the requeue in the time between
> ->dequeue() from the qdisc, and hard_start_xmit() if an event like I
> mentioned happened.

After seeing a few drivers, I understand that the rx intr (to clean
TX descriptors) can only enable the queue and not stop the queue (as
it will normally not queue any packets and only clean up the sent
ones). I don't find any way that the driver can stop the queue once
the top layer determines it is OK to send and is enqueing.

It is a wasted check for almost every packet (and IMHO opinion, for
every packet). And as you said - if a driver were written differently
to stop the queue even in the clean path, then that rare event (should
be very rare as we checked for stop_queue just a few instrutions
earlier) will result in a requeue, but the normal path is not penalized.

Thanks,

- KK

> I'm ok with it either way, especially since this is a corner case.  But
> it does need to be considered that it can happen.

