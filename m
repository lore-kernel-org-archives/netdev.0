From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Please pull 'fixes-davem' branch of wireless-2.6
Date: Tue, 8 Jan 2008 00:14:25 -0500
Message-ID: <20080108051425.GA3125@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Two more fixes for 2.6.24.  I think they are self-explanatory --
let me know if I'm too optimistic! :-)

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/fixes-davem

---

The following changes since commit 3ce54450461bad18bbe1f9f5aa3ecd2f8e8d1235:
  Linus Torvalds (1):
        Linux 2.6.24-rc7

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git fixes-davem

Andrew Lutomirski (1):
      mac80211: return an error when SIWRATE doesn't match any rate

Michael Buesch (1):
      ssb: Fix probing of PCI cores if PCI and PCIE core is available

 drivers/ssb/scan.c             |   11 +++++++++++
 net/mac80211/ieee80211_ioctl.c |    6 +++---
 2 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/drivers/ssb/scan.c b/drivers/ssb/scan.c
index 96258c6..63ee5cf 100644
--- a/drivers/ssb/scan.c
+++ b/drivers/ssb/scan.c
@@ -388,6 +388,17 @@ int ssb_bus_scan(struct ssb_bus *bus,
 		case SSB_DEV_PCI:
 		case SSB_DEV_PCIE:
 #ifdef CONFIG_SSB_DRIVER_PCICORE
+			if (bus->bustype == SSB_BUSTYPE_PCI) {
+				/* Ignore PCI cores on PCI-E cards.
+				 * Ignore PCI-E cores on PCI cards. */
+				if (dev->id.coreid == SSB_DEV_PCI) {
+					if (bus->host_pci->is_pcie)
+						continue;
+				} else {
+					if (!bus->host_pci->is_pcie)
+						continue;
+				}
+			}
 			if (bus->pcicore.dev) {
 				ssb_printk(KERN_WARNING PFX
 					   "WARNING: Multiple PCI(E) cores found\n");
diff --git a/net/mac80211/ieee80211_ioctl.c b/net/mac80211/ieee80211_ioctl.c
index 7027eed..308bbe4 100644
--- a/net/mac80211/ieee80211_ioctl.c
+++ b/net/mac80211/ieee80211_ioctl.c
@@ -591,7 +591,7 @@ static int ieee80211_ioctl_siwrate(struct net_device *dev,
 	sdata->bss->force_unicast_rateidx = -1;
 	if (rate->value < 0)
 		return 0;
-	for (i=0; i< mode->num_rates; i++) {
+	for (i=0; i < mode->num_rates; i++) {
 		struct ieee80211_rate *rates = &mode->rates[i];
 		int this_rate = rates->rate;
 
@@ -599,10 +599,10 @@ static int ieee80211_ioctl_siwrate(struct net_device *dev,
 			sdata->bss->max_ratectrl_rateidx = i;
 			if (rate->fixed)
 				sdata->bss->force_unicast_rateidx = i;
-			break;
+			return 0;
 		}
 	}
-	return 0;
+	return -EINVAL;
 }
 
 static int ieee80211_ioctl_giwrate(struct net_device *dev,
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
