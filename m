From: Tobias Diedrich <ranma+kernel@tdiedrich.de>
Subject: Re: [PATCH 6/4] Fix forcedeth hibernate/wake-on-lan problems
Date: Sun, 1 Jun 2008 01:20:05 +0200
Message-ID: <20080531232005.GA2613@yamamaya.is-a-geek.org>
References: <20080518125715.GA19229@yamamaya.is-a-geek.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ayaz Abdulla <aabdulla@nvidia.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Davi
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756760AbYEaXVS@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080518125715.GA19229@yamamaya.is-a-geek.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tobias Diedrich <ranma+kernel@tdiedrich.de>

This patch is the minimal amount of code needed to support
wake-on-lan in platform mode properly (i.e. "ethtool -s eth0 wol g"
is sufficient, no additional magic needed) for me.

This is derived from David Brownells patch
(http://lists.laptop.org/pipermail/devel/2007-April/004691.html).
However I decided to move the hook into pci-acpi.c since the other
two pci hooks also live there and pci and acpi are the only users of
the platform_enable_wakeup-hook.

As a 'side-effect' this also makes wake on usb activity work for me
and I had to disable usb wakeup (which is enabled by default) using
the power/wakeup sysfs functionality ("echo disabled >
${sysfs_path_to_device}/power/wakeup").

(BTW I first thought the 'immediate reboot because of usb wake' effect is
caused by the optical mouse generating a wake event, but it rather
seems to be a problem with a flaky secondary usb host controller,
which sees a connected device where nothing is attached)

Signed-off-by: Tobias Diedrich <ranma+kernel@tdiedrich.de>

Index: linux-2.6.26-rc4.forcedwol/drivers/pci/pci-acpi.c
===================================================================
--- linux-2.6.26-rc4.forcedwol.orig/drivers/pci/pci-acpi.c	2008-06-01 00:40:23.000000000 +0200
+++ linux-2.6.26-rc4.forcedwol/drivers/pci/pci-acpi.c	2008-06-01 00:46:55.000000000 +0200
@@ -315,6 +315,25 @@
 	}
 	return PCI_POWER_ERROR;
 }
+
+static int acpi_platform_enable_wakeup(struct device *dev, int is_on)
+{
+	struct acpi_device	*adev;
+	int			status;
+
+	if (!device_can_wakeup(dev))
+		return -EINVAL;
+
+	if (is_on && !device_may_wakeup(dev))
+		return -EINVAL;
+
+	status = acpi_bus_get_device(DEVICE_ACPI_HANDLE(dev), &adev);
+	if (status < 0)
+		return status;
+
+	adev->wakeup.state.enabled = !!is_on;
+	return 0;
+}
 #endif
 
 static int acpi_pci_set_power_state(struct pci_dev *dev, pci_power_t state)
@@ -399,6 +418,7 @@
 		return 0;
 #ifdef	CONFIG_ACPI_SLEEP
 	platform_pci_choose_state = acpi_pci_choose_state;
+	platform_enable_wakeup = acpi_platform_enable_wakeup;
 #endif
 	platform_pci_set_power_state = acpi_pci_set_power_state;
 	return 0;
