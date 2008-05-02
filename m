From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 01/13] QLogic VNIC: Driver - netdev implementation
Date: Fri, 02 May 2008 11:15:10 -0700
Message-ID: <adaiqxw4lox.fsf@cisco.com>
References: <20080430171028.31725.86190.stgit@localhost.localdomain>
	<20080430171624.31725.98475.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: general@lists.openfabrics.org, netdev@vger.kernel.org,
	amar.mudrankit@qlogic.com, poornima.kamath@qlogic.com
To: Ramachandra K <ramachandra.kuchimanchi@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:18035 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761315AbYEBSPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 14:15:12 -0400
In-Reply-To: <20080430171624.31725.98475.stgit@localhost.localdomain>
	(Ramachandra K.'s message of "Wed, 30 Apr 2008 22:46:24 +0530")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > From: Ramachandra K <ramachandra.kuchimanchi@qlogic.com>
 > 
 > QLogic Virtual NIC Driver. This patch implements netdev registration,
 > netdev functions and state maintenance of the QLogic Virtual NIC
 > corresponding to the various events associated with the QLogic Ethernet 
 > Virtual I/O Controller (EVIC/VEx) connection.
 > 
 > Signed-off-by: Poornima Kamath <poornima.kamath@qlogic.com>
 > Signed-off-by: Amar Mudrankit <amar.mudrankit@qlogic.com>

For the next submission please clean up the From and Signed-off-by
lines.  As it stands now you are saying that you (Ramachandra K) are the
author of the patch, and that Poornima and Amar signed off on it (ie
forwarded it), but you as the person sending the email did not sign off
on it.

 > +#include <rdma/ib_cache.h>

I would like to kill off the caching support in the IB core, so adding
new users of the API is not desirable.  However your code doesn't seem
to call any functions from this header anyway, so I guess you can just
delete the include.

 > +void vnic_stop_xmit(struct vnic *vnic, struct netpath *netpath)
 > +{
 > +	VNIC_FUNCTION("vnic_stop_xmit()\n");
 > +	if (netpath == vnic->current_path) {
 > +		if (vnic->xmit_started) {
 > +			netif_stop_queue(vnic->netdevice);
 > +			vnic->xmit_started = 0;
 > +		}
 > +
 > +		vnic_stop_xmit_stats(vnic);
 > +	}
 > +}

Do you have sufficient locking here?  Could vnic->current_path or
vnic->xmit_started change after they are tested, leading to bad results?
Also do you get anything from having a xmit_started flag that you
couldn't get just by testing with netif_queue_stopped()?

 > +	vnic = (struct vnic *)device->priv;

All this device->priv should probably be using netdev_priv() instead,
and without a cast (since a cast from void * is not needed).

 > +	if (jiffies > netpath->connect_time +
 > +		      vnic->config->no_path_timeout) {

want to use time_after() for jiffies comparison to avoid problems with
jiffies wrap.

 > +	vnic->netdevice = alloc_netdev((int) 0, config->name, vnic_setup);
 > +	vnic->netdevice->priv = (void *)vnic;

Not sure this is even kosher to do any more.  Anyway I think it's much
cleaner if you just allocate everything with alloc_netdev instead of
trying to stick your own structure in the priv pointer.

 > +extern cycles_t recv_ref;

seems like too generic a name to make global.  What the heck are you
using cycle_t to keep track of anyway?

 > +/* This array should be kept next to enum above since a change to npevent_type
 > +   enum affects this array. */
 > +static const char *const vnic_npevent_str[] = {
 > +    "PRIMARY CONNECTED",
 > +    "PRIMARY DISCONNECTED",
 > +    "PRIMARY CARRIER",

putting this in a header means every file that uses it gets a private copy/
