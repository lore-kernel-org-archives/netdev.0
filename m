From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: [PATCH 1/3] infiniband: rxe: avoid 64-bit division
Date: Mon, 13 Jun 2016 14:54:53 +0200
Message-ID: <1465822509-4167617-1-git-send-email-arnd@arndb.de>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Moni Shoua <monis-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Amir Vadai <amirv-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Kamal Heib <kamalh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The rxe driver fails to build on 32-bit because of a 64-bit division:

In function `rxe_qp_from_attr':
:(.text+0x53158): undefined reference to `__aeabi_uldivmod'

We can easily avoid this division by converting the nanosecond value
into jiffies directly rather than converting to microseconds first.

Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
---
 drivers/infiniband/hw/rxe/rxe_qp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/infiniband/hw/rxe/rxe_qp.c b/drivers/infiniband/hw/rxe/rxe_qp.c
index aa11ac3032b2..4e7b0985aab8 100644
--- a/drivers/infiniband/hw/rxe/rxe_qp.c
+++ b/drivers/infiniband/hw/rxe/rxe_qp.c
@@ -664,7 +664,7 @@ int rxe_qp_from_attr(struct rxe_qp *qp, struct ib_qp_attr *attr, int mask,
 			qp->qp_timeout_jiffies = 0;
 		} else {
 			/* According to the spec, timeout = 4.096 * 2 ^ attr->timeout [us] */
-			int j = usecs_to_jiffies((4096ULL << attr->timeout) / 1000);
+			int j = nsecs_to_jiffies(4096ULL << attr->timeout);
 
 			qp->qp_timeout_jiffies = j ? j : 1;
 		}
-- 
2.7.0

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
