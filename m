From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net 2/2] net: fix a bug of dropping FCoE frames when disabling
 tx ip checksum
Date: Wed, 14 Mar 2012 20:35:55 +0000
Message-ID: <1331757355.2564.31.camel@bwh-desktop.uk.solarflarecom.com>
References: <1331708518-28120-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1331708518-28120-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, Yi Zou <yi.zou@intel.com>,
	<netdev@vger.kernel.org>, <gospo@redhat.com>, <sassmann@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:9963 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755332Ab2CNUf7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2012 16:35:59 -0400
In-Reply-To: <1331708518-28120-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-03-14 at 00:01 -0700, Jeff Kirsher wrote:
> From: Yi Zou <yi.zou@intel.com>
> 
> Fix a bug when using 'ethtool -K ethx tx off' to turn off tx ip checksum,
> FCoE CRC offload should not be impacte. The skb_checksum_help() is needed
> only if it's not FCoE traffic for ip checksum, regardless of ethtool toggling
> the tx ip checksum on or off.
[...]

I think the bug is more fundamental, and it's not just a problem for
FCoE.  For the transmit path, the ip_summed values are specified as:

[forwarding]
 *	COMPLETE: the most generic way. Device supplied checksum of _all_
 *	    the packet as seen by netif_rx in skb->csum.
 *	    NOTE: Even if device supports only some protocols, but
 *	    is able to produce some skb->csum, it MUST use COMPLETE,
 *	    not UNNECESSARY.

[locally-generated]
 *	NONE: skb is checksummed by protocol or csum is not required.
 *
 *	PARTIAL: device is required to csum packet as seen by hard_start_xmit
 *	from skb->csum_start to the end and to record the checksum
 *	at skb->csum_start + skb->csum_offset.

It's implicit that the checksum algorithm for CHECKSUM_PARTIAL is as
specified for TCP/IP.  So none of those is correct when a different
algorithm is to be used.

It seems like we may need another ip_summed value for FCoE, SCTP or any
other protocol with a different checksum algorithm that will be
offloaded.  Maybe allow CHECKSUM_UNNECESSARY to be used on output in
that case?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
