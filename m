From: sjur.brandeland@stericsson.com
Subject: [RFC PATCH v3  7/8] CAIF Protocol Stack
Date: Mon, 30 Nov 2009 16:00:51 +0100
Message-ID: <1259593252-2493-8-git-send-email-sjur.brandeland@stericsson.com>
References: <1259593252-2493-1-git-send-email-sjur.brandeland@stericsson.com>
 <1259593252-2493-2-git-send-email-sjur.brandeland@stericsson.com>
 <1259593252-2493-3-git-send-email-sjur.brandeland@stericsson.com>
 <1259593252-2493-4-git-send-email-sjur.brandeland@stericsson.com>
 <1259593252-2493-5-git-send-email-sjur.brandeland@stericsson.com>
 <1259593252-2493-6-git-send-email-sjur.brandeland@stericsson.com>
 <1259593252-2493-7-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: randy.dunlap@oracle.com, kim.xx.lilliestierna@stericsson.com,
	christian.bejram@stericsson.com, daniel.martensson@stericsson.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, stefano.babic@babic.homelinux.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bgo1smout1.broadpark.no ([217.13.4.94]:55205 "EHLO
	bgo1smout1.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752778AbZK3QBz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 11:01:55 -0500
Received: from bgo1sminn1.broadpark.no ([217.13.4.93])
 by bgo1smout1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KTX0016VGF4KF20@bgo1smout1.broadpark.no> for
 netdev@vger.kernel.org; Mon, 30 Nov 2009 16:01:52 +0100 (CET)
Received: from localhost.localdomain ([84.49.68.131])
 by bgo1sminn1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KTX00IAMGDW9QV1@bgo1sminn1.broadpark.no> for
 netdev@vger.kernel.org; Mon, 30 Nov 2009 16:01:52 +0100 (CET)
In-reply-to: <1259593252-2493-7-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 Documentation/CAIF/Linux-CAIF.txt    |  263 +++++++++++++++++++++++
 Documentation/CAIF/README            |   33 +++
 Documentation/CAIF/caif.man          |  387 ++++++++++++++++++++++++++++++++++
 Documentation/CAIF/caifioc/caifioc.c |   45 ++++
 4 files changed, 728 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/CAIF/Linux-CAIF.txt
 create mode 100644 Documentation/CAIF/README
 create mode 100644 Documentation/CAIF/caif.man
 create mode 100644 Documentation/CAIF/caifioc/caifioc.c

diff --git a/Documentation/CAIF/Linux-CAIF.txt b/Documentation/CAIF/Linux-CAIF.txt
new file mode 100644
index 0000000..91c058f
--- /dev/null
+++ b/Documentation/CAIF/Linux-CAIF.txt
@@ -0,0 +1,263 @@
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
+and host. Currently, UART and Loopback are available for Linux.
+
+
+Architecture:
+------------
+The implementation of CAIF is divided into:
+* CAIF Socket Layer, Kernel API, and  Net Device.
+* CAIF Generic Protocol Implementation
+* CAIF Link Layer, implemented as NET devices.
+
+
+  RTNL/IOCTL
+   !
+   !	 +------+   +------+   +------+
+   !	+------+!  +------+!  +------+!
+   !	! Sock !!  !Kernel!!  ! Net  !!
+   !	! API  !+  ! API  !+  ! Dev  !+	  <- CAIF Client APIs
+   !	+------+   +------!   +------+
+   !	   !	      !		 !
+   !	   +----------!----------+
+   !		   +------+		  <- CAIF Protocol Implementation
+   +------->	   ! CAIF !
+		   +------+
+	     +--------!--------+
+	     !		       !
+	  +------+	    +-----+
+	  !Loop	 !	    ! TTY !	  <- Link Layer (Net Devices)
+	  +------+	    +-----+
+
+
+Using CAIF (IP) Net Device
+----------------------
+CAIF Net device can be created by use of Socket IOCTLs,
+or RT Netlink.
+
+  static struct ifcaif_param param = {
+    .ipv4_connid = 1,
+    .loop = 0
+  };
+  static struct ifreq ifr = {
+    .ifr_name = "caif%d",
+    .ifr_ifru.ifru_data = &param
+
+  };
+  s = socket(AF_CAIF,SOCK_SEQPACKET,CAIFPROTO_AT);
+  ioctl(s,SIOCCAIFNETNEW,&ifr);
+
+
+Using the Kernel API
+----------------------
+The Kernel API is used for accessing CAIF channels from the
+kernel.
+The user of the API has to implement two callbacks for receive
+and control.
+The receive callback gives a CAIF packet as a SKB. The control
+callback will
+notify of channel initialization complete, and flow-on/flow-
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
+  caif_add_device(&caif_dev);
+  caif_transmit(&caif_dev, skb);
+
+See the caif_kernel.h for details about the CAIF kernel API.
+
+
+I M P L E M E N T A T I O N
+===========================
+===========================
+
+GenCAIF - The Generic CAIF Protocol Layer
+=========================================
+
+GenCaif is a generic CAIF protocol implementation. It implements the CAIF
+protocol as defined by ST-Ericsson.
+GenCaif implements the CAIF protocol stack in a layered approach, where
+each layer described in the specification is implemented as a separate layer.
+The architecture is inspired by the design patterns "Protocol Layer" and
+"Protocol Packet".
+
+== CAIF structure ==
+
+The goal is to have CAIF as system independent as possible.
+All CAIF code (GenCAIF) can be found under net/caif/generic and
+include/net/caif/generic.
+The actual linux module implementation is under drivers/net/caif.
+There is also a user space program (that is not up to date) to run the stack in
+user space for testing.
+
+GenCAIF is:
+      -	Simple implementation of CAIF.
+      -	Layered architecture (a la Streams), each layer in the CAIF
+	specification is implemented in a separate c-file.
+      -	Client of GenCaif must implement PHY layer to access physical HW
+	with receive and transmit functions.
+      -	Client of GenCaif must call configuration function to add PHY layer.
+      -	Client of GenCaif must implement adaptation layer to consume/produce
+	CAIF payload with receive and transmit functions.
+      -	Client of GenCaif  must call configuration function to add adaptation
+	layer.
+      - When receiving / transmitting CAIF Packets (cfpkt), ownership is passed
+	to the called function (except for framing layers' receive functions
+	or if a transmit function returns an error, in which case the caller
+	must free the packet).
+
+Layered Architecture
+--------------------
+The CAIF protocol can be divided into two parts: Support functions and Protocol
+Implementation. The support functions include:
+
+      - CFPKT CAIF Packet. Implementation of CAIF Protocol Packet. The
+	CAIF Packet has functions for creating, destroying and adding content
+	and for adding/extracting header and trailers to protocol packets.
+
+      - CFLST CAIF list implementation.
+
+      - CFGLUE CAIF Glue. Contains OS Specifics, such as memory
+	allocation, endianness, etc.
+
+The CAIF Protocol implementation contains:
+
+      - CFCNFG CAIF Configuration layer. Configures the CAIF Protocol
+	Stack and has a Client interface for adding Link-Layer and
+	Driver interfaces on top of the CAIF Stack.
+
+      - CFCTRL CAIF Control layer. Encodes and Decodes control messages
+	such as enumeration and channel setup. Also matches request and
+	response messages.
+
+      - CFSERVL General CAIF Service Layer functionality; handles flow
+	control and remote shutdown requests.
+
+      - CFVEI CAIF VEI layer. Handles CAIF VEI layer (AT-Channel),
+	encodes/decodes VEI frames.
+
+      - CFDGML CAIF Data-gram layer. Handles CAIF Data-gram layer(IP
+	traffic), encodes/decodes Datagram frames.
+
+      - CFMUX CAIF Mux layer. Handles multiplexing between multiple
+	physical bearers and multiple channels such as VEI, Datagram, etc.
+	The MUX keeps track of the existing CAIF Channels and
+	Physical Instances and selects the apropriate instance based
+	on Channel-Id and Physical-ID.
+
+      - CFFRML CAIF Framing layer. Handles Framing i.e. Frame length
+	and frame checksum.
+
+      - CFSERL CAIF Serial layer. Handles concatenation/split of frames
+	into CAIF Frames with correct length.
+
+
+
+		    +---------+
+		    | Config  |
+		    | CFCNFG  |
+		    +---------+
+			 !
+    +---------+	    +---------+	    +---------+
+    |	AT    |	    | Control |	    | Datagram|
+    | CFVEIL  |	    | CFCTRL  |	    | CFDGML  |
+    +---------+	    +---------+	    +---------+
+	   \_____________!______________/
+			 !
+		    +---------+
+		    |	MUX   |
+		    |	      |
+		    +---------+
+		    _____!_____
+		   /	       \
+	    +---------+	    +---------+
+	    | CFFRML  |	    | CFFRML  |
+	    | Framing |	    | Framing |
+	    +---------+	    +---------+
+		 !		!
+	    +---------+	    +---------+
+	    | Loopback|	    | Serial  |
+	    |         |	    | CFSERL  |
+	    +---------+	    +---------+
+
+
+In this layered approach the following "rules" applies.
+      - All layers embedd the same structure "struct layer"
+      - A layer does not depend on any other layer's private data.
+      - Layers are stacked by setting the pointers
+		  layer->up , layer->dn
+      -	In order to send data upwards, each layer should do
+		 layer->up->receive(layer->up, packet);
+      - In order to send data downwards, each layer should do
+		 layer->dn->transmit(layer->dn, packet);
+
+
+Linux Driver Implementation
+===========================
+
+Linux GPRS Net Device and Character Devices are implemented on top of the
+Generic CAIF protocol. The Net device and Chr device have an instance of
+'struct layer', just like the generic caif protocol stack.
+Net and Chr devices implement the 'receive()' function defined by
+'struct layer', just like the rest of the CAIF stack. In this way, transmit and
+receive of packets is handled as by the rest of the layers: the 'dn->transmit()'
+function is called in order to transmit data.
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
+command for creation is received that contains information about
+the CAIF Channel type to be created and the type of device to instantiate
+(Net Device or Character Device).
+
+The Net Device and Character Device will register with the 'caifconfig'
+device by calling 'caif_register_netdev' and 'caif_register_chrdev'.
+When registered, the 'caifconfig' module will keep function pointers
+to the devices used when IOCTL creates new devices.
+
+The CAIF Configuration module CFCNFG is responsible for connecting and
+setting up the entire CAIF stack.
+
+The function 'cfcnfg_add_adapt_layer' is used to connect a Linux Driver
+to the ST-Ericsson modem. This function will trigger the setup of a CAIF
+Channel by sending a "LinkSetup" message to the modem. When the
+"LinkSetupResponse" is received, the CAIF protocol for the requested
+CAIF Service will be set up.
+
+The CAIF Channel configuration parameters will be given as input.
+
+
+Configuration of Link Layer
+---------------------------
+The Link Layer is implemented as Linux net devices (struct net_device).
+Payload handling and registration is done using standard Linux mecanisms.
+
+The CAIF Protocol relies on a los-less link layer without implementing
+retransmission. This implies that packet drops must not happend.
+Therefor a flow-control mecanism is implemented where the physical
+interface can initiate flow stop for all CAIF Channels.
diff --git a/Documentation/CAIF/README b/Documentation/CAIF/README
new file mode 100644
index 0000000..ef1d51f
--- /dev/null
+++ b/Documentation/CAIF/README
@@ -0,0 +1,33 @@
+copyright (C) ST-Ericsson AB 2009
+Author: Sjur Brendeland/ sjur.brandeland@stericsson.com
+        Kim Lilliestierna Kim.xx.Lilliestierna@ericsson.com
+License terms: GNU General Public License (GPL) version 2
+
+=== Start ===
+Copy the .ko files onto the board, and do insmod:
+
+insmod caif.ko
+insmod caif_loop.ko
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
+There are some things that need to be tweaked to get the host TTY
+correctly set up to talk to the modem.
+Since the CAIF stack is running in the kernel and we want to use the existing
+TTY, we are installing our physical serial driver as a line discipline above
+the TTY device. The TTY device used to communicate to modem must be specified
+as a module parameter to caif_ser.
+If the modem is using Start-of-frame-extension (STX) this must also be set as
+module parameter.
+
+$ insmod caif_ser.ko ser_ttyname=/dev/ttyS0 ser_use_stx=yes
diff --git a/Documentation/CAIF/caif.man b/Documentation/CAIF/caif.man
new file mode 100644
index 0000000..e411bde
--- /dev/null
+++ b/Documentation/CAIF/caif.man
@@ -0,0 +1,387 @@
+.TH  caif 7  "November, 2009" "version 0.1" "ST Ericsson"
+.SH NAME
+CAIF \- CAIF protocol family
+.SH SYNOPSIS
+.nf
+.B #include <sys/socket.h>
+.B #include <caif/caif_socket.h>
+.fi
+.SH DESCRIPTION
+CAIF socket implements the standard Linux networking
+.BR socket (7)
+mechanism for communicating with a ST-Ericsson modem using the CAIF protocol.
+
+The programming interface is BSD socket compatible.
+
+A CAIF socket is created by calling the
+.BR socket (2)
+function as
+.BR socket(PF_CAIF ,
+.IR socket_type ,
+.IB protocol ).
+
+Using
+.I socket_type
+.B SOCK_SEQPACKET
+will provide a reliable CAIF connection. The valid values for
+.I protocols
+are
+.B CAIFPROTO_AT, CAIFPROTO_DATAGRAM, CAIFPROTO_UTIL, CAIFPROTO_RFM.
+When a client wants to open a CAIF connection it must call
+.BR connect (2).
+CAIF socket supports
+.BR getsockopt (2),
+.BR setsockopt (2),
+.BR poll (2),
+.BR select (2),
+.BR ioctrl (2),
+.BR read (2),
+.BR write (2),
+.BR recv (2),
+.BR send (2),
+.BR recvmsg (2),
+.BR sendmsg (2).
+
+.SH LIMITATIONS
+.BR listen (2),
+.BR accept (2),
+.BR bind (2)
+are not supported because CAIF socket only can initiate connections,
+but not accept connections.
+
+The error code
+.B EMSGSIZE
+is returned by the functions
+.BR read (2),
+.BR recv (2),
+.BR recvmsg (2)
+if the provided buffer is too small to hold the received CAIF message.
+The length can be retrived by using socket option
+.BR CAIFSO_PACKET_LEN .
+
+.B EMSGSIZE
+is returned for
+.BR write (2),
+.BR send (2),
+.BR sendmsg (2)
+if trying to send a message larger than
+.BR CAIF_MAX_PACKET_SIZE .
+
+.SH OVERVIEW
+In order to use CAIF socket the function
+.BR socket (2)
+must be called initially.
+Then optionally socket operations
+can be set with
+.BR setsockopt (2),
+if no socket options are set default
+values will be used. Relevant options are
+.BR CAIFSO_CHANNEL_CONFIG,
+and for
+the utility protocol the socket option
+.BR CAIFSO_REQ_PARAM .
+
+The
+.BR connect (2)
+will send a CAIF channel connect request to the modem.
+In blocking mode connect will also wait for the response from the modem.
+The CAIF channel connect request is build based on the arguments to
+.BR socket (2),
+.BR setsockopt(2),
+and
+.BR connect (2).
+
+After a successfull connect, information about the CAIF Connection
+can be read by using getsockopt. Relevant options for getsockopt are
+.B CAIFSO_CONN_ID
+to read the unique CAIF channel ID.
+For a CAIF utility link
+.RB ( CAIFPROTO_UTIL )
+.B CAIFSO_RSP_PARAM
+can be used to read response parameters.
+
+After a successfull connect, CAIF packets can be sent with
+.BR send (2),
+.BR sendmsg (2),
+.BR recvmsg (2),
+and read with
+.BR read (2),
+.BR recv (2),
+.BR recvmsg (2).
+
+.SH ADDRESS FORMAT
+CAIF is a connection oriented protocol where the address is used to specify
+a modem service.
+.I family
+must always be set to
+.BR AF_CAIF .
+CAIF addressing is dependent of the protocol specified in the initial
+.BR socket (2)
+call. The union
+.I u
+is used according to this.
+
+.nf
+struct sockaddr_caif {
+	sa_family_t  family;
+	union {
+		struct {
+			u_int8_t type; 	/* type: enum caif_at_type */
+		}at;				/* CAIFPROTO_AT */
+		union {
+			u_int32_t connection_id;
+			u_int8_t  nsapi;
+		} dgm;				/* CAIFPROTO_DATAGRAM */
+		struct {
+			char service[16];
+		} util;				/* CAIFPROTO_UTIL */
+		struct {
+			u_int32_t connection_id;
+			char      volume[16];
+		} rfm;				/* CAIFPROTO_RFM */
+	} u;
+};
+.fi
+
+.SH PROTOCOL TYPES
+.TP
+.B CAIFPROTO_AT
+Specifies an AT channel type.
+.B caif_at_type
+enum value
+.B CAIF_ATTYPE_PLAIN (0)
+is the only enpoint type supported.
+
+.TP
+.B CAIFPROTO_RFM
+Specifies a RFM channel type.
+.I connection_id
+and
+.I volume[16]
+must be supplied.
+.TP
+.B CAIFPROTO_UTIL
+Specifies a utility channel type that will connect to a utility service.
+.I service[16]
+identifies the remote process implementing the service.
+.TP
+.B CAIFPROTO_DATAGRAM
+Specifies a datagram channel type.
+.I connection_id
+specifies the PDP context connection ID.
+.I nsapi
+is future functionality.
+.TP
+.B CAIFPROTO_DATAGRAM_LOOP
+Specifies a datagram loopback channel type (packet reflector).
+This only to be used for test purposes.
+
+.SH SOCKET OPTIONS
+CAIF supports some protocol specific socket options that can be set with
+.BR setsockopt (2)
+and read with
+.BR getsockopt (2).
+The
+.I level
+parameter to
+.BR setsockopt (2)
+or
+.BR getsockopt (2)
+must be one of the supported protocols defined by the
+.B CAIFPROTO_*
+enum.
+
+.TP
+.B CAIFSO_CHANNEL_CONFIG
+When connecting a CAIF socket, the address given in sockaddr_caif is not
+the only parameters in the
+actual CAIF connect message. It also contains priority on the connection
+and specification of which physical link to use for the connection.
+If this options is not set default values will be used for the connection.
+
+.nf
+struct caif_channel_opt {
+        u_int16_t  priority;
+        u_int16_t  link_selector;
+        char       link_name[16];
+};
+.fi
+The structure
+.B caif_channel_opt
+is used for the socket option
+.B CAIFSO_CHANNEL_CONFIG.
+When setting up a CAIF connection the socket option can be used to specify the
+priority and the physical link to use for the specific connection.
+.I priority
+is a number between 0 and 31 where 0 is the lowest priority of the channel.
+If
+.I link_name[16]
+is specified, the connection will use the specified physical link.
+Otherwise
+.I link_selector
+should be set to
+.B CAIF_LINK_LOW_LATENCY
+for low latency connections and
+.B CAIF_LINK_HIGH_BANDW
+for high bandwitdh connections.
+.TP
+.B CAIFSO_REQ_PARAM
+Connections of type
+.B CAIFPROTO_UTIL
+supply request parameters which optionally can be sent to the modem in
+the connect request.
+
+.nf
+struct caif_param {
+        u_int16_t size;
+        u_int8_t  data[256];
+};
+.fi
+.I size
+and
+.I data
+specifies the request parameter lenght and value.
+.TP
+.B CAIFSO_RSP_PARAM
+Connections of type
+.B CAIFPROTO_UTIL
+may supply response parameters in the connect response.
+The response is returned in struct
+.IR caif_param .
+.TP
+.B CAIFSO_CONN_ID
+Every open connection has a unique CAIF connection ID.
+This is assigned by the modem and is unique for every CAIF connection in the system.
+This socket option allows connection ID (u_int32_t) to be read after a successfull connect.
+.TP
+.B CAIFSO_PACKET_LEN
+The packet length can be read using the socket option
+.BR CAIFSO_PACKET_LEN .
+The type is u_int32_t.
+
+.SH ERROR CODES
+.TP
+.B [ENOTSUP]
+Generally used when using unsupported functionality in the CAIF socket layer.
+.TP
+.B [EINVAL]
+Invalid argument passed.
+.TP
+.B [EPIPE]
+Connection is closed.
+.TP
+.B [EAGAIN]
+Only valid for non-blocking sockets.
+Operation would either block or a receive timeout had been
+set and the timeout expired before any data were received.
+E.g. used for send operations when CAIF channel is in state FLOW-OFF.
+.TP
+.B [EMSGSIZE]
+Sending
+.RB ( write (2),
+.BR send (2),
+.BR sendmsg (2))
+fails with this error code if the message length is less than or equal to 0 or greater than maximum CAIF packet size.
+
+Receiving
+.RB ( read (2),
+.BR recv (2),
+.BR recvmsg (2))
+fails with this error code if the CAIF packet size is larger than the provided buffer.
+
+.TP
+.B [EBADF]
+ The argument socket is an invalid descriptor.
+.TP
+.B [EFAULT]
+ The receive buffer pointer(s) points outside the address space of the process.
+.TP
+.B [EINTR]
+ The receive was interrupted by delivery of a signal
+ before any data were available.
+.TP
+.B [ENOBUFS]
+The CAIF link layer cannot send packets due to full packet queues or
+flow stop. This may indicate that the link layer has stopped sending,
+but may be caused by transient congestion.
+.TP
+.B [ENOTCONN]
+ The CAIF socket is not connected (see
+.BR connect (2)).
+.TP
+.B [ENOTSOCK]
+ The argument socket does not refer to a socket.
+.TP
+.B [EOPNOTSUPP]
+ The type and/or protocol of the socket does not support the option(s) specified in the flags.
+.TP
+.B [ENOMEM]
+ Insufficient memory is available.
+
+
+.SH EXAMPLES (1)
+.nf
+  ...
+  struct sockaddr_caif addr = {
+    .family = AF_CAIF,
+    .u.at.type = CAIF_ATTYPE_PLAIN
+  };
+  /* Create a CAIF socket for AT Service */
+  s = socket(AF_CAIF, SOCK_SEQPACKET, CAIFPROTO_AT);
+
+  /* Connect to the AT Service at the modem */
+  connect(s, (struct sockaddr *) &addr, sizeof(addr));
+  ...
+.fi
+
+.SH EXAMPLES (2)
+
+.nf
+ struct sockaddr_caif addr = {
+    .family = AF_CAIF,
+    .u.util.service = "psock_test",
+  };
+  struct caif_channel_opt conf = {
+    .priority = 10,
+    .link_selector = CAIF_LINK_HIGH_BANDW,
+  };
+  struct caif_param rsp,req = {
+    .size = 1,
+    .data = {1}
+  };
+  u_int32_t connid;
+
+  /* Create a CAIF socket for Utility Service */
+  s = socket(PF_CAIF, SOCK_SEQPACKET, CAIFPROTO_UTIL);
+
+  /* Set the Channel Options */
+  setsockopt(s, SOL_CAIF, CAIFSO_CHANNEL, &conf, sizeof(conf));
+
+  /* Set the Request Parameters on the Utility Link */
+  setsockopt(s, SOL_CAIF, CAIFSO_REQ_PARAM, &req, sizeof(req));
+
+  /* Connect to the Utility Service */
+  connect(s, (struct sockaddr *) &addr, sizeof(addr));
+
+  /* Read out Parameter Responses and CAIF Connection ID */
+  len = sizeof(rsp);
+  getsockopt(s, SOL_CAIF, CAIFSO_RSP_PARAM, &rsp, &len);
+  len = sizeof(connid);
+  getsockopt(s, SOL_CAIF, CAIFSO_CONN_ID, &connid, &len);
+.fi
+.PP
+.SH AUTHOR
+Sjur Brandeland <sjur.brandeland@stericsson.com>
+.SH COPYRIGHT
+Copyright (C) ST-Ericsson AB 2009
+.SH SEE ALSO
+.BR socket (2),
+.BR connect (2),
+.BR setsockopt (2),
+.BR getsockopt (2),
+.BR read (2),
+.BR write (2),
+.BR recv (2),
+.BR recvmsg (2),
+.BR send (2),
+.BR sendmsg (2)
diff --git a/Documentation/CAIF/caifioc/caifioc.c b/Documentation/CAIF/caifioc/caifioc.c
new file mode 100644
index 0000000..5d6dbda
--- /dev/null
+++ b/Documentation/CAIF/caifioc/caifioc.c
@@ -0,0 +1,45 @@
+#include <sys/types.h>
+#include <sys/socket.h>
+#include <net/if.h>
+#include <sys/ioctl.h>
+#include <linux/caif/caif_socket.h>
+#include <linux/caif/if_caif.h>
+#include <stdio.h>
+#include <string.h>
+
+/*
+ * Example program creating and configuring CAIF IP Interface
+ * by use of IOCTLs.
+ */
+main()
+{
+  int s;
+  int r;
+
+  /* Set CAIF IP Inteface config parameters */
+  static struct ifcaif_param param = {
+    .ipv4_connid = 1,
+    .loop = 1
+
+  };
+
+  /* Populate ifreq parameters */
+  static struct ifreq ifr = {
+    .ifr_name = "caifioc%d",
+    .ifr_ifru.ifru_data = (void *) &param
+
+  };
+
+  /* Create a CAIF socket */
+  s = socket(AF_CAIF, SOCK_SEQPACKET, CAIFPROTO_AT);
+
+  /* Create new IP Interface */
+  r = ioctl(s, SIOCCAIFNETNEW, &ifr);
+  printf("Result=%d\n", r);
+
+  /* General Interface IOC are available, e.g. find ifindex */
+  strcpy(ifr.ifr_name, "caifioc0");
+  r = ioctl(s, SIOCGIFINDEX, &ifr);
+
+  printf("res=%d, ifindex=%d\n", r, ifr.ifr_ifindex);
+}
-- 
1.6.2.2.1669.g7eaf8

