From: Tony Prisk <linux@prisktech.co.nz>
Subject: VIA velocity network driver
Date: Sat, 27 Apr 2013 17:30:15 +1200
Message-ID: <517B6267.4070404@prisktech.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Francois Romieu <romieu@fr.zoreil.com>,
	"Mailing List, Arm" <linux-arm-kernel@lists.infradead.org>,
	netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I would like to add support to this driver for platform devices as found 
on VIA's APC8750 board. At the moment, I have a standalone platform 
version that works fine, but wanted to ask a few questions before 
sending a patch to merge this code into one driver.

The current driver is for PCI network cards, and uses pci dma functions. 
Most of the pci dma functions are wrappers around other functions which 
is what I have used for the platform version. For example:

rd_info->skb_dma = pci_map_single(vptr->pdev, rd_info->skb->data,
                     vptr->rx.buf_sz, PCI_DMA_FROMDEVICE);

is replaced with:
rd_info->skb_dma = dma_map_single(&vptr->plat_dev->dev, rd_info->skb->data,
                     vptr->rx.buf_sz, DMA_FROM_DEVICE);

Is it ok to use the non-pci versions (which are basically just the 
unwrapped pci versions) and pass the struct device *, or will I need to 
use the correct function for the correct instance.

Other than adding some new probe/remove functions, this is all that is 
needed to add platform driver support.

One bug/problem that arose is to do with the EEPROM code in 
velocity_init_registers(), in the case for VELOCITY_INIT_COLD:

         mac_eeprom_reload(regs);
         for (i = 0; i < 6; i++)
             writeb(vptr->dev->dev_addr[i], &(regs->PAR[i]));

I assume this is loading something from an EEPROM, but there is no 
EEPROM on the APC8750. Removing this code, the driver seems to work fine 
on the APC8750.
Could it be avoided with a vptr->has_no_eeprom that defaults to 0 to 
avoid breaking existing support?

Regards
Tony Prisk
