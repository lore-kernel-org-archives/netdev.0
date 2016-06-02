From: Vishwanath Pai <vpai@akamai.com>
Subject: [PATCH iptables 3/3] libxt_hashlimit: iptables-restore does not work
 as expected with xt_hashlimit
Date: Wed, 1 Jun 2016 20:17:59 -0400
Message-ID: <20160602001759.GF1644@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: coreteam@netfilter.org, johunt@akamai.com, netdev@vger.kernel.org,
	pai.vishwain@gmail.com
To: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay07.akamai.com ([23.79.238.175]:25554 "EHLO
	prod-mail-xrelay07.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751935AbcFBASB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 20:18:01 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

libxt_hashlimit: iptables-restore does not work as expected with xt_hashlimit

Add the following iptables rule.

$ iptables -A INPUT -m hashlimit --hashlimit-above 200/sec \
  --hashlimit-burst 5 --hashlimit-mode srcip --hashlimit-name hashlimit1 \
  --hashlimit-htable-expire 30000 -j DROP

$ iptables-save > save.txt

Edit save.txt and change the value of --hashlimit-above to 300:

-A INPUT -m hashlimit --hashlimit-above 300/sec --hashlimit-burst 5 \
--hashlimit-mode srcip --hashlimit-name hashlimit2 \
--hashlimit-htable-expire 30000 -j DROP

Now restore save.txt

$ iptables-restore < save.txt

Now userspace thinks that the value of --hashlimit-above is 300 but it is
actually 200 in the kernel. This happens because when we add multiple
hash-limit rules with the same name they will share the same hashtable
internally. The kernel module tries to re-use the old hashtable without
updating the values.

There are multiple problems here:
1) We can add two iptables rules with the same name, but kernel does not
   handle this well, one procfs file cannot work with two rules
2) If the second rule has no effect because the hashtable has values from
   rule 1
3) hashtable-restore does not work (as described above)

To fix this I have made the following design change:
1) If a second rule is added with the same name as an existing rule,
   append a number when we create the procfs, for example hashlimit_1,
   hashlimit_2 etc
2) Two rules will not share the same hashtable unless they are similar in
   every possible way
3) This behavior has to be forced with a new userspace flag:
   --hashlimit-ehanced-procfs, if this flag is not passed we default to
   the old behavior. This is to make sure we do not break existing scripts
   that rely on the existing behavior.

Signed-off-by: Vishwanath Pai <vpai@akamai.com>

diff --git a/extensions/libxt_hashlimit.c b/extensions/libxt_hashlimit.c
index 4193464..ac67875 100644
--- a/extensions/libxt_hashlimit.c
+++ b/extensions/libxt_hashlimit.c
@@ -67,6 +67,7 @@ enum {
 	O_HTABLE_MAX,
 	O_HTABLE_GCINT,
 	O_HTABLE_EXPIRE,
+	O_PROCFS,
 	F_BURST         = 1 << O_BURST,
 	F_UPTO          = 1 << O_UPTO,
 	F_ABOVE         = 1 << O_ABOVE,
@@ -177,6 +178,7 @@ static const struct xt_option_entry hashlimit_mt_opts[] = {
 	{.name = "hashlimit-mode", .id = O_MODE, .type = XTTYPE_STRING},
 	{.name = "hashlimit-name", .id = O_NAME, .type = XTTYPE_STRING,
 	 .flags = XTOPT_MAND | XTOPT_PUT, XTOPT_POINTER(s, name), .min = 1},
+	{.name = "hashlimit-enhanced-procfs", .id = O_PROCFS, .type = XTTYPE_NONE},
 	XTOPT_TABLEEND,
 };
 #undef s
@@ -521,6 +523,9 @@ static void hashlimit_mt_parse(struct xt_option_call *cb)
 	case O_DSTMASK:
 		info->cfg.dstmask = cb->val.hlen;
 		break;
+	case O_PROCFS:
+		info->cfg.flags |= XT_HASHLIMIT_FLAG_PROCFS;
+		break;
 	}
 }
 
@@ -856,6 +861,9 @@ hashlimit_mt_save(const struct hashlimit_cfg2 *cfg, const char* name, unsigned i
 		printf(" --hashlimit-srcmask %u", cfg->srcmask);
 	if (cfg->dstmask != dmask)
 		printf(" --hashlimit-dstmask %u", cfg->dstmask);
+
+	if ((revision == 2) && (cfg->flags & XT_HASHLIMIT_FLAG_PROCFS) )
+                printf(" --hashlimit-enhanced-procfs");
 }
 
 static void
diff --git a/extensions/libxt_hashlimit.man b/extensions/libxt_hashlimit.man
index 6aac3f2..0434f03 100644
--- a/extensions/libxt_hashlimit.man
+++ b/extensions/libxt_hashlimit.man
@@ -40,6 +40,9 @@ Like \-\-hashlimit\-srcmask, but for destination addresses.
 \fB\-\-hashlimit\-name\fP \fIfoo\fP
 The name for the /proc/net/ipt_hashlimit/foo entry.
 .TP
+\fB\-\-hashlimit\-enhanced\-procfs\fP
+Append _number to the procfs file when multiple rules with the same name exist
+.TP
 \fB\-\-hashlimit\-htable\-size\fP \fIbuckets\fP
 The number of buckets of the hash table
 .TP
diff --git a/include/linux/netfilter/xt_hashlimit.h b/include/linux/netfilter/xt_hashlimit.h
index e493fc1..2954381 100644
--- a/include/linux/netfilter/xt_hashlimit.h
+++ b/include/linux/netfilter/xt_hashlimit.h
@@ -16,6 +16,10 @@
 struct xt_hashlimit_htable;
 
 enum {
+	XT_HASHLIMIT_FLAG_PROCFS = 1
+};
+
+enum {
 	XT_HASHLIMIT_HASH_DIP = 1 << 0,
 	XT_HASHLIMIT_HASH_DPT = 1 << 1,
 	XT_HASHLIMIT_HASH_SIP = 1 << 2,
@@ -74,6 +78,9 @@ struct hashlimit_cfg2 {
 	__u32 expire;	/* when do entries expire? */
 
 	__u8 srcmask, dstmask;
+
+	__u8 procfs_suffix;
+	__u32 flags;
 };
 
 struct xt_hashlimit_mtinfo1 {
