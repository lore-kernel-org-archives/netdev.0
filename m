From: Michal Ludvig <mludvig@suse.cz>
Subject: [PATCH] XFRM policy expire
Date: Tue, 24 Feb 2004 10:09:46 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <403B14DA.3000700@suse.cz>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020103020704050801010406"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020103020704050801010406
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

the attached patch fixes a bug in xfrm_send_policy_notify(). The space 
allocated in skb must include 'sizeof(struct xfrm_user_polexpire)', not 
'sizeof(struct xfrm_userpolicy_info)' which is shorter. On ia32 it 
worked, probably because of some space gained from aligning. 
Unfortunately on amd64 it didn't and finally led to BUG() & kernel hangup.

Please apply.

BTW The second patch attached does some obvious cleanup: replaces 
RTA_ALIGN(RTA_LENGTH(x)) with RTA_SPACE(x) and ditto for NLMSG_*() 
macros. Apply on top of the first one or drop it. It's up to you.

Michal Ludvig
-- 
SUSE Labs                    mludvig@suse.cz | Cray is the only computer
(+420) 296.545.373        http://www.suse.cz | that runs an endless loop
Personal homepage http://www.logix.cz/michal | in just four hours.

--------------020103020704050801010406
Content-Type: text/plain;
 name="kernel-xfrm-polexpire.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="kernel-xfrm-polexpire.diff"

diff -rup linux-2.6.2.vanilla/net/xfrm/xfrm_user.c linux-2.6.2/net/xfrm/xfrm_user.c
--- linux-2.6.2.vanilla/net/xfrm/xfrm_user.c	2004-02-04 04:43:56.000000000 +0100
+++ linux-2.6.2/net/xfrm/xfrm_user.c	2004-02-24 09:47:42.325888560 +0100
@@ -1153,7 +1153,7 @@ static int xfrm_send_policy_notify(struc
 
 	len = sizeof(struct xfrm_user_tmpl) * xp->xfrm_nr;
 	len = RTA_ALIGN(RTA_LENGTH(len));
-	len += NLMSG_ALIGN(NLMSG_LENGTH(sizeof(struct xfrm_userpolicy_info)));
+	len += NLMSG_ALIGN(NLMSG_LENGTH(sizeof(struct xfrm_user_polexpire)));
 	skb = alloc_skb(len, GFP_ATOMIC);
 	if (skb == NULL)
 		return -ENOMEM;

--------------020103020704050801010406
Content-Type: text/plain;
 name="kernel-xfrm-cleanup.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="kernel-xfrm-cleanup.diff"

diff -rup linux-2.6.2.vanilla/net/xfrm/xfrm_user.c linux-2.6.2/net/xfrm/xfrm_user.c
--- linux-2.6.2.vanilla/net/xfrm/xfrm_user.c	2004-02-04 04:43:56.000000000 +0100
+++ linux-2.6.2/net/xfrm/xfrm_user.c	2004-02-24 10:09:37.839560352 +0100
@@ -1052,9 +1052,8 @@ static int xfrm_send_acquire(struct xfrm
 	struct sk_buff *skb;
 	size_t len;
 
-	len = RTA_LENGTH(sizeof(struct xfrm_user_tmpl) * xp->xfrm_nr);
-	len = RTA_ALIGN(len);
-	len += NLMSG_ALIGN(NLMSG_LENGTH(sizeof(struct xfrm_user_acquire)));
+	len = RTA_SPACE(sizeof(struct xfrm_user_tmpl) * xp->xfrm_nr);
+	len += NLMSG_SPACE(sizeof(struct xfrm_user_acquire));
 	skb = alloc_skb(len, GFP_ATOMIC);
 	if (skb == NULL)
 		return -ENOMEM;
@@ -1151,9 +1150,8 @@ static int xfrm_send_policy_notify(struc
 	struct sk_buff *skb;
 	size_t len;
 
-	len = sizeof(struct xfrm_user_tmpl) * xp->xfrm_nr;
-	len = RTA_ALIGN(RTA_LENGTH(len));
-	len += NLMSG_ALIGN(NLMSG_LENGTH(sizeof(struct xfrm_user_polexpire)));
+	len = RTA_SPACE(sizeof(struct xfrm_user_tmpl) * xp->xfrm_nr);
+	len += NLMSG_SPACE(sizeof(struct xfrm_user_polexpire));
 	skb = alloc_skb(len, GFP_ATOMIC);
 	if (skb == NULL)
 		return -ENOMEM;

--------------020103020704050801010406--
