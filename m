From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net] bnx2x: don't reset chip on cleanup if PCI function is
 offline
Date: Tue, 9 Aug 2016 12:14:55 +0000
Message-ID: <CO2PR11MB0088856E58DAADE7064F28AF971C0@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1470687227-21024-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>
To: "Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0106.outbound.protection.outlook.com ([104.47.41.106]:63808
	"EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932398AbcHINuS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 09:50:18 -0400
In-Reply-To: <1470687227-21024-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> When PCI error is detected, in some architectures (like PowerPC) a slot reset is
> performed - the driver's error handlers are in charge of "disable"
> device before the reset, and re-enable it after a successful slot reset.
> 
> There are two cases though that another path is taken on the code: if the slot
> reset is not successful or if too many errors already happened in the specific
> adapter (meaning that possibly the device is experiencing a HW failure that slot
> reset is not able to solve), the core PCI error mechanism (called EEH in PowerPC)
> will remove the adapter from the system, since it will consider this as a
> permanent failure on device. 
Why would the published resume()  from pci_error_handlers be called in this scenario?

> Also, we avoid the MCP information dump in case of non-recoverable PCI error
> (when adapter is about to be removed), since it will certainly fail.

We should probably avoid several things here; Why specifically only this?
 
> +	if (unlikely(pci_channel_offline(bp->pdev))) {
> +		BNX2X_ERR("Cannot dump MCP info while in PCI error\n");
> +		return;
> +	}
> +
Nitpicky, but I don't think there's reason to add 'unlikely' to a purely slowpath
Configuration.

>  	val = REG_RD(bp, MCP_REG_MCPR_CPU_PROGRAM_COUNTER);
>  	if (val == REG_RD(bp, MCP_REG_MCPR_CPU_PROGRAM_COUNTER))
>  		BNX2X_ERR("%s" "MCP PC at 0x%x\n", lvl, val); @@ -9415,10
> +9420,16 @@ unload_error:


> -	/* Reset the chip */
> -	rc = bnx2x_reset_hw(bp, reset_code);
> -	if (rc)
> -		BNX2X_ERR("HW_RESET failed\n");
> +	/* Reset the chip, unless PCI function is offline. If we reach this
> +	 * point following a PCI error handling, it means device is really
> +	 * in a bad state and we're about to remove it, so reset the chip
> +	 * is not a good idea.
> +	 */
> +	if (!pci_channel_offline(bp->pdev)) {
> +		rc = bnx2x_reset_hw(bp, reset_code);
> +		if (rc)
> +			BNX2X_ERR("HW_RESET failed\n");
> +	}

Why not simply check this at the beginning of the function?
