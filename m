From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: [PATCH 08/17] batman-adv: Only use int up and down
	gw representation
Date: Mon, 30 May 2011 09:22:53 +0200
Message-ID: <1306740182-2665-9-git-send-email-sven@narfation.org>
References: <1306740182-2665-1-git-send-email-sven@narfation.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1306740182-2665-1-git-send-email-sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

It is not save to provide memory for an int and then cast the pointer to
it to long*. It is better to standardize the up and down gateway
bandwith representation to simple ints and only use long inside
conversation routines.

Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
---
 net/batman-adv/gateway_common.c |   19 ++++++++++---------
 1 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/net/batman-adv/gateway_common.c b/net/batman-adv/gateway_common.c
index 50d3a59..ed3bd36 100644
--- a/net/batman-adv/gateway_common.c
+++ b/net/batman-adv/gateway_common.c
@@ -76,10 +76,11 @@ void gw_bandwidth_to_kbit(uint8_t gw_srv_class, int *down, int *up)
 }
 
 static bool parse_gw_bandwidth(struct net_device *net_dev, char *buff,
-			       long *up, long *down)
+			       int *up, int *down)
 {
 	int ret, multi = 1;
 	char *slash_ptr, *tmp_ptr;
+	long ldown, lup;
 
 	slash_ptr = strchr(buff, '/');
 	if (slash_ptr)
@@ -96,7 +97,7 @@ static bool parse_gw_bandwidth(struct net_device *net_dev, char *buff,
 			*tmp_ptr = '\0';
 	}
 
-	ret = strict_strtoul(buff, 10, down);
+	ret = strict_strtoul(buff, 10, &ldown);
 	if (ret) {
 		bat_err(net_dev,
 			"Download speed of gateway mode invalid: %s\n",
@@ -104,7 +105,7 @@ static bool parse_gw_bandwidth(struct net_device *net_dev, char *buff,
 		return false;
 	}
 
-	*down *= multi;
+	*down = ldown * multi;
 
 	/* we also got some upload info */
 	if (slash_ptr) {
@@ -121,7 +122,7 @@ static bool parse_gw_bandwidth(struct net_device *net_dev, char *buff,
 				*tmp_ptr = '\0';
 		}
 
-		ret = strict_strtoul(slash_ptr + 1, 10, up);
+		ret = strict_strtoul(slash_ptr + 1, 10, &lup);
 		if (ret) {
 			bat_err(net_dev,
 				"Upload speed of gateway mode invalid: "
@@ -129,7 +130,7 @@ static bool parse_gw_bandwidth(struct net_device *net_dev, char *buff,
 			return false;
 		}
 
-		*up *= multi;
+		*up = lup * multi;
 	}
 
 	return true;
@@ -138,7 +139,8 @@ static bool parse_gw_bandwidth(struct net_device *net_dev, char *buff,
 ssize_t gw_bandwidth_set(struct net_device *net_dev, char *buff, size_t count)
 {
 	struct bat_priv *bat_priv = netdev_priv(net_dev);
-	long gw_bandwidth_tmp = 0, up = 0, down = 0;
+	long gw_bandwidth_tmp = 0;
+	int up = 0, down = 0;
 	bool ret;
 
 	ret = parse_gw_bandwidth(net_dev, buff, &up, &down);
@@ -158,12 +160,11 @@ ssize_t gw_bandwidth_set(struct net_device *net_dev, char *buff, size_t count)
 	 * speeds, hence we need to calculate it back to show the number
 	 * that is going to be propagated
 	 **/
-	gw_bandwidth_to_kbit((uint8_t)gw_bandwidth_tmp,
-			     (int *)&down, (int *)&up);
+	gw_bandwidth_to_kbit((uint8_t)gw_bandwidth_tmp, &down, &up);
 
 	gw_deselect(bat_priv);
 	bat_info(net_dev, "Changing gateway bandwidth from: '%i' to: '%ld' "
-		 "(propagating: %ld%s/%ld%s)\n",
+		 "(propagating: %d%s/%d%s)\n",
 		 atomic_read(&bat_priv->gw_bandwidth), gw_bandwidth_tmp,
 		 (down > 2048 ? down / 1024 : down),
 		 (down > 2048 ? "MBit" : "KBit"),
-- 
1.7.5.3
