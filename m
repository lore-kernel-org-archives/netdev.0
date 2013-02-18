From: Felipe Balbi <balbi@ti.com>
Subject: Re: SYSFS "errors"
Date: Mon, 18 Feb 2013 23:57:43 +0200
Message-ID: <20130218215743.GA21192@arwen.pp.htv.fi>
References: <20130218184633.GC10755@arwen.pp.htv.fi>
 <Pine.LNX.4.44L0.1302181644260.6790-100000@netrider.rowland.org>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="VS++wcV0S1rZb1Fb"
Cc: Felipe Balbi <balbi@ti.com>, Greg KH <gregkh@linuxfoundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Ingo Molnar <mingo@redhat.com>, <JBottomley@parallels.com>,
	<linux-scsi@vger.kernel.org>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>,
	Doug Thompson <dougthompson@xmission.com>,
	<linux-edac@vger.kernel.org>, <rjw@sisk.pl>,
	<linux-pm@vger.kernel.org>
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <linux-pm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44L0.1302181644260.6790-100000@netrider.rowland.org>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--VS++wcV0S1rZb1Fb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Feb 18, 2013 at 04:48:06PM -0500, Alan Stern wrote:
> On Mon, 18 Feb 2013, Felipe Balbi wrote:
>=20
> > Hi, On Mon, Feb 18, 2013 at 09:49:16AM -0800, Greg KH wrote:
> > > > Input/output error - /sys/devices/cpu/power/autosuspend_delay_ms
> > >=20
> > > The issue with this file is, if the power.use_autosuspend flag is not
> > > set for the device, then it can't be read or written to.  This flag
> > > changes dynamically with the system state
> > > (__pm_runtime_use_autosuspend() can change it), so we can't just not
> > > show the file if the flag is not set properly, sorry.
> > >=20
> > > So the "error" is correct here, as is the 0644 file value.
> >=20
> > hmm... we could create the file at pm_runtime_enable() time and remove
> > it on pm_runtime_disable() time, no ? Addin Rafael to Cc
>=20
> In theory this could be done, although the times would be when runtime=20
> autosuspend is turned on or off, not when pm_runtime_enable is called.

Right, I got that after replying. Here's a patch I plan to test
tomorrow:

8<------------------------ cut here ----------------------------

=46rom 2cdeeb483383490946cc98727a167843c40d7d27 Mon Sep 17 00:00:00 2001
=46rom: Felipe Balbi <balbi@ti.com>
Date: Mon, 18 Feb 2013 21:20:28 +0200
Subject: [PATCH] base: power: create autosuspend_delay_ms from
 pm_runtime_use_autosuspend()

this patch moves the creation of autosuspend_delay_ms
sysfs file to pm_runtime_use_autosuspend() and, conversely,
its deletion to pm_runtime_dont_use_autosuspend.

The idea behind this patch is such that the file in
question is only readable after pm_runtime_use_autosuspend()
has been called for a particular device, so we might
as well move the creation of the file to that place.

Signed-off-by: Felipe Balbi <balbi@ti.com>
---
 drivers/base/power/power.h   |  4 ++++
 drivers/base/power/runtime.c |  6 ++++++
 drivers/base/power/sysfs.c   | 25 ++++++++++++++++++++++++-
 3 files changed, 34 insertions(+), 1 deletion(-)

diff --git a/drivers/base/power/power.h b/drivers/base/power/power.h
index b16686a..3822b94 100644
--- a/drivers/base/power/power.h
+++ b/drivers/base/power/power.h
@@ -90,6 +90,8 @@ static inline void device_pm_init(struct device *dev)
=20
 extern int dpm_sysfs_add(struct device *dev);
 extern void dpm_sysfs_remove(struct device *dev);
+extern int dpm_autosuspend_sysfs_add(struct device *dev);
+extern void dpm_autosuspend_sysfs_remove(struct device *dev);
 extern void rpm_sysfs_remove(struct device *dev);
 extern int wakeup_sysfs_add(struct device *dev);
 extern void wakeup_sysfs_remove(struct device *dev);
@@ -102,6 +104,8 @@ extern void pm_qos_sysfs_remove_flags(struct device *de=
v);
=20
 static inline int dpm_sysfs_add(struct device *dev) { return 0; }
 static inline void dpm_sysfs_remove(struct device *dev) {}
+static inline int dpm_autosuspend_sysfs_add(struct device *dev) { return 0=
; }
+static inline void dpm_autosuspend_sysfs_remove(struct device *dev) {}
 static inline void rpm_sysfs_remove(struct device *dev) {}
 static inline int wakeup_sysfs_add(struct device *dev) { return 0; }
 static inline void wakeup_sysfs_remove(struct device *dev) {}
diff --git a/drivers/base/power/runtime.c b/drivers/base/power/runtime.c
index 3148b10..a162ba5 100644
--- a/drivers/base/power/runtime.c
+++ b/drivers/base/power/runtime.c
@@ -1266,6 +1266,12 @@ void __pm_runtime_use_autosuspend(struct device *dev=
, bool use)
 	old_use =3D dev->power.use_autosuspend;
 	dev->power.use_autosuspend =3D use;
 	update_autosuspend(dev, old_delay, old_use);
+
+	if (use)
+		dpm_autosuspend_sysfs_add(dev);
+	else
+		dpm_autosuspend_sysfs_remove(dev);
+
 	spin_unlock_irq(&dev->power.lock);
 }
 EXPORT_SYMBOL_GPL(__pm_runtime_use_autosuspend);
diff --git a/drivers/base/power/sysfs.c b/drivers/base/power/sysfs.c
index 50d16e3..ef2a41c 100644
--- a/drivers/base/power/sysfs.c
+++ b/drivers/base/power/sysfs.c
@@ -609,15 +609,26 @@ static struct attribute *runtime_attrs[] =3D {
 	&dev_attr_control.attr,
 	&dev_attr_runtime_suspended_time.attr,
 	&dev_attr_runtime_active_time.attr,
-	&dev_attr_autosuspend_delay_ms.attr,
 #endif /* CONFIG_PM_RUNTIME */
 	NULL,
 };
+
 static struct attribute_group pm_runtime_attr_group =3D {
 	.name	=3D power_group_name,
 	.attrs	=3D runtime_attrs,
 };
=20
+static struct attribute *runtime_autosuspend_attrs[] =3D {
+#ifdef CONFIG_PM_RUNTIME
+	&dev_attr_autosuspend_delay_ms.attr,
+#endif /* CONFIG_PM_RUNTIME */
+};
+
+static struct attribute_group pm_runtime_autosuspend_attr_group =3D {
+	.name	=3D power_group_name,
+	.attrs	=3D runtime_autosuspend_attrs,
+};
+
 static struct attribute *pm_qos_latency_attrs[] =3D {
 #ifdef CONFIG_PM_RUNTIME
 	&dev_attr_pm_qos_resume_latency_us.attr,
@@ -671,6 +682,12 @@ int dpm_sysfs_add(struct device *dev)
 	return rc;
 }
=20
+int dpm_autosuspend_sysfs_add(struct device *dev)
+{
+	return sysfs_merge_group(&dev->kobj,
+			&pm_runtime_autosuspend_attr_group);
+}
+
 int wakeup_sysfs_add(struct device *dev)
 {
 	return sysfs_merge_group(&dev->kobj, &pm_wakeup_attr_group);
@@ -712,3 +729,9 @@ void dpm_sysfs_remove(struct device *dev)
 	sysfs_unmerge_group(&dev->kobj, &pm_wakeup_attr_group);
 	sysfs_remove_group(&dev->kobj, &pm_attr_group);
 }
+
+void dpm_autosuspend_sysfs_remove(struct device *dev)
+{
+	sysfs_unmerge_group(&dev->kobj,
+			&pm_runtime_autosuspend_attr_group);
+}
--=20
1.8.1.rc1.5.g7e0651a

--=20
balbi

--VS++wcV0S1rZb1Fb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJRIqPWAAoJEIaOsuA1yqREKKQP+gNtEHdA0IaJNfVwCokXa9jF
4l8AWz8Kxxyckwrn8XPHCCzIXVWuXzIdr0fkZ8A97pz7Ibn6WinNC7Bezk07+hDI
x1Th8D1BrvCj/wvv/R5rUFGoiZl/9ABF1ihukQDmgObbrXGQEuEMRfqnE6Tj7k2L
+7dnA4Rpj9KN06GGQNk2HiQ7aa8zQ2ezD1vFZ/aarec5vTCyFVxEpUD8fHzTyUNK
uAvdqslKmpAyktrj5zrFGWKkvmJmd9oYlFrN58OgVWPjqWobmdEBw/8j/wUHNKR2
9PMsjGpb+CO3iLcJBKLehaI6P44Fwpeytgw/j7XM6YO3JsOJYtHES6r1/JNhuhJ+
MbImAaGDwtQwElQH4IkN2ujWIPAzxhfo806HEBTDjtXjMo8jKaYw+eG9jC+4zSct
0Cd3IQ7zVfklYw1Jv5SJGJ8xzI0BO/unxnilB/pmdNJYY97tBJd/G2ev4hc/5KA2
aEL3fappD/l9i3vc6Hz4eIfxuIupU7FO8pbinlEGsQa4D0UueSwaCPn0kl0e1GQ+
vrxexnERS5q2Wa1slLQ6mrT6C2fDmjuRjpfle72jBm6ZFW149So/ackKgQB1fBXh
O8GJNippgaREW9Bza31URJz7VhsZgeJlbMB2+bHnf31873jjfCa0CLGNujXp1O0p
rvMwqOd3xFaJiFHtcaNg
=QpVH
-----END PGP SIGNATURE-----

--VS++wcV0S1rZb1Fb--
