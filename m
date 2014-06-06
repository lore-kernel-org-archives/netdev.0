From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2014-06-06
Date: Fri, 6 Jun 2014 12:05:58 -0400
Message-ID: <20140606160557.GA3208@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="LZvS9be/3tNcYl/X"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--LZvS9be/3tNcYl/X
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please accept this batch of fixes intended for the 3.16 stream.

For the bluetooth bits, Gustavo says:

"Here some more patches for 3.16. We know that Linus already opened the mer=
ge
window, but this is fix only pull request, and most of the patches here are
also tagged for stable."

Along with that, Andrea Merello provides a fix for the broken scanning
in the venerable at76c50x driver...

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 9e89fd8b7db71038fd9f70f34e210963fa8fc980:

  ipv6: Shrink udp_v6_mcast_next() to one socket variable (2014-06-05 16:23=
:08 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

for you to fetch changes up to c6ac68a612783aab0aad62b8edd36791b251aadb:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless-next into for-davem (2014-06-06 11:59:11 -0400)

----------------------------------------------------------------

Adam Lee (1):
      Bluetooth: ath3k: no need to set same pipe multiple times

Andrea Merello (1):
      at76c50x: fix scan does not work with latest mac80211

Johan Hedberg (4):
      Bluetooth: Fix properly ignoring LTKs of unknown types
      Bluetooth: Fix authentication check for FIPS security level
      Bluetooth: Fix requiring SMP MITM for outgoing connections
      Bluetooth: Fix missing check for FIPS security level

John W. Linville (2):
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth-next
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Jukka Rissanen (2):
      Bluetooth: 6LoWPAN: Fix MAC address universal/local bit handling
      Bluetooth: l2cap: Set more channel defaults

Jukka Taimisto (1):
      Bluetooth: Fix L2CAP deadlock

 drivers/bluetooth/ath3k.c           |  3 +-
 drivers/net/wireless/at76c50x-usb.c | 53 ++++++++++++++++++++++++++++++
 drivers/net/wireless/at76c50x-usb.h |  1 +
 net/bluetooth/6lowpan.c             | 65 ++++++++++++++++++++-------------=
----
 net/bluetooth/hci_event.c           |  4 ++-
 net/bluetooth/l2cap_core.c          |  6 ++++
 net/bluetooth/l2cap_sock.c          |  5 ++-
 net/bluetooth/mgmt.c                | 10 ++++--
 net/bluetooth/smp.c                 |  7 ++--
 9 files changed, 116 insertions(+), 38 deletions(-)

diff --git a/drivers/bluetooth/ath3k.c b/drivers/bluetooth/ath3k.c
index a83b57e57b63..f98380648cb3 100644
--- a/drivers/bluetooth/ath3k.c
+++ b/drivers/bluetooth/ath3k.c
@@ -193,9 +193,10 @@ static int ath3k_load_firmware(struct usb_device *udev,
 	sent +=3D 20;
 	count -=3D 20;
=20
+	pipe =3D usb_sndbulkpipe(udev, 0x02);
+
 	while (count) {
 		size =3D min_t(uint, count, BULK_SIZE);
-		pipe =3D usb_sndbulkpipe(udev, 0x02);
 		memcpy(send_buf, firmware->data + sent, size);
=20
 		err =3D usb_bulk_msg(udev, pipe, send_buf, size,
diff --git a/drivers/net/wireless/at76c50x-usb.c b/drivers/net/wireless/at7=
6c50x-usb.c
index 10fd12ec85be..d48776e4f343 100644
--- a/drivers/net/wireless/at76c50x-usb.c
+++ b/drivers/net/wireless/at76c50x-usb.c
@@ -1429,6 +1429,8 @@ static int at76_startup_device(struct at76_priv *priv)
 	/* remove BSSID from previous run */
 	memset(priv->bssid, 0, ETH_ALEN);
=20
+	priv->scanning =3D false;
+
 	if (at76_set_radio(priv, 1) =3D=3D 1)
 		at76_wait_completion(priv, CMD_RADIO_ON);
=20
@@ -1502,6 +1504,52 @@ static void at76_work_submit_rx(struct work_struct *=
work)
 	mutex_unlock(&priv->mtx);
 }
=20
+/* This is a workaround to make scan working:
+ * currently mac80211 does not process frames with no frequency
+ * information.
+ * However during scan the HW performs a sweep by itself, and we
+ * are unable to know where the radio is actually tuned.
+ * This function tries to do its best to guess this information..
+ * During scan, If the current frame is a beacon or a probe response,
+ * the channel information is extracted from it.
+ * When not scanning, for other frames, or if it happens that for
+ * whatever reason we fail to parse beacons and probe responses, this
+ * function returns the priv->channel information, that should be correct
+ * at least when we are not scanning.
+ */
+static inline int at76_guess_freq(struct at76_priv *priv)
+{
+	size_t el_off;
+	const u8 *el;
+	int channel =3D priv->channel;
+	int len =3D priv->rx_skb->len;
+	struct ieee80211_hdr *hdr =3D (void *)priv->rx_skb->data;
+
+	if (!priv->scanning)
+		goto exit;
+
+	if (len < 24)
+		goto exit;
+
+	if (ieee80211_is_probe_resp(hdr->frame_control)) {
+		el_off =3D offsetof(struct ieee80211_mgmt, u.probe_resp.variable);
+		el =3D ((struct ieee80211_mgmt *)hdr)->u.probe_resp.variable;
+	} else if (ieee80211_is_beacon(hdr->frame_control)) {
+		el_off =3D offsetof(struct ieee80211_mgmt, u.beacon.variable);
+		el =3D ((struct ieee80211_mgmt *)hdr)->u.beacon.variable;
+	} else {
+		goto exit;
+	}
+	len -=3D el_off;
+
+	el =3D cfg80211_find_ie(WLAN_EID_DS_PARAMS, el, len);
+	if (el && el[1] > 0)
+		channel =3D el[2];
+
+exit:
+	return ieee80211_channel_to_frequency(channel, IEEE80211_BAND_2GHZ);
+}
+
 static void at76_rx_tasklet(unsigned long param)
 {
 	struct urb *urb =3D (struct urb *)param;
@@ -1542,6 +1590,8 @@ static void at76_rx_tasklet(unsigned long param)
 	rx_status.signal =3D buf->rssi;
 	rx_status.flag |=3D RX_FLAG_DECRYPTED;
 	rx_status.flag |=3D RX_FLAG_IV_STRIPPED;
+	rx_status.band =3D IEEE80211_BAND_2GHZ;
+	rx_status.freq =3D at76_guess_freq(priv);
=20
 	at76_dbg(DBG_MAC80211, "calling ieee80211_rx_irqsafe(): %d/%d",
 		 priv->rx_skb->len, priv->rx_skb->data_len);
@@ -1894,6 +1944,8 @@ static void at76_dwork_hw_scan(struct work_struct *wo=
rk)
 	if (is_valid_ether_addr(priv->bssid))
 		at76_join(priv);
=20
+	priv->scanning =3D false;
+
 	mutex_unlock(&priv->mtx);
=20
 	ieee80211_scan_completed(priv->hw, false);
@@ -1948,6 +2000,7 @@ static int at76_hw_scan(struct ieee80211_hw *hw,
 		goto exit;
 	}
=20
+	priv->scanning =3D true;
 	ieee80211_queue_delayed_work(priv->hw, &priv->dwork_hw_scan,
 				     SCAN_POLL_INTERVAL);
=20
diff --git a/drivers/net/wireless/at76c50x-usb.h b/drivers/net/wireless/at7=
6c50x-usb.h
index 4718aa59f051..55090a38ac95 100644
--- a/drivers/net/wireless/at76c50x-usb.h
+++ b/drivers/net/wireless/at76c50x-usb.h
@@ -418,6 +418,7 @@ struct at76_priv {
 	int scan_max_time;	/* scan max channel time */
 	int scan_mode;		/* SCAN_TYPE_ACTIVE, SCAN_TYPE_PASSIVE */
 	int scan_need_any;	/* if set, need to scan for any ESSID */
+	bool scanning;		/* if set, the scan is running */
=20
 	u16 assoc_id;		/* current association ID, if associated */
=20
diff --git a/net/bluetooth/6lowpan.c b/net/bluetooth/6lowpan.c
index 73492b91105a..8796ffa08b43 100644
--- a/net/bluetooth/6lowpan.c
+++ b/net/bluetooth/6lowpan.c
@@ -420,12 +420,18 @@ static int conn_send(struct l2cap_conn *conn,
 	return 0;
 }
=20
-static void get_dest_bdaddr(struct in6_addr *ip6_daddr,
-			    bdaddr_t *addr, u8 *addr_type)
+static u8 get_addr_type_from_eui64(u8 byte)
 {
-	u8 *eui64;
+	/* Is universal(0) or local(1) bit,  */
+	if (byte & 0x02)
+		return ADDR_LE_DEV_RANDOM;
=20
-	eui64 =3D ip6_daddr->s6_addr + 8;
+	return ADDR_LE_DEV_PUBLIC;
+}
+
+static void copy_to_bdaddr(struct in6_addr *ip6_daddr, bdaddr_t *addr)
+{
+	u8 *eui64 =3D ip6_daddr->s6_addr + 8;
=20
 	addr->b[0] =3D eui64[7];
 	addr->b[1] =3D eui64[6];
@@ -433,16 +439,19 @@ static void get_dest_bdaddr(struct in6_addr *ip6_dadd=
r,
 	addr->b[3] =3D eui64[2];
 	addr->b[4] =3D eui64[1];
 	addr->b[5] =3D eui64[0];
+}
=20
-	addr->b[5] ^=3D 2;
+static void convert_dest_bdaddr(struct in6_addr *ip6_daddr,
+				bdaddr_t *addr, u8 *addr_type)
+{
+	copy_to_bdaddr(ip6_daddr, addr);
=20
-	/* Set universal/local bit to 0 */
-	if (addr->b[5] & 1) {
-		addr->b[5] &=3D ~1;
-		*addr_type =3D ADDR_LE_DEV_PUBLIC;
-	} else {
-		*addr_type =3D ADDR_LE_DEV_RANDOM;
-	}
+	/* We need to toggle the U/L bit that we got from IPv6 address
+	 * so that we get the proper address and type of the BD address.
+	 */
+	addr->b[5] ^=3D 0x02;
+
+	*addr_type =3D get_addr_type_from_eui64(addr->b[5]);
 }
=20
 static int header_create(struct sk_buff *skb, struct net_device *netdev,
@@ -473,9 +482,11 @@ static int header_create(struct sk_buff *skb, struct n=
et_device *netdev,
 		/* Get destination BT device from skb.
 		 * If there is no such peer then discard the packet.
 		 */
-		get_dest_bdaddr(&hdr->daddr, &addr, &addr_type);
+		convert_dest_bdaddr(&hdr->daddr, &addr, &addr_type);
=20
-		BT_DBG("dest addr %pMR type %d", &addr, addr_type);
+		BT_DBG("dest addr %pMR type %s IP %pI6c", &addr,
+		       addr_type =3D=3D ADDR_LE_DEV_PUBLIC ? "PUBLIC" : "RANDOM",
+		       &hdr->daddr);
=20
 		read_lock_irqsave(&devices_lock, flags);
 		peer =3D peer_lookup_ba(dev, &addr, addr_type);
@@ -556,7 +567,7 @@ static netdev_tx_t bt_xmit(struct sk_buff *skb, struct =
net_device *netdev)
 	} else {
 		unsigned long flags;
=20
-		get_dest_bdaddr(&lowpan_cb(skb)->addr, &addr, &addr_type);
+		convert_dest_bdaddr(&lowpan_cb(skb)->addr, &addr, &addr_type);
 		eui64_addr =3D lowpan_cb(skb)->addr.s6_addr + 8;
 		dev =3D lowpan_dev(netdev);
=20
@@ -564,8 +575,10 @@ static netdev_tx_t bt_xmit(struct sk_buff *skb, struct=
 net_device *netdev)
 		peer =3D peer_lookup_ba(dev, &addr, addr_type);
 		read_unlock_irqrestore(&devices_lock, flags);
=20
-		BT_DBG("xmit from %s to %pMR (%pI6c) peer %p", netdev->name,
-		       &addr, &lowpan_cb(skb)->addr, peer);
+		BT_DBG("xmit %s to %pMR type %s IP %pI6c peer %p",
+		       netdev->name, &addr,
+		       addr_type =3D=3D ADDR_LE_DEV_PUBLIC ? "PUBLIC" : "RANDOM",
+		       &lowpan_cb(skb)->addr, peer);
=20
 		if (peer && peer->conn)
 			err =3D send_pkt(peer->conn, netdev->dev_addr,
@@ -620,13 +633,13 @@ static void set_addr(u8 *eui, u8 *addr, u8 addr_type)
 	eui[6] =3D addr[1];
 	eui[7] =3D addr[0];
=20
-	eui[0] ^=3D 2;
-
-	/* Universal/local bit set, RFC 4291 */
+	/* Universal/local bit set, BT 6lowpan draft ch. 3.2.1 */
 	if (addr_type =3D=3D ADDR_LE_DEV_PUBLIC)
-		eui[0] |=3D 1;
+		eui[0] &=3D ~0x02;
 	else
-		eui[0] &=3D ~1;
+		eui[0] |=3D 0x02;
+
+	BT_DBG("type %d addr %*phC", addr_type, 8, eui);
 }
=20
 static void set_dev_addr(struct net_device *netdev, bdaddr_t *addr,
@@ -634,7 +647,6 @@ static void set_dev_addr(struct net_device *netdev, bda=
ddr_t *addr,
 {
 	netdev->addr_assign_type =3D NET_ADDR_PERM;
 	set_addr(netdev->dev_addr, addr->b, addr_type);
-	netdev->dev_addr[0] ^=3D 2;
 }
=20
 static void ifup(struct net_device *netdev)
@@ -684,13 +696,6 @@ static int add_peer_conn(struct l2cap_conn *conn, stru=
ct lowpan_dev *dev)
=20
 	memcpy(&peer->eui64_addr, (u8 *)&peer->peer_addr.s6_addr + 8,
 	       EUI64_ADDR_LEN);
-	peer->eui64_addr[0] ^=3D 2; /* second bit-flip (Universe/Local)
-				   * is done according RFC2464
-				   */
-
-	raw_dump_inline(__func__, "peer IPv6 address",
-			(unsigned char *)&peer->peer_addr, 16);
-	raw_dump_inline(__func__, "peer EUI64 address", peer->eui64_addr, 8);
=20
 	write_lock_irqsave(&devices_lock, flags);
 	INIT_LIST_HEAD(&peer->list);
diff --git a/net/bluetooth/hci_event.c b/net/bluetooth/hci_event.c
index 3454807a40c5..1096e4cd1283 100644
--- a/net/bluetooth/hci_event.c
+++ b/net/bluetooth/hci_event.c
@@ -1453,6 +1453,7 @@ static int hci_outgoing_auth_needed(struct hci_dev *h=
dev,
 	 * is requested.
 	 */
 	if (!hci_conn_ssp_enabled(conn) && !(conn->auth_type & 0x01) &&
+	    conn->pending_sec_level !=3D BT_SECURITY_FIPS &&
 	    conn->pending_sec_level !=3D BT_SECURITY_HIGH &&
 	    conn->pending_sec_level !=3D BT_SECURITY_MEDIUM)
 		return 0;
@@ -3076,7 +3077,8 @@ static void hci_link_key_request_evt(struct hci_dev *=
hdev, struct sk_buff *skb)
 		}
=20
 		if (key->type =3D=3D HCI_LK_COMBINATION && key->pin_len < 16 &&
-		    conn->pending_sec_level =3D=3D BT_SECURITY_HIGH) {
+		    (conn->pending_sec_level =3D=3D BT_SECURITY_HIGH ||
+		     conn->pending_sec_level =3D=3D BT_SECURITY_FIPS)) {
 			BT_DBG("%s ignoring key unauthenticated for high security",
 			       hdev->name);
 			goto not_found;
diff --git a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
index dc4d301d3a72..6eabbe05fe54 100644
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@ -471,8 +471,14 @@ void l2cap_chan_set_defaults(struct l2cap_chan *chan)
 	chan->max_tx =3D L2CAP_DEFAULT_MAX_TX;
 	chan->tx_win =3D L2CAP_DEFAULT_TX_WINDOW;
 	chan->tx_win_max =3D L2CAP_DEFAULT_TX_WINDOW;
+	chan->remote_max_tx =3D chan->max_tx;
+	chan->remote_tx_win =3D chan->tx_win;
 	chan->ack_win =3D L2CAP_DEFAULT_TX_WINDOW;
 	chan->sec_level =3D BT_SECURITY_LOW;
+	chan->flush_to =3D L2CAP_DEFAULT_FLUSH_TO;
+	chan->retrans_timeout =3D L2CAP_DEFAULT_RETRANS_TO;
+	chan->monitor_timeout =3D L2CAP_DEFAULT_MONITOR_TO;
+	chan->conf_state =3D 0;
=20
 	set_bit(FLAG_FORCE_ACTIVE, &chan->flags);
 }
diff --git a/net/bluetooth/l2cap_sock.c b/net/bluetooth/l2cap_sock.c
index ef5e5b04f34f..ade3fb4c23bc 100644
--- a/net/bluetooth/l2cap_sock.c
+++ b/net/bluetooth/l2cap_sock.c
@@ -1180,13 +1180,16 @@ static struct l2cap_chan *l2cap_sock_new_connection=
_cb(struct l2cap_chan *chan)
 	/* Check for backlog size */
 	if (sk_acceptq_is_full(parent)) {
 		BT_DBG("backlog full %d", parent->sk_ack_backlog);
+		release_sock(parent);
 		return NULL;
 	}
=20
 	sk =3D l2cap_sock_alloc(sock_net(parent), NULL, BTPROTO_L2CAP,
 			      GFP_ATOMIC);
-	if (!sk)
+	if (!sk) {
+		release_sock(parent);
 		return NULL;
+        }
=20
 	bt_sock_reclassify_lock(sk, BTPROTO_L2CAP);
=20
diff --git a/net/bluetooth/mgmt.c b/net/bluetooth/mgmt.c
index 5e9c21a5525f..0fce54412ffd 100644
--- a/net/bluetooth/mgmt.c
+++ b/net/bluetooth/mgmt.c
@@ -4546,10 +4546,16 @@ static int load_long_term_keys(struct sock *sk, str=
uct hci_dev *hdev,
 		else
 			type =3D HCI_SMP_LTK_SLAVE;
=20
-		if (key->type =3D=3D MGMT_LTK_UNAUTHENTICATED)
+		switch (key->type) {
+		case MGMT_LTK_UNAUTHENTICATED:
 			authenticated =3D 0x00;
-		else
+			break;
+		case MGMT_LTK_AUTHENTICATED:
 			authenticated =3D 0x01;
+			break;
+		default:
+			continue;
+		}
=20
 		hci_add_ltk(hdev, &key->addr.bdaddr, addr_type, type,
 			    authenticated, key->val, key->enc_size, key->ediv,
diff --git a/net/bluetooth/smp.c b/net/bluetooth/smp.c
index 4f9662d0fd81..3d1cc164557d 100644
--- a/net/bluetooth/smp.c
+++ b/net/bluetooth/smp.c
@@ -909,10 +909,11 @@ int smp_conn_security(struct hci_conn *hcon, __u8 sec=
_level)
=20
 	authreq =3D seclevel_to_authreq(sec_level);
=20
-	/* hcon->auth_type is set by pair_device in mgmt.c. If the MITM
-	 * flag is set we should also set it for the SMP request.
+	/* Require MITM if IO Capability allows or the security level
+	 * requires it.
 	 */
-	if ((hcon->auth_type & 0x01))
+	if (hcon->io_capability !=3D HCI_IO_NO_INPUT_OUTPUT ||
+	    sec_level > BT_SECURITY_MEDIUM)
 		authreq |=3D SMP_AUTH_MITM;
=20
 	if (hcon->link_mode & HCI_LM_MASTER) {
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--LZvS9be/3tNcYl/X
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJTkeblAAoJEJctW/TcYTgG+5kP/0N8OzlkmJDseCdAKhwP+mCy
6q0ovY0idTE7aVbifG+jFhLVxXVeFxXO+3eFDfas0t/jCBXPkg9qFAejBo/+RNTn
FlkMXzbkP5/anYSKYPTftcE8LZGhNf5bU5bChl8pDryHQI0l76uNZ+bpMHTLYZwB
bYAr3Odi4dpWp6ygY2AgCpILlpCiYQlCrS+Ng8fNXI41OK+LyMBpU3S3rM4jnCwH
YteZ/9qIXLmT4jQ3tHa9WznPEgYh0z7u7f8PBLko71PtGchyY/Iis88Z0YXVau+N
1z/DcXJlXFltlkllYLY5QnyoqH/kNaqjcUz7gyQ0rlEdH8DY+WlKbqrrLC/QB1fM
s8oUy5qUrzw79/i+ipGdsgCgmnyx55rrb35yp99zbhSocQ5RuOQIZ9nS0oMH//1f
MRQzFvyr0SM5zEdQ60VIeaDg6e6nQEU201ccl9X8LDJ72ntChnrNg//faGpz7mAt
/Dc3FAigx16uCg6w7iTpoiVLrdIORyAgqtu1+ZAtWR/4zLoCkZxD6dBEQ3yOaCqP
0+KUzn2qCiFvJZkhqGHO9aG9EKdqhjtcwrBDqNCJAp1plkMUgsZQ7KvvLBW29+Ug
2jyNTKSTPsOtaaRo8gH6PdMUhHepl2KxV8AsUuMEQo5vIFYozYGBVMkvRziL5xH7
XLCPOWyofkaixIDiNWcZ
=wlAQ
-----END PGP SIGNATURE-----

--LZvS9be/3tNcYl/X--
