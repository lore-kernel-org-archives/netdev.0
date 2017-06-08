From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net tree
Date: Thu, 8 Jun 2017 10:08:58 +1000
Message-ID: <20170608100858.4c1b18db@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Hans de Goede <hdegoede@redhat.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

After merging the net tree, today's linux-next build (x86_64 allmodconfig)
failed like this:

drivers/staging/rtl8723bs/os_dep/ioctl_cfg80211.c: In function 'rtw_cfg80211_add_monitor_if':
drivers/staging/rtl8723bs/os_dep/ioctl_cfg80211.c:2670:10: error: 'struct net_device' has no member named 'destructor'
  mon_ndev->destructor = rtw_ndev_destructor;
          ^

Caused by commit

  cf124db566e6 ("net: Fix inconsistent teardown and release of private netdev state.")

from the net tree interacting with commit

  554c0a3abf21 ("staging: Add rtl8723bs sdio wifi driver"

from Linus' tree (v4.12-rc1).

I applied the following merge fix patch for today.

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 8 Jun 2017 09:49:26 +1000
Subject: [PATCH] net: fix up for "Fix inconsistent teardown and release of private netdev state"

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/staging/rtl8723bs/os_dep/ioctl_cfg80211.c | 3 ++-
 drivers/staging/rtl8723bs/os_dep/os_intfs.c       | 2 --
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/rtl8723bs/os_dep/ioctl_cfg80211.c b/drivers/staging/rtl8723bs/os_dep/ioctl_cfg80211.c
index 36c3189fc4b7..bd4352fe2de3 100644
--- a/drivers/staging/rtl8723bs/os_dep/ioctl_cfg80211.c
+++ b/drivers/staging/rtl8723bs/os_dep/ioctl_cfg80211.c
@@ -2667,7 +2667,8 @@ static int rtw_cfg80211_add_monitor_if (struct adapter *padapter, char *name, st
 	mon_ndev->type = ARPHRD_IEEE80211_RADIOTAP;
 	strncpy(mon_ndev->name, name, IFNAMSIZ);
 	mon_ndev->name[IFNAMSIZ - 1] = 0;
-	mon_ndev->destructor = rtw_ndev_destructor;
+	mon_ndev->needs_free_netdev = true;
+	mon_ndev->priv_destructor = rtw_ndev_destructor;
 
 	mon_ndev->netdev_ops = &rtw_cfg80211_monitor_if_ops;
 
diff --git a/drivers/staging/rtl8723bs/os_dep/os_intfs.c b/drivers/staging/rtl8723bs/os_dep/os_intfs.c
index f83cfc76505c..021589913681 100644
--- a/drivers/staging/rtl8723bs/os_dep/os_intfs.c
+++ b/drivers/staging/rtl8723bs/os_dep/os_intfs.c
@@ -1207,8 +1207,6 @@ void rtw_ndev_destructor(struct net_device *ndev)
 
 	if (ndev->ieee80211_ptr)
 		kfree((u8 *)ndev->ieee80211_ptr);
-
-	free_netdev(ndev);
 }
 
 void rtw_dev_unload(struct adapter *padapter)
-- 
2.11.0

-- 
Cheers,
Stephen Rothwell
