From: Xander Huff <xander.huff-acOepvfBmUk@public.gmane.org>
Subject: [PATCH RFC] wext: Add event stream wrappers that return E2BIG when values don't fit
Date: Thu, 29 Jan 2015 15:04:12 -0600
Message-ID: <1422565452-19825-1-git-send-email-xander.huff@ni.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, james.minor-acOepvfBmUk@public.gmane.org,
	joseph.hershberger-acOepvfBmUk@public.gmane.org, ben.shelton-acOepvfBmUk@public.gmane.org, jaeden.amero-acOepvfBmUk@public.gmane.org,
	joshc-acOepvfBmUk@public.gmane.org, rich.tollerton-acOepvfBmUk@public.gmane.org, brad.mouring-acOepvfBmUk@public.gmane.org,
	Xander Huff <xander.huff-acOepvfBmUk@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: James Minor <james.minor-acOepvfBmUk@public.gmane.org>

These issues show up when using the WEXT <-> NL80211 conversion layer and
scanning with that. When the scan results come back, some of the IEs
(information elements) are missing, those that specifically advertise the
network security type. This happens due to the IEs getting chopped off in
if the buffer that's passed in isn't large enough to get the full IE. The
fix is to instead return E2BIG. Without this fix, the advertised security
type is misinterpreted, since it appears to be a WPA or WEP network.

Testing with this fix resulted in a network which previously showed up as a
PSK network now correctly showing up as EAP.

Side effects: A user space app which before did not get E2BIG and instead
got a clipped off buffer might now get E2BIG instead, if the passed buffer
is not large enough.

Signed-off-by: James Minor <james.minor-acOepvfBmUk@public.gmane.org>
Signed-off-by: Xander Huff <xander.huff-acOepvfBmUk@public.gmane.org>
Acked-by: Joe Hershberger <joseph.hershberger-acOepvfBmUk@public.gmane.org>
Acked-by: Ben Shelton <ben.shelton-acOepvfBmUk@public.gmane.org>
---
RFC because we're subtlely changing the user/kernel interface
---
 include/net/iw_handler.h |  87 ++++++++++++++++++++++
 net/wireless/scan.c      | 187 ++++++++++++++++++++++++++++++-----------------
 2 files changed, 208 insertions(+), 66 deletions(-)

diff --git a/include/net/iw_handler.h b/include/net/iw_handler.h
index a830b01..f07415a 100644
--- a/include/net/iw_handler.h
+++ b/include/net/iw_handler.h
@@ -521,6 +521,33 @@ iwe_stream_add_event(struct iw_request_info *info, char *stream, char *ends,
 
 /*------------------------------------------------------------------*/
 /*
+ * Wrapper to add an Wireless Event to a stream of events.
+ * Also returns indication of overflow conditions.
+ */
+static inline int
+iwe_stream_add_event_check(struct iw_request_info *info, char **stream,
+			   char *ends, struct iw_event *iwe, int event_len)
+{
+	int lcp_len = iwe_stream_lcp_len(info);
+
+	event_len = iwe_stream_event_len_adjust(info, event_len);
+
+	/* Check if it's possible */
+	if (likely((*stream + event_len) < ends)) {
+		iwe->len = event_len;
+		/* Beware of alignement issues on 64 bits */
+		memcpy(*stream, (char *) iwe, IW_EV_LCP_PK_LEN);
+		memcpy(*stream + lcp_len, &iwe->u,
+		       event_len - lcp_len);
+		*stream += event_len;
+		return 0;
+	} else {
+		return -E2BIG;
+	}
+}
+
+/*------------------------------------------------------------------*/
+/*
  * Wrapper to add an short Wireless Event containing a pointer to a
  * stream of events.
  */
@@ -547,6 +574,35 @@ iwe_stream_add_point(struct iw_request_info *info, char *stream, char *ends,
 
 /*------------------------------------------------------------------*/
 /*
+ * Wrapper to add an short Wireless Event containing a pointer to a
+ * stream of events.
+ * Also returns indication of overflow conditions.
+ */
+static inline int
+iwe_stream_add_point_check(struct iw_request_info *info, char **stream,
+			   char *ends, struct iw_event *iwe, char *extra)
+{
+	int event_len = iwe_stream_point_len(info) + iwe->u.data.length;
+	int point_len = iwe_stream_point_len(info);
+	int lcp_len   = iwe_stream_lcp_len(info);
+
+	/* Check if it's possible */
+	if (likely((*stream + event_len) < ends)) {
+		iwe->len = event_len;
+		memcpy(*stream, (char *) iwe, IW_EV_LCP_PK_LEN);
+		memcpy(*stream + lcp_len,
+		       ((char *) &iwe->u) + IW_EV_POINT_OFF,
+		       IW_EV_POINT_PK_LEN - IW_EV_LCP_PK_LEN);
+		memcpy(*stream + point_len, extra, iwe->u.data.length);
+		*stream += event_len;
+		return 0;
+	} else {
+		return -E2BIG;
+	}
+}
+
+/*------------------------------------------------------------------*/
+/*
  * Wrapper to add a value to a Wireless Event in a stream of events.
  * Be careful, this one is tricky to use properly :
  * At the first run, you need to have (value = event + IW_EV_LCP_LEN).
@@ -572,4 +628,35 @@ iwe_stream_add_value(struct iw_request_info *info, char *event, char *value,
 	return value;
 }
 
+/*------------------------------------------------------------------*/
+/*
+ * Wrapper to add a value to a Wireless Event in a stream of events.
+ * Be careful, this one is tricky to use properly :
+ * At the first run, you need to have (value = event + IW_EV_LCP_LEN).
+ * Also returns indication of overflow conditions.
+ */
+static inline int
+iwe_stream_add_value_check(struct iw_request_info *info, char *event,
+			   char **value, char *ends, struct iw_event *iwe,
+			   int event_len)
+{
+	int lcp_len = iwe_stream_lcp_len(info);
+
+	/* Don't duplicate LCP */
+	event_len -= IW_EV_LCP_LEN;
+
+	/* Check if it's possible */
+	if (likely((*value + event_len) < ends)) {
+		/* Add new value */
+		memcpy(*value, &iwe->u, event_len);
+		*value += event_len;
+		/* Patch LCP */
+		iwe->len = *value - event;
+		memcpy(event, (char *) iwe, lcp_len);
+		return 0;
+	} else {
+		return -E2BIG;
+	}
+}
+
 #endif	/* _IW_HANDLER_H */
diff --git a/net/wireless/scan.c b/net/wireless/scan.c
index c705c3e..1cb64ae 100644
--- a/net/wireless/scan.c
+++ b/net/wireless/scan.c
@@ -1239,15 +1239,16 @@ int cfg80211_wext_siwscan(struct net_device *dev,
 }
 EXPORT_SYMBOL_GPL(cfg80211_wext_siwscan);
 
-static void ieee80211_scan_add_ies(struct iw_request_info *info,
-				   const struct cfg80211_bss_ies *ies,
-				   char **current_ev, char *end_buf)
+static int ieee80211_scan_add_ies(struct iw_request_info *info,
+				  const struct cfg80211_bss_ies *ies,
+				  char **current_ev, char *end_buf)
 {
 	const u8 *pos, *end, *next;
 	struct iw_event iwe;
+	int err = 0;
 
 	if (!ies)
-		return;
+		return err;
 
 	/*
 	 * If needed, fragment the IEs buffer (at IE boundaries) into short
@@ -1264,10 +1265,11 @@ static void ieee80211_scan_add_ies(struct iw_request_info *info,
 		memset(&iwe, 0, sizeof(iwe));
 		iwe.cmd = IWEVGENIE;
 		iwe.u.data.length = next - pos;
-		*current_ev = iwe_stream_add_point(info, *current_ev,
-						   end_buf, &iwe,
-						   (void *)pos);
-
+		err = iwe_stream_add_point_check(info, current_ev,
+						 end_buf, &iwe,
+						 (void *)pos);
+		if (err)
+			return err;
 		pos = next;
 	}
 
@@ -1275,44 +1277,55 @@ static void ieee80211_scan_add_ies(struct iw_request_info *info,
 		memset(&iwe, 0, sizeof(iwe));
 		iwe.cmd = IWEVGENIE;
 		iwe.u.data.length = end - pos;
-		*current_ev = iwe_stream_add_point(info, *current_ev,
-						   end_buf, &iwe,
-						   (void *)pos);
+		err = iwe_stream_add_point_check(info, current_ev,
+						 end_buf, &iwe,
+						 (void *)pos);
+		if (err)
+			return err;
 	}
+	return 0;
 }
 
-static char *
+static int
 ieee80211_bss(struct wiphy *wiphy, struct iw_request_info *info,
-	      struct cfg80211_internal_bss *bss, char *current_ev,
+	      struct cfg80211_internal_bss *bss, char **current_ev,
 	      char *end_buf)
 {
 	const struct cfg80211_bss_ies *ies;
 	struct iw_event iwe;
 	const u8 *ie;
-	u8 *buf, *cfg, *p;
+	u8 *buf, *cfg;
+	char *p;
 	int rem, i, sig;
 	bool ismesh = false;
+	int err;
 
 	memset(&iwe, 0, sizeof(iwe));
 	iwe.cmd = SIOCGIWAP;
 	iwe.u.ap_addr.sa_family = ARPHRD_ETHER;
 	memcpy(iwe.u.ap_addr.sa_data, bss->pub.bssid, ETH_ALEN);
-	current_ev = iwe_stream_add_event(info, current_ev, end_buf, &iwe,
-					  IW_EV_ADDR_LEN);
+	err = iwe_stream_add_event_check(info, current_ev, end_buf, &iwe,
+					 IW_EV_ADDR_LEN);
+	if (err)
+		return err;
 
 	memset(&iwe, 0, sizeof(iwe));
 	iwe.cmd = SIOCGIWFREQ;
 	iwe.u.freq.m = ieee80211_frequency_to_channel(bss->pub.channel->center_freq);
 	iwe.u.freq.e = 0;
-	current_ev = iwe_stream_add_event(info, current_ev, end_buf, &iwe,
-					  IW_EV_FREQ_LEN);
+	err = iwe_stream_add_event_check(info, current_ev, end_buf, &iwe,
+					 IW_EV_FREQ_LEN);
+	if (err)
+		return err;
 
 	memset(&iwe, 0, sizeof(iwe));
 	iwe.cmd = SIOCGIWFREQ;
 	iwe.u.freq.m = bss->pub.channel->center_freq;
 	iwe.u.freq.e = 6;
-	current_ev = iwe_stream_add_event(info, current_ev, end_buf, &iwe,
-					  IW_EV_FREQ_LEN);
+	err = iwe_stream_add_event_check(info, current_ev, end_buf, &iwe,
+					 IW_EV_FREQ_LEN);
+	if (err)
+		return err;
 
 	if (wiphy->signal_type != CFG80211_SIGNAL_TYPE_NONE) {
 		memset(&iwe, 0, sizeof(iwe));
@@ -1341,8 +1354,11 @@ ieee80211_bss(struct wiphy *wiphy, struct iw_request_info *info,
 			/* not reached */
 			break;
 		}
-		current_ev = iwe_stream_add_event(info, current_ev, end_buf,
-						  &iwe, IW_EV_QUAL_LEN);
+		err = iwe_stream_add_event_check(info, current_ev, end_buf,
+						 &iwe, IW_EV_QUAL_LEN);
+		if (err)
+			return err;
+
 	}
 
 	memset(&iwe, 0, sizeof(iwe));
@@ -1352,8 +1368,10 @@ ieee80211_bss(struct wiphy *wiphy, struct iw_request_info *info,
 	else
 		iwe.u.data.flags = IW_ENCODE_DISABLED;
 	iwe.u.data.length = 0;
-	current_ev = iwe_stream_add_point(info, current_ev, end_buf,
-					  &iwe, "");
+	err = iwe_stream_add_point_check(info, current_ev, end_buf,
+					 &iwe, "");
+	if (err)
+		return err;
 
 	rcu_read_lock();
 	ies = rcu_dereference(bss->pub.ies);
@@ -1371,16 +1389,22 @@ ieee80211_bss(struct wiphy *wiphy, struct iw_request_info *info,
 			iwe.cmd = SIOCGIWESSID;
 			iwe.u.data.length = ie[1];
 			iwe.u.data.flags = 1;
-			current_ev = iwe_stream_add_point(info, current_ev, end_buf,
-							  &iwe, (u8 *)ie + 2);
+			err = iwe_stream_add_point_check(info, current_ev,
+							 end_buf, &iwe,
+							 (u8 *)ie + 2);
+			if (err)
+				return err;
 			break;
 		case WLAN_EID_MESH_ID:
 			memset(&iwe, 0, sizeof(iwe));
 			iwe.cmd = SIOCGIWESSID;
 			iwe.u.data.length = ie[1];
 			iwe.u.data.flags = 1;
-			current_ev = iwe_stream_add_point(info, current_ev, end_buf,
-							  &iwe, (u8 *)ie + 2);
+			err = iwe_stream_add_point_check(info, current_ev,
+							 end_buf, &iwe,
+							 (u8 *)ie + 2);
+			if (err)
+				return err;
 			break;
 		case WLAN_EID_MESH_CONFIG:
 			ismesh = true;
@@ -1395,47 +1419,62 @@ ieee80211_bss(struct wiphy *wiphy, struct iw_request_info *info,
 			sprintf(buf, "Mesh Network Path Selection Protocol ID: "
 				"0x%02X", cfg[0]);
 			iwe.u.data.length = strlen(buf);
-			current_ev = iwe_stream_add_point(info, current_ev,
-							  end_buf,
-							  &iwe, buf);
+			err = iwe_stream_add_point_check(info, current_ev,
+							 end_buf,
+							 &iwe, buf);
+			if (err)
+				goto out_fail_mesh;
 			sprintf(buf, "Path Selection Metric ID: 0x%02X",
 				cfg[1]);
 			iwe.u.data.length = strlen(buf);
-			current_ev = iwe_stream_add_point(info, current_ev,
-							  end_buf,
-							  &iwe, buf);
+			err = iwe_stream_add_point_check(info, current_ev,
+							 end_buf,
+							 &iwe, buf);
+			if (err)
+				goto out_fail_mesh;
 			sprintf(buf, "Congestion Control Mode ID: 0x%02X",
 				cfg[2]);
 			iwe.u.data.length = strlen(buf);
-			current_ev = iwe_stream_add_point(info, current_ev,
-							  end_buf,
-							  &iwe, buf);
+			err = iwe_stream_add_point_check(info, current_ev,
+							 end_buf,
+							 &iwe, buf);
+			if (err)
+				goto out_fail_mesh;
 			sprintf(buf, "Synchronization ID: 0x%02X", cfg[3]);
 			iwe.u.data.length = strlen(buf);
-			current_ev = iwe_stream_add_point(info, current_ev,
-							  end_buf,
-							  &iwe, buf);
+			err = iwe_stream_add_point_check(info, current_ev,
+							 end_buf,
+							 &iwe, buf);
+			if (err)
+				goto out_fail_mesh;
 			sprintf(buf, "Authentication ID: 0x%02X", cfg[4]);
 			iwe.u.data.length = strlen(buf);
-			current_ev = iwe_stream_add_point(info, current_ev,
-							  end_buf,
-							  &iwe, buf);
+			err = iwe_stream_add_point_check(info, current_ev,
+							 end_buf,
+							 &iwe, buf);
+			if (err)
+				goto out_fail_mesh;
 			sprintf(buf, "Formation Info: 0x%02X", cfg[5]);
 			iwe.u.data.length = strlen(buf);
-			current_ev = iwe_stream_add_point(info, current_ev,
-							  end_buf,
-							  &iwe, buf);
+			err = iwe_stream_add_point_check(info, current_ev,
+							 end_buf,
+							 &iwe, buf);
+			if (err)
+				goto out_fail_mesh;
 			sprintf(buf, "Capabilities: 0x%02X", cfg[6]);
 			iwe.u.data.length = strlen(buf);
-			current_ev = iwe_stream_add_point(info, current_ev,
-							  end_buf,
-							  &iwe, buf);
+			err = iwe_stream_add_point_check(info, current_ev,
+							 end_buf,
+							 &iwe, buf);
+out_fail_mesh:
 			kfree(buf);
+			if (err)
+				return err;
 			break;
 		case WLAN_EID_SUPP_RATES:
 		case WLAN_EID_EXT_SUPP_RATES:
 			/* display all supported rates in readable format */
-			p = current_ev + iwe_stream_lcp_len(info);
+			p = *current_ev + iwe_stream_lcp_len(info);
 
 			memset(&iwe, 0, sizeof(iwe));
 			iwe.cmd = SIOCGIWRATE;
@@ -1445,10 +1484,13 @@ ieee80211_bss(struct wiphy *wiphy, struct iw_request_info *info,
 			for (i = 0; i < ie[1]; i++) {
 				iwe.u.bitrate.value =
 					((ie[i + 2] & 0x7f) * 500000);
-				p = iwe_stream_add_value(info, current_ev, p,
-						end_buf, &iwe, IW_EV_PARAM_LEN);
+				err = iwe_stream_add_value_check(
+					info, *current_ev, &p, end_buf, &iwe,
+					IW_EV_PARAM_LEN);
+				if (err)
+					return err;
 			}
-			current_ev = p;
+			*current_ev = p;
 			break;
 		}
 		rem -= ie[1] + 2;
@@ -1465,8 +1507,10 @@ ieee80211_bss(struct wiphy *wiphy, struct iw_request_info *info,
 			iwe.u.mode = IW_MODE_MASTER;
 		else
 			iwe.u.mode = IW_MODE_ADHOC;
-		current_ev = iwe_stream_add_event(info, current_ev, end_buf,
-						  &iwe, IW_EV_UINT_LEN);
+		err = iwe_stream_add_event_check(info, current_ev, end_buf,
+						 &iwe, IW_EV_UINT_LEN);
+		if (err)
+			return err;
 	}
 
 	buf = kmalloc(31, GFP_ATOMIC);
@@ -1475,22 +1519,26 @@ ieee80211_bss(struct wiphy *wiphy, struct iw_request_info *info,
 		iwe.cmd = IWEVCUSTOM;
 		sprintf(buf, "tsf=%016llx", (unsigned long long)(ies->tsf));
 		iwe.u.data.length = strlen(buf);
-		current_ev = iwe_stream_add_point(info, current_ev, end_buf,
-						  &iwe, buf);
+		err = iwe_stream_add_point_check(info, current_ev, end_buf,
+						 &iwe, buf);
+		if (err)
+			return err;
 		memset(&iwe, 0, sizeof(iwe));
 		iwe.cmd = IWEVCUSTOM;
 		sprintf(buf, " Last beacon: %ums ago",
 			elapsed_jiffies_msecs(bss->ts));
 		iwe.u.data.length = strlen(buf);
-		current_ev = iwe_stream_add_point(info, current_ev,
-						  end_buf, &iwe, buf);
+		err = iwe_stream_add_point_check(info, current_ev,
+						 end_buf, &iwe, buf);
 		kfree(buf);
+		if (err)
+			return err;
 	}
 
-	ieee80211_scan_add_ies(info, ies, &current_ev, end_buf);
+	err = ieee80211_scan_add_ies(info, ies, current_ev, end_buf);
 	rcu_read_unlock();
 
-	return current_ev;
+	return err;
 }
 
 
@@ -1501,20 +1549,27 @@ static int ieee80211_scan_results(struct cfg80211_registered_device *rdev,
 	char *current_ev = buf;
 	char *end_buf = buf + len;
 	struct cfg80211_internal_bss *bss;
+	int err = 0;
 
 	spin_lock_bh(&rdev->bss_lock);
 	cfg80211_bss_expire(rdev);
 
 	list_for_each_entry(bss, &rdev->bss_list, list) {
 		if (buf + len - current_ev <= IW_EV_ADDR_LEN) {
-			spin_unlock_bh(&rdev->bss_lock);
-			return -E2BIG;
+			err = -E2BIG;
+			goto out_fail;
 		}
-		current_ev = ieee80211_bss(&rdev->wiphy, info, bss,
-					   current_ev, end_buf);
+		err = ieee80211_bss(&rdev->wiphy, info, bss,
+				    &current_ev, end_buf);
+		if (err)
+			goto out_fail;
 	}
+ out_fail:
 	spin_unlock_bh(&rdev->bss_lock);
-	return current_ev - buf;
+	if (err)
+		return err;
+	else
+		return current_ev - buf;
 }
 
 
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
