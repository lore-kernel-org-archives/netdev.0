From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 2.6.25] add bnx2x driver for BCM57710 - bnx2x.c
Date: Thu, 15 Nov 2007 15:03:49 -0800
Message-ID: <20071115150349.51e6d133@freepuppy.rosehill>
References: <1195154386.24548.29.camel@lb-tlvb-eliezer.il.broadcom.com>
	<1195155983.24548.35.camel@lb-tlvb-eliezer.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jeff@garzik.org,
	"masbock" <masbock@us.ibm.com>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>,
	"Ram Pai" <linuxram@us.ibm.com>,
	"Philip Oswald" <poswald@novell.com>
To: "Eliezer Tamir" <eliezert@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:43147 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755111AbXKOXGD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 18:06:03 -0500
In-Reply-To: <1195155983.24548.35.camel@lb-tlvb-eliezer.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

1. Please use dev_err() to help user figure out which board has problem:
Not:
		printk(KERN_ERR PFX "Cannot register net device\n");
Instead:
		dev_err(&pdev->dev, "cannot register net device\n");


2. Use new MAC_ADDR() rather than
	printk("node addr ");
	for (i = 0; i < 6; i++)
		printk("%2.2x", dev->dev_addr[i]);
	printk("\n");

3. The reset task logic needs more cleanup/protection.
Don't you want to cancel it on remove, and bp->in_reset_task is
not sufficient protection on SMP??
Could you not flush_scheduled_work(), instead use cancel_delayed_work_sync()?

4. Rather than hard coding mac address, could you use random_ether_address()
instead?

5. Current style police will complain about single line {}
	if (bp->phy_flags & PHY_XGXS_FLAG) {
		cmd->port = PORT_FIBRE;
	} else {
		cmd->port = PORT_TP;
	}
instead:
	if (bp->phy_flags & PHY_XGXS_FLAG)
		cmd->port = PORT_FIBRE;
	else
		cmd->port = PORT_TP;

6. The driver is using per-cpu tx queue, maybe it wants to have multi
queue instead?

7. bnx2x_get_stats() is uneeded. If you leave dev->get_stats() set to NULL
then register_netdev will handle it.


8. Spelling fixes:

>  *
>  * Written by: Eliezer Tamir <eliezert@broadcom.com>
>  * Based on code from Michael Chan's bnx2 driver
>  * UDP CSUM errata workaround by Arik Gendelman
>  * Slowpath rework by Vladislav Zolotarov
>  * Statistics and Link managment by Yitchak Gertner

spelling fix: s/managment/management/


...
>MODULE_PARM_DESC(nomcp, "ignore managment CPU (Implies onefunc)");
management

>MODULE_PARM_DESC(debug, "defualt debug msglevel");
default

> /* indexed by board_t, above */
> static const struct {
> 	char *name;
> } board_info[] __devinitdata = {
> 	{ "Broadcom NetXtreme II BCM57710 XGb" }
> };

why not just 

static const char *board_info[] = {
	"NetXtreme II BCM57710 XGb",
};

> static const struct pci_device_id bnx2x_pci_tbl[] = {
> 	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_NX2_57710,
> 		PCI_ANY_ID, PCI_ANY_ID, 0, 0, BCM57710 },
> 	{ 0 }
> };
> 

> 	/* reolve from gp_status in case of AN complete and not sgmii */
resolve??


> 	DP(NETIF_MSG_LINK, "enableing BigMAC\n");
enabling


