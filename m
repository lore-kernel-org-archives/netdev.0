From: David Lamparter <equinox@diac24.net>
Subject: Re: [PATCH RFC] net: hardware limited MTU for 802.1Q frames
Date: Fri, 23 Mar 2012 15:41:26 +0100
Message-ID: <20120323144126.GE3085863@jupiter.n2.diac24.net>
References: <1332499886-1126-1-git-send-email-msink@permonline.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Mike Sinkovsky <msink@permonline.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:50245 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756472Ab2CWOld (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2012 10:41:33 -0400
Content-Disposition: inline
In-Reply-To: <1332499886-1126-1-git-send-email-msink@permonline.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 23, 2012 at 03:51:26PM +0500, Mike Sinkovsky wrote:
> This patch add callback in net_device_ops, called from 8021q
> code to check for this hardware limitation.
[...]
> + * int (*ndo_get_hard_mtu)(struct net_device *dev)
> + *	If defined, returns hardware limit for MTU.
> + *	Called when a slave device needs to set MTU, to make sure that
> + *	this limit is not exceed.
> + *	If not defined, dev->mtu is used in hope the underlying device can
> + *	handle it.
> + *

This is, in my opinion, not thought through enough. In particular, there
are two interacting factors that your patch does not consider:

 - there are devices that support 802.1Q outside of the actual hard MTU
   limitation. (example: i think AT91SAM on-chip ethernet). In these
   cases, the device has a hard MTU of (random example) 1536 bytes, but
   supports sending the extra 4 bytes of 802.1Q "outside" of that.

   (in a case with MTU 1536, the driver can well choose to ignore that.
   But if the device supports only 1500, plus an .1Q extra tag, that
   needs to be reflected or we lose proper VLAN support.)

 - there are other protocols that also need ethernet headroom. Here's a
   short list:
    - MPLS
    - 802.1ad
    - 802.1ah
   and very importantly:
    - 802.1Q stacked in 802.1Q
    - or any other stacking essentially

If anything, the semantics of your new callback need to be defined much
better; in reality I think we should pass down the protocol stacking to
the driver and ask for the resulting MTU.

Obviously these concerns are of the future-proofing nature, though I
wouldn't think adding this is wise when there are foreseeable
inadequacies.


-David
