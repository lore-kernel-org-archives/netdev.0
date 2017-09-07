From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [V2 PATCH net-next 2/2] xdp: catch invalid XDP_REDIRECT API usage
Date: Thu, 07 Sep 2017 14:33:18 +0200
Message-ID: <150478759820.28665.14031878598812204399.stgit@firesoul>
References: <150478756604.28665.6915020425359475729.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <borkmann@iogearbox.net>,
        John Fastabend <john.fastabend@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55862 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932105AbdIGMdV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 7 Sep 2017 08:33:21 -0400
In-Reply-To: <150478756604.28665.6915020425359475729.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Catch different invalid XDP_REDIRECT and bpf_redirect_map API usage.

It is fairly easy to create a dangling redirect_info->map pointer,
which (until John or Daniel fix this) can crash the kernel.

The intended usage of the BPF helper bpf_redirect_map(), is to return
XDP_REDIRECT action after invoking it, but there is nothing stopping
the bpf_prog to return anything else.  When XDP_REDIRECT isn't
returned, then a dangling ->map pointer is left behind, as
xdp_do_redirect() isn't called.

This also happens for drivers not implementing XDP_REDIRECT, as they
are not aware of this new XDP_REDIRECT return code, they leave the map
pointer dangling.

The simply solution to check for a dangling ->map pointer after each
driver napi->poll() invocation, see xdp_do_map_check().

This patch also add a check for a dangling ->map_to_flush pointer.
This should be considered a driver bug, as the driver contract is that
a pair of xdp_do_redirect and xdp_do_flush_map MUST be called in the
same cpu context.

Note, we need to check after each drivers napi->poll call, as:
 1. DevA poll call bpf_redirect_map() but not xdp_do_redirect()
 2. DevB bpf_prog uses bpf_redirect() and call xdp_do_redirect()
    which now use map from DevA

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 include/linux/filter.h |    1 +
 net/core/dev.c         |    3 +++
 net/core/filter.c      |   25 +++++++++++++++++++++++++
 3 files changed, 29 insertions(+)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index d29e58fde364..0c48941e0022 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -724,6 +724,7 @@ int xdp_do_redirect(struct net_device *dev,
 		    struct xdp_buff *xdp,
 		    struct bpf_prog *prog);
 void xdp_do_flush_map(void);
+void xdp_do_map_check(struct napi_struct *napi);
 
 void bpf_warn_invalid_xdp_action(u32 act);
 void bpf_warn_invalid_xdp_redirect(u32 ifindex);
diff --git a/net/core/dev.c b/net/core/dev.c
index 6f845e4fec17..7eac642b469f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5320,6 +5320,7 @@ static void busy_poll_stop(struct napi_struct *napi, void *have_poll_lock)
 	 */
 	rc = napi->poll(napi, BUSY_POLL_BUDGET);
 	trace_napi_poll(napi, rc, BUSY_POLL_BUDGET);
+	xdp_do_map_check(napi);
 	netpoll_poll_unlock(have_poll_lock);
 	if (rc == BUSY_POLL_BUDGET)
 		__napi_schedule(napi);
@@ -5367,6 +5368,7 @@ void napi_busy_loop(unsigned int napi_id,
 		}
 		work = napi_poll(napi, BUSY_POLL_BUDGET);
 		trace_napi_poll(napi, work, BUSY_POLL_BUDGET);
+		xdp_do_map_check(napi);
 count:
 		if (work > 0)
 			__NET_ADD_STATS(dev_net(napi->dev),
@@ -5529,6 +5531,7 @@ static int napi_poll(struct napi_struct *n, struct list_head *repoll)
 	if (test_bit(NAPI_STATE_SCHED, &n->state)) {
 		work = n->poll(n, weight);
 		trace_napi_poll(n, work, weight);
+		xdp_do_map_check(n);
 	}
 
 	WARN_ON_ONCE(work > weight);
diff --git a/net/core/filter.c b/net/core/filter.c
index 3767470cab6c..f0e1135eeb9d 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2500,6 +2500,31 @@ void xdp_do_flush_map(void)
 }
 EXPORT_SYMBOL_GPL(xdp_do_flush_map);
 
+void xdp_do_map_check(struct napi_struct *napi)
+{
+	struct redirect_info *ri = this_cpu_ptr(&redirect_info);
+
+	/* XDP drivers (and XDP-generic) must invoke xdp_do_redirect()
+	 * when bpf_prog use helper bpf_redirect_map(), else the map
+	 * pointer can be left dangling.  Catch this invalid API
+	 * usage, instead of potentially crashing.
+	 */
+	if (ri->map) {
+		ri->map = NULL;
+		net_err_ratelimited("%s: caught invalid XDP bpf_redirect_map\n",
+				    napi->dev->name);
+		trace_xdp_exception(napi->dev, NULL, XDP_REDIRECT);
+	}
+	if (ri->map_to_flush) { /* Driver bug */
+		net_err_ratelimited("%s: XDP driver miss xdp_do_flush_map\n",
+				    napi->dev->name);
+		trace_xdp_exception(napi->dev, NULL, XDP_REDIRECT);
+		/* Flush map, else pkts can be stuck on XDP TXq */
+		xdp_do_flush_map();
+	}
+}
+EXPORT_SYMBOL_GPL(xdp_do_map_check);
+
 static int xdp_do_redirect_map(struct net_device *dev, struct xdp_buff *xdp,
 			       struct bpf_prog *xdp_prog)
 {
