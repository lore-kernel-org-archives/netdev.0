From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 3/3] rfkill: Add rfkill documentation
Date: Mon, 10 Sep 2007 19:56:03 +0200
Message-ID: <200709101956.03861.IvDoorn@gmail.com>
References: <200709101954.50852.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Torokhov <dtor@insightbb.com>, netdev@vger.kernel.org,
	Inaky Perez-Gonzalez <inaky@linux.intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.187]:47453 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755928AbXIJRpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2007 13:45:17 -0400
Received: by fk-out-0910.google.com with SMTP id z23so1292408fkz
        for <netdev@vger.kernel.org>; Mon, 10 Sep 2007 10:45:15 -0700 (PDT)
In-Reply-To: <200709101954.50852.IvDoorn@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a documentation file which contains
a short description about rfkill with some
notes about drivers and the userspace interface.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>
Acked-by: Dmitry Torokhov <dtor@mail.ru>
---
 Documentation/rfkill.txt |   88 ++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 88 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/rfkill.txt

diff --git a/Documentation/rfkill.txt b/Documentation/rfkill.txt
new file mode 100644
index 0000000..93c76fc
--- /dev/null
+++ b/Documentation/rfkill.txt
@@ -0,0 +1,88 @@
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
+ - The rfkill system handles all events, userspace is not aware of events.
+ - The rfkill system handles all events, userspace is informed about the event.
+ - The rfkill system does not handle events, userspace handles all events.
+
+The buttons to enable and disable the wireless radios are important in
+situations where the user is for example using his laptop on a location where
+wireless radios _must_ be disabled (e.g airplanes).
+Because of this requirement, userspace support for the keys should not be
+made mandatory. Because userspace might want to perform some additional smarter
+tasks when the key is pressed, rfkill still provides userspace the possibility
+to take over the task to handle the key events.
+
+The system inside the kernel has been split into 2 seperate sections:
+	1 - RFKILL
+	2 - RFKILL_INPUT
+
+The first option enables rfkill support and will make sure userspace will
+be notified of any events through the input device. It also creates several
+sysfs entries which can be used by userspace. See section "Userspace support".
+
+The second option provides a rfkill input handler. This handler will
+listen to all rfkill key events and will toggle the radio accordingly,
+with this option enabled userspace could either do nothing or simply
+perform monitoring tasks.
+
+====================================
+2: Driver support
+
+Drivers who wish to build in rfkill subsystem support should
+make sure their driver depends of the Kconfig option RFKILL, it should
+_not_ depend on RFKILL_INPUT.
+
+Unless key events trigger a interrupt to which the driver listens, polling
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
+send over the input device which has been registered by the driver.
+
+====================================
+3: Userspace support
+
+For each key a input device will be created which will send out the correct
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
+this means that when 1 or 0 is written all radios will be toggled accordingly.
+For the "claim" entry writing 1 to it will mean that the kernel will no longer
+handle key events even though RFKILL_INPUT input was enabled. When "claim" has
+been set to 0, userspace should make sure it will listen for the input events
+or check the sysfs "state" entry regularly to correctly perform the required
+tasks when the rkfill key is pressed.
-- 
1.5.3

