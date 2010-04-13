From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [Patch 3/3] net: reserve ports for applications using fixed port numbers
Date: Tue, 13 Apr 2010 22:07:19 +0900
Message-ID: <201004132207.GAJ52684.OJFtMQVFHOSFLO@I-love.SAKURA.ne.jp>
References: <20100412100744.5302.92442.sendpatchset@localhost.localdomain>
	<20100412100816.5302.74919.sendpatchset@localhost.localdomain>
	<201004130121.o3D1Lhh7099571@www262.sakura.ne.jp>
	<4BC41994.7030707@redhat.com>
	<4BC42FE0.4040601@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: opurdila@ixiacom.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, nhorman@tuxdriver.com, davem@davemloft.net,
	ebiederm@xmission.com, linux-kernel@vger.kernel.org
To: amwang@redhat.com, sean.hefty@intel.com, rolandd@cisco.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4BC42FE0.4040601@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

Adding Sean Hefty and Roland Dreier as drivers/infiniband/core/cma.c maintainer.

Cong Wang wrote:
> Cong Wang wrote:
> > Tetsuo Handa wrote:
> >> Hello.
> >>
> >>> --- linux-2.6.orig/drivers/infiniband/core/cma.c
> >>> +++ linux-2.6/drivers/infiniband/core/cma.c
> >>> @@ -1980,6 +1980,8 @@ retry:
> >>>  	/* FIXME: add proper port randomization per like inet_csk_get_port */
> >>>  	do {
> >>>  		ret = idr_get_new_above(ps, bind_list, next_port, &port);
> >>> +		if (!ret && inet_is_reserved_local_port(port))
> >>> +			ret = -EAGAIN;
> >>>  	} while ((ret == -EAGAIN) && idr_pre_get(ps, GFP_KERNEL));
> >>>  
> >>>  	if (ret)
> >>>
> >> I think above part is wrong. Below program
> > ...
> >> This result suggests that above loop will continue until idr_pre_get() fails
> >> due to out of memory if all ports were reserved.
> >>
> >> Also, if idr_get_new_above() returned 0, bind_list (which is a kmalloc()ed
> >> pointer) is already installed into a free slot (see comment on
> >> idr_get_new_above_int()). Thus, simply calling idr_get_new_above() again will
> >> install the same pointer into multiple slots. I guess it will malfunction later.
> > 
> > Thanks for testing!
> > 
> > How about:
> > 
> > +		if (!ret && inet_is_reserved_local_port(port))
> > +			ret = -EBUSY;
> > 
> > ? So that it will break the loop and return error.
> > 
> 
> Or use the similar trick:
> 
>  int tries = 10;
> ...
> 
>  if(!ret && inet_is_reserved_local_port(port)) {
>    if (tries--)
>      ret = -EAGAIN;
>    else
>      ret = -EBUSY;
>  }
> 
> Any comments?
> 
I don't like above change. Above change makes local port assignment from
"likely-succeed" (succeeds if one port is available from thousands of ports) to
"unlikely-succeed" (fail if randomly chosen port is already in use).
We should repeat for all ranges specified in /proc/sys/net/ipv4/ip_local_port_range .

cma_alloc_any_port() and cma_alloc_port() are almost identical.
Thus, I think we can call cma_alloc_port() from cma_alloc_any_port().

Sean and Roland, is below patch correct?
inet_is_reserved_local_port() is the new function proposed in this patchset.

---
 drivers/infiniband/core/cma.c |   68 ++++++++++++++----------------------------
 1 file changed, 23 insertions(+), 45 deletions(-)

--- linux-2.6.34-rc4.orig/drivers/infiniband/core/cma.c
+++ linux-2.6.34-rc4/drivers/infiniband/core/cma.c
@@ -79,7 +79,6 @@ static DEFINE_IDR(sdp_ps);
 static DEFINE_IDR(tcp_ps);
 static DEFINE_IDR(udp_ps);
 static DEFINE_IDR(ipoib_ps);
-static int next_port;
 
 struct cma_device {
 	struct list_head	list;
@@ -1970,47 +1969,31 @@ err1:
 
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
+	do {
+		rover++;
+		if ((rover < low) || (rover > high))
+			rover = low;
+		if (last_used_port != rover &&
+		    !inet_is_reserved_local_port(rover) &&
+		    !idr_find(ps, (unsigned short) rover) &&
+		    !cma_alloc_port(ps, id_priv, rover)) {
+			/*
+			 * Remember previously used port number in order to
+			 * avoid re-using same port immediately after it is
+			 * closed.
+			 */
+			last_used_port = rover;
+			return 0;
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
+	} while (--remaining > 0);
+	return -EADDRNOTAVAIL;
 }
 
 static int cma_use_port(struct idr *ps, struct rdma_id_private *id_priv)
@@ -2995,12 +2978,7 @@ static void cma_remove_one(struct ib_dev
 
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
