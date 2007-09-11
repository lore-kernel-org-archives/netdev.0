From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 3/3 v2] rfkill: Add rfkill documentation
Date: Tue, 11 Sep 2007 19:01:01 +0200
Message-ID: <200709111901.02137.IvDoorn@gmail.com>
References: <200709101954.50852.IvDoorn@gmail.com> <200709101956.03861.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Torokhov <dtor@insightbb.com>, netdev@vger.kernel.org,
	Inaky Perez-Gonzalez <inaky@linux.intel.com>,
	Randy Dunlap <randy.dunlap@oracle.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:3016 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750971AbXIKQtp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2007 12:49:45 -0400
Received: by ug-out-1314.google.com with SMTP id z38so93456ugc
        for <netdev@vger.kernel.org>; Tue, 11 Sep 2007 09:49:43 -0700 (PDT)
In-Reply-To: <200709101956.03861.IvDoorn@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a documentation file which contains
a short description about rfkill with some
notes about drivers and the userspace interface.

Changes since v1:
 - Spellchecking

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>
Acked-by: Dmitry Torokhov <dtor@mail.ru>
---

Only patch 3 was updated, patches 1 and 2 remain the same.

 Documentation/rfkill.txt |   89 ++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 89 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/rfkill.txt

diff --git a/Documentation/rfkill.txt b/Documentation/rfkill.txt
new file mode 100644
index 0000000..0f35134
--- /dev/null
+++ b/Documentation/rfkill.txt
@@ -0,0 +1,89 @@
+rfkill - RF switch subsystem support
+====================================
+
+1 Implementation details
+2 Driver support
+3 Userspace support
+
+===============================================================================
+1: Implementation details
+
+The rfkill switch subsystem offers support for keys often found on laptops
+to enable wireless devices like WiFi and Bluetooth.
+
+This is done by providing the user 3 possibilities:
+ 1 - The rfkill system handles all events, userspace is not aware of events;
+ 2 - The rfkill system handles all events, userspace is informed about the event;
+ 3 - The rfkill system does not handle events, userspace handles all events;
+
+The buttons to enable and disable the wireless radios are important in
+situations where the user is for example using his laptop on a location where
+wireless radios _must_ be disabled (e.g. airplanes).
+Because of this requirement, userspace support for the keys should not be
+made mandatory. Because userspace might want to perform some additional smarter
+tasks when the key is pressed, rfkill still provides userspace the possibility
+to take over the task to handle the key events.
+
+The system inside the kernel has been split into 2 separate sections:
+	1 - RFKILL
+	2 - RFKILL_INPUT
+
+The first option enables rfkill support and will make sure userspace will
+be notified of any events through the input device. It also creates several
+sysfs entries which can be used by userspace. See section "Userspace support".
+
+The second option provides an rfkill input handler. This handler will
+listen to all rfkill key events and will toggle the radio accordingly.
+With this option enabled userspace could either do nothing or simply
+perform monitoring tasks.
+
+====================================
+2: Driver support
+
+To build a driver with rfkill subsystem support, the driver should
+depend on the Kconfig symbol RFKILL; it should _not_ depend on
+RKFILL_INPUT.
+
+Unless key events trigger an interrupt to which the driver listens, polling
+will be required to determine the key state changes. For this the input
+layer providers the input-polldev handler.
+
+A driver should implement a few steps to correctly make use of the
+rfkill subsystem. First for non-polling drivers:
+
+	- rfkill_allocate()
+	- input_allocate_device()
+	- rfkill_register()
+	- input_register_device()
+
+For polling drivers:
+
+	- rfkill_allocate()
+	- input_allocate_polled_device()
+	- rfkill_register()
+	- input_register_polled_device()
+
+When a key event has been detected, the correct event should be
+sent over the input device which has been registered by the driver.
+
+====================================
+3: Userspace support
+
+For each key an input device will be created which will send out the correct
+key event when the rfkill key has been pressed.
+
+The following sysfs entries will be created:
+
+	name: Name assigned by driver to this key (interface or driver name).
+	type: Name of the key type ("wlan", "bluetooth", etc).
+	state: Current state of the key. 1: On, 0: Off.
+	claim: 1: Userspace handles events, 0: Kernel handles events
+
+Both the "state" and "claim" entries are also writable. For the "state" entry
+this means that when 1 or 0 is written all radios, not yet in the requested
+state, will be will be toggled accordingly.
+For the "claim" entry writing 1 to it means that the kernel no longer handles
+handle key events even though RFKILL_INPUT input was enabled. When "claim" has
+been set to 0, userspace should make sure that it listens for the input events
+or check the sysfs "state" entry regularly to correctly perform the required
+tasks when the rkfill key is pressed.
-- 
1.5.3

