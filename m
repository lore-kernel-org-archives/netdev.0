From: "Sean Hefty" <sean.hefty@intel.com>
Subject: RE: [PATCH] Infiniband: Randomize local port allocation.
Date: Wed, 14 Apr 2010 17:01:04 -0700
Message-ID: <195EB1AD388F455AA386EB214FCD09F4@amr.corp.intel.com>
References: <20100412100744.5302.92442.sendpatchset@localhost.localdomain>	<20100412100816.5302.74919.sendpatchset@localhost.localdomain>	<201004130121.o3D1Lhh7099571@www262.sakura.ne.jp>	<4BC41994.7030707@redhat.com>	<4BC42FE0.4040601@redhat.com> <201004132207.GAJ52684.OJFtMQVFHOSFLO@I-love.SAKURA.ne.jp> <21DAC78125424ED291B5D6477CFF9657@amr.corp.intel.com> <201004140201.o3E21Aqn075978@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <amwang@redhat.com>, <opurdila@ixiacom.com>,
	<eric.dumazet@gmail.com>, <netdev@vger.kernel.org>,
	<nhorman@tuxdriver.com>, <davem@davemloft.net>,
	<ebiederm@xmission.com>, <linux-kernel@vger.kernel.org>
To: <penguin-kernel@i-love.sakura.ne.jp>, <rolandd@cisco.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201004140201.o3E21Aqn075978@www262.sakura.ne.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>[PATCH] Infiniband: Randomize local port allocation.
>
>Randomize local port allocation in a way sctp_get_port_local() does.
>
>Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Thanks for fixing this long outstanding issue.  :)  The latest patch looks
correct and passed some simple tests that I ran against it.  One comment below,
which I didn't catch before:

>---
> drivers/infiniband/core/cma.c |   69 ++++++++++++++---------------------------
>-
> 1 file changed, 24 insertions(+), 45 deletions(-)
>
>--- linux-2.6.34-rc4.orig/drivers/infiniband/core/cma.c
>+++ linux-2.6.34-rc4/drivers/infiniband/core/cma.c
>@@ -79,7 +79,6 @@ static DEFINE_IDR(sdp_ps);
> static DEFINE_IDR(tcp_ps);
> static DEFINE_IDR(udp_ps);
> static DEFINE_IDR(ipoib_ps);
>-static int next_port;
>
> struct cma_device {
> 	struct list_head	list;
>@@ -1970,47 +1969,32 @@ err1:
>
> static int cma_alloc_any_port(struct idr *ps, struct rdma_id_private *id_priv)
> {
>-	struct rdma_bind_list *bind_list;
>-	int port, ret, low, high;
>-
>-	bind_list = kzalloc(sizeof *bind_list, GFP_KERNEL);
>-	if (!bind_list)
>-		return -ENOMEM;
>-
>-retry:
>-	/* FIXME: add proper port randomization per like inet_csk_get_port */
>-	do {
>-		ret = idr_get_new_above(ps, bind_list, next_port, &port);
>-	} while ((ret == -EAGAIN) && idr_pre_get(ps, GFP_KERNEL));
>-
>-	if (ret)
>-		goto err1;
>+	static unsigned int last_used_port;
>+	int low, high, remaining;
>+	unsigned int rover;
>
> 	inet_get_local_port_range(&low, &high);
>-	if (port > high) {
>-		if (next_port != low) {
>-			idr_remove(ps, port);
>-			next_port = low;
>-			goto retry;
>+	remaining = (high - low) + 1;
>+	rover = net_random() % remaining + low;
>+	do {
>+		rover++;
>+		if ((rover < low) || (rover > high))
>+			rover = low;

Assuming that we're likely to pick a valid port on the first try, it would be
more efficient to move the above 3 lines to the end of the while loop.

>+		if (last_used_port != rover &&
>+		    !idr_find(ps, (unsigned short) rover)) {
>+			int ret = cma_alloc_port(ps, id_priv, rover);
>+			/*
>+			 * Remember previously used port number in order to
>+			 * avoid re-using same port immediately after it is
>+			 * closed.
>+			 */
>+			if (!ret)
>+				last_used_port = rover;
>+			if (ret != -EADDRNOTAVAIL)
>+				return ret;
> 		}
>-		ret = -EADDRNOTAVAIL;
>-		goto err2;
>-	}
>-
>-	if (port == high)
>-		next_port = low;
>-	else
>-		next_port = port + 1;
>-
>-	bind_list->ps = ps;
>-	bind_list->port = (unsigned short) port;
>-	cma_bind_port(bind_list, id_priv);
>-	return 0;
>-err2:
>-	idr_remove(ps, port);
>-err1:
>-	kfree(bind_list);
>-	return ret;
>+	} while (--remaining > 0);
>+	return -EADDRNOTAVAIL;
> }
