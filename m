From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 2/3][NET_BATCH] net core use batching
Date: Mon, 8 Oct 2007 12:46:23 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32903BC1234@orsmsx414.amr.corp.intel.com>
References: <1191868010.4335.33.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <krkumar2@in.ibm.com>, <johnpol@2ka.mipt.ru>,
	<herbert@gondor.apana.org.au>, <kaber@trash.net>,
	<shemminger@linux-foundation.org>, <jagana@us.ibm.com>,
	<Robert.Olsson@data.slu.se>, <rick.jones2@hp.com>,
	<xma@us.ibm.com>, <gaagaan@gmail.com>, <netdev@vger.kernel.org>,
	<rdreier@cisco.com>, <mcarlson@broadcom.com>, <jeff@garzik.org>,
	<mchan@broadcom.com>, <general@lists.openfabrics.org>,
	<tgraf@suug.ch>, <randy.dunlap@oracle.com>, <sri@us.ibm.com>
To: <hadi@cyberus.ca>, "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:11866 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750952AbXJHTq1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 15:46:27 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1191868010.4335.33.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: J Hadi Salim [mailto:j.hadi123@gmail.com] On Behalf Of jamal
> Sent: Monday, October 08, 2007 11:27 AM
> To: David Miller
> Cc: krkumar2@in.ibm.com; johnpol@2ka.mipt.ru; 
> herbert@gondor.apana.org.au; kaber@trash.net; 
> shemminger@linux-foundation.org; jagana@us.ibm.com; 
> Robert.Olsson@data.slu.se; rick.jones2@hp.com; 
> xma@us.ibm.com; gaagaan@gmail.com; netdev@vger.kernel.org; 
> rdreier@cisco.com; Waskiewicz Jr, Peter P; 
> mcarlson@broadcom.com; jeff@garzik.org; mchan@broadcom.com; 
> general@lists.openfabrics.org; kumarkr@linux.ibm.com; 
> tgraf@suug.ch; randy.dunlap@oracle.com; sri@us.ibm.com
> Subject: [PATCH 2/3][NET_BATCH] net core use batching
> 
> This patch adds the usage of batching within the core.
> 
> cheers,
> jamal

Hey Jamal,
	I still have concerns how this will work with Tx multiqueue.
The way the batching code looks right now, you will probably send a
batch of skb's from multiple bands from PRIO or RR to the driver.  For
non-Tx multiqueue drivers, this is fine.  For Tx multiqueue drivers,
this isn't fine, since the Tx ring is selected by the value of
skb->queue_mapping (set by the qdisc on {prio|rr}_classify()).  If the
whole batch comes in with different queue_mappings, this could prove to
be an interesting issue.
	Now I see in the driver HOWTO you recently sent that the driver
will be expected to loop over the list and call it's ->hard_start_xmit()
for each skb.  I think that should be fine for multiqueue, I just wanted
to see if you had any thoughts on how it should work, any performance
issues you can see (I can't think of any).  Since the batching feature
and Tx multiqueue are very new features, I'd like to make sure we can
think of any possible issues with them coexisting before they are both
mainline.

	Looking ahead for multiqueue, I'm still working on the per-queue
lock implementation for multiqueue, which I know will not work with
batching as it's designed today.  I'm still not sure how to handle this,
because it really would require the batch you send to have the same
queue_mapping in each skb, so you're grabbing the correct queue_lock.
Or, we could have the core grab all the queue locks for each
skb->queue_mapping represented in the batch.  That would block another
batch though if it had any of those queues in it's next batch before the
first one completed.  Thoughts?

Thanks Jamal,

-PJ Waskiewicz
<peter.p.waskiewicz.jr@intel.com>
