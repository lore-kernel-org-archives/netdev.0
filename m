From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net-next] net: qmi_wwan: should hold RTNL while changing netdev type
Date: Sun,  6 Dec 2015 21:25:50 +0100
Message-ID: <1449433550-5616-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The notifier calls were thrown in as a last-minute fix for an
imagined "this device could be part of a bridge" problem. That
revealed a certain lack of locking.  Not to mention testing...

Avoid this splat:

RTNL: assertion failed at net/core/dev.c (1639)
CPU: 0 PID: 4293 Comm: bash Not tainted 4.4.0-rc3+ #358
Hardware name: LENOVO 2776LEG/2776LEG, BIOS 6EET55WW (3.15 ) 12/19/2011
 0000000000000000 ffff8800ad253d60 ffffffff8122f7cf ffff8800ad253d98
 ffff8800ad253d88 ffffffff813833ab 0000000000000002 ffff880230f48560
 ffff880230a12900 ffff8800ad253da0 ffffffff813833da 0000000000000002
Call Trace:
 [<ffffffff8122f7cf>] dump_stack+0x4b/0x63
 [<ffffffff813833ab>] call_netdevice_notifiers_info+0x3d/0x59
 [<ffffffff813833da>] call_netdevice_notifiers+0x13/0x15
 [<ffffffffa09be227>] raw_ip_store+0x81/0x193 [qmi_wwan]
 [<ffffffff8131e149>] dev_attr_store+0x20/0x22
 [<ffffffff811d858b>] sysfs_kf_write+0x49/0x50
 [<ffffffff811d8027>] kernfs_fop_write+0x10a/0x151
 [<ffffffff8117249a>] __vfs_write+0x26/0xa5
 [<ffffffff81085ed4>] ? percpu_down_read+0x53/0x7f
 [<ffffffff81174c9e>] ? __sb_start_write+0x5f/0xb0
 [<ffffffff81174c9e>] ? __sb_start_write+0x5f/0xb0
 [<ffffffff81172c37>] vfs_write+0xa3/0xe7
 [<ffffffff811734ad>] SyS_write+0x50/0x7e
 [<ffffffff8145c517>] entry_SYSCALL_64_fastpath+0x12/0x6f

=46ixes: 32f7adf633b9 ("net: qmi_wwan: support "raw IP" mode")
Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
 drivers/net/usb/qmi_wwan.c | 22 +++++++++++++++-------
 1 file changed, 15 insertions(+), 7 deletions(-)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 9cc361b06909..fa9e55435f61 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -16,6 +16,7 @@
 #include <linux/etherdevice.h>
 #include <linux/if_arp.h>
 #include <linux/mii.h>
+#include <linux/rtnetlink.h>
 #include <linux/usb.h>
 #include <linux/usb/cdc.h>
 #include <linux/usb/usbnet.h>
@@ -92,7 +93,7 @@ static ssize_t raw_ip_store(struct device *d,  struct=
 device_attribute *attr, co
 	struct usbnet *dev =3D netdev_priv(to_net_dev(d));
 	struct qmi_wwan_state *info =3D (void *)&dev->data;
 	bool enable;
-	int err;
+	int ret;
=20
 	if (strtobool(buf, &enable))
 		return -EINVAL;
@@ -101,18 +102,22 @@ static ssize_t raw_ip_store(struct device *d,  st=
ruct device_attribute *attr, co
 	if (enable =3D=3D (info->flags & QMI_WWAN_FLAG_RAWIP))
 		return len;
=20
+	if (!rtnl_trylock())
+		return restart_syscall();
+
 	/* we don't want to modify a running netdev */
 	if (netif_running(dev->net)) {
 		netdev_err(dev->net, "Cannot change a running device\n");
-		return -EBUSY;
+		ret =3D -EBUSY;
+		goto err;
 	}
=20
 	/* let other drivers deny the change */
-	err =3D call_netdevice_notifiers(NETDEV_PRE_TYPE_CHANGE, dev->net);
-	err =3D notifier_to_errno(err);
-	if (err) {
+	ret =3D call_netdevice_notifiers(NETDEV_PRE_TYPE_CHANGE, dev->net);
+	ret =3D notifier_to_errno(ret);
+	if (ret) {
 		netdev_err(dev->net, "Type change was refused\n");
-		return err;
+		goto err;
 	}
=20
 	if (enable)
@@ -121,7 +126,10 @@ static ssize_t raw_ip_store(struct device *d,  str=
uct device_attribute *attr, co
 		info->flags &=3D ~QMI_WWAN_FLAG_RAWIP;
 	qmi_wwan_netdev_setup(dev->net);
 	call_netdevice_notifiers(NETDEV_POST_TYPE_CHANGE, dev->net);
-	return len;
+	ret =3D len;
+err:
+	rtnl_unlock();
+	return ret;
 }
=20
 static DEVICE_ATTR_RW(raw_ip);
--=20
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
