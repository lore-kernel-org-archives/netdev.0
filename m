From: Chris Leech <cleech-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [RFC PATCH 2/4] iscsi: sysfs filtering by network namespace
Date: Wed, 13 May 2015 15:12:45 -0700
Message-ID: <1431555167-23995-3-git-send-email-cleech@redhat.com>
References: <1431555167-23995-1-git-send-email-cleech@redhat.com>
Reply-To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: <open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>, <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <open-iscsi+bncBCYMVIPVXQMBB7UYZ6VAKGQEKHITVFA-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <1431555167-23995-1-git-send-email-cleech-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Post: <http://groups.google.com/group/open-iscsi/post>, <mailto:open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:open-iscsi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/open-iscsi
Sender: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/open-iscsi/subscribe>, <mailto:open-iscsi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+856124926423+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <http://groups.google.com/group/open-iscsi/subscribe>
List-Id: netdev.vger.kernel.org

This makes the iscsi_host, iscsi_session, iscsi_connection, and
iscsi_endpoint transport class devices only visible in sysfs under a
matching network namespace.  The network namespace for all of these
objects is tracked in the iscsi_cls_host structure.
---
 drivers/scsi/scsi_transport_iscsi.c | 114 ++++++++++++++++++++++++++++++------
 include/scsi/scsi_transport_iscsi.h |   1 +
 2 files changed, 98 insertions(+), 17 deletions(-)

diff --git a/drivers/scsi/scsi_transport_iscsi.c b/drivers/scsi/scsi_transport_iscsi.c
index 88a3347..2b146cb 100644
--- a/drivers/scsi/scsi_transport_iscsi.c
+++ b/drivers/scsi/scsi_transport_iscsi.c
@@ -161,9 +161,33 @@ static void iscsi_endpoint_release(struct device *dev)
 	kfree(ep);
 }
 
+static const struct net *iscsi_host_net(struct iscsi_cls_host *ihost)
+{
+	return ihost->netns;
+}
+
+static const struct net *iscsi_endpoint_net(struct iscsi_endpoint *ep)
+{
+	struct iscsi_cls_conn *cls_conn = ep->conn;
+	struct iscsi_cls_session *cls_session = iscsi_conn_to_session(cls_conn);
+	struct Scsi_Host *shost = iscsi_session_to_shost(cls_session);
+	struct iscsi_cls_host *ihost = shost->shost_data;
+
+	return iscsi_host_net(ihost);
+}
+
+static const void *iscsi_endpoint_namespace(struct device *dev)
+{
+	struct iscsi_endpoint *ep = iscsi_dev_to_endpoint(dev);
+
+	return iscsi_endpoint_net(ep);
+}
+
 static struct class iscsi_endpoint_class = {
 	.name = "iscsi_endpoint",
 	.dev_release = iscsi_endpoint_release,
+	.ns_type = &net_ns_type_operations,
+	.namespace = iscsi_endpoint_namespace,
 };
 
 static ssize_t
@@ -1570,6 +1594,7 @@ static int iscsi_setup_host(struct transport_container *tc, struct device *dev,
 	memset(ihost, 0, sizeof(*ihost));
 	atomic_set(&ihost->nr_scans, 0);
 	mutex_init(&ihost->mutex);
+	ihost->netns = &init_net;
 
 	iscsi_bsg_host_add(shost, ihost);
 	/* ignore any bsg add error - we just can't do sgio */
@@ -1590,23 +1615,78 @@ static int iscsi_remove_host(struct transport_container *tc,
 	return 0;
 }
 
-static DECLARE_TRANSPORT_CLASS(iscsi_host_class,
-			       "iscsi_host",
-			       iscsi_setup_host,
-			       iscsi_remove_host,
-			       NULL);
-
-static DECLARE_TRANSPORT_CLASS(iscsi_session_class,
-			       "iscsi_session",
-			       NULL,
-			       NULL,
-			       NULL);
-
-static DECLARE_TRANSPORT_CLASS(iscsi_connection_class,
-			       "iscsi_connection",
-			       NULL,
-			       NULL,
-			       NULL);
+#define DECLARE_TRANSPORT_CLASS_NS(cls, nm, su, rm, cfg, ns, nslookup)	\
+struct transport_class cls = {						\
+	.class = {							\
+		.name = nm,						\
+		.ns_type = ns,						\
+		.namespace = nslookup,					\
+	},								\
+	.setup = su,							\
+	.remove = rm,							\
+	.configure = cfg,						\
+}
+
+static const void *iscsi_host_namespace(struct device *dev)
+{
+	struct Scsi_Host *shost = transport_class_to_shost(dev);
+	struct iscsi_cls_host *ihost = shost->shost_data;
+
+	return iscsi_host_net(ihost);
+}
+
+static DECLARE_TRANSPORT_CLASS_NS(iscsi_host_class,
+				  "iscsi_host",
+				  iscsi_setup_host,
+				  iscsi_remove_host,
+				  NULL,
+				  &net_ns_type_operations,
+				  iscsi_host_namespace);
+
+static const struct net *iscsi_sess_net(struct iscsi_cls_session *cls_session)
+{
+	struct Scsi_Host *shost = iscsi_session_to_shost(cls_session);
+	struct iscsi_cls_host *ihost = shost->shost_data;
+
+	return iscsi_host_net(ihost);
+}
+
+static const void *iscsi_sess_namespace(struct device *dev)
+{
+	struct iscsi_cls_session *cls_session = transport_class_to_session(dev);
+
+	return iscsi_sess_net(cls_session);
+}
+
+static DECLARE_TRANSPORT_CLASS_NS(iscsi_session_class,
+				  "iscsi_session",
+				  NULL,
+				  NULL,
+				  NULL,
+				  &net_ns_type_operations,
+				  iscsi_sess_namespace);
+
+static const struct net *iscsi_conn_net(struct iscsi_cls_conn *cls_conn)
+{
+	struct iscsi_cls_session *cls_session = iscsi_conn_to_session(cls_conn);
+
+	return iscsi_sess_net(cls_session);
+}
+
+static const void *iscsi_conn_namespace(struct device *dev)
+{
+	struct iscsi_cls_conn *cls_conn = transport_class_to_conn(dev);
+
+	return iscsi_conn_net(cls_conn);
+}
+
+static DECLARE_TRANSPORT_CLASS_NS(iscsi_connection_class,
+				  "iscsi_connection",
+				  NULL,
+				  NULL,
+				  NULL,
+				  &net_ns_type_operations,
+				  iscsi_conn_namespace);
 
 struct iscsi_net {
 	struct sock *nls;
diff --git a/include/scsi/scsi_transport_iscsi.h b/include/scsi/scsi_transport_iscsi.h
index 2555ee5..860ac0c 100644
--- a/include/scsi/scsi_transport_iscsi.h
+++ b/include/scsi/scsi_transport_iscsi.h
@@ -275,6 +275,7 @@ struct iscsi_cls_host {
 	struct request_queue *bsg_q;
 	uint32_t port_speed;
 	uint32_t port_state;
+	struct net *netns;
 };
 
 #define iscsi_job_to_shost(_job) \
-- 
2.1.0

-- 
You received this message because you are subscribed to the Google Groups "open-iscsi" group.
To unsubscribe from this group and stop receiving emails from it, send an email to open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
To post to this group, send email to open-iscsi-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
Visit this group at http://groups.google.com/group/open-iscsi.
For more options, visit https://groups.google.com/d/optout.
