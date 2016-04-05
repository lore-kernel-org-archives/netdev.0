From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [RFC PATCH 2/6] ppp: don't hold ppp_mutex before calling
 ppp_unattached_ioctl()
Date: Tue, 5 Apr 2016 02:56:20 +0200
Message-ID: <97e90b123669a441512a73711421b2fd0f1fb031.1459807527.git.g.nault@alphalink.fr>
References: <cover.1459807527.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-ppp@vger.kernel.org, Paul Mackerras <paulus@samba.org>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:55803 "EHLO
	zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752016AbcDEA4Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 20:56:25 -0400
Content-Disposition: inline
In-Reply-To: <cover.1459807527.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Let ppp_unattached_ioctl() lock ppp_mutex only when needed.
For PPPIOCATTACH and PPPIOCATTCHAN, we just need to lock ppp_mutex
before all_ppp_mutex/all_channels_lock (to keep lock ordering) and to
take care of the -ENOTTY error code when file->private_data is not
NULL.
For PPPIOCNEWUNIT, ppp_mutex is pushed further down in
ppp_create_interface() and is held right before rtnl_lock. The goal is
to eventually lock ppp_mutex after rtnl_lock, so that PPP device
creation can be done inside a rtnetlink function handler.

While there, remove unused ppp_file argument from ppp_unattached_ioctl()
prototype.

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 drivers/net/ppp/ppp_generic.c | 51 +++++++++++++++++++++++++++++++++----------
 1 file changed, 39 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index ec83b83..7329c72 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -245,8 +245,8 @@ struct ppp_net {
 #define seq_after(a, b)		((s32)((a) - (b)) > 0)
 
 /* Prototypes. */
-static int ppp_unattached_ioctl(struct net *net, struct ppp_file *pf,
-			struct file *file, unsigned int cmd, unsigned long arg);
+static int ppp_unattached_ioctl(struct net *net, struct file *file,
+				unsigned int cmd, unsigned long arg);
 static void ppp_xmit_process(struct ppp *ppp);
 static void ppp_send_frame(struct ppp *ppp, struct sk_buff *skb);
 static void ppp_push(struct ppp *ppp);
@@ -584,12 +584,19 @@ static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 	void __user *argp = (void __user *)arg;
 	int __user *p = argp;
 
+	switch (cmd) {
+	case PPPIOCNEWUNIT:
+	case PPPIOCATTACH:
+	case PPPIOCATTCHAN:
+		return ppp_unattached_ioctl(current->nsproxy->net_ns, file,
+					    cmd, arg);
+	}
+
 	mutex_lock(&ppp_mutex);
 
 	pf = file->private_data;
 	if (!pf) {
-		err = ppp_unattached_ioctl(current->nsproxy->net_ns,
-					   pf, file, cmd, arg);
+		err = -ENOTTY;
 		goto out;
 	}
 
@@ -838,8 +845,8 @@ out:
 	return err;
 }
 
-static int ppp_unattached_ioctl(struct net *net, struct ppp_file *pf,
-			struct file *file, unsigned int cmd, unsigned long arg)
+static int ppp_unattached_ioctl(struct net *net, struct file *file,
+				unsigned int cmd, unsigned long arg)
 {
 	int unit, err = -EFAULT;
 	struct ppp *ppp;
@@ -867,31 +874,43 @@ static int ppp_unattached_ioctl(struct net *net, struct ppp_file *pf,
 		/* Attach to an existing ppp unit */
 		if (get_user(unit, p))
 			break;
+
 		err = -ENXIO;
 		pn = ppp_pernet(net);
+		mutex_lock(&ppp_mutex);
 		mutex_lock(&pn->all_ppp_mutex);
 		ppp = ppp_find_unit(pn, unit);
 		if (ppp) {
-			atomic_inc(&ppp->file.refcnt);
-			file->private_data = &ppp->file;
-			err = 0;
+			err = -ENOTTY;
+			if (!file->private_data) {
+				atomic_inc(&ppp->file.refcnt);
+				file->private_data = &ppp->file;
+				err = 0;
+			}
 		}
 		mutex_unlock(&pn->all_ppp_mutex);
+		mutex_unlock(&ppp_mutex);
 		break;
 
 	case PPPIOCATTCHAN:
 		if (get_user(unit, p))
 			break;
+
 		err = -ENXIO;
 		pn = ppp_pernet(net);
+		mutex_lock(&ppp_mutex);
 		spin_lock_bh(&pn->all_channels_lock);
 		chan = ppp_find_channel(pn, unit);
 		if (chan) {
-			atomic_inc(&chan->file.refcnt);
-			file->private_data = &chan->file;
-			err = 0;
+			err = -ENOTTY;
+			if (!file->private_data) {
+				atomic_inc(&chan->file.refcnt);
+				file->private_data = &chan->file;
+				err = 0;
+			}
 		}
 		spin_unlock_bh(&pn->all_channels_lock);
+		mutex_unlock(&ppp_mutex);
 		break;
 
 	default:
@@ -2772,9 +2791,15 @@ static int ppp_create_interface(struct net *net, struct file *file, int *unit)
 	 */
 	dev_net_set(dev, net);
 
+	mutex_lock(&ppp_mutex);
 	rtnl_lock();
 	mutex_lock(&pn->all_ppp_mutex);
 
+	if (file->private_data) {
+		ret = -ENOTTY;
+		goto out2;
+	}
+
 	if (*unit < 0) {
 		ret = unit_get(&pn->units_idr, ppp);
 		if (ret < 0)
@@ -2818,12 +2843,14 @@ static int ppp_create_interface(struct net *net, struct file *file, int *unit)
 
 	mutex_unlock(&pn->all_ppp_mutex);
 	rtnl_unlock();
+	mutex_unlock(&ppp_mutex);
 
 	return 0;
 
 out2:
 	mutex_unlock(&pn->all_ppp_mutex);
 	rtnl_unlock();
+	mutex_unlock(&ppp_mutex);
 	free_netdev(dev);
 out1:
 	return ret;
-- 
2.8.0.rc3
