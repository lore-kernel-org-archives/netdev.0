From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Please pull 'upstream-fixes' branch of wireless-2.6
Date: Tue, 29 May 2007 14:30:37 -0400
Message-ID: <20070529183037.GB3496@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The following changes since commit c420bc9f09a0926b708c3edb27eacba434a4=
f4ba:
  Linus Torvalds (1):
        Linux 2.6.22-rc3

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.g=
it upstream-fixes

Akinobu Mita (2):
      ieee80211: fix incomplete error message
      softmac: alloc_ieee80211() NULL check

Bj=F6rn Steinbrink (1):
      prism54: fix monitor mode oops

Brandon Craig Rhodes (1):
      hostap: Allocate enough tailroom for TKIP

 drivers/net/wireless/hostap/hostap_80211_tx.c   |   13 ++++++++-----
 drivers/net/wireless/prism54/islpci_eth.c       |    5 +++--
 net/ieee80211/ieee80211_module.c                |    2 +-
 net/ieee80211/softmac/ieee80211softmac_module.c |    5 ++++-
 4 files changed, 16 insertions(+), 9 deletions(-)

diff --git a/drivers/net/wireless/hostap/hostap_80211_tx.c b/drivers/ne=
t/wireless/hostap/hostap_80211_tx.c
index 246fac0..3df3c60 100644
--- a/drivers/net/wireless/hostap/hostap_80211_tx.c
+++ b/drivers/net/wireless/hostap/hostap_80211_tx.c
@@ -311,7 +311,7 @@ static struct sk_buff * hostap_tx_encrypt(struct sk=
_buff *skb,
 	local_info_t *local;
 	struct ieee80211_hdr_4addr *hdr;
 	u16 fc;
-	int hdr_len, res;
+	int prefix_len, postfix_len, hdr_len, res;
=20
 	iface =3D netdev_priv(skb->dev);
 	local =3D iface->local;
@@ -337,10 +337,13 @@ static struct sk_buff * hostap_tx_encrypt(struct =
sk_buff *skb,
 	if (skb =3D=3D NULL)
 		return NULL;
=20
-	if ((skb_headroom(skb) < crypt->ops->extra_mpdu_prefix_len ||
-	     skb_tailroom(skb) < crypt->ops->extra_mpdu_postfix_len) &&
-	    pskb_expand_head(skb, crypt->ops->extra_mpdu_prefix_len,
-			     crypt->ops->extra_mpdu_postfix_len, GFP_ATOMIC)) {
+	prefix_len =3D crypt->ops->extra_mpdu_prefix_len +
+		crypt->ops->extra_msdu_prefix_len;
+	postfix_len =3D crypt->ops->extra_mpdu_postfix_len +
+		crypt->ops->extra_msdu_postfix_len;
+	if ((skb_headroom(skb) < prefix_len ||
+	     skb_tailroom(skb) < postfix_len) &&
+	    pskb_expand_head(skb, prefix_len, postfix_len, GFP_ATOMIC)) {
 		kfree_skb(skb);
 		return NULL;
 	}
diff --git a/drivers/net/wireless/prism54/islpci_eth.c b/drivers/net/wi=
reless/prism54/islpci_eth.c
index dd070cc..f49eb06 100644
--- a/drivers/net/wireless/prism54/islpci_eth.c
+++ b/drivers/net/wireless/prism54/islpci_eth.c
@@ -378,9 +378,10 @@ islpci_eth_receive(islpci_private *priv)
 	display_buffer((char *) skb->data, skb->len);
 #endif
 	/* take care of monitor mode and spy monitoring. */
-	if (unlikely(priv->iw_mode =3D=3D IW_MODE_MONITOR))
+	if (unlikely(priv->iw_mode =3D=3D IW_MODE_MONITOR)) {
+		skb->dev =3D ndev;
 		discard =3D islpci_monitor_rx(priv, &skb);
-	else {
+	} else {
 		if (unlikely(skb->data[2 * ETH_ALEN] =3D=3D 0)) {
 			/* The packet has a rx_annex. Read it for spy monitoring, Then
 			 * remove it, while keeping the 2 leading MAC addr.
diff --git a/net/ieee80211/ieee80211_module.c b/net/ieee80211/ieee80211=
_module.c
index 7ec6610..17ad278 100644
--- a/net/ieee80211/ieee80211_module.c
+++ b/net/ieee80211/ieee80211_module.c
@@ -140,7 +140,7 @@ struct net_device *alloc_ieee80211(int sizeof_priv)
=20
 	dev =3D alloc_etherdev(sizeof(struct ieee80211_device) + sizeof_priv)=
;
 	if (!dev) {
-		IEEE80211_ERROR("Unable to network device.\n");
+		IEEE80211_ERROR("Unable to allocate network device.\n");
 		goto failed;
 	}
 	ieee =3D netdev_priv(dev);
diff --git a/net/ieee80211/softmac/ieee80211softmac_module.c b/net/ieee=
80211/softmac/ieee80211softmac_module.c
index e9cdc66..c308756 100644
--- a/net/ieee80211/softmac/ieee80211softmac_module.c
+++ b/net/ieee80211/softmac/ieee80211softmac_module.c
@@ -33,7 +33,10 @@ struct net_device *alloc_ieee80211softmac(int sizeof=
_priv)
 	struct ieee80211softmac_device *softmac;
 	struct net_device *dev;
=20
-	dev =3D alloc_ieee80211(sizeof(struct ieee80211softmac_device) + size=
of_priv);
+	dev =3D alloc_ieee80211(sizeof(*softmac) + sizeof_priv);
+	if (!dev)
+		return NULL;
+
 	softmac =3D ieee80211_priv(dev);
 	softmac->dev =3D dev;
 	softmac->ieee =3D netdev_priv(dev);
--=20
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
