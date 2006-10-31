From: James Morris <jmorris@namei.org>
Subject: [PATCH] ipv6: fix flowlabel seqfile handling
Date: Tue, 31 Oct 2006 01:20:21 -0500 (EST)
Message-ID: <Pine.LNX.4.64.0610310034500.14627@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail8.sea5.speakeasy.net ([69.17.117.10]:21400 "EHLO
	mail8.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1422644AbWJaGUY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Oct 2006 01:20:24 -0500
To: =?iso-2022-jp?Q?YOSHIFUJI_Hideaki_=2F_=B5=C8=C6=A3=B1=D1=CC=C0?=
	<yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There's a bug in the seqfile show operation for flowlabel objects, where 
each hash chain is traversed cumulatively for each element.  The following 
function is called for each element of each chain:

static void ip6fl_fl_seq_show(struct seq_file *seq, struct ip6_flowlabel *fl)
{
        while(fl) {
                seq_printf...
		
		fl = fl->next;
	}
}

Thus, objects can appear mutliple times when reading 
/proc/net/ip6_flowlabel, as the above is called for each element in the 
chain.

The solution is to remove the while() loop from the above, and traverse 
each chain exactly once, per the patch below.  This also removes the 
ip6fl_fl_seq_show() function, which does nothing else.

Please apply.

Signed-off-by: James Morris <jmorris@namei.org>

---

 net/ipv6/ip6_flowlabel.c |   18 ++++++------------
 1 file changed, 6 insertions(+), 12 deletions(-)


diff -purN --minimal -X dontdiff linux-2.6.p/net/ipv6/ip6_flowlabel.c linux-2.6.w/net/ipv6/ip6_flowlabel.c
--- linux-2.6.p/net/ipv6/ip6_flowlabel.c	2006-10-30 23:11:02.000000000 -0500
+++ linux-2.6.w/net/ipv6/ip6_flowlabel.c	2006-10-31 00:18:11.000000000 -0500
@@ -627,9 +627,13 @@ static void ip6fl_seq_stop(struct seq_fi
 	read_unlock_bh(&ip6_fl_lock);
 }
 
-static void ip6fl_fl_seq_show(struct seq_file *seq, struct ip6_flowlabel *fl)
+static int ip6fl_seq_show(struct seq_file *seq, void *v)
 {
-	while(fl) {
+	if (v == SEQ_START_TOKEN)
+		seq_printf(seq, "%-5s %-1s %-6s %-6s %-6s %-8s %-32s %s\n",
+			   "Label", "S", "Owner", "Users", "Linger", "Expires", "Dst", "Opt");
+	else {
+		struct ip6_flowlabel *fl = v;
 		seq_printf(seq,
 			   "%05X %-1d %-6d %-6d %-6ld %-8ld " NIP6_SEQFMT " %-4d\n",
 			   (unsigned)ntohl(fl->label),
@@ -640,17 +644,7 @@ static void ip6fl_fl_seq_show(struct seq
 			   (long)(fl->expires - jiffies)/HZ,
 			   NIP6(fl->dst),
 			   fl->opt ? fl->opt->opt_nflen : 0);
-		fl = fl->next;
 	}
-}
-
-static int ip6fl_seq_show(struct seq_file *seq, void *v)
-{
-	if (v == SEQ_START_TOKEN)
-		seq_printf(seq, "%-5s %-1s %-6s %-6s %-6s %-8s %-32s %s\n",
-			   "Label", "S", "Owner", "Users", "Linger", "Expires", "Dst", "Opt");
-	else
-		ip6fl_fl_seq_show(seq, v);
 	return 0;
 }
 

