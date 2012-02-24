From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 10/12] wireless: check given MAC address, if invalid return -EADDRNOTAVAIL
Date: Fri, 24 Feb 2012 17:01:20 +0100
Message-ID: <1330099282-4588-11-git-send-email-danny.kukawka@bisect.de>
References: <1330099282-4588-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>, linux-wireless@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, libertas-dev@lists.infradead.org
To: "John W. Linville" <linville@tuxdriver.com>,
	Simon Kelley <simon@thekelleys.org.uk>,
	Brett Rudley <brudley@broadcom.com>,
	Henry Ptasinski <henryp@broadcom.com>,
	Roland Vossen <rvossen@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Kan Yan <kanyan@broadcom.com>, Jouni Malinen <j@w1.fi>,
	Dan Williams <dcbw@redhat.com>, Bing Zhao <bzhao@marvell.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330099282-4588-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Check if given address is valid in .ndo_set_mac_address, if
invalid return -EADDRNOTAVAIL as eth_mac_addr() already does
if is_valid_ether_addr() fails.

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/wireless/airo.c                        |    3 +++
 drivers/net/wireless/atmel.c                       |    3 +++
 .../net/wireless/brcm80211/brcmfmac/dhd_linux.c    |    5 ++++-
 drivers/net/wireless/hostap/hostap_main.c          |    3 +++
 drivers/net/wireless/libertas/main.c               |    3 +++
 drivers/net/wireless/mwifiex/main.c                |    3 +++
 drivers/net/wireless/zd1201.c                      |    2 ++
 7 files changed, 21 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index 1c008c6..a205332 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -2320,6 +2320,9 @@ static int airo_set_mac_address(struct net_device *dev, void *p)
 	struct airo_info *ai = dev->ml_priv;
 	struct sockaddr *addr = p;
 
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+
 	readConfigRid(ai, 1);
 	memcpy (ai->config.macAddr, addr->sa_data, dev->addr_len);
 	set_bit (FLAG_COMMIT, &ai->flags);
diff --git a/drivers/net/wireless/atmel.c b/drivers/net/wireless/atmel.c
index 3010cee..1abeb0e 100644
--- a/drivers/net/wireless/atmel.c
+++ b/drivers/net/wireless/atmel.c
@@ -1309,6 +1309,9 @@ static int atmel_set_mac_address(struct net_device *dev, void *p)
 {
 	struct sockaddr *addr = p;
 
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+
 	memcpy (dev->dev_addr, addr->sa_data, dev->addr_len);
 	return atmel_open(dev);
 }
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c b/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c
index db2df1f..d192758 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c
@@ -257,7 +257,10 @@ static int brcmf_netdev_set_mac_address(struct net_device *ndev, void *addr)
 {
 	struct brcmf_if *ifp = netdev_priv(ndev);
 	struct brcmf_pub *drvr = ifp->drvr;
-	struct sockaddr *sa = (struct sockaddr *)addr;
+	struct sockaddr *sa = addr;
+
+	if (!is_valid_ether_addr(sa->sa_data))
+		return -EADDRNOTAVAIL;
 
 	memcpy(&drvr->macvalue, sa->sa_data, ETH_ALEN);
 	schedule_work(&drvr->setmacaddr_work);
diff --git a/drivers/net/wireless/hostap/hostap_main.c b/drivers/net/wireless/hostap/hostap_main.c
index bfa0d54..0c475d3 100644
--- a/drivers/net/wireless/hostap/hostap_main.c
+++ b/drivers/net/wireless/hostap/hostap_main.c
@@ -713,6 +713,9 @@ static int prism2_set_mac_address(struct net_device *dev, void *p)
 	iface = netdev_priv(dev);
 	local = iface->local;
 
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+
 	if (local->func->set_rid(dev, HFA384X_RID_CNFOWNMACADDR, addr->sa_data,
 				 ETH_ALEN) < 0 || local->func->reset_port(dev))
 		return -EINVAL;
diff --git a/drivers/net/wireless/libertas/main.c b/drivers/net/wireless/libertas/main.c
index 957681d..33bf268 100644
--- a/drivers/net/wireless/libertas/main.c
+++ b/drivers/net/wireless/libertas/main.c
@@ -297,6 +297,9 @@ int lbs_set_mac_address(struct net_device *dev, void *addr)
 
 	lbs_deb_enter(LBS_DEB_NET);
 
+	if (!is_valid_ether_addr(phwaddr->sa_data))
+		return -EADDRNOTAVAIL;
+
 	/*
 	 * Can only set MAC address when all interfaces are down, to be written
 	 * to the hardware when one of them is brought up.
diff --git a/drivers/net/wireless/mwifiex/main.c b/drivers/net/wireless/mwifiex/main.c
index 790a379..7b43109 100644
--- a/drivers/net/wireless/mwifiex/main.c
+++ b/drivers/net/wireless/mwifiex/main.c
@@ -485,6 +485,9 @@ mwifiex_set_mac_address(struct net_device *dev, void *addr)
 	struct sockaddr *hw_addr = addr;
 	int ret;
 
+	if (!is_valid_ether_addr(hw_addr->sa_data))
+		return -EADDRNOTAVAIL;
+
 	memcpy(priv->curr_addr, hw_addr->sa_data, ETH_ALEN);
 
 	/* Send request to firmware */
diff --git a/drivers/net/wireless/zd1201.c b/drivers/net/wireless/zd1201.c
index a66b93b..60bc0ea 100644
--- a/drivers/net/wireless/zd1201.c
+++ b/drivers/net/wireless/zd1201.c
@@ -853,6 +853,8 @@ static int zd1201_set_mac_address(struct net_device *dev, void *p)
 
 	if (!zd)
 		return -ENODEV;
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
 
 	err = zd1201_setconfig(zd, ZD1201_RID_CNFOWNMACADDR, 
 	    addr->sa_data, dev->addr_len, 1);
-- 
1.7.8.3
