From: Chris Wright <chrisw@sous-sol.org>
Subject: [PATCH 2/2 v2] netlink: kill eff_cap from struct netlink_skb_parms
Date: Thu, 3 Mar 2011 12:15:22 -0800
Message-ID: <20110303201522.GT4988@sequoia.sous-sol.org>
References: <4D6F6180.5030903@trash.net>
 <20110303173230.GP4988@sequoia.sous-sol.org>
 <20110303.105655.189705829.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chrisw@sous-sol.org, kaber@trash.net, netdev@vger.kernel.org,
	dm-devel@redhat.com, linux-security-module@vger.kernel.org,
	drbd-dev@lists.linbit.com, Evgeniy Polyakov <zbr@ioremap.net>,
	linux-fbdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sous-sol.org ([216.99.217.87]:47641 "EHLO sequoia.sous-sol.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758196Ab1CCUP6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2011 15:15:58 -0500
Content-Disposition: inline
In-Reply-To: <20110303.105655.189705829.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* David Miller (davem@davemloft.net) wrote:
> From: Chris Wright <chrisw@sous-sol.org>
> Date: Thu, 3 Mar 2011 09:32:30 -0800
> 
> > * Patrick McHardy (kaber@trash.net) wrote:
> > 
> >> commit 8ff259625f0ab295fa085b0718eed13093813fbc
> >> Author: Patrick McHardy <kaber@trash.net>
> >> Date:   Thu Mar 3 10:17:31 2011 +0100
> >> 
> >>     netlink: kill eff_cap from struct netlink_skb_parms
> >>     
> >>     Netlink message processing in the kernel is synchronous these days,
> >>     capabilities can be checked directly in security_netlink_recv() from
> >>     the current process.
> >>     
> >>     Signed-off-by: Patrick McHardy <kaber@trash.net>
> > 
> > Thanks for doing that Patrick.  I looked at this earlier and thought
> > there was still an async path, but I guess that's just to another
> > userspace process.
> > 
> > BTW, I think you missed a couple connector based callers:
> > 
> > drivers/staging/pohmelfs/config.c:      if (!cap_raised(nsp->eff_cap, CAP_SYS_AD
> > drivers/video/uvesafb.c:        if (!cap_raised(nsp->eff_cap, CAP_SYS_ADMIN))
> > 
> > Fix those and:
> > 
> > Acked-by: Chris Wright <chrisw@sous-sol.org>
> 
> Patrick, I'll apply your first patch, please respin this second patch with
> the changes mentioned here.

Here, I respun it so I could work on top of it

thanks,
-chris
---
From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2/2 v2] netlink: kill eff_cap from struct netlink_skb_parms

Netlink message processing in the kernel is synchronous these days,
capabilities can be checked directly in security_netlink_recv() from
the current process.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Reviewed-by: James Morris <jmorris@namei.org>
[chrisw: update to include pohmelfs and uvesafb]
Signed-off-by: Chris Wright <chrisw@sous-sol.org>
---

I did not do exhaustive .config compile tests

 drivers/block/drbd/drbd_nl.c           |    2 +-
 drivers/md/dm-log-userspace-transfer.c |    2 +-
 drivers/staging/pohmelfs/config.c      |    2 +-
 drivers/video/uvesafb.c                |    2 +-
 include/linux/netlink.h                |    1 -
 net/netlink/af_netlink.c               |    6 ------
 security/commoncap.c                   |    3 +--
 7 files changed, 5 insertions(+), 13 deletions(-)

diff --git a/drivers/block/drbd/drbd_nl.c b/drivers/block/drbd/drbd_nl.c
index 8cbfaa6..fe81c85 100644
--- a/drivers/block/drbd/drbd_nl.c
+++ b/drivers/block/drbd/drbd_nl.c
@@ -2177,7 +2177,7 @@ static void drbd_connector_callback(struct cn_msg *req, struct netlink_skb_parms
 		return;
 	}
 
-	if (!cap_raised(nsp->eff_cap, CAP_SYS_ADMIN)) {
+	if (!cap_raised(current_cap(), CAP_SYS_ADMIN)) {
 		retcode = ERR_PERM;
 		goto fail;
 	}
diff --git a/drivers/md/dm-log-userspace-transfer.c b/drivers/md/dm-log-userspace-transfer.c
index 049eaf1..1f23e04 100644
--- a/drivers/md/dm-log-userspace-transfer.c
+++ b/drivers/md/dm-log-userspace-transfer.c
@@ -134,7 +134,7 @@ static void cn_ulog_callback(struct cn_msg *msg, struct netlink_skb_parms *nsp)
 {
 	struct dm_ulog_request *tfr = (struct dm_ulog_request *)(msg + 1);
 
-	if (!cap_raised(nsp->eff_cap, CAP_SYS_ADMIN))
+	if (!cap_raised(current_cap(), CAP_SYS_ADMIN))
 		return;
 
 	spin_lock(&receiving_list_lock);
diff --git a/drivers/staging/pohmelfs/config.c b/drivers/staging/pohmelfs/config.c
index 89279ba..39413b7 100644
--- a/drivers/staging/pohmelfs/config.c
+++ b/drivers/staging/pohmelfs/config.c
@@ -525,7 +525,7 @@ static void pohmelfs_cn_callback(struct cn_msg *msg, struct netlink_skb_parms *n
 {
 	int err;
 
-	if (!cap_raised(nsp->eff_cap, CAP_SYS_ADMIN))
+	if (!cap_raised(current_cap(), CAP_SYS_ADMIN))
 		return;
 
 	switch (msg->flags) {
diff --git a/drivers/video/uvesafb.c b/drivers/video/uvesafb.c
index 52ec095..5180a21 100644
--- a/drivers/video/uvesafb.c
+++ b/drivers/video/uvesafb.c
@@ -73,7 +73,7 @@ static void uvesafb_cn_callback(struct cn_msg *msg, struct netlink_skb_parms *ns
 	struct uvesafb_task *utask;
 	struct uvesafb_ktask *task;
 
-	if (!cap_raised(nsp->eff_cap, CAP_SYS_ADMIN))
+	if (!cap_raised(current_cap(), CAP_SYS_ADMIN))
 		return;
 
 	if (msg->seq >= UVESAFB_TASKS_MAX)
diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 66823b8..4c4ac3f 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -160,7 +160,6 @@ struct netlink_skb_parms {
 	struct ucred		creds;		/* Skb credentials	*/
 	__u32			pid;
 	__u32			dst_group;
-	kernel_cap_t		eff_cap;
 };
 
 #define NETLINK_CB(skb)		(*(struct netlink_skb_parms*)&((skb)->cb))
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 97ecd92..a808fb1 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1364,12 +1364,6 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	NETLINK_CB(skb).dst_group = dst_group;
 	memcpy(NETLINK_CREDS(skb), &siocb->scm->creds, sizeof(struct ucred));
 
-	/* What can I do? Netlink is asynchronous, so that
-	   we will have to save current capabilities to
-	   check them, when this message will be delivered
-	   to corresponding kernel module.   --ANK (980802)
-	 */
-
 	err = -EFAULT;
 	if (memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len)) {
 		kfree_skb(skb);
diff --git a/security/commoncap.c b/security/commoncap.c
index 64c2ed9..a83e607 100644
--- a/security/commoncap.c
+++ b/security/commoncap.c
@@ -52,13 +52,12 @@ static void warn_setuid_and_fcaps_mixed(const char *fname)
 
 int cap_netlink_send(struct sock *sk, struct sk_buff *skb)
 {
-	NETLINK_CB(skb).eff_cap = current_cap();
 	return 0;
 }
 
 int cap_netlink_recv(struct sk_buff *skb, int cap)
 {
-	if (!cap_raised(NETLINK_CB(skb).eff_cap, cap))
+	if (!cap_raised(current_cap(), cap))
 		return -EPERM;
 	return 0;
 }
-- 
1.7.1

