From: Denis Cheng <crquan@gmail.com>
Subject: [PATCH] [net/ipv4]: fib_seq_show function adjustment to get a more sensable output of /proc/net/route
Date: Tue, 23 Oct 2007 02:26:22 +0800
Message-ID: <1193077582-4790-1-git-send-email-crquan@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Denis Cheng <crquan@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.225]:18916 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755184AbXJVS1F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2007 14:27:05 -0400
Received: by nz-out-0506.google.com with SMTP id s18so508947nze
        for <netdev@vger.kernel.org>; Mon, 22 Oct 2007 11:27:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

the temporary bf[127] char array is redundant, and the specified width 127 make the output of /proc/net/route include many trailing spaces;
since most terminal's cols are less than 127, this made every fib entry occupy two lines,

after applied this patch, the output of /proc/net/route is more sensable like this:

Iface	Destination	Gateway 	Flags	RefCnt	Use	Metric	Mask		MTU	Window	IRTT
eth0	0001A8C0	00000000	0001	0	0	0	00FFFFFF	0	0	0
lo	0000007F	00000000	0001	0	0	0	000000FF	0	0	0
eth0	00000000	0101A8C0	0003	0	0	0	00000000	0	0	0

Signed-off-by: Denis Cheng <crquan@gmail.com>
---
 net/ipv4/fib_hash.c |   15 +++++++--------
 1 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/fib_hash.c b/net/ipv4/fib_hash.c
index 527a6e0..2a4033e 100644
--- a/net/ipv4/fib_hash.c
+++ b/net/ipv4/fib_hash.c
@@ -992,7 +992,6 @@ static unsigned fib_flag_trans(int type, __be32 mask, struct fib_info *fi)
 static int fib_seq_show(struct seq_file *seq, void *v)
 {
 	struct fib_iter_state *iter;
-	char bf[128];
 	__be32 prefix, mask;
 	unsigned flags;
 	struct fib_node *f;
@@ -1000,9 +999,9 @@ static int fib_seq_show(struct seq_file *seq, void *v)
 	struct fib_info *fi;
 
 	if (v == SEQ_START_TOKEN) {
-		seq_printf(seq, "%-127s\n", "Iface\tDestination\tGateway "
+		seq_printf(seq, "Iface\tDestination\tGateway "
 			   "\tFlags\tRefCnt\tUse\tMetric\tMask\t\tMTU"
-			   "\tWindow\tIRTT");
+			   "\tWindow\tIRTT\n");
 		goto out;
 	}
 
@@ -1014,18 +1013,18 @@ static int fib_seq_show(struct seq_file *seq, void *v)
 	mask	= FZ_MASK(iter->zone);
 	flags	= fib_flag_trans(fa->fa_type, mask, fi);
 	if (fi)
-		snprintf(bf, sizeof(bf),
-			 "%s\t%08X\t%08X\t%04X\t%d\t%u\t%d\t%08X\t%d\t%u\t%u",
+		seq_printf(seq,
+			 "%s\t%08X\t%08X\t%04X\t%d\t%u\t%d\t%08X\t%d\t%u\t%u\n",
 			 fi->fib_dev ? fi->fib_dev->name : "*", prefix,
 			 fi->fib_nh->nh_gw, flags, 0, 0, fi->fib_priority,
 			 mask, (fi->fib_advmss ? fi->fib_advmss + 40 : 0),
 			 fi->fib_window,
 			 fi->fib_rtt >> 3);
 	else
-		snprintf(bf, sizeof(bf),
-			 "*\t%08X\t%08X\t%04X\t%d\t%u\t%d\t%08X\t%d\t%u\t%u",
+		seq_printf(seq,
+			 "*\t%08X\t%08X\t%04X\t%d\t%u\t%d\t%08X\t%d\t%u\t%u\n",
 			 prefix, 0, flags, 0, 0, 0, mask, 0, 0, 0);
-	seq_printf(seq, "%-127s\n", bf);
+
 out:
 	return 0;
 }
-- 
1.5.3.4

