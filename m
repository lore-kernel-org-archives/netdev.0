From: Pali =?utf-8?q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: Re: wl1251: NVS firmware data
Date: Sat, 6 Dec 2014 14:02:21 +0100
Message-ID: <201412061402.21514@pali>
References: <201411271506.20457@pali> <20141127155840.GC24149@kroah.com> <20141206124954.GB17289@amd>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3316292.aab7oo1W3o";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Grazvydas Ignotas <notasas@gmail.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
	Aaro Koskinen <aaro.koskinen@iki.fi>,
	Kalle Valo <kvalo@adurom.com>,
	Sebastian Reichel <sre@ring0.de>,
	David Gnedt <david.gnedt@davizone.at>
To: Pavel Machek <pavel@ucw.cz>,
	"Greg Kroah-Hartman" <gregkh@linuxfoundation.org>,
	Ming Lei <ming.lei@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141206124954.GB17289@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart3316292.aab7oo1W3o
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Saturday 06 December 2014 13:49:54 Pavel Machek wrote:
> On Thu 2014-11-27 07:58:40, Greg Kroah-Hartman wrote:
> > On Thu, Nov 27, 2014 at 04:22:58PM +0100, Pali Roh=C3=A1r wrote:
> > > On Thursday 27 November 2014 16:16:55 Greg Kroah-Hartman wrote:
> > > > On Thu, Nov 27, 2014 at 03:43:23PM +0100, Pali Roh=C3=A1r wrote:
> > > > > On Thursday 27 November 2014 15:21:44 Ming Lei wrote:
> > > > > > On Thu, Nov 27, 2014 at 10:06 PM, Pali Roh=C3=A1r
> > > > >=20
> > > > > <pali.rohar@gmail.com> wrote:
> > > > > > > Hello,
> > > > > > >=20
> > > > > > > wifi driver wl1251 needs NVS calibration data for
> > > > > > > working. These data are loaded by driver via
> > > > > > > request_firmware from userspace file:
> > > > > > > ti-connectivity/wl1251-nvs.bin. In linux-fimrware
> > > > > > > git tree there is generic wl1251-nvs.bin file
> > > > > > > which is used by default.
> > > > > > >=20
> > > > > > > Driver wl1251 is used on Nokia N900 cellphone for
> > > > > > > its wifi chip. This cellphone has one special MTD
> > > > > > > partition (called CAL) where are stored some
> > > > > > > configuration data in special binary (key-value)
> > > > > > > format. And there is also stored correct
> > > > > > > calibration data for specific device (each device
> > > > > > > has different data). It is preferred to use those
> > > > > > > data instead generic one (provided by
> > > > > > > linux-firmware git tree).
> > > > > > >=20
> > > > > > > Now my question is: How to correctly load
> > > > > > > calibration data from special Nokia N900 CAL
> > > > > > > partition into wl1251 kernel driver?
> > > > > >=20
> > > > > > It is better to let user space script handle the
> > > > > > request.
> > > > >=20
> > > > > Yes, this makes sense. Implementing CAL parser in
> > > > > kernel wl1251 driver would be hard...
> > > > >=20
> > > > > > > By default kernel reads
> > > > > > > ti-connectivity/wl1251-nvs.bin file from VFS if
> > > > > > > exists without any userspace support. If it fails
> > > > > > > then it fallback to loading via udev.
> > > > > >=20
> > > > > > You can remove or rename this file so that loading
> > > > > > from user space can be triggered.
> > > > >=20
> > > > > It is no so easy... In case when CAL does not contains
> > > > > NVS data then we want to use this generic NVS file.
> > > > > And telling everybody to rename this is file is not
> > > > > good solution...
> > > >=20
> > > > But that's up to your system configuration, not the
> > > > kernel. Make a userspace package for the firmware that
> > > > creates it in the format you need it to be in, for the
> > > > hardware you have, and then there would not be any need
> > > > for a kernel change, right?
> > > >=20
> > > > greg k-h
> > >=20
> > > Not so simple as you think. Some parts of NVS data are
> > > configured based on location and cellular station. Data
> > > are not static.
> >=20
> > Then you need a dynamic program that you control, in
> > userspace, to dump the needed data into the kernel.  Don't
> > try to do it with "static" firmware files.  Use the binary
> > sysfs file interface for this if you want.
>=20
> Actually, this seems to be similar situation to fpga
> programming.
>=20
> There, it is static firmware for 90% users, but some special
> use cases want it more dynamic.
> 									Pavel

Greg, Ming, what do you think about this approach?

diff --git a/drivers/base/firmware_class.c b/drivers/base/firmware_class.c
index 3d785eb..810c4b9 100644
=2D-- a/drivers/base/firmware_class.c
+++ b/drivers/base/firmware_class.c
@@ -111,6 +111,11 @@ static inline long firmware_loading_timeout(void)
 #define FW_OPT_FALLBACK		0
 #endif
 #define FW_OPT_NO_WARN	(1U << 3)
+#ifdef CONFIG_FW_LOADER_USER_HELPER
+#define FW_OPT_PREFER_USER	(1U << 4)
+#else
+#define FW_OPT_PREFER_USER	0
+#endif
=20
 struct firmware_cache {
 	/* firmware_buf instance will be added into the below list */
@@ -1131,7 +1136,20 @@ _request_firmware(const struct firmware **firmware_p=
, const char *name,
 		}
 	}
=20
=2D	ret =3D fw_get_filesystem_firmware(device, fw->priv);
+	if (opt_flags & FW_OPT_PREFER_USER) {
+		ret =3D fw_load_from_user_helper(fw, name, device, opt_flags, timeout);
+		if (ret) {
+			dev_warn(device,
+				 "User helper firmware load for %s failed with error %d\n",
+				 name, ret);
+			dev_warn(device, "Falling back to direct firmware load\n");
+		}
+	} else {
+		ret =3D -EINVAL;
+	}
+
+	if (ret)
+		ret =3D fw_get_filesystem_firmware(device, fw->priv);
 	if (ret) {
 		if (!(opt_flags & FW_OPT_NO_WARN))
 			dev_warn(device,
@@ -1218,6 +1236,28 @@ int request_firmware_direct(const struct firmware **=
firmware_p,
 EXPORT_SYMBOL_GPL(request_firmware_direct);
=20
 /**
+ * request_firmware_prefer_user: - prefer usermode helper for loading firm=
ware
+ * @firmware_p: pointer to firmware image
+ * @name: name of firmware file
+ * @device: device for which firmware is being loaded
+ *
+ * This function works pretty much like request_firmware(), but it prefer
+ * usermode helper. If usermode helper fails then it fallback to direct ac=
cess.
+ * Usefull for dynamic or model specific firmware data.
+ **/
+int request_firmware_prefer_user(const struct firmware **firmware_p,
+			    const char *name, struct device *device)
+{
+	int ret;
+	__module_get(THIS_MODULE);
+	ret =3D _request_firmware(firmware_p, name, device,
+				FW_OPT_UEVENT | FW_OPT_PREFER_USER);
+	module_put(THIS_MODULE);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(request_firmware_prefer_user);
+
+/**
  * release_firmware: - release the resource associated with a firmware ima=
ge
  * @fw: firmware resource to release
  **/
diff --git a/include/linux/firmware.h b/include/linux/firmware.h
index 5c41c5e..d35c511 100644
=2D-- a/include/linux/firmware.h
+++ b/include/linux/firmware.h
@@ -47,6 +47,8 @@ int request_firmware_nowait(
 	void (*cont)(const struct firmware *fw, void *context));
 int request_firmware_direct(const struct firmware **fw, const char *name,
 			    struct device *device);
+int request_firmware_prefer_user(const struct firmware **fw, const char *n=
ame,
+				 struct device *device);
=20
 void release_firmware(const struct firmware *fw);
 #else


=2D-=20
Pali Roh=C3=A1r
pali.rohar@gmail.com

--nextPart3316292.aab7oo1W3o
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAlSC/l0ACgkQi/DJPQPkQ1JFLQCffxwnPouUxVMAHQ+1fdHCJBcK
OUgAnRvWuGeSw8KY8V1TOrX9qSl8FqOJ
=Koho
-----END PGP SIGNATURE-----

--nextPart3316292.aab7oo1W3o--
