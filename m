From: Meng Xu <mengxu.gatech@gmail.com>
Subject: [PATCH] isdn/i4l: check the message proto does not change across fetches
Date: Tue, 19 Sep 2017 14:52:58 -0400
Message-ID: <1505847178-3179-1-git-send-email-mengxu.gatech@gmail.com>
Cc: meng.xu@gatech.edu, sanidhya@gatech.edu, taesoo@gatech.edu,
        Meng Xu <mengxu.gatech@gmail.com>
To: isdn@linux-pingi.de, davem@davemloft.net, johannes.berg@intel.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In isdn_ppp_write(), the header (i.e., protobuf) of the buffer is fetched
twice from userspace. The first fetch is used to peek at the protocol
of the message and reset the huptimer if necessary; while the second
fetch copies in the whole buffer. However, given that buf resides in
userspace memory, a user process can race to change its memory content
across fetches. By doing so, we can either avoid resetting the huptimer
for any type of packets (by first setting proto to PPP_LCP and later
change to the actual type) or force resetting the huptimer for LCP packets.

This patch does a memcmp between the two fetches and abort if changes to
the protobuf is detected across fetches.

Signed-off-by: Meng Xu <mengxu.gatech@gmail.com>
---
 drivers/isdn/i4l/isdn_ppp.c | 13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/drivers/isdn/i4l/isdn_ppp.c b/drivers/isdn/i4l/isdn_ppp.c
index 6c44609..21a9ae8 100644
--- a/drivers/isdn/i4l/isdn_ppp.c
+++ b/drivers/isdn/i4l/isdn_ppp.c
@@ -857,6 +857,7 @@ isdn_ppp_write(int min, struct file *file, const char __user *buf, int count)
 		    (lp->flags & ISDN_NET_CONNECTED)) {
 			unsigned short hl;
 			struct sk_buff *skb;
+			void *skb_tail;
 			/*
 			 * we need to reserve enough space in front of
 			 * sk_buff. old call to dev_alloc_skb only reserved
@@ -869,11 +870,21 @@ isdn_ppp_write(int min, struct file *file, const char __user *buf, int count)
 				return count;
 			}
 			skb_reserve(skb, hl);
-			if (copy_from_user(skb_put(skb, count), buf, count))
+			skb_tail = skb_put(skb, count);
+			if (copy_from_user(skb_tail, buf, count))
 			{
 				kfree_skb(skb);
 				return -EFAULT;
 			}
+
+			/*
+			 * abort if the message proto is changed between the fetches
+			 */
+			if (memcmp(skb_tail, protobuf, 4)) {
+				kfree_skb(skb);
+				return -EFAULT;
+			}
+
 			if (is->debug & 0x40) {
 				printk(KERN_DEBUG "ppp xmit: len %d\n", (int) skb->len);
 				isdn_ppp_frame_log("xmit", skb->data, skb->len, 32, is->unit, lp->ppp_slot);
-- 
2.7.4
