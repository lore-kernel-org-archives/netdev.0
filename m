From: <jie.yang@atheros.com>
Subject: [PATCH]atl1e:fix bug [Bug 11454] New: atl1e - BUG: scheduling while atomic: modprobe/678/0x00000002
Date: Sun, 31 Aug 2008 12:51:58 +0800
Message-ID: <12201583182726-git-send-email-jie.yang@atheros.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <bugme-daemon@bugzilla.kernel.org>, <harn-solo@gmx.de>,
	<jeff@garzik.org>, <matthew@wil.cx>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, Jie Yang <jie.yang@atheros.com>
To: <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.atheros.com ([12.36.123.2]:39473 "EHLO mail.atheros.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750796AbYHaEv7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Aug 2008 00:51:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

from Jie Yang <jie.yang@atheros.com>

 On Saturday, August 30, 2008 5:27 AM
 Andrew Morton <akpm@linux-foundation.org]>
> On Fri, 29 Aug 2008 14:08:09 -0700 (PDT) 
> bugme-daemon@bugzilla.kernel.org wrote:
> 
> > http://bugzilla.kernel.org/show_bug.cgi?id=11454
> >
> >            Summary: atl1e - BUG: scheduling while atomic:
> >                     modprobe/678/0x00000002
> >            Product: Drivers
> >            Version: 2.5
> >      KernelVersion: 2.6.27-rc5
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: high
> >           Priority: P1
> >          Component: Network
> >         AssignedTo: jgarzik@pobox.com
> >         ReportedBy: harn-solo@gmx.de
> >
> >
> > Latest working kernel version: -
> > Earliest failing kernel version: 2.6.27-rc1
> > Software: x86_64
> >
> 
> drivers/net/atl1e/atl1e_hw.c:   struct atl1e_adapter *adapter 
> = (struct atl1e_adapter *)hw->adapter;
> drivers/net/atl1e/atl1e_hw.c:   struct atl1e_adapter *adapter 
> = (struct atl1e_adapter *)hw->adapter;
> drivers/net/atl1e/atl1e_hw.c:   struct atl1e_adapter *adapter 
> = (struct atl1e_adapter *)hw->adapter;
> 
> are unneeded and undesirable.  hw->adapter already has type 
> atl1e_adapter*.
> 

just as Matthew Wilcox <matthew@wil.cx> mentioned:
> Lockdep warns about the mdio_lock taken with interrupts enabled then 
> later taken from interrupt context.  Initially, I considered changing 
> these to spin_lock_irq/spin_unlock_irq, but then I looked at 
> atl1e_phy_init() and saw that it calls msleep().  Sleeping while 
> holding a spinlock is not allowed either.
> 
> In the probe path, we haven't registered the interrupt handler, so it 
> can't poke at this card yet.  It's before we call register_netdev(), 
> so I don't think any other threads can reach this card either.  If I'm 
> right, we don't need a spinlock at all.

So, just do not take mdio_lock lock in atl1e_probe, and remove the
unneeded (struct atl1e_adapter *)

Signed-off-by: Jie Yang <jie.yang@atheros.com>
---

BTW: I do not know if this format is suitable for repling [Bugme-new],
if it is not suitable, just let me know.

diff --git a/drivers/net/atl1e/atl1e_hw.c b/drivers/net/atl1e/atl1e_hw.c
index 949e753..8cbc1b5 100644
--- a/drivers/net/atl1e/atl1e_hw.c
+++ b/drivers/net/atl1e/atl1e_hw.c
@@ -397,7 +397,7 @@ static int atl1e_phy_setup_autoneg_adv(struct atl1e_hw *hw)
  */
 int atl1e_phy_commit(struct atl1e_hw *hw)
 {
-       struct atl1e_adapter *adapter = (struct atl1e_adapter *)hw->adapter;
+       struct atl1e_adapter *adapter = hw->adapter;
        struct pci_dev *pdev = adapter->pdev;
        int ret_val;
        u16 phy_data;
@@ -431,7 +431,7 @@ int atl1e_phy_commit(struct atl1e_hw *hw)

 int atl1e_phy_init(struct atl1e_hw *hw)
 {
-       struct atl1e_adapter *adapter = (struct atl1e_adapter *)hw->adapter;
+       struct atl1e_adapter *adapter = hw->adapter;
        struct pci_dev *pdev = adapter->pdev;
        s32 ret_val;
        u16 phy_val;
@@ -525,7 +525,7 @@ int atl1e_phy_init(struct atl1e_hw *hw)
  */
 int atl1e_reset_hw(struct atl1e_hw *hw)
 {
-       struct atl1e_adapter *adapter = (struct atl1e_adapter *)hw->adapter;
+       struct atl1e_adapter *adapter = hw->adapter;
        struct pci_dev *pdev = adapter->pdev;

        u32 idle_status_data = 0;
diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e_main.c
index 7685b99..9b60352 100644
--- a/drivers/net/atl1e/atl1e_main.c
+++ b/drivers/net/atl1e/atl1e_main.c
@@ -2390,9 +2390,7 @@ static int __devinit atl1e_probe(struct pci_dev *pdev,
        }

        /* Init GPHY as early as possible due to power saving issue  */
-       spin_lock(&adapter->mdio_lock);
        atl1e_phy_init(&adapter->hw);
-       spin_unlock(&adapter->mdio_lock);
        /* reset the controller to
         * put the device in a known good starting state */
        err = atl1e_reset_hw(&adapter->hw);

