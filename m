From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [PATCH] pktgen: reduce stack usage
Date: Fri, 18 Feb 2005 14:37:51 -0800
Message-ID: <42166E3F.2050304@osdl.org>
References: <20050218134219.3f079110.rddunlap@osdl.org> <20050218221121.GA22845@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060305080105070604010102"
Cc: robert.olsson@its.uu.se, netdev <netdev@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20050218221121.GA22845@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060305080105070604010102
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Francois Romieu wrote:
> Randy.Dunlap <rddunlap@osdl.org> :
> 
>>(resend)
>>Any comments this time?
> 
> 
> Did I miss a simultaneous use of both buffers or could it be possible to
> save an extra IP_NAME_SZ bytes of data with an evil ugly union ?

I don't see any simultaneous uses of the 2 buffers, so here's the
union version of the patch (attached this time), although it only
saves 4 bytes... so maybe the compiler had already realized that
usage.  Either one accomplishes a large stack reduction, but the
first one is slightly more readable & maintainable (to me),
and less error-prone (or more future-proof) (again, to me).

Thanks,
-- 
~Randy

--------------060305080105070604010102
Content-Type: text/x-patch;
 name="pktgen_stack_v2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="pktgen_stack_v2.patch"


pktgen: proc_if_write: reduce stack usage (on i386)
from 776 to 292 bytes by combining/reusing locals.

Signed-off-by: Randy Dunlap <rddunlap@osdl.org>

diffstat:=
 net/core/pktgen.c |   96 ++++++++++++++++++++++++------------------------------
 1 files changed, 44 insertions(+), 52 deletions(-)

diff -Naurp ./net/core/pktgen.c~pktgen_stack ./net/core/pktgen.c
--- ./net/core/pktgen.c~pktgen_stack	2005-02-18 13:39:12.309983016 -0800
+++ ./net/core/pktgen.c	2005-02-18 14:28:54.007696064 -0800
@@ -811,6 +811,10 @@ static int proc_if_write(struct file *fi
         struct pktgen_dev *pkt_dev = (struct pktgen_dev*)(data);
         char* pg_result = NULL;
         int tmp = 0;
+	union bufs {
+		char buf4[IP_NAME_SZ];
+		char buf6[128];
+	} bu;
         
         pg_result = &(pkt_dev->result[0]);
         
@@ -1071,16 +1075,15 @@ static int proc_if_write(struct file *fi
 		return count;
 	}
 	if (!strcmp(name, "dst_min") || !strcmp(name, "dst")) {
-                char buf[IP_NAME_SZ];
 		len = strn_len(&user_buffer[i], sizeof(pkt_dev->dst_min) - 1);
                 if (len < 0) { return len; }
 
-                if (copy_from_user(buf, &user_buffer[i], len))
+                if (copy_from_user(bu.buf4, &user_buffer[i], len))
 			return -EFAULT;
-                buf[len] = 0;
-                if (strcmp(buf, pkt_dev->dst_min) != 0) {
+                bu.buf4[len] = 0;
+                if (strcmp(bu.buf4, pkt_dev->dst_min) != 0) {
                         memset(pkt_dev->dst_min, 0, sizeof(pkt_dev->dst_min));
-                        strncpy(pkt_dev->dst_min, buf, len);
+                        strncpy(pkt_dev->dst_min, bu.buf4, len);
                         pkt_dev->daddr_min = in_aton(pkt_dev->dst_min);
                         pkt_dev->cur_daddr = pkt_dev->daddr_min;
                 }
@@ -1091,17 +1094,16 @@ static int proc_if_write(struct file *fi
 		return count;
 	}
 	if (!strcmp(name, "dst_max")) {
-                char buf[IP_NAME_SZ];
 		len = strn_len(&user_buffer[i], sizeof(pkt_dev->dst_max) - 1);
                 if (len < 0) { return len; }
 
-                if (copy_from_user(buf, &user_buffer[i], len))
+                if (copy_from_user(bu.buf4, &user_buffer[i], len))
 			return -EFAULT;
 
-                buf[len] = 0;
-                if (strcmp(buf, pkt_dev->dst_max) != 0) {
+                bu.buf4[len] = 0;
+                if (strcmp(bu.buf4, pkt_dev->dst_max) != 0) {
                         memset(pkt_dev->dst_max, 0, sizeof(pkt_dev->dst_max));
-                        strncpy(pkt_dev->dst_max, buf, len);
+                        strncpy(pkt_dev->dst_max, bu.buf4, len);
                         pkt_dev->daddr_max = in_aton(pkt_dev->dst_max);
                         pkt_dev->cur_daddr = pkt_dev->daddr_max;
                 }
@@ -1112,108 +1114,99 @@ static int proc_if_write(struct file *fi
 		return count;
 	}
 	if (!strcmp(name, "dst6")) {
-                char buf[128];
-
 		len = strn_len(&user_buffer[i], 128 - 1);
                 if (len < 0) return len; 
 
 		pkt_dev->flags |= F_IPV6;
 
-                if (copy_from_user(buf, &user_buffer[i], len))
+                if (copy_from_user(bu.buf6, &user_buffer[i], len))
 			return -EFAULT;
-                buf[len] = 0;
+                bu.buf6[len] = 0;
 
-		scan_ip6(buf, pkt_dev->in6_daddr.s6_addr);
-		fmt_ip6(buf,  pkt_dev->in6_daddr.s6_addr);
+		scan_ip6(bu.buf6, pkt_dev->in6_daddr.s6_addr);
+		fmt_ip6(bu.buf6,  pkt_dev->in6_daddr.s6_addr);
 
 		ipv6_addr_copy(&pkt_dev->cur_in6_daddr, &pkt_dev->in6_daddr);
 
                 if(debug) 
-			printk("pktgen: dst6 set to: %s\n", buf);
+			printk("pktgen: dst6 set to: %s\n", bu.buf6);
 
                 i += len;
-		sprintf(pg_result, "OK: dst6=%s", buf);
+		sprintf(pg_result, "OK: dst6=%s", bu.buf6);
 		return count;
 	}
 	if (!strcmp(name, "dst6_min")) {
-                char buf[128];
-
 		len = strn_len(&user_buffer[i], 128 - 1);
                 if (len < 0) return len; 
 
 		pkt_dev->flags |= F_IPV6;
 
-                if (copy_from_user(buf, &user_buffer[i], len))
+                if (copy_from_user(bu.buf6, &user_buffer[i], len))
 			return -EFAULT;
-                buf[len] = 0;
+                bu.buf6[len] = 0;
 
-		scan_ip6(buf, pkt_dev->min_in6_daddr.s6_addr);
-		fmt_ip6(buf,  pkt_dev->min_in6_daddr.s6_addr);
+		scan_ip6(bu.buf6, pkt_dev->min_in6_daddr.s6_addr);
+		fmt_ip6(bu.buf6,  pkt_dev->min_in6_daddr.s6_addr);
 
 		ipv6_addr_copy(&pkt_dev->cur_in6_daddr, &pkt_dev->min_in6_daddr);
                 if(debug) 
-			printk("pktgen: dst6_min set to: %s\n", buf);
+			printk("pktgen: dst6_min set to: %s\n", bu.buf6);
 
                 i += len;
-		sprintf(pg_result, "OK: dst6_min=%s", buf);
+		sprintf(pg_result, "OK: dst6_min=%s", bu.buf6);
 		return count;
 	}
 	if (!strcmp(name, "dst6_max")) {
-                char buf[128];
-
 		len = strn_len(&user_buffer[i], 128 - 1);
                 if (len < 0) return len; 
 
 		pkt_dev->flags |= F_IPV6;
 
-                if (copy_from_user(buf, &user_buffer[i], len))
+                if (copy_from_user(bu.buf6, &user_buffer[i], len))
 			return -EFAULT;
-                buf[len] = 0;
+                bu.buf6[len] = 0;
 
-		scan_ip6(buf, pkt_dev->max_in6_daddr.s6_addr);
-		fmt_ip6(buf,  pkt_dev->max_in6_daddr.s6_addr);
+		scan_ip6(bu.buf6, pkt_dev->max_in6_daddr.s6_addr);
+		fmt_ip6(bu.buf6,  pkt_dev->max_in6_daddr.s6_addr);
 
                 if(debug) 
-			printk("pktgen: dst6_max set to: %s\n", buf);
+			printk("pktgen: dst6_max set to: %s\n", bu.buf6);
 
                 i += len;
-		sprintf(pg_result, "OK: dst6_max=%s", buf);
+		sprintf(pg_result, "OK: dst6_max=%s", bu.buf6);
 		return count;
 	}
 	if (!strcmp(name, "src6")) {
-                char buf[128];
-
 		len = strn_len(&user_buffer[i], 128 - 1);
                 if (len < 0) return len; 
 
 		pkt_dev->flags |= F_IPV6;
 
-                if (copy_from_user(buf, &user_buffer[i], len))
+                if (copy_from_user(bu.buf6, &user_buffer[i], len))
 			return -EFAULT;
-                buf[len] = 0;
+                bu.buf6[len] = 0;
 
-		scan_ip6(buf, pkt_dev->in6_saddr.s6_addr);
-		fmt_ip6(buf,  pkt_dev->in6_saddr.s6_addr);
+		scan_ip6(bu.buf6, pkt_dev->in6_saddr.s6_addr);
+		fmt_ip6(bu.buf6,  pkt_dev->in6_saddr.s6_addr);
 
 		ipv6_addr_copy(&pkt_dev->cur_in6_saddr, &pkt_dev->in6_saddr);
 
                 if(debug) 
-			printk("pktgen: src6 set to: %s\n", buf);
+			printk("pktgen: src6 set to: %s\n", bu.buf6);
 		
                 i += len;
-		sprintf(pg_result, "OK: src6=%s", buf);
+		sprintf(pg_result, "OK: src6=%s", bu.buf6);
 		return count;
 	}
 	if (!strcmp(name, "src_min")) {
-                char buf[IP_NAME_SZ];
 		len = strn_len(&user_buffer[i], sizeof(pkt_dev->src_min) - 1);
                 if (len < 0) { return len; }
-                if (copy_from_user(buf, &user_buffer[i], len))
+                if (copy_from_user(bu.buf4, &user_buffer[i], len))
 			return -EFAULT;
-                buf[len] = 0;
-                if (strcmp(buf, pkt_dev->src_min) != 0) {
+                bu.buf4[len] = 0;
+                if (strcmp(bu.buf4, pkt_dev->src_min) != 0) {
                         memset(pkt_dev->src_min, 0, sizeof(pkt_dev->src_min));
-                        strncpy(pkt_dev->src_min, buf, len);
+                        strncpy(pkt_dev->src_min, bu.buf4, len);
                         pkt_dev->saddr_min = in_aton(pkt_dev->src_min);
                         pkt_dev->cur_saddr = pkt_dev->saddr_min;
                 }
@@ -1224,15 +1217,14 @@ static int proc_if_write(struct file *fi
 		return count;
 	}
 	if (!strcmp(name, "src_max")) {
-                char buf[IP_NAME_SZ];
 		len = strn_len(&user_buffer[i], sizeof(pkt_dev->src_max) - 1);
                 if (len < 0) { return len; }
-                if (copy_from_user(buf, &user_buffer[i], len))
+                if (copy_from_user(bu.buf4, &user_buffer[i], len))
 			return -EFAULT;
-                buf[len] = 0;
-                if (strcmp(buf, pkt_dev->src_max) != 0) {
+                bu.buf4[len] = 0;
+                if (strcmp(bu.buf4, pkt_dev->src_max) != 0) {
                         memset(pkt_dev->src_max, 0, sizeof(pkt_dev->src_max));
-                        strncpy(pkt_dev->src_max, buf, len);
+                        strncpy(pkt_dev->src_max, bu.buf4, len);
                         pkt_dev->saddr_max = in_aton(pkt_dev->src_max);
                         pkt_dev->cur_saddr = pkt_dev->saddr_max;
                 }

--------------060305080105070604010102--
