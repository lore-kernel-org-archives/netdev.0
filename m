From: Patrick Ohly <patrick.ohly@intel.com>
Subject: Re: [RFC][PATCH 1/2] net: support for TX timestamps
Date: Wed, 30 Jul 2008 14:43:33 +0200
Message-ID: <1217421813.30512.169.camel@ecld0pohly>
References: <1217291753-5322-1-git-send-email-opurdila@ixiacom.com>
	 <1217291753-5322-2-git-send-email-opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:53379 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756599AbYG3Mpi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jul 2008 08:45:38 -0400
In-Reply-To: <1217291753-5322-2-git-send-email-opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-07-29 at 03:35 +0300, Octavian Purdila wrote:
> The actual timestamp will reach userspace as a RX timestamp on the
> cloned packet. If timestamping is requested and no timestamping is
> done in the device driver (potentially this may use hardware
> timestamping), it will be done in software after the device's
> start_hard_xmit routine.

This needs to be augmented to not fall back to software time stamping,
as discussed in "[RFC][PATCH 1/1] net: support for hardware
timestamping".

Apart from that the API looks okay. It should be fairly simple to adapt
PTPd.

> @@ -1568,6 +1576,8 @@ static int dev_gso_segment(struct sk_buff *skb)
>  
>  int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  {
> +	int rc;
> +
>  	if (likely(!skb->next)) {
>  		if (!list_empty(&ptype_all))
>  			dev_queue_xmit_nit(skb, dev);
> @@ -1579,13 +1589,15 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  				goto gso;
>  		}
>  
> -		return dev->hard_start_xmit(skb, dev);
> +		rc = dev->hard_start_xmit(skb, dev);
> +		if (likely(!rc))
> +			net_tx_timestamp(skb);
> +		return rc;
>  	}

How do you recognize whether the driver did hardware time stamping? Hmm,
okay, I think I can answer that myself: if the driver supports hardware
time stamping, it must clear tstamp in its hard_start_xmit(). Later on
when it has transmitted the packet, it extracts the corresponding
hardware time stamp and calls skb_tx_timestamp(). Right? If so, this
should go into a comment somewhere.

The implicit assumption here is that drivers do not touch tstamp,
because otherwise software time stamping might accidentally be disabled
by a driver. That seems to be the case, at least for in-kernel drivers.

Is skb->sk always guaranteed to be set in hard_start_xmit?
skb_tx_timestamp() depends on it. In 2.6.23 the field always seemed to
be valid, but in 2.6.26 I think I have seen NULL pointers there for PTP
UDP broadcasts.

-- 
Best Regards, Patrick Ohly

The content of this message is my personal opinion only and although
I am an employee of Intel, the statements I make here in no way
represent Intel's position on the issue, nor am I authorized to speak
on behalf of Intel on this matter.

