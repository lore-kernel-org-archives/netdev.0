From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] pktgen: reduce stack usage
Date: Fri, 18 Feb 2005 13:42:19 -0800
Message-ID: <20050218134219.3f079110.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>
To: robert.olsson@its.uu.se
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

(resend)
Any comments this time?



pktgen: proc_if_write: reduce stack usage (on i386)
from 776 to 296 bytes by combining/reusing locals.

Signed-off-by: Randy Dunlap <rddunlap@osdl.org>

diffstat:=
 net/core/pktgen.c |   94 ++++++++++++++++++++++++------------------------------
 1 files changed, 42 insertions(+), 52 deletions(-)

diff -Naurp ./net/core/pktgen.c~pktgen_stack ./net/core/pktgen.c
--- ./net/core/pktgen.c~pktgen_stack	2005-01-27 16:31:49.000000000 -0800
+++ ./net/core/pktgen.c	2005-01-30 19:07:55.252712936 -0800
@@ -811,6 +811,8 @@ static int proc_if_write(struct file *fi
         struct pktgen_dev *pkt_dev = (struct pktgen_dev*)(data);
         char* pg_result = NULL;
         int tmp = 0;
+	char buf4[IP_NAME_SZ];
+	char buf6[128];
         
         pg_result = &(pkt_dev->result[0]);
         
@@ -1071,16 +1073,15 @@ static int proc_if_write(struct file *fi
 		return count;
 	}
 	if (!strcmp(name, "dst_min") || !strcmp(name, "dst")) {
-                char buf[IP_NAME_SZ];
 		len = strn_len(&user_buffer[i], sizeof(pkt_dev->dst_min) - 1);
                 if (len < 0) { return len; }
 
-                if (copy_from_user(buf, &user_buffer[i], len))
+                if (copy_from_user(buf4, &user_buffer[i], len))
 			return -EFAULT;
-                buf[len] = 0;
-                if (strcmp(buf, pkt_dev->dst_min) != 0) {
+                buf4[len] = 0;
+                if (strcmp(buf4, pkt_dev->dst_min) != 0) {
                         memset(pkt_dev->dst_min, 0, sizeof(pkt_dev->dst_min));
-                        strncpy(pkt_dev->dst_min, buf, len);
+                        strncpy(pkt_dev->dst_min, buf4, len);
                         pkt_dev->daddr_min = in_aton(pkt_dev->dst_min);
                         pkt_dev->cur_daddr = pkt_dev->daddr_min;
                 }
@@ -1091,17 +1092,16 @@ static int proc_if_write(struct file *fi
 		return count;
 	}
 	if (!strcmp(name, "dst_max")) {
-                char buf[IP_NAME_SZ];
 		len = strn_len(&user_buffer[i], sizeof(pkt_dev->dst_max) - 1);
                 if (len < 0) { return len; }
 
-                if (copy_from_user(buf, &user_buffer[i], len))
+                if (copy_from_user(buf4, &user_buffer[i], len))
 			return -EFAULT;
 
-                buf[len] = 0;
-                if (strcmp(buf, pkt_dev->dst_max) != 0) {
+                buf4[len] = 0;
+                if (strcmp(buf4, pkt_dev->dst_max) != 0) {
                         memset(pkt_dev->dst_max, 0, sizeof(pkt_dev->dst_max));
-                        strncpy(pkt_dev->dst_max, buf, len);
+                        strncpy(pkt_dev->dst_max, buf4, len);
                         pkt_dev->daddr_max = in_aton(pkt_dev->dst_max);
                         pkt_dev->cur_daddr = pkt_dev->daddr_max;
                 }
@@ -1112,108 +1112,99 @@ static int proc_if_write(struct file *fi
 		return count;
 	}
 	if (!strcmp(name, "dst6")) {
-                char buf[128];
-
 		len = strn_len(&user_buffer[i], 128 - 1);
                 if (len < 0) return len; 
 
 		pkt_dev->flags |= F_IPV6;
 
-                if (copy_from_user(buf, &user_buffer[i], len))
+                if (copy_from_user(buf6, &user_buffer[i], len))
 			return -EFAULT;
-                buf[len] = 0;
+                buf6[len] = 0;
 
-		scan_ip6(buf, pkt_dev->in6_daddr.s6_addr);
-		fmt_ip6(buf,  pkt_dev->in6_daddr.s6_addr);
+		scan_ip6(buf6, pkt_dev->in6_daddr.s6_addr);
+		fmt_ip6(buf6,  pkt_dev->in6_daddr.s6_addr);
 
 		ipv6_addr_copy(&pkt_dev->cur_in6_daddr, &pkt_dev->in6_daddr);
 
                 if(debug) 
-			printk("pktgen: dst6 set to: %s\n", buf);
+			printk("pktgen: dst6 set to: %s\n", buf6);
 
                 i += len;
-		sprintf(pg_result, "OK: dst6=%s", buf);
+		sprintf(pg_result, "OK: dst6=%s", buf6);
 		return count;
 	}
 	if (!strcmp(name, "dst6_min")) {
-                char buf[128];
-
 		len = strn_len(&user_buffer[i], 128 - 1);
                 if (len < 0) return len; 
 
 		pkt_dev->flags |= F_IPV6;
 
-                if (copy_from_user(buf, &user_buffer[i], len))
+                if (copy_from_user(buf6, &user_buffer[i], len))
 			return -EFAULT;
-                buf[len] = 0;
+                buf6[len] = 0;
 
-		scan_ip6(buf, pkt_dev->min_in6_daddr.s6_addr);
-		fmt_ip6(buf,  pkt_dev->min_in6_daddr.s6_addr);
+		scan_ip6(buf6, pkt_dev->min_in6_daddr.s6_addr);
+		fmt_ip6(buf6,  pkt_dev->min_in6_daddr.s6_addr);
 
 		ipv6_addr_copy(&pkt_dev->cur_in6_daddr, &pkt_dev->min_in6_daddr);
                 if(debug) 
-			printk("pktgen: dst6_min set to: %s\n", buf);
+			printk("pktgen: dst6_min set to: %s\n", buf6);
 
                 i += len;
-		sprintf(pg_result, "OK: dst6_min=%s", buf);
+		sprintf(pg_result, "OK: dst6_min=%s", buf6);
 		return count;
 	}
 	if (!strcmp(name, "dst6_max")) {
-                char buf[128];
-
 		len = strn_len(&user_buffer[i], 128 - 1);
                 if (len < 0) return len; 
 
 		pkt_dev->flags |= F_IPV6;
 
-                if (copy_from_user(buf, &user_buffer[i], len))
+                if (copy_from_user(buf6, &user_buffer[i], len))
 			return -EFAULT;
-                buf[len] = 0;
+                buf6[len] = 0;
 
-		scan_ip6(buf, pkt_dev->max_in6_daddr.s6_addr);
-		fmt_ip6(buf,  pkt_dev->max_in6_daddr.s6_addr);
+		scan_ip6(buf6, pkt_dev->max_in6_daddr.s6_addr);
+		fmt_ip6(buf6,  pkt_dev->max_in6_daddr.s6_addr);
 
                 if(debug) 
-			printk("pktgen: dst6_max set to: %s\n", buf);
+			printk("pktgen: dst6_max set to: %s\n", buf6);
 
                 i += len;
-		sprintf(pg_result, "OK: dst6_max=%s", buf);
+		sprintf(pg_result, "OK: dst6_max=%s", buf6);
 		return count;
 	}
 	if (!strcmp(name, "src6")) {
-                char buf[128];
-
 		len = strn_len(&user_buffer[i], 128 - 1);
                 if (len < 0) return len; 
 
 		pkt_dev->flags |= F_IPV6;
 
-                if (copy_from_user(buf, &user_buffer[i], len))
+                if (copy_from_user(buf6, &user_buffer[i], len))
 			return -EFAULT;
-                buf[len] = 0;
+                buf6[len] = 0;
 
-		scan_ip6(buf, pkt_dev->in6_saddr.s6_addr);
-		fmt_ip6(buf,  pkt_dev->in6_saddr.s6_addr);
+		scan_ip6(buf6, pkt_dev->in6_saddr.s6_addr);
+		fmt_ip6(buf6,  pkt_dev->in6_saddr.s6_addr);
 
 		ipv6_addr_copy(&pkt_dev->cur_in6_saddr, &pkt_dev->in6_saddr);
 
                 if(debug) 
-			printk("pktgen: src6 set to: %s\n", buf);
+			printk("pktgen: src6 set to: %s\n", buf6);
 		
                 i += len;
-		sprintf(pg_result, "OK: src6=%s", buf);
+		sprintf(pg_result, "OK: src6=%s", buf6);
 		return count;
 	}
 	if (!strcmp(name, "src_min")) {
-                char buf[IP_NAME_SZ];
 		len = strn_len(&user_buffer[i], sizeof(pkt_dev->src_min) - 1);
                 if (len < 0) { return len; }
-                if (copy_from_user(buf, &user_buffer[i], len))
+                if (copy_from_user(buf4, &user_buffer[i], len))
 			return -EFAULT;
-                buf[len] = 0;
-                if (strcmp(buf, pkt_dev->src_min) != 0) {
+                buf4[len] = 0;
+                if (strcmp(buf4, pkt_dev->src_min) != 0) {
                         memset(pkt_dev->src_min, 0, sizeof(pkt_dev->src_min));
-                        strncpy(pkt_dev->src_min, buf, len);
+                        strncpy(pkt_dev->src_min, buf4, len);
                         pkt_dev->saddr_min = in_aton(pkt_dev->src_min);
                         pkt_dev->cur_saddr = pkt_dev->saddr_min;
                 }
@@ -1224,15 +1215,14 @@ static int proc_if_write(struct file *fi
 		return count;
 	}
 	if (!strcmp(name, "src_max")) {
-                char buf[IP_NAME_SZ];
 		len = strn_len(&user_buffer[i], sizeof(pkt_dev->src_max) - 1);
                 if (len < 0) { return len; }
-                if (copy_from_user(buf, &user_buffer[i], len))
+                if (copy_from_user(buf4, &user_buffer[i], len))
 			return -EFAULT;
-                buf[len] = 0;
-                if (strcmp(buf, pkt_dev->src_max) != 0) {
+                buf4[len] = 0;
+                if (strcmp(buf4, pkt_dev->src_max) != 0) {
                         memset(pkt_dev->src_max, 0, sizeof(pkt_dev->src_max));
-                        strncpy(pkt_dev->src_max, buf, len);
+                        strncpy(pkt_dev->src_max, buf4, len);
                         pkt_dev->saddr_max = in_aton(pkt_dev->src_max);
                         pkt_dev->cur_saddr = pkt_dev->saddr_max;
                 }


---
