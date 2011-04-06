From: ANDY KENNEDY <ANDY.KENNEDY@adtran.com>
Subject: mdiobus_register() issue for an SMSC8720a PHY
Date: Wed, 6 Apr 2011 13:22:38 -0500
Message-ID: <9AC3F0E75060224C8BBC5BA2DDC8853A1FA0C0C6@EXV1.corp.adtran.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p02c12o147.mxlogic.net ([208.65.145.80]:47878 "EHLO
	p02c12o147.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756213Ab1DFSbB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 14:31:01 -0400
Content-Class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm attempting to bring up an SMSC8720a off of a *freaky* MDIO bus.
Attempting to register my bus has failed.  The following is the oops I
get (with prink modifications by me) when attempting to register:

Adding MDIO bus device for eth0
Last one before. . .
###############################################################3
mdiobus_register:92
###############################################################3
mdiobus_register:98
###############################################################3
mdiobus_register:102
###############################################################3
mdiobus_register:106
###############################################################3
mdiobus_register:109
========================================================================
======  device_add:989
========================================================================
======  device_add:991
setup_parent is being called with dev = 0x8781da40, parent = 0x00000000
========================================================================
======  get_device_parent:663
========================================================================
======  get_device_parent:670
========================================================================
======  get_device_parent:683
========================================================================
======  get_device_parent:685
========================================================================
======  get_device_parent:689
dev = 0x8781da40
dev->class = 0x803c2ad4
dev->class->p = 0x00000000
dev->class->p->class_dirs = 0x00000048
CPU 0 Unable to handle kernel paging request at virtual address
00000048, epc == 8027c424, ra == 8027c41c
Oops[#1]:
Cpu 0
$ 0   : 00000000 00000000 00000000 00000002
$ 4   : 00000001 00000003 ffffffff 00000001
$ 8   : 804d9c8f 00000002 00000001 8036fde0
$12   : 3d3d3d3d 00000000 00000000 3d3d3d3d
$16   : 804e0000 8781da40 878046c0 00000000
$20   : 8781da04 8781da40 804e0000 00000000
$24   : 00000010 00000000
$28   : 87820000 87821de0 00000000 8027c41c
Hi    : 00000000
Lo    : 00000015
epc   : 8027c424 0x8027c424
    Not tainted
ra    : 8027c41c 0x8027c41c
Status: 11008403    KERNEL EXL IE
Cause : 00800008
BadVA : 00000048
PrId  : 0a019554 (MIPS 34Kc)
Modules linked in:
Process swapper (pid: 1, threadinfo=87820000, task=87818000,
tls=00000000)
Stack : ffffffea 00000048 ffffffff 00000001 8781da40 00000000 80390000
8027d060
        80390000 8781da40 00000000 00000001 00000000 00000000 00000000
80105150
        8781da40 8781da00 80370000 80390000 ffffffea 8781da04 8781da40
802a699c
        00000000 80375930 0000006d 00000000 8781da00 803cbc70 00000000
00000000
        00000000 00000000 00000000 00000000 00000000 803cbc58 00000000
00000000
        ...
Call Trace:[<8027d060>] 0x8027d060
[<80105150>] 0x80105150
[<802a699c>] 0x802a699c
[<803cbc70>] 0x803cbc70
[<803cbc58>] 0x803cbc58
[<803cbca8>] 0x803cbca8
[<80107db0>] 0x80107db0
[<801d1250>] 0x801d1250
[<8015bed0>] 0x8015bed0
[<803c89dc>] 0x803c89dc
[<80109180>] 0x80109180
[<803c8914>] 0x803c8914
[<80109170>] 0x80109170


Code: 24a50048  8e220094  8c420038 <8c440048> 24420048  0809f114
2484fffc  8c85000c  54b20005
Disabling lock debugging due to kernel taint
note: swapper[1] exited with preempt_count 1
Kernel panic - not syncing: Attempted to kill init!
Rebooting in 5 seconds..

The three lines showing the NULL pointer dereference are made with the
following code added to get_device_parent():
printk("dev = 0x%08x\n", (uint32_t)dev);
printk("dev->class = 0x%08x\n", (uint32_t)dev->class);
printk("dev->class->p = 0x%08x\n", (uint32_t)dev->class->p);
printk("dev->class->p->class_dirs = 0x%08x\n",
(uint32_t)&dev->class->p->class_dirs); }
                list_for_each_entry(k, &dev->class->p->class_dirs.list,
entry)
                        if (k->parent == parent_kobj) {
                                kobj = kobject_get(k);
                                break;
                        }

The code that attempts to register my MDIO bus is as follows:

static struct platform_device *pdev;
void __init mgt_eth_mdio_init(void)
{
        struct mii_bus *mgt_mdio = mdiobus_alloc();
        if (!mgt_mdio){
                printk(KERN_EMERG "Cannot get memory for mgt_mdio\n");
                return;
        }
        pdev = platform_device_register_simple("HOST ETH MDIO bus", 0,
NULL, 0);
        if (IS_ERR(pdev)) {
                printk(KERN_EMERG "Cannot create platform device for
MDIO Parent.\n");
                return ;
        }

        iowrite32(0x13, MAP_ETH_MCFG);
        mgt_mdio->name = "MGT_ETH_MDIO";
        mgt_mdio->id[0] = '0';
        mgt_mdio->read = mgt_eth_mdio_read;
        mgt_mdio->write = mgt_eth_mdio_write;
        mgt_mdio->irq = kzalloc(PHY_MAX_ADDR * sizeof(*mgt_mdio->irq),
                                GFP_KERNEL);
        mgt_mdio->irq[0] = MGT_ETH_IRQ;
        mgt_mdio->parent = &pdev->dev;
        mgt_mdio->phy_mask = 0xfffffffe;  //mask all but 0, it is the
only one.
        // Last but not least, setup memory for the phy_map.
        mgt_mdio->phy_map[0] = phy_device_create(mgt_mdio, 0, 0);
        dev_set_drvdata(&pdev->dev, mgt_mdio);
printk("Last one before. . . \n");
        // Shortly after this line, the system prints the Oops above
        mdiobus_register(mgt_mdio);
printk("Probably don't see this.\n");
}

What am I doing wrong?  Also, why do I get the message "Disabling lock
debugging due to kernel taint" when above it the kernel reports "Not
tainted"?

Andy Fleming suggested that I was not initializing my platform_device
correctly, so I, based upon his suggestion, added the dev_set_drvdata()
line.  This made no effect.

If you see something I'm doing wrong, please advise.


Andy Kennedy
