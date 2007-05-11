From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Fri, 11 May 2007 14:48:14 +0530
Message-ID: <OF251384FB.93952CAB-ON652572D8.00324514-652572D8.00331BB3@in.ibm.com>
References: <20070511090138.GA24695@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Ian McDonald <ian.mcdonald@jandi.co.nz>, netdev@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp06.au.ibm.com ([202.81.18.155]:46492 "EHLO
	ausmtp06.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755531AbXEKJTb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 05:19:31 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp06.au.ibm.com (8.13.8/8.13.8) with ESMTP id l4B9KvGG6475818
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 19:20:57 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.250.242])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4B9MtZv164766
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 19:22:56 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4B9JNdp025265
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 19:19:24 +1000
In-Reply-To: <20070511090138.GA24695@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Evgeniy,

Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote on 05/11/2007 02:31:38 PM:

> On Fri, May 11, 2007 at 10:34:22AM +0530, Krishna Kumar2
(krkumar2@in.ibm.com) wrote:
> > Not combining packets, I am sending them out in the same sequence it
was
> > queued. If the xmit failed, the driver's new API returns the skb which
> > failed to be sent. This skb and all other linked skbs are requeue'd in
> > the reverse order (fofi?) till the next time it is tried again. I see
> > that sometimes I can send tx_queue_len packets in one shot and all
> > succeeds. But the downside is that in failure case, the packets have to
> > be requeue'd.
>
> And what if you have thousand(s) of packets queued and first one has
> failed, requeing all the rest one-by-one is not a solution. If it is
> being done under heavy lock (with disabled irqs especially) it becomes a
> disaster.

If first one failed for other reasons from described below, it is freed up
and the next one attempted. There are three cases where we cannot continue
:
no slots, device blocked, no lock.

Jamal had suggested to get information on #available slots from the driver.
The queue_stopped is checked before linking packets, so the only other
error case is not getting a lock. And this too is true only in the ~LLTX
case,
which optionally could be a check to enable this linking. Also, there could
be limits to how many packets are queue'd. I tried tx_queue_len as well as
tx_queue_len/2, but there could be other options.

> I thought of a bit different approach: driver maintains own queue (or
> has access to stack's one) and only uses lock to dequeue a packet. If
> transmit fails, nothing is requeued, but the same packet is tried until
> transmit is completed. If number of transmits failed in order, driver
> says it is broken and/or stops queue. Thus one can setup several
> descriptors in one go and do it without any locks. Stack calls driver's
> xmit function which essentially sets bit that new packets are available,
> but driver must have access to qdisk.

Bugs will increase if drivers also are allowed to access qdisc, since it
is difficult code as it is. Right now it is easy to see how the qdisc is
manipulated.

thanks,

- KK

> If e1000 driver would not be so... so 'uncommon' compared to another
> small gige drivers I would try to cook up a patch, but I will not with
> e1000 :)
>
> --
>    Evgeniy Polyakov

