From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH 1/3] IPV6: ignore on-link information without on-link flag
 set
Date: Fri, 04 Jul 2003 18:36:58 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030704.183658.38951452.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, jmorris@intercode.com.au
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

1/3: ignore on-link information without on-link flag set

On-link flag == 0 in RA message does not mean that the 
prefix is off-link. It simply means the prefix 
does not talk about on-link information.

Index: linux-2.5/net/ipv6/addrconf.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv6/addrconf.c,v
retrieving revision 1.44
diff -u -r1.44 addrconf.c
--- linux-2.5/net/ipv6/addrconf.c	1 Jul 2003 16:42:06 -0000	1.44
+++ linux-2.5/net/ipv6/addrconf.c	4 Jul 2003 07:37:37 -0000
@@ -1299,7 +1299,6 @@
 void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len)
 {
 	struct prefix_info *pinfo;
-	struct rt6_info *rt;
 	__u32 valid_lft;
 	__u32 prefered_lft;
 	int addr_type;
@@ -1355,23 +1354,26 @@
 	else
 		rt_expires = jiffies + valid_lft * HZ;
 
-	rt = rt6_lookup(&pinfo->prefix, NULL, dev->ifindex, 1);
-
-	if (rt && ((rt->rt6i_flags & (RTF_GATEWAY | RTF_DEFAULT)) == 0)) {
-		if (rt->rt6i_flags&RTF_EXPIRES) {
-			if (pinfo->onlink == 0 || valid_lft == 0) {
-				ip6_del_rt(rt, NULL, NULL);
-				rt = NULL;
-			} else {
-				rt->rt6i_expires = rt_expires;
+	if (pinfo->onlink) {
+		struct rt6_info *rt;
+		rt = rt6_lookup(&pinfo->prefix, NULL, dev->ifindex, 1);
+
+		if (rt && ((rt->rt6i_flags & (RTF_GATEWAY | RTF_DEFAULT)) == 0)) {
+			if (rt->rt6i_flags&RTF_EXPIRES) {
+				if (valid_lft == 0) {
+					ip6_del_rt(rt, NULL, NULL);
+					rt = NULL;
+				} else {
+					rt->rt6i_expires = rt_expires;
+				}
 			}
+		} else if (valid_lft) {
+			addrconf_prefix_route(&pinfo->prefix, pinfo->prefix_len,
+					      dev, rt_expires, RTF_ADDRCONF|RTF_EXPIRES);
 		}
-	} else if (pinfo->onlink && valid_lft) {
-		addrconf_prefix_route(&pinfo->prefix, pinfo->prefix_len,
-				      dev, rt_expires, RTF_ADDRCONF|RTF_EXPIRES);
+		if (rt)
+			dst_release(&rt->u.dst);
 	}
-	if (rt)
-		dst_release(&rt->u.dst);
 
 	/* Try to figure out our local address for this prefix */
 


-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
