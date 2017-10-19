From: Samuel Mendoza-Jonas <sam@mendozajonas.com>
Subject: [PATCH net 4/5] net/ncsi: Enforce failover on link monitor timeout
Date: Thu, 19 Oct 2017 13:43:08 +1100
Message-ID: <20171019024309.13628-4-sam@mendozajonas.com>
References: <20171019024309.13628-1-sam@mendozajonas.com>
Cc: Gavin Shan <gwshan@linux.vnet.ibm.com>,
        "David S . Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org,
        Samuel Mendoza-Jonas <sam@mendozajonas.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171019024309.13628-1-sam@mendozajonas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gavin Shan <gwshan@linux.vnet.ibm.com>

The NCSI channel has been configured to provide service if its link
monitor timer is enabled, regardless of its state (inactive or active).
So the timeout event on the link monitor indicates the out-of-service
on that channel, for which a failover is needed.

This sets NCSI_DEV_RESHUFFLE flag to enforce failover on link monitor
timeout, regardless the channel's original state (inactive or active).
Also, the link is put into "down" state to give the failing channel
lowest priority when selecting for the active channel. The state of
failing channel should be set to active in order for deinitialization
and failover to be done.

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
Signed-off-by: Samuel Mendoza-Jonas <sam@mendozajonas.com>
---
 net/ncsi/ncsi-manage.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/ncsi/ncsi-manage.c b/net/ncsi/ncsi-manage.c
index 0966eff48ce7..28c42b22b748 100644
--- a/net/ncsi/ncsi-manage.c
+++ b/net/ncsi/ncsi-manage.c
@@ -189,6 +189,7 @@ static void ncsi_channel_monitor(unsigned long data)
 	struct ncsi_channel *nc = (struct ncsi_channel *)data;
 	struct ncsi_package *np = nc->package;
 	struct ncsi_dev_priv *ndp = np->ndp;
+	struct ncsi_channel_mode *ncm;
 	struct ncsi_cmd_arg nca;
 	bool enabled, chained;
 	unsigned int monitor_state;
@@ -228,20 +229,21 @@ static void ncsi_channel_monitor(unsigned long data)
 	case NCSI_CHANNEL_MONITOR_WAIT ... NCSI_CHANNEL_MONITOR_WAIT_MAX:
 		break;
 	default:
-		if (!(ndp->flags & NCSI_DEV_HWA) &&
-		    state == NCSI_CHANNEL_ACTIVE) {
+		if (!(ndp->flags & NCSI_DEV_HWA)) {
 			ncsi_report_link(ndp, true);
 			ndp->flags |= NCSI_DEV_RESHUFFLE;
 		}
 
 		ncsi_stop_channel_monitor(nc);
 
+		ncm = &nc->modes[NCSI_MODE_LINK];
 		spin_lock_irqsave(&nc->lock, flags);
 		nc->state = NCSI_CHANNEL_INVISIBLE;
+		ncm->data[2] &= ~0x1;
 		spin_unlock_irqrestore(&nc->lock, flags);
 
 		spin_lock_irqsave(&ndp->lock, flags);
-		nc->state = NCSI_CHANNEL_INACTIVE;
+		nc->state = NCSI_CHANNEL_ACTIVE;
 		list_add_tail_rcu(&nc->link, &ndp->channel_queue);
 		spin_unlock_irqrestore(&ndp->lock, flags);
 		ncsi_process_next_channel(ndp);
-- 
2.14.2
