From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: RE: [PATCH] Infiniband: Randomize local port allocation.
Date: Thu, 15 Apr 2010 14:46:30 +0900
Message-ID: <201004150546.o3F5kUtb094163@www262.sakura.ne.jp>
References: <20100412100744.5302.92442.sendpatchset@localhost.localdomain>	<20100412100816.5302.74919.sendpatchset@localhost.localdomain>	<201004130121.o3D1Lhh7099571@www262.sakura.ne.jp>	<4BC41994.7030707@redhat.com>	<4BC42FE0.4040601@redhat.com> <201004132207.GAJ52684.OJFtMQVFHOSFLO@I-love.SAKURA.ne.jp> <21DAC78125424ED291B5D6477CFF9657@amr.corp.intel.com> <201004140201.o3E21Aqn075978@www262.sakura.ne.jp> <195EB1AD388F455AA386EB214FCD09F4@amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rolandd@cisco.com, amwang@redhat.com
To: sean.hefty@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:49821 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754875Ab0DOFqv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 01:46:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tetsuo Handa wrote:
> Sean Hefty wrote:
> > >+	remaining = (high - low) + 1;
> > >+	rover = net_random() % remaining + low;
> > >+	do {
> > >+		rover++;
> > >+		if ((rover < low) || (rover > high))
> > >+			rover = low;
> > 
> > Assuming that we're likely to pick a valid port on the first try, it would be
> > more efficient to move the above 3 lines to the end of the while loop.
> > 
> Indeed. I moved these lines to "if (--remaining) { ... }" block.

Oh, I made more changes than needed.
Adding "goto start;" and "start:" are sufficient.
Please use whichever you like.
--------------------
[PATCH] Infiniband: Randomize local port allocation.

Randomize local port allocation in a way sctp_get_port_local() does.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 drivers/infiniband/core/cma.c |   71 +++++++++++++++---------------------------
 1 file changed, 26 insertions(+), 45 deletions(-)

--- linux-2.6.34-rc4.orig/drivers/infiniband/core/cma.c
+++ linux-2.6.34-rc4/drivers/infiniband/core/cma.c
@@ -79,7 +79,6 @@ static DEFINE_IDR(sdp_ps);
 static DEFINE_IDR(tcp_ps);
 static DEFINE_IDR(udp_ps);
 static DEFINE_IDR(ipoib_ps);
-static int next_port;
 
 struct cma_device {
 	struct list_head	list;
@@ -1970,47 +1969,34 @@ err1:
 
 static int cma_alloc_any_port(struct idr *ps, struct rdma_id_private *id_priv)
 {
-	struct rdma_bind_list *bind_list;
-	int port, ret, low, high;
-
-	bind_list = kzalloc(sizeof *bind_list, GFP_KERNEL);
-	if (!bind_list)
-		return -ENOMEM;
-
-retry:
-	/* FIXME: add proper port randomization per like inet_csk_get_port */
-	do {
-		ret = idr_get_new_above(ps, bind_list, next_port, &port);
-	} while ((ret == -EAGAIN) && idr_pre_get(ps, GFP_KERNEL));
-
-	if (ret)
-		goto err1;
+	static unsigned int last_used_port;
+	int low, high, remaining;
+	unsigned int rover;
 
 	inet_get_local_port_range(&low, &high);
-	if (port > high) {
-		if (next_port != low) {
-			idr_remove(ps, port);
-			next_port = low;
-			goto retry;
+	remaining = (high - low) + 1;
+	rover = net_random() % remaining + low;
+	goto start;
+	do {
+		rover++;
+		if ((rover < low) || (rover > high))
+			rover = low;
+start:
+		if (last_used_port != rover &&
+		    !idr_find(ps, (unsigned short) rover)) {
+			int ret = cma_alloc_port(ps, id_priv, rover);
+			/*
+			 * Remember previously used port number in order to
+			 * avoid re-using same port immediately after it is
+			 * closed.
+			 */
+			if (!ret)
+				last_used_port = rover;
+			if (ret != -EADDRNOTAVAIL)
+				return ret;
 		}
-		ret = -EADDRNOTAVAIL;
-		goto err2;
-	}
-
-	if (port == high)
-		next_port = low;
-	else
-		next_port = port + 1;
-
-	bind_list->ps = ps;
-	bind_list->port = (unsigned short) port;
-	cma_bind_port(bind_list, id_priv);
-	return 0;
-err2:
-	idr_remove(ps, port);
-err1:
-	kfree(bind_list);
-	return ret;
+	} while (--remaining);
+	return -EADDRNOTAVAIL;
 }
 
 static int cma_use_port(struct idr *ps, struct rdma_id_private *id_priv)
@@ -2995,12 +2981,7 @@ static void cma_remove_one(struct ib_dev
 
 static int __init cma_init(void)
 {
-	int ret, low, high, remaining;
-
-	get_random_bytes(&next_port, sizeof next_port);
-	inet_get_local_port_range(&low, &high);
-	remaining = (high - low) + 1;
-	next_port = ((unsigned int) next_port % remaining) + low;
+	int ret;
 
 	cma_wq = create_singlethread_workqueue("rdma_cm");
 	if (!cma_wq)
