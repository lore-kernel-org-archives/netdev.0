From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 2/3] NET: [CORE] Stack changes to add multiqueue hardware support API
Date: Thu, 28 Jun 2007 12:06:41 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC329031F061E@orsmsx414.amr.corp.intel.com>
References: <468405EE.8070802@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>, <jeff@garzik.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, <hadi@cyberus.ca>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:42867 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763995AbXF1TGn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2007 15:06:43 -0400
Content-class: urn:content-classes:message
In-Reply-To: <468405EE.8070802@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Waskiewicz Jr, Peter P wrote:
> >>Quick question: where are the sch_generic changes? :)
> >>
> >>If you hold for ten minutes I'll post a set of slightly changed 
> >>patches with the NETDEVICES_MULTIQUEUE option and a fix for this.
> > 
> > 
> > Jamal's and KK's qdisc_restart() rewrite took the 
> netif_queue_stopped()
> > call out of sch_generic.c.  So the underlying qdisc is only 
> responsible
> > for checking the queue status now before dequeueing.
> 
> 
> Yes, I noticed that now. Doesn't seem right though as long as
> queueing while queue is stopped is treated as a bug by the
> drivers.
> 
> But I vaguely recall seeing a discussion about this, I'll check
> the archives.

The basic gist is before the dequeue is done, the qdisc is locked by the
qdisc is running bit, so another CPU cannot get in there.  So if the
queue isn't stopped when a dequeue is done, that same queue should not
be stopped when hard_start_xmit() is called.  The only thing I could
think of that could happen is some out-of-band cleanup routine in the
driver where the tx_ring lock is held, and the skb is bounced back,
where the driver returns NETIF_TX_BUSY, and you requeue.  This is an
extreme corner case, so the check could be removed.

-PJ
