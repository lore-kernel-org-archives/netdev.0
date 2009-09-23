From: sjur.brandeland@stericsson.com
Subject: [PATCH 7/8] [RFC] CAIF Protocol Stack
Date: Wed, 23 Sep 2009 19:31:36 +0200
Message-ID: <1253727096-10413-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: Kim.xx.Lilliestierna@ericsson.com, sjur.brandeland@stericsson.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bgo1smout1.broadpark.no ([217.13.4.94]:55556 "EHLO
	bgo1smout1.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753225AbZIWSbo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2009 14:31:44 -0400
Received: from bgo1sminn1.broadpark.no ([217.13.4.93])
 by bgo1smout1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KQF003SIQ0TF560@bgo1smout1.broadpark.no> for
 netdev@vger.kernel.org; Wed, 23 Sep 2009 19:31:41 +0200 (CEST)
Received: from localhost.localdomain ([84.49.68.131])
 by bgo1sminn1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KQF00K9IQ0P6861@bgo1sminn1.broadpark.no> for
 netdev@vger.kernel.org; Wed, 23 Sep 2009 19:31:41 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kim Lilliestierna <Kim.xx.Lilliestierna@ericsson.com>

Signed-off-by: sjur.brandeland@stericsson.com

---
 Documentation/CAIF/Linux-CAIF.txt                  |  319 +++++++++++++++++
 Documentation/CAIF/README                          |   60 ++++
 Documentation/CAIF/chardevconfig/Makefile          |   11 +
 Documentation/CAIF/chardevconfig/README            |   39 ++
 Documentation/CAIF/chardevconfig/caif_cmd_parse.c  |  365 ++++++++++++++++++++
 Documentation/CAIF/chardevconfig/chardevconfig.c   |  111 ++++++
 .../CAIF/chardevconfig/create_devices.config       |   12 +
 .../CAIF/chardevconfig/delete_devices.config       |   12 +
 Documentation/CAIF/ldiscd/ldiscd.c                 |  123 +++++++
 9 files changed, 1052 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/CAIF/Linux-CAIF.txt
 create mode 100644 Documentation/CAIF/README
 create mode 100644 Documentation/CAIF/chardevconfig/Makefile
 create mode 100644 Documentation/CAIF/chardevconfig/README
 create mode 100644 Documentation/CAIF/chardevconfig/caif_cmd_parse.c
 create mode 100644 Documentation/CAIF/chardevconfig/chardevconfig.c
 create mode 100644 Documentation/CAIF/chardevconfig/create_devices.config
 create mode 100644 Documentation/CAIF/chardevconfig/delete_devices.config
 create mode 100644 Documentation/CAIF/ldiscd/ldiscd.c

diff --git a/Documentation/CAIF/Linux-CAIF.txt b/Documentation/CAIF/Linux-CAIF.txt
new file mode 100644
index 0000000..42fd66e
--- /dev/null
+++ b/Documentation/CAIF/Linux-CAIF.txt
@@ -0,0 +1,319 @@
+Linux CAIF
+===========
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
+   !               +------+               <- CAIF Protocol Implementation
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
+   struct caif_channel_create_action at = {
+	.name = {
+	   .name = "cnhlatl",
+	   .type = CAIF_DEV_CHR
+        },
+	.config = {
+	    .channel = CAIF_CHTY_AT,
+	 }};
+   fd = open("/dev/caifconfig",..);
+   ioctl(fd, CAIF_IOC_CONFIG_DEVICE,&at_config);
+
+A configuration tool chardevconfig exist in order to simplify
+creation of CAIF Channels (typically used from init scripts).
+E.g:
+
+   $chardevconfig /dev/caifconfig -
+   CREATE TYPE=AT NAME=chnlat1 DEVTYPE=CHAR ^D
+
+This will result in creation of the device node "/dev/chnlat1".
+"/dev/chnlat1" can be used to read and write AT commands and
+responses
+from the modem:
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
+   CREATE TYPE=DGM NAME=caif0 DEVTYPE=NET CONNID=1 ^D
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
+  struct caif_device caif_dev = {
+    .caif_config = {
+     .name = "MYDEV"
+     .type = CAIF_CHTY_AT
+    }
+   .receive_cb = my_receive,
+   .control_cb = my_control,
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
+===========================
+===========================
+
+
+
+
+GenCAIF - The Generic CAIF Protocol Layer
+=========================================
+
+
+GenCaif is a generic CAIF protocol implementation. It implements the CAIF
+protocol as specified in "CAIF Protocol Specification" (155 19-CRH 109 913).
+GenCaif implements the CAIF protocol stack in a layered approach, where
+each layer described in the specification is implemented as a separate layer.
+The architecture is inspired by the design patterns "Protocol Layer" and
+"Protocol Packet".
+
+== CAIF structure ==
+
+The goal is to have caif as system independent as possible.
+All caif code can be found under GenCaif/src and GenCaif/inc.
+The actual linux module implementation is under src/kernel.
+There is also a user space program that is not up to date to run the stack in
+user space for testing.
+
+We have tested the kernel implementation on the emulator with a modem and we
+are able to enumerate and make a link setup.
+
+GenCAIF is:
+      -	Simple implementation of CAIF.
+      -	Layered architecture (ala Streams), each layer specified CAIF
+        specification is implemented in a separate c-file.
+      -	Client of GenCaif must implement PHY layer to access physical HW
+	with receive and transmit functions.
+      -	Client of GenCaif must call configuration function add PHY layer.
+      -	Client of GenCaif must implement adaptation layer to consume/produce
+        CAIF payload with receive and transmit functions.
+      -	Client of GenCaif  must call configuration function add adaptation
+        layer.
+      - When receiving / transmitting CAIF Packets (cfpkt) ownership is passed
+        to the called function (except Framinglayer's receive function).
+
+
+
+Layered Architecture
+--------------------
+The CAIF protocol can be divided into two parts Support functions and Protocol
+Implementation. The support functions include:
+
+      - CFPKT CAIF Packet. Implementation of CAIF Protocol Packet. The
+        CAIF Packet has functions for creating,destroying, adding content, and
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
+      - CFCTRL CAIF Control layer. Encodes and Decodes control messages
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
+        physical bearers and multiple channels such as VEI, Data-gram etc
+	The MUX is keeping track of the existing CAIF Channels and
+	Physical Instances and selects the apropriate instance based
+	on Channel-Id and Physical-ID.
+
+      - CFFRML CAIF Framing layer. Handles Framing i.e. Frame length
+        and frame checksum.
+
+      - CFSERL CAIF Serial layer. Handles concatenation/split of frames
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
+===========================
+
+Linux GPRS Net Device and Character Devices are implemented on top of the
+Generic CAIF protocol. The Net device and Chr device has an instance of
+'struct layer' as the generic caif protocol stack.
+Net and Chr device implements the 'receive()' function defined by
+'struct layer' as the rest of the CAIF stack. In this way transmit and
+reception of packets is handled as the rest of the layers, 'dn->transmit()'
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
+the CAIF Channel type to be created and the type of device to instanciate
+(Net Device or Character Device).
+
+The Net Device and Character Device will register into the 'caifconfig'
+device by calling 'caif_register_netdev' and 'caif_register_chrdev'.
+When registered the 'caifconfig' module will keep function pointers
+to the devices used when IOCTL creates new devices.
+
+
+The CAIF Configuration module CFCNFG is responsible for connecting and
+setting up the entire CAIF stack.
+
+The function 'cfcnfg_add_adapt_layer' is used to connect a Linux Driver
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
+defined by 'struct layer' in order to send payload. When data is received
+the Link Layer calls 'up->receive()'.
+Configuring the link layer is done by the function 'cfcnfg_add_phy_layer'.
+This function will set up the CAIF Layers for the new Link Layer.
+
+
+The physical Link Layers registers intself into 'caifconfig' by
+calling the function 'caif_phy_register()'.
diff --git a/Documentation/CAIF/README b/Documentation/CAIF/README
new file mode 100644
index 0000000..aa04150
--- /dev/null
+++ b/Documentation/CAIF/README
@@ -0,0 +1,60 @@
+copyright (C) ST-Ericsson AB 2009
+Author: Sjur Brendeland/ sjur.brandeland@stericsson.com
+        Kim Lilliestierna Kim.xx.Lilliestierna@ericsson.com
+License terms: GNU General Public License (GPL), version 2.
+
+=== Start ===
+Copy the .ko files onto the board, and do insmod:
+
+insmod caif.ko
+insmod phyif_msl.ko
+insmod chnl_chr.ko
+insmod chnl_net.ko
+ifconfig caif0 <your-home-address> up
+
+
+=== Test Loopback on net device ===
+insmod chnl_net.ko loop=yes
+ifconfig caif0 192.168.0.1 up
+ping -c 10 -s 1000 192.168.0.2
+
+=== Preparing the setup.===
+
+Make sure that the kernel is built with module support.
+
+There are some things that need to be
+tweaked to get the host TTY correctly setup to talk to the modem.
+Since the CAIF stack is running in the kernel and we want to use the existing
+TTY we are installing our physical serial driver as a line discipline above
+the TTY device.
+
+To achieve this we need the help of a daemon program called ldiscd.
+The benefit is that we can hook up to any TTY, the downside is that we need
+an extra operation in order to install the line discipline.
+
+Getting the host TTY to behave (This should only be necessary when running
+on the emulator, otherwise the ldiscd should correctly configure the UART).
+
+Retrieve the current settings:
+
+$ stty -a -F /dev/ttyUSB1
+
+Make sure that we are having 115200, 8n1, CTS/RTS (for example if CTS/RTS is missing):
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
+Install the VEI channel (this will enumerate and do the linksetup of the first VEI channel. If this goes well you should see /dev/chn*) (There are printks logging all buffers that can be checked with dmesg):
+$ modprobe chnl_chr
+
+The AT (VEI) channel is ready to use (you can now send AT commands on it):
+$ echo -e "AT\r\n" > /dev/chnlat10
+
+Verify that you got an OK response (There are printks logging all buffers that can be checked with dmesg):
+$ cat /dev/chnlat10
diff --git a/Documentation/CAIF/chardevconfig/Makefile b/Documentation/CAIF/chardevconfig/Makefile
new file mode 100644
index 0000000..5bd7d90
--- /dev/null
+++ b/Documentation/CAIF/chardevconfig/Makefile
@@ -0,0 +1,11 @@
+CFLAGS=-g -Wall -I ../../../include -I../../../include/linux/caif
+
+PROGS=chardevconfig
+OBJS=chardevconfig.o caif_cmd_parse.o
+all: $(PROGS)
+
+chardevconfig: chardevconfig.o caif_cmd_parse.o
+	$(CC) $(CFLAGS) -o chardevconfig $(OBJS)
+
+clean:
+	rm -f $(PROGS) $(OBJS)
diff --git a/Documentation/CAIF/chardevconfig/README b/Documentation/CAIF/chardevconfig/README
new file mode 100644
index 0000000..bc7013b
--- /dev/null
+++ b/Documentation/CAIF/chardevconfig/README
@@ -0,0 +1,39 @@
+Usage: chardevconfig configdevice configfile
+Usage: chardevconfig configdevice -
+
+The program will read commands from the configfile (or stdin), parse them and
+do ioctl calls to the configdevice. One command per line. Lines with syntax
+errors (e.g. starting with a #) will be skipped.
+
+Examples:
+
+CREATE TYPE=AT NAME=chnlat10 DEVTYPE=CHAR PHYPREF=LAT PRIO=HI
+CREATE TYPE=AT NAME=chnlat11 DEVTYPE=CHAR PHYPREF=LAT PRIO=HI
+CREATE TYPE=AT NAME=chnlat12 DEVTYPE=CHAR PHYPREF=LAT PRIO=HI
+CREATE TYPE=AT NAME=chnlat13 DEVTYPE=CHAR PHYPREF=LAT PRIO=HI
+
+CREATE TYPE=RFM NAME=chn_rfm DEVTYPE=CHAR PHYPREF=BW CONNID=1 VOLUME=rfm
+CREATE TYPE=RFM NAME=chn_afs DEVTYPE=CHAR PHYPREF=BW CONNID=1 VOLUME=/afs
+CREATE TYPE=RFM NAME=chn_ifs DEVTYPE=CHAR PHYPREF=BW CONNID=1 VOLUME=/ifs
+CREATE TYPE=RFM NAME=chn_sys DEVTYPE=CHAR PHYPREF=BW CONNID=1 VOLUME=/sys"
+
+CREATE TYPE=UTIL NAME=chn_psocktest DEVTYPE=CHAR PHYPREF=LAT SOCK=CAIF_PSOC_TEST PARAM=01
+
+CREATE TYPE=DGM NAME=chn_datagram DEVTYPE=CHAR PHYPREF=BW CONNID=1
+CREATE TYPE=DGM NAME=datagram_raw_ip DEVTYPE=CHAR PHYPREF=BW CONNID=1
+
+CREATE TYPE=DGMLOOP NAME=datagram_loop DEVTYPE=CHAR PHYPREF=BW
+
+
+DELETE NAME=chnlat10 DEVTYPE=CHAR
+DELETE NAME=chnlat11 DEVTYPE=CHAR
+DELETE NAME=chnlat12 DEVTYPE=CHAR
+DELETE NAME=chnlat13 DEVTYPE=CHAR
+DELETE NAME=chn_rfm DEVTYPE=CHAR
+DELETE NAME=chn_afs DEVTYPE=CHAR
+DELETE NAME=chn_ifs DEVTYPE=CHAR
+DELETE NAME=chn_sys DEVTYPE=CHAR
+DELETE NAME=chn_psocktest DEVTYPE=CHAR
+DELETE NAME=chn_datagram DEVTYPE=CHAR
+DELETE NAME=datagram_loop DEVTYPE=CHAR
+DELETE NAME=datagram_raw_ip DEVTYPE=CHAR
diff --git a/Documentation/CAIF/chardevconfig/caif_cmd_parse.c b/Documentation/CAIF/chardevconfig/caif_cmd_parse.c
new file mode 100644
index 0000000..a52ded0
--- /dev/null
+++ b/Documentation/CAIF/chardevconfig/caif_cmd_parse.c
@@ -0,0 +1,365 @@
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
+#include <sys/ioctl.h>
+#include <caif_config.h>
+#include <caif_ioctl.h>
+
+
+#define CFLOG_TRACE(a)
+
+
+/** Strips of blanks */
+void skip_blanks(char **c)
+{
+	while (**c == ' ')
+		(*c)++;
+
+}
+
+/** Parses the specified command.
+ *  @param[in/out] in Pointer to where to start parsing, and if parsing successfull position behind parsed tex
+ *  @param[in]     cmd String to parse
+ *  @return        1 on success, 0 on error
+ */
+int cmd_parse(char **in, char *cmd, int *err)
+{
+
+	char *pos = *in;
+	skip_blanks(&pos);
+	if (strncmp(pos, cmd, strlen(cmd)) == 0) {
+		pos += strlen(cmd);
+		skip_blanks(&pos);
+		*in = pos;
+		CFLOG_TRACE(("arg_parse: Match '%s'\n", cmd));
+
+		return 1;
+	}
+	return 0;
+}
+
+/** Parses a value pair on the format <CMD> = <arg>
+ *  @param[in/out] in Pointer to where to start parsing, and if parsing successfull position behind parsed tex
+ *  @param[in]     cmd String to parse
+ *  @param[out]    arg Argument on the right side of '='
+ *  @return        1 on success, 0 on error
+ */
+int arg_parse(char **in, char *cmd, char *arg, int arglen, int *err)
+{
+	char *pos = *in;
+	skip_blanks(&pos);
+	if (strncmp(pos, cmd, strlen(cmd)) == 0) {
+		pos += strlen(cmd);
+		skip_blanks(&pos);
+		if (*pos != '=') {
+			*err = 1;
+			return 0;
+		}
+		pos++;
+		while (*pos && *pos != ' ')
+			*arg++ = *pos++;
+		*arg = 0;
+		skip_blanks(&pos);
+		*in = pos;
+		CFLOG_TRACE(("arg_parse: Match '%s' Arg: '%s'\n", cmd, pos));
+		return 1;
+	}
+	return 0;
+}
+
+/** Parses a value pair on the format <CMD> = <int>
+ *  @param[in/out] in Pointer to where to start parsing, and if parsing successfull position behind parsed tex
+ *  @param[in]     cmd
+ *  @param[out]    val Parsed integer value
+ *  @return        1 on success, 0 on error
+ */
+int int_parse(char **in, char *cmd, int *val, int *err)
+{
+	char *pos = *in;
+	char arg[100];
+	if (arg_parse(&pos, cmd, arg, sizeof(arg), err)) {
+		sscanf(arg, "%d", val);
+		*in = pos;
+		CFLOG_TRACE(("int_parse: Match '%s' '%d'\n", cmd, *val));
+
+		return 1;
+	}
+	return 0;
+}
+
+/** Parses a value pair on the format <CMD> = <hex-string>
+ *  @param[in/out] in     Pointer to where to start parsing, and if parsing successfull position behind parsed tex
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
+	char *pos = *in;
+	char tmp[3];
+	int start = maxlen - 1;
+	int val = 0;
+	int len = 0;
+	int i;
+	char hexstr[100];
+	unsigned char buf[256];
+	if (arg_parse(&pos, cmd, hexstr, sizeof(hexstr), err)) {
+
+		i = strlen(hexstr);
+		while (i > 0) {
+			tmp[0] = hexstr[i - 2];
+			tmp[1] = hexstr[i - 1];
+			tmp[2] = 0;
+			sscanf(tmp, "%x", &val);
+			buf[start--] = (unsigned char) (val & 0xff);
+			len++;
+			i -= 2;
+		}
+		*buflen = len;
+		for (i = 0; i < len; i++)
+			tobuf[i] = buf[maxlen - len + i];
+
+		*in = pos;
+		CFLOG_TRACE(("hex_parse: Match '%s' '%s'\n", cmd, tmp));
+		return 1;
+	}
+	return 0;
+}
+
+/** Parses a value pair on the format <CMD> = <token>
+ *  @param[in/out] in      Pointer to where to start parsing, and if parsing successfull position behind parsed tex
+ *  @param[in]     cmd     Integer to parse
+ *  @param[out]    toktype Specify the class of tokens to be parsed
+ *  @param[in]     val     Specify the value (in enums) corresponding to a token
+ *  @return        1 on success, 0 on error
+ */
+
+int tok_parse(char **in, char *cmd, char *toktype, int *val, int *err)
+{
+	struct {
+		char *tok;
+		char *toktype;
+		int val;
+	} tokens[] = {
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
+	char *pos = *in;
+
+	if (arg_parse(&pos, cmd, tok, sizeof(tok), err)) {
+		int i;
+		for (i = 0; tokens[i].tok != NULL; i++) {
+			if (strcmp(tokens[i].toktype, toktype) == 0
+			    && strcmp(tokens[i].tok, tok) == 0) {
+
+				*val = tokens[i].val;
+				*in = pos;
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
+	int err = 0;
+	char *pos = cmd;
+	int val;
+	int len;
+	unsigned char *u;
+	int phy_specified = 0;
+	memset(param, 0, sizeof(*param));
+	if (cmd_parse(&pos, "HELP", &err))
+		return 0;
+
+	if (cmd_parse(&pos, "DELETE", &err)) {
+		struct caif_device_name *cf = &param->delete_channel;
+		*action = CAIF_IOC_REMOVE_DEVICE;
+
+		CFLOG_TRACE(("DELETE -  pos='%s'\n", pos));
+
+		if (arg_parse(&pos, "NAME", cf->name, sizeof(cf->name), &err)) {
+			CFLOG_TRACE(("NAME - arg='%s' pos='%s'\n", cf->name,
+				     pos));
+
+		} else {
+			CFLOG_TRACE(("Parse Error for DELETE: '%s'\n", pos));
+			return -1;
+		}
+
+		if (tok_parse(&pos, "DEVTYPE", "DEVTY", &val, &err)) {
+			cf->devtype = val;
+			CFLOG_TRACE(("DEVTYPE - arg='%d' pos='%s'\n", val,
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
+		struct caif_channel_create_action *cf = &param->create_channel;
+		*action = CAIF_IOC_CONFIG_DEVICE;
+		CFLOG_TRACE(("CREATE -  pos='%s'\n", pos));
+
+
+		if (tok_parse(&pos, "TYPE", "CHTY", &val, &err)) {
+			cf->config.type = val;
+			CFLOG_TRACE(("TYPE - arg='%d' pos='%s'\n", val, pos));
+
+		} else {
+			CFLOG_TRACE(("TYPE REQUIRED\n"));
+			return -1;
+		}
+
+		if (arg_parse
+		    (&pos, "NAME", cf->name.name, sizeof(cf->name.name),
+		     &err)) {
+			CFLOG_TRACE(("NAME - arg='%s' pos='%s'\n",
+				     cf->name.name, pos));
+
+		} else {
+			CFLOG_TRACE(("NAME REQUIRED\n"));
+			return -1;
+		}
+
+		if (tok_parse(&pos, "DEVTYPE", "DEVTY", &val, &err)) {
+			cf->name.devtype = val;
+			CFLOG_TRACE(("DEVTYPE - arg='%d' pos='%s'\n", val,
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
+			phy_specified = 1;
+			CFLOG_TRACE(("PHYNAME - arg='%s' pos='%s'\n",
+				     cf->config.phy_name, pos));
+
+		}
+		if (tok_parse(&pos, "PHYPREF", "PHYPREF", &val, &err)) {
+			cf->config.phy_pref = val;
+			phy_specified = 1;
+			CFLOG_TRACE(("NAME - val='%d' pos='%s'\n", val, pos));
+
+		}
+
+		if (!phy_specified) {
+			CFLOG_TRACE(("PHYNAME or PHYPREF REQUIRED\n"));
+			return -1;
+		}
+
+		if (tok_parse(&pos, "PRIO", "PRIO", &val, &err)) {
+			cf->config.priority = val;
+			CFLOG_TRACE(("PRIO - val='%d' pos='%s'\n", val, pos));
+
+		}
+		if (cf->config.type == CAIF_CHTY_DATAGRAM
+		    && int_parse(&pos, "CONNID", &val, &err)) {
+			cf->config.u.dgm.connection_id = val;
+			CFLOG_TRACE(("CONNID - val='%d' pos='%s'\n", val,
+				     pos));
+
+		}
+		if (cf->config.type == CAIF_CHTY_RFM
+		    && int_parse(&pos, "CONNID", &val, &err)) {
+			cf->config.u.rfm.connection_id = val;
+			CFLOG_TRACE(("CONNID - val=%d pos='%s'\n", val, pos));
+
+		}
+		if (cf->config.type == CAIF_CHTY_RFM
+		    && arg_parse(&pos, "VOLUME", cf->config.u.rfm.volume,
+				 sizeof(cf->config.u.rfm.volume), &err)) {
+			cf->config.u.rfm.connection_id = val;
+			CFLOG_TRACE(("VOLUME - arg='%s' pos='%s'\n",
+				     cf->config.u.rfm.volume, pos));
+
+		}
+		if (cf->config.type == CAIF_CHTY_UTILITY
+		    && arg_parse(&pos, "SOCK", cf->config.u.utility.name,
+				 sizeof(cf->config.u.utility.name), &err)) {
+			cf->config.u.rfm.connection_id = val;
+			CFLOG_TRACE(("SOCK - arg='%s' pos='%s'\n",
+				     cf->config.u.utility.name, pos));
+
+		}
+
+		if (cf->config.type == CAIF_CHTY_UTILITY
+		    && hex_parse(&pos, "PARAM",
+				 cf->config.u.utility.params,
+				 sizeof(cf->config.u.utility.params), &len,
+				 &err)) {
+			cf->config.u.utility.paramlen = len;
+			u = cf->config.u.utility.params;
+			CFLOG_TRACE(("PARAM %02x,%02x,%02x,%02x-  pos='%s'\n",
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
diff --git a/Documentation/CAIF/chardevconfig/chardevconfig.c b/Documentation/CAIF/chardevconfig/chardevconfig.c
new file mode 100644
index 0000000..cb09b0d
--- /dev/null
+++ b/Documentation/CAIF/chardevconfig/chardevconfig.c
@@ -0,0 +1,111 @@
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
+
+
+#define BUFFERLENGTH 512
+
+
+int caif_cmd_parse(char *cmd, int *action, union caif_action *param);
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
+	config_devname = argv[1];
+
+	if (!strncmp(argv[2], "-", 1)) {
+		/* stdin */
+		configfile = stdin;
+	} else {
+		configfile = fopen(argv[2], "r");
+	}
+	if (configfile == NULL) {
+		fprintf(stderr, "fopen %s: %s\n", argv[2], strerror(errno));
+		exit(-1);
+	}
+
+	cmd = malloc(BUFFERLENGTH);
+	if (cmd == NULL) {
+		fprintf(stderr, "malloc error: %s\n", strerror(errno));
+		exit(-1);
+	}
+
+	while (fgets(cmd, BUFFERLENGTH, configfile) != NULL) {
+
+		bytes_read = strlen(cmd);
+		while (isspace(cmd[bytes_read - 1])) {
+			cmd[bytes_read - 1] = 0;
+			bytes_read--;
+		}
+
+		ret = caif_cmd_parse(cmd, &request, &param);
+
+		if (ret != 0) {
+			fprintf(stderr, "'%s'\n", cmd);
+			fprintf(stderr, "Error parsing config string.\n");
+			continue;
+		}
+
+		fd = open(config_devname, O_RDWR);
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
+		if (request == CAIF_IOC_CONFIG_DEVICE) {
+			printf
+			    ("Create device: name = %s, "
+			     "major = %d, minor = %d\n",
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
diff --git a/Documentation/CAIF/chardevconfig/create_devices.config b/Documentation/CAIF/chardevconfig/create_devices.config
new file mode 100644
index 0000000..645ba8d
--- /dev/null
+++ b/Documentation/CAIF/chardevconfig/create_devices.config
@@ -0,0 +1,12 @@
+CREATE TYPE=AT NAME=chnlat10 DEVTYPE=CHAR PHYPREF=LAT PRIO=HI
+CREATE TYPE=AT NAME=chnlat11 DEVTYPE=CHAR PHYPREF=LAT PRIO=HI
+CREATE TYPE=AT NAME=chnlat12 DEVTYPE=CHAR PHYPREF=LAT PRIO=HI
+CREATE TYPE=AT NAME=chnlat13 DEVTYPE=CHAR PHYPREF=LAT PRIO=HI
+CREATE TYPE=RFM NAME=chn_rfm DEVTYPE=CHAR PHYPREF=BW CONNID=1 VOLUME=rfm
+CREATE TYPE=RFM NAME=chn_afs DEVTYPE=CHAR PHYPREF=BW CONNID=1 VOLUME=/afs
+CREATE TYPE=RFM NAME=chn_ifs DEVTYPE=CHAR PHYPREF=BW CONNID=1 VOLUME=/ifs
+CREATE TYPE=RFM NAME=chn_sys DEVTYPE=CHAR PHYPREF=BW CONNID=1 VOLUME=/sys"
+CREATE TYPE=UTIL NAME=chn_psocktest DEVTYPE=CHAR PHYPREF=LAT SOCK=CAIF_PSOCK_TEST PARAM=01
+CREATE TYPE=DGM NAME=chn_datagram DEVTYPE=CHAR PHYPREF=BW CONNID=1
+CREATE TYPE=DGMLOOP NAME=datagram_loop DEVTYPE=CHAR PHYPREF=BW
+CREATE TYPE=DGM NAME=datagram_raw_ip DEVTYPE=CHAR PHYPREF=BW CONNID=1
diff --git a/Documentation/CAIF/chardevconfig/delete_devices.config b/Documentation/CAIF/chardevconfig/delete_devices.config
new file mode 100644
index 0000000..220c40a
--- /dev/null
+++ b/Documentation/CAIF/chardevconfig/delete_devices.config
@@ -0,0 +1,12 @@
+DELETE NAME=chnlat10 DEVTYPE=CHAR
+DELETE NAME=chnlat11 DEVTYPE=CHAR
+DELETE NAME=chnlat12 DEVTYPE=CHAR
+DELETE NAME=chnlat13 DEVTYPE=CHAR
+DELETE NAME=chn_rfm DEVTYPE=CHAR
+DELETE NAME=chn_afs DEVTYPE=CHAR
+DELETE NAME=chn_ifs DEVTYPE=CHAR
+DELETE NAME=chn_sys DEVTYPE=CHAR
+DELETE NAME=chn_psocktest DEVTYPE=CHAR
+DELETE NAME=chn_datagram DEVTYPE=CHAR
+DELETE NAME=datagram_loop DEVTYPE=CHAR
+DELETE NAME=datagram_raw_ip DEVTYPE=CHAR
diff --git a/Documentation/CAIF/ldiscd/ldiscd.c b/Documentation/CAIF/ldiscd/ldiscd.c
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
+	int ldiscnr = 2;
+
+	/* Fork off the parent process */
+	pid = fork();
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
+	sid = setsid();
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
+	fd = open(CAIF_LDISC_TTY, O_RDWR);
+	if (fd < 0) {
+		/* Log the failure */
+		exit(EXIT_FAILURE);
+	}
+
+	/* Configure UART settings. */
+	memset(&tio, 0, sizeof(tio));
+
+	/* 115200 baud, 8n1, CTS/RTS flow control. */
+	tio.c_cflag = B115200 | CRTSCTS | CS8 | CLOCAL | CREAD;
+
+	/* Flush TTY and set new termios. */
+	result = tcflush(fd, TCIOFLUSH);
+	if (result)
+		/* Log the failure */
+		exit(EXIT_FAILURE);
+
+
+	result = tcsetattr(fd, TCSANOW, &tio);
+	if (result)
+		/* Log the failure */
+		exit(EXIT_FAILURE);
+
+
+	/* Change line discipline for the tty device and keep it open */
+	result = ioctl(fd, TIOCSETD, &ldiscnr);
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
-- 
1.6.0.4

