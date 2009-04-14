From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH RFC] Documentation/isdn/INTERFACE.CAPI
Date: Tue, 14 Apr 2009 21:53:46 +0200
Message-ID: <49E4E9CA.8000802@imap.cc>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig51C1999B5067435E4DB258CB"
To: isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755275AbZDNTyS@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig51C1999B5067435E4DB258CB
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

In the course of my efforts to deduce the kernel CAPI hardware driver
interface from the existing driver sources in drivers/isdn/hardware,
I started to collect what I found out into a document INTERFACE.CAPI
analogous to the existing INTERFACE documents for the old isdn4linux
subsystem. I include the current state below and would welcome any
comments and corrections.

Open questions so far:

- Is there any rule or convention for the contents and format of the
  entries in /proc/capi/controller and /proc/capi/controllers/*?

- What is the benefit of registering/unregistering the driver itself
  with register_capi_driver()/unregister_capi_driver()? In particular,
  when and to what purpose is the add_card() callback used?

More questions are sure to follow once I get on with figuring out the
workings of the callback functions register_appl()/release_appl(). :-)

Thanks,
Tilman

diff --git a/Documentation/isdn/00-INDEX b/Documentation/isdn/00-INDEX
index 33543ac..f33110a 100644
--- a/Documentation/isdn/00-INDEX
+++ b/Documentation/isdn/00-INDEX
@@ -8,6 +8,8 @@ INTERFACE
        - description of isdn4linux Link Level and Hardware Level interfa=
ces.
 INTERFACE.fax
        - description of the fax subinterface of isdn4linux.
+INTERFACE.CAPI
+       - description of kernel CAPI Link Level to Hardware Level interfa=
ce.
 README
        - general info on what you need and what to do for Linux ISDN.
 README.FAQ
diff --git a/Documentation/isdn/INTERFACE.CAPI b/Documentation/isdn/INTER=
FACE.CAPI
new file mode 100644
index 0000000..d7112ac
--- /dev/null
+++ b/Documentation/isdn/INTERFACE.CAPI
@@ -0,0 +1,111 @@
+Kernel CAPI Interface to Hardware Drivers
+-----------------------------------------
+
+1. Overview
+
+Kernel CAPI operates as a dispatching layer between CAPI applications an=
d CAPI
+hardware drivers. Hardware drivers register ISDN devices (controllers, i=
n CAPI
+lingo) with Kernel CAPI to indicate their readiness to provide their ser=
vice
+to CAPI applications. CAPI applications also register with Kernel CAPI,
+requesting association with a CAPI device. Kernel CAPI then dispatches t=
he
+application registration to an available device, forwarding it to the
+corresponding hardware driver.
+
+
+2. Driver and Device Registration
+
+CAPI drivers optionally register themselves with Kernel CAPI by calling =
the
+Kernel CAPI function register_capi_driver() with a pointer to a struct
+capi_driver. This structure must be filled with the name and revision of=
 the
+driver, and optionally a pointer to a callback function, add_card(). The=

+registration can be revoked by calling the function unregister_capi_driv=
er()
+with a pointer to the same struct capi_driver.
+
+CAPI drivers must register each of the ISDN devices they control with Ke=
rnel
+CAPI by calling the Kernel CAPI function attach_capi_ctr() with a pointe=
r to a
+struct capi_ctr before they can be used. This structure must be filled w=
ith
+the names of the driver and controller, and a number of callback functio=
n
+pointers which are subsequently used by Kernel CAPI for communicating wi=
th the
+driver. The registration can be revoked by calling the function
+detach_capi_ctr() with a pointer to the same struct capi_ctr.
+
+
+3. Data Structures
+
+3.1 struct capi_driver
+
+This structure describes a Kernel CAPI driver itself. It is used in the
+register_capi_driver() and unregister_capi_driver() functions, and conta=
ins
+the following non-private fields, all to be set by the driver before cal=
ling
+register_capi_driver():
+
+char name[32]
+       the name of the driver, as a zero terminated ASCII string
+char revision[32]
+       the revision number of the driver, as a zero terminated ASCII str=
ing
+int (*add_card)(struct capi_driver *driver, capicardparams *data)
+       a callback function pointer (may be NULL)
+
+
+3.2 struct capi_ctr
+
+This structure describes an ISDN device (controller) handled by a Kernel=
 CAPI
+driver. It is used in the attach_capi_ctr() and detach_capi_ctr() functi=
ons,
+and contains the following non-private fields:
+
+- to be set by the driver before calling attach_capi_ctr():
+
+struct module *owner
+       pointer to the driver module owning the device
+
+void *driverdata
+       an opaque pointer to driver specific data, not touched by Kernel =
CAPI
+
+char name[32]
+       the name of the controller, as a zero terminated ASCII string
+
+char *driver_name
+       the name of the driver, as a zero terminated ASCII string
+
+int (*load_firmware)(struct capi_ctr *card, capiloaddata *ldata)
+       (optional) pointer to a callback function for loading firmware in=
to
+       the device
+
+void (*reset_ctr)(struct capi_ctr *card)
+       pointer to a callback function for performing a reset on the devi=
ce,
+       releasing all registered applications
+
+void (*register_appl)(struct capi_ctr *card, u16 applid,
+                       capi_register_params *rparam)
+void (*release_appl)(struct capi_ctr *card, u16 applid)
+u16  (*send_message)(struct capi_ctr *card, struct sk_buff *skb)
+       callback function pointers for driver operation
+
+char *(*procinfo)(struct capi_ctr *card)
+       pointer to a callback function returning the entry for the device=
 in
+       the CAPI controller info table, /proc/capi/controller
+
+read_proc_t *ctr_read_proc
+       pointer to the read_proc callback function for the device's proc =
file
+       system entry, /proc/capi/controllers/<n>; will be called with a
+       pointer to the device's capi_ctr structure as the last (data) arg=
ument
+
+- to be filled in before calling the ready callback (whatever that means=
):
+
+u8 manu[CAPI_MANUFACTURER_LEN]
+       value to return for CAPI_GET_MANUFACTURER
+
+capi_version version
+       value to return for CAPI_GET_VERSION
+
+capi_profile profile
+       value to return for CAPI_GET_PROFILE
+
+u8 serial[CAPI_SERIAL_LEN]
+       value to return for CAPI_GET_SERIAL
+
+
+4. Functions
+
+tbc
+

--=20
Tilman Schmidt                    E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=F6ffnet mindestens haltbar bis: (siehe R=FCckseite)


--------------enig51C1999B5067435E4DB258CB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.4-svn0 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iD8DBQFJ5OnTQ3+did9BuFsRAvXnAJ43KbSGgiBfiqzHdFiyVAoV0lENmACfZB7q
2dNapaqF5o2VkKR2Y878lTQ=
=qUuE
-----END PGP SIGNATURE-----

--------------enig51C1999B5067435E4DB258CB--
