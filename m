From: Chris Leech <cleech-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [RFC PATCH 4/4] iscsi: set netns for iscsi_tcp hosts
Date: Wed, 13 May 2015 15:12:47 -0700
Message-ID: <1431555167-23995-5-git-send-email-cleech@redhat.com>
References: <1431555167-23995-1-git-send-email-cleech@redhat.com>
Reply-To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: <open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>, <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <open-iscsi+bncBCYMVIPVXQMBBAEZZ6VAKGQEEORZBLA-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <1431555167-23995-1-git-send-email-cleech-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Post: <http://groups.google.com/group/open-iscsi/post>, <mailto:open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:open-iscsi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/open-iscsi
Sender: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/open-iscsi/subscribe>, <mailto:open-iscsi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+856124926423+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <http://groups.google.com/group/open-iscsi/subscribe>
List-Id: netdev.vger.kernel.org

This lets iscsi_tcp operate in multiple namespaces.  It uses current
during session creation to find the net namespace, but it might be
better to manage to pass it along from the iscsi netlink socket.
---
 drivers/scsi/iscsi_tcp.c            | 7 +++++++
 drivers/scsi/scsi_transport_iscsi.c | 7 ++++++-
 include/scsi/scsi_transport_iscsi.h | 1 +
 3 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/drivers/scsi/iscsi_tcp.c b/drivers/scsi/iscsi_tcp.c
index 0b8af18..ebe99da 100644
--- a/drivers/scsi/iscsi_tcp.c
+++ b/drivers/scsi/iscsi_tcp.c
@@ -948,6 +948,11 @@ static int iscsi_sw_tcp_slave_configure(struct scsi_device *sdev)
 	return 0;
 }
 
+static struct net *iscsi_sw_tcp_netns(struct Scsi_Host *shost)
+{
+	return current->nsproxy->net_ns;
+}
+
 static struct scsi_host_template iscsi_sw_tcp_sht = {
 	.module			= THIS_MODULE,
 	.name			= "iSCSI Initiator over TCP/IP",
@@ -1003,6 +1008,8 @@ static struct iscsi_transport iscsi_sw_tcp_transport = {
 	.alloc_pdu		= iscsi_sw_tcp_pdu_alloc,
 	/* recovery */
 	.session_recovery_timedout = iscsi_session_recovery_timedout,
+	/* net namespace */
+	.get_netns		= iscsi_sw_tcp_netns,
 };
 
 static int __init iscsi_sw_tcp_init(void)
diff --git a/drivers/scsi/scsi_transport_iscsi.c b/drivers/scsi/scsi_transport_iscsi.c
index 4fdd4bf..791aacd 100644
--- a/drivers/scsi/scsi_transport_iscsi.c
+++ b/drivers/scsi/scsi_transport_iscsi.c
@@ -1590,11 +1590,16 @@ static int iscsi_setup_host(struct transport_container *tc, struct device *dev,
 {
 	struct Scsi_Host *shost = dev_to_shost(dev);
 	struct iscsi_cls_host *ihost = shost->shost_data;
+	struct iscsi_internal *priv = to_iscsi_internal(shost->transportt);
+	struct iscsi_transport *transport = priv->iscsi_transport;
 
 	memset(ihost, 0, sizeof(*ihost));
 	atomic_set(&ihost->nr_scans, 0);
 	mutex_init(&ihost->mutex);
-	ihost->netns = &init_net;
+	if (transport->get_netns)
+		ihost->netns = transport->get_netns(shost);
+	else
+		ihost->netns = &init_net;
 
 	iscsi_bsg_host_add(shost, ihost);
 	/* ignore any bsg add error - we just can't do sgio */
diff --git a/include/scsi/scsi_transport_iscsi.h b/include/scsi/scsi_transport_iscsi.h
index 860ac0c..878bcf2 100644
--- a/include/scsi/scsi_transport_iscsi.h
+++ b/include/scsi/scsi_transport_iscsi.h
@@ -168,6 +168,7 @@ struct iscsi_transport {
 	int (*logout_flashnode_sid) (struct iscsi_cls_session *cls_sess);
 	int (*get_host_stats) (struct Scsi_Host *shost, char *buf, int len);
 	u8 (*check_protection)(struct iscsi_task *task, sector_t *sector);
+	struct net *(*get_netns)(struct Scsi_Host *shost);
 };
 
 /*
-- 
2.1.0

-- 
You received this message because you are subscribed to the Google Groups "open-iscsi" group.
To unsubscribe from this group and stop receiving emails from it, send an email to open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
To post to this group, send email to open-iscsi-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
Visit this group at http://groups.google.com/group/open-iscsi.
For more options, visit https://groups.google.com/d/optout.
