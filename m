From: Andy Fleming <afleming@freescale.com>
Subject: schedule_work issues
Date: Fri, 27 Aug 2004 17:34:11 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <37CEBC36-F879-11D8-942E-000393C30512@freescale.com>
Mime-Version: 1.0 (Apple Message framework v618)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Previously I sent a message detailing how I could not get my ethernet 
driver to recognize a link if I used DHCP to configure for an NFS root. 
  However, now it seems the problem has spread since I updated to the 
newest version of the kernel.  With the previous version (2.6.8), 
everything worked.  With a version current as of yesterday, the driver 
fails to recognize a link.  This is what I get:

Serial: CPM driver $Revision: 0.01 $
ttyCPM0 at MMIO 0xfdfd1a00 (irq = 40) is a CPM UART
ttyCPM1 at MMIO 0xfdfd1a60 (irq = 43) is a CPM UART
RAMDISK driver initialized: 16 RAM disks of 32768K size 1024 blocksize
loop: loaded (max 8 devices)
eth0: Gianfar Ethernet Controller Version 1.1, 00:e0:0c:00:00:0d
eth0: Running with NAPI enabled
eth0: 256/256 RX/TX BD ring size
eth1: Gianfar Ethernet Controller Version 1.1, 00:e0:0c:00:01:0d
eth1: Running with NAPI enabled
eth1: 256/256 RX/TX BD ring size
e100: Intel(R) PRO/100 Network Driver, 3.0.27-k2-NAPI
e100: Copyright(c) 1999-2004 Intel Corporation
Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
ide: Assuming 50MHz system bus speed for PIO modes; override with 
idebus=xx
NET: Registered protocol family 2
IP: routing cache hash table of 4096 buckets, 32Kbytes
TCP: Hash tables configured (established 131072 bind 65536)
NET: Registered protocol family 1
NET: Registered protocol family 17
eth0: PHY is Marvell 88E1101 (1410c62)

It then sits there forever.  The debugger indicates it is receiving 
interrupts, and debug output proves my link interrupt is triggering, 
and a timer acts the same.  however, I both the timer and the interrupt 
call schedule_work() to accomplish the actual work of detecting the 
link state, and configuring the controller as necessary.  Debug output 
indicates that this function is never called.  Extensive debugging has 
shown that the kernel gets into try_to_wake_up(), and exits:

	old_state = p->state;
         if (!(old_state & state))
                 goto out;

old_state at this point is 0, and state is 3, with those two bits 
representing TASK_INTERRUPTIBLE and TASK_UNINTERRUPTIBLE.  I tried 
setting those bits in my driver, but that did not work.  At this point, 
I'm stuck.  My interrupt function is pretty simple:

static irqreturn_t phy_interrupt(int irq, void *dev_id, struct pt_regs 
*regs)
{
         struct net_device *dev = (struct net_device *) dev_id;
         struct gfar_private *priv = netdev_priv(dev);

         /* Clear the interrupt */
         mii_clear_phy_interrupt(priv->mii_info);

         /* Disable PHY interrupts */
         mii_configure_phy_interrupt(priv->mii_info,
                         MII_INTERRUPT_DISABLED);

         /* Schedule the phy change */
         schedule_work(&priv->tq);

         return IRQ_HANDLED;
}

I'm not sure this is the correct list, but I'm hoping this is a simple 
matter of my driver doing something wrong.  Any ideas?

Andy
