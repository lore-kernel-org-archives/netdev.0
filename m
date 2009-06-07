From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 4/4] isdn: extend INTERFACE.CAPI document
Date: Sun,  7 Jun 2009 21:09:24 +0200 (CEST)
Message-ID: <20090607-patch-04.tilman@imap.cc>
References: <20090607-patch-00.tilman@imap.cc>
To: davem@davemloft.net, Karsten Keil <karsten-keil@t-online.de>,
	isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-ker
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pxnet.com ([195.227.45.7]:43727 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754619AbZFGTJl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Jun 2009 15:09:41 -0400
In-Reply-To: <20090607-patch-00.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clarify calling context and return codes of callback methods, and
add a description of the _cmsg structure and helper functions.

Impact: documentation
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 Documentation/isdn/INTERFACE.CAPI |   90 ++++++++++++++++++++++++++++++++++++-
 1 files changed, 88 insertions(+), 2 deletions(-)

diff --git a/Documentation/isdn/INTERFACE.CAPI b/Documentation/isdn/INTERFACE.CAPI
index 4631538..686e107 100644
--- a/Documentation/isdn/INTERFACE.CAPI
+++ b/Documentation/isdn/INTERFACE.CAPI
@@ -114,20 +114,36 @@ char *driver_name
 int (*load_firmware)(struct capi_ctr *ctrlr, capiloaddata *ldata)
 	(optional) pointer to a callback function for sending firmware and
 	configuration data to the device
+	Return value: 0 on success, error code on error
+	Called in process context.
 
 void (*reset_ctr)(struct capi_ctr *ctrlr)
-	pointer to a callback function for performing a reset on the device,
-	releasing all registered applications
+	(optional) pointer to a callback function for performing a reset on
+	the device, releasing all registered applications
+	Called in process context.
 
 void (*register_appl)(struct capi_ctr *ctrlr, u16 applid,
 			capi_register_params *rparam)
 void (*release_appl)(struct capi_ctr *ctrlr, u16 applid)
 	pointers to callback functions for registration and deregistration of
 	applications with the device
+	Calls to these functions are serialized by Kernel CAPI so that only
+	one call to any of them is active at any time.
 
 u16  (*send_message)(struct capi_ctr *ctrlr, struct sk_buff *skb)
 	pointer to a callback function for sending a CAPI message to the
 	device
+	Return value: CAPI error code
+	If the method returns 0 (CAPI_NOERROR) the driver has taken ownership
+	of the skb and the caller may no longer access it. If it returns a
+	non-zero (error) value then ownership of the skb returns to the caller
+	who may reuse or free it.
+	The return value should only be used to signal problems with respect
+	to accepting or queueing the message. Errors occurring during the
+	actual processing of the message should be signaled with an
+	appropriate reply message.
+	Calls to this function are not serialized by Kernel CAPI, ie. it must
+	be prepared to be re-entered.
 
 char *(*procinfo)(struct capi_ctr *ctrlr)
 	pointer to a callback function returning the entry for the device in
@@ -138,6 +154,8 @@ read_proc_t *ctr_read_proc
 	system entry, /proc/capi/controllers/<n>; will be called with a
 	pointer to the device's capi_ctr structure as the last (data) argument
 
+Note: Callback functions are never called in interrupt context.
+
 - to be filled in before calling capi_ctr_ready():
 
 u8 manu[CAPI_MANUFACTURER_LEN]
@@ -153,6 +171,45 @@ u8 serial[CAPI_SERIAL_LEN]
 	value to return for CAPI_GET_SERIAL
 
 
+4.3 The _cmsg Structure
+
+(declared in <linux/isdn/capiutil.h>)
+
+The _cmsg structure stores the contents of a CAPI 2.0 message in an easily
+accessible form. It contains members for all possible CAPI 2.0 parameters, of
+which only those appearing in the message type currently being processed are
+actually used. Unused members should be set to zero.
+
+Members are named after the CAPI 2.0 standard names of the parameters they
+represent. See <linux/isdn/capiutil.h> for the exact spelling. Member data
+types are:
+
+u8          for CAPI parameters of type 'byte'
+
+u16         for CAPI parameters of type 'word'
+
+u32         for CAPI parameters of type 'dword'
+
+_cstruct    for CAPI parameters of type 'struct' not containing any
+	    variably-sized (struct) subparameters (eg. 'Called Party Number')
+	    The member is a pointer to a buffer containing the parameter in
+	    CAPI encoding (length + content). It may also be NULL, which will
+	    be taken to represent an empty (zero length) parameter.
+
+_cmstruct   for CAPI parameters of type 'struct' containing 'struct'
+	    subparameters ('Additional Info' and 'B Protocol')
+	    The representation is a single byte containing one of the values:
+	    CAPI_DEFAULT: the parameter is empty
+	    CAPI_COMPOSE: the values of the subparameters are stored
+	    individually in the corresponding _cmsg structure members
+
+Functions capi_cmsg2message() and capi_message2cmsg() are provided to convert
+messages between their transport encoding described in the CAPI 2.0 standard
+and their _cmsg structure representation. Note that capi_cmsg2message() does
+not know or check the size of its destination buffer. The caller must make
+sure it is big enough to accomodate the resulting CAPI message.
+
+
 5. Lower Layer Interface Functions
 
 (declared in <linux/isdn/capilli.h>)
@@ -211,3 +268,32 @@ CAPIMSG_CONTROL(m)	CAPIMSG_SETCONTROL(m, contr)	Controller/PLCI/NCCI
 							(u32)
 CAPIMSG_DATALEN(m)	CAPIMSG_SETDATALEN(m, len)	Data Length (u16)
 
+
+Library functions for working with _cmsg structures
+(from <linux/isdn/capiutil.h>):
+
+unsigned capi_cmsg2message(_cmsg *cmsg, u8 *msg)
+	Assembles a CAPI 2.0 message from the parameters in *cmsg, storing the
+	result in *msg.
+
+unsigned capi_message2cmsg(_cmsg *cmsg, u8 *msg)
+	Disassembles the CAPI 2.0 message in *msg, storing the parameters in
+	*cmsg.
+
+unsigned capi_cmsg_header(_cmsg *cmsg, u16 ApplId, u8 Command, u8 Subcommand,
+			  u16 Messagenumber, u32 Controller)
+	Fills the header part and address field of the _cmsg structure *cmsg
+	with the given values, zeroing the remainder of the structure so only
+	parameters with non-default values need to be changed before sending
+	the message.
+
+void capi_cmsg_answer(_cmsg *cmsg)
+	Sets the low bit of the Subcommand field in *cmsg, thereby converting
+	_REQ to _CONF and _IND to _RESP.
+
+char *capi_cmd2str(u8 Command, u8 Subcommand)
+	Returns the CAPI 2.0 message name corresponding to the given command
+	and subcommand values, as a static ASCII string. The return value may
+	be NULL if the command/subcommand is not one of those defined in the
+	CAPI 2.0 standard.
+
-- 
1.6.2.1.214.ge986c

