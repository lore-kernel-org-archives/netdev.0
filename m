From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [RFC][PATCH] neigh: Allow for user space users of the neighbour table
Date: Fri, 20 Feb 2009 12:23:43 -0800
Message-ID: <m11vtshn74.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Gautam Kachroo <gk-BGArkANP9klv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>,
	<linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Currently it is possible to do just about everything with the arp table
from user space except treat an entry like you are using it.  To that end
implement and a flag NTF_USE that when set in a netwlink update request
treats the neighbour table entry like the kernel does on the output path.

This allows user space applications to share the kernel's arp cache.

Signed-off-by: Eric Biederman <ebiederm-BGArkANP9klv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>
---
 include/linux/neighbour.h |    1 +
 net/core/neighbour.c      |    6 +++++-
 2 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/include/linux/neighbour.h b/include/linux/neighbour.h
index 8730d5d..12c9de1 100644
--- a/include/linux/neighbour.h
+++ b/include/linux/neighbour.h
@@ -31,6 +31,7 @@ enum
  *	Neighbor Cache Entry Flags
  */
 
+#define NTF_USE		0x01
 #define NTF_PROXY	0x08	/* == ATF_PUBL */
 #define NTF_ROUTER	0x80
 
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 278a142..0fc92ed 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1656,7 +1656,11 @@ static int neigh_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 				flags &= ~NEIGH_UPDATE_F_OVERRIDE;
 		}
 
-		err = neigh_update(neigh, lladdr, ndm->ndm_state, flags);
+		if (ndm->ndm_flags & NTF_USE) {
+			neigh_event_send(neigh, NULL);
+			err = 0;
+		} else
+			err = neigh_update(neigh, lladdr, ndm->ndm_state, flags);
 		neigh_release(neigh);
 		goto out_dev_put;
 	}
-- 
1.6.1.2.350.g88cc

--
To unsubscribe from this list: send the line "unsubscribe linux-api" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
