From: Cong Wang <amwang@redhat.com>
Subject: [Patch v2 5/5] pktgen: replace scan_ip6() with in6_pton()
Date: Wed, 10 Oct 2012 11:48:20 +0800
Message-ID: <1349840900-24138-5-git-send-email-amwang@redhat.com>
References: <1349840900-24138-1-git-send-email-amwang@redhat.com>
Cc: Cong Wang <amwang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21301 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932358Ab2JJDsh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2012 23:48:37 -0400
In-Reply-To: <1349840900-24138-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/core/pktgen.c |  101 ++--------------------------------------------------
 1 files changed, 4 insertions(+), 97 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 47fe18e..d1dc14c 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -449,8 +449,6 @@ static void pktgen_stop_all_threads_ifs(void);
 static void pktgen_stop(struct pktgen_thread *t);
 static void pktgen_clear_counters(struct pktgen_dev *pkt_dev);
 
-static unsigned int scan_ip6(const char *s, char ip[16]);
-
 /* Module parameters, defaults. */
 static int pg_count_d __read_mostly = 1000;
 static int pg_delay_d __read_mostly;
@@ -1299,7 +1297,7 @@ static ssize_t pktgen_if_write(struct file *file,
 			return -EFAULT;
 		buf[len] = 0;
 
-		scan_ip6(buf, pkt_dev->in6_daddr.s6_addr);
+		in6_pton(buf, -1, pkt_dev->in6_daddr.s6_addr, -1, NULL);
 		snprintf(buf, sizeof(buf), "%pI6c", &pkt_dev->in6_daddr);
 
 		pkt_dev->cur_in6_daddr = pkt_dev->in6_daddr;
@@ -1322,7 +1320,7 @@ static ssize_t pktgen_if_write(struct file *file,
 			return -EFAULT;
 		buf[len] = 0;
 
-		scan_ip6(buf, pkt_dev->min_in6_daddr.s6_addr);
+		in6_pton(buf, -1, pkt_dev->min_in6_daddr.s6_addr, -1, NULL);
 		snprintf(buf, sizeof(buf), "%pI6c", &pkt_dev->min_in6_daddr);
 
 		pkt_dev->cur_in6_daddr = pkt_dev->min_in6_daddr;
@@ -1344,7 +1342,7 @@ static ssize_t pktgen_if_write(struct file *file,
 			return -EFAULT;
 		buf[len] = 0;
 
-		scan_ip6(buf, pkt_dev->max_in6_daddr.s6_addr);
+		in6_pton(buf, -1, pkt_dev->max_in6_daddr.s6_addr, -1, NULL);
 		snprintf(buf, sizeof(buf), "%pI6c", &pkt_dev->max_in6_daddr);
 
 		if (debug)
@@ -1365,7 +1363,7 @@ static ssize_t pktgen_if_write(struct file *file,
 			return -EFAULT;
 		buf[len] = 0;
 
-		scan_ip6(buf, pkt_dev->in6_saddr.s6_addr);
+		in6_pton(buf, -1, pkt_dev->in6_saddr.s6_addr, -1, NULL);
 		snprintf(buf, sizeof(buf), "%pI6c", &pkt_dev->in6_saddr);
 
 		pkt_dev->cur_in6_saddr = pkt_dev->in6_saddr;
@@ -2765,97 +2763,6 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 	return skb;
 }
 
-/*
- * scan_ip6, fmt_ip taken from dietlibc-0.21
- * Author Felix von Leitner <felix-dietlibc@fefe.de>
- *
- * Slightly modified for kernel.
- * Should be candidate for net/ipv4/utils.c
- * --ro
- */
-
-static unsigned int scan_ip6(const char *s, char ip[16])
-{
-	unsigned int i;
-	unsigned int len = 0;
-	unsigned long u;
-	char suffix[16];
-	unsigned int prefixlen = 0;
-	unsigned int suffixlen = 0;
-	__be32 tmp;
-	char *pos;
-
-	for (i = 0; i < 16; i++)
-		ip[i] = 0;
-
-	for (;;) {
-		if (*s == ':') {
-			len++;
-			if (s[1] == ':') {	/* Found "::", skip to part 2 */
-				s += 2;
-				len++;
-				break;
-			}
-			s++;
-		}
-
-		u = simple_strtoul(s, &pos, 16);
-		i = pos - s;
-		if (!i)
-			return 0;
-		if (prefixlen == 12 && s[i] == '.') {
-
-			/* the last 4 bytes may be written as IPv4 address */
-
-			tmp = in_aton(s);
-			memcpy((struct in_addr *)(ip + 12), &tmp, sizeof(tmp));
-			return i + len;
-		}
-		ip[prefixlen++] = (u >> 8);
-		ip[prefixlen++] = (u & 255);
-		s += i;
-		len += i;
-		if (prefixlen == 16)
-			return len;
-	}
-
-/* part 2, after "::" */
-	for (;;) {
-		if (*s == ':') {
-			if (suffixlen == 0)
-				break;
-			s++;
-			len++;
-		} else if (suffixlen != 0)
-			break;
-
-		u = simple_strtol(s, &pos, 16);
-		i = pos - s;
-		if (!i) {
-			if (*s)
-				len--;
-			break;
-		}
-		if (suffixlen + prefixlen <= 12 && s[i] == '.') {
-			tmp = in_aton(s);
-			memcpy((struct in_addr *)(suffix + suffixlen), &tmp,
-			       sizeof(tmp));
-			suffixlen += 4;
-			len += strlen(s);
-			break;
-		}
-		suffix[suffixlen++] = (u >> 8);
-		suffix[suffixlen++] = (u & 255);
-		s += i;
-		len += i;
-		if (prefixlen + suffixlen == 16)
-			break;
-	}
-	for (i = 0; i < suffixlen; i++)
-		ip[16 - suffixlen + i] = suffix[i];
-	return len;
-}
-
 static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
 					struct pktgen_dev *pkt_dev)
 {
-- 
1.7.7.6
