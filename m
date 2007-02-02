From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: [PATCH 2/7] [S390]: Rewrite of the IUCV base code, part 2
Date: Fri, 2 Feb 2007 13:05:57 +0100
Message-ID: <20070202120557.GC10392@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:43716 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423031AbXBBMGu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Feb 2007 07:06:50 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l12C6mSp002235
	for <netdev@vger.kernel.org>; Fri, 2 Feb 2007 07:06:48 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l12C6mSM305474
	for <netdev@vger.kernel.org>; Fri, 2 Feb 2007 07:06:48 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l12C6mpT018362
	for <netdev@vger.kernel.org>; Fri, 2 Feb 2007 07:06:48 -0500
Received: from goulee.de.ibm.com (dyn-9-152-216-77.boeblingen.de.ibm.com [9.152.216.77])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id l12C6hCB018058
	for <netdev@vger.kernel.org>; Fri, 2 Feb 2007 07:06:47 -0500
Received: from goulee.de.ibm.com (localhost.localdomain [127.0.0.1])
	by goulee.de.ibm.com (8.13.1/8.13.1) with ESMTP id l12C5voG014448
	for <netdev@vger.kernel.org>; Fri, 2 Feb 2007 13:05:57 +0100
Received: (from pavlic@localhost)
	by goulee.de.ibm.com (8.13.1/8.13.1/Submit) id l12C5vQ6014445
	for netdev@vger.kernel.org; Fri, 2 Feb 2007 13:05:57 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Martin Schwidefsky <schwidefsky@de.ibm.com>

Add rewritten IUCV base code to net/iucv.

Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>
Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---

 arch/s390/defconfig     |    1 
 include/net/iucv/iucv.h |  415 ++++++++++++
 net/Kconfig             |    1 
 net/Makefile            |    1 
 net/iucv/Kconfig        |    7 
 net/iucv/Makefile       |    5 
 net/iucv/iucv.c         | 1619 +++++++++++++++++++++++++++++++++++++++++++++++
 7 files changed, 2049 insertions(+), 0 deletions(-)

diff --git a/arch/s390/defconfig b/arch/s390/defconfig
index 7d9fd17..56fe005 100644
--- a/arch/s390/defconfig
+++ b/arch/s390/defconfig
@@ -177,6 +177,7 @@ CONFIG_XFRM=y
 # CONFIG_XFRM_USER is not set
 # CONFIG_XFRM_SUB_POLICY is not set
 CONFIG_NET_KEY=y
+CONFIG_IUCV=m
 CONFIG_INET=y
 CONFIG_IP_MULTICAST=y
 # CONFIG_IP_ADVANCED_ROUTER is not set
diff --git a/include/net/iucv/iucv.h b/include/net/iucv/iucv.h
new file mode 100644
index 0000000..746e741
--- /dev/null
+++ b/include/net/iucv/iucv.h
@@ -0,0 +1,415 @@
+/*
+ *  drivers/s390/net/iucv.h
+ *    IUCV base support.
+ *
+ *  S390 version
+ *    Copyright 2000, 2006 IBM Corporation
+ *    Author(s):Alan Altmark (Alan_Altmark@us.ibm.com)
+ *		Xenia Tkatschow (xenia@us.ibm.com)
+ *    Rewritten for af_iucv:
+ *	Martin Schwidefsky <schwidefsky@de.ibm.com>
+ *
+ *
+ * Functionality:
+ * To explore any of the IUCV functions, one must first register their
+ * program using iucv_register(). Once your program has successfully
+ * completed a register, it can exploit the other functions.
+ * For furthur reference on all IUCV functionality, refer to the
+ * CP Programming Services book, also available on the web thru
+ * www.ibm.com/s390/vm/pubs, manual # SC24-5760
+ *
+ * Definition of Return Codes
+ * - All positive return codes including zero are reflected back
+ *   from CP. The definition of each return code can be found in
+ *   CP Programming Services book.
+ * - Return Code of:
+ *   -EINVAL: Invalid value
+ *   -ENOMEM: storage allocation failed
+ */
+
+#include <linux/types.h>
+#include <asm/debug.h>
+
+/*
+ * IUCV option flags usable by device drivers:
+ *
+ * IUCV_IPRMDATA  Indicates that your program can handle a message in the
+ *		  parameter list / a message is sent in the parameter list.
+ *		  Used for iucv_path_accept, iucv_path_connect,
+ *		  iucv_message_reply, iucv_message_send, iucv_message_send2way.
+ * IUCV_IPQUSCE	  Indicates that you do not want to receive messages on this
+ *		  path until an iucv_path_resume is issued.
+ *		  Used for iucv_path_accept, iucv_path_connect.
+ * IUCV_IPBUFLST  Indicates that an address list is used for the message data.
+ *		  Used for iucv_message_receive, iucv_message_send,
+ *		  iucv_message_send2way.
+ * IUCV_IPPRTY	  Specifies that you want to send priority messages.
+ *		  Used for iucv_path_accept, iucv_path_connect,
+ *		  iucv_message_reply, iucv_message_send, iucv_message_send2way.
+ * IUCV_IPSYNC	  Indicates a synchronous send request.
+ *		  Used for iucv_message_send, iucv_message_send2way.
+ * IUCV_IPANSLST  Indicates that an address list is used for the reply data.
+ *		  Used for iucv_message_reply, iucv_message_send2way.
+ * IUCV_IPLOCAL	  Specifies that the communication partner has to be on the
+ *		  local system. If local is specified no target class can be
+ *		  specified.
+ *		  Used for iucv_path_connect.
+ *
+ * All flags are defined in the input field IPFLAGS1 of each function
+ * and can be found in CP Programming Services.
+ */
+#define IUCV_IPRMDATA	0x80
+#define IUCV_IPQUSCE	0x40
+#define IUCV_IPBUFLST	0x40
+#define IUCV_IPPRTY	0x20
+#define IUCV_IPANSLST	0x08
+#define IUCV_IPSYNC	0x04
+#define IUCV_IPLOCAL	0x01
+
+/*
+ * iucv_array : Defines buffer array.
+ * Inside the array may be 31- bit addresses and 31-bit lengths.
+ * Use a pointer to an iucv_array as the buffer, reply or answer
+ * parameter on iucv_message_send, iucv_message_send2way, iucv_message_receive
+ * and iucv_message_reply if IUCV_IPBUFLST or IUCV_IPANSLST are used.
+ */
+struct iucv_array {
+	u32 address;
+	u32 length;
+} __attribute__ ((aligned (8)));
+
+extern struct bus_type iucv_bus;
+extern struct device *iucv_root;
+
+/*
+ * struct iucv_path
+ * pathid: 16 bit path identification
+ * msglim: 16 bit message limit
+ * flags: properties of the path: IPRMDATA, IPQUSCE, IPPRTY
+ * handler:  address of iucv handler structure
+ * private: private information of the handler associated with the path
+ * list: list_head for the iucv_handler path list.
+ */
+struct iucv_path {
+	u16 pathid;
+	u16 msglim;
+	u8  flags;
+	void *private;
+	struct iucv_handler *handler;
+	struct list_head list;
+};
+
+/*
+ * struct iucv_message
+ * id: 32 bit message id
+ * audit: 32 bit error information of purged or replied messages
+ * class: 32 bit target class of a message (source class for replies)
+ * tag: 32 bit tag to be associated with the message
+ * length: 32 bit length of the message / reply
+ * reply_size: 32 bit maximum allowed length of the reply
+ * rmmsg: 8 byte inline message
+ * flags: message properties (IUCV_IPPRTY)
+ */
+struct iucv_message {
+	u32 id;
+	u32 audit;
+	u32 class;
+	u32 tag;
+	u32 length;
+	u32 reply_size;
+	u8  rmmsg[8];
+	u8  flags;
+};
+
+/*
+ * struct iucv_handler
+ *
+ * A vector of functions that handle IUCV interrupts. Each functions gets
+ * a parameter area as defined by the CP Programming Services and private
+ * pointer that is provided by the user of the interface.
+ */
+struct iucv_handler {
+	 /*
+	  * The path_pending function is called after an iucv interrupt
+	  * type 0x01 has been received. The base code allocates a path
+	  * structure and "asks" the handler if this path belongs to the
+	  * handler. To accept the path the path_pending function needs
+	  * to call iucv_path_accept and return 0. If the callback returns
+	  * a value != 0 the iucv base code will continue with the next
+	  * handler. The order in which the path_pending functions are
+	  * called is the order of the registration of the iucv handlers
+	  * to the base code.
+	  */
+	int  (*path_pending)(struct iucv_path *, u8 ipvmid[8], u8 ipuser[16]);
+	/*
+	 * The path_complete function is called after an iucv interrupt
+	 * type 0x02 has been received for a path that has been established
+	 * for this handler with iucv_path_connect and got accepted by the
+	 * peer with iucv_path_accept.
+	 */
+	void (*path_complete)(struct iucv_path *, u8 ipuser[16]);
+	 /*
+	  * The path_severed function is called after an iucv interrupt
+	  * type 0x03 has been received. The communication peer shutdown
+	  * his end of the communication path. The path still exists and
+	  * remaining messages can be received until a iucv_path_sever
+	  * shuts down the other end of the path as well.
+	  */
+	void (*path_severed)(struct iucv_path *, u8 ipuser[16]);
+	/*
+	 * The path_quiesced function is called after an icuv interrupt
+	 * type 0x04 has been received. The communication peer has quiesced
+	 * the path. Delivery of messages is stopped until iucv_path_resume
+	 * has been called.
+	 */
+	void (*path_quiesced)(struct iucv_path *, u8 ipuser[16]);
+	/*
+	 * The path_resumed function is called after an icuv interrupt
+	 * type 0x05 has been received. The communication peer has resumed
+	 * the path.
+	 */
+	void (*path_resumed)(struct iucv_path *, u8 ipuser[16]);
+	/*
+	 * The message_pending function is called after an icuv interrupt
+	 * type 0x06 or type 0x07 has been received. A new message is
+	 * availabe and can be received with iucv_message_receive.
+	 */
+	void (*message_pending)(struct iucv_path *, struct iucv_message *);
+	/*
+	 * The message_complete function is called after an icuv interrupt
+	 * type 0x08 or type 0x09 has been received. A message send with
+	 * iucv_message_send2way has been replied to. The reply can be
+	 * received with iucv_message_receive.
+	 */
+	void (*message_complete)(struct iucv_path *, struct iucv_message *);
+
+	struct list_head list;
+	struct list_head paths;
+};
+
+/**
+ * iucv_register:
+ * @handler: address of iucv handler structure
+ * @smp: != 0 indicates that the handler can deal with out of order messages
+ *
+ * Registers a driver with IUCV.
+ *
+ * Returns 0 on success, -ENOMEM if the memory allocation for the pathid
+ * table failed, or -EIO if IUCV_DECLARE_BUFFER failed on all cpus.
+ */
+int iucv_register(struct iucv_handler *handler, int smp);
+
+/**
+ * iucv_unregister
+ * @handler:  address of iucv handler structure
+ * @smp: != 0 indicates that the handler can deal with out of order messages
+ *
+ * Unregister driver from IUCV.
+ */
+void iucv_unregister(struct iucv_handler *handle, int smp);
+
+/**
+ * iucv_path_alloc
+ * @msglim: initial message limit
+ * @flags: initial flags
+ * @gfp: kmalloc allocation flag
+ *
+ * Allocate a new path structure for use with iucv_connect.
+ *
+ * Returns NULL if the memory allocation failed or a pointer to the
+ * path structure.
+ */
+static inline struct iucv_path *iucv_path_alloc(u16 msglim, u8 flags, gfp_t gfp)
+{
+	struct iucv_path *path;
+
+	path = kzalloc(sizeof(struct iucv_path), gfp);
+	if (path) {
+		path->msglim = msglim;
+		path->flags = flags;
+	}
+	return path;
+}
+
+/**
+ * iucv_path_free
+ * @path: address of iucv path structure
+ *
+ * Frees a path structure.
+ */
+static inline void iucv_path_free(struct iucv_path *path)
+{
+	kfree(path);
+}
+
+/**
+ * iucv_path_accept
+ * @path: address of iucv path structure
+ * @handler: address of iucv handler structure
+ * @userdata: 16 bytes of data reflected to the communication partner
+ * @private: private data passed to interrupt handlers for this path
+ *
+ * This function is issued after the user received a connection pending
+ * external interrupt and now wishes to complete the IUCV communication path.
+ *
+ * Returns the result of the CP IUCV call.
+ */
+int iucv_path_accept(struct iucv_path *path, struct iucv_handler *handler,
+		     u8 userdata[16], void *private);
+
+/**
+ * iucv_path_connect
+ * @path: address of iucv path structure
+ * @handler: address of iucv handler structure
+ * @userid: 8-byte user identification
+ * @system: 8-byte target system identification
+ * @userdata: 16 bytes of data reflected to the communication partner
+ * @private: private data passed to interrupt handlers for this path
+ *
+ * This function establishes an IUCV path. Although the connect may complete
+ * successfully, you are not able to use the path until you receive an IUCV
+ * Connection Complete external interrupt.
+ *
+ * Returns the result of the CP IUCV call.
+ */
+int iucv_path_connect(struct iucv_path *path, struct iucv_handler *handler,
+		      u8 userid[8], u8 system[8], u8 userdata[16],
+		      void *private);
+
+/**
+ * iucv_path_quiesce:
+ * @path: address of iucv path structure
+ * @userdata: 16 bytes of data reflected to the communication partner
+ *
+ * This function temporarily suspends incoming messages on an IUCV path.
+ * You can later reactivate the path by invoking the iucv_resume function.
+ *
+ * Returns the result from the CP IUCV call.
+ */
+int iucv_path_quiesce(struct iucv_path *path, u8 userdata[16]);
+
+/**
+ * iucv_path_resume:
+ * @path: address of iucv path structure
+ * @userdata: 16 bytes of data reflected to the communication partner
+ *
+ * This function resumes incoming messages on an IUCV path that has
+ * been stopped with iucv_path_quiesce.
+ *
+ * Returns the result from the CP IUCV call.
+ */
+int iucv_path_resume(struct iucv_path *path, u8 userdata[16]);
+
+/**
+ * iucv_path_sever
+ * @path: address of iucv path structure
+ * @userdata: 16 bytes of data reflected to the communication partner
+ *
+ * This function terminates an IUCV path.
+ *
+ * Returns the result from the CP IUCV call.
+ */
+int iucv_path_sever(struct iucv_path *path, u8 userdata[16]);
+
+/**
+ * iucv_message_purge
+ * @path: address of iucv path structure
+ * @msg: address of iucv msg structure
+ * @srccls: source class of message
+ *
+ * Cancels a message you have sent.
+ *
+ * Returns the result from the CP IUCV call.
+ */
+int iucv_message_purge(struct iucv_path *path, struct iucv_message *msg,
+		       u32 srccls);
+
+/**
+ * iucv_message_receive
+ * @path: address of iucv path structure
+ * @msg: address of iucv msg structure
+ * @flags: flags that affect how the message is received (IUCV_IPBUFLST)
+ * @buffer: address of data buffer or address of struct iucv_array
+ * @size: length of data buffer
+ * @residual:
+ *
+ * This function receives messages that are being sent to you over
+ * established paths. This function will deal with RMDATA messages
+ * embedded in struct iucv_message as well.
+ *
+ * Returns the result from the CP IUCV call.
+ */
+int iucv_message_receive(struct iucv_path *path, struct iucv_message *msg,
+			 u8 flags, void *buffer, size_t size, size_t *residual);
+
+/**
+ * iucv_message_reject
+ * @path: address of iucv path structure
+ * @msg: address of iucv msg structure
+ *
+ * The reject function refuses a specified message. Between the time you
+ * are notified of a message and the time that you complete the message,
+ * the message may be rejected.
+ *
+ * Returns the result from the CP IUCV call.
+ */
+int iucv_message_reject(struct iucv_path *path, struct iucv_message *msg);
+
+/**
+ * iucv_message_reply
+ * @path: address of iucv path structure
+ * @msg: address of iucv msg structure
+ * @flags: how the reply is sent (IUCV_IPRMDATA, IUCV_IPPRTY, IUCV_IPBUFLST)
+ * @reply: address of data buffer or address of struct iucv_array
+ * @size: length of reply data buffer
+ *
+ * This function responds to the two-way messages that you receive. You
+ * must identify completely the message to which you wish to reply. ie,
+ * pathid, msgid, and trgcls. Prmmsg signifies the data is moved into
+ * the parameter list.
+ *
+ * Returns the result from the CP IUCV call.
+ */
+int iucv_message_reply(struct iucv_path *path, struct iucv_message *msg,
+		       u8 flags, void *reply, size_t size);
+
+/**
+ * iucv_message_send
+ * @path: address of iucv path structure
+ * @msg: address of iucv msg structure
+ * @flags: how the message is sent (IUCV_IPRMDATA, IUCV_IPPRTY, IUCV_IPBUFLST)
+ * @srccls: source class of message
+ * @buffer: address of data buffer or address of struct iucv_array
+ * @size: length of send buffer
+ *
+ * This function transmits data to another application. Data to be
+ * transmitted is in a buffer and this is a one-way message and the
+ * receiver will not reply to the message.
+ *
+ * Returns the result from the CP IUCV call.
+ */
+int iucv_message_send(struct iucv_path *path, struct iucv_message *msg,
+		      u8 flags, u32 srccls, void *buffer, size_t size);
+
+/**
+ * iucv_message_send2way
+ * @path: address of iucv path structure
+ * @msg: address of iucv msg structure
+ * @flags: how the message is sent and the reply is received
+ *	   (IUCV_IPRMDATA, IUCV_IPBUFLST, IUCV_IPPRTY, IUCV_ANSLST)
+ * @srccls: source class of message
+ * @buffer: address of data buffer or address of struct iucv_array
+ * @size: length of send buffer
+ * @ansbuf: address of answer buffer or address of struct iucv_array
+ * @asize: size of reply buffer
+ *
+ * This function transmits data to another application. Data to be
+ * transmitted is in a buffer. The receiver of the send is expected to
+ * reply to the message and a buffer is provided into which IUCV moves
+ * the reply to this message.
+ *
+ * Returns the result from the CP IUCV call.
+ */
+int iucv_message_send2way(struct iucv_path *path, struct iucv_message *msg,
+			  u8 flags, u32 srccls, void *buffer, size_t size,
+			  void *answer, size_t asize, size_t *residual);
diff --git a/net/Kconfig b/net/Kconfig
index 7dfc949..9156578 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -37,6 +37,7 @@ config NETDEBUG
 source "net/packet/Kconfig"
 source "net/unix/Kconfig"
 source "net/xfrm/Kconfig"
+source "net/iucv/Kconfig"
 
 config INET
 	bool "TCP/IP networking"
diff --git a/net/Makefile b/net/Makefile
index ad4d14f..4854ac5 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -47,6 +47,7 @@ obj-$(CONFIG_IP_SCTP)		+= sctp/
 obj-$(CONFIG_IEEE80211)		+= ieee80211/
 obj-$(CONFIG_TIPC)		+= tipc/
 obj-$(CONFIG_NETLABEL)		+= netlabel/
+obj-$(CONFIG_IUCV)		+= iucv/
 
 ifeq ($(CONFIG_NET),y)
 obj-$(CONFIG_SYSCTL)		+= sysctl_net.o
diff --git a/net/iucv/Kconfig b/net/iucv/Kconfig
new file mode 100644
index 0000000..45ecf0b
--- /dev/null
+++ b/net/iucv/Kconfig
@@ -0,0 +1,7 @@
+config IUCV
+	tristate "IUCV support (VM only)"
+	depends on S390
+	help
+	  Select this option if you want to use inter-user communication under
+	  VM or VIF sockets. If you run on z/VM, say "Y" to enable a fast
+	  communication link between VM guests.
diff --git a/net/iucv/Makefile b/net/iucv/Makefile
new file mode 100644
index 0000000..8759417
--- /dev/null
+++ b/net/iucv/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for IUCV
+#
+
+obj-$(CONFIG_IUCV)	+= iucv.o
diff --git a/net/iucv/iucv.c b/net/iucv/iucv.c
new file mode 100644
index 0000000..fa944f8
--- /dev/null
+++ b/net/iucv/iucv.c
@@ -0,0 +1,1619 @@
+/*
+ * IUCV base infrastructure.
+ *
+ * Copyright 2001, 2006 IBM Deutschland Entwicklung GmbH, IBM Corporation
+ * Author(s):
+ *    Original source:
+ *	Alan Altmark (Alan_Altmark@us.ibm.com)	Sept. 2000
+ *	Xenia Tkatschow (xenia@us.ibm.com)
+ *    2Gb awareness and general cleanup:
+ *	Fritz Elfert (elfert@de.ibm.com, felfert@millenux.com)
+ *    Rewritten for af_iucv:
+ *	Martin Schwidefsky <schwidefsky@de.ibm.com>
+ *
+ * Documentation used:
+ *    The original source
+ *    CP Programming Service, IBM document # SC24-5760
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2, or (at your option)
+ * any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+
+#include <linux/module.h>
+#include <linux/moduleparam.h>
+
+#include <linux/spinlock.h>
+#include <linux/kernel.h>
+#include <linux/slab.h>
+#include <linux/init.h>
+#include <linux/interrupt.h>
+#include <linux/list.h>
+#include <linux/errno.h>
+#include <linux/err.h>
+#include <linux/device.h>
+#include <linux/cpu.h>
+#include <net/iucv/iucv.h>
+#include <asm/atomic.h>
+#include <asm/ebcdic.h>
+#include <asm/io.h>
+#include <asm/s390_ext.h>
+#include <asm/s390_rdev.h>
+#include <asm/smp.h>
+
+/*
+ * FLAGS:
+ * All flags are defined in the field IPFLAGS1 of each function
+ * and can be found in CP Programming Services.
+ * IPSRCCLS - Indicates you have specified a source class.
+ * IPTRGCLS - Indicates you have specified a target class.
+ * IPFGPID  - Indicates you have specified a pathid.
+ * IPFGMID  - Indicates you have specified a message ID.
+ * IPNORPY  - Indicates a one-way message. No reply expected.
+ * IPALL    - Indicates that all paths are affected.
+ */
+#define IUCV_IPSRCCLS	0x01
+#define IUCV_IPTRGCLS	0x01
+#define IUCV_IPFGPID	0x02
+#define IUCV_IPFGMID	0x04
+#define IUCV_IPNORPY	0x10
+#define IUCV_IPALL	0x80
+
+static int iucv_bus_match (struct device *dev, struct device_driver *drv)
+{
+	return 0;
+}
+
+struct bus_type iucv_bus = {
+	.name = "iucv",
+	.match = iucv_bus_match,
+};
+
+struct device *iucv_root;
+static int iucv_available;
+
+/* General IUCV interrupt structure */
+struct iucv_irq_data {
+	u16 ippathid;
+	u8  ipflags1;
+	u8  iptype;
+	u32 res2[8];
+};
+
+struct iucv_work {
+	struct list_head list;
+	struct iucv_irq_data data;
+};
+
+static LIST_HEAD(iucv_work_queue);
+static DEFINE_SPINLOCK(iucv_work_lock);
+
+static struct iucv_irq_data *iucv_irq_data;
+static cpumask_t iucv_buffer_cpumask = CPU_MASK_NONE;
+static cpumask_t iucv_irq_cpumask = CPU_MASK_NONE;
+
+static void iucv_tasklet_handler(unsigned long);
+static DECLARE_TASKLET(iucv_tasklet, iucv_tasklet_handler,0);
+
+enum iucv_command_codes {
+	IUCV_QUERY = 0,
+	IUCV_RETRIEVE_BUFFER = 2,
+	IUCV_SEND = 4,
+	IUCV_RECEIVE = 5,
+	IUCV_REPLY = 6,
+	IUCV_REJECT = 8,
+	IUCV_PURGE = 9,
+	IUCV_ACCEPT = 10,
+	IUCV_CONNECT = 11,
+	IUCV_DECLARE_BUFFER = 12,
+	IUCV_QUIESCE = 13,
+	IUCV_RESUME = 14,
+	IUCV_SEVER = 15,
+	IUCV_SETMASK = 16,
+};
+
+/*
+ * Error messages that are used with the iucv_sever function. They get
+ * converted to EBCDIC.
+ */
+static char iucv_error_no_listener[16] = "NO LISTENER";
+static char iucv_error_no_memory[16] = "NO MEMORY";
+static char iucv_error_pathid[16] = "INVALID PATHID";
+
+/*
+ * iucv_handler_list: List of registered handlers.
+ */
+static LIST_HEAD(iucv_handler_list);
+
+/*
+ * iucv_path_table: an array of iucv_path structures.
+ */
+static struct iucv_path **iucv_path_table;
+static unsigned long iucv_max_pathid;
+
+/*
+ * iucv_lock: spinlock protecting iucv_handler_list and iucv_pathid_table
+ */
+static DEFINE_SPINLOCK(iucv_table_lock);
+
+/*
+ * iucv_tasklet_cpu: contains the number of the cpu executing the tasklet.
+ * Needed for iucv_path_sever called from tasklet.
+ */
+static int iucv_tasklet_cpu = -1;
+
+/*
+ * Mutex and wait queue for iucv_register/iucv_unregister.
+ */
+static DEFINE_MUTEX(iucv_register_mutex);
+
+/*
+ * Counter for number of non-smp capable handlers.
+ */
+static int iucv_nonsmp_handler;
+
+/*
+ * IUCV control data structure. Used by iucv_path_accept, iucv_path_connect,
+ * iucv_path_quiesce and iucv_path_sever.
+ */
+struct iucv_cmd_control {
+	u16 ippathid;
+	u8  ipflags1;
+	u8  iprcode;
+	u16 ipmsglim;
+	u16 res1;
+	u8  ipvmid[8];
+	u8  ipuser[16];
+	u8  iptarget[8];
+} __attribute__ ((packed,aligned(8)));
+
+/*
+ * Data in parameter list iucv structure. Used by iucv_message_send,
+ * iucv_message_send2way and iucv_message_reply.
+ */
+struct iucv_cmd_dpl {
+	u16 ippathid;
+	u8  ipflags1;
+	u8  iprcode;
+	u32 ipmsgid;
+	u32 iptrgcls;
+	u8  iprmmsg[8];
+	u32 ipsrccls;
+	u32 ipmsgtag;
+	u32 ipbfadr2;
+	u32 ipbfln2f;
+	u32 res;
+} __attribute__ ((packed,aligned(8)));
+
+/*
+ * Data in buffer iucv structure. Used by iucv_message_receive,
+ * iucv_message_reject, iucv_message_send, iucv_message_send2way
+ * and iucv_declare_cpu.
+ */
+struct iucv_cmd_db {
+	u16 ippathid;
+	u8  ipflags1;
+	u8  iprcode;
+	u32 ipmsgid;
+	u32 iptrgcls;
+	u32 ipbfadr1;
+	u32 ipbfln1f;
+	u32 ipsrccls;
+	u32 ipmsgtag;
+	u32 ipbfadr2;
+	u32 ipbfln2f;
+	u32 res;
+} __attribute__ ((packed,aligned(8)));
+
+/*
+ * Purge message iucv structure. Used by iucv_message_purge.
+ */
+struct iucv_cmd_purge {
+	u16 ippathid;
+	u8  ipflags1;
+	u8  iprcode;
+	u32 ipmsgid;
+	u8  ipaudit[3];
+	u8  res1[5];
+	u32 res2;
+	u32 ipsrccls;
+	u32 ipmsgtag;
+	u32 res3[3];
+} __attribute__ ((packed,aligned(8)));
+
+/*
+ * Set mask iucv structure. Used by iucv_enable_cpu.
+ */
+struct iucv_cmd_set_mask {
+	u8  ipmask;
+	u8  res1[2];
+	u8  iprcode;
+	u32 res2[9];
+} __attribute__ ((packed,aligned(8)));
+
+union iucv_param {
+	struct iucv_cmd_control ctrl;
+	struct iucv_cmd_dpl dpl;
+	struct iucv_cmd_db db;
+	struct iucv_cmd_purge purge;
+	struct iucv_cmd_set_mask set_mask;
+};
+
+/*
+ * Anchor for per-cpu IUCV command parameter block.
+ */
+static union iucv_param *iucv_param;
+
+/**
+ * iucv_call_b2f0
+ * @code: identifier of IUCV call to CP.
+ * @parm: pointer to a struct iucv_parm block
+ *
+ * Calls CP to execute IUCV commands.
+ *
+ * Returns the result of the CP IUCV call.
+ */
+static inline int iucv_call_b2f0(int command, union iucv_param *parm)
+{
+	register unsigned long reg0 asm ("0");
+	register unsigned long reg1 asm ("1");
+	int ccode;
+
+	reg0 = command;
+	reg1 = virt_to_phys(parm);
+	asm volatile(
+		"	.long 0xb2f01000\n"
+		"	ipm	%0\n"
+		"	srl	%0,28\n"
+		: "=d" (ccode), "=m" (*parm), "+d" (reg0), "+a" (reg1)
+		:  "m" (*parm) : "cc");
+	return (ccode == 1) ? parm->ctrl.iprcode : ccode;
+}
+
+/**
+ * iucv_query_maxconn
+ *
+ * Determines the maximum number of connections that may be established.
+ *
+ * Returns the maximum number of connections or -EPERM is IUCV is not
+ * available.
+ */
+static int iucv_query_maxconn(void)
+{
+	register unsigned long reg0 asm ("0");
+	register unsigned long reg1 asm ("1");
+	void *param;
+	int ccode;
+
+	param = kzalloc(sizeof(union iucv_param), GFP_KERNEL|GFP_DMA);
+	if (!param)
+		return -ENOMEM;
+	reg0 = IUCV_QUERY;
+	reg1 = (unsigned long) param;
+	asm volatile (
+		"	.long	0xb2f01000\n"
+		"	ipm	%0\n"
+		"	srl	%0,28\n"
+		: "=d" (ccode), "+d" (reg0), "+d" (reg1) : : "cc");
+	if (ccode == 0)
+		iucv_max_pathid = reg0;
+	kfree(param);
+	return ccode ? -EPERM : 0;
+}
+
+/**
+ * iucv_allow_cpu
+ * @data: unused
+ *
+ * Allow iucv interrupts on this cpu.
+ */
+static void iucv_allow_cpu(void *data)
+{
+	int cpu = smp_processor_id();
+	union iucv_param *parm;
+
+	/*
+	 * Enable all iucv interrupts.
+	 * ipmask contains bits for the different interrupts
+	 *	0x80 - Flag to allow nonpriority message pending interrupts
+	 *	0x40 - Flag to allow priority message pending interrupts
+	 *	0x20 - Flag to allow nonpriority message completion interrupts
+	 *	0x10 - Flag to allow priority message completion interrupts
+	 *	0x08 - Flag to allow IUCV control interrupts
+	 */
+	parm = percpu_ptr(iucv_param, smp_processor_id());
+	memset(parm, 0, sizeof(union iucv_param));
+	parm->set_mask.ipmask = 0xf8;
+	iucv_call_b2f0(IUCV_SETMASK, parm);
+
+	/* Set indication that iucv interrupts are allowed for this cpu. */
+	cpu_set(cpu, iucv_irq_cpumask);
+}
+
+/**
+ * iucv_block_cpu
+ * @data: unused
+ *
+ * Block iucv interrupts on this cpu.
+ */
+static void iucv_block_cpu(void *data)
+{
+	int cpu = smp_processor_id();
+	union iucv_param *parm;
+
+	/* Disable all iucv interrupts. */
+	parm = percpu_ptr(iucv_param, smp_processor_id());
+	memset(parm, 0, sizeof(union iucv_param));
+	iucv_call_b2f0(IUCV_SETMASK, parm);
+
+	/* Clear indication that iucv interrupts are allowed for this cpu. */
+	cpu_clear(cpu, iucv_irq_cpumask);
+}
+
+/**
+ * iucv_declare_cpu
+ * @data: unused
+ *
+ * Declare a interupt buffer on this cpu.
+ */
+static void iucv_declare_cpu(void *data)
+{
+	int cpu = smp_processor_id();
+	union iucv_param *parm;
+	int rc;
+
+	if (cpu_isset(cpu, iucv_buffer_cpumask))
+		return;
+
+	/* Declare interrupt buffer. */
+	parm = percpu_ptr(iucv_param, cpu);
+	memset(parm, 0, sizeof(union iucv_param));
+	parm->db.ipbfadr1 = virt_to_phys(percpu_ptr(iucv_irq_data, cpu));
+	rc = iucv_call_b2f0(IUCV_DECLARE_BUFFER, parm);
+	if (rc) {
+		char *err = "Unknown";
+		switch(rc) {
+		case 0x03:
+			err = "Directory error";
+			break;
+		case 0x0a:
+			err = "Invalid length";
+			break;
+		case 0x13:
+			err = "Buffer already exists";
+			break;
+		case 0x3e:
+			err = "Buffer overlap";
+			break;
+		case 0x5c:
+			err = "Paging or storage error";
+			break;
+		}
+		printk(KERN_WARNING "iucv_register: iucv_declare_buffer "
+		       "on cpu %i returned error 0x%02x (%s)\n", cpu, rc, err);
+		return;
+	}
+
+	/* Set indication that an iucv buffer exists for this cpu. */
+	cpu_set(cpu, iucv_buffer_cpumask);
+
+	if (iucv_nonsmp_handler == 0 || cpus_empty(iucv_irq_cpumask))
+		/* Enable iucv interrupts on this cpu. */
+		iucv_allow_cpu(NULL);
+	else
+		/* Disable iucv interrupts on this cpu. */
+		iucv_block_cpu(NULL);
+}
+
+/**
+ * iucv_retrieve_cpu
+ * @data: unused
+ *
+ * Retrieve interrupt buffer on this cpu.
+ */
+static void iucv_retrieve_cpu(void *data)
+{
+	int cpu = smp_processor_id();
+	union iucv_param *parm;
+
+	if (!cpu_isset(cpu, iucv_buffer_cpumask))
+		return;
+
+	/* Block iucv interrupts. */
+	iucv_block_cpu(NULL);
+
+	/* Retrieve interrupt buffer. */
+	parm = percpu_ptr(iucv_param, cpu);
+	iucv_call_b2f0(IUCV_RETRIEVE_BUFFER, parm);
+
+	/* Clear indication that an iucv buffer exists for this cpu. */
+	cpu_clear(cpu, iucv_buffer_cpumask);
+}
+
+/**
+ * iucv_setmask_smp
+ *
+ * Allow iucv interrupts on all cpus.
+ */
+static void iucv_setmask_mp(void)
+{
+	int cpu;
+
+	for_each_online_cpu(cpu)
+		/* Enable all cpus with a declared buffer. */
+		if (cpu_isset(cpu, iucv_buffer_cpumask) && 
+		    !cpu_isset(cpu, iucv_irq_cpumask))
+			smp_call_function_on(iucv_allow_cpu, NULL, 0, 1, cpu);
+}
+
+/**
+ * iucv_setmask_up
+ *
+ * Allow iucv interrupts on a single cpus.
+ */
+static void iucv_setmask_up(void)
+{
+	cpumask_t cpumask;
+	int cpu;
+
+	/* Disable all cpu but the first in cpu_irq_cpumask. */
+	cpumask = iucv_irq_cpumask;
+	cpu_clear(first_cpu(iucv_irq_cpumask), cpumask);
+	for_each_cpu_mask(cpu, cpumask)
+		smp_call_function_on(iucv_block_cpu, NULL, 0, 1, cpu);
+}
+
+/**
+ * iucv_enable
+ *
+ * This function makes iucv ready for use. It allocates the pathid
+ * table, declares an iucv interrupt buffer and enables the iucv
+ * interrupts. Called when the first user has registered an iucv
+ * handler.
+ */
+static int iucv_enable(void)
+{
+	size_t alloc_size;
+	int cpu, rc;
+
+	rc = -ENOMEM;
+	alloc_size = iucv_max_pathid * sizeof(struct iucv_path);
+	iucv_path_table = kzalloc(alloc_size, GFP_KERNEL);
+	if (!iucv_path_table)
+		goto out;
+	/* Declare per cpu buffers. */
+	rc = -EIO;
+	for_each_online_cpu(cpu)
+		smp_call_function_on(iucv_declare_cpu, NULL, 0, 1, cpu);
+	if (cpus_empty(iucv_buffer_cpumask))
+		/* No cpu could declare an iucv buffer. */
+		goto out_path;
+	return 0;
+
+out_path:
+	kfree(iucv_path_table);
+out:
+	return rc;
+}
+
+/**
+ * iucv_disable
+ *
+ * This function shuts down iucv. It disables iucv interrupts, retrieves
+ * the iucv interrupt buffer and frees the pathid table. Called after the
+ * last user unregister its iucv handler.
+ */
+static void iucv_disable(void)
+{
+	on_each_cpu(iucv_retrieve_cpu, NULL, 0, 1);
+	kfree(iucv_path_table);
+}
+
+#ifdef CONFIG_HOTPLUG_CPU
+static int __cpuinit iucv_cpu_notify(struct notifier_block *self,
+				     unsigned long action, void *hcpu)
+{
+	cpumask_t cpumask;
+	long cpu = (long) hcpu;
+
+	switch (action) {
+	case CPU_UP_PREPARE:
+		if (!percpu_populate(iucv_irq_data,
+				     sizeof(struct iucv_irq_data),
+				     GFP_KERNEL|GFP_DMA, cpu))
+			return NOTIFY_BAD;
+		if (!percpu_populate(iucv_param, sizeof(union iucv_param),
+				     GFP_KERNEL|GFP_DMA, cpu)) {
+			percpu_depopulate(iucv_irq_data, cpu);
+			return NOTIFY_BAD;
+		}
+		break;
+	case CPU_UP_CANCELED:
+	case CPU_DEAD:
+		percpu_depopulate(iucv_param, cpu);
+		percpu_depopulate(iucv_irq_data, cpu);
+		break;
+	case CPU_ONLINE:
+	case CPU_DOWN_FAILED:
+		smp_call_function_on(iucv_declare_cpu, NULL, 0, 1, cpu);
+		break;
+	case CPU_DOWN_PREPARE:
+		cpumask = iucv_buffer_cpumask;
+		cpu_clear(cpu, cpumask);
+		if (cpus_empty(cpumask))
+			/* Can't offline last IUCV enabled cpu. */
+			return NOTIFY_BAD;
+		smp_call_function_on(iucv_retrieve_cpu, NULL, 0, 1, cpu);
+		if (cpus_empty(iucv_irq_cpumask))
+			smp_call_function_on(iucv_allow_cpu, NULL, 0, 1,
+					     first_cpu(iucv_buffer_cpumask));
+		break;
+	}
+	return NOTIFY_OK;
+}
+
+static struct notifier_block iucv_cpu_notifier = {
+	.notifier_call = iucv_cpu_notify,
+};
+#endif
+
+/**
+ * iucv_sever_pathid
+ * @pathid: path identification number.
+ * @userdata: 16-bytes of user data.
+ *
+ * Sever an iucv path to free up the pathid. Used internally.
+ */
+static int iucv_sever_pathid(u16 pathid, u8 userdata[16])
+{
+	union iucv_param *parm;
+
+	parm = percpu_ptr(iucv_param, smp_processor_id());
+	memset(parm, 0, sizeof(union iucv_param));
+	if (userdata)
+		memcpy(parm->ctrl.ipuser, userdata, sizeof(parm->ctrl.ipuser));
+	parm->ctrl.ippathid = pathid;
+	return iucv_call_b2f0(IUCV_SEVER, parm);
+}
+
+/**
+ * __iucv_cleanup_pathid
+ * @dummy: unused dummy argument
+ *
+ * Nop function called via smp_call_function to force work items from
+ * pending external iucv interrupts to the work queue.
+ */
+static void __iucv_cleanup_pathid(void *dummy)
+{
+}
+
+/**
+ * iucv_cleanup_pathid
+ * @pathid: 16 bit pathid
+ *
+ * Function called after a path has been severed to find all remaining
+ * work items for the now stale pathid. The caller needs to hold the
+ * iucv_table_lock.
+ */
+static void iucv_cleanup_pathid(u16 pathid)
+{
+	struct iucv_work *p, *n;
+
+	/*
+	 * Path is severed, the pathid can be reused immediatly on
+	 * a iucv connect or a connection pending interrupt.
+	 * iucv_path_connect and connection pending interrupt will
+	 * wait until the iucv_table_lock is released before the
+	 * recycled pathid enters the system.
+	 * Force remaining interrupts to the work queue, then
+	 * scan the work queue for items of this path.
+	 */
+	smp_call_function(__iucv_cleanup_pathid, NULL, 0, 1);
+	spin_lock_irq(&iucv_work_lock);
+	list_for_each_entry_safe(p, n, &iucv_work_queue, list) {
+		/* Remove work items for pathid except connection pending */
+		if (p->data.ippathid == pathid && p->data.iptype != 0x01) {
+			list_del(&p->list);
+			kfree(p);
+		}
+	}
+	spin_unlock_irq(&iucv_work_lock);
+}
+
+/**
+ * iucv_register:
+ * @handler: address of iucv handler structure
+ * @smp: != 0 indicates that the handler can deal with out of order messages
+ *
+ * Registers a driver with IUCV.
+ *
+ * Returns 0 on success, -ENOMEM if the memory allocation for the pathid
+ * table failed, or -EIO if IUCV_DECLARE_BUFFER failed on all cpus.
+ */
+int iucv_register(struct iucv_handler *handler, int smp)
+{
+	int rc;
+
+	if (!iucv_available)
+		return -ENOSYS;
+	mutex_lock(&iucv_register_mutex);
+	if (!smp)
+		iucv_nonsmp_handler++;
+	if (list_empty(&iucv_handler_list)) {
+		rc = iucv_enable();
+		if (rc)
+			goto out_mutex;
+	} else if (!smp && iucv_nonsmp_handler == 1)
+		iucv_setmask_up();
+	INIT_LIST_HEAD(&handler->paths);
+
+	spin_lock_irq(&iucv_table_lock);
+	list_add_tail(&handler->list, &iucv_handler_list);
+	spin_unlock_irq(&iucv_table_lock);
+	rc = 0;
+out_mutex:
+	mutex_unlock(&iucv_register_mutex);
+	return rc;
+}
+
+/**
+ * iucv_unregister
+ * @handler:  address of iucv handler structure
+ * @smp: != 0 indicates that the handler can deal with out of order messages
+ *
+ * Unregister driver from IUCV.
+ */
+void iucv_unregister(struct iucv_handler *handler, int smp)
+{
+	struct iucv_path *p, *n;
+
+	mutex_lock(&iucv_register_mutex);
+	spin_lock_bh(&iucv_table_lock);
+	/* Remove handler from the iucv_handler_list. */
+	list_del_init(&handler->list);
+	/* Sever all pathids still refering to the handler. */
+	list_for_each_entry_safe(p, n, &handler->paths, list) {
+		iucv_sever_pathid(p->pathid, NULL);
+		iucv_path_table[p->pathid] = NULL;
+		list_del(&p->list);
+		iucv_cleanup_pathid(p->pathid);
+		iucv_path_free(p);
+	}
+	spin_unlock_bh(&iucv_table_lock);
+	if (!smp)
+		iucv_nonsmp_handler--;
+	if (list_empty(&iucv_handler_list))
+		iucv_disable();
+	else if (!smp && iucv_nonsmp_handler == 0)
+		iucv_setmask_mp();
+	mutex_unlock(&iucv_register_mutex);
+}
+
+/**
+ * iucv_path_accept
+ * @path: address of iucv path structure
+ * @handler: address of iucv handler structure
+ * @userdata: 16 bytes of data reflected to the communication partner
+ * @private: private data passed to interrupt handlers for this path
+ *
+ * This function is issued after the user received a connection pending
+ * external interrupt and now wishes to complete the IUCV communication path.
+ *
+ * Returns the result of the CP IUCV call.
+ */
+int iucv_path_accept(struct iucv_path *path, struct iucv_handler *handler,
+		     u8 userdata[16], void *private)
+{
+	union iucv_param *parm;
+	int rc;
+
+	local_bh_disable();
+	/* Prepare parameter block. */
+	parm = percpu_ptr(iucv_param, smp_processor_id());
+	memset(parm, 0, sizeof(union iucv_param));
+	parm->ctrl.ippathid = path->pathid;
+	parm->ctrl.ipmsglim = path->msglim;
+	if (userdata)
+		memcpy(parm->ctrl.ipuser, userdata, sizeof(parm->ctrl.ipuser));
+	parm->ctrl.ipflags1 = path->flags;
+
+	rc = iucv_call_b2f0(IUCV_ACCEPT, parm);
+	if (!rc) {
+		path->private = private;
+		path->msglim = parm->ctrl.ipmsglim;
+		path->flags = parm->ctrl.ipflags1;
+	}
+	local_bh_enable();
+	return rc;
+}
+
+/**
+ * iucv_path_connect
+ * @path: address of iucv path structure
+ * @handler: address of iucv handler structure
+ * @userid: 8-byte user identification
+ * @system: 8-byte target system identification
+ * @userdata: 16 bytes of data reflected to the communication partner
+ * @private: private data passed to interrupt handlers for this path
+ *
+ * This function establishes an IUCV path. Although the connect may complete
+ * successfully, you are not able to use the path until you receive an IUCV
+ * Connection Complete external interrupt.
+ *
+ * Returns the result of the CP IUCV call.
+ */
+int iucv_path_connect(struct iucv_path *path, struct iucv_handler *handler,
+		      u8 userid[8], u8 system[8], u8 userdata[16],
+		      void *private)
+{
+	union iucv_param *parm;
+	int rc;
+
+	preempt_disable();
+	if (iucv_tasklet_cpu != smp_processor_id())
+		spin_lock_bh(&iucv_table_lock);
+	parm = percpu_ptr(iucv_param, smp_processor_id());
+	memset(parm, 0, sizeof(union iucv_param));
+	parm->ctrl.ipmsglim = path->msglim;
+	parm->ctrl.ipflags1 = path->flags;
+	if (userid) {
+		memcpy(parm->ctrl.ipvmid, userid, sizeof(parm->ctrl.ipvmid));
+		ASCEBC(parm->ctrl.ipvmid, sizeof(parm->ctrl.ipvmid));
+		EBC_TOUPPER(parm->ctrl.ipvmid, sizeof(parm->ctrl.ipvmid));
+	}
+	if (system) {
+		memcpy(parm->ctrl.iptarget, system,
+		       sizeof(parm->ctrl.iptarget));
+		ASCEBC(parm->ctrl.iptarget, sizeof(parm->ctrl.iptarget));
+		EBC_TOUPPER(parm->ctrl.iptarget, sizeof(parm->ctrl.iptarget));
+	}
+	if (userdata)
+		memcpy(parm->ctrl.ipuser, userdata, sizeof(parm->ctrl.ipuser));
+
+	rc = iucv_call_b2f0(IUCV_CONNECT, parm);
+	if (!rc) {
+		if (parm->ctrl.ippathid < iucv_max_pathid) {
+			path->pathid = parm->ctrl.ippathid;
+			path->msglim = parm->ctrl.ipmsglim;
+			path->flags = parm->ctrl.ipflags1;
+			path->handler = handler;
+			path->private = private;
+			list_add_tail(&path->list, &handler->paths);
+			iucv_path_table[path->pathid] = path;
+		} else {
+			iucv_sever_pathid(parm->ctrl.ippathid,
+					  iucv_error_pathid);
+			rc = -EIO;
+		}
+	}
+	if (iucv_tasklet_cpu != smp_processor_id())
+		spin_unlock_bh(&iucv_table_lock);
+	preempt_enable();
+	return rc;
+}
+
+/**
+ * iucv_path_quiesce:
+ * @path: address of iucv path structure
+ * @userdata: 16 bytes of data reflected to the communication partner
+ *
+ * This function temporarily suspends incoming messages on an IUCV path.
+ * You can later reactivate the path by invoking the iucv_resume function.
+ *
+ * Returns the result from the CP IUCV call.
+ */
+int iucv_path_quiesce(struct iucv_path *path, u8 userdata[16])
+{
+	union iucv_param *parm;
+	int rc;
+
+	local_bh_disable();
+	parm = percpu_ptr(iucv_param, smp_processor_id());
+	memset(parm, 0, sizeof(union iucv_param));
+	if (userdata)
+		memcpy(parm->ctrl.ipuser, userdata, sizeof(parm->ctrl.ipuser));
+	parm->ctrl.ippathid = path->pathid;
+	rc = iucv_call_b2f0(IUCV_QUIESCE, parm);
+	local_bh_enable();
+	return rc;
+}
+
+/**
+ * iucv_path_resume:
+ * @path: address of iucv path structure
+ * @userdata: 16 bytes of data reflected to the communication partner
+ *
+ * This function resumes incoming messages on an IUCV path that has
+ * been stopped with iucv_path_quiesce.
+ *
+ * Returns the result from the CP IUCV call.
+ */
+int iucv_path_resume(struct iucv_path *path, u8 userdata[16])
+{
+	union iucv_param *parm;
+	int rc;
+
+	local_bh_disable();
+	parm = percpu_ptr(iucv_param, smp_processor_id());
+	memset(parm, 0, sizeof(union iucv_param));
+	if (userdata)
+		memcpy(parm->ctrl.ipuser, userdata, sizeof(parm->ctrl.ipuser));
+	parm->ctrl.ippathid = path->pathid;
+	rc = iucv_call_b2f0(IUCV_RESUME, parm);
+	local_bh_enable();
+	return rc;
+}
+
+/**
+ * iucv_path_sever
+ * @path: address of iucv path structure
+ * @userdata: 16 bytes of data reflected to the communication partner
+ *
+ * This function terminates an IUCV path.
+ *
+ * Returns the result from the CP IUCV call.
+ */
+int iucv_path_sever(struct iucv_path *path, u8 userdata[16])
+{
+	int rc;
+
+
+	preempt_disable();
+	if (iucv_tasklet_cpu != smp_processor_id())
+		spin_lock_bh(&iucv_table_lock);
+	rc = iucv_sever_pathid(path->pathid, userdata);
+	if (!rc) {
+		iucv_path_table[path->pathid] = NULL;
+		list_del_init(&path->list);
+		iucv_cleanup_pathid(path->pathid);
+	}
+	if (iucv_tasklet_cpu != smp_processor_id())
+		spin_unlock_bh(&iucv_table_lock);
+	preempt_enable();
+	return rc;
+}
+
+/**
+ * iucv_message_purge
+ * @path: address of iucv path structure
+ * @msg: address of iucv msg structure
+ * @srccls: source class of message
+ *
+ * Cancels a message you have sent.
+ *
+ * Returns the result from the CP IUCV call.
+ */
+int iucv_message_purge(struct iucv_path *path, struct iucv_message *msg,
+		       u32 srccls)
+{
+	union iucv_param *parm;
+	int rc;
+
+	local_bh_disable();
+	parm = percpu_ptr(iucv_param, smp_processor_id());
+	memset(parm, 0, sizeof(union iucv_param));
+	parm->purge.ippathid = path->pathid;
+	parm->purge.ipmsgid = msg->id;
+	parm->purge.ipsrccls = srccls;
+	parm->purge.ipflags1 = IUCV_IPSRCCLS | IUCV_IPFGMID | IUCV_IPFGPID;
+	rc = iucv_call_b2f0(IUCV_PURGE, parm);
+	if (!rc) {
+		msg->audit = (*(u32 *) &parm->purge.ipaudit) >> 8;
+		msg->tag = parm->purge.ipmsgtag;
+	}
+	local_bh_enable();
+	return rc;
+}
+
+/**
+ * iucv_message_receive
+ * @path: address of iucv path structure
+ * @msg: address of iucv msg structure
+ * @flags: how the message is received (IUCV_IPBUFLST)
+ * @buffer: address of data buffer or address of struct iucv_array
+ * @size: length of data buffer
+ * @residual:
+ *
+ * This function receives messages that are being sent to you over
+ * established paths. This function will deal with RMDATA messages
+ * embedded in struct iucv_message as well.
+ *
+ * Returns the result from the CP IUCV call.
+ */
+int iucv_message_receive(struct iucv_path *path, struct iucv_message *msg,
+			 u8 flags, void *buffer, size_t size, size_t *residual)
+{
+	union iucv_param *parm;
+	struct iucv_array *array;
+	u8 *rmmsg;
+	size_t copy;
+	int rc;
+
+	if (msg->flags & IUCV_IPRMDATA) {
+		/*
+		 * Message is 8 bytes long and has been stored to the
+		 * message descriptor itself.
+		 */
+		rc = (size < 8) ? 5 : 0;
+		if (residual)
+			*residual = abs(size - 8);
+		rmmsg = msg->rmmsg;
+		if (flags & IUCV_IPBUFLST) {
+			/* Copy to struct iucv_array. */
+			size = (size < 8) ? size : 8;
+			for (array = buffer; size > 0; array++) {
+				copy = min_t(size_t, size, array->length);
+				memcpy((u8 *)(addr_t) array->address,
+				       rmmsg, copy);
+				rmmsg += copy;
+				size -= copy;
+			}
+		} else {
+			/* Copy to direct buffer. */
+			memcpy(buffer, rmmsg, min_t(size_t, size, 8));
+		}
+		return 0;
+	}
+
+	local_bh_disable();
+	parm = percpu_ptr(iucv_param, smp_processor_id());
+	memset(parm, 0, sizeof(union iucv_param));
+	parm->db.ipbfadr1 = (u32)(addr_t) buffer;
+	parm->db.ipbfln1f = (u32) size;
+	parm->db.ipmsgid = msg->id;
+	parm->db.ippathid = path->pathid;
+	parm->db.iptrgcls = msg->class;
+	parm->db.ipflags1 = (flags | IUCV_IPFGPID |
+			     IUCV_IPFGMID | IUCV_IPTRGCLS);
+	rc = iucv_call_b2f0(IUCV_RECEIVE, parm);
+	if (!rc || rc == 5) {
+		msg->flags = parm->db.ipflags1;
+		if (residual)
+			*residual = parm->db.ipbfln1f;
+	}
+	local_bh_enable();
+	return rc;
+}
+
+/**
+ * iucv_message_reject
+ * @path: address of iucv path structure
+ * @msg: address of iucv msg structure
+ *
+ * The reject function refuses a specified message. Between the time you
+ * are notified of a message and the time that you complete the message,
+ * the message may be rejected.
+ *
+ * Returns the result from the CP IUCV call.
+ */
+int iucv_message_reject(struct iucv_path *path, struct iucv_message *msg)
+{
+	union iucv_param *parm;
+	int rc;
+
+	local_bh_disable();
+	parm = percpu_ptr(iucv_param, smp_processor_id());
+	memset(parm, 0, sizeof(union iucv_param));
+	parm->db.ippathid = path->pathid;
+	parm->db.ipmsgid = msg->id;
+	parm->db.iptrgcls = msg->class;
+	parm->db.ipflags1 = (IUCV_IPTRGCLS | IUCV_IPFGMID | IUCV_IPFGPID);
+	rc = iucv_call_b2f0(IUCV_REJECT, parm);
+	local_bh_enable();
+	return rc;
+}
+
+/**
+ * iucv_message_reply
+ * @path: address of iucv path structure
+ * @msg: address of iucv msg structure
+ * @flags: how the reply is sent (IUCV_IPRMDATA, IUCV_IPPRTY, IUCV_IPBUFLST)
+ * @reply: address of reply data buffer or address of struct iucv_array
+ * @size: length of reply data buffer
+ *
+ * This function responds to the two-way messages that you receive. You
+ * must identify completely the message to which you wish to reply. ie,
+ * pathid, msgid, and trgcls. Prmmsg signifies the data is moved into
+ * the parameter list.
+ *
+ * Returns the result from the CP IUCV call.
+ */
+int iucv_message_reply(struct iucv_path *path, struct iucv_message *msg,
+		       u8 flags, void *reply, size_t size)
+{
+	union iucv_param *parm;
+	int rc;
+
+	local_bh_disable();
+	parm = percpu_ptr(iucv_param, smp_processor_id());
+	memset(parm, 0, sizeof(union iucv_param));
+	if (flags & IUCV_IPRMDATA) {
+		parm->dpl.ippathid = path->pathid;
+		parm->dpl.ipflags1 = flags;
+		parm->dpl.ipmsgid = msg->id;
+		parm->dpl.iptrgcls = msg->class;
+		memcpy(parm->dpl.iprmmsg, reply, min_t(size_t, size, 8));
+	} else {
+		parm->db.ipbfadr1 = (u32)(addr_t) reply;
+		parm->db.ipbfln1f = (u32) size;
+		parm->db.ippathid = path->pathid;
+		parm->db.ipflags1 = flags;
+		parm->db.ipmsgid = msg->id;
+		parm->db.iptrgcls = msg->class;
+	}
+	rc = iucv_call_b2f0(IUCV_REPLY, parm);
+	local_bh_enable();
+	return rc;
+}
+
+/**
+ * iucv_message_send
+ * @path: address of iucv path structure
+ * @msg: address of iucv msg structure
+ * @flags: how the message is sent (IUCV_IPRMDATA, IUCV_IPPRTY, IUCV_IPBUFLST)
+ * @srccls: source class of message
+ * @buffer: address of send buffer or address of struct iucv_array
+ * @size: length of send buffer
+ *
+ * This function transmits data to another application. Data to be
+ * transmitted is in a buffer and this is a one-way message and the
+ * receiver will not reply to the message.
+ *
+ * Returns the result from the CP IUCV call.
+ */
+int iucv_message_send(struct iucv_path *path, struct iucv_message *msg,
+		      u8 flags, u32 srccls, void *buffer, size_t size)
+{
+	union iucv_param *parm;
+	int rc;
+
+	local_bh_disable();
+	parm = percpu_ptr(iucv_param, smp_processor_id());
+	memset(parm, 0, sizeof(union iucv_param));
+	if (flags & IUCV_IPRMDATA) {
+		/* Message of 8 bytes can be placed into the parameter list. */
+		parm->dpl.ippathid = path->pathid;
+		parm->dpl.ipflags1 = flags | IUCV_IPNORPY;
+		parm->dpl.iptrgcls = msg->class;
+		parm->dpl.ipsrccls = srccls;
+		parm->dpl.ipmsgtag = msg->tag;
+		memcpy(parm->dpl.iprmmsg, buffer, 8);
+	} else {
+		parm->db.ipbfadr1 = (u32)(addr_t) buffer;
+		parm->db.ipbfln1f = (u32) size;
+		parm->db.ippathid = path->pathid;
+		parm->db.ipflags1 = flags | IUCV_IPNORPY;
+		parm->db.iptrgcls = msg->class;
+		parm->db.ipsrccls = srccls;
+		parm->db.ipmsgtag = msg->tag;
+	}
+	rc = iucv_call_b2f0(IUCV_SEND, parm);
+	if (!rc)
+		msg->id = parm->db.ipmsgid;
+	local_bh_enable();
+	return rc;
+}
+
+/**
+ * iucv_message_send2way
+ * @path: address of iucv path structure
+ * @msg: address of iucv msg structure
+ * @flags: how the message is sent and the reply is received
+ *	   (IUCV_IPRMDATA, IUCV_IPBUFLST, IUCV_IPPRTY, IUCV_ANSLST)
+ * @srccls: source class of message
+ * @buffer: address of send buffer or address of struct iucv_array
+ * @size: length of send buffer
+ * @ansbuf: address of answer buffer or address of struct iucv_array
+ * @asize: size of reply buffer
+ *
+ * This function transmits data to another application. Data to be
+ * transmitted is in a buffer. The receiver of the send is expected to
+ * reply to the message and a buffer is provided into which IUCV moves
+ * the reply to this message.
+ *
+ * Returns the result from the CP IUCV call.
+ */
+int iucv_message_send2way(struct iucv_path *path, struct iucv_message *msg,
+			  u8 flags, u32 srccls, void *buffer, size_t size,
+			  void *answer, size_t asize, size_t *residual)
+{
+	union iucv_param *parm;
+	int rc;
+
+	local_bh_disable();
+	parm = percpu_ptr(iucv_param, smp_processor_id());
+	memset(parm, 0, sizeof(union iucv_param));
+	if (flags & IUCV_IPRMDATA) {
+		parm->dpl.ippathid = path->pathid;
+		parm->dpl.ipflags1 = path->flags;	/* priority message */
+		parm->dpl.iptrgcls = msg->class;
+		parm->dpl.ipsrccls = srccls;
+		parm->dpl.ipmsgtag = msg->tag;
+		parm->dpl.ipbfadr2 = (u32)(addr_t) answer;
+		parm->dpl.ipbfln2f = (u32) asize;
+		memcpy(parm->dpl.iprmmsg, buffer, 8);
+	} else {
+		parm->db.ippathid = path->pathid;
+		parm->db.ipflags1 = path->flags;	/* priority message */
+		parm->db.iptrgcls = msg->class;
+		parm->db.ipsrccls = srccls;
+		parm->db.ipmsgtag = msg->tag;
+		parm->db.ipbfadr1 = (u32)(addr_t) buffer;
+		parm->db.ipbfln1f = (u32) size;
+		parm->db.ipbfadr2 = (u32)(addr_t) answer;
+		parm->db.ipbfln2f = (u32) asize;
+	}
+	rc = iucv_call_b2f0(IUCV_SEND, parm);
+	if (!rc)
+		msg->id = parm->db.ipmsgid;
+	local_bh_enable();
+	return rc;
+}
+
+/**
+ * iucv_path_pending
+ * @data: Pointer to external interrupt buffer
+ *
+ * Process connection pending work item. Called from tasklet while holding
+ * iucv_table_lock.
+ */
+struct iucv_path_pending {
+	u16 ippathid;
+	u8  ipflags1;
+	u8  iptype;
+	u16 ipmsglim;
+	u16 res1;
+	u8  ipvmid[8];
+	u8  ipuser[16];
+	u32 res3;
+	u8  ippollfg;
+	u8  res4[3];
+} __attribute__ ((packed));
+
+static void iucv_path_pending(struct iucv_irq_data *data)
+{
+	struct iucv_path_pending *ipp = (void *) data;
+	struct iucv_handler *handler;
+	struct iucv_path *path;
+	char *error;
+
+	BUG_ON(iucv_path_table[ipp->ippathid]);
+	/* New pathid, handler found. Create a new path struct. */
+	error = iucv_error_no_memory;
+	path = iucv_path_alloc(ipp->ipmsglim, ipp->ipflags1, GFP_ATOMIC);
+	if (!path)
+		goto out_sever;
+	path->pathid = ipp->ippathid;
+	iucv_path_table[path->pathid] = path;
+	EBCASC(ipp->ipvmid, 8);
+
+	/* Call registered handler until one is found that wants the path. */
+	list_for_each_entry(handler, &iucv_handler_list, list) {
+		if (!handler->path_pending)
+			continue;
+		/*
+		 * Add path to handler to allow a call to iucv_path_sever
+		 * inside the path_pending function. If the handler returns
+		 * an error remove the path from the handler again.
+		 */
+		list_add(&path->list, &handler->paths);
+		path->handler = handler;
+		if (!handler->path_pending(path, ipp->ipvmid, ipp->ipuser))
+			return;
+		list_del(&path->list);
+		path->handler = NULL;
+	}
+	/* No handler wanted the path. */
+	iucv_path_table[path->pathid] = NULL;
+	iucv_path_free(path);
+	error = iucv_error_no_listener;
+out_sever:
+	iucv_sever_pathid(ipp->ippathid, error);
+}
+
+/**
+ * iucv_path_complete
+ * @data: Pointer to external interrupt buffer
+ *
+ * Process connection complete work item. Called from tasklet while holding
+ * iucv_table_lock.
+ */
+struct iucv_path_complete {
+	u16 ippathid;
+	u8  ipflags1;
+	u8  iptype;
+	u16 ipmsglim;
+	u16 res1;
+	u8  res2[8];
+	u8  ipuser[16];
+	u32 res3;
+	u8  ippollfg;
+	u8  res4[3];
+} __attribute__ ((packed));
+
+static void iucv_path_complete(struct iucv_irq_data *data)
+{
+	struct iucv_path_complete *ipc = (void *) data;
+	struct iucv_path *path = iucv_path_table[ipc->ippathid];
+
+	BUG_ON(!path || !path->handler);
+	if (path->handler->path_complete)
+		path->handler->path_complete(path, ipc->ipuser);
+}
+
+/**
+ * iucv_path_severed
+ * @data: Pointer to external interrupt buffer
+ *
+ * Process connection severed work item. Called from tasklet while holding
+ * iucv_table_lock.
+ */
+struct iucv_path_severed {
+	u16 ippathid;
+	u8  res1;
+	u8  iptype;
+	u32 res2;
+	u8  res3[8];
+	u8  ipuser[16];
+	u32 res4;
+	u8  ippollfg;
+	u8  res5[3];
+} __attribute__ ((packed));
+
+static void iucv_path_severed(struct iucv_irq_data *data)
+{
+	struct iucv_path_severed *ips = (void *) data;
+	struct iucv_path *path = iucv_path_table[ips->ippathid];
+
+	BUG_ON(!path || !path->handler);
+	if (path->handler->path_severed)
+		path->handler->path_severed(path, ips->ipuser);
+	else {
+		iucv_sever_pathid(path->pathid, NULL);
+		iucv_path_table[path->pathid] = NULL;
+		list_del_init(&path->list);
+		iucv_cleanup_pathid(path->pathid);
+		iucv_path_free(path);
+	}
+}
+
+/**
+ * iucv_path_quiesced
+ * @data: Pointer to external interrupt buffer
+ *
+ * Process connection quiesced work item. Called from tasklet while holding
+ * iucv_table_lock.
+ */
+struct iucv_path_quiesced {
+	u16 ippathid;
+	u8  res1;
+	u8  iptype;
+	u32 res2;
+	u8  res3[8];
+	u8  ipuser[16];
+	u32 res4;
+	u8  ippollfg;
+	u8  res5[3];
+} __attribute__ ((packed));
+
+static void iucv_path_quiesced(struct iucv_irq_data *data)
+{
+	struct iucv_path_quiesced *ipq = (void *) data;
+	struct iucv_path *path = iucv_path_table[ipq->ippathid];
+
+	BUG_ON(!path || !path->handler);
+	if (path->handler->path_quiesced)
+		path->handler->path_quiesced(path, ipq->ipuser);
+}
+
+/**
+ * iucv_path_resumed
+ * @data: Pointer to external interrupt buffer
+ *
+ * Process connection resumed work item. Called from tasklet while holding
+ * iucv_table_lock.
+ */
+struct iucv_path_resumed {
+	u16 ippathid;
+	u8  res1;
+	u8  iptype;
+	u32 res2;
+	u8  res3[8];
+	u8  ipuser[16];
+	u32 res4;
+	u8  ippollfg;
+	u8  res5[3];
+} __attribute__ ((packed));
+
+static void iucv_path_resumed(struct iucv_irq_data *data)
+{
+	struct iucv_path_resumed *ipr = (void *) data;
+	struct iucv_path *path = iucv_path_table[ipr->ippathid];
+
+	BUG_ON(!path || !path->handler);
+	if (path->handler->path_resumed)
+		path->handler->path_resumed(path, ipr->ipuser);
+}
+
+/**
+ * iucv_message_complete
+ * @data: Pointer to external interrupt buffer
+ *
+ * Process message complete work item. Called from tasklet while holding
+ * iucv_table_lock.
+ */
+struct iucv_message_complete {
+	u16 ippathid;
+	u8  ipflags1;
+	u8  iptype;
+	u32 ipmsgid;
+	u32 ipaudit;
+	u8  iprmmsg[8];
+	u32 ipsrccls;
+	u32 ipmsgtag;
+	u32 res;
+	u32 ipbfln2f;
+	u8  ippollfg;
+	u8  res2[3];
+} __attribute__ ((packed));
+
+static void iucv_message_complete(struct iucv_irq_data *data)
+{
+	struct iucv_message_complete *imc = (void *) data;
+	struct iucv_path *path = iucv_path_table[imc->ippathid];
+	struct iucv_message msg;
+
+	BUG_ON(!path || !path->handler);
+	if (path->handler->message_complete) {
+		msg.flags = imc->ipflags1;
+		msg.id = imc->ipmsgid;
+		msg.audit = imc->ipaudit;
+		memcpy(msg.rmmsg, imc->iprmmsg, 8);
+		msg.class = imc->ipsrccls;
+		msg.tag = imc->ipmsgtag;
+		msg.length = imc->ipbfln2f;
+		path->handler->message_complete(path, &msg);
+	}
+}
+
+/**
+ * iucv_message_pending
+ * @data: Pointer to external interrupt buffer
+ *
+ * Process message pending work item. Called from tasklet while holding
+ * iucv_table_lock.
+ */
+struct iucv_message_pending {
+	u16 ippathid;
+	u8  ipflags1;
+	u8  iptype;
+	u32 ipmsgid;
+	u32 iptrgcls;
+	union {
+		u32 iprmmsg1_u32;
+		u8  iprmmsg1[4];
+	} ln1msg1;
+	union {
+		u32 ipbfln1f;
+		u8  iprmmsg2[4];
+	} ln1msg2;
+	u32 res1[3];
+	u32 ipbfln2f;
+	u8  ippollfg;
+	u8  res2[3];
+} __attribute__ ((packed));
+
+static void iucv_message_pending(struct iucv_irq_data *data)
+{
+	struct iucv_message_pending *imp = (void *) data;
+	struct iucv_path *path = iucv_path_table[imp->ippathid];
+	struct iucv_message msg;
+
+	BUG_ON(!path || !path->handler);
+	if (path->handler->message_pending) {
+		msg.flags = imp->ipflags1;
+		msg.id = imp->ipmsgid;
+		msg.class = imp->iptrgcls;
+		if (imp->ipflags1 & IUCV_IPRMDATA) {
+			memcpy(msg.rmmsg, imp->ln1msg1.iprmmsg1, 8);
+			msg.length = 8;
+		} else
+			msg.length = imp->ln1msg2.ipbfln1f;
+		msg.reply_size = imp->ipbfln2f;
+		path->handler->message_pending(path, &msg);
+	}
+}
+
+/**
+ * iucv_tasklet_handler:
+ *
+ * This tasklet loops over the queue of irq buffers created by
+ * iucv_external_interrupt, calls the appropriate action handler
+ * and then frees the buffer.
+ */
+static void iucv_tasklet_handler(unsigned long ignored)
+{
+	typedef void iucv_irq_fn(struct iucv_irq_data *);
+	static iucv_irq_fn *irq_fn[] = {
+		[0x01] = iucv_path_pending,
+		[0x02] = iucv_path_complete,
+		[0x03] = iucv_path_severed,
+		[0x04] = iucv_path_quiesced,
+		[0x05] = iucv_path_resumed,
+		[0x06] = iucv_message_complete,
+		[0x07] = iucv_message_complete,
+		[0x08] = iucv_message_pending,
+		[0x09] = iucv_message_pending,
+	};
+	struct iucv_work *p;
+
+	/* Serialize tasklet, iucv_path_sever and iucv_path_connect. */
+	spin_lock(&iucv_table_lock);
+	iucv_tasklet_cpu = smp_processor_id();
+
+	spin_lock_irq(&iucv_work_lock);
+	while (!list_empty(&iucv_work_queue)) {
+		p = list_entry(iucv_work_queue.next, struct iucv_work, list);
+		list_del_init(&p->list);
+		spin_unlock_irq(&iucv_work_lock);
+		irq_fn[p->data.iptype](&p->data);
+		kfree(p);
+		spin_lock_irq(&iucv_work_lock);
+	}
+	spin_unlock_irq(&iucv_work_lock);
+
+	iucv_tasklet_cpu = -1;
+	spin_unlock(&iucv_table_lock);
+}
+
+/**
+ * iucv_external_interrupt
+ * @code: irq code
+ *
+ * Handles external interrupts coming in from CP.
+ * Places the interrupt buffer on a queue and schedules iucv_tasklet_handler().
+ */
+static void iucv_external_interrupt(u16 code)
+{
+	struct iucv_irq_data *p;
+	struct iucv_work *work;
+
+	p = percpu_ptr(iucv_irq_data, smp_processor_id());
+	if (p->ippathid >= iucv_max_pathid) {
+		printk(KERN_WARNING "iucv_do_int: Got interrupt with "
+		       "pathid %d > max_connections (%ld)\n",
+		       p->ippathid, iucv_max_pathid - 1);
+		iucv_sever_pathid(p->ippathid, iucv_error_no_listener);
+		return;
+	}
+	if (p->iptype  < 0x01 || p->iptype > 0x09) {
+		printk(KERN_ERR "iucv_do_int: unknown iucv interrupt\n");
+		return;
+	}
+	work = kmalloc(sizeof(struct iucv_work), GFP_ATOMIC);
+	if (!work) {
+		printk(KERN_WARNING "iucv_external_interrupt: out of memory\n");
+		return;
+	}
+	memcpy(&work->data, p, sizeof(work->data));
+	spin_lock(&iucv_work_lock);
+	list_add_tail(&work->list, &iucv_work_queue);
+	spin_unlock(&iucv_work_lock);
+	tasklet_schedule(&iucv_tasklet);
+}
+
+/**
+ * iucv_init
+ *
+ * Allocates and initializes various data structures.
+ */
+static int iucv_init(void)
+{
+	int rc;
+
+	if (!MACHINE_IS_VM) {
+		rc = -EPROTONOSUPPORT;
+		goto out;
+	}
+	rc = iucv_query_maxconn();
+	if (rc)
+		goto out;
+	rc = register_external_interrupt (0x4000, iucv_external_interrupt);
+	if (rc)
+		goto out;
+	rc = bus_register(&iucv_bus);
+	if (rc)
+		goto out_int;
+	iucv_root = s390_root_dev_register("iucv");
+	if (IS_ERR(iucv_root)) {
+		rc = PTR_ERR(iucv_root);
+		goto out_bus;
+	}
+	/* Note: GFP_DMA used used to get memory below 2G */
+	iucv_irq_data = percpu_alloc(sizeof(struct iucv_irq_data),
+				     GFP_KERNEL|GFP_DMA);
+	if (!iucv_irq_data) {
+		rc = -ENOMEM;
+		goto out_root;
+	}
+	/* Allocate parameter blocks. */
+	iucv_param = percpu_alloc(sizeof(union iucv_param),
+				  GFP_KERNEL|GFP_DMA);
+	if (!iucv_param) {
+		rc = -ENOMEM;
+		goto out_extint;
+	}
+	register_hotcpu_notifier(&iucv_cpu_notifier);
+	ASCEBC(iucv_error_no_listener, 16);
+	ASCEBC(iucv_error_no_memory, 16);
+	ASCEBC(iucv_error_pathid, 16);
+	iucv_available = 1;
+	return 0;
+
+out_extint:
+	percpu_free(iucv_irq_data);
+out_root:
+	s390_root_dev_unregister(iucv_root);
+out_bus:
+	bus_unregister(&iucv_bus);
+out_int:
+	unregister_external_interrupt(0x4000, iucv_external_interrupt);
+out:
+	return rc;
+}
+
+/**
+ * iucv_exit
+ *
+ * Frees everything allocated from iucv_init.
+ */
+static void iucv_exit(void)
+{
+	struct iucv_work *p, *n;
+
+	spin_lock_irq(&iucv_work_lock);
+	list_for_each_entry_safe(p, n, &iucv_work_queue, list)
+		kfree(p);
+	spin_unlock_irq(&iucv_work_lock);
+	unregister_hotcpu_notifier(&iucv_cpu_notifier);
+	percpu_free(iucv_param);
+	percpu_free(iucv_irq_data);
+	s390_root_dev_unregister(iucv_root);
+	bus_unregister(&iucv_bus);
+	unregister_external_interrupt(0x4000, iucv_external_interrupt);
+}
+
+subsys_initcall(iucv_init);
+module_exit(iucv_exit);
+
+/**
+ * Export all public stuff
+ */
+EXPORT_SYMBOL (iucv_bus);
+EXPORT_SYMBOL (iucv_root);
+EXPORT_SYMBOL (iucv_register);
+EXPORT_SYMBOL (iucv_unregister);
+EXPORT_SYMBOL (iucv_path_accept);
+EXPORT_SYMBOL (iucv_path_connect);
+EXPORT_SYMBOL (iucv_path_quiesce);
+EXPORT_SYMBOL (iucv_path_sever);
+EXPORT_SYMBOL (iucv_message_purge);
+EXPORT_SYMBOL (iucv_message_receive);
+EXPORT_SYMBOL (iucv_message_reject);
+EXPORT_SYMBOL (iucv_message_reply);
+EXPORT_SYMBOL (iucv_message_send);
+EXPORT_SYMBOL (iucv_message_send2way);
+
+MODULE_AUTHOR("(C) 2001 IBM Corp. by Fritz Elfert (felfert@millenux.com)");
+MODULE_DESCRIPTION("Linux for S/390 IUCV lowlevel driver");
+MODULE_LICENSE("GPL");
-- 
1.4.2.3

