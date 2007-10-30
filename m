From: Alexey Dobriyan <adobriyan@sw.ru>
Subject: [PATCH 1/2] Convert /proc/net/ipv6_route to seq_file interface
Date: Tue, 30 Oct 2007 16:11:47 +0300
Message-ID: <20071030131147.GA6210@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:9948 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754496AbXJ3NL4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Oct 2007 09:11:56 -0400
Received: from sw.ru ([192.168.0.16])
	by relay.sw.ru (8.13.4/8.13.4) with SMTP id l9UDBm6G008226
	for <netdev@vger.kernel.org>; Tue, 30 Oct 2007 16:11:49 +0300 (MSK)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

One proc_net_create() user less.

Signed-off-by: Alexey Dobriyan <adobriyan@sw.ru>
---

 net/ipv6/route.c |   70 +++++++++++++++++++------------------------------------
 1 file changed, 25 insertions(+), 45 deletions(-)

--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2288,71 +2288,49 @@ struct rt6_proc_arg
 
 static int rt6_info_route(struct rt6_info *rt, void *p_arg)
 {
-	struct rt6_proc_arg *arg = (struct rt6_proc_arg *) p_arg;
+	struct seq_file *m = p_arg;
 
-	if (arg->skip < arg->offset / RT6_INFO_LEN) {
-		arg->skip++;
-		return 0;
-	}
-
-	if (arg->len >= arg->length)
-		return 0;
-
-	arg->len += sprintf(arg->buffer + arg->len,
-			    NIP6_SEQFMT " %02x ",
-			    NIP6(rt->rt6i_dst.addr),
+	seq_printf(m, NIP6_SEQFMT " %02x ", NIP6(rt->rt6i_dst.addr),
 			    rt->rt6i_dst.plen);
 
 #ifdef CONFIG_IPV6_SUBTREES
-	arg->len += sprintf(arg->buffer + arg->len,
-			    NIP6_SEQFMT " %02x ",
-			    NIP6(rt->rt6i_src.addr),
+	seq_printf(m, NIP6_SEQFMT " %02x ", NIP6(rt->rt6i_src.addr),
 			    rt->rt6i_src.plen);
 #else
-	arg->len += sprintf(arg->buffer + arg->len,
-			    "00000000000000000000000000000000 00 ");
+	seq_puts(m, "00000000000000000000000000000000 00 ");
 #endif
 
 	if (rt->rt6i_nexthop) {
-		arg->len += sprintf(arg->buffer + arg->len,
-				    NIP6_SEQFMT,
+		seq_printf(m, NIP6_SEQFMT,
 				    NIP6(*((struct in6_addr *)rt->rt6i_nexthop->primary_key)));
 	} else {
-		arg->len += sprintf(arg->buffer + arg->len,
-				    "00000000000000000000000000000000");
+		seq_puts(m, "00000000000000000000000000000000");
 	}
-	arg->len += sprintf(arg->buffer + arg->len,
-			    " %08x %08x %08x %08x %8s\n",
+	seq_printf(m, " %08x %08x %08x %08x %8s\n",
 			    rt->rt6i_metric, atomic_read(&rt->u.dst.__refcnt),
 			    rt->u.dst.__use, rt->rt6i_flags,
 			    rt->rt6i_dev ? rt->rt6i_dev->name : "");
 	return 0;
 }
 
-static int rt6_proc_info(char *buffer, char **start, off_t offset, int length)
+static int ipv6_route_show(struct seq_file *m, void *v)
 {
-	struct rt6_proc_arg arg = {
-		.buffer = buffer,
-		.offset = offset,
-		.length = length,
-	};
-
-	fib6_clean_all(rt6_info_route, 0, &arg);
-
-	*start = buffer;
-	if (offset)
-		*start += offset % RT6_INFO_LEN;
-
-	arg.len -= offset % RT6_INFO_LEN;
-
-	if (arg.len > length)
-		arg.len = length;
-	if (arg.len < 0)
-		arg.len = 0;
+	fib6_clean_all(rt6_info_route, 0, m);
+	return 0;
+}
 
-	return arg.len;
+static int ipv6_route_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, ipv6_route_show, NULL);
 }
 
+static const struct file_operations ipv6_route_proc_fops = {
+	.open		= ipv6_route_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
 static int rt6_stats_seq_show(struct seq_file *seq, void *v)
 {
 	seq_printf(seq, "%04x %04x %04x %04x %04x %04x %04x\n",
@@ -2499,9 +2477,11 @@ void __init ip6_route_init(void)
 
 	fib6_init();
 #ifdef 	CONFIG_PROC_FS
-	p = proc_net_create(&init_net, "ipv6_route", 0, rt6_proc_info);
-	if (p)
+	p = create_proc_entry("ipv6_route", 0, init_net.proc_net);
+	if (p) {
 		p->owner = THIS_MODULE;
+		p->proc_fops = &ipv6_route_proc_fops;
+	}
 
 	proc_net_fops_create(&init_net, "rt6_stats", S_IRUGO, &rt6_stats_seq_fops);
 #endif

