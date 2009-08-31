From: Tim Sander <tim01@vlsi.informatik.tu-darmstadt.de>
Subject: [PATCH] Re: Latest PreemptRT patch error on imx35
Date: Mon, 31 Aug 2009 18:37:27 +0200
Message-ID: <200908311837.28289.tim01@vlsi.informatik.tu-darmstadt.de>
References: <200908311143.08952.tim01@vlsi.informatik.tu-darmstadt.de> <20090831132200.GA21836@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-rt-users <linux-rt-users@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Greg Ungerer <gerg@uclinux.org>, netdev@vger.kernel.org
To: Uwe =?iso-8859-1?q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <linux-rt-users-owner@vger.kernel.org>
In-Reply-To: <20090831132200.GA21836@pengutronix.de>
Content-Disposition: inline
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Uwe
> The exact problem is:
>       fec_enet_mii (this takes &fep->mii_lock) and calls mip->mii_func
>       which happens to be mii_queue.  mii_queue in turn takes
>       &fep->mii_lock again.
Mh, lets see, i tried this:
--- linux-2.6.30/drivers/net/fec.orig.c 2009-08-31 18:01:25.000000000 +0200
+++ linux-2.6.30/drivers/net/fec.c      2009-08-31 18:06:31.000000000 +0200
@@ -622,8 +622,7 @@
                goto unlock;
        }

-       if (mip->mii_func != NULL)
-               (*(mip->mii_func))(readl(fep->hwp + FEC_MII_DATA), dev);
+       mii_queue_locked(readl(fep->hwp + FEC_MII_DATA), dev);

        mii_head = mip->mii_next;
        mip->mii_next = mii_free;
@@ -637,17 +636,9 @@
 }

 static int
-mii_queue(struct net_device *dev, int regval, void (*func)(uint, struct 
net_device *))
+mii_queue_locked(struct net_device *dev, int regval, void (*func)(uint, 
struct net_device *))
 {
-       struct fec_enet_private *fep;
-       unsigned long   flags;
-       mii_list_t      *mip;
        int             retval;
-
-       /* Add PHY address to register command */
-       fep = netdev_priv(dev);
-       spin_lock_irqsave(&fep->mii_lock, flags);
-
        regval |= fep->phy_addr << 23;
        retval = 0;

@@ -666,6 +657,22 @@
        } else {
                retval = 1;
        }
+       return retval;
+}
+
+static int
+mii_queue(struct net_device *dev, int regval, void (*func)(uint, struct 
net_device *))
+{
+       struct fec_enet_private *fep;
+       unsigned long   flags;
+       mii_list_t      *mip;
+       int             retval;
+
+       /* Add PHY address to register command */
+       fep = netdev_priv(dev);
+       spin_lock_irqsave(&fep->mii_lock, flags);
+
+       retval=mii_queue_locked(dev,regval,net_device);

        spin_unlock_irqrestore(&fep->mii_lock, flags);
        return retval;

---
But it still gives me:
FEC Ethernet Driver
kernel BUG at kernel/rtmutex.c:807!
Unable to handle kernel NULL pointer dereference at virtual address 00000000
pgd = c0004000
[00000000] *pgd=00000000
Internal error: Oops: 805 [#1] PREEMPT
Modules linked in:
CPU: 0    Not tainted  (2.6.31-rc8-rt9 #1)
PC is at __bug+0x1c/0x28
LR is at __bug+0x18/0x28
pc : [<c0024184>]    lr : [<c0024180>]    psr: 00000193
sp : c7891ef0  ip : c7891e30  fp : 00000002
r10: c7911c24  r9 : c031f9cc  r8 : c0351e54
r7 : 40000113  r6 : c0195c74  r5 : c7890000  r4 : 600e0000
r3 : 00000000  r2 : 00000001  r1 : c7890000  r0 : 0000002a
Flags: nzcv  IRQs off  FIQs on  Mode SVC_32  ISA ARM  Segment kernel
Control: 00c5387d  Table: 80004008  DAC: 00000017
Process irq/57-fec (pid: 243, stack limit = 0xc7890268)
Stack: (0xc7891ef0 to 0xc7892000)
1ee0:                                     c025fb3c c025fd38 00000000 40000113
1f00: ffffffff c7891f10 c025fcd8 c0032124 00000000 c7891f20 c0031764 c781e01c
1f20: c78ffb40 00000017 00000000 c7819b20 c7891f74 600e0000 c7911800 c0195c74
1f40: c7911c24 c0351e54 c031f9cc c0351e58 00000002 c0195dfc c0351d64 c7911b20
1f60: c7911800 c7911c24 c0351e54 c0196794 c025ee80 c031f9c4 c79885a0 c7890000
1f80: c031f988 c79885c8 c031f9e4 c0062950 00000000 00000032 c7891fbc c781fe4c
1fa0: c79885a0 c006281c 00000000 00000000 00000000 00000000 00000000 c004c5e8
1fc0: 00000000 00000000 c7891fc8 c7891fc8 c7891fd0 c7891fd0 00000000 00000000
1fe0: c7891fe0 c7891fe0 00000000 00000000 00000000 c00218b4 ffebfef3 ddddebfd
[<c0024184>] (__bug+0x1c/0x28) from [<c025fd38>] 
(rt_spin_lock_slowlock+0x220/0x234)
[<c025fd38>] (rt_spin_lock_slowlock+0x220/0x234) from [<c0195dfc>] 
(mii_queue+0x20/0xb4)
[<c0195dfc>] (mii_queue+0x20/0xb4) from [<c0196794>] 
(fec_enet_interrupt+0x84/0x104)
[<c0196794>] (fec_enet_interrupt+0x84/0x104) from [<c0062950>] 
(irq_thread+0x134/0x1c0)
[<c0062950>] (irq_thread+0x134/0x1c0) from [<c004c5e8>] (kthread+0x7c/0x84)
[<c004c5e8>] (kthread+0x7c/0x84) from [<c00218b4>] 
(kernel_thread_exit+0x0/0x8)
Code: e1a01000 e59f000c eb08e8b0 e3a03000 (e5833000)
---[ end trace 25de9c8d632021f6 ]---
exiting task "irq/57-fec" (243) is an active IRQ thread (irq 57)

Best regards
Tim
