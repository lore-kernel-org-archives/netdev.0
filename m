From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/4] Fix acquiring socket lock before reading RTNETLINK
	response
Date: Fri, 23 Apr 2010 07:55:36 -0700
Message-ID: <1272034539-19899-2-git-send-email-danms@us.ibm.com>
References: <1272034539-19899-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1272034539-19899-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 net/checkpoint_dev.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/checkpoint_dev.c b/net/checkpoint_dev.c
index 7ccb899..2787892 100644
--- a/net/checkpoint_dev.c
+++ b/net/checkpoint_dev.c
@@ -136,11 +136,12 @@ static struct nlmsghdr *rtnl_get_response(struct socket *rtnl,
 
 	*skb = NULL;
 
+	lock_sock(rtnl->sk);
 	ret = sk_wait_data(rtnl->sk, &timeo);
-	if (!ret)
-		return ERR_PTR(-EPIPE);
+	if (ret)
+		*skb = skb_dequeue(&rtnl->sk->sk_receive_queue);
+	release_sock(rtnl->sk);
 
-	*skb = skb_dequeue(&rtnl->sk->sk_receive_queue);
 	if (!*skb)
 		return ERR_PTR(-EPIPE);
 
-- 
1.6.2.5
