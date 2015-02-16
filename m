From: Casey Leedom <leedom@chelsio.com>
Subject: RE: chelsio: Use a more common const struct pci_device_id foo[]
 style
Date: Mon, 16 Feb 2015 18:05:06 +0000
Message-ID: <4985EFDD773FCB459EF7915D2A3621ADB9E00A@nice.asicdesigners.com>
References: <1423879550.2795.12.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	linux-scsi <linux-scsi@vger.kernel.org>,
	David Miller <davem@redhat.com>
To: Joe Perches <joe@perches.com>,
	Hariprasad S <hariprasad@chelsio.com>,
	"James E.J. Bottomley" <JBottomley@parallels.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423879550.2795.12.camel@perches.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  I can't quite tell if this is a patch request being sent to netdev/Da=
vid Miller or if it's a suggestion sent to Chelsio that you'd like Chel=
sio to adopt.  I ~think~ it's the latter because the subject doesn't in=
clude the standard formatting for a patch request but I'm not 100% fami=
liar with the netdev/kernel.org conventions for this.  My apologies if =
I'm misinterpreting your message.

1.  The use of "const" certainly seems like a win.

 2. Thanks for catching the redundant use of CH_PCI_DEVICE_ID_TABLE_DEF=
INE_BEGIN to guard
    the actual contents of t4_pci_id_tbl.h.  That's already being handl=
ed via the check for
    __T4_PCI_ID_TBL_H__ =97 no idea why I put that in there ...

 3. The use of the CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN and
    CH_PCI_DEVICE_ID_TABLE_DEFINE_END are used to make the t4_pci_id_tb=
l.h
    accommodate different driver needs.  The header file is only concer=
ned with providing
    a common enumeration of existing PCI Device Identifiers associated =
with adapters.
    The files including the header are only concerned with providing th=
e necessary context
    for the header file.  The header file ai an OS-independent header f=
ile which is
    shared across six existing OS driver implementations; similar to ou=
r OS-independent
    register definitions file.

 4. The CH_PCI_ID_TABLE_ENTRY() macro is similarly used to strictly par=
tition
    the roles of t4_pci_id_tbl.h and the files which include it.  t4_pc=
i_id_tbl.h is
    exactly what it's name implies: solely an enumeration of assigned h=
ardware
    adapter PCI Device Identifiers.

 5. Because of the above change in the original abstraction layering, a=
 new macro
    CH_PCI_ID_TABLE_ENTRY_DATA is introduced in this patch which passes=
 in
    a desired value for the "dev" parameter of the PCI_VDEVICE() macro.=
  But the
    documentation for this new macro in t4_pci_id_tbl.h is incorrectly =
given the
    documentation of the original CH_PCI_ID_TABLE_ENTRY() macro which
    was originally supplied by the file including t4_pci_id_tbl.h.  Thi=
s leaves its
    usage confusing for anyone reading the header file.

In conclusion:

 A. I like the use of "const" in the table.

 B. I like removing the redundant content inclusion check of
    CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN.

 C. I'm uncomfortable with all the other changes.

Casey

________________________________________
=46rom: Joe Perches [joe@perches.com]
Sent: Friday, February 13, 2015 6:05 PM
To: Hariprasad S; Casey Leedom; James E.J. Bottomley
Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org; linux-scsi
Subject: chelsio: Use a more common const struct pci_device_id foo[] st=
yle

Chelsio code shares a pci_device_table from an #include file.
Make the include guard simpler and make the arrays const.

Reduces data by moving tables to text.

Removed unnecessary macros:
o CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN
o CH_PCI_DEVICE_ID_TABLE_DEFINE_END
o CH_PCI_ID_TABLE_ENTRY (moved to the .h file)
Added new macro define:
o CH_PCI_ID_TABLE_ENTRY_DATA

  text     data     bss     dec     hex filename
  50550     923     172   51645    c9bd drivers/net/ethernet/chelsio/cx=
gb4/cxgb4_main.o.new
  46935    4531     172   51638    c9b6 drivers/net/ethernet/chelsio/cx=
gb4/cxgb4_main.o.old
  27864     355       8   28227    6e43 drivers/net/ethernet/chelsio/cx=
gb4vf/cxgb4vf_main.o.new
  26072    2203       8   28283    6e7b drivers/net/ethernet/chelsio/cx=
gb4vf/cxgb4vf_main.o.old
   9734     450      24   10208    27e0 drivers/scsi/csiostor/csio_init=
=2Eo.new
   7942    2242      24   10208    27e0 drivers/scsi/csiostor/csio_init=
=2Eo.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    | 17 ++++------
 drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h | 38 ++++++++------=
--------
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    | 10 ++----
 drivers/scsi/csiostor/csio_init.c                  | 11 +++----
 4 files changed, 27 insertions(+), 49 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/=
net/ethernet/chelsio/cxgb4/cxgb4_main.c
index a22cf93..8a01eeb 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -123,23 +123,18 @@ struct filter_entry {

 /* Macros needed to support the PCI Device ID Table ...
  */
-#define CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN \
-       static struct pci_device_id cxgb4_pci_tbl[] =3D {
-#define CH_PCI_DEVICE_ID_FUNCTION 0x4
+
+#define CH_PCI_DEVICE_ID_FUNCTION      0x4
+#define CH_PCI_ID_TABLE_ENTRY_DATA     4

 /* Include PCI Device IDs for both PF4 and PF0-3 so our PCI probe() ro=
utine is
  * called for both.
  */
-#define CH_PCI_DEVICE_ID_FUNCTION2 0x0
-
-#define CH_PCI_ID_TABLE_ENTRY(devid) \
-               {PCI_VDEVICE(CHELSIO, (devid)), 4}
-
-#define CH_PCI_DEVICE_ID_TABLE_DEFINE_END \
-               { 0, } \
-       }
+#define CH_PCI_DEVICE_ID_FUNCTION2     0x0

+static const struct pci_device_id cxgb4_pci_tbl[] =3D {
 #include "t4_pci_id_tbl.h"
+};

 #define FW4_FNAME "cxgb4/t4fw.bin"
 #define FW5_FNAME "cxgb4/t5fw.bin"
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h b/drive=
rs/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
index ddfb5b8..f648091 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
@@ -39,9 +39,6 @@
  *
  * The macros are:
  *
- * CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN
- *   -- Used to start the definition of the PCI ID Table.
- *
  * CH_PCI_DEVICE_ID_FUNCTION
  *   -- The PCI Function Number to use in the PCI Device ID Table.  "0=
"
  *   -- for drivers attaching to PF0-3, "4" for drivers attaching to P=
=464,
@@ -51,25 +48,17 @@
  *   -- If defined, create a PCI Device ID Table with both
  *   -- CH_PCI_DEVICE_ID_FUNCTION and CH_PCI_DEVICE_ID_FUNCTION2 popul=
ated.
  *
- * CH_PCI_ID_TABLE_ENTRY(DeviceID)
+ * CH_PCI_ID_TABLE_ENTRY_DATA(DeviceID)
  *   -- Used for the individual PCI Device ID entries.  Note that we w=
ill
  *   -- be adding a trailing comma (",") after all of the entries (and
  *   -- between the pairs of entries if CH_PCI_DEVICE_ID_FUNCTION2 is =
defined).
- *
- * CH_PCI_DEVICE_ID_TABLE_DEFINE_END
- *   -- Used to finish the definition of the PCI ID Table.  Note that =
we
- *   -- will be adding a trailing semi-colon (";") here.
  */
-#ifdef CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN

 #ifndef CH_PCI_DEVICE_ID_FUNCTION
 #error CH_PCI_DEVICE_ID_FUNCTION not defined!
 #endif
-#ifndef CH_PCI_ID_TABLE_ENTRY
-#error CH_PCI_ID_TABLE_ENTRY not defined!
-#endif
-#ifndef CH_PCI_DEVICE_ID_TABLE_DEFINE_END
-#error CH_PCI_DEVICE_ID_TABLE_DEFINE_END not defined!
+#ifndef CH_PCI_ID_TABLE_ENTRY_DATA
+#error CH_PCI_ID_TABLE_ENTRY_DATA not defined!
 #endif

 /* T4 and later ASICs use a PCI Device ID scheme of 0xVFPP where:
@@ -81,19 +70,22 @@
  * We use this consistency in order to create the proper PCI Device ID=
s
  * for the specified CH_PCI_DEVICE_ID_FUNCTION.
  */
+
+#define CH_PCI_ID_TABLE_ENTRY(devid)                                  =
 \
+       { PCI_VDEVICE(CHELSIO, devid), CH_PCI_ID_TABLE_ENTRY_DATA }
+
 #ifndef CH_PCI_DEVICE_ID_FUNCTION2
-#define CH_PCI_ID_TABLE_FENTRY(devid) \
-       CH_PCI_ID_TABLE_ENTRY((devid) | \
+#define CH_PCI_ID_TABLE_FENTRY(devid)                                 =
 \
+       CH_PCI_ID_TABLE_ENTRY((devid) |                                =
 \
                              ((CH_PCI_DEVICE_ID_FUNCTION) << 8))
 #else
-#define CH_PCI_ID_TABLE_FENTRY(devid) \
-       CH_PCI_ID_TABLE_ENTRY((devid) | \
-                             ((CH_PCI_DEVICE_ID_FUNCTION) << 8)), \
-       CH_PCI_ID_TABLE_ENTRY((devid) | \
+#define CH_PCI_ID_TABLE_FENTRY(devid)                                 =
 \
+       CH_PCI_ID_TABLE_ENTRY((devid) |                                =
 \
+                             ((CH_PCI_DEVICE_ID_FUNCTION) << 8)),     =
 \
+       CH_PCI_ID_TABLE_ENTRY((devid) |                                =
 \
                              ((CH_PCI_DEVICE_ID_FUNCTION2) << 8))
 #endif

-CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN
        /* T4 adapters:
         */
        CH_PCI_ID_TABLE_FENTRY(0x4000), /* T440-dbg */
@@ -154,8 +146,6 @@ CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN
        CH_PCI_ID_TABLE_FENTRY(0x5087), /* Custom T580-CR */
        CH_PCI_ID_TABLE_FENTRY(0x5088), /* Custom T570-CR */
        CH_PCI_ID_TABLE_FENTRY(0x5089), /* Custom T520-CR */
-CH_PCI_DEVICE_ID_TABLE_DEFINE_END;
-
-#endif /* CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN */
+       {},

 #endif /* __T4_PCI_ID_TBL_H__ */
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/driv=
ers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index 122e296..7b8b834 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -3033,16 +3033,12 @@ static void cxgb4vf_pci_shutdown(struct pci_dev=
 *pdev)

 /* Macros needed to support the PCI Device ID Table ...
  */
-#define CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN \
-       static struct pci_device_id cxgb4vf_pci_tbl[] =3D {
 #define CH_PCI_DEVICE_ID_FUNCTION      0x8
+#define CH_PCI_ID_TABLE_ENTRY_DATA     0

-#define CH_PCI_ID_TABLE_ENTRY(devid) \
-               { PCI_VDEVICE(CHELSIO, (devid)), 0 }
-
-#define CH_PCI_DEVICE_ID_TABLE_DEFINE_END { 0, } }
-
+static const struct pci_device_id cxgb4vf_pci_tbl[] =3D {
 #include "../cxgb4/t4_pci_id_tbl.h"
+};

 MODULE_DESCRIPTION(DRV_DESC);
 MODULE_AUTHOR("Chelsio Communications");
diff --git a/drivers/scsi/csiostor/csio_init.c b/drivers/scsi/csiostor/=
csio_init.c
index d9631e1..0618fbd 100644
--- a/drivers/scsi/csiostor/csio_init.c
+++ b/drivers/scsi/csiostor/csio_init.c
@@ -1171,17 +1171,14 @@ static struct pci_error_handlers csio_err_handl=
er =3D {
 /*
  *  Macros needed to support the PCI Device ID Table ...
  */
-#define CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN \
-       static struct pci_device_id csio_pci_tbl[] =3D {
+
 /* Define for FCoE uses PF6 */
 #define CH_PCI_DEVICE_ID_FUNCTION      0x6
+#define CH_PCI_ID_TABLE_ENTRY_DATA     0

-#define CH_PCI_ID_TABLE_ENTRY(devid) \
-               { PCI_VDEVICE(CHELSIO, (devid)), 0 }
-
-#define CH_PCI_DEVICE_ID_TABLE_DEFINE_END { 0, } }
-
+static const struct pci_device_id csio_pci_tbl[] =3D {
 #include "t4_pci_id_tbl.h"
+};

 static struct pci_driver csio_pci_driver =3D {
        .name           =3D KBUILD_MODNAME,
