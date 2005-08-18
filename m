From: Khalid Aziz <khalid_aziz@hp.com>
Subject: Re: [Fastboot] Re: Re: tg3: issue for reboot/kexec
Date: Thu, 18 Aug 2005 12:35:52 -0600
Message-ID: <1124390152.2274.14.camel@lyra.fc.hp.com>
References: <42BC9F09.1060002@us.ibm.com>
	<20050624174652.159f26ce.rdunlap@xenotime.net>
	<20050625033328.GC3934@kroah.com>
	<m18y0rl9bq.fsf@ebiederm.dsl.xmission.com>
	<20050630233354.GA22287@kroah.com>
	<m1vf3vjtbc.fsf@ebiederm.dsl.xmission.com>
	<1124389821.2274.11.camel@lyra.fc.hp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-hMrsjfyf9h+K9XfaaO3e"
Cc: linux-pm@lists.osdl.org, Fastboot mailing list <fastboot@lists.osdl.org>,
   netdev@vger.kernel.org
Return-path: <linux-pm-bounces@lists.osdl.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
In-Reply-To: <1124389821.2274.11.camel@lyra.fc.hp.com>
List-Unsubscribe: <https://lists.osdl.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/linux-pm>
List-Post: <mailto:linux-pm@lists.osdl.org>
List-Help: <mailto:linux-pm-request@lists.osdl.org?subject=help>
List-Subscribe: <https://lists.osdl.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.osdl.org?subject=subscribe>
Sender: linux-pm-bounces@lists.osdl.org
Errors-To: linux-pm-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org


--=-hMrsjfyf9h+K9XfaaO3e
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Thu, 2005-08-18 at 12:30 -0600, Khalid Aziz wrote:
> On Thu, 2005-06-30 at 17:52 -0600, Eric W. Biederman wrote:
> > Greg KH <greg@kroah.com> writes:
> > 
> > > On Thu, Jun 30, 2005 at 05:21:45PM -0600, Eric W. Biederman wrote:
> > >> However I have gotten feedback a couple of times that
> > >> driver writers tend to prefer using reboot notifiers.  In part
> > >> because shutdown functions don't exist for non-pci devices.
> > >
> > > That's a very lame excuse.  All busses should have shutdown functions.
> > > And any device that is just bypassing all of the existing bus logic is
> > > still tying into the driver core directly (which is a bad thing by
> > > itself, but that's a different matter.)  And there's a shutdown method
> > > there too.
> > >
> > > So there is no excuse to not use it.  Please, if they complain, point
> > > them to me :)
> > 
> > Ok.
> > 
> > Then there is still my complaint and device_shutdown doesn't get called
> > on module removal which means it really doesn't get implemented.  Perhaps
> > with kexec now being in the mainline kernel this will get better.
> > 
> > Currently I have the following patch outstanding against the e1000
> > driver because on reboot on some boxes it card revisions
> > it places the card into a sleep state the driver initialization 
> > routing cannot get the card out of.
> > 
> > And yes the e1000 is bad and is using a reboot_notifier.
> > 
> > Eric
> > 
> >  e1000_main.c |    2 +-
> >  1 files changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff -uNr linux-2.4.29-kexec-apic-virtwire-on-shutdownx86_64/drivers/net/e1000/e1000_main.c linux-2.4.29-e1000-no-poweroff-on-reboot/drivers/net/e1000/e1000_main.c
> > --- linux-2.4.29-kexec-apic-virtwire-on-shutdownx86_64/drivers/net/e1000/e1000_main.c   Tue Feb 15 14:17:09 2005
> > +++ linux-2.4.29-e1000-no-poweroff-on-reboot/drivers/net/e1000/e1000_main.c     Wed Feb 16 05:49:00 2005
> > @@ -2777,7 +2777,7 @@
> >         case SYS_POWER_OFF:
> >                 while((pdev = pci_find_device(PCI_ANY_ID, PCI_ANY_ID, pdev))) {
> >                         if(pci_dev_driver(pdev) == &e1000_driver)
> > -                               e1000_suspend(pdev, 3);
> > +                               e1000_suspend(pdev, (event == SYS_DOWN)?0:3);
> >                 }
> >         }
> >        return NOTIFY_DONE;
> 
> I have found that I can not walk reboot_notifier list in all cases
> before kexec'ing a new kernel. For instance, when handling INIT on ia64,
> we are running in interrupt context and atleast some of the reboot
> notifier callbacks call schedule(). Calling schedule() is not gonna work
> when we are running in interrupt context. I have the same concern for
> when panic gets called in interrupt context. So I added a shutdown
> function to e1000 driver instead. Patch is attached. This patch has
> worked for me.
> 
> As soon as I have all the issues sorted out with kexec'ing on INIT on
> ia64, I will post a fully updated kexec patch for ia64. I now have kexec
> working solid on INIT with e1000 driver and it can handle multiple back
> to back INITs and come up in kexec'd kernel every time. I am now trying
> to sort some issues out with tg3 driver (another driver with no shutdown
> routine :(
> 

Sorry, forgot to remove the last hunk that is already in 2.6.12. Updated
patch attached.

--
Khalid 

====================================================================
Khalid Aziz                       Open Source and Linux Organization
(970)898-9214                                        Hewlett-Packard
khalid.aziz@hp.com                                  Fort Collins, CO

"The Linux kernel is subject to relentless development" 
                                - Alessandro Rubini

--=-hMrsjfyf9h+K9XfaaO3e
Content-Disposition: attachment; filename=e1000_shutdown.patch
Content-Type: text/x-patch; name=e1000_shutdown.patch; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 7bit

diff -urNp hpte-2.6/drivers/net/e1000/e1000_main.c hpte-2.6.init/drivers/net/e1000/e1000_main.c
--- hpte-2.6/drivers/net/e1000/e1000_main.c	2005-07-08 13:57:55.000000000 -0600
+++ hpte-2.6.init/drivers/net/e1000/e1000_main.c	2005-07-21 09:42:17.000000000 -0600
@@ -211,6 +211,7 @@ static void e1000_restore_vlan(struct e1
 
 static int e1000_notify_reboot(struct notifier_block *, unsigned long event, void *ptr);
 static int e1000_suspend(struct pci_dev *pdev, uint32_t state);
+static void e1000_shutdown(struct device *dev);
 #ifdef CONFIG_PM
 static int e1000_resume(struct pci_dev *pdev);
 #endif
@@ -257,6 +258,8 @@ MODULE_PARM_DESC(debug, "Debug level (0=
  * loaded. All it does is register with the PCI subsystem.
  **/
 
+#define REBOOT_NOTIFIER	0
+
 static int __init
 e1000_init_module(void)
 {
@@ -266,10 +269,15 @@ e1000_init_module(void)
 
 	printk(KERN_INFO "%s\n", e1000_copyright);
 
+#if (!REBOOT_NOTIFIER)
+	e1000_driver.driver.shutdown = e1000_shutdown;
+#endif
 	ret = pci_module_init(&e1000_driver);
+#if REBOOT_NOTIFIER
 	if(ret >= 0) {
 		register_reboot_notifier(&e1000_notifier_reboot);
 	}
+#endif
 	return ret;
 }
 
@@ -285,7 +293,9 @@ module_init(e1000_init_module);
 static void __exit
 e1000_exit_module(void)
 {
+#if REBOOT_NOTIFIER
 	unregister_reboot_notifier(&e1000_notifier_reboot);
+#endif
 	pci_unregister_driver(&e1000_driver);
 }
 
@@ -3197,6 +3207,71 @@ e1000_suspend(struct pci_dev *pdev, uint
 	return 0;
 }
 
+static void
+e1000_shutdown(struct device *dev)
+{
+	struct pci_dev *pdev = to_pci_dev(dev);
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_hw *hw = &adapter->hw;
+	uint32_t ctrl;
+
+	netif_device_detach(netdev);
+
+	if(netif_running(netdev)) {
+		e1000_irq_disable(adapter);
+		del_timer(&adapter->tx_fifo_stall_timer);
+		del_timer(&adapter->watchdog_timer);
+		del_timer(&adapter->phy_info_timer);
+
+#ifdef CONFIG_E1000_NAPI
+		netif_poll_disable(netdev);
+#endif
+		adapter->link_speed = 0;
+		adapter->link_duplex = 0;
+		netif_carrier_off(netdev);
+		netif_stop_queue(netdev);
+	}
+
+	ctrl = E1000_READ_REG(hw, CTRL);
+
+	/* Must reset the PHY before resetting the MAC */
+	if((hw->mac_type == e1000_82541) || (hw->mac_type == e1000_82547)) {
+		E1000_WRITE_REG_IO(hw, CTRL, (ctrl | E1000_CTRL_PHY_RST));
+		mdelay(5);
+	}
+
+	/* Issue a global reset to the MAC.  This will reset the chip's
+	 * transmit, receive, DMA, and link units.  It will not effect
+	 * the current PCI configuration.  The global reset bit is self-
+	 * clearing, and should clear within a microsecond.
+	 */
+	switch(hw->mac_type) {
+	    case e1000_82544:
+	    case e1000_82540:
+	    case e1000_82545:
+	    case e1000_82546:
+	    case e1000_82541:
+	    case e1000_82541_rev_2:
+	        /* These controllers can't ack the 64-bit write when issuing the
+	         * reset, so use IO-mapping as a workaround to issue the reset 
+		 */
+	        E1000_WRITE_REG_IO(hw, CTRL, (ctrl | E1000_CTRL_RST));
+	        break;
+	    case e1000_82545_rev_3:
+	    case e1000_82546_rev_3:
+	        /* Reset is performed on a shadow of the control register */
+	        E1000_WRITE_REG(hw, CTRL_DUP, (ctrl | E1000_CTRL_RST));
+	        break;
+	    default:
+	        E1000_WRITE_REG(hw, CTRL, (ctrl | E1000_CTRL_RST));
+	        break;
+	}
+
+	pci_disable_device(pdev);
+	pci_set_power_state(pdev, 0);
+}
+
 #ifdef CONFIG_PM
 static int
 e1000_resume(struct pci_dev *pdev)

--=-hMrsjfyf9h+K9XfaaO3e
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline


--=-hMrsjfyf9h+K9XfaaO3e--
