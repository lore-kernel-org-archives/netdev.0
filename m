From: Denis Vlasenko <vda@ilport.com.ua>
Subject: Re: [PATH][RFC] acxsm: Make acx mdoular again
Date: Mon, 27 Feb 2006 12:20:14 +0200
Message-ID: <200602271220.14853.vda@ilport.com.ua>
References: <200602261710.33923.carlos@cmartin.tk>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_eJtAE2W5xX0QzPl"
Cc: netdev@vger.kernel.org, acx100-devel@lists.sourceforge.net,
	"Christoph Hellwig" <hch@infradead.org>
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: Carlos =?iso-8859-1?q?Mart=EDn?= <carlos@cmartin.tk>
In-Reply-To: <200602261710.33923.carlos@cmartin.tk>
Sender: acx100-devel-admin@lists.sourceforge.net
Errors-To: acx100-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:acx100-devel@lists.sourceforge.net>
List-Help: <mailto:acx100-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=acx100-devel>
List-Id: netdev.vger.kernel.org

--Boundary-00=_eJtAE2W5xX0QzPl
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Sunday 26 February 2006 18:10, Carlos Mart=EDn wrote:
> Hi,
>=20
> Well, here it is. I've not been able to run-test it yet, but it at least=
=20
> compiles and loads without problems. This is on x86_64 compiled against=20
> Linville's wireless-2.6 git tree. (I don't have any x86 boxes running Lin=
ux=20
> right now, but it should be alright).
>=20
> I've added a struct acx_ops with function pointers and deleted the functi=
ons=20
> that just call the PCI/USB version depending on what we're using at the=20
> moment. A few functions I've just made empty to simplify and not having t=
o=20
> check every time wether we do have it or not. These are only called on=20
> load/unload and error conditions. Normal operation shouldn't suffer any s=
peed=20
> decrease it may be faster at times because we dereference a few pointers=
=20
> instead of calling a couple of functions (just guessing, though).
>=20
> The patch is 38K uncompressed. I've compressed and attached it and upload=
ed to=20
> http://www.cmartin.tk/acx/acxsm-modularise.patch
>=20
>    text    data     bss     dec     hex filename
>   55491     588       4   56083    db13 acx-common.ko
>   33523    1040       4   34567    8707 acx-pci.ko
>   17109    1008       0   18117    46c5 acx-usb.ko
>=20
> Comments are welcome and I'll split the patch if needed.

usb.c
=3D=3D=3D=3D=3D
#define BOGUS_SAFETY_PADDING 0x40

int
acxusb_s_issue_cmd_timeo(
        acx_device_t *adev,
        unsigned cmd,
        void *buffer,
        unsigned buflen,
        unsigned timeout)
{
#if ACX_DEBUG
        return acx_s_issue_cmd_timeo_debug(adev, cmd, buffer, buflen, timeo=
ut, __stringify(cmd));
#else
        return acx_s_issue_cmd_timeo_debug(adev, cmd, buffer, buflen, timeo=
ut);
#endif
}

stringify what? We want symbolic command name, not it's numeric value.
stringifying must occur in .h file.


acx_func.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
#if ACX_DEBUG

/* We want to log cmd names */
int acxpci_s_issue_cmd_timeo_debug(acx_device_t *adev, unsigned cmd, void *=
param, unsigned len, unsigned timeout, const char* cmdstr);
int acxusb_s_issue_cmd_timeo_debug(acx_device_t *adev, unsigned cmd, void *=
param, unsigned len, unsigned timeout, const char* cmdstr);
static inline int
acx_s_issue_cmd_timeo_debug(acx_device_t *adev, unsigned cmd, void *param, =
unsigned len, unsigned timeout, const char* cmdstr)
{
        if (IS_PCI(adev))
                return acxpci_s_issue_cmd_timeo_debug(adev, cmd, param, len=
, timeout, cmdstr);
        return acxusb_s_issue_cmd_timeo_debug(adev, cmd, param, len, timeou=
t, cmdstr);
}
int acx_s_issue_cmd(acx_device_t *adev, unsigned cmd, void *param, unsigned=
 len);

It will recurse: acx_s_issue_cmd_timeo_debug -> acxusb_s_issue_cmd_timeo_de=
bug -> acx_s_issue_cmd_timeo_debug ->....
Why do you need if (IS_PCI(adev)) at all?

Please apply the attached style fixes on top of your patches.

Patch is not applied. Sorry.
=2D-
vda

--Boundary-00=_eJtAE2W5xX0QzPl
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="acxsm-modularise2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="acxsm-modularise2.patch"

diff -urpN current_sm.1/acx_func.h current_sm.2/acx_func.h
--- current_sm.1/acx_func.h	Mon Feb 27 12:13:27 2006
+++ current_sm.2/acx_func.h	Mon Feb 27 12:10:32 2006
@@ -444,7 +444,7 @@ int acx_s_interrogate_debug(acx_device_t
 #else
 
 
-/* We can't make this a #define or inline because we need to referece it. */
+/* We can't make this a #define or inline because we need to reference it. */
 int acx_s_issue_cmd(acx_device_t *adev, unsigned cmd, void *param, unsigned len);
 
 int acxpci_s_issue_cmd_timeo(acx_device_t *adev, unsigned cmd, void *param, unsigned len, unsigned timeout);
diff -urpN current_sm.1/common.c current_sm.2/common.c
--- current_sm.1/common.c	Mon Feb 27 12:13:28 2006
+++ current_sm.2/common.c	Mon Feb 27 12:06:33 2006
@@ -331,10 +331,11 @@ acx_log_fn_exit_v(const char *funcname, 
 EXPORT_SYMBOL_GPL(acx_log_fn_exit_v);
 #endif /* ACX_DEBUG > 1 */
 
-int acx_s_issue_cmd(acx_device_t *adev, unsigned cmd, void *param, unsigned len)
+int
+acx_s_issue_cmd(acx_device_t *adev, unsigned cmd, void *param, unsigned len)
 {
-  return adev->ops.issue_cmd_timeo(adev, cmd, param, len,
-				   ACX_CMD_TIMEOUT_DEFAULT);
+	return adev->ops.issue_cmd_timeo(adev, cmd, param, len,
+				ACX_CMD_TIMEOUT_DEFAULT);
 }
 
 EXPORT_SYMBOL_GPL(acx_s_issue_cmd);
@@ -1940,7 +1941,7 @@ acx_s_scan_chan(acx_device_t *adev)
 	FN_EXIT0;
 }
 
- EXPORT_SYMBOL_GPL(acx_s_scan_chan);
+EXPORT_SYMBOL_GPL(acx_s_scan_chan);
 
 void
 acx_s_cmd_start_scan(acx_device_t *adev)
@@ -2059,7 +2060,7 @@ acx111_s_feature_set(acx_device_t *adev,
 /***********************************************************************
 ** acx100_s_init_memory_pools
 */
-int
+static int
 acx100_s_init_memory_pools(acx_device_t *adev, const acx_ie_memmap_t *mmt)
 {
 	acx100_ie_memblocksize_t MemoryBlockSize;
diff -urpN current_sm.1/pci.c current_sm.2/pci.c
--- current_sm.1/pci.c	Mon Feb 27 12:13:28 2006
+++ current_sm.2/pci.c	Mon Feb 27 12:08:30 2006
@@ -3089,7 +3089,11 @@ end:
 	return (tx_t*)txdesc;
 }
 
-void acxpci_l_dealloc_tx(tx_t *tx_opaque){}
+void
+acxpci_l_dealloc_tx(tx_t *tx_opaque)
+{
+}
+
 
 /***********************************************************************
 */

--Boundary-00=_eJtAE2W5xX0QzPl--


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
