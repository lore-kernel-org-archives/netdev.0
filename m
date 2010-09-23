From: Christoph Lameter <cl@linux.com>
Subject: Re: igmp: Staggered igmp report intervals for unsolicited igmp
 reports
Date: Thu, 23 Sep 2010 10:32:17 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1009231026510.32567@router.home>
References: <alpine.DEB.2.00.1009221354410.32661@router.home> <alpine.DEB.2.00.1009221400010.32661@router.home> <OFF06BBC88.0B6755D5-ON882577A6.0068F4F8-882577A6.006B31FB@us.ibm.com> <alpine.DEB.2.00.1009221448460.32661@router.home>
 <20100922215052.GK11157@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Stevens <dlstevens@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	Bob Arendt <rda@rincon.com>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp102.prem.mail.ac4.yahoo.com ([76.13.13.41]:32921 "HELO
	smtp102.prem.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752578Ab0IWPcV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 11:32:21 -0400
In-Reply-To: <20100922215052.GK11157@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 22 Sep 2010, Jason Gunthorpe wrote:

> > The device is ready. Its just the multicast group that has not been
> > established yet.
>
> In IB when the SA replies to a group join the group should be ready,
> prior to that the device can't send into the group because it has no
> MLID for the group.. If you have a MLID then the group is working.

When the SA replies it has created the MLID but not reconfigured the
fabric yet. So the initial IGMP messages get lost.

> Is the issue you are dropping IGMP packets because the 224.0.0.2 join
> hasn't finished? Ideally you'd wait for the SA to reply before sending
> a IGMP, but a simpler solution might just be to use the broadcast MLID
> for packets addressed to a MGID that has not yet got a MLID. This
> would bebe similar to the ethernet behaviour of flooding.

IGMP reports are sent on the multicast group not on 224.0.0.2. 224.0.0.2
is only used when leaving a multicast group.

I thought also about solutions along the same lines. We could modify the
IB layer to send to 224.0.0.2 while until the SA has confirmed the
creation of the MC group. For that to work we first would need to modify
the SA logic to ensure that it only sends confirmation *after* the fabric
has been reconfigured. Then we need to switch the MLIDs of the MC group
when the notification is received.

If the IB layer has not joined 224.0.0.2 yet (and it will take awhile)
then we could even fallback to broadcast until its ready.

