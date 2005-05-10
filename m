From: Horms <horms@verge.net.au>
Subject: Re: Small 2.6.11.8 airo.c issue
Date: Tue, 10 May 2005 19:44:37 +0900
Message-ID: <20050510104437.GB27913@verge.net.au>
References: <427C3FBD.mailOLE1FRMAW@hongkong>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Ross Combs <rocombs@cs.nmsu.edu>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <427C3FBD.mailOLE1FRMAW@hongkong>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, May 06, 2005 at 11:10:37PM -0500, Ross Combs wrote:
> I ran into a small configuration problem a couple of days ago while
> using menuconfig to setup a new kernel for my laptop.  Basically,
> it refused to show the airo.c driver as an option.  After looking
> at the Kconfig files I figured out it was because I did not have ISA
> enabled -- but I'm not using an ISA version of the card so it should
> not be a dependency.
> 
> I originally reported it to Jean Tourrilhes but he said that netdev
> would be a better place to send it and that Javier might know why it
> was added.  My original message is included below.
> 
> 
> > I just upgraded my system to a recent 2.6 kernel and noticed a small
> > bug in the configuration for the airo.c driver.  It now requires
> > that ISA be enabled, though it is not a requirement for all hardware
> > using that driver.  In my case, I'm using an IBM T30 laptop with a
> > mini-PCI card.
> >
> > Once I edited the Kconfig file to remove the ISA dependency (maybe it
> > should be an OR instead of an AND but removing it was easier for a
> > local change), I was able to select the driver.  It compiled without
> > problems and I'm using it successfully with encryption for the first
> > time ever.
> >
> > I'm very happy with the new driver.
> >
> > Please let me know if this is not the right place to report bugs.  I
> > just mailed the people listed in the source code.
> 
> Thanks,
> -Ross

This patch might help your cause. Though I note that
airo is marked as broken unless pci is enabled, makes
me wonder if isa cards work at all.

-- 
Horms

drivers/net/wireless/Kconfig: needs update
drivers/net/wireless/airo.c: needs update
Index: drivers/net/wireless/Kconfig
===================================================================
--- eed337ef5e9ae7d62caa84b7974a11fddc7f06e0/drivers/net/wireless/Kconfig  (mode:100644)
+++ uncommitted/drivers/net/wireless/Kconfig  (mode:100644)
@@ -139,7 +139,7 @@
 
 config AIRO
 	tristate "Cisco/Aironet 34X/35X/4500/4800 ISA and PCI cards"
-	depends on NET_RADIO && ISA && (PCI || BROKEN)
+	depends on NET_RADIO && (PCI || BROKEN)
 	---help---
 	  This is the standard Linux driver to support Cisco/Aironet ISA and
 	  PCI 802.11 wireless cards.
Index: drivers/net/wireless/airo.c
===================================================================
--- eed337ef5e9ae7d62caa84b7974a11fddc7f06e0/drivers/net/wireless/airo.c  (mode:100644)
+++ uncommitted/drivers/net/wireless/airo.c  (mode:100644)
@@ -217,8 +217,10 @@
 static int basic_rate;
 static char *ssids[3];
 
+#ifdef CONFIG_ISA
 static int io[4];
 static int irq[4];
+#endif
 
 static
 int maxencrypt /* = 0 */; /* The highest rate that the card can encrypt at.
@@ -245,8 +247,10 @@
 		   for PCMCIA when used with airo_cs.");
 MODULE_LICENSE("Dual BSD/GPL");
 MODULE_SUPPORTED_DEVICE("Aironet 4500, 4800 and Cisco 340/350");
+#ifdef CONFIG_ISA
 module_param_array(io, int, NULL, 0);
 module_param_array(irq, int, NULL, 0);
+#endif
 module_param(basic_rate, int, 0);
 module_param_array(rates, int, NULL, 0);
 module_param_array(ssids, charp, NULL, 0);
@@ -5542,7 +5546,10 @@
 
 static int __init airo_init_module( void )
 {
-	int i, have_isa_dev = 0;
+	int i;
+#ifdef CONFIG_ISA
+	int have_isa_dev = 0;
+#endif
 
 	airo_entry = create_proc_entry("aironet",
 				       S_IFDIR | airo_perm,
@@ -5550,6 +5557,7 @@
         airo_entry->uid = proc_uid;
         airo_entry->gid = proc_gid;
 
+#ifdef CONFIG_ISA
 	for( i = 0; i < 4 && io[i] && irq[i]; i++ ) {
 		printk( KERN_INFO
 			"airo:  Trying to configure ISA adapter at irq=%d io=0x%x\n",
@@ -5557,6 +5565,7 @@
 		if (init_airo_card( irq[i], io[i], 0, NULL ))
 			have_isa_dev = 1;
 	}
+#endif
 
 #ifdef CONFIG_PCI
 	printk( KERN_INFO "airo:  Probing for PCI adapters\n" );
