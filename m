From: "Tilman Schmidt" <Karsten-Keil@t-online.de>
Subject: [PATCH 2/3] Documentation/isdn/INTERFACE.CAPI
Date: Wed, 22 Apr 2009 16:31:48 +0200
Message-ID: <d304c4279b3a444dfbdde6741ee57f06bb092408.1240410708.git.keil@b1-systems.de>
References: <cover.1240410708.git.keil@b1-systems.de>
Cc: Randy Dunlap <rdunlap@xenotime.net>,
	David Miller <davem@davemloft.net>, tilman@imap.cc,
	isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout03.t-online.de ([194.25.134.81]:59039 "EHLO
	mailout03.t-online.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751526AbZDVQji (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 12:39:38 -0400
In-Reply-To: <cover.1240410708.git.keil@b1-systems.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Date: Tue, 21 Apr 2009 11:18:52 +0200
isdn: document Kernel CAPI driver interface

Create a file Documentation/isdn/INTERFACE.CAPI describing the
interface between the kernel CAPI subsystem and ISDN device drivers,
analogous to the existing Documentation/isdn/INTERFACE for the old
isdn4linux subsystem. Also add kerneldoc comments to the exported
functions in drivers/isdn/capi/kcapi.c.

Impact: Documentation
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
Signed-off-by: Karsten Keil <keil@b1-systems.de>
---
 Documentation/isdn/00-INDEX       |    2 +
 Documentation/isdn/INTERFACE.CAPI |  207 +++++++++++++++++++++++++++++++++++++
 drivers/isdn/capi/kcapi.c         |  171 ++++++++++++++++++++++++++++++
 3 files changed, 380 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/isdn/INTERFACE.CAPI

diff --git a/Documentation/isdn/00-INDEX b/Documentation/isdn/00-INDEX
index d9660ee..5a2d699 100644
--- a/Documentation/isdn/00-INDEX
+++ b/Documentation/isdn/00-INDEX
@@ -8,6 +8,8 @@ INTERFACE
 	- description of isdn4linux Link Level and Hardware Level interfaces.
 INTERFACE.fax
 	- description of the fax subinterface of isdn4linux.
+INTERFACE.CAPI
+	- description of kernel CAPI Link Level to Hardware Level interface.
 README
 	- general info on what you need and what to do for Linux ISDN.
 README.FAQ
diff --git a/Documentation/isdn/INTERFACE.CAPI b/Documentation/isdn/INTERFACE.CAPI
new file mode 100644
index 0000000..8947ffc
--- /dev/null
+++ b/Documentation/isdn/INTERFACE.CAPI
@@ -0,0 +1,207 @@
+Kernel CAPI Interface to Hardware Drivers
+-----------------------------------------
+
+1. Overview
+
+Kernel CAPI operates as a dispatching layer between CAPI applications and CAPI
+hardware drivers. Hardware drivers register ISDN devices (controllers, in CAPI
+lingo) with Kernel CAPI to indicate their readiness to provide their service
+to CAPI applications. CAPI applications also register with Kernel CAPI,
+requesting association with a CAPI device. Kernel CAPI then dispatches the
+application registration to an available device, forwarding it to the
+corresponding hardware driver. Kernel CAPI then forwards CAPI messages in both
+directions between the application and the hardware driver.
+
+
+2. Driver and Device Registration
+
+CAPI drivers optionally register themselves with Kernel CAPI by calling the
+Kernel CAPI function register_capi_driver() with a pointer to a struct
+capi_driver. This structure must be filled with the name and revision of the
+driver, and optionally a pointer to a callback function, add_card(). The
+registration can be revoked by calling the function unregister_capi_driver()
+with a pointer to the same struct capi_driver.
+
+CAPI drivers must register each of the ISDN devices they control with Kernel
+CAPI by calling the Kernel CAPI function attach_capi_ctr() with a pointer to a
+struct capi_ctr before they can be used. This structure must be filled with
+the names of the driver and controller, and a number of callback function
+pointers which are subsequently used by Kernel CAPI for communicating with the
+driver. The registration can be revoked by calling the function
+detach_capi_ctr() with a pointer to the same struct capi_ctr.
+
+Before the device can be actually used, the driver must fill in the device
+information fields 'manu', 'version', 'profile' and 'serial' in the capi_ctr
+structure of the device, and signal its readiness by calling capi_ctr_ready().
+From then on, Kernel CAPI may call the registered callback functions for the
+device.
+
+If the device becomes unusable for any reason (shutdown, disconnect ...), the
+driver has to call capi_ctr_reseted(). This will prevent further calls to the
+callback functions by Kernel CAPI.
+
+
+3. Application Registration and Communication
+
+Kernel CAPI forwards registration requests from applications (calls to CAPI
+operation CAPI_REGISTER) to an appropriate hardware driver by calling its
+register_appl() callback function. A unique Application ID (ApplID, u16) is
+allocated by Kernel CAPI and passed to register_appl() along with the
+parameter structure provided by the application. This is analogous to the
+open() operation on regular files or character devices.
+
+After a successful return from register_appl(), CAPI messages from the
+application may be passed to the driver for the device via calls to the
+send_message() callback function. The CAPI message to send is stored in the
+data portion of a skb. Conversely, the driver may call Kernel CAPI's
+capi_ctr_handle_message() function to pass a received CAPI message to Kernel
+CAPI for forwarding to an application, specifying its ApplID.
+
+Format and semantics of CAPI messages are specified in the CAPI 2.0 standard.
+
+Deregistration requests (CAPI operation CAPI_RELEASE) from applications are
+forwarded as calls to the release_appl() callback function, passing the same
+ApplID as with register_appl(). After return from release_appl(), no CAPI
+messages for that application may be passed to or from the device anymore.
+
+
+4. Data Structures
+
+4.1 struct capi_driver
+
+This structure describes a Kernel CAPI driver itself. It is used in the
+register_capi_driver() and unregister_capi_driver() functions, and contains
+the following non-private fields, all to be set by the driver before calling
+register_capi_driver():
+
+char name[32]
+	the name of the driver, as a zero terminated ASCII string
+char revision[32]
+	the revision number of the driver, as a zero terminated ASCII string
+int (*add_card)(struct capi_driver *driver, capicardparams *data)
+	a callback function pointer (may be NULL)
+
+
+4.2 struct capi_ctr
+
+This structure describes an ISDN device (controller) handled by a Kernel CAPI
+driver. After registration via the attach_capi_ctr() function it is passed to
+all controller specific lower layer interface and callback functions to
+identify the controller to operate on.
+
+It contains the following non-private fields:
+
+- to be set by the driver before calling attach_capi_ctr():
+
+struct module *owner
+	pointer to the driver module owning the device
+
+void *driverdata
+	an opaque pointer to driver specific data, not touched by Kernel CAPI
+
+char name[32]
+	the name of the controller, as a zero terminated ASCII string
+
+char *driver_name
+	the name of the driver, as a zero terminated ASCII string
+
+int (*load_firmware)(struct capi_ctr *ctrlr, capiloaddata *ldata)
+	(optional) pointer to a callback function for sending firmware and
+	configuration data to the device
+
+void (*reset_ctr)(struct capi_ctr *ctrlr)
+	pointer to a callback function for performing a reset on the device,
+	releasing all registered applications
+
+void (*register_appl)(struct capi_ctr *ctrlr, u16 applid,
+			capi_register_params *rparam)
+void (*release_appl)(struct capi_ctr *ctrlr, u16 applid)
+	pointers to callback functions for registration and deregistration of
+	applications with the device
+
+u16  (*send_message)(struct capi_ctr *ctrlr, struct sk_buff *skb)
+	pointer to a callback function for sending a CAPI message to the
+	device
+
+char *(*procinfo)(struct capi_ctr *ctrlr)
+	pointer to a callback function returning the entry for the device in
+	the CAPI controller info table, /proc/capi/controller
+
+read_proc_t *ctr_read_proc
+	pointer to the read_proc callback function for the device's proc file
+	system entry, /proc/capi/controllers/<n>; will be called with a
+	pointer to the device's capi_ctr structure as the last (data) argument
+
+- to be filled in before calling capi_ctr_ready():
+
+u8 manu[CAPI_MANUFACTURER_LEN]
+	value to return for CAPI_GET_MANUFACTURER
+
+capi_version version
+	value to return for CAPI_GET_VERSION
+
+capi_profile profile
+	value to return for CAPI_GET_PROFILE
+
+u8 serial[CAPI_SERIAL_LEN]
+	value to return for CAPI_GET_SERIAL
+
+
+5. Lower Layer Interface Functions
+
+(declared in <linux/isdn/capilli.h>)
+
+void register_capi_driver(struct capi_driver *drvr)
+void unregister_capi_driver(struct capi_driver *drvr)
+	register/unregister a driver with Kernel CAPI
+
+int attach_capi_ctr(struct capi_ctr *ctrlr)
+int detach_capi_ctr(struct capi_ctr *ctrlr)
+	register/unregister a device (controller) with Kernel CAPI
+
+void capi_ctr_ready(struct capi_ctr *ctrlr)
+void capi_ctr_reseted(struct capi_ctr *ctrlr)
+	signal controller ready/not ready
+
+void capi_ctr_suspend_output(struct capi_ctr *ctrlr)
+void capi_ctr_resume_output(struct capi_ctr *ctrlr)
+	signal suspend/resume
+
+void capi_ctr_handle_message(struct capi_ctr * ctrlr, u16 applid,
+				struct sk_buff *skb)
+	pass a received CAPI message to Kernel CAPI
+	for forwarding to the specified application
+
+
+6. Helper Functions and Macros
+
+Library functions (from <linux/isdn/capilli.h>):
+
+void capilib_new_ncci(struct list_head *head, u16 applid,
+			u32 ncci, u32 winsize)
+void capilib_free_ncci(struct list_head *head, u16 applid, u32 ncci)
+void capilib_release_appl(struct list_head *head, u16 applid)
+void capilib_release(struct list_head *head)
+void capilib_data_b3_conf(struct list_head *head, u16 applid,
+			u32 ncci, u16 msgid)
+u16  capilib_data_b3_req(struct list_head *head, u16 applid,
+			u32 ncci, u16 msgid)
+
+
+Macros to extract/set element values from/in a CAPI message header
+(from <linux/isdn/capiutil.h>):
+
+Get Macro		Set Macro			Element (Type)
+
+CAPIMSG_LEN(m)		CAPIMSG_SETLEN(m, len)		Total Length (u16)
+CAPIMSG_APPID(m)	CAPIMSG_SETAPPID(m, applid)	ApplID (u16)
+CAPIMSG_COMMAND(m)	CAPIMSG_SETCOMMAND(m,cmd)	Command (u8)
+CAPIMSG_SUBCOMMAND(m)	CAPIMSG_SETSUBCOMMAND(m, cmd)	Subcommand (u8)
+CAPIMSG_CMD(m)		-				Command*256
+							+ Subcommand (u16)
+CAPIMSG_MSGID(m)	CAPIMSG_SETMSGID(m, msgid)	Message Number (u16)
+
+CAPIMSG_CONTROL(m)	CAPIMSG_SETCONTROL(m, contr)	Controller/PLCI/NCCI
+							(u32)
+CAPIMSG_DATALEN(m)	CAPIMSG_SETDATALEN(m, len)	Data Length (u16)
+
diff --git a/drivers/isdn/capi/kcapi.c b/drivers/isdn/capi/kcapi.c
index 5360c4f..f331703 100644
--- a/drivers/isdn/capi/kcapi.c
+++ b/drivers/isdn/capi/kcapi.c
@@ -270,6 +270,15 @@ static void recv_handler(struct work_struct *work)
 	mutex_unlock(&ap->recv_mtx);
 }
 
+/**
+ * capi_ctr_handle_message() - handle incoming CAPI message
+ * @card:	controller descriptor structure.
+ * @appl:	application ID.
+ * @skb:	message.
+ *
+ * Called by hardware driver to pass a CAPI message to the application.
+ */
+
 void capi_ctr_handle_message(struct capi_ctr * card, u16 appl, struct sk_buff *skb)
 {
 	struct capi20_appl *ap;
@@ -348,6 +357,13 @@ error:
 
 EXPORT_SYMBOL(capi_ctr_handle_message);
 
+/**
+ * capi_ctr_ready() - signal CAPI controller ready
+ * @card:	controller descriptor structure.
+ *
+ * Called by hardware driver to signal that the controller is up and running.
+ */
+
 void capi_ctr_ready(struct capi_ctr * card)
 {
 	card->cardstate = CARD_RUNNING;
@@ -360,6 +376,14 @@ void capi_ctr_ready(struct capi_ctr * card)
 
 EXPORT_SYMBOL(capi_ctr_ready);
 
+/**
+ * capi_ctr_reseted() - signal CAPI controller reset
+ * @card:	controller descriptor structure.
+ *
+ * Called by hardware driver to signal that the controller is down and
+ * unavailable for use.
+ */
+
 void capi_ctr_reseted(struct capi_ctr * card)
 {
 	u16 appl;
@@ -391,6 +415,13 @@ void capi_ctr_reseted(struct capi_ctr * card)
 
 EXPORT_SYMBOL(capi_ctr_reseted);
 
+/**
+ * capi_ctr_suspend_output() - suspend controller
+ * @card:	controller descriptor structure.
+ *
+ * Called by hardware driver to stop data flow.
+ */
+
 void capi_ctr_suspend_output(struct capi_ctr *card)
 {
 	if (!card->blocked) {
@@ -401,6 +432,13 @@ void capi_ctr_suspend_output(struct capi_ctr *card)
 
 EXPORT_SYMBOL(capi_ctr_suspend_output);
 
+/**
+ * capi_ctr_resume_output() - resume controller
+ * @card:	controller descriptor structure.
+ *
+ * Called by hardware driver to resume data flow.
+ */
+
 void capi_ctr_resume_output(struct capi_ctr *card)
 {
 	if (card->blocked) {
@@ -413,6 +451,14 @@ EXPORT_SYMBOL(capi_ctr_resume_output);
 
 /* ------------------------------------------------------------- */
 
+/**
+ * attach_capi_ctr() - register CAPI controller
+ * @card:	controller descriptor structure.
+ *
+ * Called by hardware driver to register a controller with the CAPI subsystem.
+ * Return value: 0 on success, error code < 0 on error
+ */
+
 int
 attach_capi_ctr(struct capi_ctr *card)
 {
@@ -459,6 +505,15 @@ attach_capi_ctr(struct capi_ctr *card)
 
 EXPORT_SYMBOL(attach_capi_ctr);
 
+/**
+ * detach_capi_ctr() - unregister CAPI controller
+ * @card:	controller descriptor structure.
+ *
+ * Called by hardware driver to remove the registration of a controller
+ * with the CAPI subsystem.
+ * Return value: 0 on success, error code < 0 on error
+ */
+
 int detach_capi_ctr(struct capi_ctr *card)
 {
         if (card->cardstate != CARD_DETECTED)
@@ -479,6 +534,13 @@ int detach_capi_ctr(struct capi_ctr *card)
 
 EXPORT_SYMBOL(detach_capi_ctr);
 
+/**
+ * register_capi_driver() - register CAPI driver
+ * @driver:	driver descriptor structure.
+ *
+ * Called by hardware driver to register itself with the CAPI subsystem.
+ */
+
 void register_capi_driver(struct capi_driver *driver)
 {
 	unsigned long flags;
@@ -490,6 +552,13 @@ void register_capi_driver(struct capi_driver *driver)
 
 EXPORT_SYMBOL(register_capi_driver);
 
+/**
+ * unregister_capi_driver() - unregister CAPI driver
+ * @driver:	driver descriptor structure.
+ *
+ * Called by hardware driver to unregister itself from the CAPI subsystem.
+ */
+
 void unregister_capi_driver(struct capi_driver *driver)
 {
 	unsigned long flags;
@@ -505,6 +574,13 @@ EXPORT_SYMBOL(unregister_capi_driver);
 /* -------- CAPI2.0 Interface ---------------------------------- */
 /* ------------------------------------------------------------- */
 
+/**
+ * capi20_isinstalled() - CAPI 2.0 operation CAPI_INSTALLED
+ *
+ * Return value: CAPI result code (CAPI_NOERROR if at least one ISDN controller
+ *	is ready for use, CAPI_REGNOTINSTALLED otherwise)
+ */
+
 u16 capi20_isinstalled(void)
 {
 	int i;
@@ -517,6 +593,18 @@ u16 capi20_isinstalled(void)
 
 EXPORT_SYMBOL(capi20_isinstalled);
 
+/**
+ * capi20_register() - CAPI 2.0 operation CAPI_REGISTER
+ * @ap:		CAPI application descriptor structure.
+ *
+ * Register an application's presence with CAPI.
+ * A unique application ID is assigned and stored in @ap->applid.
+ * After this function returns successfully, the message receive
+ * callback function @ap->recv_message() may be called at any time
+ * until capi20_release() has been called for the same @ap.
+ * Return value: CAPI result code
+ */
+
 u16 capi20_register(struct capi20_appl *ap)
 {
 	int i;
@@ -571,6 +659,16 @@ u16 capi20_register(struct capi20_appl *ap)
 
 EXPORT_SYMBOL(capi20_register);
 
+/**
+ * capi20_release() - CAPI 2.0 operation CAPI_RELEASE
+ * @ap:		CAPI application descriptor structure.
+ *
+ * Terminate an application's registration with CAPI.
+ * After this function returns successfully, the message receive
+ * callback function @ap->recv_message() will no longer be called.
+ * Return value: CAPI result code
+ */
+
 u16 capi20_release(struct capi20_appl *ap)
 {
 	int i;
@@ -603,6 +701,15 @@ u16 capi20_release(struct capi20_appl *ap)
 
 EXPORT_SYMBOL(capi20_release);
 
+/**
+ * capi20_put_message() - CAPI 2.0 operation CAPI_PUT_MESSAGE
+ * @ap:		CAPI application descriptor structure.
+ * @skb:	CAPI message.
+ *
+ * Transfer a single message to CAPI.
+ * Return value: CAPI result code
+ */
+
 u16 capi20_put_message(struct capi20_appl *ap, struct sk_buff *skb)
 {
 	struct capi_ctr *card;
@@ -668,6 +775,16 @@ u16 capi20_put_message(struct capi20_appl *ap, struct sk_buff *skb)
 
 EXPORT_SYMBOL(capi20_put_message);
 
+/**
+ * capi20_get_manufacturer() - CAPI 2.0 operation CAPI_GET_MANUFACTURER
+ * @contr:	controller number.
+ * @buf:	result buffer (64 bytes).
+ *
+ * Retrieve information about the manufacturer of the specified ISDN controller
+ * or (for @contr == 0) the driver itself.
+ * Return value: CAPI result code
+ */
+
 u16 capi20_get_manufacturer(u32 contr, u8 *buf)
 {
 	struct capi_ctr *card;
@@ -685,6 +802,16 @@ u16 capi20_get_manufacturer(u32 contr, u8 *buf)
 
 EXPORT_SYMBOL(capi20_get_manufacturer);
 
+/**
+ * capi20_get_version() - CAPI 2.0 operation CAPI_GET_VERSION
+ * @contr:	controller number.
+ * @verp:	result structure.
+ *
+ * Retrieve version information for the specified ISDN controller
+ * or (for @contr == 0) the driver itself.
+ * Return value: CAPI result code
+ */
+
 u16 capi20_get_version(u32 contr, struct capi_version *verp)
 {
 	struct capi_ctr *card;
@@ -703,6 +830,16 @@ u16 capi20_get_version(u32 contr, struct capi_version *verp)
 
 EXPORT_SYMBOL(capi20_get_version);
 
+/**
+ * capi20_get_serial() - CAPI 2.0 operation CAPI_GET_SERIAL_NUMBER
+ * @contr:	controller number.
+ * @serial:	result buffer (8 bytes).
+ *
+ * Retrieve the serial number of the specified ISDN controller
+ * or (for @contr == 0) the driver itself.
+ * Return value: CAPI result code
+ */
+
 u16 capi20_get_serial(u32 contr, u8 *serial)
 {
 	struct capi_ctr *card;
@@ -721,6 +858,16 @@ u16 capi20_get_serial(u32 contr, u8 *serial)
 
 EXPORT_SYMBOL(capi20_get_serial);
 
+/**
+ * capi20_get_profile() - CAPI 2.0 operation CAPI_GET_PROFILE
+ * @contr:	controller number.
+ * @profp:	result structure.
+ *
+ * Retrieve capability information for the specified ISDN controller
+ * or (for @contr == 0) the number of installed controllers.
+ * Return value: CAPI result code
+ */
+
 u16 capi20_get_profile(u32 contr, struct capi_profile *profp)
 {
 	struct capi_ctr *card;
@@ -903,6 +1050,15 @@ static int old_capi_manufacturer(unsigned int cmd, void __user *data)
 }
 #endif
 
+/**
+ * capi20_manufacturer() - CAPI 2.0 operation CAPI_MANUFACTURER
+ * @cmd:	command.
+ * @data:	parameter.
+ *
+ * Perform manufacturer specific command.
+ * Return value: CAPI result code
+ */
+
 int capi20_manufacturer(unsigned int cmd, void __user *data)
 {
         struct capi_ctr *card;
@@ -981,6 +1137,21 @@ int capi20_manufacturer(unsigned int cmd, void __user *data)
 EXPORT_SYMBOL(capi20_manufacturer);
 
 /* temporary hack */
+
+/**
+ * capi20_set_callback() - set CAPI application notification callback function
+ * @ap:		CAPI application descriptor structure.
+ * @callback:	callback function (NULL to remove).
+ *
+ * If not NULL, the callback function will be called to notify the
+ * application of the addition or removal of a controller.
+ * The first argument (cmd) will tell whether the controller was added
+ * (KCI_CONTRUP) or removed (KCI_CONTRDOWN).
+ * The second argument (contr) will be the controller number.
+ * For cmd==KCI_CONTRUP the third argument (data) will be a pointer to the
+ * new controller's capability profile structure.
+ */
+
 void capi20_set_callback(struct capi20_appl *ap,
 			 void (*callback) (unsigned int cmd, __u32 contr, void *data))
 {
-- 
1.6.0.2

