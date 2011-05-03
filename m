From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] pktgen: use %pI6c for printing IPv6 addresses
Date: Wed, 4 May 2011 00:23:40 +0300
Message-ID: <20110503212340.GA25293@p183>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:54193 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754030Ab1ECVXp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2011 17:23:45 -0400
Received: by fxm17 with SMTP id 17so399780fxm.19
        for <netdev@vger.kernel.org>; Tue, 03 May 2011 14:23:44 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I don't know why %pI6 doesn't compress, but the format specifier is
kernel-standard, so use it.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/core/pktgen.c |  109 ++++++------------------------------------------------
 1 file changed, 13 insertions(+), 96 deletions(-)

--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -449,7 +449,6 @@ static void pktgen_stop(struct pktgen_thread *t);
 static void pktgen_clear_counters(struct pktgen_dev *pkt_dev);
 
 static unsigned int scan_ip6(const char *s, char ip[16]);
-static unsigned int fmt_ip6(char *s, const char ip[16]);
 
 /* Module parameters, defaults. */
 static int pg_count_d __read_mostly = 1000;
@@ -556,21 +555,13 @@ static int pktgen_if_show(struct seq_file *seq, void *v)
 			   pkt_dev->skb_priority);
 
 	if (pkt_dev->flags & F_IPV6) {
-		char b1[128], b2[128], b3[128];
-		fmt_ip6(b1, pkt_dev->in6_saddr.s6_addr);
-		fmt_ip6(b2, pkt_dev->min_in6_saddr.s6_addr);
-		fmt_ip6(b3, pkt_dev->max_in6_saddr.s6_addr);
 		seq_printf(seq,
-			   "     saddr: %s  min_saddr: %s  max_saddr: %s\n", b1,
-			   b2, b3);
-
-		fmt_ip6(b1, pkt_dev->in6_daddr.s6_addr);
-		fmt_ip6(b2, pkt_dev->min_in6_daddr.s6_addr);
-		fmt_ip6(b3, pkt_dev->max_in6_daddr.s6_addr);
-		seq_printf(seq,
-			   "     daddr: %s  min_daddr: %s  max_daddr: %s\n", b1,
-			   b2, b3);
-
+			   "     saddr: %pI6c  min_saddr: %pI6c  max_saddr: %pI6c\n"
+			   "     daddr: %pI6c  min_daddr: %pI6c  max_daddr: %pI6c\n",
+			   &pkt_dev->in6_saddr,
+			   &pkt_dev->min_in6_saddr, &pkt_dev->max_in6_saddr,
+			   &pkt_dev->in6_daddr,
+			   &pkt_dev->min_in6_daddr, &pkt_dev->max_in6_daddr);
 	} else {
 		seq_printf(seq,
 			   "     dst_min: %s  dst_max: %s\n",
@@ -706,10 +697,9 @@ static int pktgen_if_show(struct seq_file *seq, void *v)
 		   pkt_dev->cur_src_mac_offset);
 
 	if (pkt_dev->flags & F_IPV6) {
-		char b1[128], b2[128];
-		fmt_ip6(b1, pkt_dev->cur_in6_daddr.s6_addr);
-		fmt_ip6(b2, pkt_dev->cur_in6_saddr.s6_addr);
-		seq_printf(seq, "     cur_saddr: %s  cur_daddr: %s\n", b2, b1);
+		seq_printf(seq, "     cur_saddr: %pI6c  cur_daddr: %pI6c\n",
+				&pkt_dev->cur_in6_saddr,
+				&pkt_dev->cur_in6_daddr);
 	} else
 		seq_printf(seq, "     cur_saddr: 0x%x  cur_daddr: 0x%x\n",
 			   pkt_dev->cur_saddr, pkt_dev->cur_daddr);
@@ -1309,7 +1299,7 @@ static ssize_t pktgen_if_write(struct file *file,
 		buf[len] = 0;
 
 		scan_ip6(buf, pkt_dev->in6_daddr.s6_addr);
-		fmt_ip6(buf, pkt_dev->in6_daddr.s6_addr);
+		snprintf(buf, sizeof(buf), "%pI6c", &pkt_dev->in6_daddr);
 
 		ipv6_addr_copy(&pkt_dev->cur_in6_daddr, &pkt_dev->in6_daddr);
 
@@ -1332,7 +1322,7 @@ static ssize_t pktgen_if_write(struct file *file,
 		buf[len] = 0;
 
 		scan_ip6(buf, pkt_dev->min_in6_daddr.s6_addr);
-		fmt_ip6(buf, pkt_dev->min_in6_daddr.s6_addr);
+		snprintf(buf, sizeof(buf), "%pI6c", &pkt_dev->min_in6_daddr);
 
 		ipv6_addr_copy(&pkt_dev->cur_in6_daddr,
 			       &pkt_dev->min_in6_daddr);
@@ -1355,7 +1345,7 @@ static ssize_t pktgen_if_write(struct file *file,
 		buf[len] = 0;
 
 		scan_ip6(buf, pkt_dev->max_in6_daddr.s6_addr);
-		fmt_ip6(buf, pkt_dev->max_in6_daddr.s6_addr);
+		snprintf(buf, sizeof(buf), "%pI6c", &pkt_dev->max_in6_daddr);
 
 		if (debug)
 			printk(KERN_DEBUG "pktgen: dst6_max set to: %s\n", buf);
@@ -1376,7 +1366,7 @@ static ssize_t pktgen_if_write(struct file *file,
 		buf[len] = 0;
 
 		scan_ip6(buf, pkt_dev->in6_saddr.s6_addr);
-		fmt_ip6(buf, pkt_dev->in6_saddr.s6_addr);
+		snprintf(buf, sizeof(buf), "%pI6c", &pkt_dev->in6_saddr);
 
 		ipv6_addr_copy(&pkt_dev->cur_in6_saddr, &pkt_dev->in6_saddr);
 
@@ -2898,79 +2888,6 @@ static unsigned int scan_ip6(const char *s, char ip[16])
 	return len;
 }
 
-static char tohex(char hexdigit)
-{
-	return hexdigit > 9 ? hexdigit + 'a' - 10 : hexdigit + '0';
-}
-
-static int fmt_xlong(char *s, unsigned int i)
-{
-	char *bak = s;
-	*s = tohex((i >> 12) & 0xf);
-	if (s != bak || *s != '0')
-		++s;
-	*s = tohex((i >> 8) & 0xf);
-	if (s != bak || *s != '0')
-		++s;
-	*s = tohex((i >> 4) & 0xf);
-	if (s != bak || *s != '0')
-		++s;
-	*s = tohex(i & 0xf);
-	return s - bak + 1;
-}
-
-static unsigned int fmt_ip6(char *s, const char ip[16])
-{
-	unsigned int len;
-	unsigned int i;
-	unsigned int temp;
-	unsigned int compressing;
-	int j;
-
-	len = 0;
-	compressing = 0;
-	for (j = 0; j < 16; j += 2) {
-
-#ifdef V4MAPPEDPREFIX
-		if (j == 12 && !memcmp(ip, V4mappedprefix, 12)) {
-			inet_ntoa_r(*(struct in_addr *)(ip + 12), s);
-			temp = strlen(s);
-			return len + temp;
-		}
-#endif
-		temp = ((unsigned long)(unsigned char)ip[j] << 8) +
-		    (unsigned long)(unsigned char)ip[j + 1];
-		if (temp == 0) {
-			if (!compressing) {
-				compressing = 1;
-				if (j == 0) {
-					*s++ = ':';
-					++len;
-				}
-			}
-		} else {
-			if (compressing) {
-				compressing = 0;
-				*s++ = ':';
-				++len;
-			}
-			i = fmt_xlong(s, temp);
-			len += i;
-			s += i;
-			if (j < 14) {
-				*s++ = ':';
-				++len;
-			}
-		}
-	}
-	if (compressing) {
-		*s++ = ':';
-		++len;
-	}
-	*s = 0;
-	return len;
-}
-
 static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
 					struct pktgen_dev *pkt_dev)
 {
