From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Fri, 11 May 2007 15:22:13 +0530
Message-ID: <OF6C27DF4E.9060BDB4-ON652572D8.0035C627-652572D8.00363827@in.ibm.com>
References: <20070511093202.GB24695@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Ian McDonald <ian.mcdonald@jandi.co.nz>, netdev@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:37719 "EHLO
	ausmtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753153AbXEKJxI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 05:53:08 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l4BACrP8140370
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 20:12:53 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.250.237])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4B9uZwV092094
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 19:56:36 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4B9r2Vo005205
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 19:53:03 +1000
In-Reply-To: <20070511093202.GB24695@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote on 05/11/2007 03:02:02 PM:

> On Fri, May 11, 2007 at 02:48:14PM +0530, Krishna Kumar2
(krkumar2@in.ibm.com) wrote:
> > > And what if you have thousand(s) of packets queued and first one has
> > > failed, requeing all the rest one-by-one is not a solution. If it is
> > > being done under heavy lock (with disabled irqs especially) it
becomes a
> > > disaster.
> >
> > If first one failed for other reasons from described below, it is freed
up
> > and the next one attempted. There are three cases where we cannot
continue
> > :
> > no slots, device blocked, no lock.
> >
> Why stack should ever know what hardware is being used?
> If you are going to break things, break it with scary sound :)

Actually it could just be an API exported by drivers which implement this
new
xmit API.

> Design new interface, where driver has access to the queue (say only
> using one helper dequeue_first_packet()), stack can only queue packets
> to the tail, driver can also stop that by setting a bit (which was there
> likely before we had knew word Linux).
>
> That is all, driver does not access qdisk, it only gets the first skb.
> Transmit function is completely lockless (until something is shared with
> receive path/interrupts, but it is private driver's part), stack will
> not be changed at all (except new helper to dequeue first packet from
> the qdisk, actually it is already there, it just needs to be exported),
> driver's xit function sets a flag that there are packets (or it can be
> even empty, since packet's presense can be detected via the same qdisk
> interface). You read qdisk len, setup several descriptors in one go,
> dequeue set of skbs and commit them. If something has failed, it is not
> requeued, but resent (or even dropped after fair amount of attempts).
> No locks, no requeues? Seems simple imho.

I will analyze this in more detail when I return (leaving just now, so got
really no time). The only issue that I see quickly is "No locks", since to
get things off the queue you need to hold the queue_lock.

Thanks,

- KK

