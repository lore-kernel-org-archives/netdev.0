From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Fri, 11 May 2007 10:52:16 +0530
Message-ID: <OF5A173A00.C4FD79C5-ON652572D8.001C203E-652572D8.001D8134@in.ibm.com>
References: <1178827887.4062.90.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Gagan Arneja <gaagaan@gmail.com>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>,
	Sridhar Samudrala <sri@US.IBM.COM>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:39089 "EHLO
	ausmtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754308AbXEKFXA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 01:23:00 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l4B5gg2i037956
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 15:42:42 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.250.237])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4B5QNR7058012
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 15:26:25 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4B5MnJ7031332
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 15:22:50 +1000
In-Reply-To: <1178827887.4062.90.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

J Hadi Salim <j.hadi123@gmail.com> wrote on 05/11/2007 01:41:27 AM:

> > It's not just small packets. The cost of calling hard_start_xmit/byte
> > was rather high on your particular device. I've seen  PCI read
> > transaction in hard_start_xmit taking ~10,000 cycles on one particular
> > device. Count the cycles your brand of NIC is taking in it's
> > xmit_routine. The worse it is, the stronger your case for cluster
> > transmits.
>
> You would need to almost re-write the driver to make sure it does IO
> which is taking advantage of the batching.

I didn't try to optimize the driver to take any real advantage, I coded it
as simply as :

top:
      next = skb->skb_flink;
      Original driver code here, or another option is to remove the locking
            and put it before the "top:" above, no other changes.
      skb = next;
      if (skb)
            goto top;
This way, the diffs are minimal. However, driver experts might know of some
tricks to optimize this, since most drivers have a hundred checks before
sending one skb, and whether some optimization to avoid that for each skb
is possible.

> You could avoid totaly requeueing by asking the driver how much space it
> has. Once you shove down to it a number of packets, you are then
> guaranteed they will never be requeued (refer to the slides i pointed to
> earlier).

This is a good idea, I will look at your slides to see what this exactly
is.
However, even with this check, drivers will return error, eg trylock failed
or, like the e1000 has - fifo_workaround failures. But I still think it
will
significantly reduce the failures. Right now, I get a lot of requeue's.

thanks,

- KK

