From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Subject: [PATCH -mm 8/9] netconsole: Update documentation for dynamic reconfigurability
Date: Wed, 04 Jul 2007 16:38:19 +0530
Message-ID: <20070704110819.28520.50445.sendpatchset@cselinux1.cse.iitk.ac.in>
References: <20070704110739.28520.5036.sendpatchset@cselinux1.cse.iitk.ac.in>
Cc: Keiichi Kii <k-keiichi@bx.jp.nec.com>,
	Satyam Sharma <ssatyam@cse.iitk.ac.in>,
	Netdev <netdev@vger.kernel.org>,
	Joel Becker <joel.becker@oracle.com>,
	Matt Mackall <mpm@selenic.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.iitk.ac.in ([203.197.196.4]:57175 "EHLO mail4.iitk.ac.in"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761171AbXGDLIH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jul 2007 07:08:07 -0400
In-Reply-To: <20070704110739.28520.5036.sendpatchset@cselinux1.cse.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Satyam Sharma <ssatyam@cse.iitk.ac.in>

[8/9] netconsole: Update documentation for dynamic reconfigurability

Add myself to parties interested in receiving bug reports, and give lots
of examples. Also fix some whitespace inconsistencies I introduced earlier.

Signed-off-by: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Cc: Keiichi Kii <k-keiichi@bx.jp.nec.com>
Cc: Takayoshi Kochi <t-kochi@bq.jp.nec.com>

---

 Documentation/networking/netconsole.txt |   70 +++++++++++++++++++++++++++++++-
 1 file changed, 68 insertions(+), 2 deletions(-)

---

diff -ruNp a/Documentation/networking/netconsole.txt b/Documentation/networking/netconsole.txt
--- a/Documentation/networking/netconsole.txt	2007-07-04 03:12:25.000000000 +0530
+++ b/Documentation/networking/netconsole.txt	2007-07-04 12:24:44.000000000 +0530
@@ -3,6 +3,10 @@ started by Ingo Molnar <mingo@redhat.com
 2.6 port and netpoll api by Matt Mackall <mpm@selenic.com>, Sep 9 2003
 
 Please send bug reports to Matt Mackall <mpm@selenic.com>
+and Satyam Sharma <satyam.sharma@gmail.com>
+
+Introduction:
+=============
 
 This module logs kernel printk messages over UDP allowing debugging of
 problem where disk logging fails and serial consoles are impractical.
@@ -13,6 +17,9 @@ the specified interface as soon as possi
 capture of early kernel panics, it does capture most of the boot
 process.
 
+Sender and receiver configuration:
+==================================
+
 It takes a string configuration parameter "netconsole" in the
 following format:
 
@@ -38,7 +45,7 @@ It also supports logging to multiple rem
 parameters for the multiple agents separated by semicolons and the
 complete string enclosed in "quotes", thusly:
 
-modprobe netconsole netconsole="@/,@10.0.0.2/;@/eth1,6892@10.0.0.3/"
+ modprobe netconsole netconsole="@/,@10.0.0.2/;@/eth1,6892@10.0.0.3/"
 
 Built-in netconsole starts immediately after the TCP stack is
 initialized and attempts to bring up the supplied dev at the supplied
@@ -46,6 +53,64 @@ address.
 
 The remote host can run either 'netcat -u -l -p <port>' or syslogd.
 
+Dynamic reconfiguration:
+========================
+
+Dynamic reconfigurability is a useful addition to netconsole that enables
+remote logging targets to be dynamically added, removed, or have their
+parameters reconfigured at runtime from a configfs-based userspace interface.
+
+To include this feature, select CONFIG_NETCONSOLE_DYNAMIC when building the
+netconsole module (or kernel, if netconsole is built-in).
+
+Some examples follow (configfs is mounted at the /config mountpoint, say).
+
+To add a remote logging target (target names can be arbitrary):
+
+ cd /config/netconsole/
+ mkdir target1
+
+Note that newly created targets have default parameter values (as mentioned
+above) and are disabled by default -- they must first be enabled by writing
+"1" to the "enabled" attribute (usually after setting parameters accordingly)
+as described below.
+
+To remove a target:
+
+ rmdir /config/netconsole/othertarget/
+
+The interface exposes these parameters of a netconsole target to userspace:
+
+	id		Unique identifier for this target	(read-only)
+	enabled		Is this target currently enabled?	(read-write)
+	dev_name	Local network interface name		(read-only)
+	local_ip	Source IP address to use		(read-write)
+	remote_ip	Remote agent's IP address		(read-write)
+	local_port	Source UDP port to use			(read-write)
+	remote_port	Remote agent's UDP port			(read-write)
+	local_mac	Local interface's MAC address		(read-only)
+	remote_mac	Remote agent's MAC address		(read-write)
+
+The "enabled" attribute is also used to control whether the parameters of
+a target can be updated or not -- you can modify the parameters of only
+disabled targets (i.e. if "enabled" is 0).
+
+To update a target's parameters:
+
+ cat enabled				# check if enabled is 1
+ echo 0 > enabled			# disable the target (if required)
+ echo eth2 > dev_name			# set local interface
+ echo 10.0.0.4 > remote_ip		# update some parameter
+ echo cb:a9:87:65:43:21 > remote_mac	# update more parameters
+ echo 1 > enabled			# enable target again
+
+Note that you can even update the local interface dynamically. This is
+especially useful if you want to use interfaces that have newly come up
+and didn't even exist when netconsole was loaded / initialized.
+
+Miscellaneous notes:
+====================
+
 WARNING: the default target ethernet setting uses the broadcast
 ethernet address to send packets, which can cause increased load on
 other systems on the same ethernet segment.
@@ -55,7 +120,8 @@ so it is advised to explicitly specify t
 from the config parameters passed to netconsole.
 
 TIP: to find out the MAC address of 10.0.0.2, you may try using:
-ping -c 1 10.0.0.2 ; /sbin/arp -n | grep 10.0.0.2
+
+ ping -c 1 10.0.0.2 ; /sbin/arp -n | grep 10.0.0.2
 
 TIP: in case the remote logging agent is on a separate LAN subnet than
 the sender, it is suggested to try specifying the default gateway's
