From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Fri, 11 May 2007 12:22:55 +0530
Message-ID: <OFE9F48A4E.113AD706-ON652572D8.002496EE-652572D8.0025CE03@in.ibm.com>
References: <46440D39.8060207@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, Rick Jones <rick.jones2@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>
To: Gagan Arneja <gaagaan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:34796 "EHLO
	ausmtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755143AbXEKH2Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 03:28:25 -0400
In-Reply-To: <46440D39.8060207@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Gagan,

> I have to claim incomplete familiarity for the code. But still, if
> you're out there running with no locks for a period, there's no
> assumption you can make. The "lock could be held quickly" assertion is a
> fallacy.

I will try to explain since the code is pretty complicated. Packets coming
to IP (in dev_queue_xmit) are first added to a FIFO queue associated with
the device (queue_lock is first held). Then qdisc_run is called and if it
can set the QDISC_RUNNING bit (making it the "sole dequeue'r"), it calls
qdisc_restart (which *could* get the tx lock) and drops the queue_lock to
call the actual driver xmit routine. Meanwhile 'n' cpus can race and add
more skbs to the same queue, each getting this lock for a short time and
dropping, and all these skbs are added to the end of the queue. These are
"pure enqueuer's" (since their attempt to set the same bit fails and they
return from qdisc_run). In the original thread, the dequeue'r gets an error
from driver xmit. It first re-gets the queue_lock and calls requeue, which
adds the skb to the head of the queue. Since no one else has been able to
dequeue packets while the RUNNING bit is set, packet re-ordering cannot
happen. After returning to __qdisc_run, the RUNNING bit is cleared.

Hope that clarifies the code.

thanks,

- KK

