From: Thomas Graf <tgraf@suug.ch>
Subject: [RFC] dynamic hash table size & xor hash function for cls_fw
Date: Thu, 7 Apr 2005 02:55:19 +0200
Message-ID: <20050407005519.GS26731@postel.suug.ch>
References: <20050405213023.0256.LARK@linux.net.cn> <1112717495.1076.22.camel@jzny.localdomain> <20050406143842.026B.LARK@linux.net.cn> <20050406123036.GO26731@postel.suug.ch> <1112794459.1096.61.camel@jzny.localdomain> <20050406134502.GP26731@postel.suug.ch> <20050406141020.GQ26731@postel.suug.ch> <20050406111509.0462abcf.davem@davemloft.net> <20050406183134.GR26731@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, lark@linux.net.cn, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050406183134.GR26731@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Thomas Graf <20050406183134.GR26731@postel.suug.ch> 2005-04-06 20:31
> Yes, it sounds pretty good. I can't find any scenario where it
> would perform unacceptable, it's not perfect but fair enough
> for everyone I guess.

Changes the hashtable size to PAGE_SIZE/sizeof(unsigned long) and
adapts the hashing algorithm to xor various buckets in order to
maintain collision free hashing for the most common use case
while providing some kind of distribution for more rare cases.

The hashing function looks really ugly, it is, but gcc will optimize
away all the uneeded branches which will make it short again. The hash
case for 10bits hash table ignores the most significant 2 bits, I
don't think this has any impact but would rather be wasted cycles.
It looks inefficient but the manual shifting & xoring only takes one
instruction more than the HTSIZE == 256 case on my x86 box so the
increased hashing area should be worth it.

Thoughts?


===== net/sched/cls_fw.c 1.21 vs edited =====
--- 1.21/net/sched/cls_fw.c	2005-03-29 02:45:46 +02:00
+++ edited/net/sched/cls_fw.c	2005-04-07 02:41:46 +02:00
@@ -46,9 +46,11 @@
 #include <net/act_api.h>
 #include <net/pkt_cls.h>
 
+#define HTSIZE (PAGE_SIZE/sizeof(struct fw_filter *))
+
 struct fw_head
 {
-	struct fw_filter *ht[256];
+	struct fw_filter *ht[HTSIZE];
 };
 
 struct fw_filter
@@ -69,7 +71,28 @@
 
 static __inline__ int fw_hash(u32 handle)
 {
-	return handle&0xFF;
+	if (HTSIZE == 4096)
+		return ((handle >> 24) & 0xFFF) ^
+		       ((handle >> 12) & 0xFFF) ^
+		       (handle & 0xFFF);
+	else if (HTSIZE == 2048)
+		return ((handle >> 22) & 0x7FF) ^
+		       ((handle >> 11) & 0x7FF) ^
+		       (handle & 0x7FF);
+	else if (HTSIZE == 1024)
+		return ((handle >> 20) & 0x3FF) ^
+		       ((handle >> 10) & 0x3FF) ^
+		       (handle & 0x3FF);
+	else if (HTSIZE == 512)
+		return (handle >> 27) ^
+		       ((handle >> 18) & 0x1FF) ^
+		       ((handle >> 9) & 0x1FF) ^
+		       (handle & 0x1FF);
+	else if (HTSIZE == 256) {
+		u8 *t = (u8 *) &handle;
+		return t[0] ^ t[1] ^ t[2] ^ t[3];
+	} else 
+		return handle & (HTSIZE - 1);
 }
 
 static int fw_classify(struct sk_buff *skb, struct tcf_proto *tp,
@@ -152,7 +175,7 @@
 	if (head == NULL)
 		return;
 
-	for (h=0; h<256; h++) {
+	for (h=0; h<HTSIZE; h++) {
 		while ((f=head->ht[h]) != NULL) {
 			head->ht[h] = f->next;
 			fw_delete_filter(tp, f);
@@ -291,7 +314,7 @@
 	if (arg->stop)
 		return;
 
-	for (h = 0; h < 256; h++) {
+	for (h = 0; h < HTSIZE; h++) {
 		struct fw_filter *f;
 
 		for (f = head->ht[h]; f; f = f->next) {
