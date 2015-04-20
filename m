From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH v2 01/11] RDMA/CMA: Mark IPv4 addresses correctly when
 the listener is IPv6
Date: Mon, 20 Apr 2015 14:01:11 -0600
Message-ID: <20150420200111.GA32449@obsidianresearch.com>
References: <1429520622-10303-1-git-send-email-haggaie@mellanox.com>
 <1429520622-10303-2-git-send-email-haggaie@mellanox.com>
 <20150420164140.GC7676@obsidianresearch.com>
 <CAJ3xEMgKFdr68Qt0vNCaf1p4YjPK2KUSn2FdtQVP0SZQ+Y7atg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Haggai Eran <haggaie@mellanox.com>,
	Doug Ledford <dledford@redhat.com>,
	Roland Dreier <roland@kernel.org>,
	Sean Hefty <sean.hefty@intel.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:53006 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751255AbbDTUBU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Apr 2015 16:01:20 -0400
Content-Disposition: inline
In-Reply-To: <CAJ3xEMgKFdr68Qt0vNCaf1p4YjPK2KUSn2FdtQVP0SZQ+Y7atg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 20, 2015 at 09:38:02PM +0300, Or Gerlitz wrote:
> On Mon, Apr 20, 2015 at 7:41 PM, Jason Gunthorpe
> <jgunthorpe@obsidianresearch.com> wrote:
> > On Mon, Apr 20, 2015 at 12:03:32PM +0300, Haggai Eran wrote:
> >> From: Yotam Kenneth <yotamke@mellanox.com>
> >>
> >> When accepting a new connection with the listener being IPv6, the
> >> family of the new connection is set as IPv6. This causes cma_zero_addr
> >> function to return true on an non-zero address. As a result, the wrong
> >> code path is taken. This causes the connection request to be rejected,
> >> as the RDMA-CM code looks for the wrong type of device.
> >
> > This description doesn't really make sense as to what the problem is.

> Jason, could you take a look @ this thread
> http://marc.info/?t=141589395000004&r=1&w=2 where the authors
> addressed some comments from Sean and he eventually Acked the patch?

Please actually read my comments:

 If listen_id->route.addr.src_addr.ss_family != AF_INET then it is
 invalid to cast to sockaddr_in.

Sean asked basically the same thing, and his question was ignored too.

This should take care of it, testing, and figuring the fixes tag is
left as an exercise to the reader..

>From 24cdf029349c9ffad0b2aab37058048ab422960f Mon Sep 17 00:00:00 2001
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Date: Mon, 20 Apr 2015 13:48:52 -0600
Subject: [PATCH] RDMA/CMA: Canonize IPv4 on IPV6 sockets properly

When accepting a new IPv4 connect to an IPv6 socket, the CMA tries to
canonize the address family to IPv4, but does not properly process
the listening sockaddr to get the listening port, and does not properly
set the address family of the canonized sockaddr.

Cc: <stable@vger.kernel.org>
Reported-By: Yotam Kenneth <yotamke@mellanox.com>
Signed-off-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
---
 drivers/infiniband/core/cma.c | 27 +++++++++++++++++----------
 1 file changed, 17 insertions(+), 10 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index d570030d899c..e8d492eceff3 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -859,19 +859,27 @@ static void cma_save_ib_info(struct rdma_cm_id *id, struct rdma_cm_id *listen_id
 	memcpy(&ib->sib_addr, &path->dgid, 16);
 }
 
+static unsigned int ss_get_port(const struct sockaddr_storage *ss)
+{
+	if (ss->ss_family == AF_INET)
+		return ((struct sockaddr_in *)ss)->sin_port;
+	else if (ss->ss_family == AF_INET6)
+		return ((struct sockaddr_in6 *)ss)->sin6_port;
+	BUG();
+}
+
 static void cma_save_ip4_info(struct rdma_cm_id *id, struct rdma_cm_id *listen_id,
 			      struct cma_hdr *hdr)
 {
-	struct sockaddr_in *listen4, *ip4;
+	struct sockaddr_in *ip4;
 
-	listen4 = (struct sockaddr_in *) &listen_id->route.addr.src_addr;
 	ip4 = (struct sockaddr_in *) &id->route.addr.src_addr;
-	ip4->sin_family = listen4->sin_family;
+	ip4->sin_family = AF_INET;
 	ip4->sin_addr.s_addr = hdr->dst_addr.ip4.addr;
-	ip4->sin_port = listen4->sin_port;
+	ip4->sin_port = ss_get_port(&listen_id->route.addr.src_addr);
 
 	ip4 = (struct sockaddr_in *) &id->route.addr.dst_addr;
-	ip4->sin_family = listen4->sin_family;
+	ip4->sin_family = AF_INET;
 	ip4->sin_addr.s_addr = hdr->src_addr.ip4.addr;
 	ip4->sin_port = hdr->port;
 }
@@ -879,16 +887,15 @@ static void cma_save_ip4_info(struct rdma_cm_id *id, struct rdma_cm_id *listen_i
 static void cma_save_ip6_info(struct rdma_cm_id *id, struct rdma_cm_id *listen_id,
 			      struct cma_hdr *hdr)
 {
-	struct sockaddr_in6 *listen6, *ip6;
+	struct sockaddr_in6 *ip6;
 
-	listen6 = (struct sockaddr_in6 *) &listen_id->route.addr.src_addr;
 	ip6 = (struct sockaddr_in6 *) &id->route.addr.src_addr;
-	ip6->sin6_family = listen6->sin6_family;
+	ip6->sin6_family = AF_INET6;
 	ip6->sin6_addr = hdr->dst_addr.ip6;
-	ip6->sin6_port = listen6->sin6_port;
+	ip6->sin6_port = ss_get_port(&listen_id->route.addr.src_addr);
 
 	ip6 = (struct sockaddr_in6 *) &id->route.addr.dst_addr;
-	ip6->sin6_family = listen6->sin6_family;
+	ip6->sin6_family = AF_INET6;
 	ip6->sin6_addr = hdr->src_addr.ip6;
 	ip6->sin6_port = hdr->port;
 }
-- 
1.9.1
