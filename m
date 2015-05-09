From: sfeldma@gmail.com
Subject: =?UTF-8?q?=5BPATCH=20net-next=20v6=2023/23=5D=20switchdev=3A=20bring=20documentation=20up-to-date?=
Date: Sat,  9 May 2015 10:40:25 -0700
Message-ID: <1431193225-807-24-git-send-email-sfeldma@gmail.com>
References: <1431193225-807-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, andrew@lunn.ch, simon.horman@netronome.com,
	joe@perches.com, sridhar.samudrala@intel.com, ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:34084 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751671AbbEIRnm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 13:43:42 -0400
Received: by pdbqa5 with SMTP id qa5so110990927pdb.1
        for <netdev@vger.kernel.org>; Sat, 09 May 2015 10:43:41 -0700 (PDT)
In-Reply-To: <1431193225-807-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Scott Feldman <sfeldma@gmail.com>

Much need updated of switchdev documentation to cover what's been
implmented to-date.  There are some XXX comments in the text for
unimplemented or broken items.  I'd like to keep these in there (poor-m=
an's
TODO list) and update the document once each issue is resolved.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 Documentation/networking/switchdev.txt |  414 ++++++++++++++++++++++++=
+++-----
 1 file changed, 355 insertions(+), 59 deletions(-)

diff --git a/Documentation/networking/switchdev.txt b/Documentation/net=
working/switchdev.txt
index f981a92..b3e18c8 100644
--- a/Documentation/networking/switchdev.txt
+++ b/Documentation/networking/switchdev.txt
@@ -1,59 +1,355 @@
-Switch (and switch-ish) device drivers HOWTO
-=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D
-
-Please note that the word "switch" is here used in very generic meanin=
g.
-This include devices supporting L2/L3 but also various flow offloading=
 chips,
-including switches embedded into SR-IOV NICs.
-
-Lets describe a topology a bit. Imagine the following example:
-
-       +----------------------------+    +---------------+
-       |     SOME switch chip       |    |      CPU      |
-       +----------------------------+    +---------------+
-       port1 port2 port3 port4 MNGMNT    |     PCI-E     |
-         |     |     |     |     |       +---------------+
-        PHY   PHY    |     |     |         |  NIC0 NIC1
-                     |     |     |         |   |    |
-                     |     |     +- PCI-E -+   |    |
-                     |     +------- MII -------+    |
-                     +------------- MII ------------+
-
-In this example, there are two independent lines between the switch si=
licon
-and CPU. NIC0 and NIC1 drivers are not aware of a switch presence. The=
y are
-separate from the switch driver. SOME switch chip is by managed by a d=
river
-via PCI-E device MNGMNT. Note that MNGMNT device, NIC0 and NIC1 may be
-connected to some other type of bus.
-
-Now, for the previous example show the representation in kernel:
-
-       +----------------------------+    +---------------+
-       |     SOME switch chip       |    |      CPU      |
-       +----------------------------+    +---------------+
-       sw0p0 sw0p1 sw0p2 sw0p3 MNGMNT    |     PCI-E     |
-         |     |     |     |     |       +---------------+
-        PHY   PHY    |     |     |         |  eth0 eth1
-                     |     |     |         |   |    |
-                     |     |     +- PCI-E -+   |    |
-                     |     +------- MII -------+    |
-                     +------------- MII ------------+
-
-Lets call the example switch driver for SOME switch chip "SOMEswitch".=
 This
-driver takes care of PCI-E device MNGMNT. There is a netdevice instanc=
e sw0pX
-created for each port of a switch. These netdevices are instances
-of "SOMEswitch" driver. sw0pX netdevices serve as a "representation"
-of the switch chip. eth0 and eth1 are instances of some other existing=
 driver.
-
-The only difference of the switch-port netdevice from the ordinary net=
device
-is that is implements couple more NDOs:
-
-  ndo_switch_parent_id_get - This returns the same ID for two port net=
devices
-			     of the same physical switch chip. This is
-			     mandatory to be implemented by all switch drivers
-			     and serves the caller for recognition of a port
-			     netdevice.
-  ndo_switch_parent_* - Functions that serve for a manipulation of the=
 switch
-			chip itself (it can be though of as a "parent" of the
-			port, therefore the name). They are not port-specific.
-			Caller might use arbitrary port netdevice of the same
-			switch and it will make no difference.
-  ndo_switch_port_* - Functions that serve for a port-specific manipul=
ation.
+Ethernet switch device driver model (switchdev)
+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
+Copyright (c) 2014 Jiri Pirko <jiri@resnulli.us>
+Copyright (c) 2014-2015 Scott Feldman <sfeldma@gmail.com>
+
+
+The Ethernet switch device driver model (switchdev) is an in-kernel dr=
iver
+model for switch devices which offload the forwarding (data) plane fro=
m the
+kernel.
+
+Figure 1 is a block diagram showing the components of the switchdev mo=
del for
+an example setup using a data-center-class switch ASIC chip.  Other se=
tups
+with SR-IOV or soft switches, such as OVS, are possible.
+
+
+=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89User-space=E2=80=89tools=E2=
=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=
=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=
=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=
=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=
=80=89
+=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89
+=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89user=E2=
=80=89space=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=
=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=
=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89|=E2=80=89=E2=80=89=E2=80=89=E2=80=
=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=
=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=
=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=
=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=
=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89
+=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89+---------------=
----------------------------------------------------+=E2=80=89=E2=80=89=
=E2=80=89
+=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89kernel=E2=
=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=
=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=
=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89|=E2=80=89N=
etlink=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=
=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=
=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=
=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=
=80=89=E2=80=89
+=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89|=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89
+=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89+--------------+----------=
---------------------+=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=
=89=E2=80=89=E2=80=89=E2=80=89
+=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89|=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89Network=E2=80=89s=
tack=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=
=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=
=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=
=89|=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=
=89=E2=80=89
+=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89|=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
(Linux)=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=
=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=
=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=
=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89|=E2=80=89=E2=80=89=E2=80=89=E2=
=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89
+=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89|=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89|=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89
+=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89+-------------------------=
---------------------+=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=
=89=E2=80=89=E2=80=89=E2=80=89
+=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89
+                           sw1p2     sw1p4     sw1p6
+=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89sw1p1=E2=80=89 + =
 sw1p3  + =E2=80=89sw1p5  +  =E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=
=89=E2=80=89=E2=80=89=E2=80=89eth1=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=
=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=
=80=89
+=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
+=E2=80=89=E2=80=89=E2=80=89=E2=80=89|=E2=80=89=E2=80=89=E2=80=89=E2=80=
=89+=E2=80=89=E2=80=89=E2=80=89=E2=80=89|=E2=80=89=E2=80=89=E2=80=89=E2=
=80=89+=E2=80=89=E2=80=89=E2=80=89=E2=80=89|=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89+=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89
+=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
|=E2=80=89=E2=80=89=E2=80=89=E2=80=89|=E2=80=89=E2=80=89=E2=80=89=E2=80=
=89|=E2=80=89=E2=80=89=E2=80=89=E2=80=89|=E2=80=89=E2=80=89=E2=80=89=E2=
=80=89|=E2=80=89=E2=80=89=E2=80=89=E2=80=89|=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89|=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89
+=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89+--+----+----+----+-+--+--=
--+---+=E2=80=89=E2=80=89+-----+-----+=E2=80=89=E2=80=89=E2=80=89=E2=80=
=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89
+=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89|=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89Switch=E2=80=89dr=
iver=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=
=89=E2=80=89|=E2=80=89=E2=80=89|=E2=80=89=E2=80=89=E2=80=89=E2=80=89mgm=
t=E2=80=89=E2=80=89=E2=80=89|=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=
=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89
+=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89|=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89(this=E2=80=89document)=E2=
=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89|=E2=
=80=89=E2=80=89|=E2=80=89=E2=80=89=E2=80=89driver=E2=80=89=E2=80=89|=E2=
=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=
=80=89
+=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89|=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89|=E2=80=89=E2=80=89|=E2=80=89=E2=80=
=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=
=89=E2=80=89|=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=
=89=E2=80=89=E2=80=89
+=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89+--------------+----------=
------+=E2=80=89=E2=80=89+-----------+=E2=80=89=E2=80=89=E2=80=89=E2=80=
=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89
+=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89|=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89 =E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89
+=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89kernel=E2=
=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=
=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=
=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89|=E2=80=89H=
W=E2=80=89bus=E2=80=89(eg=E2=80=89PCI)=E2=80=89=E2=80=89=E2=80=89=E2=80=
=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89 =E2=80=89=E2=80=89=E2=80=
=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=
=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89
+=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89+---------------=
----------------------------------------------------+=E2=80=89=E2=80=89=
=E2=80=89
+=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89hardwar=
e=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89|=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89 =E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89
+=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89+--------------+---+------=
------+=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=
=80=89 =E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=
=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89
+=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89|=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89Switch=E2=80=89de=
vice (sw1)=E2=80=89=E2=80=89=E2=80=89|=E2=80=89=E2=80=89=E2=80=89=E2=80=
=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89 =E2=80=89=E2=80=89=E2=80=89=E2=80=
=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=
=89=E2=80=89=E2=80=89=E2=80=89
+=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89|=E2=80=89=E2=80=89+----+=E2=
=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=
=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=
=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89+--------+=E2=
=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=
=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89
+=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89|=E2=80=89=E2=80=89|=E2=80=
=89=E2=80=89=E2=80=89=E2=80=89v=E2=80=89offloaded=E2=80=89data=E2=80=89=
path=E2=80=89=E2=80=89=E2=80=89|=E2=80=89mgmt=E2=80=89port=E2=80=89=E2=80=
=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=
=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89
+=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89|=E2=80=89=E2=80=89|=E2=80=
=89=E2=80=89=E2=80=89=E2=80=89|=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=
=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=
=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=
=89=E2=80=89=E2=80=89|=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=
=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=
=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=
=89=E2=80=89=E2=80=89
+=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89+--|----|----+----+----+--=
--+---+=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=
=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=
=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=
=80=89
+=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
|=E2=80=89=E2=80=89=E2=80=89=E2=80=89|=E2=80=89=E2=80=89=E2=80=89=E2=80=
=89|=E2=80=89=E2=80=89=E2=80=89=E2=80=89|=E2=80=89=E2=80=89=E2=80=89=E2=
=80=89|=E2=80=89=E2=80=89=E2=80=89=E2=80=89|=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89
+=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
+=E2=80=89=E2=80=89=E2=80=89=E2=80=89+=E2=80=89=E2=80=89=E2=80=89=E2=80=
=89+=E2=80=89=E2=80=89=E2=80=89=E2=80=89+=E2=80=89=E2=80=89=E2=80=89=E2=
=80=89+=E2=80=89=E2=80=89=E2=80=89=E2=80=89+=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89
+=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89p1=E2=80=
=89=E2=80=89=E2=80=89p2=E2=80=89=E2=80=89=E2=80=89p3=E2=80=89=E2=80=89=E2=
=80=89p4=E2=80=89=E2=80=89=E2=80=89p5=E2=80=89=E2=80=89=E2=80=89p6
+=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89
+=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89front-panel=E2=80=89ports=E2=
=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=
=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=
=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=
=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89
+=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=
=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89=E2=80=89
+
+                                    Fig 1.
+
+
+Include Files
+-------------
+
+#include <linux/netdevice.h>
+#include <net/switchdev.h>
+
+
+Configuration
+-------------
+
+Use "depends NET_SWITCHDEV" in driver's Kconfig to ensure switchdev mo=
del
+support is built for driver.
+
+
+Switch Ports
+------------
+
+On switchdev driver initialization, the driver will allocate and regis=
ter a
+struct net_device (using register_netdev()) for each enumerated physic=
al switch
+port, called the port netdev.  A port netdev is the software represent=
ation of
+the physical port and provides a conduit for control traffic to/from t=
he
+controller (the kernel) and the network, as well as an anchor point fo=
r higher
+level constructs such as bridges, bonds, VLANs, tunnels, and L3 router=
s.  Using
+standard netdev tools (iproute2, ethtool, etc), the port netdev can al=
so
+provide to the user access to the physical properties of the switch po=
rt such
+as PHY link state and I/O statistics.
+
+There is (currently) no higher-level kernel object for the switch beyo=
nd the
+port netdevs.  All of the switchdev driver ops are netdev ops or switc=
hdev ops.
+
+A switch management port is outside the scope of the switchdev driver =
model.
+Typically, the management port is not participating in offloaded data =
plane and
+is loaded with a different driver, such as a NIC driver, on the manage=
ment port
+device.
+
+Port Netdev Naming
+^^^^^^^^^^^^^^^^^^
+
+Udev rules should be used for port netdev naming, using some unique at=
tribute
+of the port as a key, for example the port MAC address or the port PHY=
S name.
+Hard-coding of kernel netdev names within the driver is discouraged; l=
et the
+kernel pick the default netdev name, and let udev set the final name b=
ased on a
+port attribute.
+
+Using port PHYS name (ndo_get_phys_port_name) for the key is particula=
rly
+useful for dynically-named ports where the device names it's ports bas=
ed on
+external configuration.  For example, if a physical 40G port is split =
logically
+into 4 10G ports, resulting in 4 port netdevs, the device can give a u=
nique
+name for each port using port PHYS name.  The udev rule would be:
+
+SUBSYSTEM=3D=3D"net", ACTION=3D=3D"add", DRIVER=3D"<driver>", ATTR{phy=
s_port_name}!=3D"", \
+	NAME=3D"$attr{phys_port_name}"
+
+Suggested naming convention is "swXpYsZ", where X is the switch name o=
r ID, Y
+is the port name or ID, and Z is the sub-port name or ID.  For example=
, sw1p1s0
+would be sub-port 0 on port 1 on switch 1.
+
+Switch ID
+^^^^^^^^^
+
+The switchdev driver must implement the switchdev op switchdev_port_at=
tr_get for
+SWITCHDEV_ATTR_PORT_PARENT_ID for each port netdev, returning the same=
 physical ID
+for each port of a switch.  The ID must be unique between switches on =
the same
+system.  The ID does not need to be unique between switches on differe=
nt
+systems.
+
+The switch ID is used to locate ports on a switch and to know if aggre=
gated
+ports belong to the same switch.
+
+Port Features
+^^^^^^^^^^^^^
+
+NETIF_F_NETNS_LOCAL
+
+If the switchdev driver (and device) only supports offloading of the d=
efault
+network namespace (netns), the driver should set this feature flag to =
prevent
+the port netdev from being moved out of the default netns.  A netns-aw=
are
+driver/device would not set this flag and be resposible for partitioni=
ng
+hardware to preserve netns containment.  This means hardware cannot fo=
rward
+traffic from a port in one namespace to another port in another namesp=
ace.
+
+Port Topology
+^^^^^^^^^^^^^
+
+The port netdevs representing the physical switch ports can be organiz=
ed into
+higher-level switching constructs.  The default construct is a standal=
one
+router port, used to offload L3 forwarding.  Two or more ports can be =
bonded
+together to form a LAG.  Two or more ports (or LAGs) can be bridged to=
 bridge
+to L2 networks.  VLANs can be applied to sub-divide L2 networks.  L2-o=
ver-L3
+tunnels can be built on ports.  These constructs are built using stand=
ard Linux
+tools such as the bridge driver, the bonding/team drivers, and netlink=
-based
+tools such as iproute2.
+
+The switchdev driver can know a particular port's position in the topo=
logy by
+monitoring NETDEV_CHANGEUPPER notifications.  For example, a port move=
d into a
+bond will see it's upper master change.  If that bond is moved into a =
bridge,
+the bond's upper master will change.  And so on.  The driver will trac=
k such
+movements to know what position a port is in in the overall topology b=
y
+registering for netdevice events and acting on NETDEV_CHANGEUPPER.
+
+L2 Forwarding Offload
+---------------------
+
+The idea is to offload the L2 data forwarding (switching) path from th=
e kernel
+to the switchdev device by mirroring bridge FDB entries down to the de=
vice.  An
+FDB entry is the {port, MAC, VLAN} tuple forwarding destination.
+
+To offloading L2 bridging, the switchdev driver/device should support:
+
+	- Static FDB entries installed on a bridge port
+	- Notification of learned/forgotten src mac/vlans from device
+	- STP state changes on the port
+	- VLAN flooding of multicast/broadcast and unknown unicast packets
+
+Static FDB Entries
+^^^^^^^^^^^^^^^^^^
+
+The switchdev driver should implement ndo_fdb_add, ndo_fdb_del and ndo=
_fdb_dump
+to support static FDB entries installed to the device.  Static bridge =
=46DB
+entries are installed, for example, using iproute2 bridge cmd:
+
+	bridge fdb add ADDR dev DEV [vlan VID] [self]
+
+Note: by default, the bridge does not filter on VLAN and only bridges =
untagged
+traffic.  To enable VLAN support, turn on VLAN filtering:
+
+	echo 1 >/sys/class/net/<bridge>/bridge/vlan_filtering
+
+Notification of Learned/Forgotten Source MAC/VLANs
+^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
+
+The switch device will learn/forget source MAC address/VLAN on ingress=
 packets
+and notify the switch driver of the mac/vlan/port tuples.  The switch =
driver,
+in turn, will notify the bridge driver using the switchdev notifier ca=
ll:
+
+	err =3D call_switchdev_notifiers(val, dev, info);
+
+Where val is SWITCHDEV_FDB_ADD when learning and SWITCHDEV_FDB_DEL whe=
n forgetting, and
+info points to a struct switchdev_notifier_fdb_info.  On SWITCHDEV_FDB=
_ADD, the bridge
+driver will install the FDB entry into the bridge's FDB and mark the e=
ntry as
+NTF_EXT_LEARNED.  The iproute2 bridge command will label these entries
+"offload":
+
+	$ bridge fdb
+	52:54:00:12:35:01 dev sw1p1 master br0 permanent
+	00:02:00:00:02:00 dev sw1p1 master br0 offload
+	00:02:00:00:02:00 dev sw1p1 self
+	52:54:00:12:35:02 dev sw1p2 master br0 permanent
+	00:02:00:00:03:00 dev sw1p2 master br0 offload
+	00:02:00:00:03:00 dev sw1p2 self
+	33:33:00:00:00:01 dev eth0 self permanent
+	01:00:5e:00:00:01 dev eth0 self permanent
+	33:33:ff:00:00:00 dev eth0 self permanent
+	01:80:c2:00:00:0e dev eth0 self permanent
+	33:33:00:00:00:01 dev br0 self permanent
+	01:00:5e:00:00:01 dev br0 self permanent
+	33:33:ff:12:35:01 dev br0 self permanent
+
+Learning on the port should be disabled on the bridge using the bridge=
 command:
+
+	bridge link set dev DEV learning off
+
+Learning on the device port should be enabled, as well as learning_syn=
c:
+
+	bridge link set dev DEV learning on self
+	bridge link set dev DEV learning_sync on self
+
+Learning_sync attribute enables syncing of the learned/forgotton FDB e=
ntry to
+the bridge's FDB.  It's possible, but not optimal, to enable learning =
on the
+device port and on the bridge port, and disable learning_sync.
+
+To support learning and learning_sync port attributes, the driver impl=
ements
+switchdev op switchdev_port_attr_get/set for SWITCHDEV_ATTR_PORT_BRIDG=
E_FLAGS.  The driver
+should initialize the attributes to the hardware defaults.
+
+FDB Ageing
+^^^^^^^^^^
+
+There are two FDB ageing models supported: 1) ageing by the device, an=
d 2)
+ageing by the kernel.  Ageing by the device is preferred if many FDB e=
ntries
+are supported.  The driver calls call_switchdev_notifiers(SWITCHDEV_FD=
B_DEL, ...) to
+age out the FDB entry.  In this model, ageing by the kernel should be =
turned
+off.  XXX: how to turn off ageing in kernel on a per-port basis or oth=
erwise
+prevent the kernel from ageing out the FDB entry?
+
+In the kernel ageing model, the standard bridge ageing mechanism is us=
ed to age
+out stale FDB entries.  To keep an FDB entry "alive", the driver shoul=
d refresh
+the FDB entry by calling call_switchdev_notifiers(SWITCHDEV_FDB_ADD, .=
=2E.).  The
+notification will reset the FDB entry's last-used time to now.  The dr=
iver
+should rate limit refresh notifications, for example, no more than onc=
e a
+second.  If the FDB entry expires, ndo_fdb_del is called to remove ent=
ry from
+the device.  XXX: this last part isn't currently correct: ndo_fdb_del =
isn't
+called, so the stale entry remains in device...this need to get fixed.
+
+FDB Flush
+^^^^^^^^^
+
+XXX: Unimplemented.  Need to support FDB flush by bridge driver for po=
rt and
+remove both static and learned FDB entries.
+
+STP State Change on Port
+^^^^^^^^^^^^^^^^^^^^^^^^
+
+Internally or with a third-party STP protocol implementation (e.g. mst=
pd), the
+bridge driver maintains the STP state for ports, and will notify the s=
witch
+driver of STP state change on a port using the switchdev op switchdev_=
attr_port_set for
+SWITCHDEV_ATTR_PORT_STP_UPDATE.
+
+State is one of BR_STATE_*.  The switch driver can use STP state updat=
es to
+update ingress packet filter list for the port.  For example, if port =
is
+DISABLED, no packets should pass, but if port moves to BLOCKED, then S=
TP BPDUs
+and other IEEE 01:80:c2:xx:xx:xx link-local multicast packets can pass=
=2E
+
+Note that STP BDPUs are untagged and STP state applies to all VLANs on=
 the port
+so packet filters should be applied consistently across untagged and t=
agged
+VLANs on the port.
+
+Flooding L2 domain
+^^^^^^^^^^^^^^^^^^
+
+For a given L2 VLAN domain, the switch device should flood multicast/b=
roadcast
+and unknown unicast packets to all ports in domain, if allowed by port=
's
+current STP state.  The switch driver, knowing which ports are within =
which
+vlan L2 domain, can program the switch device for flooding.  The packe=
t should
+also be sent to the port netdev for processing by the bridge driver.  =
The
+bridge should not reflood the packet to the same ports the device floo=
ded.
+XXX: the mechanism to avoid duplicate flood packets is being discuseed=
=2E
+
+It is possible for the switch device to not handle flooding and push t=
he
+packets up to the bridge driver for flooding.  This is not ideal as th=
e number
+of ports scale in the L2 domain as the device is much more efficient a=
t
+flooding packets that software.
+
+IGMP Snooping
+^^^^^^^^^^^^^
+
+XXX: complete this section
+
+
+L3 routing
+----------
+
+Offloading L3 routing requires that device be programmed with FIB entr=
ies from
+the kernel, with the device doing the FIB lookup and forwarding.  The =
device
+does a longest prefix match (LPM) on FIB entries matching route prefix=
 and
+forwards the packet to the matching FIB entry's nexthop(s) egress port=
s.  To
+program the device, the switchdev driver is called with add/delete ops=
 for IPv4
+and IPv6 FIB entries.  For IPv4, the driver implements switchdev ops:
+
+	int (*switchdev_fib_ipv4_add)(struct net_device *dev,
+				  __be32 dst, int dst_len,
+				  struct fib_info *fi,
+				  u8 tos, u8 type,
+				  u32 nlflags, u32 tb_id);
+
+	int (*switchdev_fib_ipv4_del)(struct net_device *dev,
+				  __be32 dst, int dst_len,
+				  struct fib_info *fi,
+				  u8 tos, u8 type,
+				  u32 tb_id);
+
+to add/delete IPv4 dst/dest_len prefix on table tb_id.  The *fi struct=
ure holds
+details on the route and route's nexthops.  *dev is one of the port ne=
tdevs
+mentioned in the routes next hop list.  If the output port netdevs ref=
erenced
+in the route's nexthop list don't all have the same switch ID, the dri=
ver is
+not called to add/delete the FIB entry.
+
+Routes offloaded to the device are labeled with "offload" in the ip ro=
ute
+listing:
+
+	$ ip route show
+	default via 192.168.0.2 dev eth0
+	11.0.0.0/30 dev sw1p1  proto kernel  scope link  src 11.0.0.2 offload
+	11.0.0.4/30 via 11.0.0.1 dev sw1p1  proto zebra  metric 20 offload
+	11.0.0.8/30 dev sw1p2  proto kernel  scope link  src 11.0.0.10 offloa=
d
+	11.0.0.12/30 via 11.0.0.9 dev sw1p2  proto zebra  metric 20 offload
+	12.0.0.2  proto zebra  metric 30 offload
+		nexthop via 11.0.0.1  dev sw1p1 weight 1
+		nexthop via 11.0.0.9  dev sw1p2 weight 1
+	12.0.0.3 via 11.0.0.1 dev sw1p1  proto zebra  metric 20 offload
+	12.0.0.4 via 11.0.0.9 dev sw1p2  proto zebra  metric 20 offload
+	192.168.0.0/24 dev eth0  proto kernel  scope link  src 192.168.0.15
+
+XXX: add/del IPv6 FIB API
+
+Nexthop Resolution
+^^^^^^^^^^^^^^^^^^
+
+The FIB entry's nexthop list contains the nexthop tuple (gateway, dev)=
, but for
+the switch device to forward the packet with the correct dst mac addre=
ss, the
+nexthop gateways must be resolved to the neighbor's mac address.  Neig=
hbor mac
+address discovery comes via the ARP (or ND) process and is available v=
ia the
+arp_tbl neighbor table.  To resolve the routes nexthop gateways, the d=
river
+should trigger the kernel's neighbor resolution process.  See the rock=
er
+driver's rocker_port_ipv4_resolve() for an example.
+
+The driver can monitor for updates to arp_tbl using the netevent notif=
ier
+NETEVENT_NEIGH_UPDATE.  The device can be programmed with resolved nex=
thops
+for the routes as arp_tbl updates.
--=20
1.7.10.4
