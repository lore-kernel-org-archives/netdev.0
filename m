From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [usb regression] Re: [PATCH 2.6.24-rc3] Fix /proc/net breakage
Date: Sun, 30 Dec 2007 15:34:45 -0500 (EST)
Message-ID: <Pine.LNX.4.44L0.0712301526090.1963-100000@netrider.rowland.org>
References: <20071230161405.GA27788@elte.hu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ingo Molnar <mingo@elte.hu>, Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Woodhouse <dwmw2@infradead.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Pavel Machek <pavel@ucw.cz>,
	kernel list <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Pavel Emelyanov <xemul@openvz.org>,
	"Denis V. Lunev" <den@openvz.org>, Greg KH <greg@kroah.com>
To: Andreas Mohr <andi@lisas.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756897AbXL3Ue6@vger.kernel.org>
In-Reply-To: <20071230161405.GA27788@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 30 Dec 2007, Ingo Molnar wrote:

> * Andreas Mohr <andi@lisas.de> wrote:
> 
> > (yes, that's all there is, despite CONFIG_USB_DEBUG being set)
> > 
> > The LED of a usb stick isn't active either, for obvious reasons.
> > 
> > And keep in mind that this is a (relatively old) OHCI-only machine... 
> > (which had the 2.6.19 lsmod showing ohci-hcd just fine and working 
> > fine with WLAN USB)
> > 
> > Now pondering whether to try -rc6 proper or whether to revert specific 
> > guilty-looking USB changes... And wondering how to properly elevate 
> > this issue (prompt Greg about it, new thread, bug #, ...?)

It looks like Greg misused the debugfs API -- which is ironic, because
he wrote debugfs in the first place!  :-)

Let me know if this patch fixes the problem.  If it does, I'll submit 
it to Greg with all the proper accoutrements.

Alan Stern


Index: 2.6.24-rc6-mm1/drivers/usb/host/ohci-hcd.c
===================================================================
--- 2.6.24-rc6-mm1.orig/drivers/usb/host/ohci-hcd.c
+++ 2.6.24-rc6-mm1/drivers/usb/host/ohci-hcd.c
@@ -1067,14 +1067,8 @@ static int __init ohci_hcd_mod_init(void
 
 #ifdef DEBUG
 	ohci_debug_root = debugfs_create_dir("ohci", NULL);
-	if (!ohci_debug_root || IS_ERR(ohci_debug_root)) {
-		if (!ohci_debug_root)
-			retval = -ENOENT;
-		else
-			retval = PTR_ERR(ohci_debug_root);
-
-		goto error_debug;
-	}
+	if (!ohci_debug_root)
+		return -ENOENT;
 #endif
 
 #ifdef PS3_SYSTEM_BUS_DRIVER
@@ -1142,7 +1136,6 @@ static int __init ohci_hcd_mod_init(void
 #ifdef DEBUG
 	debugfs_remove(ohci_debug_root);
 	ohci_debug_root = NULL;
- error_debug:
 #endif
 
 	return retval;
Index: 2.6.24-rc6-mm1/drivers/usb/host/ohci-dbg.c
===================================================================
--- 2.6.24-rc6-mm1.orig/drivers/usb/host/ohci-dbg.c
+++ 2.6.24-rc6-mm1/drivers/usb/host/ohci-dbg.c
@@ -813,30 +813,29 @@ static inline void create_debug_files (s
 	struct device *dev = bus->dev;
 
 	ohci->debug_dir = debugfs_create_dir(bus->bus_name, ohci_debug_root);
-	if (!ohci->debug_dir || IS_ERR(ohci->debug_dir)) {
-		ohci->debug_dir = NULL;
-		goto done;
-	}
+	if (!ohci->debug_dir)
+		return;
 
 	ohci->debug_async = debugfs_create_file("async", S_IRUGO,
 						ohci->debug_dir, dev,
 						&debug_async_fops);
-	if (!ohci->debug_async || IS_ERR(ohci->debug_async))
+	if (!ohci->debug_async)
 		goto async_error;
 
 	ohci->debug_periodic = debugfs_create_file("periodic", S_IRUGO,
 						   ohci->debug_dir, dev,
 						   &debug_periodic_fops);
-	if (!ohci->debug_periodic || IS_ERR(ohci->debug_periodic))
+	if (!ohci->debug_periodic)
 		goto periodic_error;
 
 	ohci->debug_registers = debugfs_create_file("registers", S_IRUGO,
 						    ohci->debug_dir, dev,
 						    &debug_registers_fops);
-	if (!ohci->debug_registers || IS_ERR(ohci->debug_registers))
+	if (!ohci->debug_registers)
 		goto registers_error;
 
-	goto done;
+	ohci_dbg(ohci, "created debug files\n");
+	return;
 
 registers_error:
 	debugfs_remove(ohci->debug_periodic);
@@ -847,10 +846,6 @@ periodic_error:
 async_error:
 	debugfs_remove(ohci->debug_dir);
 	ohci->debug_dir = NULL;
-done:
-	return;
-
-	ohci_dbg (ohci, "created debug files\n");
 }
 
 static inline void remove_debug_files (struct ohci_hcd *ohci)
Index: 2.6.24-rc6-mm1/drivers/usb/host/ehci-hcd.c
===================================================================
--- 2.6.24-rc6-mm1.orig/drivers/usb/host/ehci-hcd.c
+++ 2.6.24-rc6-mm1/drivers/usb/host/ehci-hcd.c
@@ -1019,14 +1019,8 @@ static int __init ehci_hcd_init(void)
 
 #ifdef DEBUG
 	ehci_debug_root = debugfs_create_dir("ehci", NULL);
-	if (!ehci_debug_root || IS_ERR(ehci_debug_root)) {
-		if (!ehci_debug_root)
-			retval = -ENOENT;
-		else
-			retval = PTR_ERR(ehci_debug_root);
-
-		return retval;
-	}
+	if (!ehci_debug_root)
+		return -ENOENT;
 #endif
 
 #ifdef PLATFORM_DRIVER
Index: 2.6.24-rc6-mm1/drivers/usb/host/ehci-dbg.c
===================================================================
--- 2.6.24-rc6-mm1.orig/drivers/usb/host/ehci-dbg.c
+++ 2.6.24-rc6-mm1/drivers/usb/host/ehci-dbg.c
@@ -914,30 +914,28 @@ static inline void create_debug_files (s
 	struct usb_bus *bus = &ehci_to_hcd(ehci)->self;
 
 	ehci->debug_dir = debugfs_create_dir(bus->bus_name, ehci_debug_root);
-	if (!ehci->debug_dir || IS_ERR(ehci->debug_dir)) {
-		ehci->debug_dir = NULL;
-		goto done;
-	}
+	if (!ehci->debug_dir)
+		return;
 
 	ehci->debug_async = debugfs_create_file("async", S_IRUGO,
 						ehci->debug_dir, bus,
 						&debug_async_fops);
-	if (!ehci->debug_async || IS_ERR(ehci->debug_async))
+	if (!ehci->debug_async)
 		goto async_error;
 
 	ehci->debug_periodic = debugfs_create_file("periodic", S_IRUGO,
 						   ehci->debug_dir, bus,
 						   &debug_periodic_fops);
-	if (!ehci->debug_periodic || IS_ERR(ehci->debug_periodic))
+	if (!ehci->debug_periodic)
 		goto periodic_error;
 
 	ehci->debug_registers = debugfs_create_file("registers", S_IRUGO,
 						    ehci->debug_dir, bus,
 						    &debug_registers_fops);
-	if (!ehci->debug_registers || IS_ERR(ehci->debug_registers))
+	if (!ehci->debug_registers)
 		goto registers_error;
 
-	goto done;
+	return;
 
 registers_error:
 	debugfs_remove(ehci->debug_periodic);
@@ -948,9 +946,6 @@ periodic_error:
 async_error:
 	debugfs_remove(ehci->debug_dir);
 	ehci->debug_dir = NULL;
