From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next v2 2/2] Re-check for a VIO_DESC_READY data
 descriptor after short udelay()
Date: Sat, 6 Sep 2014 17:02:53 -0400
Message-ID: <20140906210253.GA5710@oracle.com>
References: <20140902162029.GC31516@oracle.com>
 <5405EFE7.4090302@oracle.com>
 <20140904.223648.559995846094457545.davem@davemloft.net>
 <20140905134758.GB1256@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: david.stevens@oracle.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:23801 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751521AbaIFVDF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Sep 2014 17:03:05 -0400
Content-Disposition: inline
In-Reply-To: <20140905134758.GB1256@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (09/05/14 09:47), Sowmini Varadhan wrote:
> > The memory barrier exists in order to make sure the cookies et al. are
> > globally visible before the VIO_DESC_READY.  We don't want stores to
> > be reordered such that the VIO_DESC_READY is seen too early.
> 
> Ok, though David (dls) was just pointing out that a rmb() might
> be missing in vnet_walk_rx_one() before checking for READY descriptor

Stared at this a bit over the last two days, checked
the documentation, discussed with dls offline - looks like 
(a) the rmb() thing was mostly a red-herring/fud 
(b) we do need the wmb()

The wmb() part is working correctly as designed:

The producer will do
  /* code to set up cookies */
  wmb(); /* makes sure above changes are committed */
  d->hdr.state = VIO_DESC_READY;

the consumer will do

        if (desc->hdr.state != VIO_DESC_READY)
                return 1;
        err = vnet_rx_one(port, desc->size, desc->cookies, desc->ncookies);
                :
        desc->hdr.state = VIO_DESC_DONE;

So the vnet_rx_one() will only use valid cookie information at
all times.

This allows the code to correctly able to read multiple READY descriptors 
for a single LDC trigger, which it already does today.
(and it would be needlessly inefficient to clamp this down to
only one descriptor read per LDC-start in the vnet_rx())

So what (if any) is the outstanding question about wmb() at this 
point?

--Sowmini
