From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH 3/3] NetXen: Graceful teardown of interface and hardware upon module unload
Date: Sun, 1 Jul 2007 00:12:11 +0200
Message-ID: <200707010012.11527.mb@bu3sch.de>
References: <20070630203844.256007454@netxen.com> <20070630204424.876510236@netxen.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rob@netxen.com,
	Milan Bag <mbag@netxen.com>, Wen Xiong <wenxiong@us.ibm.com>
To: dhananjay.phadke@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:45124
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752773AbXF3WSP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jun 2007 18:18:15 -0400
In-Reply-To: <20070630204424.876510236@netxen.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 30 June 2007 22:38:47 dhananjay.phadke@gmail.com wrote:
> These changes allow driver close routine to be called during module unload,
> to clean-up buffers and other software resources, flush queues etc. Also,
> hardware is reset to pristine state. 
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
> Signed-off-by: Milan Bag <mbag@netxen.com>
> Signed-off-by: Wen Xiong <wenxiong@us.ibm.com>

>  		off = netxen_nic_pci_set_window(adapter, memaddr);
>  		addr = pci_base_offset(adapter, off);
>  		writel(data, addr);
> +		do {
> +			if (readl(addr) == data)
> +				break;
> +			msleep_interruptible(100);

If you use msleep_interruptible(), I'd say you should check for
the return value of that call and probably abort firmware
processing here if a signal interrupted us.

>  	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ADDRESS, addr);
>  	netxen_nic_reg_write(adapter, NETXEN_ROMUSB_ROM_ABYTE_CNT, 3);
> @@ -856,10 +853,10 @@ int netxen_pinit_from_rom(struct netxen_
>  				netxen_nic_pci_change_crbwindow(adapter, 1);
>  			}
>  			if (init_delay == 1) {
> -				ssleep(1);
> +				ssleep(2);

Is it possible/desired to do some interruptible sleep here?
Two seconds uninterruptible sleep is probably a long time.
Even at init/boot.

> Index: netdev-2.6/drivers/net/netxen/netxen_nic_main.c
> ===================================================================
> --- netdev-2.6.orig/drivers/net/netxen/netxen_nic_main.c
> +++ netdev-2.6/drivers/net/netxen/netxen_nic_main.c
> @@ -511,6 +511,8 @@ netxen_nic_probe(struct pci_dev *pdev, c
>  			val |= 0x4;
>  			netxen_nic_write_w0(adapter, NETXEN_PCIE_REG(0x4), val);
>  			netxen_nic_read_w0(adapter, NETXEN_PCIE_REG(0x4), &val);
> +			if (!(val & 0x4))
> +				printk(KERN_ERR "NetXen: bit set failed\n");

That's the award for the most useless error message. :P
Can you give the user a hint what this bit is about?

> +	if (adapter->portnum == 0) {
> +		if (init_firmware_done) {
> +			dma_watchdog_shutdown_request(adapter);
> +			msleep(100);
> +			i = 100;
> +			while ((dma_watchdog_shutdown_poll_result(adapter) != 1) && i) {
> +				printk(KERN_INFO "dma_watchdog_shutdown_poll still in progress\n");
> +				msleep(100);
> +				i--;
> +			}
> +
> +			if (i == 0) {
> +				printk(KERN_ERR "dma_watchdog_shutdown_request failed\n");
> +				return;
> +			}
> +
> +			/* clear the register for future unloads/loads */
> +			writel(0, NETXEN_CRB_NORMALIZE(adapter, NETXEN_CAM_RAM(0x1fc)));
> +			printk(KERN_INFO "State: 0x%0x\n",
> +				readl(NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE)));
> +
> +			/* leave the hw in the same state as reboot */
> +			writel(0, NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE));
> +			if (netxen_pinit_from_rom(adapter, 0))
> +				return;
> +			udelay(500);

I guess we can do msleep(1) here, too, instead of the huge delay,
although it's twice as long.
Though, I could live with a 500us delay, too, if that's desired.


The rest looks pretty good to me.

-- 
Greetings Michael.
