From: David Howells <dhowells@redhat.com>
Subject: [PATCH 17/26] hostap: Don't use create_proc_read_entry() [RFC]
Date: Thu, 11 Apr 2013 14:29:52 +0100
Message-ID: <20130411132952.32763.3184.stgit@warthog.procyon.org.uk>
References: <20130411132739.32763.82609.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, Jouni Malinen <j@w1.fi>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 linux-wireless@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>,
 viro@ZenIV.linux.org.uk, netdev@vger.kernel.org,
 Johannes Berg <johannes@sipsolutions.net>
To: linux-kernel@vger.kernel.org
Return-path: <devel-bounces@linuxdriverproject.org>
In-Reply-To: <20130411132739.32763.82609.stgit@warthog.procyon.org.uk>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/devel/>
List-Post: <mailto:devel@linuxdriverproject.org>
List-Help: <mailto:devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: devel-bounces@linuxdriverproject.org
Sender: "devel" <devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Don't use create_proc_read_entry() as that is deprecated, but rather use
proc_create_data() and seq_file instead.

Signed-off-by: David Howells <dhowells@redhat.com>
cc: Jouni Malinen <j@w1.fi>
cc: John W. Linville <linville@tuxdriver.com>
cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
cc: Johannes Berg <johannes@sipsolutions.net>
cc: linux-wireless@vger.kernel.org
cc: netdev@vger.kernel.org
cc: devel@driverdev.osuosl.org
---

 drivers/net/wireless/hostap/hostap_ap.c       |  375 +++++++++-------
 drivers/net/wireless/hostap/hostap_download.c |   68 +++
 drivers/net/wireless/hostap/hostap_hw.c       |   38 +-
 drivers/net/wireless/hostap/hostap_proc.c     |  589 ++++++++++++++-----------
 drivers/net/wireless/hostap/hostap_wlan.h     |    3 
 drivers/staging/rtl8192e/rtllib_crypt_ccmp.c  |   21 -
 drivers/staging/rtl8192e/rtllib_crypt_tkip.c  |   44 +-
 drivers/staging/rtl8192e/rtllib_crypt_wep.c   |    6 
 include/net/lib80211.h                        |    4 
 net/wireless/lib80211_crypt_ccmp.c            |   29 +
 net/wireless/lib80211_crypt_tkip.c            |   44 +-
 net/wireless/lib80211_crypt_wep.c             |    5 
 12 files changed, 703 insertions(+), 523 deletions(-)

diff --git a/drivers/net/wireless/hostap/hostap_ap.c b/drivers/net/wireless/hostap/hostap_ap.c
index dd9a18f..19c45e3 100644
--- a/drivers/net/wireless/hostap/hostap_ap.c
+++ b/drivers/net/wireless/hostap/hostap_ap.c
@@ -17,6 +17,7 @@
  */
 
 #include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 #include <linux/delay.h>
 #include <linux/random.h>
 #include <linux/if_arp.h>
@@ -64,28 +65,32 @@ static void prism2_send_mgmt(struct net_device *dev,
 
 
 #ifndef PRISM2_NO_PROCFS_DEBUG
-static int ap_debug_proc_read(char *page, char **start, off_t off,
-			      int count, int *eof, void *data)
-{
-	char *p = page;
-	struct ap_data *ap = (struct ap_data *) data;
-
-	if (off != 0) {
-		*eof = 1;
-		return 0;
-	}
-
-	p += sprintf(p, "BridgedUnicastFrames=%u\n", ap->bridged_unicast);
-	p += sprintf(p, "BridgedMulticastFrames=%u\n", ap->bridged_multicast);
-	p += sprintf(p, "max_inactivity=%u\n", ap->max_inactivity / HZ);
-	p += sprintf(p, "bridge_packets=%u\n", ap->bridge_packets);
-	p += sprintf(p, "nullfunc_ack=%u\n", ap->nullfunc_ack);
-	p += sprintf(p, "autom_ap_wds=%u\n", ap->autom_ap_wds);
-	p += sprintf(p, "auth_algs=%u\n", ap->local->auth_algs);
-	p += sprintf(p, "tx_drop_nonassoc=%u\n", ap->tx_drop_nonassoc);
+static int ap_debug_proc_show(struct seq_file *m, void *v)
+{
+	struct ap_data *ap = m->private;
+
+	seq_printf(m, "BridgedUnicastFrames=%u\n", ap->bridged_unicast);
+	seq_printf(m, "BridgedMulticastFrames=%u\n", ap->bridged_multicast);
+	seq_printf(m, "max_inactivity=%u\n", ap->max_inactivity / HZ);
+	seq_printf(m, "bridge_packets=%u\n", ap->bridge_packets);
+	seq_printf(m, "nullfunc_ack=%u\n", ap->nullfunc_ack);
+	seq_printf(m, "autom_ap_wds=%u\n", ap->autom_ap_wds);
+	seq_printf(m, "auth_algs=%u\n", ap->local->auth_algs);
+	seq_printf(m, "tx_drop_nonassoc=%u\n", ap->tx_drop_nonassoc);
+	return 0;
+}
 
-	return (p - page);
+static int ap_debug_proc_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, ap_debug_proc_show, PDE_DATA(inode));
 }
+
+static const struct file_operations ap_debug_proc_fops = {
+	.open		= ap_debug_proc_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
 #endif /* PRISM2_NO_PROCFS_DEBUG */
 
 
@@ -325,50 +330,81 @@ void hostap_deauth_all_stas(struct net_device *dev, struct ap_data *ap,
 }
 
 
-static int ap_control_proc_read(char *page, char **start, off_t off,
-				int count, int *eof, void *data)
+static int ap_control_proc_show(struct seq_file *m, void *v)
 {
-	char *p = page;
-	struct ap_data *ap = (struct ap_data *) data;
+	struct ap_data *ap = m->private;
 	char *policy_txt;
 	struct mac_entry *entry;
 
-	if (off != 0) {
-		*eof = 1;
+	if (v == SEQ_START_TOKEN) {
+		switch (ap->mac_restrictions.policy) {
+		case MAC_POLICY_OPEN:
+			policy_txt = "open";
+			break;
+		case MAC_POLICY_ALLOW:
+			policy_txt = "allow";
+			break;
+		case MAC_POLICY_DENY:
+			policy_txt = "deny";
+			break;
+		default:
+			policy_txt = "unknown";
+			break;
+		}
+		seq_printf(m, "MAC policy: %s\n", policy_txt);
+		seq_printf(m, "MAC entries: %u\n", ap->mac_restrictions.entries);
+		seq_puts(m, "MAC list:\n");
 		return 0;
 	}
 
-	switch (ap->mac_restrictions.policy) {
-	case MAC_POLICY_OPEN:
-		policy_txt = "open";
-		break;
-	case MAC_POLICY_ALLOW:
-		policy_txt = "allow";
-		break;
-	case MAC_POLICY_DENY:
-		policy_txt = "deny";
-		break;
-	default:
-		policy_txt = "unknown";
-		break;
-	}
-	p += sprintf(p, "MAC policy: %s\n", policy_txt);
-	p += sprintf(p, "MAC entries: %u\n", ap->mac_restrictions.entries);
-	p += sprintf(p, "MAC list:\n");
+	entry = v;
+	seq_printf(m, "%pM\n", entry->addr);
+	return 0;
+}
+
+static void *ap_control_proc_start(struct seq_file *m, loff_t *_pos)
+{
+	struct ap_data *ap = m->private;
 	spin_lock_bh(&ap->mac_restrictions.lock);
-	list_for_each_entry(entry, &ap->mac_restrictions.mac_list, list) {
-		if (p - page > PAGE_SIZE - 80) {
-			p += sprintf(p, "All entries did not fit one page.\n");
-			break;
-		}
+	return seq_list_start_head(&ap->mac_restrictions.mac_list, *_pos);
+}
 
-		p += sprintf(p, "%pM\n", entry->addr);
-	}
+static void *ap_control_proc_next(struct seq_file *m, void *v, loff_t *_pos)
+{
+	struct ap_data *ap = m->private;
+	return seq_list_next(v, &ap->mac_restrictions.mac_list, _pos);
+}
+
+static void ap_control_proc_stop(struct seq_file *m, void *v)
+{
+	struct ap_data *ap = m->private;
 	spin_unlock_bh(&ap->mac_restrictions.lock);
+}
 
-	return (p - page);
+static const struct seq_operations ap_control_proc_seqops = {
+	.start	= ap_control_proc_start,
+	.next	= ap_control_proc_next,
+	.stop	= ap_control_proc_stop,
+	.show	= ap_control_proc_show,
+};
+
+static int ap_control_proc_open(struct inode *inode, struct file *file)
+{
+	int ret = seq_open(file, &ap_control_proc_seqops);
+	if (ret == 0) {
+		struct seq_file *m = file->private_data;
+		m->private = PDE_DATA(inode);
+	}
+	return ret;
 }
 
+static const struct file_operations ap_control_proc_fops = {
+	.open		= ap_control_proc_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
+
 
 int ap_control_add_mac(struct mac_restrictions *mac_restrictions, u8 *mac)
 {
@@ -510,61 +546,84 @@ void ap_control_kickall(struct ap_data *ap)
 
 #ifndef PRISM2_NO_KERNEL_IEEE80211_MGMT
 
-#define PROC_LIMIT (PAGE_SIZE - 80)
-
-static int prism2_ap_proc_read(char *page, char **start, off_t off,
-			       int count, int *eof, void *data)
+static int prism2_ap_proc_show(struct seq_file *m, void *v)
 {
-	char *p = page;
-	struct ap_data *ap = (struct ap_data *) data;
-	struct sta_info *sta;
+	struct sta_info *sta = v;
 	int i;
 
-	if (off > PROC_LIMIT) {
-		*eof = 1;
+	if (v == SEQ_START_TOKEN) {
+		seq_printf(m, "# BSSID CHAN SIGNAL NOISE RATE SSID FLAGS\n");
 		return 0;
 	}
 
-	p += sprintf(p, "# BSSID CHAN SIGNAL NOISE RATE SSID FLAGS\n");
-	spin_lock_bh(&ap->sta_table_lock);
-	list_for_each_entry(sta, &ap->sta_list, list) {
-		if (!sta->ap)
-			continue;
+	if (!sta->ap)
+		return 0;
 
-		p += sprintf(p, "%pM %d %d %d %d '",
-			     sta->addr,
-			     sta->u.ap.channel, sta->last_rx_signal,
-			     sta->last_rx_silence, sta->last_rx_rate);
-		for (i = 0; i < sta->u.ap.ssid_len; i++)
-			p += sprintf(p, ((sta->u.ap.ssid[i] >= 32 &&
-					  sta->u.ap.ssid[i] < 127) ?
-					 "%c" : "<%02x>"),
-				     sta->u.ap.ssid[i]);
-		p += sprintf(p, "'");
-		if (sta->capability & WLAN_CAPABILITY_ESS)
-			p += sprintf(p, " [ESS]");
-		if (sta->capability & WLAN_CAPABILITY_IBSS)
-			p += sprintf(p, " [IBSS]");
-		if (sta->capability & WLAN_CAPABILITY_PRIVACY)
-			p += sprintf(p, " [WEP]");
-		p += sprintf(p, "\n");
-
-		if ((p - page) > PROC_LIMIT) {
-			printk(KERN_DEBUG "hostap: ap proc did not fit\n");
-			break;
-		}
-	}
-	spin_unlock_bh(&ap->sta_table_lock);
+	seq_printf(m, "%pM %d %d %d %d '",
+		   sta->addr,
+		   sta->u.ap.channel, sta->last_rx_signal,
+		   sta->last_rx_silence, sta->last_rx_rate);
 
-	if ((p - page) <= off) {
-		*eof = 1;
-		return 0;
+	for (i = 0; i < sta->u.ap.ssid_len; i++) {
+		if (sta->u.ap.ssid[i] >= 32 && sta->u.ap.ssid[i] < 127)
+			seq_putc(m, sta->u.ap.ssid[i]);
+		else
+			seq_printf(m, "<%02x>", sta->u.ap.ssid[i]);
 	}
 
-	*start = page + off;
+	seq_putc(m, '\'');
+	if (sta->capability & WLAN_CAPABILITY_ESS)
+		seq_puts(m, " [ESS]");
+	if (sta->capability & WLAN_CAPABILITY_IBSS)
+		seq_puts(m, " [IBSS]");
+	if (sta->capability & WLAN_CAPABILITY_PRIVACY)
+		seq_puts(m, " [WEP]");
+	seq_putc(m, '\n');
+	return 0;
+}
+
+static void *prism2_ap_proc_start(struct seq_file *m, loff_t *_pos)
+{
+	struct ap_data *ap = m->private;
+	spin_lock_bh(&ap->sta_table_lock);
+	return seq_list_start_head(&ap->sta_list, *_pos);
+}
 
-	return (p - page - off);
+static void *prism2_ap_proc_next(struct seq_file *m, void *v, loff_t *_pos)
+{
+	struct ap_data *ap = m->private;
+	return seq_list_next(v, &ap->sta_list, _pos);
 }
+
+static void prism2_ap_proc_stop(struct seq_file *m, void *v)
+{
+	struct ap_data *ap = m->private;
+	spin_unlock_bh(&ap->sta_table_lock);
+}
+
+static const struct seq_operations prism2_ap_proc_seqops = {
+	.start	= prism2_ap_proc_start,
+	.next	= prism2_ap_proc_next,
+	.stop	= prism2_ap_proc_stop,
+	.show	= prism2_ap_proc_show,
+};
+
+static int prism2_ap_proc_open(struct inode *inode, struct file *file)
+{
+	int ret = seq_open(file, &prism2_ap_proc_seqops);
+	if (ret == 0) {
+		struct seq_file *m = file->private_data;
+		m->private = PDE_DATA(inode);
+	}
+	return ret;
+}
+
+static const struct file_operations prism2_ap_proc_fops = {
+	.open		= prism2_ap_proc_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
 #endif /* PRISM2_NO_KERNEL_IEEE80211_MGMT */
 
 
@@ -836,15 +895,12 @@ void hostap_init_ap_proc(local_info_t *local)
 		return;
 
 #ifndef PRISM2_NO_PROCFS_DEBUG
-	create_proc_read_entry("ap_debug", 0, ap->proc,
-			       ap_debug_proc_read, ap);
+	proc_create_data("ap_debug", 0, ap->proc, &ap_debug_proc_fops, ap);
 #endif /* PRISM2_NO_PROCFS_DEBUG */
 
 #ifndef PRISM2_NO_KERNEL_IEEE80211_MGMT
-	create_proc_read_entry("ap_control", 0, ap->proc,
-			       ap_control_proc_read, ap);
-	create_proc_read_entry("ap", 0, ap->proc,
-			       prism2_ap_proc_read, ap);
+	proc_create_data("ap_control", 0, ap->proc, &ap_control_proc_fops, ap);
+	proc_create_data("ap", 0, ap->proc, &prism2_ap_proc_fops, ap);
 #endif /* PRISM2_NO_KERNEL_IEEE80211_MGMT */
 
 }
@@ -982,79 +1038,86 @@ static void prism2_send_mgmt(struct net_device *dev,
 #endif /* PRISM2_NO_KERNEL_IEEE80211_MGMT */
 
 
-static int prism2_sta_proc_read(char *page, char **start, off_t off,
-				int count, int *eof, void *data)
+static int prism2_sta_proc_show(struct seq_file *m, void *v)
 {
-	char *p = page;
-	struct sta_info *sta = (struct sta_info *) data;
+	struct sta_info *sta = m->private;
 	int i;
 
 	/* FIX: possible race condition.. the STA data could have just expired,
 	 * but proc entry was still here so that the read could have started;
 	 * some locking should be done here.. */
 
-	if (off != 0) {
-		*eof = 1;
-		return 0;
-	}
-
-	p += sprintf(p, "%s=%pM\nusers=%d\naid=%d\n"
-		     "flags=0x%04x%s%s%s%s%s%s%s\n"
-		     "capability=0x%02x\nlisten_interval=%d\nsupported_rates=",
-		     sta->ap ? "AP" : "STA",
-		     sta->addr, atomic_read(&sta->users), sta->aid,
-		     sta->flags,
-		     sta->flags & WLAN_STA_AUTH ? " AUTH" : "",
-		     sta->flags & WLAN_STA_ASSOC ? " ASSOC" : "",
-		     sta->flags & WLAN_STA_PS ? " PS" : "",
-		     sta->flags & WLAN_STA_TIM ? " TIM" : "",
-		     sta->flags & WLAN_STA_PERM ? " PERM" : "",
-		     sta->flags & WLAN_STA_AUTHORIZED ? " AUTHORIZED" : "",
-		     sta->flags & WLAN_STA_PENDING_POLL ? " POLL" : "",
-		     sta->capability, sta->listen_interval);
+	seq_printf(m,
+		   "%s=%pM\nusers=%d\naid=%d\n"
+		   "flags=0x%04x%s%s%s%s%s%s%s\n"
+		   "capability=0x%02x\nlisten_interval=%d\nsupported_rates=",
+		   sta->ap ? "AP" : "STA",
+		   sta->addr, atomic_read(&sta->users), sta->aid,
+		   sta->flags,
+		   sta->flags & WLAN_STA_AUTH ? " AUTH" : "",
+		   sta->flags & WLAN_STA_ASSOC ? " ASSOC" : "",
+		   sta->flags & WLAN_STA_PS ? " PS" : "",
+		   sta->flags & WLAN_STA_TIM ? " TIM" : "",
+		   sta->flags & WLAN_STA_PERM ? " PERM" : "",
+		   sta->flags & WLAN_STA_AUTHORIZED ? " AUTHORIZED" : "",
+		   sta->flags & WLAN_STA_PENDING_POLL ? " POLL" : "",
+		   sta->capability, sta->listen_interval);
 	/* supported_rates: 500 kbit/s units with msb ignored */
 	for (i = 0; i < sizeof(sta->supported_rates); i++)
 		if (sta->supported_rates[i] != 0)
-			p += sprintf(p, "%d%sMbps ",
-				     (sta->supported_rates[i] & 0x7f) / 2,
-				     sta->supported_rates[i] & 1 ? ".5" : "");
-	p += sprintf(p, "\njiffies=%lu\nlast_auth=%lu\nlast_assoc=%lu\n"
-		     "last_rx=%lu\nlast_tx=%lu\nrx_packets=%lu\n"
-		     "tx_packets=%lu\n"
-		     "rx_bytes=%lu\ntx_bytes=%lu\nbuffer_count=%d\n"
-		     "last_rx: silence=%d dBm signal=%d dBm rate=%d%s Mbps\n"
-		     "tx_rate=%d\ntx[1M]=%d\ntx[2M]=%d\ntx[5.5M]=%d\n"
-		     "tx[11M]=%d\n"
-		     "rx[1M]=%d\nrx[2M]=%d\nrx[5.5M]=%d\nrx[11M]=%d\n",
-		     jiffies, sta->last_auth, sta->last_assoc, sta->last_rx,
-		     sta->last_tx,
-		     sta->rx_packets, sta->tx_packets, sta->rx_bytes,
-		     sta->tx_bytes, skb_queue_len(&sta->tx_buf),
-		     sta->last_rx_silence,
-		     sta->last_rx_signal, sta->last_rx_rate / 10,
-		     sta->last_rx_rate % 10 ? ".5" : "",
-		     sta->tx_rate, sta->tx_count[0], sta->tx_count[1],
-		     sta->tx_count[2], sta->tx_count[3],  sta->rx_count[0],
-		     sta->rx_count[1], sta->rx_count[2], sta->rx_count[3]);
+			seq_printf(m, "%d%sMbps ",
+				   (sta->supported_rates[i] & 0x7f) / 2,
+				   sta->supported_rates[i] & 1 ? ".5" : "");
+	seq_printf(m,
+		   "\njiffies=%lu\nlast_auth=%lu\nlast_assoc=%lu\n"
+		   "last_rx=%lu\nlast_tx=%lu\nrx_packets=%lu\n"
+		   "tx_packets=%lu\n"
+		   "rx_bytes=%lu\ntx_bytes=%lu\nbuffer_count=%d\n"
+		   "last_rx: silence=%d dBm signal=%d dBm rate=%d%s Mbps\n"
+		   "tx_rate=%d\ntx[1M]=%d\ntx[2M]=%d\ntx[5.5M]=%d\n"
+		   "tx[11M]=%d\n"
+		   "rx[1M]=%d\nrx[2M]=%d\nrx[5.5M]=%d\nrx[11M]=%d\n",
+		   jiffies, sta->last_auth, sta->last_assoc, sta->last_rx,
+		   sta->last_tx,
+		   sta->rx_packets, sta->tx_packets, sta->rx_bytes,
+		   sta->tx_bytes, skb_queue_len(&sta->tx_buf),
+		   sta->last_rx_silence,
+		   sta->last_rx_signal, sta->last_rx_rate / 10,
+		   sta->last_rx_rate % 10 ? ".5" : "",
+		   sta->tx_rate, sta->tx_count[0], sta->tx_count[1],
+		   sta->tx_count[2], sta->tx_count[3],  sta->rx_count[0],
+		   sta->rx_count[1], sta->rx_count[2], sta->rx_count[3]);
 	if (sta->crypt && sta->crypt->ops && sta->crypt->ops->print_stats)
-		p = sta->crypt->ops->print_stats(p, sta->crypt->priv);
+		sta->crypt->ops->print_stats(m, sta->crypt->priv);
 #ifndef PRISM2_NO_KERNEL_IEEE80211_MGMT
 	if (sta->ap) {
 		if (sta->u.ap.channel >= 0)
-			p += sprintf(p, "channel=%d\n", sta->u.ap.channel);
-		p += sprintf(p, "ssid=");
-		for (i = 0; i < sta->u.ap.ssid_len; i++)
-			p += sprintf(p, ((sta->u.ap.ssid[i] >= 32 &&
-					  sta->u.ap.ssid[i] < 127) ?
-					 "%c" : "<%02x>"),
-				     sta->u.ap.ssid[i]);
-		p += sprintf(p, "\n");
+			seq_printf(m, "channel=%d\n", sta->u.ap.channel);
+		seq_puts(m, "ssid=");
+		for (i = 0; i < sta->u.ap.ssid_len; i++) {
+			if (sta->u.ap.ssid[i] >= 32 && sta->u.ap.ssid[i] < 127)
+				seq_putc(m, sta->u.ap.ssid[i]);
+			else
+				seq_printf(m, "<%02x>", sta->u.ap.ssid[i]);
+		}
+		seq_putc(m, '\n');
 	}
 #endif /* PRISM2_NO_KERNEL_IEEE80211_MGMT */
 
-	return (p - page);
+	return 0;
+}
+
+static int prism2_sta_proc_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, prism2_sta_proc_show, PDE_DATA(inode));
 }
 
+static const struct file_operations prism2_sta_proc_fops = {
+	.open		= prism2_sta_proc_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
 
 static void handle_add_proc_queue(struct work_struct *work)
 {
@@ -1076,9 +1139,9 @@ static void handle_add_proc_queue(struct work_struct *work)
 
 		if (sta) {
 			sprintf(name, "%pM", sta->addr);
-			sta->proc = create_proc_read_entry(
+			sta->proc = proc_create_data(
 				name, 0, ap->proc,
-				prism2_sta_proc_read, sta);
+				&prism2_sta_proc_fops, sta);
 
 			atomic_dec(&sta->users);
 		}
diff --git a/drivers/net/wireless/hostap/hostap_download.c b/drivers/net/wireless/hostap/hostap_download.c
index e73bf73..705fe66 100644
--- a/drivers/net/wireless/hostap/hostap_download.c
+++ b/drivers/net/wireless/hostap/hostap_download.c
@@ -174,20 +174,70 @@ static int prism2_pda_ok(u8 *buf)
 }
 
 
-static int prism2_download_aux_dump(struct net_device *dev,
-				     unsigned int addr, int len, u8 *buf)
-{
-	int res;
+#define prism2_download_aux_dump_npages 65536
 
-	prism2_enable_aux_port(dev, 1);
-	res = hfa384x_from_aux(dev, addr, len, buf);
-	prism2_enable_aux_port(dev, 0);
-	if (res)
-		return -1;
+struct prism2_download_aux_dump {
+	local_info_t *local;
+	u16 page[0x80];
+};
+
+static int prism2_download_aux_dump_proc_show(struct seq_file *m, void *v)
+{
+	struct prism2_download_aux_dump *ctx = m->private;
 
+	hfa384x_from_aux(ctx->local->dev, (unsigned long)v - 1, 0x80, ctx->page);
+	seq_write(m, ctx->page, 0x80);
 	return 0;
 }
 
+static void *prism2_download_aux_dump_proc_start(struct seq_file *m, loff_t *_pos)
+{
+	struct prism2_download_aux_dump *ctx = m->private;
+	prism2_enable_aux_port(ctx->local->dev, 1);
+	if (*_pos >= prism2_download_aux_dump_npages)
+		return NULL;
+	return (void *)((unsigned long)*_pos + 1);
+}
+
+static void *prism2_download_aux_dump_proc_next(struct seq_file *m, void *v, loff_t *_pos)
+{
+	++*_pos;
+	if (*_pos >= prism2_download_aux_dump_npages)
+		return NULL;
+	return (void *)((unsigned long)*_pos + 1);
+}
+
+static void prism2_download_aux_dump_proc_stop(struct seq_file *m, void *v)
+{
+	struct prism2_download_aux_dump *ctx = m->private;
+	prism2_enable_aux_port(ctx->local->dev, 0);
+}
+
+static const struct seq_operations prism2_download_aux_dump_proc_seqops = {
+	.start	= prism2_download_aux_dump_proc_start,
+	.next	= prism2_download_aux_dump_proc_next,
+	.stop	= prism2_download_aux_dump_proc_stop,
+	.show	= prism2_download_aux_dump_proc_show,
+};
+
+static int prism2_download_aux_dump_proc_open(struct inode *inode, struct file *file)
+{
+	int ret = seq_open_private(file, &prism2_download_aux_dump_proc_seqops,
+				   sizeof(struct prism2_download_aux_dump));
+	if (ret == 0) {
+		struct seq_file *m = file->private_data;
+		m->private = PDE_DATA(inode);
+	}
+	return ret;
+}
+
+static const struct file_operations prism2_download_aux_dump_proc_fops = {
+	.open		= prism2_download_aux_dump_proc_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release_private,
+};
+
 
 static u8 * prism2_read_pda(struct net_device *dev)
 {
diff --git a/drivers/net/wireless/hostap/hostap_hw.c b/drivers/net/wireless/hostap/hostap_hw.c
index 8e7000f..507ab99 100644
--- a/drivers/net/wireless/hostap/hostap_hw.c
+++ b/drivers/net/wireless/hostap/hostap_hw.c
@@ -38,6 +38,7 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 #include <linux/if_arp.h>
 #include <linux/delay.h>
 #include <linux/random.h>
@@ -129,8 +130,7 @@ static void prism2_check_sta_fw_version(local_info_t *local);
 
 #ifdef PRISM2_DOWNLOAD_SUPPORT
 /* hostap_download.c */
-static int prism2_download_aux_dump(struct net_device *dev,
-				    unsigned int addr, int len, u8 *buf);
+static const struct file_operations prism2_download_aux_dump_proc_fops;
 static u8 * prism2_read_pda(struct net_device *dev);
 static int prism2_download(local_info_t *local,
 			   struct prism2_download_param *param);
@@ -2894,19 +2894,12 @@ static void hostap_tick_timer(unsigned long data)
 
 
 #ifndef PRISM2_NO_PROCFS_DEBUG
-static int prism2_registers_proc_read(char *page, char **start, off_t off,
-				      int count, int *eof, void *data)
+static int prism2_registers_proc_show(struct seq_file *m, void *v)
 {
-	char *p = page;
-	local_info_t *local = (local_info_t *) data;
-
-	if (off != 0) {
-		*eof = 1;
-		return 0;
-	}
+	local_info_t *local = m->private;
 
 #define SHOW_REG(n) \
-p += sprintf(p, #n "=%04x\n", hfa384x_read_reg(local->dev, HFA384X_##n##_OFF))
+  seq_printf(m, #n "=%04x\n", hfa384x_read_reg(local->dev, HFA384X_##n##_OFF))
 
 	SHOW_REG(CMD);
 	SHOW_REG(PARAM0);
@@ -2952,8 +2945,21 @@ p += sprintf(p, #n "=%04x\n", hfa384x_read_reg(local->dev, HFA384X_##n##_OFF))
 	SHOW_REG(PCI_M1_CTL);
 #endif /* PRISM2_PCI */
 
-	return (p - page);
+	return 0;
 }
+
+static int prism2_registers_proc_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, prism2_registers_proc_show, PDE_DATA(inode));
+}
+
+static const struct file_operations prism2_registers_proc_fops = {
+	.open		= prism2_registers_proc_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
+
 #endif /* PRISM2_NO_PROCFS_DEBUG */
 
 
@@ -3128,7 +3134,7 @@ prism2_init_local_data(struct prism2_helper_functions *funcs, int card_idx,
 	local->func->reset_port = prism2_reset_port;
 	local->func->schedule_reset = prism2_schedule_reset;
 #ifdef PRISM2_DOWNLOAD_SUPPORT
-	local->func->read_aux = prism2_download_aux_dump;
+	local->func->read_aux_fops = &prism2_download_aux_dump_proc_fops;
 	local->func->download = prism2_download;
 #endif /* PRISM2_DOWNLOAD_SUPPORT */
 	local->func->tx = prism2_tx_80211;
@@ -3274,8 +3280,8 @@ static int hostap_hw_ready(struct net_device *dev)
 		}
 		hostap_init_proc(local);
 #ifndef PRISM2_NO_PROCFS_DEBUG
-		create_proc_read_entry("registers", 0, local->proc,
-				       prism2_registers_proc_read, local);
+		proc_create_data("registers", 0, local->proc,
+				 &prism2_registers_proc_fops, local);
 #endif /* PRISM2_NO_PROCFS_DEBUG */
 		hostap_init_ap_proc(local);
 		return 0;
diff --git a/drivers/net/wireless/hostap/hostap_proc.c b/drivers/net/wireless/hostap/hostap_proc.c
index dc447c1..89292cf 100644
--- a/drivers/net/wireless/hostap/hostap_proc.c
+++ b/drivers/net/wireless/hostap/hostap_proc.c
@@ -12,259 +12,297 @@
 
 
 #ifndef PRISM2_NO_PROCFS_DEBUG
-static int prism2_debug_proc_read(char *page, char **start, off_t off,
-				  int count, int *eof, void *data)
+static int prism2_debug_proc_show(struct seq_file *m, void *v)
 {
-	char *p = page;
-	local_info_t *local = (local_info_t *) data;
+	local_info_t *local = m->private;
 	int i;
 
-	if (off != 0) {
-		*eof = 1;
-		return 0;
-	}
-
-	p += sprintf(p, "next_txfid=%d next_alloc=%d\n",
-		     local->next_txfid, local->next_alloc);
+	seq_printf(m, "next_txfid=%d next_alloc=%d\n",
+		   local->next_txfid, local->next_alloc);
 	for (i = 0; i < PRISM2_TXFID_COUNT; i++)
-		p += sprintf(p, "FID: tx=%04X intransmit=%04X\n",
-			     local->txfid[i], local->intransmitfid[i]);
-	p += sprintf(p, "FW TX rate control: %d\n", local->fw_tx_rate_control);
-	p += sprintf(p, "beacon_int=%d\n", local->beacon_int);
-	p += sprintf(p, "dtim_period=%d\n", local->dtim_period);
-	p += sprintf(p, "wds_max_connections=%d\n",
-		     local->wds_max_connections);
-	p += sprintf(p, "dev_enabled=%d\n", local->dev_enabled);
-	p += sprintf(p, "sw_tick_stuck=%d\n", local->sw_tick_stuck);
+		seq_printf(m, "FID: tx=%04X intransmit=%04X\n",
+			   local->txfid[i], local->intransmitfid[i]);
+	seq_printf(m, "FW TX rate control: %d\n", local->fw_tx_rate_control);
+	seq_printf(m, "beacon_int=%d\n", local->beacon_int);
+	seq_printf(m, "dtim_period=%d\n", local->dtim_period);
+	seq_printf(m, "wds_max_connections=%d\n", local->wds_max_connections);
+	seq_printf(m, "dev_enabled=%d\n", local->dev_enabled);
+	seq_printf(m, "sw_tick_stuck=%d\n", local->sw_tick_stuck);
 	for (i = 0; i < WEP_KEYS; i++) {
 		if (local->crypt_info.crypt[i] &&
 		    local->crypt_info.crypt[i]->ops) {
-			p += sprintf(p, "crypt[%d]=%s\n", i,
-				     local->crypt_info.crypt[i]->ops->name);
+			seq_printf(m, "crypt[%d]=%s\n", i,
+				   local->crypt_info.crypt[i]->ops->name);
 		}
 	}
-	p += sprintf(p, "pri_only=%d\n", local->pri_only);
-	p += sprintf(p, "pci=%d\n", local->func->hw_type == HOSTAP_HW_PCI);
-	p += sprintf(p, "sram_type=%d\n", local->sram_type);
-	p += sprintf(p, "no_pri=%d\n", local->no_pri);
+	seq_printf(m, "pri_only=%d\n", local->pri_only);
+	seq_printf(m, "pci=%d\n", local->func->hw_type == HOSTAP_HW_PCI);
+	seq_printf(m, "sram_type=%d\n", local->sram_type);
+	seq_printf(m, "no_pri=%d\n", local->no_pri);
+
+	return 0;
+}
 
-	return (p - page);
+static int prism2_debug_proc_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, prism2_debug_proc_show, PDE_DATA(inode));
 }
+
+static const struct file_operations prism2_debug_proc_fops = {
+	.open		= prism2_debug_proc_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
 #endif /* PRISM2_NO_PROCFS_DEBUG */
 
 
-static int prism2_stats_proc_read(char *page, char **start, off_t off,
-				  int count, int *eof, void *data)
+static int prism2_stats_proc_show(struct seq_file *m, void *v)
 {
-	char *p = page;
-	local_info_t *local = (local_info_t *) data;
+	local_info_t *local = m->private;
 	struct comm_tallies_sums *sums = &local->comm_tallies;
 
-	if (off != 0) {
-		*eof = 1;
-		return 0;
-	}
-
-	p += sprintf(p, "TxUnicastFrames=%u\n", sums->tx_unicast_frames);
-	p += sprintf(p, "TxMulticastframes=%u\n", sums->tx_multicast_frames);
-	p += sprintf(p, "TxFragments=%u\n", sums->tx_fragments);
-	p += sprintf(p, "TxUnicastOctets=%u\n", sums->tx_unicast_octets);
-	p += sprintf(p, "TxMulticastOctets=%u\n", sums->tx_multicast_octets);
-	p += sprintf(p, "TxDeferredTransmissions=%u\n",
-		     sums->tx_deferred_transmissions);
-	p += sprintf(p, "TxSingleRetryFrames=%u\n",
-		     sums->tx_single_retry_frames);
-	p += sprintf(p, "TxMultipleRetryFrames=%u\n",
-		     sums->tx_multiple_retry_frames);
-	p += sprintf(p, "TxRetryLimitExceeded=%u\n",
-		     sums->tx_retry_limit_exceeded);
-	p += sprintf(p, "TxDiscards=%u\n", sums->tx_discards);
-	p += sprintf(p, "RxUnicastFrames=%u\n", sums->rx_unicast_frames);
-	p += sprintf(p, "RxMulticastFrames=%u\n", sums->rx_multicast_frames);
-	p += sprintf(p, "RxFragments=%u\n", sums->rx_fragments);
-	p += sprintf(p, "RxUnicastOctets=%u\n", sums->rx_unicast_octets);
-	p += sprintf(p, "RxMulticastOctets=%u\n", sums->rx_multicast_octets);
-	p += sprintf(p, "RxFCSErrors=%u\n", sums->rx_fcs_errors);
-	p += sprintf(p, "RxDiscardsNoBuffer=%u\n",
-		     sums->rx_discards_no_buffer);
-	p += sprintf(p, "TxDiscardsWrongSA=%u\n", sums->tx_discards_wrong_sa);
-	p += sprintf(p, "RxDiscardsWEPUndecryptable=%u\n",
-		     sums->rx_discards_wep_undecryptable);
-	p += sprintf(p, "RxMessageInMsgFragments=%u\n",
-		     sums->rx_message_in_msg_fragments);
-	p += sprintf(p, "RxMessageInBadMsgFragments=%u\n",
-		     sums->rx_message_in_bad_msg_fragments);
+	seq_printf(m, "TxUnicastFrames=%u\n", sums->tx_unicast_frames);
+	seq_printf(m, "TxMulticastframes=%u\n", sums->tx_multicast_frames);
+	seq_printf(m, "TxFragments=%u\n", sums->tx_fragments);
+	seq_printf(m, "TxUnicastOctets=%u\n", sums->tx_unicast_octets);
+	seq_printf(m, "TxMulticastOctets=%u\n", sums->tx_multicast_octets);
+	seq_printf(m, "TxDeferredTransmissions=%u\n",
+		   sums->tx_deferred_transmissions);
+	seq_printf(m, "TxSingleRetryFrames=%u\n", sums->tx_single_retry_frames);
+	seq_printf(m, "TxMultipleRetryFrames=%u\n",
+		   sums->tx_multiple_retry_frames);
+	seq_printf(m, "TxRetryLimitExceeded=%u\n",
+		   sums->tx_retry_limit_exceeded);
+	seq_printf(m, "TxDiscards=%u\n", sums->tx_discards);
+	seq_printf(m, "RxUnicastFrames=%u\n", sums->rx_unicast_frames);
+	seq_printf(m, "RxMulticastFrames=%u\n", sums->rx_multicast_frames);
+	seq_printf(m, "RxFragments=%u\n", sums->rx_fragments);
+	seq_printf(m, "RxUnicastOctets=%u\n", sums->rx_unicast_octets);
+	seq_printf(m, "RxMulticastOctets=%u\n", sums->rx_multicast_octets);
+	seq_printf(m, "RxFCSErrors=%u\n", sums->rx_fcs_errors);
+	seq_printf(m, "RxDiscardsNoBuffer=%u\n", sums->rx_discards_no_buffer);
+	seq_printf(m, "TxDiscardsWrongSA=%u\n", sums->tx_discards_wrong_sa);
+	seq_printf(m, "RxDiscardsWEPUndecryptable=%u\n",
+		   sums->rx_discards_wep_undecryptable);
+	seq_printf(m, "RxMessageInMsgFragments=%u\n",
+		   sums->rx_message_in_msg_fragments);
+	seq_printf(m, "RxMessageInBadMsgFragments=%u\n",
+		   sums->rx_message_in_bad_msg_fragments);
 	/* FIX: this may grow too long for one page(?) */
 
-	return (p - page);
+	return 0;
+}
+
+static int prism2_stats_proc_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, prism2_stats_proc_show, PDE_DATA(inode));
 }
 
+static const struct file_operations prism2_stats_proc_fops = {
+	.open		= prism2_stats_proc_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
+
 
-static int prism2_wds_proc_read(char *page, char **start, off_t off,
-				int count, int *eof, void *data)
+static int prism2_wds_proc_show(struct seq_file *m, void *v)
 {
-	char *p = page;
-	local_info_t *local = (local_info_t *) data;
-	struct list_head *ptr;
+	struct list_head *ptr = v;
 	struct hostap_interface *iface;
 
-	if (off > PROC_LIMIT) {
-		*eof = 1;
-		return 0;
-	}
+	iface = list_entry(ptr, struct hostap_interface, list);
+	if (iface->type == HOSTAP_INTERFACE_WDS)
+		seq_printf(m, "%s\t%pM\n",
+			   iface->dev->name, iface->u.wds.remote_addr);
+	return 0;
+}
 
+static void *prism2_wds_proc_start(struct seq_file *m, loff_t *_pos)
+{
+	local_info_t *local = m->private;
 	read_lock_bh(&local->iface_lock);
-	list_for_each(ptr, &local->hostap_interfaces) {
-		iface = list_entry(ptr, struct hostap_interface, list);
-		if (iface->type != HOSTAP_INTERFACE_WDS)
-			continue;
-		p += sprintf(p, "%s\t%pM\n",
-			     iface->dev->name,
-			     iface->u.wds.remote_addr);
-		if ((p - page) > PROC_LIMIT) {
-			printk(KERN_DEBUG "%s: wds proc did not fit\n",
-			       local->dev->name);
-			break;
-		}
-	}
-	read_unlock_bh(&local->iface_lock);
+	return seq_list_start(&local->hostap_interfaces, *_pos);
+}
 
-	if ((p - page) <= off) {
-		*eof = 1;
-		return 0;
-	}
+static void *prism2_wds_proc_next(struct seq_file *m, void *v, loff_t *_pos)
+{
+	local_info_t *local = m->private;
+	return seq_list_next(v, &local->hostap_interfaces, _pos);
+}
+
+static void prism2_wds_proc_stop(struct seq_file *m, void *v)
+{
+	local_info_t *local = m->private;
+	read_unlock_bh(&local->iface_lock);
+}
 
-	*start = page + off;
+static const struct seq_operations prism2_wds_proc_seqops = {
+	.start	= prism2_wds_proc_start,
+	.next	= prism2_wds_proc_next,
+	.stop	= prism2_wds_proc_stop,
+	.show	= prism2_wds_proc_show,
+};
 
-	return (p - page - off);
+static int prism2_wds_proc_open(struct inode *inode, struct file *file)
+{
+	int ret = seq_open(file, &prism2_wds_proc_seqops);
+	if (ret == 0) {
+		struct seq_file *m = file->private_data;
+		m->private = PDE_DATA(inode);
+	}
+	return ret;
 }
 
+static const struct file_operations prism2_wds_proc_fops = {
+	.open		= prism2_wds_proc_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
 
-static int prism2_bss_list_proc_read(char *page, char **start, off_t off,
-				     int count, int *eof, void *data)
+
+static int prism2_bss_list_proc_show(struct seq_file *m, void *v)
 {
-	char *p = page;
-	local_info_t *local = (local_info_t *) data;
-	struct list_head *ptr;
+	local_info_t *local = m->private;
+	struct list_head *ptr = v;
 	struct hostap_bss_info *bss;
 	int i;
 
-	if (off > PROC_LIMIT) {
-		*eof = 1;
+	if (ptr == &local->bss_list) {
+		seq_printf(m, "#BSSID\tlast_update\tcount\tcapab_info\tSSID(txt)\t"
+			   "SSID(hex)\tWPA IE\n");
 		return 0;
 	}
 
-	p += sprintf(p, "#BSSID\tlast_update\tcount\tcapab_info\tSSID(txt)\t"
-		     "SSID(hex)\tWPA IE\n");
+	bss = list_entry(ptr, struct hostap_bss_info, list);
+	seq_printf(m, "%pM\t%lu\t%u\t0x%x\t",
+		   bss->bssid, bss->last_update,
+		   bss->count, bss->capab_info);
+
+	for (i = 0; i < bss->ssid_len; i++)
+		seq_putc(m,bss->ssid[i] >= 32 && bss->ssid[i] < 127 ?
+			   bss->ssid[i] : '_');
+
+	seq_putc(m, '\t');
+	for (i = 0; i < bss->ssid_len; i++)
+		seq_printf(m, "%02x", bss->ssid[i]);
+	seq_putc(m, '\t');
+	for (i = 0; i < bss->wpa_ie_len; i++)
+		seq_printf(m, "%02x", bss->wpa_ie[i]);
+	seq_putc(m, '\n');
+	return 0;
+}
+
+static void *prism2_bss_list_proc_start(struct seq_file *m, loff_t *_pos)
+{
+	local_info_t *local = m->private;
 	spin_lock_bh(&local->lock);
-	list_for_each(ptr, &local->bss_list) {
-		bss = list_entry(ptr, struct hostap_bss_info, list);
-		p += sprintf(p, "%pM\t%lu\t%u\t0x%x\t",
-			     bss->bssid, bss->last_update,
-			     bss->count, bss->capab_info);
-		for (i = 0; i < bss->ssid_len; i++) {
-			p += sprintf(p, "%c",
-				     bss->ssid[i] >= 32 && bss->ssid[i] < 127 ?
-				     bss->ssid[i] : '_');
-		}
-		p += sprintf(p, "\t");
-		for (i = 0; i < bss->ssid_len; i++) {
-			p += sprintf(p, "%02x", bss->ssid[i]);
-		}
-		p += sprintf(p, "\t");
-		for (i = 0; i < bss->wpa_ie_len; i++) {
-			p += sprintf(p, "%02x", bss->wpa_ie[i]);
-		}
-		p += sprintf(p, "\n");
-		if ((p - page) > PROC_LIMIT) {
-			printk(KERN_DEBUG "%s: BSS proc did not fit\n",
-			       local->dev->name);
-			break;
-		}
-	}
-	spin_unlock_bh(&local->lock);
+	return seq_list_start_head(&local->bss_list, *_pos);
+}
 
-	if ((p - page) <= off) {
-		*eof = 1;
-		return 0;
-	}
+static void *prism2_bss_list_proc_next(struct seq_file *m, void *v, loff_t *_pos)
+{
+	local_info_t *local = m->private;
+	return seq_list_next(v, &local->bss_list, _pos);
+}
+
+static void prism2_bss_list_proc_stop(struct seq_file *m, void *v)
+{
+	local_info_t *local = m->private;
+	spin_unlock_bh(&local->lock);
+}
 
-	*start = page + off;
+static const struct seq_operations prism2_bss_list_proc_seqops = {
+	.start	= prism2_bss_list_proc_start,
+	.next	= prism2_bss_list_proc_next,
+	.stop	= prism2_bss_list_proc_stop,
+	.show	= prism2_bss_list_proc_show,
+};
 
-	return (p - page - off);
+static int prism2_bss_list_proc_open(struct inode *inode, struct file *file)
+{
+	int ret = seq_open(file, &prism2_bss_list_proc_seqops);
+	if (ret == 0) {
+		struct seq_file *m = file->private_data;
+		m->private = PDE_DATA(inode);
+	}
+	return ret;
 }
 
+static const struct file_operations prism2_bss_list_proc_fops = {
+	.open		= prism2_bss_list_proc_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
 
-static int prism2_crypt_proc_read(char *page, char **start, off_t off,
-				  int count, int *eof, void *data)
+
+static int prism2_crypt_proc_show(struct seq_file *m, void *v)
 {
-	char *p = page;
-	local_info_t *local = (local_info_t *) data;
+	local_info_t *local = m->private;
 	int i;
 
-	if (off > PROC_LIMIT) {
-		*eof = 1;
-		return 0;
-	}
-
-	p += sprintf(p, "tx_keyidx=%d\n", local->crypt_info.tx_keyidx);
+	seq_printf(m, "tx_keyidx=%d\n", local->crypt_info.tx_keyidx);
 	for (i = 0; i < WEP_KEYS; i++) {
 		if (local->crypt_info.crypt[i] &&
 		    local->crypt_info.crypt[i]->ops &&
 		    local->crypt_info.crypt[i]->ops->print_stats) {
-			p = local->crypt_info.crypt[i]->ops->print_stats(
-				p, local->crypt_info.crypt[i]->priv);
+			local->crypt_info.crypt[i]->ops->print_stats(
+				m, local->crypt_info.crypt[i]->priv);
 		}
 	}
+	return 0;
+}
 
-	if ((p - page) <= off) {
-		*eof = 1;
-		return 0;
-	}
-
-	*start = page + off;
-
-	return (p - page - off);
+static int prism2_crypt_proc_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, prism2_crypt_proc_show, PDE_DATA(inode));
 }
 
+static const struct file_operations prism2_crypt_proc_fops = {
+	.open		= prism2_crypt_proc_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
+
 
-static int prism2_pda_proc_read(char *page, char **start, off_t off,
-				int count, int *eof, void *data)
+static ssize_t prism2_pda_proc_read(struct file *file, char __user *buf,
+				    size_t count, loff_t *_pos)
 {
-	local_info_t *local = (local_info_t *) data;
+	local_info_t *local = PDE_DATA(file_inode(file));
+	size_t off;
 
-	if (local->pda == NULL || off >= PRISM2_PDA_SIZE) {
-		*eof = 1;
+	if (local->pda == NULL || *_pos >= PRISM2_PDA_SIZE)
 		return 0;
-	}
 
-	if (off + count > PRISM2_PDA_SIZE)
+	off = *_pos;
+	if (count > PRISM2_PDA_SIZE - off)
 		count = PRISM2_PDA_SIZE - off;
-
-	memcpy(page, local->pda + off, count);
+	if (copy_to_user(buf, local->pda + off, count) != 0)
+		return -EFAULT;
+	*_pos += count;
 	return count;
 }
 
+static const struct file_operations prism2_pda_proc_fops = {
+	.read		= prism2_pda_proc_read,
+	.llseek		= generic_file_llseek,
+};
 
-static int prism2_aux_dump_proc_read(char *page, char **start, off_t off,
-				     int count, int *eof, void *data)
-{
-	local_info_t *local = (local_info_t *) data;
-
-	if (local->func->read_aux == NULL) {
-		*eof = 1;
-		return 0;
-	}
-
-	if (local->func->read_aux(local->dev, off, count, page)) {
-		*eof = 1;
-		return 0;
-	}
-	*start = page;
 
-	return count;
+static ssize_t prism2_aux_dump_proc_no_read(struct file *file, char __user *buf,
+					    size_t bufsize, loff_t *_pos)
+{
+	return 0;
 }
 
+static const struct file_operations prism2_aux_dump_proc_fops = {
+	.read		= prism2_aux_dump_proc_no_read,
+};
+
 
 #ifdef PRISM2_IO_DEBUG
 static int prism2_io_debug_proc_read(char *page, char **start, off_t off,
@@ -306,82 +344,108 @@ static int prism2_io_debug_proc_read(char *page, char **start, off_t off,
 
 
 #ifndef PRISM2_NO_STATION_MODES
-static int prism2_scan_results_proc_read(char *page, char **start, off_t off,
-					 int count, int *eof, void *data)
+static int prism2_scan_results_proc_show(struct seq_file *m, void *v)
 {
-	char *p = page;
-	local_info_t *local = (local_info_t *) data;
-	int entry, i, len, total = 0;
+	local_info_t *local = m->private;
+	unsigned long entry;
+	int i, len;
 	struct hfa384x_hostscan_result *scanres;
-	u8 *pos;
+	u8 *p;
 
-	p += sprintf(p, "CHID ANL SL BcnInt Capab Rate BSSID ATIM SupRates "
-		     "SSID\n");
+	if (v == SEQ_START_TOKEN) {
+		seq_printf(m,
+			   "CHID ANL SL BcnInt Capab Rate BSSID ATIM SupRates SSID\n");
+		return 0;
+	}
+
+	entry = (unsigned long)v - 2;
+	scanres = &local->last_scan_results[entry];
+
+	seq_printf(m, "%d %d %d %d 0x%02x %d %pM %d ",
+		   le16_to_cpu(scanres->chid),
+		   (s16) le16_to_cpu(scanres->anl),
+		   (s16) le16_to_cpu(scanres->sl),
+		   le16_to_cpu(scanres->beacon_interval),
+		   le16_to_cpu(scanres->capability),
+		   le16_to_cpu(scanres->rate),
+		   scanres->bssid,
+		   le16_to_cpu(scanres->atim));
+
+	p = scanres->sup_rates;
+	for (i = 0; i < sizeof(scanres->sup_rates); i++) {
+		if (p[i] == 0)
+			break;
+		seq_printf(m, "<%02x>", p[i]);
+	}
+	seq_putc(m, ' ');
+
+	p = scanres->ssid;
+	len = le16_to_cpu(scanres->ssid_len);
+	if (len > 32)
+		len = 32;
+	for (i = 0; i < len; i++) {
+		unsigned char c = p[i];
+		if (c >= 32 && c < 127)
+			seq_putc(m, c);
+		else
+			seq_printf(m, "<%02x>", c);
+	}
+	seq_putc(m, '\n');
+	return 0;
+}
 
+static void *prism2_scan_results_proc_start(struct seq_file *m, loff_t *_pos)
+{
+	local_info_t *local = m->private;
 	spin_lock_bh(&local->lock);
-	for (entry = 0; entry < local->last_scan_results_count; entry++) {
-		scanres = &local->last_scan_results[entry];
 
-		if (total + (p - page) <= off) {
-			total += p - page;
-			p = page;
-		}
-		if (total + (p - page) > off + count)
-			break;
-		if ((p - page) > (PAGE_SIZE - 200))
-			break;
+	/* We have a header (pos 0) + N results to show (pos 1...N) */
+	if (*_pos > local->last_scan_results_count)
+		return NULL;
+	return (void *)(unsigned long)(*_pos + 1); /* 0 would be EOF */
+}
 
-		p += sprintf(p, "%d %d %d %d 0x%02x %d %pM %d ",
-			     le16_to_cpu(scanres->chid),
-			     (s16) le16_to_cpu(scanres->anl),
-			     (s16) le16_to_cpu(scanres->sl),
-			     le16_to_cpu(scanres->beacon_interval),
-			     le16_to_cpu(scanres->capability),
-			     le16_to_cpu(scanres->rate),
-			     scanres->bssid,
-			     le16_to_cpu(scanres->atim));
-
-		pos = scanres->sup_rates;
-		for (i = 0; i < sizeof(scanres->sup_rates); i++) {
-			if (pos[i] == 0)
-				break;
-			p += sprintf(p, "<%02x>", pos[i]);
-		}
-		p += sprintf(p, " ");
-
-		pos = scanres->ssid;
-		len = le16_to_cpu(scanres->ssid_len);
-		if (len > 32)
-			len = 32;
-		for (i = 0; i < len; i++) {
-			unsigned char c = pos[i];
-			if (c >= 32 && c < 127)
-				p += sprintf(p, "%c", c);
-			else
-				p += sprintf(p, "<%02x>", c);
-		}
-		p += sprintf(p, "\n");
-	}
+static void *prism2_scan_results_proc_next(struct seq_file *m, void *v, loff_t *_pos)
+{
+	local_info_t *local = m->private;
+
+	++*_pos;
+	if (*_pos > local->last_scan_results_count)
+		return NULL;
+	return (void *)(unsigned long)(*_pos + 1); /* 0 would be EOF */
+}
+
+static void prism2_scan_results_proc_stop(struct seq_file *m, void *v)
+{
+	local_info_t *local = m->private;
 	spin_unlock_bh(&local->lock);
+}
 
-	total += (p - page);
-	if (total >= off + count)
-		*eof = 1;
+static const struct seq_operations prism2_scan_results_proc_seqops = {
+	.start	= prism2_scan_results_proc_start,
+	.next	= prism2_scan_results_proc_next,
+	.stop	= prism2_scan_results_proc_stop,
+	.show	= prism2_scan_results_proc_show,
+};
 
-	if (total < off) {
-		*eof = 1;
-		return 0;
+static int prism2_scan_results_proc_open(struct inode *inode, struct file *file)
+{
+	int ret = seq_open(file, &prism2_scan_results_proc_seqops);
+	if (ret == 0) {
+		struct seq_file *m = file->private_data;
+		m->private = PDE_DATA(inode);
 	}
+	return ret;
+}
+
+static const struct file_operations prism2_scan_results_proc_fops = {
+	.open		= prism2_scan_results_proc_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
 
-	len = total - off;
-	if (len > (p - page))
-		len = p - page;
-	*start = p - len;
-	if (len > count)
-		len = count;
 
-	return len;
-}
 #endif /* PRISM2_NO_STATION_MODES */
 
 
@@ -403,28 +467,29 @@ void hostap_init_proc(local_info_t *local)
 	}
 
 #ifndef PRISM2_NO_PROCFS_DEBUG
-	create_proc_read_entry("debug", 0, local->proc,
-			       prism2_debug_proc_read, local);
+	proc_create_data("debug", 0, local->proc,
+			 &prism2_debug_proc_fops, local);
 #endif /* PRISM2_NO_PROCFS_DEBUG */
-	create_proc_read_entry("stats", 0, local->proc,
-			       prism2_stats_proc_read, local);
-	create_proc_read_entry("wds", 0, local->proc,
-			       prism2_wds_proc_read, local);
-	create_proc_read_entry("pda", 0, local->proc,
-			       prism2_pda_proc_read, local);
-	create_proc_read_entry("aux_dump", 0, local->proc,
-			       prism2_aux_dump_proc_read, local);
-	create_proc_read_entry("bss_list", 0, local->proc,
-			       prism2_bss_list_proc_read, local);
-	create_proc_read_entry("crypt", 0, local->proc,
-			       prism2_crypt_proc_read, local);
+	proc_create_data("stats", 0, local->proc,
+			 &prism2_stats_proc_fops, local);
+	proc_create_data("wds", 0, local->proc,
+			 &prism2_wds_proc_fops, local);
+	proc_create_data("pda", 0, local->proc,
+			 &prism2_pda_proc_fops, local);
+	proc_create_data("aux_dump", 0, local->proc,
+			 local->func->read_aux_fops ?: &prism2_aux_dump_proc_fops,
+			 local);
+	proc_create_data("bss_list", 0, local->proc,
+			 &prism2_bss_list_proc_fops, local);
+	proc_create_data("crypt", 0, local->proc,
+			 &prism2_crypt_proc_fops, local);
 #ifdef PRISM2_IO_DEBUG
-	create_proc_read_entry("io_debug", 0, local->proc,
-			       prism2_io_debug_proc_read, local);
+	proc_create_data("io_debug", 0, local->proc,
+			 &prism2_io_debug_proc_fops, local);
 #endif /* PRISM2_IO_DEBUG */
 #ifndef PRISM2_NO_STATION_MODES
-	create_proc_read_entry("scan_results", 0, local->proc,
-			       prism2_scan_results_proc_read, local);
+	proc_create_data("scan_results", 0, local->proc,
+			 &prism2_scan_results_proc_fops, local);
 #endif /* PRISM2_NO_STATION_MODES */
 }
 
diff --git a/drivers/net/wireless/hostap/hostap_wlan.h b/drivers/net/wireless/hostap/hostap_wlan.h
index 7bb0b4b..5790401 100644
--- a/drivers/net/wireless/hostap/hostap_wlan.h
+++ b/drivers/net/wireless/hostap/hostap_wlan.h
@@ -596,8 +596,7 @@ struct prism2_helper_functions {
 			struct prism2_download_param *param);
 	int (*tx)(struct sk_buff *skb, struct net_device *dev);
 	int (*set_tim)(struct net_device *dev, int aid, int set);
-	int (*read_aux)(struct net_device *dev, unsigned addr, int len,
-			u8 *buf);
+	const struct file_operations *read_aux_fops;
 
 	int need_tx_headroom; /* number of bytes of headroom needed before
 			       * IEEE 802.11 header */
diff --git a/drivers/staging/rtl8192e/rtllib_crypt_ccmp.c b/drivers/staging/rtl8192e/rtllib_crypt_ccmp.c
index 4217b88..e51cb49 100644
--- a/drivers/staging/rtl8192e/rtllib_crypt_ccmp.c
+++ b/drivers/staging/rtl8192e/rtllib_crypt_ccmp.c
@@ -412,19 +412,18 @@ static int rtllib_ccmp_get_key(void *key, int len, u8 *seq, void *priv)
 }
 
 
-static char *rtllib_ccmp_print_stats(char *p, void *priv)
+static void rtllib_ccmp_print_stats(struct seq_file *m, void *priv)
 {
 	struct rtllib_ccmp_data *ccmp = priv;
-	p += sprintf(p, "key[%d] alg=CCMP key_set=%d "
-		     "tx_pn=%pM rx_pn=%pM "
-		     "format_errors=%d replays=%d decrypt_errors=%d\n",
-		     ccmp->key_idx, ccmp->key_set,
-		     ccmp->tx_pn, ccmp->rx_pn,
-		     ccmp->dot11RSNAStatsCCMPFormatErrors,
-		     ccmp->dot11RSNAStatsCCMPReplays,
-		     ccmp->dot11RSNAStatsCCMPDecryptErrors);
-
-	return p;
+	seq_printf(m,
+		   "key[%d] alg=CCMP key_set=%d "
+		   "tx_pn=%pM rx_pn=%pM "
+		   "format_errors=%d replays=%d decrypt_errors=%d\n",
+		   ccmp->key_idx, ccmp->key_set,
+		   ccmp->tx_pn, ccmp->rx_pn,
+		   ccmp->dot11RSNAStatsCCMPFormatErrors,
+		   ccmp->dot11RSNAStatsCCMPReplays,
+		   ccmp->dot11RSNAStatsCCMPDecryptErrors);
 }
 
 static struct lib80211_crypto_ops rtllib_crypt_ccmp = {
diff --git a/drivers/staging/rtl8192e/rtllib_crypt_tkip.c b/drivers/staging/rtl8192e/rtllib_crypt_tkip.c
index 8009250..5cfd73b 100644
--- a/drivers/staging/rtl8192e/rtllib_crypt_tkip.c
+++ b/drivers/staging/rtl8192e/rtllib_crypt_tkip.c
@@ -708,30 +708,30 @@ static int rtllib_tkip_get_key(void *key, int len, u8 *seq, void *priv)
 }
 
 
-static char *rtllib_tkip_print_stats(char *p, void *priv)
+static void rtllib_tkip_print_stats(struct seq_file *m, void *priv)
 {
 	struct rtllib_tkip_data *tkip = priv;
-	p += sprintf(p, "key[%d] alg=TKIP key_set=%d "
-		     "tx_pn=%02x%02x%02x%02x%02x%02x "
-		     "rx_pn=%02x%02x%02x%02x%02x%02x "
-		     "replays=%d icv_errors=%d local_mic_failures=%d\n",
-		     tkip->key_idx, tkip->key_set,
-		     (tkip->tx_iv32 >> 24) & 0xff,
-		     (tkip->tx_iv32 >> 16) & 0xff,
-		     (tkip->tx_iv32 >> 8) & 0xff,
-		     tkip->tx_iv32 & 0xff,
-		     (tkip->tx_iv16 >> 8) & 0xff,
-		     tkip->tx_iv16 & 0xff,
-		     (tkip->rx_iv32 >> 24) & 0xff,
-		     (tkip->rx_iv32 >> 16) & 0xff,
-		     (tkip->rx_iv32 >> 8) & 0xff,
-		     tkip->rx_iv32 & 0xff,
-		     (tkip->rx_iv16 >> 8) & 0xff,
-		     tkip->rx_iv16 & 0xff,
-		     tkip->dot11RSNAStatsTKIPReplays,
-		     tkip->dot11RSNAStatsTKIPICVErrors,
-		     tkip->dot11RSNAStatsTKIPLocalMICFailures);
-	return p;
+	seq_printf(m,
+		   "key[%d] alg=TKIP key_set=%d "
+		   "tx_pn=%02x%02x%02x%02x%02x%02x "
+		   "rx_pn=%02x%02x%02x%02x%02x%02x "
+		   "replays=%d icv_errors=%d local_mic_failures=%d\n",
+		   tkip->key_idx, tkip->key_set,
+		   (tkip->tx_iv32 >> 24) & 0xff,
+		   (tkip->tx_iv32 >> 16) & 0xff,
+		   (tkip->tx_iv32 >> 8) & 0xff,
+		   tkip->tx_iv32 & 0xff,
+		   (tkip->tx_iv16 >> 8) & 0xff,
+		   tkip->tx_iv16 & 0xff,
+		   (tkip->rx_iv32 >> 24) & 0xff,
+		   (tkip->rx_iv32 >> 16) & 0xff,
+		   (tkip->rx_iv32 >> 8) & 0xff,
+		   tkip->rx_iv32 & 0xff,
+		   (tkip->rx_iv16 >> 8) & 0xff,
+		   tkip->rx_iv16 & 0xff,
+		   tkip->dot11RSNAStatsTKIPReplays,
+		   tkip->dot11RSNAStatsTKIPICVErrors,
+		   tkip->dot11RSNAStatsTKIPLocalMICFailures);
 }
 
 static struct lib80211_crypto_ops rtllib_crypt_tkip = {
diff --git a/drivers/staging/rtl8192e/rtllib_crypt_wep.c b/drivers/staging/rtl8192e/rtllib_crypt_wep.c
index 8cdf389..c4df6e0 100644
--- a/drivers/staging/rtl8192e/rtllib_crypt_wep.c
+++ b/drivers/staging/rtl8192e/rtllib_crypt_wep.c
@@ -247,12 +247,10 @@ static int prism2_wep_get_key(void *key, int len, u8 *seq, void *priv)
 }
 
 
-static char *prism2_wep_print_stats(char *p, void *priv)
+static void prism2_wep_print_stats(struct seq_file *m, void *priv)
 {
 	struct prism2_wep_data *wep = priv;
-	p += sprintf(p, "key[%d] alg=WEP len=%d\n",
-		     wep->key_idx, wep->key_len);
-	return p;
+	seq_printf(m, "key[%d] alg=WEP len=%d\n", wep->key_idx, wep->key_len);
 }
 
 static struct lib80211_crypto_ops rtllib_crypt_wep = {
diff --git a/include/net/lib80211.h b/include/net/lib80211.h
index d178c26..be95b92 100644
--- a/include/net/lib80211.h
+++ b/include/net/lib80211.h
@@ -30,6 +30,8 @@
 #include <linux/skbuff.h>
 #include <linux/ieee80211.h>
 #include <linux/timer.h>
+#include <linux/seq_file.h>
+
 /* print_ssid() is intended to be used in debug (and possibly error)
  * messages. It should never be used for passing ssid to user space. */
 const char *print_ssid(char *buf, const char *ssid, u8 ssid_len);
@@ -75,7 +77,7 @@ struct lib80211_crypto_ops {
 
 	/* procfs handler for printing out key information and possible
 	 * statistics */
-	char *(*print_stats) (char *p, void *priv);
+	void (*print_stats) (struct seq_file *m, void *priv);
 
 	/* Crypto specific flag get/set for configuration settings */
 	unsigned long (*get_flags) (void *priv);
diff --git a/net/wireless/lib80211_crypt_ccmp.c b/net/wireless/lib80211_crypt_ccmp.c
index 1526c21..dc0e59e 100644
--- a/net/wireless/lib80211_crypt_ccmp.c
+++ b/net/wireless/lib80211_crypt_ccmp.c
@@ -430,24 +430,23 @@ static int lib80211_ccmp_get_key(void *key, int len, u8 * seq, void *priv)
 	return CCMP_TK_LEN;
 }
 
-static char *lib80211_ccmp_print_stats(char *p, void *priv)
+static void lib80211_ccmp_print_stats(struct seq_file *m, void *priv)
 {
 	struct lib80211_ccmp_data *ccmp = priv;
 
-	p += sprintf(p, "key[%d] alg=CCMP key_set=%d "
-		     "tx_pn=%02x%02x%02x%02x%02x%02x "
-		     "rx_pn=%02x%02x%02x%02x%02x%02x "
-		     "format_errors=%d replays=%d decrypt_errors=%d\n",
-		     ccmp->key_idx, ccmp->key_set,
-		     ccmp->tx_pn[0], ccmp->tx_pn[1], ccmp->tx_pn[2],
-		     ccmp->tx_pn[3], ccmp->tx_pn[4], ccmp->tx_pn[5],
-		     ccmp->rx_pn[0], ccmp->rx_pn[1], ccmp->rx_pn[2],
-		     ccmp->rx_pn[3], ccmp->rx_pn[4], ccmp->rx_pn[5],
-		     ccmp->dot11RSNAStatsCCMPFormatErrors,
-		     ccmp->dot11RSNAStatsCCMPReplays,
-		     ccmp->dot11RSNAStatsCCMPDecryptErrors);
-
-	return p;
+	seq_printf(m,
+		   "key[%d] alg=CCMP key_set=%d "
+		   "tx_pn=%02x%02x%02x%02x%02x%02x "
+		   "rx_pn=%02x%02x%02x%02x%02x%02x "
+		   "format_errors=%d replays=%d decrypt_errors=%d\n",
+		   ccmp->key_idx, ccmp->key_set,
+		   ccmp->tx_pn[0], ccmp->tx_pn[1], ccmp->tx_pn[2],
+		   ccmp->tx_pn[3], ccmp->tx_pn[4], ccmp->tx_pn[5],
+		   ccmp->rx_pn[0], ccmp->rx_pn[1], ccmp->rx_pn[2],
+		   ccmp->rx_pn[3], ccmp->rx_pn[4], ccmp->rx_pn[5],
+		   ccmp->dot11RSNAStatsCCMPFormatErrors,
+		   ccmp->dot11RSNAStatsCCMPReplays,
+		   ccmp->dot11RSNAStatsCCMPDecryptErrors);
 }
 
 static struct lib80211_crypto_ops lib80211_crypt_ccmp = {
diff --git a/net/wireless/lib80211_crypt_tkip.c b/net/wireless/lib80211_crypt_tkip.c
index d475cfc..8c90ba7 100644
--- a/net/wireless/lib80211_crypt_tkip.c
+++ b/net/wireless/lib80211_crypt_tkip.c
@@ -703,30 +703,30 @@ static int lib80211_tkip_get_key(void *key, int len, u8 * seq, void *priv)
 	return TKIP_KEY_LEN;
 }
 
-static char *lib80211_tkip_print_stats(char *p, void *priv)
+static void lib80211_tkip_print_stats(struct seq_file *m, void *priv)
 {
 	struct lib80211_tkip_data *tkip = priv;
-	p += sprintf(p, "key[%d] alg=TKIP key_set=%d "
-		     "tx_pn=%02x%02x%02x%02x%02x%02x "
-		     "rx_pn=%02x%02x%02x%02x%02x%02x "
-		     "replays=%d icv_errors=%d local_mic_failures=%d\n",
-		     tkip->key_idx, tkip->key_set,
-		     (tkip->tx_iv32 >> 24) & 0xff,
-		     (tkip->tx_iv32 >> 16) & 0xff,
-		     (tkip->tx_iv32 >> 8) & 0xff,
-		     tkip->tx_iv32 & 0xff,
-		     (tkip->tx_iv16 >> 8) & 0xff,
-		     tkip->tx_iv16 & 0xff,
-		     (tkip->rx_iv32 >> 24) & 0xff,
-		     (tkip->rx_iv32 >> 16) & 0xff,
-		     (tkip->rx_iv32 >> 8) & 0xff,
-		     tkip->rx_iv32 & 0xff,
-		     (tkip->rx_iv16 >> 8) & 0xff,
-		     tkip->rx_iv16 & 0xff,
-		     tkip->dot11RSNAStatsTKIPReplays,
-		     tkip->dot11RSNAStatsTKIPICVErrors,
-		     tkip->dot11RSNAStatsTKIPLocalMICFailures);
-	return p;
+	seq_printf(m,
+		   "key[%d] alg=TKIP key_set=%d "
+		   "tx_pn=%02x%02x%02x%02x%02x%02x "
+		   "rx_pn=%02x%02x%02x%02x%02x%02x "
+		   "replays=%d icv_errors=%d local_mic_failures=%d\n",
+		   tkip->key_idx, tkip->key_set,
+		   (tkip->tx_iv32 >> 24) & 0xff,
+		   (tkip->tx_iv32 >> 16) & 0xff,
+		   (tkip->tx_iv32 >> 8) & 0xff,
+		   tkip->tx_iv32 & 0xff,
+		   (tkip->tx_iv16 >> 8) & 0xff,
+		   tkip->tx_iv16 & 0xff,
+		   (tkip->rx_iv32 >> 24) & 0xff,
+		   (tkip->rx_iv32 >> 16) & 0xff,
+		   (tkip->rx_iv32 >> 8) & 0xff,
+		   tkip->rx_iv32 & 0xff,
+		   (tkip->rx_iv16 >> 8) & 0xff,
+		   tkip->rx_iv16 & 0xff,
+		   tkip->dot11RSNAStatsTKIPReplays,
+		   tkip->dot11RSNAStatsTKIPICVErrors,
+		   tkip->dot11RSNAStatsTKIPLocalMICFailures);
 }
 
 static struct lib80211_crypto_ops lib80211_crypt_tkip = {
diff --git a/net/wireless/lib80211_crypt_wep.c b/net/wireless/lib80211_crypt_wep.c
index c130401..1c292e4 100644
--- a/net/wireless/lib80211_crypt_wep.c
+++ b/net/wireless/lib80211_crypt_wep.c
@@ -253,11 +253,10 @@ static int lib80211_wep_get_key(void *key, int len, u8 * seq, void *priv)
 	return wep->key_len;
 }
 
-static char *lib80211_wep_print_stats(char *p, void *priv)
+static void lib80211_wep_print_stats(struct seq_file *m, void *priv)
 {
 	struct lib80211_wep_data *wep = priv;
-	p += sprintf(p, "key[%d] alg=WEP len=%d\n", wep->key_idx, wep->key_len);
-	return p;
+	seq_printf(m, "key[%d] alg=WEP len=%d\n", wep->key_idx, wep->key_len);
 }
 
 static struct lib80211_crypto_ops lib80211_crypt_wep = {
