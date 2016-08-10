From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net] bnx2x: don't reset chip on cleanup if PCI function is
 offline
Date: Wed, 10 Aug 2016 07:59:55 +0000
Message-ID: <CO2PR11MB008852D899DEF786AD7CB48C971D0@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1470687227-21024-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
 <CO2PR11MB0088856E58DAADE7064F28AF971C0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <57A9DA2B.7080908@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: "Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0137.outbound.protection.outlook.com ([104.47.33.137]:23543
	"EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S934937AbcHJTfa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2016 15:35:30 -0400
In-Reply-To: <57A9DA2B.7080908@linux.vnet.ibm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Why would the published resume()  from pci_error_handlers be called in this
> scenario?
> 
> It isn't. That's why I specifically commented on commit message: "There are two
> cases though that another path is taken on the code".
> 
> The code path reach bnx2x_chip_cleanup() on device removal from the system,
> as seen in the below call trace:
> 
> bnx2x_chip_cleanup+0x3c0/0x910 [bnx2x]
> bnx2x_nic_unload+0x268/0xaf0 [bnx2x]
> bnx2x_close+0x34/0x50 [bnx2x]
> __dev_close_many+0xd4/0x150
> dev_close_many+0xa8/0x160
> rollback_registered_many+0x174/0x3f0
> rollback_registered+0x40/0x70
> unregister_netdevice_queue+0x98/0x110
> unregister_netdev+0x34/0x50
> __bnx2x_remove+0xa8/0x3a0 [bnx2x]
> pci_device_remove+0x70/0x110

Makes sense.

> >> Also, we avoid the MCP information dump in case of non-recoverable
> >> PCI error (when adapter is about to be removed), since it will certainly fail.
> >
> > We should probably avoid several things here; Why specifically only this?
> 
> For example, we shouldn't execute bnx2x_timer() in this scenario. But I thought
> it'd be too much to check every call of a timer function against PCI channel state
> just to avoid it's execution on this scenario, so I just let it execute, since it seems
> harmless.
> 
> >> +	/* Reset the chip, unless PCI function is offline. If we reach this
> >> +	 * point following a PCI error handling, it means device is really
> >> +	 * in a bad state and we're about to remove it, so reset the chip
> >> +	 * is not a good idea.
> >> +	 */
> >> +	if (!pci_channel_offline(bp->pdev)) {
> >> +		rc = bnx2x_reset_hw(bp, reset_code);
> >> +		if (rc)
> >> +			BNX2X_ERR("HW_RESET failed\n");
> >> +	}
> >
> > Why not simply check this at the beginning of the function?
> 
> Because I wasn't sure if I could drop the entire execution of chip_cleanup(). I
> tried to keep the most of this function aiming to shutdown the module in a
> gentle way, like cleaning MAC, stopping queues...but again, I'm open to
> suggestions and gladly will change this in v2 if you think it's for the best.

Problem is I won't be able to have a more thorough review of this in the next
couple of days - and other than code-review I won't have a reasonable way
of testing this [I can use aer_inject, but I don't have your magical EEH
error injections, and I'm not at all certain it would suffice for a good testing ].

I agree that even as-is, what you're suggesting is an improvement to the
existing flow - so it's basically up to dave, i.e., whether to take a half fix
or wait for a more thorough one.
