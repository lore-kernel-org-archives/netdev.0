From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [Q] How to invalidate ARP cache for a network device from
 within kernel
Date: Sat, 27 Nov 2010 09:33:42 +0100
Message-ID: <20101127093342.3f1d01ce@stein>
References: <1290793099.3716.21.camel@maxim-laptop>
	<20101127021833.328e8942@stein>
	<1290821143.4145.3.camel@maxim-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux1394-devel <linux1394-devel@lists.sourceforge.net>
To: Maxim Levitsky <maximlevitsky@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:36509 "EHLO
	einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751290Ab0K0Idz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Nov 2010 03:33:55 -0500
In-Reply-To: <1290821143.4145.3.camel@maxim-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Nov 27 Maxim Levitsky wrote:
> Subject: [PATCH 1/3] firewire: net: restart ISO channel on bus resets
> 
> ---
>  drivers/firewire/net.c |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
> index 1a467a9..007969c 100644
> --- a/drivers/firewire/net.c
> +++ b/drivers/firewire/net.c
> @@ -1593,10 +1593,15 @@ static void fwnet_update(struct fw_unit *unit)
>  {
>  	struct fw_device *device = fw_parent_device(unit);
>  	struct fwnet_peer *peer = dev_get_drvdata(&unit->device);
> +	struct fwnet_device *dev = peer->dev;
>  	int generation;
>  
>  	generation = device->generation;
>  
> +	fw_iso_context_stop(dev->broadcast_rcv_context);
> +	fw_iso_context_start(dev->broadcast_rcv_context, -1, 0,
> +			FW_ISO_CONTEXT_MATCH_ALL_TAGS);
> +
>  	spin_lock_irq(&peer->dev->lock);
>  	peer->node_id    = device->node_id;
>  	peer->generation = generation;

Could you add a changelog?

And it can be optimized to do only once per bus generation.  E.g. add a
generation field for the IR context in fwnet_device.  Or do it only if
fw_unit is that of the local node.

OTOH, is this actually necessary on normal bus resets?  It should only
be necessary after PM resume, right?  If so, perhaps do it only if the
generation increased by more than one.

Also, wouldn't a fw_iso_context_start alone, without prior stop,
suffice?
-- 
Stefan Richter
-=====-==-=- =-== ==-==
http://arcgraph.de/sr/
