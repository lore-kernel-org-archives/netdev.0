From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH] aoe: remove private mac address format function
Date: Mon, 24 Nov 2008 11:55:00 -0800
Message-ID: <1227556500.5511.19.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jens Axboe <jens.axboe@oracle.com>,
	linux-netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.174]:46918 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752521AbYKXTzE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 14:55:04 -0500
Received: by wf-out-1314.google.com with SMTP id 26so2283469wfd.26
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2008 11:55:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add %pm to omit the colons when printing a mac address.

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
Jens, sent to netdev/DaveM as the extended printk bits are in
net-next and not mainline and this patch depends on them.

 drivers/block/aoe/aoe.h    |    1 -
 drivers/block/aoe/aoecmd.c |   22 ++++++++++------------
 drivers/block/aoe/aoenet.c |   11 -----------
 lib/vsprintf.c             |    3 +++
 4 files changed, 13 insertions(+), 24 deletions(-)

diff --git a/drivers/block/aoe/aoe.h b/drivers/block/aoe/aoe.h
index 93f3690..c237527 100644
--- a/drivers/block/aoe/aoe.h
+++ b/drivers/block/aoe/aoe.h
@@ -200,4 +200,3 @@ void aoenet_xmit(struct sk_buff_head *);
 int is_aoe_netif(struct net_device *ifp);
 int set_aoe_iflist(const char __user *str, size_t size);
 
-unsigned long long mac_addr(char addr[6]);
diff --git a/drivers/block/aoe/aoecmd.c b/drivers/block/aoe/aoecmd.c
index 71ff78c..45c5a33 100644
--- a/drivers/block/aoe/aoecmd.c
+++ b/drivers/block/aoe/aoecmd.c
@@ -349,11 +349,9 @@ resend(struct aoedev *d, struct aoetgt *t, struct frame *f)
 	ah = (struct aoe_atahdr *) (h+1);
 
 	snprintf(buf, sizeof buf,
-		"%15s e%ld.%d oldtag=%08x@%08lx newtag=%08x "
-		"s=%012llx d=%012llx nout=%d\n",
+		"%15s e%ld.%d oldtag=%08x@%08lx newtag=%08x s=%pm d=%pm nout=%d\n",
 		"retransmit", d->aoemajor, d->aoeminor, f->tag, jiffies, n,
-		mac_addr(h->src),
-		mac_addr(h->dst), t->nout);
+		h->src, h->dst, t->nout);
 	aoechr_error(buf);
 
 	f->tag = n;
@@ -544,10 +542,10 @@ rexmit_timer(ulong vp)
 				printk(KERN_INFO
 					"aoe: e%ld.%d: "
 					"too many lost jumbo on "
-					"%s:%012llx - "
+					"%s:%pm - "
 					"falling back to %d frames.\n",
 					d->aoemajor, d->aoeminor,
-					ifp->nd->name, mac_addr(t->addr),
+					ifp->nd->name, t->addr,
 					DEFAULTBCNT);
 				ifp->maxbcnt = 0;
 			}
@@ -672,8 +670,8 @@ ataid_complete(struct aoedev *d, struct aoetgt *t, unsigned char *id)
 
 	if (d->ssize != ssize)
 		printk(KERN_INFO
-			"aoe: %012llx e%ld.%d v%04x has %llu sectors\n",
-			mac_addr(t->addr),
+			"aoe: %pm e%ld.%d v%04x has %llu sectors\n",
+			t->addr,
 			d->aoemajor, d->aoeminor,
 			d->fw_ver, (long long)ssize);
 	d->ssize = ssize;
@@ -775,8 +773,8 @@ aoecmd_ata_rsp(struct sk_buff *skb)
 	n = get_unaligned_be32(&hin->tag);
 	t = gettgt(d, hin->src);
 	if (t == NULL) {
-		printk(KERN_INFO "aoe: can't find target e%ld.%d:%012llx\n",
-			d->aoemajor, d->aoeminor, mac_addr(hin->src));
+		printk(KERN_INFO "aoe: can't find target e%ld.%d:%pm\n",
+			d->aoemajor, d->aoeminor, hin->src);
 		spin_unlock_irqrestore(&d->lock, flags);
 		return;
 	}
@@ -1036,10 +1034,10 @@ aoecmd_cfg_rsp(struct sk_buff *skb)
 		n = n ? n * 512 : DEFAULTBCNT;
 		if (n != ifp->maxbcnt) {
 			printk(KERN_INFO
-				"aoe: e%ld.%d: setting %d%s%s:%012llx\n",
+				"aoe: e%ld.%d: setting %d%s%s:%pm\n",
 				d->aoemajor, d->aoeminor, n,
 				" byte data frames on ", ifp->nd->name,
-				mac_addr(t->addr));
+				t->addr);
 			ifp->maxbcnt = n;
 		}
 	}
diff --git a/drivers/block/aoe/aoenet.c b/drivers/block/aoe/aoenet.c
index 9157d64..30de5b1 100644
--- a/drivers/block/aoe/aoenet.c
+++ b/drivers/block/aoe/aoenet.c
@@ -83,17 +83,6 @@ set_aoe_iflist(const char __user *user_str, size_t size)
 	return 0;
 }
 
-unsigned long long
-mac_addr(char addr[6])
-{
-	__be64 n = 0;
-	char *p = (char *) &n;
-
-	memcpy(p + 2, addr, 6);	/* (sizeof addr != 6) */
-
-	return (unsigned long long) __be64_to_cpu(n);
-}
-
 void
 aoenet_xmit(struct sk_buff_head *queue)
 {
diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index 6897724..3b77702 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -669,6 +669,9 @@ static char *pointer(const char *fmt, char *buf, char *end, void *ptr, int field
 		return symbol_string(buf, end, ptr, field_width, precision, flags);
 	case 'R':
 		return resource_string(buf, end, ptr, field_width, precision, flags);
+	case 'm':
+		flags |= SPECIAL;
+		/* Fallthrough */
 	case 'M':
 		return mac_address_string(buf, end, ptr, field_width, precision, flags);
 	case 'i':
-- 
1.6.0.4.1013.gc6a01



