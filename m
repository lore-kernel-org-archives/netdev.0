From: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2 5/5] net: Add Open vSwitch kernel
	components.
Date: Mon, 21 Nov 2011 13:59:55 -0800
Message-ID: <20111121135955.571254b1@nehalam.linuxnetplumber.net>
References: <1321911029-20707-1-git-send-email-jesse@nicira.com>
	<1321911029-20707-6-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1321911029-20707-6-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 21 Nov 2011 13:30:29 -0800
Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org> wrote:

> +/**
> + *	vport_record_error - indicate device error to generic stats layer
> + *
> + * @vport: vport that encountered the error
> + * @err_type: one of enum vport_err_type types to indicate the error type
> + *
> + * If using the vport generic stats layer indicate that an error of the given
> + * type has occured.
> + */
> +void vport_record_error(struct vport *vport, enum vport_err_type err_type)
> +{
> +	spin_lock(&vport->stats_lock);

Sorry for over analyzing this... but I don't think the stats_lock
is necessary either. The only thing it is protecting is against 64 bit
wrap. If you used another u64_stat_sync for that one, it could be eliminated.

Maybe?


--- a/net/openvswitch/vport.c	2011-11-21 13:56:54.991757053 -0800
+++ b/net/openvswitch/vport.c	2011-11-21 13:57:49.352333329 -0800
@@ -130,8 +130,6 @@ struct vport *vport_alloc(int priv_size,
 	if (!vport->percpu_stats)
 		return ERR_PTR(-ENOMEM);
 
-	spin_lock_init(&vport->stats_lock);
-
 	return vport;
 }
 
@@ -235,6 +233,7 @@ void vport_del(struct vport *vport)
 void vport_get_stats(struct vport *vport, struct ovs_vport_stats *stats)
 {
 	int i;
+	unsigned int start;
 
 	memset(stats, 0, sizeof(*stats));
 
@@ -247,19 +246,17 @@ void vport_get_stats(struct vport *vport
 	 * netdev-stats can be directly read over netlink-ioctl.
 	 */
 
-	spin_lock_bh(&vport->stats_lock);
-
-	stats->rx_errors	= vport->err_stats.rx_errors;
-	stats->tx_errors	= vport->err_stats.tx_errors;
-	stats->tx_dropped	= vport->err_stats.tx_dropped;
-	stats->rx_dropped	= vport->err_stats.rx_dropped;
-
-	spin_unlock_bh(&vport->stats_lock);
+	do {
+		start = u64_stats_fetch_begin_bh(&vport->err_stats.sync);
+		stats->rx_errors	= vport->err_stats.rx_errors;
+		stats->tx_errors	= vport->err_stats.tx_errors;
+		stats->tx_dropped	= vport->err_stats.tx_dropped;
+		stats->rx_dropped	= vport->err_stats.rx_dropped;
+	} while (u64_stats_fetch_retry_bh(&vport->err_stats.sync, start));
 
 	for_each_possible_cpu(i) {
 		const struct vport_percpu_stats *percpu_stats;
 		struct vport_percpu_stats local_stats;
-		unsigned int start;
 
 		percpu_stats = per_cpu_ptr(vport->percpu_stats, i);
 
@@ -372,7 +369,7 @@ int vport_send(struct vport *vport, stru
  */
 void vport_record_error(struct vport *vport, enum vport_err_type err_type)
 {
-	spin_lock(&vport->stats_lock);
+	u64_stats_update_begin(&vport->err_stats.sync);
 
 	switch (err_type) {
 	case VPORT_E_RX_DROPPED:
@@ -392,5 +389,5 @@ void vport_record_error(struct vport *vp
 		break;
 	};
 
-	spin_unlock(&vport->stats_lock);
+	u64_stats_update_end(&vport->err_stats.sync);
 }
--- a/net/openvswitch/vport.h	2011-11-21 13:56:54.991757053 -0800
+++ b/net/openvswitch/vport.h	2011-11-21 13:58:01.448461585 -0800
@@ -62,6 +62,7 @@ struct vport_err_stats {
 	u64 rx_errors;
 	u64 tx_dropped;
 	u64 tx_errors;
+	struct u64_stats_sync sync;
 };
 
 /**
