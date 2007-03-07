From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 1/2] NET: Multiple queue network device support
Date: Wed, 7 Mar 2007 14:18:41 -0800
Message-ID: <D5C1322C3E673F459512FB59E0DDC329026B6719@orsmsx414.amr.corp.intel.com>
References: <20070226.170317.41636240.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <jgarzik@pobox.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	<auke@foo-projects.org>, "Ronciak, John" <john.ronciak@intel.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:48817 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030297AbXCGWSq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2007 17:18:46 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20070226.170317.41636240.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,
	I did some research based on your feedback.  Specifically, I
looked at removing ->map_queue() and allowing ->enqueue() to take care
of mapping and locking of the queues (and ->dequeue()).  I found that it
can be done either way, but I'm not sure I like taking the locking out
of dev_queue_xmit(), and relying on the qdisc ->enqueue() to make sure
locking is completed correctly.  Having a map routine also allows
various parts of the stack to query the skb where it belongs.
	I also looked into storing the mapped queue value in the skb,
namely in skb->priority.  If I were to use this value, I'd lose
filtering capabilities in sch_prio.c, where if no tc filter exists for
the skb in question, it relies on the value of skb->priority to enqueue
to a band.  The value of skb->priority could also be used in a base
driver for further filtering (some of the MAC-based QoS on wireless
devices comes to mind), so I'm not sure I feel comfortable using that
field to store the queue.  I also envision some qdiscs in the future
that could change the mapping of bands to queues without reloading the
qdisc, so storing the queue information in the skb could lead to
out-of-order packets into queues (stale information in the skb).
	What do you think?

Thanks,

PJ Waskiewicz
Software Engineer
LAD - LAN Access Division, New Technologies
Intel Corporation
peter.p.waskiewicz.jr@intel.com
 

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net] 
> Sent: Monday, February 26, 2007 5:03 PM
> To: Kok, Auke-jan H
> Cc: jgarzik@pobox.com; netdev@vger.kernel.org; 
> linux-kernel@vger.kernel.org; Waskiewicz Jr, Peter P; 
> Brandeburg, Jesse; auke@foo-projects.org; Ronciak, John
> Subject: Re: [PATCH 1/2] NET: Multiple queue network device support
> 
> From: "Kok, Auke" <auke-jan.h.kok@intel.com>
> Date: Thu, 08 Feb 2007 16:09:50 -0800
> 
> > From: Peter Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> > 
> > Added an API and associated supporting routines for 
> multiqueue network 
> > devices.  This allows network devices supporting multiple 
> TX queues to 
> > configure each queue within the netdevice and manage each queue 
> > independantly.  Changes to the PRIO Qdisc also allow a user to map 
> > multiple flows to individual TX queues, taking advantage of 
> each queue 
> > on the device.
> > 
> > Signed-off-by: Peter Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> > Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> 
> Thanks for posting this.
> 
> I was wonding if it would be better to have the ->enqueue() 
> perform the mapping operation, store the queue index selected 
> inside of the skb, and just use the normal 
> ->hard_start_xmit() to send the packet out?
> 
> The only thing to take care of is the per-queue locking, but 
> that should be easily doable.
> 
> We might be able to do this even without making sk_buff any larger.
> For example, I suppose skb->priority might be deducable down 
> to a u16.  After a quick audit I really cannot see any 
> legitimate use of anything larger than 16-bit values, but a 
> more thorough audit would be necessary to validate this.
> 
