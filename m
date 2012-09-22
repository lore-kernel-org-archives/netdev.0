From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless 2012-09-22
Date: Sat, 22 Sep 2012 13:13:42 -0400
Message-ID: <20120922171341.GB2101@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="fdj2RfSjLxBAspz7"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--fdj2RfSjLxBAspz7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit 1199992df2417dc9a1db1b19930ea4d0a697a61e

Dave,

Please pull this last(?) batch of fixes intended for 3.6...

For the Bluetooth bits, Gustavo says this:

"Here goes probably my last update to 3.6. It includes the two patches
you were ok last week(from Andrzej Kaczmarek), those are critical
ones, and two other fixes one for a system crash and the other for
a missing lockdep annotation."

The referenced fixes from Andrzej prevent attempts to configure devices
that are powered-off.

Along with the Bluetooth fixes, there are a couple of 802.11 fixes.
Emmanuel Grumbach gives us an iwlwifi fix to prevent releasing an
interrupt twice.  Luis R. Rodriguez provides a fix for a possible
circular lock dependency in the cfg80211 regulatory enforcement code.

All of these have been in linux-next for a few days.  I hope they are
not too late to make the 3.6 release!

Thanks,

John

---

The following changes since commit abef3bd71029b80ec1bdd6c6244b5b0b99f56633:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2012-09-21=
 14:32:55 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to 1199992df2417dc9a1db1b19930ea4d0a697a61e:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2012-09-22 12:19:22 -0400)

----------------------------------------------------------------

Andrei Emeltchenko (1):
      Bluetooth: Fix freeing uninitialized delayed works

Andrzej Kaczmarek (2):
      Bluetooth: mgmt: Fix enabling SSP while powered off
      Bluetooth: mgmt: Fix enabling LE while powered off

Emmanuel Grumbach (1):
      iwlwifi: don't double free the interrupt in failure path

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Luis R. Rodriguez (1):
      cfg80211: fix possible circular lock on reg_regdb_search()

Vinicius Costa Gomes (1):
      Bluetooth: Fix not removing power_off delayed work

 drivers/net/wireless/iwlwifi/pcie/trans.c |  1 +
 net/bluetooth/hci_core.c                  |  2 ++
 net/bluetooth/l2cap_core.c                |  2 +-
 net/bluetooth/mgmt.c                      | 16 ++++++++++++++++
 net/wireless/reg.c                        | 12 +++++++++---
 5 files changed, 29 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/pcie/trans.c b/drivers/net/wirele=
ss/iwlwifi/pcie/trans.c
index 1e86ea2..dbeebef 100644
--- a/drivers/net/wireless/iwlwifi/pcie/trans.c
+++ b/drivers/net/wireless/iwlwifi/pcie/trans.c
@@ -1442,6 +1442,7 @@ static int iwl_trans_pcie_start_hw(struct iwl_trans *=
trans)
 	return err;
=20
 err_free_irq:
+	trans_pcie->irq_requested =3D false;
 	free_irq(trans_pcie->irq, trans);
 error:
 	iwl_free_isr_ict(trans);
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index d4de5db..0b997c8 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -734,6 +734,8 @@ static int hci_dev_do_close(struct hci_dev *hdev)
=20
 	cancel_work_sync(&hdev->le_scan);
=20
+	cancel_delayed_work(&hdev->power_off);
+
 	hci_req_cancel(hdev, ENODEV);
 	hci_req_lock(hdev);
=20
diff --git a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
index 4ea1710..38c00f1 100644
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@ -1008,7 +1008,7 @@ static void l2cap_send_disconn_req(struct l2cap_conn =
*conn, struct l2cap_chan *c
 	if (!conn)
 		return;
=20
-	if (chan->mode =3D=3D L2CAP_MODE_ERTM) {
+	if (chan->mode =3D=3D L2CAP_MODE_ERTM && chan->state =3D=3D BT_CONNECTED)=
 {
 		__clear_retrans_timer(chan);
 		__clear_monitor_timer(chan);
 		__clear_ack_timer(chan);
diff --git a/net/bluetooth/mgmt.c b/net/bluetooth/mgmt.c
index ad6613d..eba022d 100644
--- a/net/bluetooth/mgmt.c
+++ b/net/bluetooth/mgmt.c
@@ -2875,6 +2875,22 @@ int mgmt_powered(struct hci_dev *hdev, u8 powered)
 		if (scan)
 			hci_send_cmd(hdev, HCI_OP_WRITE_SCAN_ENABLE, 1, &scan);
=20
+		if (test_bit(HCI_SSP_ENABLED, &hdev->dev_flags)) {
+			u8 ssp =3D 1;
+
+			hci_send_cmd(hdev, HCI_OP_WRITE_SSP_MODE, 1, &ssp);
+		}
+
+		if (test_bit(HCI_LE_ENABLED, &hdev->dev_flags)) {
+			struct hci_cp_write_le_host_supported cp;
+
+			cp.le =3D 1;
+			cp.simul =3D !!(hdev->features[6] & LMP_SIMUL_LE_BR);
+
+			hci_send_cmd(hdev, HCI_OP_WRITE_LE_HOST_SUPPORTED,
+				     sizeof(cp), &cp);
+		}
+
 		update_class(hdev);
 		update_name(hdev, hdev->dev_name);
 		update_eir(hdev);
diff --git a/net/wireless/reg.c b/net/wireless/reg.c
index 2ded3c7..72d170c 100644
--- a/net/wireless/reg.c
+++ b/net/wireless/reg.c
@@ -350,6 +350,9 @@ static void reg_regdb_search(struct work_struct *work)
 	struct reg_regdb_search_request *request;
 	const struct ieee80211_regdomain *curdom, *regdom;
 	int i, r;
+	bool set_reg =3D false;
+
+	mutex_lock(&cfg80211_mutex);
=20
 	mutex_lock(&reg_regdb_search_mutex);
 	while (!list_empty(&reg_regdb_search_list)) {
@@ -365,9 +368,7 @@ static void reg_regdb_search(struct work_struct *work)
 				r =3D reg_copy_regd(&regdom, curdom);
 				if (r)
 					break;
-				mutex_lock(&cfg80211_mutex);
-				set_regdom(regdom);
-				mutex_unlock(&cfg80211_mutex);
+				set_reg =3D true;
 				break;
 			}
 		}
@@ -375,6 +376,11 @@ static void reg_regdb_search(struct work_struct *work)
 		kfree(request);
 	}
 	mutex_unlock(&reg_regdb_search_mutex);
+
+	if (set_reg)
+		set_regdom(regdom);
+
+	mutex_unlock(&cfg80211_mutex);
 }
=20
 static DECLARE_WORK(reg_regdb_work, reg_regdb_search);
--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.

--fdj2RfSjLxBAspz7
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQXfHFAAoJEJctW/TcYTgGreUP/RTMyeMKMv27VXxxuizAcKUR
ytLUU5W7Btyd6N/dVqMeLyq9gKCRZjCu+v+tLtnMHzvkJmO929i98aCkDCe8NRUj
gvx/X/0wcSMIqg5AF+WgIX3BVZBSXsqN1YldJPMfEvExigW7T7MSFMDZuE2kzQp0
Airv35EWkrSlzeqp6EoOtRun3OhAA/fmaUeATgTfMLQmtzoA32JRz0Hw4ka1oL1l
uCaS2TPfu/ixLJFPekUDgDMCRiB8NSI2EO73FZgpxDOqBjRKgHIme7EcyC/+t8Jx
u5RIcZQHSBkuTOnE6PvKbGej4yYWLPybP/RKx9la18Tu0EVibP01SzdK3wI4BY4Q
WCQ8T5YxL0PiEH7ezybXTX4nCgfQJX925qsVefj7Jb7BbZsUCF9n8U5ZuH+zwjxI
yH9Hv7k1mVUZ1O1/8fj+AqEohvaVmhY+XfCRp4UUjzu+9GT9osCh7P2i+w9+2T7j
6RyIbh54zuQdUrmZ69wf3dxRTXf6FNb9wFYV9DXs7Q2HRa2AuNdIhl23CGVgj1Xj
+J13qoP4hnr5aBkNMSThmx7pR9Af26Mi/TpAhtNtOSeSGrRI0bANKJdOP5FQ7TJF
TDnfhOJdx4/+rJmtWpqztrGW2U0KMR0Zy5jA3YmUanCpk1SXIOFnLbprBfZ+0ZAY
VBTEoITy+H/xGXNSTITH
=oTzo
-----END PGP SIGNATURE-----

--fdj2RfSjLxBAspz7--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
