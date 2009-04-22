From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [PATCH RFC v2] Documentation/isdn/INTERFACE.CAPI
Date: Wed, 22 Apr 2009 08:35:38 -0700
Message-ID: <49EF394A.7090705@xenotime.net>
References: <49E4E9CA.8000802@imap.cc> <20090421091852.9C31C111815@xenon.ts.pxnet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: isdn4linux@listserv.isdn4linux.de,
	Karsten Keil <isdn@linux-pingi.de>,
	i4ldeveloper@listserv.isdn4linux.de,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([72.52.64.118]:55357 "HELO xenotime.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751419AbZDVPej (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Apr 2009 11:34:39 -0400
Received: from ::ffff:71.117.247.66 ([71.117.247.66]) by xenotime.net for <netdev@vger.kernel.org>; Wed, 22 Apr 2009 08:34:37 -0700
In-Reply-To: <20090421091852.9C31C111815@xenon.ts.pxnet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tilman Schmidt wrote:
> isdn: document Kernel CAPI driver interface
> 
> Create a file Documentation/isdn/INTERFACE.CAPI describing the
> interface between the kernel CAPI subsystem and ISDN device drivers,
> analogous to the existing Documentation/isdn/INTERFACE for the old
> isdn4linux subsystem. Also add kerneldoc comments to the exported
> functions in drivers/isdn/capi/kcapi.c.
> 
> Impact: Documentation
> Signed-off-by: Tilman Schmidt <tilman@imap.cc>
> ---
> Second, expanded draft. Hopefully better formatted mail.
> Expanded recipient list. Comments? Anything?
> 
>  Documentation/isdn/00-INDEX       |    2 
>  Documentation/isdn/INTERFACE.CAPI |  207 ++++++++++++++++++++++++++++
>  drivers/isdn/capi/kcapi.c         |  171 +++++++++++++++++++++++
>  3 files changed, 380 insertions(+)
> 
> diff --git a/Documentation/isdn/00-INDEX b/Documentation/isdn/00-INDEX
> index 33543ac..f33110a 100644
> --- a/Documentation/isdn/00-INDEX
> +++ b/Documentation/isdn/00-INDEX
> @@ -8,6 +8,8 @@ INTERFACE
>  	- description of isdn4linux Link Level and Hardware Level interfaces.
>  INTERFACE.fax
>  	- description of the fax subinterface of isdn4linux.
> +INTERFACE.CAPI
> +	- description of kernel CAPI Link Level to Hardware Level interface.
>  README
>  	- general info on what you need and what to do for Linux ISDN.
>  README.FAQ
> diff --git a/Documentation/isdn/INTERFACE.CAPI b/Documentation/isdn/INTERFACE.CAPI
> new file mode 100644
> index 0000000..1a976ae
> --- /dev/null
> +++ b/Documentation/isdn/INTERFACE.CAPI
> @@ -0,0 +1,207 @@
> +Kernel CAPI Interface to Hardware Drivers
> +-----------------------------------------
> +
> +1. Overview
> +

Should say what CAPI means, please.

> +Kernel CAPI operates as a dispatching layer between CAPI applications and CAPI
> +hardware drivers. Hardware drivers register ISDN devices (controllers, in CAPI
> +lingo) with Kernel CAPI to indicate their readiness to provide their service
> +to CAPI applications. CAPI applications also register with Kernel CAPI,
> +requesting association with a CAPI device. Kernel CAPI then dispatches the
> +application registration to an available device, forwarding it to the
> +corresponding hardware driver. Kernel CAPI then forwards CAPI messages in both
> +directions between the application and the hardware driver.
> +
> +
> +2. Driver and Device Registration
> +
> +CAPI drivers optionally register themselves with Kernel CAPI by calling the
> +Kernel CAPI function register_capi_driver() with a pointer to a struct
> +capi_driver. This structure must be filled with the name and revision of the
> +driver, and optionally a pointer to a callback function, add_card(). The
> +registration can be revoked by calling the function unregister_capi_driver()
> +with a pointer to the same struct capi_driver.
> +
> +CAPI drivers must register each of the ISDN devices they control with Kernel
> +CAPI by calling the Kernel CAPI function attach_capi_ctr() with a pointer to a
> +struct capi_ctr before they can be used. This structure must be filled with
> +the names of the driver and controller, and a number of callback function
> +pointers which are subsequently used by Kernel CAPI for communicating with the
> +driver. The registration can be revoked by calling the function
> +detach_capi_ctr() with a pointer to the same struct capi_ctr.
> +
> +Before the device can be actually used, the driver must fill in the device
> +information fields 'manu', 'version', 'profile' and 'serial' in the capi_ctr
> +structure of the device, and signal its readiness by calling capi_ctr_ready().
> +From then on, Kernel CAPI may call the registered callback functions for the
> +device.
> +
> +If the device becomes unusable for any reason (shutdown, disconnect ...), the
> +driver has to call capi_ctr_reseted(). This will prevent further calls to the
> +callback functions by Kernel CAPI.
> +
> +
> +3. Application Registration and Communication
> +
> +Kernel CAPI forwards registration requests from applications (calls to CAPI
> +operation CAPI_REGISTER) to an appropriate hardware driver by calling its 
> +register_appl() callback function. A unique Application ID (ApplID, u16) is
> +allocated by Kernel CAPI and passed to register_appl() along with the
> +parameter structure provided by the application. This is analogous to the
> +open() operation on regular files or character devices.
> +
> +After a successful return from register_appl(), CAPI messages from the
> +application may be passed to the driver for the device via calls to the 
> +send_message() callback function. The CAPI message to send is stored in the
> +data portion of a skb. Conversely, the driver may call Kernel CAPI's

I would say/write "an skb."

> +capi_ctr_handle_message() function to pass a received CAPI message to Kernel
> +CAPI for forwarding to an application, specifying its ApplID.
> +
> +Format and semantics of CAPI messages are specified in the CAPI 2.0 standard.

(googles)  which happens to be availble at www.capi.org.

> +
> +Deregistration requests (CAPI operation CAPI_RELEASE) from applications are
> +forwarded as calls to the release_appl() callback function, passing the same
> +ApplID as with register_appl(). After return from release_appl(), no CAPI
> +messages for that application may be passed to or from the device anymore.
> +
> +
> +4. Data Structures
> +
> +4.1 struct capi_driver
> +
> +This structure describes a Kernel CAPI driver itself. It is used in the
> +register_capi_driver() and unregister_capi_driver() functions, and contains
> +the following non-private fields, all to be set by the driver before calling
> +register_capi_driver():
> +
> +char name[32]
> +	the name of the driver, as a zero terminated ASCII string

	                             zero-terminated
	                      (or)   null-terminated

> +char revision[32]
> +	the revision number of the driver, as a zero terminated ASCII string

	                                        ditto

> +int (*add_card)(struct capi_driver *driver, capicardparams *data)
> +	a callback function pointer (may be NULL)
> +
> +
> +4.2 struct capi_ctr
> +
> +This structure describes an ISDN device (controller) handled by a Kernel CAPI
> +driver. After registration via the attach_capi_ctr() function it is passed to
> +all controller specific lower layer interface and callback functions to
> +identify the controller to operate on.
> +
> +It contains the following non-private fields:
> +
> +- to be set by the driver before calling attach_capi_ctr():
> +
> +struct module *owner
> +	pointer to the driver module owning the device
> +
> +void *driverdata
> +	an opaque pointer to driver specific data, not touched by Kernel CAPI
> +
> +char name[32]
> +	the name of the controller, as a zero terminated ASCII string

	                                 (ditto, above/below)
> +
> +char *driver_name
> +	the name of the driver, as a zero terminated ASCII string
> +
> +int (*load_firmware)(struct capi_ctr *ctrlr, capiloaddata *ldata)
> +	(optional) pointer to a callback function for sending firmware and
> +	configuration data to the device
> +
> +void (*reset_ctr)(struct capi_ctr *ctrlr)
> +	pointer to a callback function for performing a reset on the device,
> +	releasing all registered applications
> +
> +void (*register_appl)(struct capi_ctr *ctrlr, u16 applid,
> +			capi_register_params *rparam)
> +void (*release_appl)(struct capi_ctr *ctrlr, u16 applid)
> +	pointers to callback functions for registration and deregistration of
> +	applications with the device
> +
> +u16  (*send_message)(struct capi_ctr *ctrlr, struct sk_buff *skb)
> +	pointer to a callback function for sending a CAPI message to the
> +	device
> +
> +char *(*procinfo)(struct capi_ctr *ctrlr)
> +	pointer to a callback function returning the entry for the device in
> +	the CAPI controller info table, /proc/capi/controller
> +
> +read_proc_t *ctr_read_proc
> +	pointer to the read_proc callback function for the device's proc file
> +	system entry, /proc/capi/controllers/<n>; will be called with a
> +	pointer to the device's capi_ctr structure as the last (data) argument
> +
> +- to be filled in before calling capi_ctr_ready():
> +
> +u8 manu[CAPI_MANUFACTURER_LEN]
> +	value to return for CAPI_GET_MANUFACTURER
> +
> +capi_version version
> +	value to return for CAPI_GET_VERSION
> +
> +capi_profile profile
> +	value to return for CAPI_GET_PROFILE
> +
> +u8 serial[CAPI_SERIAL_LEN]
> +	value to return for CAPI_GET_SERIAL
> +
> +
> +5. Lower Layer Interface Functions
> +
> +(declared in <linux/isdn/capilli.h>)
> +
> +void register_capi_driver(struct capi_driver *drvr)
> +void unregister_capi_driver(struct capi_driver *drvr)
> +	register/unregister a driver with Kernel CAPI
> +
> +int attach_capi_ctr(struct capi_ctr *ctrlr)
> +int detach_capi_ctr(struct capi_ctr *ctrlr)
> +	register/unregister a device (controller) with Kernel CAPI
> +
> +void capi_ctr_ready(struct capi_ctr *ctrlr)
> +void capi_ctr_reseted(struct capi_ctr *ctrlr)
> +	signal controller ready/not ready
> +
> +void capi_ctr_suspend_output(struct capi_ctr *ctrlr)
> +void capi_ctr_resume_output(struct capi_ctr *ctrlr)
> +	signal suspend/resume
> +
> +void capi_ctr_handle_message(struct capi_ctr * ctrlr, u16 applid,
> +				struct sk_buff *skb)
> +	pass a received CAPI message to Kernel CAPI
> +	for forwarding to the specified application
> +
> +
> +6. Helper Functions and Macros
> +
> +Library functions (from <linux/isdn/capilli.h>):
> +
> +void capilib_new_ncci(struct list_head *head, u16 applid,
> +			u32 ncci, u32 winsize)
> +void capilib_free_ncci(struct list_head *head, u16 applid, u32 ncci)
> +void capilib_release_appl(struct list_head *head, u16 applid)
> +void capilib_release(struct list_head *head)
> +void capilib_data_b3_conf(struct list_head *head, u16 applid,
> +     			u32 ncci, u16 msgid)
> +u16  capilib_data_b3_req(struct list_head *head, u16 applid,
> +     			u32 ncci, u16 msgid)
> +
> +
> +Macros to extract/set element values from/in a CAPI message header
> +(from <linux/isdn/capiutil.h>):
> +
> +Get Macro		Set Macro			Element (Type)
> +
> +CAPIMSG_LEN(m)		CAPIMSG_SETLEN(m, len)		Total Length (u16)
> +CAPIMSG_APPID(m)	CAPIMSG_SETAPPID(m, applid)	ApplID (u16)
> +CAPIMSG_COMMAND(m)	CAPIMSG_SETCOMMAND(m,cmd)	Command (u8)
> +CAPIMSG_SUBCOMMAND(m)	CAPIMSG_SETSUBCOMMAND(m, cmd)	Subcommand (u8)
> +CAPIMSG_CMD(m)		-				Command*256
> +							+ Subcommand (u16)
> +CAPIMSG_MSGID(m)	CAPIMSG_SETMSGID(m, msgid)	Message Number (u16)
> +
> +CAPIMSG_CONTROL(m)	CAPIMSG_SETCONTROL(m, contr)	Controller/PLCI/NCCI
> +					      		(u32)
> +CAPIMSG_DATALEN(m)	CAPIMSG_SETDATALEN(m, len)	Data Length (u16)
> +
> diff --git a/drivers/isdn/capi/kcapi.c b/drivers/isdn/capi/kcapi.c
> index 5360c4f..f331703 100644
> --- a/drivers/isdn/capi/kcapi.c
> +++ b/drivers/isdn/capi/kcapi.c

kernel-doc changes look good.

Nice job.  Thanks.

~Randy


