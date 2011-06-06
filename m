From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [E1000-devel] [PATCH] e100: Fix inconsistency in bad frames
 handling
Date: Mon, 6 Jun 2011 10:49:06 -0700 (Pacific Daylight Time)
Message-ID: <alpine.WNT.2.00.1106060940010.3568@JBRANDEB-DESK2.amr.corp.intel.com>
References: <BANLkTimpYniHhN6ccMXN7Lx3xDdK6sC+FQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>, netdev@vger.kernel.org
To: Andrea Merello <andrea.merello@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:13616 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752292Ab1FFRtH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jun 2011 13:49:07 -0400
In-Reply-To: <BANLkTimpYniHhN6ccMXN7Lx3xDdK6sC+FQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


<added netdev>, removed other useless lists.

On Sat, 4 Jun 2011, Andrea Merello wrote:
> In e100 driver it seems that the intention was to accept bad frames in
> promiscuous mode and loopback mode.
> I think this is evident because of the following code in the driver:
> 
> if (nic->flags & promiscuous || nic->loopback) {
> 		config->rx_save_bad_frames = 0x1;	/* 1=save, 0=discard */
> 		config->rx_discard_short_frames = 0x0;	/* 1=discard, 0=save */
> 		config->promiscuous_mode = 0x1;		/* 1=on, 0=off */
> 	}
> 

Hi, thanks for your work on e100.
 
> However this intention is not really realized because bad frames are
> discarded later by SW check.
> This patch finally honors the above intention, making the RX code to
> let bad frames to pass when the NIC is in promiscuous or loopback
> mode.

I think this may be a mistake by the authors of the software developers 
manual.  The manual suggests that save bad frames and save short frames 
should be enabled in promisc mode, but all of our other drivers *do not* 
save bad frames when in promiscuous mode (by design).  This is intentional 
because a bad frame is just that, bad, and with no hope of knowing if the 
data in it is okay/malicious/other.  I understand your reasoning above, 
but realistically the rx_save_bad_frames should NOT be set.  I'd ack a 
patch to comment that line out.

> This helped me a lot to debug an FPGA ethernet core.
> Maybe it can be also useful to someone else..

I think this patch is just that, debug only. As a developer I understand 
why this is useful, but there is no reason any normal user would be able 
to benefit from this, so for now, sorry:

NACK.

> 
> Thanks
> Andrea
> 
>  --- drivers/net/e100_orig.c     2011-06-14 23:29:38.322267075 +0200
> +++ drivers/net/e100.c  2011-06-14 23:34:10.700791472 +0200
> @@ -1975,7 +1975,8 @@ static int e100_rx_indicate(struct nic *
>         skb_put(skb, actual_size);
>         skb->protocol = eth_type_trans(skb, nic->netdev);
> 
> -       if (unlikely(!(rfd_status & cb_ok))) {
> +       if (unlikely(!(nic->flags & promiscuous || nic->loopback) &&
> +           !(rfd_status & cb_ok))) {
>                 /* Don't indicate if hardware indicates errors */
>                 dev_kfree_skb_any(skb);
>         } else if (actual_size > ETH_DATA_LEN + VLAN_ETH_HLEN) {
> 
