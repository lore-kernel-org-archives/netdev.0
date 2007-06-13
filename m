From: Keiichi KII <k-keiichi@bx.jp.nec.com>
Subject: [RFC][PATCH -mm take5 7/7] update documentation
Date: Wed, 13 Jun 2007 19:31:59 +0900
Message-ID: <466FC79F.7090805@bx.jp.nec.com>
References: <466FC455.5060001@bx.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Matt Mackall <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO201.gate.nec.co.jp ([202.32.8.193]:57855 "EHLO
	tyo201.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756872AbXFMKcS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 06:32:18 -0400
In-Reply-To: <466FC455.5060001@bx.jp.nec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Keiichi KII <k-keiichi@bx.jp.nec.com>

update Documentation/networking/netconsole.txt
 - how to use sysfs for dynamic configurability
 - how to use ioctl for dynamic configurability

Signed-off-by: Keiichi KII <k-keiichi@bx.jp.nec.com>
---
Index: mm/Documentation/networking/netconsole.txt
===================================================================
--- mm.orig/Documentation/networking/netconsole.txt
+++ mm/Documentation/networking/netconsole.txt
@@ -4,6 +4,9 @@ started by Ingo Molnar <mingo@redhat.com
 
 Please send bug reports to Matt Mackall <mpm@selenic.com>
 
+1. Description
+--------------
+
 This module logs kernel printk messages over UDP allowing debugging of
 problem where disk logging fails and serial consoles are impractical.
 
@@ -13,6 +16,21 @@ the specified interface as soon as possi
 capture of early kernel panics, it does capture most of the boot
 process.
 
+This module equips the runtime configurability that can changes
+values(src/tgt IP address and port, tgt MAC address) by using sysfs
+and can add/remove logging agent by using ioctls.
+
+In order to use the runtime configurability, you have to enable
+CONFIG_NETCONSOLE_DYNCON. If you don't use one, you don't have to enable
+CONFIG_NETCONSOLE_DYNCON. By disabling this option, The kernel module
+size is smaller than the module enabled CONFIG_NETCONSOLE_DYNCON.
+
+2. Configuration
+----------------
+
+2.1 Module Parameter(sender side)
+---------------------------------
+
 It takes a string configuration parameter "netconsole" in the
 following format:
 
@@ -34,12 +52,21 @@ Examples:
 
  insmod netconsole netconsole=@/,@10.0.0.2/
 
+Or it also takes a semi-colon separated configuration parameter.
+In the case, you can send kerenl messages to multiple logging agents.
+
+ netconsole=<target1>;<target2>;<target3>
+
+ each target is the above configuration parameter.
+
+Examples:
+
+ netconsole="@/,6666@10.0.0.2/;@/,6666@10.0.0.3/"
+
 Built-in netconsole starts immediately after the TCP stack is
 initialized and attempts to bring up the supplied dev at the supplied
 address.
 
-The remote host can run either 'netcat -u -l -p <port>' or syslogd.
-
 WARNING: the default target ethernet setting uses the broadcast
 ethernet address to send packets, which can cause increased load on
 other systems on the same ethernet segment.
@@ -55,3 +82,83 @@ from IRQ contexts as well, and does not 
 sending packets. Due to these unique needs, configuration cannot
 be more automatic, and some fundamental limitations will remain:
 only IP networks, UDP packets and ethernet devices are supported.
+
+2.2 Receiver side
+-----------------
+
+The remote host can run either 'netcat -u -l -p <port>' or syslogd.
+
+3 Dynamic Configurability
+-------------------------
+
+You can make use of the dynamic configurability if
+CONFIG_NETCONSOLE_DYNCON is enabled. The operations are the following.
+
+3.1 /sys/class/misc/netconsole
+
+This entry, "netconsole", has the following attributes related to
+netconsole. You can change configuration of netconsole(writable
+attributes such as IP address, port number and so on) and check
+current configuration of netconsole.
+
+-+- /sys/class/misc/
+ |-+- netconsole/
+   |-+- port1/
+   | |--- enabled      [rw-r--r--] 0:disable 1:enable
+   | |--- id           [r--r--r--] unique port id
+   | |--- local_ip     [rw-r--r--] source IP to use
+   | |--- local_mac    [r--r--r--] source MAC address
+   | |--- local_port   [rw-r--r--] source port number for UDP packets
+   | |--- net:<netdev> [r--r--r--] symlink to net_dev: eth0,eth1,...
+   | |--- remote_ip    [rw-r--r--] port number for logging agent
+   | |--- remote_mac   [rw-r--r--] MAC address for logging agent
+   | +--- remote_port  [rw-r--r--] IP address for logging agent
+   |--- port2/
+   |--- port3/
+   ...
+
+If "enabled" attribute of certain port is '1', this port is used
+and the configurations of this port are uable to change.
+
+If "enabled" attribute of certain port is '0', this port isn't used
+and the configurations of this port are able to change.
+
+3.2 ioctls
+
+1. create device file
+
+First of all, we would like you to check the entry, "/proc/devices",
+in procfs because of creating device file for netconsole.
+If you can find the entry, "netcon" and that major number, create
+the device file using mknod command.
+
+2. send commands using ioctl system call
+
+You can send the following ioctl commands to the above device file.
+
+- NETCONSOLE_ADD_TARGET ioctl adds netconsole target
+
+In the case of module parameter,
+
+  netconsole=6665@10.0.0.1/eth0,6666@10.0.0.2/12:34:56:78:9a:bc
+
+In the case of ioclt command,
+
+  struct netconsole_request req = {
+          .netdev_name = "eth0",
+          .local_ip = inet_addr("10.0.0.1"),
+          .local_port = 6665,
+          .remote_ip = inet_addr("10.0.0.2"),
+          .remote_port = 6666,
+          .remote_mac = {0x12, 0x34, 0x56, 0x78, 0x9a, 0xbc},
+  };
+  ioctl(fd, NETCON_ADD_TARGET, &req)
+
+The above patterns mean the same thing.
+
+- NETCONSOLE_REMOVE_TARGET ioctl removes netconsole target.
+
+  ioctl(fd, NETCON_REMOVE_TARGET, &id)
+
+The above "id" is port number in /sys/class/misc/netconsole.
+For example, The "id" is 1 for /sys/class/misc/netconsole/port1.

-- 


