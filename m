From: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH v2 01/11] RDMA/CMA: Mark IPv4 addresses correctly when the listener is IPv6
Date: Mon, 20 Apr 2015 12:03:32 +0300
Message-ID: <1429520622-10303-2-git-send-email-haggaie@mellanox.com>
References: <1429520622-10303-1-git-send-email-haggaie@mellanox.com>
Cc: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1429520622-10303-1-git-send-email-haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

When accepting a new connection with the listener being IPv6, the
family of the new connection is set as IPv6. This causes cma_zero_addr
function to return true on an non-zero address. As a result, the wrong
code path is taken. This causes the connection request to be rejected,
as the RDMA-CM code looks for the wrong type of device.

Since copying the ip address is done in different function depending
on the family (cma_save_ip4_info/cma_save_ip6_info) this is fixed by
hard coding the family of the IP address according to the function.

Signed-off-by: Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/infiniband/core/cma.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index d570030d899c..6e5e11ca7702 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -866,12 +866,12 @@ static void cma_save_ip4_info(struct rdma_cm_id *id, struct rdma_cm_id *listen_i
 
 	listen4 = (struct sockaddr_in *) &listen_id->route.addr.src_addr;
 	ip4 = (struct sockaddr_in *) &id->route.addr.src_addr;
-	ip4->sin_family = listen4->sin_family;
+	ip4->sin_family = AF_INET;
 	ip4->sin_addr.s_addr = hdr->dst_addr.ip4.addr;
 	ip4->sin_port = listen4->sin_port;
 
 	ip4 = (struct sockaddr_in *) &id->route.addr.dst_addr;
-	ip4->sin_family = listen4->sin_family;
+	ip4->sin_family = AF_INET;
 	ip4->sin_addr.s_addr = hdr->src_addr.ip4.addr;
 	ip4->sin_port = hdr->port;
 }
@@ -883,12 +883,12 @@ static void cma_save_ip6_info(struct rdma_cm_id *id, struct rdma_cm_id *listen_i
 
 	listen6 = (struct sockaddr_in6 *) &listen_id->route.addr.src_addr;
 	ip6 = (struct sockaddr_in6 *) &id->route.addr.src_addr;
-	ip6->sin6_family = listen6->sin6_family;
+	ip6->sin6_family = AF_INET6;
 	ip6->sin6_addr = hdr->dst_addr.ip6;
 	ip6->sin6_port = listen6->sin6_port;
 
 	ip6 = (struct sockaddr_in6 *) &id->route.addr.dst_addr;
-	ip6->sin6_family = listen6->sin6_family;
+	ip6->sin6_family = AF_INET6;
 	ip6->sin6_addr = hdr->src_addr.ip6;
 	ip6->sin6_port = hdr->port;
 }
-- 
1.7.11.2

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
