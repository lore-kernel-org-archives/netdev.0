From: "Sean Hefty" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] rdma/cm: Randomize local port allocation.
Date: Thu, 15 Apr 2010 12:55:29 -0700
Message-ID: <5CE6BC7B954643FAAFFD2AD66F673CBD@amr.corp.intel.com>
References: <20100412100744.5302.92442.sendpatchset@localhost.localdomain>	<20100412100816.5302.74919.sendpatchset@localhost.localdomain>	<201004130121.o3D1Lhh7099571@www262.sakura.ne.jp>	<4BC41994.7030707@redhat.com>	<4BC42FE0.4040601@redhat.com> <201004132207.GAJ52684.OJFtMQVFHOSFLO@I-love.SAKURA.ne.jp> <21DAC78125424ED291B5D6477CFF9657@amr.corp.intel.com> <201004140201.o3E21Aqn075978@www262.sakura.ne.jp> <195EB1AD388F455AA386EB214FCD09F4@amr.corp.intel.com> <201004150229.o3F2T4dZ054768@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <opurdila-+zzKsuq53OdBDgjK7y7TUQ@public.gmane.org>,
	<eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<rolandd-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "'Tetsuo Handa'" <penguin-kernel-JPay3/Yim36HaxMnTkn67Xf5DAMn2ifp@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201004150229.o3F2T4dZ054768-etx+eQDEXHD7nzcFbJAaVXf5DAMn2ifp@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Tetsuo Handa <penguin-kernel-JPay3/Yim36HaxMnTkn67Xf5DAMn2ifp@public.gmane.org>

>Randomize local port allocation in a way sctp_get_port_local() does.
>Update rover at the end of loop since we're likely to pick a valid port
>on the first try.
>
>Signed-off-by: Tetsuo Handa <penguin-kernel-JPay3/Yim36HaxMnTkn67Xf5DAMn2ifp@public.gmane.org>
Reviewed-by: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

>---

I like this version, thanks!  I'm not sure which tree to merge it through.
Are you needing this for 2.6.34, or is 2.6.35 okay?

> drivers/infiniband/core/cma.c |   70 +++++++++++++++--------------------------
>-
> 1 file changed, 25 insertions(+), 45 deletions(-)
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
>@@ -1970,47 +1969,33 @@ err1:
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
>-		}
>-		ret = -EADDRNOTAVAIL;
>-		goto err2;
>+	remaining = (high - low) + 1;
>+	rover = net_random() % remaining + low;
>+retry:
>+	if (last_used_port != rover &&
>+	    !idr_find(ps, (unsigned short) rover)) {
>+		int ret = cma_alloc_port(ps, id_priv, rover);
>+		/*
>+		 * Remember previously used port number in order to avoid
>+		 * re-using same port immediately after it is closed.
>+		 */
>+		if (!ret)
>+			last_used_port = rover;
>+		if (ret != -EADDRNOTAVAIL)
>+			return ret;
> 	}
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
>+	if (--remaining) {
>+		rover++;
>+		if ((rover < low) || (rover > high))
>+			rover = low;
>+		goto retry;
>+	}
>+	return -EADDRNOTAVAIL;
> }
>
> static int cma_use_port(struct idr *ps, struct rdma_id_private *id_priv)
>@@ -2995,12 +2980,7 @@ static void cma_remove_one(struct ib_dev
>
> static int __init cma_init(void)
> {
>-	int ret, low, high, remaining;
>-
>-	get_random_bytes(&next_port, sizeof next_port);
>-	inet_get_local_port_range(&low, &high);
>-	remaining = (high - low) + 1;
>-	next_port = ((unsigned int) next_port % remaining) + low;
>+	int ret;
>
> 	cma_wq = create_singlethread_workqueue("rdma_cm");
> 	if (!cma_wq)

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
