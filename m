From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [pull 2.6.30 1/2] wimax: fix oops if netlink fails to add attribute
Date: Wed,  6 May 2009 14:47:22 -0700
Message-ID: <d1a2627a29667fe7c4a9d06e1579a2d65bd39bba.1241646234.git.inaky@linux.intel.com>
References: <cover.1241646234.git.inaky@linux.intel.com>
Cc: netdev@vger.kernel.org
To: wimax@linuxwimax.org
Return-path: <wimax-bounces@linuxwimax.org>
In-Reply-To: <cover.1241646234.git.inaky@linux.intel.com>
In-Reply-To: <cover.1241646234.git.inaky@linux.intel.com>
References: <cover.1241646234.git.inaky@linux.intel.com>
List-Unsubscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.moblin.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org

When sending a message to user space using wimax_msg(), if nla_put()
fails, correctly interpret the return code from wimax_msg_alloc() as
an err ptr and return the error code instead of crashing (as it is
assuming than non-NULL means the pointer is ok).

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 net/wimax/op-msg.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/wimax/op-msg.c b/net/wimax/op-msg.c
index 5d149c1..9ad4d89 100644
--- a/net/wimax/op-msg.c
+++ b/net/wimax/op-msg.c
@@ -149,7 +149,8 @@ struct sk_buff *wimax_msg_alloc(struct wimax_dev *wimax_dev,
 	}
 	result = nla_put(skb, WIMAX_GNL_MSG_DATA, size, msg);
 	if (result < 0) {
-		dev_err(dev, "no memory to add payload in attribute\n");
+		dev_err(dev, "no memory to add payload (msg %p size %zu) in "
+			"attribute: %d\n", msg, size, result);
 		goto error_nla_put;
 	}
 	genlmsg_end(skb, genl_msg);
@@ -299,10 +300,10 @@ int wimax_msg(struct wimax_dev *wimax_dev, const char *pipe_name,
 	struct sk_buff *skb;
 
 	skb = wimax_msg_alloc(wimax_dev, pipe_name, buf, size, gfp_flags);
-	if (skb == NULL)
-		goto error_msg_new;
-	result = wimax_msg_send(wimax_dev, skb);
-error_msg_new:
+	if (IS_ERR(skb))
+		result = PTR_ERR(skb);
+	else
+		result = wimax_msg_send(wimax_dev, skb);
 	return result;
 }
 EXPORT_SYMBOL_GPL(wimax_msg);
-- 
1.6.2.3
