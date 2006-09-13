From: Pradeep Dalvi <pradeep@netxen.com>
Subject: Re: [PATCH 2.6.17 0/9] NetXen: 1G/10G Ethernet Driver
Date: Wed, 13 Sep 2006 10:20:28 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0609131012140.28154@dut39>
References: <Pine.LNX.4.64.0608310543370.23783@dut39> <450560C0.8060602@garzik.org>
 <200609112004.50351.pradeep@linsyssoft.com> <4507715A.7090601@garzik.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: "Amit S. Kale" <amitkale@netxen.com>, netdev@vger.kernel.org,
	Sanjeev Jorapur <sanjeev@netxen.com>,
	Rob Mapes <rob@netxen.com>, unmproj@linsyssoft.com,
	Stephen Hemminger <shemminger@osdl.org>, brazilnut@us.ibm.com,
	wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:1360 "EHLO
	nxmail.netxen.com") by vger.kernel.org with ESMTP id S1750811AbWIMRUe
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Sep 2006 13:20:34 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <4507715A.7090601@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff,

Thanks for your comments.  We are incorporating these suggestions and will 
resubmit an updated driver asap.

--
pradeep

On Tue, 12 Sep 2006, Jeff Garzik wrote:

> More updates needed:
>
> 1) diff against 2.6.18-rcX (currently -rc6)
>
> 2) remove ifdefs around NETIF_F_TSO
>
> 3) remove ifdefs around CONFIG_PCI_MSI
>
> 4) during initial allocation of port struct, the following line is completely 
> superfluous:
>
> 	port->flags &= ~NETXEN_NETDEV_STATUS
>
> 5) netxen_nic_set_multi() does not have any multi-cast filter update code
>
> 6) remove impossible checks such as the following in nic_set_promise_mode:
>
> +       if ((phy < 0) || (phy > 3))
> +               return -1;
>
> 7) the following line in nic_set_mtu requires explanation, or fixing:
>
> +       case NETXEN_NIC_XGBE:
> +               new_mtu += 100; /* so that MAC accepts frames > MTU */
>
> 8) never call udelay() with a number >= 1000.  use mdelay()
>
> 9) [major] a great many functions simply do
>
> netxen_nic_do_blah()
>       case NETXEN_NIC_GBE:
> 		netxen_nic_do_blah_gbe()
> 		break;
>
>       case NETXEN_NIC_XGBE:
> 		netxen_nic_do_blah_xgbe()
> 		break;
>
> This is silly and makes the code needlessly larger and needlessly slower. 
> Modularize the driver to avoid all such functions.
>
> 10) don't cast iounmap argument to u8*
>
> 11) don't case to/from void*, particularly where you accidentally drop the 
> __iomem marker:
>
> +               addr = (void *)(adapter->ahw.pci_base + off);
>
> 12) make sure the driver passes sparse checks.  Read Documentation/sparse.txt
>
> 13) __iomem markers missing in NETXEN_NIC_HW_BLOCK_WRITE_64, 
> NETXEN_NIC_HW_BLOCK_READ_64
>
> 14) If you need a 'void __iomem *' cast in the following macros, there is a 
> type definition bug somewhere:
>
>
> +#define NETXEN_NIC_LOCKED_READ_REG(X, Y)                       \
> +       addr = (void __iomem *)(adapter->ahw.pci_base + X);     \
> +       *(u32 *)Y = readl(addr);
> +
> +#define NETXEN_NIC_LOCKED_WRITE_REG(X, Y)                      \
> +       addr = (void __iomem *)(adapter->ahw.pci_base + X);     \
> +       writel(*(u32 *)Y, addr);
> +
>
> 15) implement NETXEN_NIC_LOCKED_READ_REG, NETXEN_NIC_LOCKED_WRITE_REG, 
> NETXEN_NIC_HW_BLOCK_WRITE_64, NETXEN_NIC_HW_BLOCK_READ_64 as static inline 
> functions rather than macros for greater type safety
>
> 16) don't invent your own set_bit, clear_bit, etc:  _netxen_crb_set_bit
>
> 17) don't needlessly invent new types such as
> +typedef __le32 netxen_crbword_t;       /* single word in CRB space */
>
> 18) The strings in netxen_nic_gstrings_test[] should be easily 
> computer-parseable.  Eliminate parens, spaces
>
> 19) eliminate magic numbers (replace with named constants) in, e.g.
>
> +       if ((netxen_rom_fast_read(adapter, 0, &n) == 0) && (n & 0x80000000)) 
> {
> +               n &= ~0x80000000;
> +               if (n < 1024)
>
> 20) use the short driver name (commonly DRV_NAME constant in other drivers) 
> in ETHTOOL_GDRVINFO:
> +       strncpy(drvinfo->driver, "NetXen NIC Driver", 32);
>
> 21) export the real firmware version in ETHTOOL_GDRVINFO:
> +       strncpy(drvinfo->fw_version, NETXEN_NIC_FW_VERSIONID, 32);
>
> 22) netxen_nic_set_settings() simply returns success if the NIC is XGBE, 
> which is obviously wrong
>
> 23) bogus return value -1 in netxen_nic_get_eeprom()
>
> 24) -EOPNOTSUPP would seem to be a much better return value for XGBE in 
> netxen_nic_set_pauseparam()
>
> 25) netxen_nic_change_mtu() should check minimum MTU too
>
> 26) long delays should be sleeping, not spinning the CPU and locking out 
> other tasks:
>
> +       udelay(10000);
>
>
>
> I stopped reviewing here.  That should keep you busy...
>
> 	Jeff
>
>
>
>
>
