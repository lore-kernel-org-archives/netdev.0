From: sjur.brandeland@stericsson.com
Subject: [PATCH] [CAIF-RFC 7/8-v2] CAIF Protocol Stack
Date: Fri, 09 Oct 2009 15:39:30 +0200
Message-ID: <1255095571-6501-8-git-send-email-sjur.brandeland@stericsson.com>
References: <1255095571-6501-1-git-send-email-sjur.brandeland@stericsson.com>
 <1255095571-6501-2-git-send-email-sjur.brandeland@stericsson.com>
 <1255095571-6501-3-git-send-email-sjur.brandeland@stericsson.com>
 <1255095571-6501-4-git-send-email-sjur.brandeland@stericsson.com>
 <1255095571-6501-5-git-send-email-sjur.brandeland@stericsson.com>
 <1255095571-6501-6-git-send-email-sjur.brandeland@stericsson.com>
 <1255095571-6501-7-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: stefano.babic@babic.homelinux.org, randy.dunlap@oracle.com,
	kim.xx.lilliestierna@stericsson.com,
	christian.bejram@stericsson.com, daniel.martensson@stericsson.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bgo1smout1.broadpark.no ([217.13.4.94]:51694 "EHLO
	bgo1smout1.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760787AbZJINm6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2009 09:42:58 -0400
Received: from bgo1sminn1.broadpark.no ([217.13.4.93])
 by bgo1smout1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KR9002AL1Z9VL90@bgo1smout1.broadpark.no> for
 netdev@vger.kernel.org; Fri, 09 Oct 2009 15:40:21 +0200 (CEST)
Received: from localhost.localdomain ([84.49.68.131])
 by bgo1sminn1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KR900DNY1Y4LSP0@bgo1sminn1.broadpark.no> for
 netdev@vger.kernel.org; Fri, 09 Oct 2009 15:40:20 +0200 (CEST)
In-reply-to: <1255095571-6501-7-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Braendeland <sjur.brandeland@stericsson.com>

Change-Id: I6cb476abc44bf49ac74562178dba7b6e47c2e342
Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 Documentation/CAIF/Linux-CAIF.txt                  |  318 ++++++++++++=
+++++
 Documentation/CAIF/README                          |   60 ++++
 Documentation/CAIF/caif_user_config.dox            |  105 ++++++
 Documentation/CAIF/chardevconfig/Makefile          |   11 +
 Documentation/CAIF/chardevconfig/README            |   39 ++
 Documentation/CAIF/chardevconfig/caif_cmd_parse.c  |  366 ++++++++++++=
++++++++
 Documentation/CAIF/chardevconfig/caif_cmd_parse.h  |   22 ++
 Documentation/CAIF/chardevconfig/chardevconfig.c   |  110 ++++++
 .../CAIF/chardevconfig/create_devices.config       |    1 +
 .../CAIF/chardevconfig/delete_devices.config       |    1 +
 Documentation/CAIF/ldiscd/README                   |   12 +
 Documentation/CAIF/ldiscd/ldiscd.c                 |  123 +++++++
 Documentation/DocBook/caif.tmpl                    |  238 ++++++++++++=
+
 13 files changed, 1406 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/CAIF/Linux-CAIF.txt
 create mode 100644 Documentation/CAIF/README
 create mode 100644 Documentation/CAIF/caif_user_config.dox
 create mode 100644 Documentation/CAIF/chardevconfig/Makefile
 create mode 100644 Documentation/CAIF/chardevconfig/README
 create mode 100644 Documentation/CAIF/chardevconfig/caif_cmd_parse.c
 create mode 100644 Documentation/CAIF/chardevconfig/caif_cmd_parse.h
 create mode 100644 Documentation/CAIF/chardevconfig/chardevconfig.c
 create mode 100644 Documentation/CAIF/chardevconfig/create_devices.con=
fig
 create mode 100644 Documentation/CAIF/chardevconfig/delete_devices.con=
fig
 create mode 100644 Documentation/CAIF/ldiscd/README
 create mode 100644 Documentation/CAIF/ldiscd/ldiscd.c
 create mode 100644 Documentation/DocBook/caif.tmpl

diff --git a/Documentation/CAIF/Linux-CAIF.txt b/Documentation/CAIF/Lin=
ux-CAIF.txt
new file mode 100644
index 0000000..26faba6
--- /dev/null
+++ b/Documentation/CAIF/Linux-CAIF.txt
@@ -0,0 +1,318 @@
+Linux CAIF
+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
+
+Introduction
+------------
+CAIF is a MUX protocol used by ST-Ericsson cellular modems for
+communication
+between Modem and host. The host processes can open virtual AT
+channels, initiate GPRS Data connections, Video channels and
+Utility Channels.
+The Utility Channels are general purpose pipes between modem
+and host.
+
+ST-Ericsson modems support a number of transports between modem
+and host,
+currently Uart and Shared Memory are available for Linux.
+
+Architecture:
+------------
+The Implementation of CAIF is divided into:
+* CAIF Drivers: Character Device, Net Device and Kernel API.
+* CAIF Generic Protocol Implementation
+* CAIF Link Layer
+
+CAIF is using IOCTLs to manage the CAIF Drivers.
+
+
+  IOCTL
+   !
+   !     +------+   +------+   +------+
+   !    +------+!  +------+!  +------+!
+   !    ! Char !!  !Kernel!!  ! Net  !!
+   !    ! Dev  !+  ! API  !+  ! Dev  !+   <- CAIF Drivers
+   !    +------+   +------!   +------+
+   !       !          !          !
+   !       +----------!----------+
+   !               +------+               <- CAIF Protocol Implementat=
ion
+   +------->       ! CAIF !                  /dev/caifconfig
+                   +------+
+             +--------!--------+
+             !                 !
+          +------+          +-----+
+          !ShMem !          ! TTY !       <- Link Layer
+          +------+          +-----+
+
+
+
+Using CAIF Character Device
+-----------------------------
+CAIF character devices are configured by use of IOCTLs on the
+node "/dev/caifconfig". E.g. the following code will create an
+CAIF Character Device that will make an AT channel accessible:
+
+   struct caif_channel_create_action at =3D {
+	.name =3D {
+	   .name =3D "cnhlatl",
+	   .type =3D CAIF_DEV_CHR
+        },
+	.config =3D {
+	    .channel =3D CAIF_CHTY_AT,
+	 }};
+   fd =3D open("/dev/caifconfig",..);
+   ioctl(fd, CAIF_IOC_CONFIG_DEVICE,&at_config);
+
+A configuration tool chardevconfig exist in order to simplify
+creation of CAIF Channels (typically used from init scripts).
+E.g:
+
+   $chardevconfig /dev/caifconfig -
+   CREATE TYPE=3DAT NAME=3Dchnlat1 DEVTYPE=3DCHAR PHYPREF=3DBW
+
+This will result in creation of the device node "/dev/chnlat1".
+"/dev/chnlat1" can be used to read and write AT commands and
+responses from the modem:
+
+   $cat /dev/chnlat1 &
+   $printf "AT\r" > /dev/chnlat1
+   OK
+
+
+
+Using CAIF Net Device
+----------------------
+CAIF Net device can be created similarly as the character
+device.
+E.g:
+
+   $chardevconfig /dev/caifconfig -
+   CREATE TYPE=3DDGM NAME=3Dcaif0 DEVTYPE=3DNET CONNID=3D1 ^D
+
+   $ifconfig caif0 <ip address> up
+
+
+Using the Kernel API
+----------------------
+The Kernel API is used for accessing CAIF channels from the
+kernel.
+The user of the API has to implement two callbacks for receive
+and control.
+The receive callback give a CAIF packet as a SKB. The control
+callback will
+notify about channel initialization complete, and flow-on/flow-
+off.
+
+
+  struct caif_device caif_dev =3D {
+    .caif_config =3D {
+     .name =3D "MYDEV"
+     .type =3D CAIF_CHTY_AT
+    }
+   .receive_cb =3D my_receive,
+   .control_cb =3D my_control,
+  };
+
+  caif_add_device(&caif_dev);
+
+  caif_transmit(&caif_dev, skb);
+
+
+See the caif_kernel.h for details about the CAIF kernel API.
+
+
+
+
+
+
+
+
+I M P L E M E N T A T I O N
+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D
+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D
+
+
+
+
+GenCAIF - The Generic CAIF Protocol Layer
+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
+
+
+GenCaif is a generic CAIF protocol implementation. It implements the C=
AIF
+protocol as defined by ST-Ericsson.
+GenCaif implements the CAIF protocol stack in a layered approach, wher=
e
+each layer described in the specification is implemented as a separate=
 layer.
+The architecture is inspired by the design patterns "Protocol Layer" a=
nd
+"Protocol Packet".
+
+=3D=3D CAIF structure =3D=3D
+
+The goal is to have caif as system independent as possible.
+All caif code can be found under GenCaif/src and GenCaif/inc.
+The actual linux module implementation is under src/kernel.
+There is also a user space program that is not up to date to run the s=
tack in
+user space for testing.
+
+We have tested the kernel implementation on the emulator with a modem =
and we
+are able to enumerate and make a link setup.
+
+GenCAIF is:
+      -	Simple implementation of CAIF.
+      -	Layered architecture (ala Streams), each layer specified CAIF
+        specification is implemented in a separate c-file.
+      -	Client of GenCaif must implement PHY layer to access physical =
HW
+	with receive and transmit functions.
+      -	Client of GenCaif must call configuration function add PHY lay=
er.
+      -	Client of GenCaif must implement adaptation layer to consume/p=
roduce
+        CAIF payload with receive and transmit functions.
+      -	Client of GenCaif  must call configuration function add adapta=
tion
+        layer.
+      - When receiving / transmitting CAIF Packets (cfpkt) ownership i=
s passed
+        to the called function (except Framinglayer's receive function=
).
+
+
+
+Layered Architecture
+--------------------
+The CAIF protocol can be divided into two parts Support functions and =
Protocol
+Implementation. The support functions include:
+
+      - CFPKT CAIF Packet. Implementation of CAIF Protocol Packet. The
+        CAIF Packet has functions for creating,destroying, adding cont=
ent, and
+        adding/extracting header and trailers to protocol packets.
+
+      - CFLST CAIF list implementation.
+
+      - CFGLUE CAIF Glue. Contains OS Specifics such as memory
+        allocation, endianness etc.
+
+
+The CAIF Protocol implementation contains:
+
+      - CFCNFG CAIF Configuration layer. Configures the CAIF Protocol
+        Stack, and has Client interface for adding Link-Layer and
+	Driver interfaces on top of the CAIF Stack.
+
+      - CFCTRL CAIF Control layer. Encodes and Decodes control message=
s
+	such as enumeration, and channel setup. And matches request and
+	response messages.
+
+      - CFSERVL General CAIF Service Layer functionality, handle flow
+	control and remote shutdown requests.
+
+      - CFVEI CAIF VEI layer. Handles CAIF VEI layer (AT-Channel),
+        code/encodes VEI frames.
+
+      - CFDGML CAIF Data-gram layer. Handles CAIF Data-gram layer(IP
+        traffic), code/encodes Datagram frames.
+
+      - CFMUX CAIF Mux layer. Handles multiplexing between multiple
+        physical bearers and multiple channels such as VEI, Data-gram =
etc
+	The MUX is keeping track of the existing CAIF Channels and
+	Physical Instances and selects the apropriate instance based
+	on Channel-Id and Physical-ID.
+
+      - CFFRML CAIF Framing layer. Handles Framing i.e. Frame length
+        and frame checksum.
+
+      - CFSERL CAIF Serial layer. Handles concatenation/split of frame=
s
+        into CAIF Frames with correct length.
+
+      - CFSHML CAIF Shared Memory layer.
+
+
+
+                    +---------+
+                    | Config  |
+                    | CFCNFG  |
+                    +---------+
+                         !
+    +---------+     +---------+     +---------+
+    |   AT    |     | Control |     | Datagram|
+    | CFVEIL  |     | CFCTRL  |     | CFDGML  |
+    +---------+     +---------+     +---------+
+           \_____________!______________/
+                         !
+                    +---------+
+                    |   MUX   |
+                    |         |
+                    +---------+
+                    _____!_____
+                   /           \
+            +---------+     +---------+
+            | CFFRML  |     | CFFRML  |
+            | Framing |     | Framing |
+            +---------+     +---------+
+                 !              !
+            +---------+     +---------+
+            | Sh-Mem  |     | Serial  |
+            | CFSHML  |     | CFSERL  |
+            +---------+     +---------+
+
+
+
+In this layered approach the following "rules" applies.
+      - All layers embedd the same structure 'struct layer'
+      - Layer do not depend on any others layer private data.
+      - Layers are stacked by setting the pointers
+		  layer->up , layer->dn
+      -	In order to send data upwards each layer should do
+		 layer->up->receive(layer->up, packet);
+      - In oder to send data downwards each layer should do
+		 layer->dn->transmit(layer->dn, packet);
+
+
+
+Linux Driver Implementation
+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D
+
+Linux GPRS Net Device and Character Devices are implemented on top of =
the
+Generic CAIF protocol. The Net device and Chr device has an instance o=
f
+'struct layer' as the generic caif protocol stack.
+Net and Chr device implements the 'receive()' function defined by
+'struct layer' as the rest of the CAIF stack. In this way transmit and
+reception of packets is handled as the rest of the layers, 'dn->transm=
it()'
+function is called in order to tranmit data.
+
+The layer on top of the Generic CAIF is called an "adaptation layer".
+
+
+Configuration of Drivers
+------------------------
+
+Configuration is the most complex part of the CAIF protocol.
+Configuration is controlled by the Misc device 'caifconfig'
+implemented in caif_chr. A device is created when a IOCTL
+command for creation is received containing information about
+the CAIF Channel type to be created and the type of device to instanci=
ate
+(Net Device or Character Device).
+
+The Net Device and Character Device will register into the 'caifconfig=
'
+device by calling 'caif_register_netdev' and 'caif_register_chrdev'.
+When registered the 'caifconfig' module will keep function pointers
+to the devices used when IOCTL creates new devices.
+
+
+The CAIF Configuration module CFCNFG is responsible for connecting and
+setting up the entire CAIF stack.
+
+The function 'cfcnfg_add_adapt_layer' is used to connect a Linux Drive=
r
+to the ST-Ericsson modem. This function will trigger the setup of CAIF
+Channel by sending a "LinkSetup" message to the modem. When the
+"LinkSetupResponse" is received the CAIF protocol for the requested
+CAIF Service will be set up.
+
+The CAIF Channel configuration parameters will be given as input.
+
+
+
+Configuration of Link Layer
+---------------------------
+The Link Layer (or Phy Layer) must implement the 'transmit' function
+defined by 'struct layer' in order to send payload. When data is recei=
ved
+the Link Layer calls 'up->receive()'.
+Configuring the link layer is done by the function 'cfcnfg_add_phy_lay=
er'.
+This function will set up the CAIF Layers for the new Link Layer.
+
+
+The physical Link Layers registers intself into 'caifconfig' by
+calling the function 'caif_phy_register()'.
diff --git a/Documentation/CAIF/README b/Documentation/CAIF/README
new file mode 100644
index 0000000..a8c43cb
--- /dev/null
+++ b/Documentation/CAIF/README
@@ -0,0 +1,60 @@
+copyright (C) ST-Ericsson AB 2009
+Author: Sjur Brendeland/ sjur.brandeland@stericsson.com
+        Kim Lilliestierna Kim.xx.Lilliestierna@ericsson.com
+License terms: GNU General Public License (GPL), version 2.
+
+=3D=3D=3D Start =3D=3D=3D
+Copy the .ko files onto the board, and do insmod:
+
+insmod caif.ko
+insmod phyif_loop.ko
+insmod chnl_chr.ko
+insmod chnl_net.ko
+ifconfig caif0 <your-home-address> up
+
+
+=3D=3D=3D Test Loopback on net device =3D=3D=3D
+insmod chnl_net.ko loop=3Dyes
+ifconfig caif0 192.168.0.1 up
+ping -c 10 -s 1000 192.168.0.2
+
+=3D=3D=3D Preparing the setup.=3D=3D=3D
+
+Make sure that the kernel is built with module support.
+
+There are some things that need to be
+tweaked to get the host TTY correctly setup to talk to the modem.
+Since the CAIF stack is running in the kernel and we want to use the e=
xisting
+TTY we are installing our physical serial driver as a line discipline =
above
+the TTY device.
+
+To achieve this we need the help of a daemon program called ldiscd.
+The benefit is that we can hook up to any TTY, the downside is that we=
 need
+an extra operation in order to install the line discipline.
+
+Getting the host TTY to behave (This should only be necessary when run=
ning
+on the emulator, otherwise the ldiscd should correctly configure the U=
ART).
+
+Retrieve the current settings:
+
+$ stty -a -F /dev/ttyUSB1
+
+Make sure that we are having 115200, 8n1, CTS/RTS (for example if CTS/=
RTS is missing):
+$ stty -F /dev/ttyUSB1 ctsrts
+
+Build the line discipline daemon. (You need to change CAIF_LDISC_TTY
+if your not using /dev/ttyS0.)
+
+$ gcc ldiscd.c -o ldisc
+
+Install the line discipline (daemon)
+$ ldisc
+
+Install the VEI channel (this will enumerate and do the linksetup of t=
he first VEI channel. If this goes well you should see /dev/chn*) (Ther=
e are printks logging all buffers that can be checked with dmesg):
+$ modprobe chnl_chr
+
+The AT (VEI) channel is ready to use (you can now send AT commands on =
it):
+$ echo -e "AT\r\n" > /dev/chnlat10
+
+Verify that you got an OK response (There are printks logging all buff=
ers that can be checked with dmesg):
+$ cat /dev/chnlat10
diff --git a/Documentation/CAIF/caif_user_config.dox b/Documentation/CA=
IF/caif_user_config.dox
new file mode 100644
index 0000000..4753139
--- /dev/null
+++ b/Documentation/CAIF/caif_user_config.dox
@@ -0,0 +1,105 @@
+/*
+*      Copyright (C) ST-Ericsson AB 2009
+*
+*      CAIF User Space API for CAIF Channels.
+*
+*      Author: Sjur Br=E6ndeland/ sjur.brandeland@stericsson.com
+*
+*      License terms: GNU General Public License (GPL), version 2 or l=
ater.
+*/
+
+
+/**
+\defgroup  caif_config Configuring CAIF
+\section CAIF Configiration  basics
+CAIF is configured by ioctl's agains the CAIF configuration device nor=
mally \b "/dev/caifconfig"
+
+The ioctl structurs can either be populated manually or the cmd_parse =
utility from GenCaif can be
+used to parse a higlevel commands string and populate the itoctl struc=
ture correctly.
+
+This method is used by the chrdevconfig utility that also can be used =
to configure  CAIF and is typically used by the init system.
+
+Since the high level command language is a direct mapping of the exist=
ing ioctl commands the following description uses that.
+
+The CAIF Kernel Driver will act on the given \b CREATE or \b DELETE co=
mmands and create or delete CAIF channels accordingly.
+
+The hardware drivers for the physical links to the modems is configure=
d by \b ACTIVATE or \b DEACTIVATE commands.
+CAIF PHY Drivers and Channel configuration must be done before any CAI=
=46 Channels can be accessed from Linux User Space.
+
+\section Defined commands
+The following commands are defined:
+- \b CREATE                      - Create a new Net or Character devic=
e.
+- \b DELETE                      - Delete a Net or Character device
+- \b ACTIVATE                    - Activate a CAIF PHY interface.
+- \b DEACTIVATE                  - De-activate a CAIF PHY interface.
+
+\remark
+Character type devices will show up in /dev/ once they are configured.
+Note also that configured channels are not opened before a file handle=
 is opened from user space.
+
+\section Examples
+The examples below uses the chardevconfig utility as an example on cre=
ating channels
+
+\subsection Configuration of an AT type Channel:
+\code
+$ echo "CREATE TYPE=3DAT DEV=3DCHAR NAME=3Dchnlat1" | chrdevconfig /de=
v/caifconfig
+$ ls /dev/chnlat1
+/dev/chnlat1
+\endcode
+
+\subsection Example configuration of an RFM type Channel:
+\code
+$ echo "CREATE TYPE=3DRFM DEV=3DCHAR NAME=3Drfm01 CONNID=3D1 VOLUME=3D=
/rfm" | chrdevconfig  /dev/caifconfig
+\endcode
+
+\subsection Configure a new PHY Instance
+\code
+$ echo "CONFIG-PHY TYPE=3DMSL NAME=3DPHYMSL8 INSTANCE=3D1 CHECKSUM=3Dn=
o HEAD-ALIGN=3D2 TAIL-ALIGN=3D2 TRANSFER-ALIGN=3D16
+\endcode
+
+\subsection Example of Android Init file:
+config file, typically /etc/create_devices.config
+\code
+CREATE TYPE=3DAT NAME=3Dchnlat10 DEVTYPE=3DCHAR PHYPREF=3DLAT PRIO=3DH=
I
+CREATE TYPE=3DAT NAME=3Dchnlat11 DEVTYPE=3DCHAR PHYPREF=3DLAT PRIO=3DH=
I
+CREATE TYPE=3DUTIL NAME=3Dchn_psocktest DEVTYPE=3DCHAR PHYPREF=3DLAT S=
OCK=3DCAIF_PSOCK_TEST PARAM=3D01
+CREATE TYPE=3DDGMLOOP NAME=3Ddatagram_loop DEVTYPE=3DCHAR PHYPREF=3DBW
+\endcode
+and the init entry would be:
+\code
+# init file entry for CAIF
+# Configure MSL for CAIF
+chardevconfig /dev/caifconfig /etc/create_devices.config
+\endcode
+
+
+\section Configuration syntax
+
+\code
+CREATE					Create new CAIF Channel
+TYPE=3D[ AT | UTIL | DGM | RFM | DEBUG ]	Type of CAIF Channel to confi=
gure.
+NAME=3D<devname>				Name of character device to create. Device will be=
 visible in /dev/<devname>.
+DEVTYPE=3DCHAR | NET			Type of Linux Device to create, Character Devic=
e or Net Device.
+PHYNAME=3D<name> | PHYPEF=3D BW | LAT	Name of Physical Device, or pref=
erence Bandwidth (BW) or Latency (LAT)
+[ PRIO=3D[ HI, NORM, LOW ] ]		Priority level payload data in the CAIF =
Channel.
+[ CONNID=3D<id> ]			Connection ID - Applies to RFM and DATAGRAM
+[ VOLUME=3D<volume> ] 			Volume name of RFM, Applies to RFM only
+[ SOCK=3D<PSOCK NAME> ] 			PSock Server Name, Applies to PSOCK only
+[ PARAM=3D<param> ] 			Parameter to PSOCK, Applies to PSOCK only
+
+
+DELETE NAME=3D<devname>			Deletes a CAIF Channel
+
+
+ACTIVATE				Activates a new CAIF PHY Instance
+PHYTYPE=3D[UART|SPI|MSL|SHM|LOOP]	Type of CAIF PHY Instance to configu=
re
+NAME=3D<phy-name>			Name of the CAIF PHY Device
+INSTANCE=3D<id>				Instance ID of the device
+CHECKSUM=3D[yes|no]			Frame Checksum is used for this PHY
+PARAM=3D...				Other PHY Specific configuration parameters
+
+
+DEACTIVATE NAME=3D<phy-name>		De-activates a PHY Instance
+
+\endcode
+*/
diff --git a/Documentation/CAIF/chardevconfig/Makefile b/Documentation/=
CAIF/chardevconfig/Makefile
new file mode 100644
index 0000000..5bd7d90
--- /dev/null
+++ b/Documentation/CAIF/chardevconfig/Makefile
@@ -0,0 +1,11 @@
+CFLAGS=3D-g -Wall -I ../../../include -I../../../include/linux/caif
+
+PROGS=3Dchardevconfig
+OBJS=3Dchardevconfig.o caif_cmd_parse.o
+all: $(PROGS)
+
+chardevconfig: chardevconfig.o caif_cmd_parse.o
+	$(CC) $(CFLAGS) -o chardevconfig $(OBJS)
+
+clean:
+	rm -f $(PROGS) $(OBJS)
diff --git a/Documentation/CAIF/chardevconfig/README b/Documentation/CA=
IF/chardevconfig/README
new file mode 100644
index 0000000..bc7013b
--- /dev/null
+++ b/Documentation/CAIF/chardevconfig/README
@@ -0,0 +1,39 @@
+Usage: chardevconfig configdevice configfile
+Usage: chardevconfig configdevice -
+
+The program will read commands from the configfile (or stdin), parse t=
hem and
+do ioctl calls to the configdevice. One command per line. Lines with s=
yntax
+errors (e.g. starting with a #) will be skipped.
+
+Examples:
+
+CREATE TYPE=3DAT NAME=3Dchnlat10 DEVTYPE=3DCHAR PHYPREF=3DLAT PRIO=3DH=
I
+CREATE TYPE=3DAT NAME=3Dchnlat11 DEVTYPE=3DCHAR PHYPREF=3DLAT PRIO=3DH=
I
+CREATE TYPE=3DAT NAME=3Dchnlat12 DEVTYPE=3DCHAR PHYPREF=3DLAT PRIO=3DH=
I
+CREATE TYPE=3DAT NAME=3Dchnlat13 DEVTYPE=3DCHAR PHYPREF=3DLAT PRIO=3DH=
I
+
+CREATE TYPE=3DRFM NAME=3Dchn_rfm DEVTYPE=3DCHAR PHYPREF=3DBW CONNID=3D=
1 VOLUME=3Drfm
+CREATE TYPE=3DRFM NAME=3Dchn_afs DEVTYPE=3DCHAR PHYPREF=3DBW CONNID=3D=
1 VOLUME=3D/afs
+CREATE TYPE=3DRFM NAME=3Dchn_ifs DEVTYPE=3DCHAR PHYPREF=3DBW CONNID=3D=
1 VOLUME=3D/ifs
+CREATE TYPE=3DRFM NAME=3Dchn_sys DEVTYPE=3DCHAR PHYPREF=3DBW CONNID=3D=
1 VOLUME=3D/sys"
+
+CREATE TYPE=3DUTIL NAME=3Dchn_psocktest DEVTYPE=3DCHAR PHYPREF=3DLAT S=
OCK=3DCAIF_PSOC_TEST PARAM=3D01
+
+CREATE TYPE=3DDGM NAME=3Dchn_datagram DEVTYPE=3DCHAR PHYPREF=3DBW CONN=
ID=3D1
+CREATE TYPE=3DDGM NAME=3Ddatagram_raw_ip DEVTYPE=3DCHAR PHYPREF=3DBW C=
ONNID=3D1
+
+CREATE TYPE=3DDGMLOOP NAME=3Ddatagram_loop DEVTYPE=3DCHAR PHYPREF=3DBW
+
+
+DELETE NAME=3Dchnlat10 DEVTYPE=3DCHAR
+DELETE NAME=3Dchnlat11 DEVTYPE=3DCHAR
+DELETE NAME=3Dchnlat12 DEVTYPE=3DCHAR
+DELETE NAME=3Dchnlat13 DEVTYPE=3DCHAR
+DELETE NAME=3Dchn_rfm DEVTYPE=3DCHAR
+DELETE NAME=3Dchn_afs DEVTYPE=3DCHAR
+DELETE NAME=3Dchn_ifs DEVTYPE=3DCHAR
+DELETE NAME=3Dchn_sys DEVTYPE=3DCHAR
+DELETE NAME=3Dchn_psocktest DEVTYPE=3DCHAR
+DELETE NAME=3Dchn_datagram DEVTYPE=3DCHAR
+DELETE NAME=3Ddatagram_loop DEVTYPE=3DCHAR
+DELETE NAME=3Ddatagram_raw_ip DEVTYPE=3DCHAR
diff --git a/Documentation/CAIF/chardevconfig/caif_cmd_parse.c b/Docume=
ntation/CAIF/chardevconfig/caif_cmd_parse.c
new file mode 100644
index 0000000..0833184
--- /dev/null
+++ b/Documentation/CAIF/chardevconfig/caif_cmd_parse.c
@@ -0,0 +1,366 @@
+/*
+ *      Copyright (C) ST-Ericsson AB 2009
+ *
+ *      Author: Daniel Martensson / Daniel.Martensson@stericsson.com
+ *
+ *      License terms: GNU General Public License (GPL), version 2.
+ *
+ */
+
+#include <stdio.h>
+#include <string.h>
+#include <strings.h>
+#include <sys/ioctl.h>
+#include <caif_config.h>
+#include <caif_ioctl.h>
+#include <stdio.h>
+
+#define CFLOG_TRACE(a)
+
+
+/** Strips of blanks */
+void skip_blanks(char **c)
+{
+	while (**c =3D=3D ' ')
+		(*c)++;
+
+}
+
+/** Parses the specified command.
+ *  @param[in/out] in Pointer to where to start parsing, and if parsin=
g successfull position behind parsed tex
+ *  @param[in]     cmd String to parse
+ *  @return        1 on success, 0 on error
+ */
+int cmd_parse(char **in, char *cmd, int *err)
+{
+
+	char *pos =3D *in;
+	skip_blanks(&pos);
+	if (strncmp(pos, cmd, strlen(cmd)) =3D=3D 0) {
+		pos +=3D strlen(cmd);
+		skip_blanks(&pos);
+		*in =3D pos;
+		CFLOG_TRACE(("arg_parse: Match '%s'\n", cmd));
+
+		return 1;
+	}
+	return 0;
+}
+
+/** Parses a value pair on the format <CMD> =3D <arg>
+ *  @param[in/out] in Pointer to where to start parsing, and if parsin=
g successfull position behind parsed tex
+ *  @param[in]     cmd String to parse
+ *  @param[out]    arg Argument on the right side of '=3D'
+ *  @return        1 on success, 0 on error
+ */
+int arg_parse(char **in, char *cmd, char *arg, int arglen, int *err)
+{
+	char *pos =3D *in;
+	skip_blanks(&pos);
+	if (strncmp(pos, cmd, strlen(cmd)) =3D=3D 0) {
+		pos +=3D strlen(cmd);
+		skip_blanks(&pos);
+		if (*pos !=3D '=3D') {
+			*err =3D 1;
+			return 0;
+		}
+		pos++;
+		while (*pos && *pos !=3D ' ')
+			*arg++ =3D *pos++;
+		*arg =3D 0;
+		skip_blanks(&pos);
+		*in =3D pos;
+		CFLOG_TRACE(("arg_parse: Match '%s' Arg: '%s'\n", cmd, pos));
+		return 1;
+	}
+	return 0;
+}
+
+/** Parses a value pair on the format <CMD> =3D <int>
+ *  @param[in/out] in Pointer to where to start parsing, and if parsin=
g successfull position behind parsed tex
+ *  @param[in]     cmd
+ *  @param[out]    val Parsed integer value
+ *  @return        1 on success, 0 on error
+ */
+int int_parse(char **in, char *cmd, int *val, int *err)
+{
+	char *pos =3D *in;
+	char arg[100];
+	if (arg_parse(&pos, cmd, arg, sizeof(arg), err)) {
+		sscanf(arg, "%d", val);
+		*in =3D pos;
+		CFLOG_TRACE(("int_parse: Match '%s' '%d'\n", cmd, *val));
+
+		return 1;
+	}
+	return 0;
+}
+
+/** Parses a value pair on the format <CMD> =3D <hex-string>
+ *  @param[in/out] in     Pointer to where to start parsing, and if pa=
rsing successfull position behind parsed tex
+ *  @param[in]     cmd    Integer to parse
+ *  @param[out]    tobuf  Parsed hex string
+ *  @param[in]     maxlen Max-len of the binary parsed hex string
+ *  @param[out]    buflen Length of the parsed hex sting (in bytes)
+ *  @return        1 on success, 0 on error
+ */
+
+int
+hex_parse(char **in, char *cmd, unsigned char *tobuf, int maxlen,
+	  int *buflen, int *err)
+{
+	char *pos =3D *in;
+	char tmp[3];
+	int start =3D maxlen - 1;
+	int val =3D 0;
+	int len =3D 0;
+	int i;
+	char hexstr[100];
+	unsigned char buf[256];
+	if (arg_parse(&pos, cmd, hexstr, sizeof(hexstr), err)) {
+
+		i =3D strlen(hexstr);
+		while (i > 0) {
+			tmp[0] =3D hexstr[i - 2];
+			tmp[1] =3D hexstr[i - 1];
+			tmp[2] =3D 0;
+			sscanf(tmp, "%x", &val);
+			buf[start--] =3D (unsigned char) (val & 0xff);
+			len++;
+			i -=3D 2;
+		}
+		*buflen =3D len;
+		for (i =3D 0; i < len; i++)
+			tobuf[i] =3D buf[maxlen - len + i];
+
+		*in =3D pos;
+		CFLOG_TRACE(("hex_parse: Match '%s' '%s'\n", cmd, tmp));
+		return 1;
+	}
+	return 0;
+}
+
+/** Parses a value pair on the format <CMD> =3D <token>
+ *  @param[in/out] in      Pointer to where to start parsing, and if p=
arsing successfull position behind parsed tex
+ *  @param[in]     cmd     Integer to parse
+ *  @param[out]    toktype Specify the class of tokens to be parsed
+ *  @param[in]     val     Specify the value (in enums) corresponding =
to a token
+ *  @return        1 on success, 0 on error
+ */
+
+int tok_parse(char **in, char *cmd, char *toktype, int *val, int *err)
+{
+	struct {
+		char *tok;
+		char *toktype;
+		int val;
+	} tokens[] =3D {
+		{
+		"LAT", "PHYPREF", CAIF_PHYPREF_LOW_LAT}, {
+		"BW", "PHYPREF", CAIF_PHYPREF_HIGH_BW}, {
+		"LOOP", "PHYPREF", _CAIF_PHYPREF_LOOP}, {
+		"LOW", "PRIO", CAIF_PRIO_LOW}, {
+		"NORM", "PRIO", CAIF_PRIO_NORMAL}, {
+		"HI", "PRIO", CAIF_PRIO_HIGH}, {
+		"AT", "CHTY", CAIF_CHTY_AT}, {
+		"DGM", "CHTY", CAIF_CHTY_DATAGRAM}, {
+		"DGMLOOP", "CHTY", CAIF_CHTY_DATAGRAM_LOOP}, {
+		"VIDEO", "CHTY", CAIF_CHTY_VIDEO}, {
+		"DEBUG", "CHTY", CAIF_CHTY_DEBUG}, {
+		"TRACE", "CHTY", CAIF_CHTY_DEBUG_TRACE}, {
+		"IDEBUG", "CHTY", CAIF_CHTY_DEBUG_INTERACT}, {
+		"RFM", "CHTY", CAIF_CHTY_RFM}, {
+		"UTIL", "CHTY", CAIF_CHTY_UTILITY}, {
+		"YES", "BOOL", 1}, {
+		"NO", "BOOL", 0}, {
+		"CHAR", "DEVTY", CAIF_DEV_CHR}, {
+		"NET", "DEVTY", CAIF_DEV_NET}, {
+
+		NULL, 0}
+	};
+
+	char tok[100];
+	char *pos =3D *in;
+
+	if (arg_parse(&pos, cmd, tok, sizeof(tok), err)) {
+		int i;
+		for (i =3D 0; tokens[i].tok !=3D NULL; i++) {
+			if (strcmp(tokens[i].toktype, toktype) =3D=3D 0
+			    && strcmp(tokens[i].tok, tok) =3D=3D 0) {
+
+				*val =3D tokens[i].val;
+				*in =3D pos;
+				CFLOG_TRACE(("tok_parse:"
+					     " Match '%s' '%s' (%s)->%d\n",
+					     cmd, tok, toktype, *val));
+				return 1;
+			}
+		}
+	}
+	return 0;
+}
+
+/** Parses a command string from user.
+ *  @param[in]     cmd     The command string to be parsed
+ *  @param[out]    action  The type of action of this string
+ *  @param[in]     param   The action parameters for this command
+ *  @return        0 on success, < 0 on error.
+ */
+int caif_cmd_parse(char *cmd, int *action, union caif_action *param)
+{
+
+	int err =3D 0;
+	char *pos =3D cmd;
+	int val;
+	int len;
+	unsigned char *u;
+	int phy_specified =3D 0;
+	memset(param, 0, sizeof(*param));
+	if (cmd_parse(&pos, "HELP", &err))
+		return 0;
+
+	if (cmd_parse(&pos, "DELETE", &err)) {
+		struct caif_device_name *cf =3D &param->delete_channel;
+		*action =3D CAIF_IOC_REMOVE_DEVICE;
+
+		CFLOG_TRACE(("DELETE -  pos=3D'%s'\n", pos));
+
+		if (arg_parse(&pos, "NAME", cf->name, sizeof(cf->name), &err)) {
+			CFLOG_TRACE(("NAME - arg=3D'%s' pos=3D'%s'\n", cf->name,
+				     pos));
+
+		} else {
+			CFLOG_TRACE(("Parse Error for DELETE: '%s'\n", pos));
+			return -1;
+		}
+
+		if (tok_parse(&pos, "DEVTYPE", "DEVTY", &val, &err)) {
+			cf->devtype =3D val;
+			CFLOG_TRACE(("DEVTYPE - arg=3D'%d' pos=3D'%s'\n", val,
+				     pos));
+
+		} else {
+			CFLOG_TRACE(("DEVTYPE REQUIRED\n"));
+			return -1;
+		}
+
+
+		if (strlen(pos) > 0) {
+			CFLOG_TRACE(("Could not parse string '%s'\n", pos));
+			return -1;
+		}
+	} else if (cmd_parse(&pos, "CREATE", &err)) {
+		struct caif_channel_create_action *cf =3D &param->create_channel;
+		*action =3D CAIF_IOC_CONFIG_DEVICE;
+		CFLOG_TRACE(("CREATE -  pos=3D'%s'\n", pos));
+
+
+		if (tok_parse(&pos, "TYPE", "CHTY", &val, &err)) {
+			cf->config.type =3D val;
+			CFLOG_TRACE(("TYPE - arg=3D'%d' pos=3D'%s'\n", val, pos));
+
+		} else {
+			CFLOG_TRACE(("TYPE REQUIRED\n"));
+			return -1;
+		}
+
+		if (arg_parse
+		    (&pos, "NAME", cf->name.name, sizeof(cf->name.name),
+		     &err)) {
+			CFLOG_TRACE(("NAME - arg=3D'%s' pos=3D'%s'\n",
+				     cf->name.name, pos));
+
+		} else {
+			CFLOG_TRACE(("NAME REQUIRED\n"));
+			return -1;
+		}
+
+		if (tok_parse(&pos, "DEVTYPE", "DEVTY", &val, &err)) {
+			cf->name.devtype =3D val;
+			CFLOG_TRACE(("DEVTYPE - arg=3D'%d' pos=3D'%s'\n", val,
+				     pos));
+
+		} else {
+			CFLOG_TRACE(("DEVTYPE REQUIRED\n"));
+			return -1;
+		}
+
+
+		if (arg_parse(&pos, "PHYNAME", cf->config.phy_name,
+			      sizeof(cf->config.phy_name), &err)) {
+			phy_specified =3D 1;
+			CFLOG_TRACE(("PHYNAME - arg=3D'%s' pos=3D'%s'\n",
+				     cf->config.phy_name, pos));
+
+		}
+		if (tok_parse(&pos, "PHYPREF", "PHYPREF", &val, &err)) {
+			cf->config.phy_pref =3D val;
+			phy_specified =3D 1;
+			CFLOG_TRACE(("NAME - val=3D'%d' pos=3D'%s'\n", val, pos));
+
+		}
+
+		if (!phy_specified) {
+			CFLOG_TRACE(("PHYNAME or PHYPREF REQUIRED\n"));
+			return -1;
+		}
+
+		if (tok_parse(&pos, "PRIO", "PRIO", &val, &err)) {
+			cf->config.priority =3D val;
+			CFLOG_TRACE(("PRIO - val=3D'%d' pos=3D'%s'\n", val, pos));
+
+		}
+		if (cf->config.type =3D=3D CAIF_CHTY_DATAGRAM
+		    && int_parse(&pos, "CONNID", &val, &err)) {
+			cf->config.u.dgm.connection_id =3D val;
+			CFLOG_TRACE(("CONNID - val=3D'%d' pos=3D'%s'\n", val,
+				     pos));
+
+		}
+		if (cf->config.type =3D=3D CAIF_CHTY_RFM
+		    && int_parse(&pos, "CONNID", &val, &err)) {
+			cf->config.u.rfm.connection_id =3D val;
+			CFLOG_TRACE(("CONNID - val=3D%d pos=3D'%s'\n", val, pos));
+
+		}
+		if (cf->config.type =3D=3D CAIF_CHTY_RFM
+		    && arg_parse(&pos, "VOLUME", cf->config.u.rfm.volume,
+				 sizeof(cf->config.u.rfm.volume), &err)) {
+			cf->config.u.rfm.connection_id =3D val;
+			CFLOG_TRACE(("VOLUME - arg=3D'%s' pos=3D'%s'\n",
+				     cf->config.u.rfm.volume, pos));
+
+		}
+		if (cf->config.type =3D=3D CAIF_CHTY_UTILITY
+		    && arg_parse(&pos, "SOCK", cf->config.u.utility.name,
+				 sizeof(cf->config.u.utility.name), &err)) {
+			cf->config.u.rfm.connection_id =3D val;
+			CFLOG_TRACE(("SOCK - arg=3D'%s' pos=3D'%s'\n",
+				     cf->config.u.utility.name, pos));
+
+		}
+
+		if (cf->config.type =3D=3D CAIF_CHTY_UTILITY
+		    && hex_parse(&pos, "PARAM",
+				 cf->config.u.utility.params,
+				 sizeof(cf->config.u.utility.params), &len,
+				 &err)) {
+			cf->config.u.utility.paramlen =3D len;
+			u =3D cf->config.u.utility.params;
+			CFLOG_TRACE(("PARAM %02x,%02x,%02x,%02x-  pos=3D'%s'\n",
+				     u[0], u[1], u[2], u[3], pos));
+
+		}
+
+		if (strlen(pos) > 0) {
+			CFLOG_TRACE(("Could not parse string '%s'\n", pos));
+			return -1;
+		}
+
+	} else {
+		CFLOG_TRACE(("UNRECOGNIZED COMMAND '%s'\n", pos));
+		return -1;
+	}
+	return 0;
+
+}
diff --git a/Documentation/CAIF/chardevconfig/caif_cmd_parse.h b/Docume=
ntation/CAIF/chardevconfig/caif_cmd_parse.h
new file mode 100644
index 0000000..d27227f
--- /dev/null
+++ b/Documentation/CAIF/chardevconfig/caif_cmd_parse.h
@@ -0,0 +1,22 @@
+/*
+ *      Copyright (C) ST-Ericsson AB 2009
+ *
+ *      Author: Daniel Martensson / Daniel.Martensson@stericsson.com
+ *
+ *      License terms: GNU General Public License (GPL), version 2.
+ *
+ */
+
+
+
+
+
+#ifndef CAIF_CMD_PARSE_H_
+#define CAIF_CMD_PARSE_H_
+
+#include "caif_config.h"
+#include "caif_ioctl.h"
+
+int caif_cmd_parse(char *cmd, int *action, union caif_action *param);
+
+#endif
diff --git a/Documentation/CAIF/chardevconfig/chardevconfig.c b/Documen=
tation/CAIF/chardevconfig/chardevconfig.c
new file mode 100644
index 0000000..2aee860
--- /dev/null
+++ b/Documentation/CAIF/chardevconfig/chardevconfig.c
@@ -0,0 +1,110 @@
+/*
+ *      Copyright (C) ST-Ericsson AB 2009
+ *
+ *      Author: Per Sigmond / Per.Sigmond@stericsson.com
+ *
+ *      License terms: GNU General Public License (GPL), version 2.
+ *
+ */
+#include <stdlib.h>
+#include <stdio.h>
+#include <errno.h>
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <fcntl.h>
+#include <string.h>
+#include <unistd.h>
+#include <sys/ioctl.h>
+#include <ctype.h>
+#include <caif_ioctl.h>
+#include "caif_cmd_parse.h"
+
+
+#define BUFFERLENGTH 512
+
+
+void usage(char *argv0)
+{
+	fprintf(stderr, "Usage: %s device configfile\n", argv0);
+	fprintf(stderr, "Usage: %s device -\n", argv0);
+}
+
+int main(int argc, char *argv[])
+{
+
+	int fd;
+	FILE *configfile;
+	char *config_devname;
+	union caif_action param;
+	int request;
+	int ret;
+	char *cmd;
+	int bytes_read;
+
+	if (argc < 3) {
+		usage(argv[0]);
+		exit(-1);
+	}
+	config_devname =3D argv[1];
+
+	if (!strncmp(argv[2], "-", 1)) {
+		/* stdin */
+		configfile =3D stdin;
+	} else {
+		configfile =3D fopen(argv[2], "r");
+	}
+	if (configfile =3D=3D NULL) {
+		fprintf(stderr, "fopen %s: %s\n", argv[2], strerror(errno));
+		exit(-1);
+	}
+
+	cmd =3D malloc(BUFFERLENGTH);
+	if (cmd =3D=3D NULL) {
+		fprintf(stderr, "malloc error: %s\n", strerror(errno));
+		exit(-1);
+	}
+
+	while (fgets(cmd, BUFFERLENGTH, configfile) !=3D NULL) {
+
+		bytes_read =3D strlen(cmd);
+		while (isspace(cmd[bytes_read - 1])) {
+			cmd[bytes_read - 1] =3D 0;
+			bytes_read--;
+		}
+
+		ret =3D caif_cmd_parse(cmd, &request, &param);
+
+		if (ret !=3D 0) {
+			fprintf(stderr, "'%s'\n", cmd);
+			fprintf(stderr, "Error parsing config string.\n");
+			continue;
+		}
+
+		fd =3D open(config_devname, O_RDWR);
+		if (fd < 0) {
+			fprintf(stderr, "open %s: %s\n", config_devname,
+				strerror(errno));
+			exit(-1);
+		}
+
+		if (ioctl(fd, request, &param) < 0) {
+			fprintf(stderr, "'%s'\n", cmd);
+			fprintf(stderr, "ioctl: %s\n", strerror(errno));
+		}
+		close(fd);
+
+		if (request =3D=3D CAIF_IOC_CONFIG_DEVICE) {
+			printf
+			    ("Create device: name =3D %s, "
+			     "major =3D %d, minor =3D %d\n",
+			     param.create_channel.name.name,
+			     param.create_channel.major,
+			     param.create_channel.minor);
+		}
+	}
+
+	fclose(configfile);
+	free(cmd);
+
+	return 0;
+}
diff --git a/Documentation/CAIF/chardevconfig/create_devices.config b/D=
ocumentation/CAIF/chardevconfig/create_devices.config
new file mode 100644
index 0000000..374ac19
--- /dev/null
+++ b/Documentation/CAIF/chardevconfig/create_devices.config
@@ -0,0 +1 @@
+CREATE TYPE=3DAT NAME=3Dchnlat1 DEVTYPE=3DCHAR PHYPREF=3DLAT PRIO=3DHI
diff --git a/Documentation/CAIF/chardevconfig/delete_devices.config b/D=
ocumentation/CAIF/chardevconfig/delete_devices.config
new file mode 100644
index 0000000..e057a85
--- /dev/null
+++ b/Documentation/CAIF/chardevconfig/delete_devices.config
@@ -0,0 +1 @@
+DELETE NAME=3Dchnlat1 DEVTYPE=3DCHAR
diff --git a/Documentation/CAIF/ldiscd/README b/Documentation/CAIF/ldis=
cd/README
new file mode 100644
index 0000000..6936225
--- /dev/null
+++ b/Documentation/CAIF/ldiscd/README
@@ -0,0 +1,12 @@
+Building the line discipline:
+
+Open a shell and cd to the caif/app/ldiscd directory:
+
+First set the environment variables:
+$ source  ~/android-repo/build/envsetup.sh
+
+Set the Android TOP directory (~/android-repo on my machine):
+$ export TOP=3D~/android-repo
+
+Now build (the output will end up in: ~/android-repo/out/target/produc=
t/generic/system/bin/ldiscd)
+$ mm
diff --git a/Documentation/CAIF/ldiscd/ldiscd.c b/Documentation/CAIF/ld=
iscd/ldiscd.c
new file mode 100644
index 0000000..9e3483d
--- /dev/null
+++ b/Documentation/CAIF/ldiscd/ldiscd.c
@@ -0,0 +1,123 @@
+/*
+ *	Copyright (C) ST-Ericsson AB 2009
+ *
+ *	Author: Daniel Martensson / Daniel.Martensson@stericsson.com
+ *
+ *	License terms: GNU General Public License (GPL), version 2.
+ *
+ */
+
+
+
+
+
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <fcntl.h>
+#include <errno.h>
+#include <unistd.h>
+#include <syslog.h>
+#include <string.h>
+#include <termios.h>
+#include <asm/ioctls.h>
+
+#define CAIF_LDISC_TTY	"/dev/ttyS0"
+
+int main(void)
+{
+
+	/* Our process ID and Session ID */
+	pid_t pid, sid;
+
+	/* Termios structure for UART configuration. */
+	struct termios tio;
+
+	/* File handle to the tty device node */
+	int fd;
+
+	/* Result */
+	int result;
+
+	/* Line discipline number to use (N_MOUSE) */
+	int ldiscnr =3D 2;
+
+	/* Fork off the parent process */
+	pid =3D fork();
+	if (pid < 0)
+		exit(EXIT_FAILURE);
+
+	/* If we got a good PID, then
+	   we can exit the parent process. */
+	if (pid > 0)
+		exit(EXIT_SUCCESS);
+
+
+	/* Change the file mode mask */
+	umask(0);
+
+	/* Open any logs here */
+
+	/* Create a new SID for the child process */
+	sid =3D setsid();
+	if (sid < 0)
+		/* Log the failure */
+		exit(EXIT_FAILURE);
+
+
+	/* Change the current working directory */
+	if ((chdir("/")) < 0)
+		/* Log the failure */
+		exit(EXIT_FAILURE);
+
+
+	/* Close out the standard file descriptors */
+	close(STDIN_FILENO);
+	close(STDOUT_FILENO);
+	close(STDERR_FILENO);
+
+	/* Daemon-specific initialization goes here */
+
+	/* Open the tty device node */
+	fd =3D open(CAIF_LDISC_TTY, O_RDWR);
+	if (fd < 0) {
+		/* Log the failure */
+		exit(EXIT_FAILURE);
+	}
+
+	/* Configure UART settings. */
+	memset(&tio, 0, sizeof(tio));
+
+	/* 115200 baud, 8n1, CTS/RTS flow control. */
+	tio.c_cflag =3D B115200 | CRTSCTS | CS8 | CLOCAL | CREAD;
+
+	/* Flush TTY and set new termios. */
+	result =3D tcflush(fd, TCIOFLUSH);
+	if (result)
+		/* Log the failure */
+		exit(EXIT_FAILURE);
+
+
+	result =3D tcsetattr(fd, TCSANOW, &tio);
+	if (result)
+		/* Log the failure */
+		exit(EXIT_FAILURE);
+
+
+	/* Change line discipline for the tty device and keep it open */
+	result =3D ioctl(fd, TIOCSETD, &ldiscnr);
+	if (result < 0)
+		/* Log the failure */
+		exit(EXIT_FAILURE);
+
+
+	/* The Big Loop */
+	while (1)
+		sleep(0x7FFFFFFF);
+
+
+	close(fd);
+
+	exit(EXIT_SUCCESS);
+}
diff --git a/Documentation/DocBook/caif.tmpl b/Documentation/DocBook/ca=
if.tmpl
new file mode 100644
index 0000000..23ba098
--- /dev/null
+++ b/Documentation/DocBook/caif.tmpl
@@ -0,0 +1,238 @@
+<?xml version=3D"1.0" encoding=3D"UTF-8"?>
+<!DOCTYPEbook PUBLIC "-//OASIS//DTD DocBook XML V4.1.2//EN"
+	"http://www.oasis-open.org/docbook/xml/4.1.2/docbookx.dtd"[]>
+
+<book id=3D"GuidtoCAIF">
+<bookinfo>
+<title>CAIF Programming Guide</title>
+
+<authorgroup>
+<author>
+<firstname>Sjur</firstname>
+<surname>Brendeland/</surname>
+<affiliation>
+<address>
+<email>sjur.brandeland@stericsson.com</email>
+</address>
+</affiliation>
+</author>
+</authorgroup>
+
+<copyright>
+<year>2009</year>
+<holder>ST-Ericsson AB</holder>
+</copyright>
+
+<legalnotice>
+<para>
+This documentation is free software; you can redistribute
+it and/or modify it under the terms of the GNU General Public
+License as published by the Free Software Foundation; either
+version 2 of the License, or (at your option) any later
+version.
+</para>
+
+<para>
+This program is distributed in the hope that it will be
+useful, but WITHOUT ANY WARRANTY; without even the implied
+warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
+See the GNU General Public License for more details.
+</para>
+
+<para>
+You should have received a copy of the GNU General Public
+License along with this program; if not, write to the Free
+Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
+MA 02111-1307 USA
+</para>
+
+<para>
+For more details see the file COPYING in the source
+distribution of Linux.
+</para>
+</legalnotice>
+</bookinfo>
+
+<toc></toc>
+
+<chapter id=3D"intro">
+<title>Introduction</title>
+<para>
+
+
+ !!!!!!! WARNING this document is a work in progrss and is not
+ !!!!!!! complete or accurate at this point in time
+
+
+CAIF is a MUX protocol used by ST-Ericsson cellular modems for
+communication
+between Modem and host. The host processes can open virtual AT
+channels, initiate GPRS Data connections, Video channels and
+Utility Channels.
+The Utility Channels are general purpose pipes between modem
+and host.
+
+ST-Ericsson modems support a number of transports between modem
+and host,
+currently Uart and Shared Memory are available for Linux.
+
+</para>
+
+ <sect1 id=3D"architecture">
+            <title>Architecture</title>
+<para>
+The Implementation of CAIF is divided into:
+<itemizedlist>
+  <listitem> CAIF Drivers: Character Device, Net Device and Kernel API=
=2E</listitem>
+  <listitem>CAIF Generic Protocol Implementation</listitem>
+  <listitem>CAIF Link Layer</listitem>
+</itemizedlist>
+</para>
+<para>
+CAIF is using IOCTLs to manage the CAIF Drivers.
+<programlisting>
+  IOCTL
+   !
+   !     +------+   +------+   +------+
+   !    +------+!  +------+!  +------+!
+   !    ! Char !!  !Kernel!!  ! Net  !!
+   !    ! Dev  !+  ! API  !+  ! Dev  !+   <- CAIF Drivers
+   !    +------+   +------!   +------+
+   !       !          !          !
+   !       +----------!----------+
+   !               +------+               <- CAIF Protocol Implementat=
ion
+   +------->       ! CAIF !                  /dev/caifconfig
+                   +------+
+             +--------!--------+
+             !                 !
+          +------+          +-----+
+          !ShMem !          ! TTY !       <- Link Layer
+          +------+          +-----+
+</programlisting>
+</para>
+</sect1>
+
+
+</chapter>
+
+<chapter id=3D"bugs">
+<title>Known Bugs And Assumptions</title>
+<para>
+<variablelist>
+
+<varlistentry><term>CAIF is minimal</term>
+<listitem>
+<para>
+	Thecurrent CAIF implementation is very basic
+</para>
+</listitem></varlistentry>
+
+<varlistentry><term>Quirks</term>
+<listitem>
+<para>
+	listquirks here
+</para>
+</listitem></varlistentry>
+</variablelist>
+
+</para>
+</chapter>
+
+<chapter id=3D"config">
+<title>Public Functions Provided</title>
+
+  <para>
+   caif_config.h
+   This file defines the types needed for channel configuration.
+   The CAIF Channel configuration is held in the structure \ref
+   caif_channel_config .
+   The configured character devices will be visible in /dev/caifXXXX.
+  </para>
+
+
+    <para>
+      Example AT channel configuration
+      <programlisting>
+struct caif_channel_config at_config =3D {
+	.channel	=3D CAIF_CHTY_AT,
+	.phy_ref	=3D CAIF_PHYPREF_LOW_LAT,
+	.priority	=3D CAIF_PRIO_HIGH
+};
+      </programlisting>
+      </para>
+
+      <para>
+        Example Datagram channel configuration
+	<programlisting>
+struct caif_channel_config dgm_config =3D {
+	.channel		=3D CAIF_CHTY_DATAGRAM,
+	.phy_ref		=3D CAIF_PHYPREF_HIGH_BW,
+	.priority		=3D CAIF_PRIO_NORMAL,
+	.u.dgm.connection_id	=3D my_connection_id
+};
+		</programlisting>
+		</para>
+
+		<para>
+		Example RFM channel configuration
+		<programlisting>
+struct caif_channel_config rfm_config =3D {
+	.channel		=3D CAIF_CHTY_RFM,
+	.phy_ref		=3D CAIF_PHYPREF_LOW_LAT,
+	.priority 		=3D CAIF_PRIO_HIGH,
+	.u.rfm.connection_id 	=3D my_connection_id,
+	.u.rfm.name 		=3D "/rfm"
+};
+		</programlisting>
+		</para>
+
+		<para>
+		Example Utility channel configuration
+		<programlisting>
+struct caif_channel_config rfm_config =3D {
+	.channel		=3D CAIF_CHTY_UTILITY,
+	.phy_ref		=3D CAIF_PHYPREF_LOW_LAT,
+	.priority		=3D CAIF_PRIO_HIGH,
+	.u.utility.name		=3D "PSOCK_TEST_PROC",
+	.u.utility.params	=3D {0x01},
+	.u.utility.paramlen	=3D 1,
+	.u.utility.fifosize_kb	=3D 0,Architecture:
+------------
+The Implementation of CAIF is divided into:
+* CAIF Drivers: Character Device, Net Device and Kernel API.
+* CAIF Generic Protocol Implementation
+* CAIF Link Layer
+
+CAIF is using IOCTLs to manage the CAIF Drivers.
+
+
+  IOCTL
+   !
+   !     +------+   +------+   +------+
+   !    +------+!  +------+!  +------+!
+   !    ! Char !!  !Kernel!!  ! Net  !!
+   !    ! Dev  !+  ! API  !+  ! Dev  !+   <- CAIF Drivers
+   !    +------+   +------!   +------+
+   !       !          !          !
+   !       +----------!----------+
+   !               +------+               <- CAIF Protocol Implementat=
ion
+   +------->       ! CAIF !                  /dev/caifconfig
+                   +------+
+             +--------!--------+
+             !                 !
+          +------+          +-----+
+          !ShMem !          ! TTY !       <- Link Layer
+          +------+          +-----+
+
+	.u.utility.fifosize_bufs=3D 0
+};
+		</programlisting>
+		</para>
+
+!Iinclude/linux/caif/caif_config.h
+!Enet/caif/caif_chnlif.c
+
+</chapter>
+
+
+</book>
--=20
1.6.0.4

