From: Kristian Larsson <kristian@spritelink.net>
Subject: pktgen IP address stepping
Date: Thu, 16 Dec 2010 18:28:00 +0100
Message-ID: <20101216172800.GA8404@spritelink.se>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="VbJkn9YxBvnuCH5J"
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Mail2.SpriteLink.NET ([195.182.5.83]:54322 "EHLO
	Mail2.SpriteLink.NET" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756839Ab0LPRij (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 12:38:39 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--VbJkn9YxBvnuCH5J
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hello David (and list)!

First of all, I'm hoping I'm sending this to the right person / list,
I've never submitted nor written a patch for the Linux kernel before,
so please bare with me.


This patch adds the ability to set the step rate at which the source
or destination IP address is increased when src_min / src_max or
dst_min / dst_max is used with pktgen.

Usage is simple, two new parameters:
  src_step X
  dst_step X
where X is a positive integer (or actually an unsigned long long).

This is useful for network testing when you want to send packets to
large parts of the Internet.

In addition to adding stepping support, I've changed the init value of
current source / destination address in the code to the max. The
current kernel sets it to the min value, but before the first packet
is sent out, the value is increased. By setting it to max, and we try
to increase it, it will wrap and thus actually start at the min value.
I find this more intuitive and to follow the principle of least
astonishement - I'd actually go as far as say the old behaviour is a
bug. Anyway, there are also some formatting changes and editorial
nitpicks.  Of course, src / dst step has been added to the output of
the proc interface.


My tests involved performance measurements of routers, specifically in
the area of convergence times. Most larger routers implement their FIB
in a TCAM, SRAM or something similarly fast and deterministic. While
reads, ie lookups are often very fast, updates are often quite slow.
My testing show some platforms rewriting some 2000 prefixes per
seconds. So basically, what I wanted to test was just how routers
rewrite their FIB and so I needed to send a packet to every prefix they
have stored in FIB and receive it on one of two output interfaces - the
first if the reroute has not yet happened and on the second interface
if it has. Since I'm dealing with Internet core routers that means I
have a full BGP table (ie some 330k prefix as of late 2010) and I thus
want to send one packet, or 330k packets per second, to each and every
prefix. In addition, it would require to me to input a list of
prefixes to pktgen somehow as the prefixes certainly aren't evenly
spread out (ie, not evenly sized). Instead of implementing that, I
went for an approximation, sending a packet to every Nth address,
which in my case is 65535, or every /16. This gives a pretty good
approximate of the entire routing table, at least good enough for my
tests.

Tests will be posted on http://labs.spritelink.net for those
interested. It will probably be until the beginning of next year
before anything is posted since most of the testing is performed at my
employer, Tele2, and we need to wrap it all up first.

The changes included in this patch was developed during my own (and
not my employers) time and I give permission to place it under whatever
license needed for inclusion in the Linux kernel. pktgen.c appeared to
include some list of changes at the top so I added myself, if this is
too small a change or whatever, that can of course be removed.

Looking forward to any feedback and / or suggestions.

Kind regards,
   Kristian.

-- 
Kristian Larsson                                        KLL-RIPE
+46 704 264511			              kll@spritelink.net

--VbJkn9YxBvnuCH5J
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="linux-pktgen-step.patch"

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 2953b2a..391cecc 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -114,6 +114,9 @@
  * Fixed src_mac command to set source mac of packet to value specified in
  * command by Adit Ranadive <adit.262@gmail.com>
  *
+ * Added support for increasing src / dst ip by values larger than one (1) when
+ * doing src or dst min/max by Kristian Larsson <kll@spritelink.net>
+ *
  */
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
@@ -288,6 +291,10 @@ struct pktgen_dev {
 	char src_min[IP_NAME_SZ];	/* IP, ie 1.2.3.4 */
 	char src_max[IP_NAME_SZ];	/* IP, ie 1.2.3.4 */
 
+	unsigned long long dst_step;
+	unsigned long long src_step;	/* Step up (ie increase) IP src / dst by this
+					   much. 1 by default. */
+
 	struct in6_addr in6_saddr;
 	struct in6_addr in6_daddr;
 	struct in6_addr cur_in6_daddr;
@@ -572,11 +579,11 @@ static int pktgen_if_show(struct seq_file *seq, void *v)
 
 	} else {
 		seq_printf(seq,
-			   "     dst_min: %s  dst_max: %s\n",
-			   pkt_dev->dst_min, pkt_dev->dst_max);
+			   "     dst_min: %s  dst_max: %s  dst_step: %llu\n",
+			   pkt_dev->dst_min, pkt_dev->dst_max, pkt_dev->dst_step);
 		seq_printf(seq,
-			   "        src_min: %s  src_max: %s\n",
-			   pkt_dev->src_min, pkt_dev->src_max);
+			   "     src_min: %s  src_max: %s  src_step: %llu\n",
+			   pkt_dev->src_min, pkt_dev->src_max, pkt_dev->src_step);
 	}
 
 	seq_puts(seq, "     src_mac: ");
@@ -1359,6 +1366,21 @@ static ssize_t pktgen_if_write(struct file *file,
 		sprintf(pg_result, "OK: dst6_max=%s", buf);
 		return count;
 	}
+	if (!strcmp(name, "dst_step")) {
+		len = num_arg(&user_buffer[i], 10, &value);
+		if (len < 0)
+			return len;
+
+		i += len;
+		if (!value)
+			return len;
+		pkt_dev->dst_step = value;
+		if (debug)
+			pr_info("pktgen: dst_step set to: %llu\n", pkt_dev->dst_step);
+
+		sprintf(pg_result, "OK: dst_step=%llu", pkt_dev->dst_step);
+		return count;
+	}
 	if (!strcmp(name, "src6")) {
 		len = strn_len(&user_buffer[i], sizeof(buf) - 1);
 		if (len < 0)
@@ -1424,6 +1446,21 @@ static ssize_t pktgen_if_write(struct file *file,
 		sprintf(pg_result, "OK: src_max=%s", pkt_dev->src_max);
 		return count;
 	}
+	if (!strcmp(name, "src_step")) {
+		len = num_arg(&user_buffer[i], 10, &value);
+		if (len < 0)
+			return len;
+
+		i += len;
+		if (!value)
+			return len;
+		pkt_dev->src_step = value;
+		if (debug)
+			pr_info("pktgen: src_step set to: %llu\n", pkt_dev->src_step);
+
+		sprintf(pg_result, "OK: src_step=%llu", pkt_dev->src_step);
+		return count;
+	}
 	if (!strcmp(name, "dst_mac")) {
 		char *v = valstr;
 		unsigned char old_dmac[ETH_ALEN];
@@ -2160,8 +2197,17 @@ static void pktgen_setup_inject(struct pktgen_dev *pkt_dev)
 	/* Initialize current values. */
 	pkt_dev->cur_dst_mac_offset = 0;
 	pkt_dev->cur_src_mac_offset = 0;
-	pkt_dev->cur_saddr = pkt_dev->saddr_min;
-	pkt_dev->cur_daddr = pkt_dev->daddr_min;
+
+	/*
+	 * Setting init value of current src / dst addr to max value seems
+	 * backwards, but it's not, it is increased for every run, including
+	 * the first one and so setting it to min value means we never actually
+	 * use the min value as it will be increased before we send the first
+	 * packet. Max on the other hand means we wrap on first run and thus
+	 * send first packet with min value.
+	 */
+	pkt_dev->cur_saddr = pkt_dev->saddr_max;
+	pkt_dev->cur_daddr = pkt_dev->daddr_max;
 	pkt_dev->cur_udp_dst = pkt_dev->udp_dst_min;
 	pkt_dev->cur_udp_src = pkt_dev->udp_src_min;
 	pkt_dev->nflows = 0;
@@ -2414,7 +2460,7 @@ static void mod_cur_headers(struct pktgen_dev *pkt_dev)
 				t = random32() % (imx - imn) + imn;
 			else {
 				t = ntohl(pkt_dev->cur_saddr);
-				t++;
+				t += pkt_dev->src_step;
 				if (t > imx)
 					t = imn;
 
@@ -2446,7 +2492,7 @@ static void mod_cur_headers(struct pktgen_dev *pkt_dev)
 					pkt_dev->cur_daddr = s;
 				} else {
 					t = ntohl(pkt_dev->cur_daddr);
-					t++;
+					t += pkt_dev->dst_step;
 					if (t > imx) {
 						t = imn;
 					}
@@ -3752,6 +3798,8 @@ static int pktgen_add_device(struct pktgen_thread *t, const char *ifname)
 	pkt_dev->udp_src_max = 9;
 	pkt_dev->udp_dst_min = 9;
 	pkt_dev->udp_dst_max = 9;
+	pkt_dev->dst_step = 1;
+	pkt_dev->src_step = 1;
 
 	pkt_dev->vlan_p = 0;
 	pkt_dev->vlan_cfi = 0;

--VbJkn9YxBvnuCH5J--
