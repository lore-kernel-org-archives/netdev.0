From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [INET] Add flags field to ip_tunnel_parm
Date: Tue, 14 Sep 2004 22:16:17 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040914121617.GA5652@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="d6Gm4EdcadzBjdND"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>,
   YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--d6Gm4EdcadzBjdND
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

This patch adds a new flags field to struct ip_tunnel_parm.

The reason is that one of its users, ip_gre cannot place any new flags
in the existing fields.  i_flags is unuseable for GRE because any future
GRE extension may use one of those bits.

Of course we'll need new flags to implement the DSCP options as we
did for ip6_tunnel.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

BTW if anyone else wants to add more fields to the structure, now is
the time.

Another thing, the iptnl_* functions turn out to be fairly big.
So I'd like to uninline them.  Unfortunately I can't think of a
good place to put them.

Should I:

1) Put it into ipip.c and make the others depend on it.
2) Put it into xfrm4_tunnel.c and make the others depend on it.
3) Put it into some other file in net/ipv4 that's always built in.
4) Create a new module just for this (and any other shared code between them).
5) Replace inline with __attribute__ ((__unused__)).
6) Stop thinking about this and do something useful :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--d6Gm4EdcadzBjdND
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

--- /dev/null	2004-08-18 20:24:57.000000000 +1000
+++ work-2.6/include/net/ip_tunnel.h	2004-09-14 21:56:46.000000000 +1000
@@ -0,0 +1,37 @@
+#ifndef _NET_IP_TUNNEL_H
+#define _NET_IP_TUNNEL_H
+
+#include <linux/if_tunnel.h>
+
+struct ip_tunnel_parm_v1
+{
+	char			name[IFNAMSIZ];
+	int			link;
+	__u16			i_flags;
+	__u16			o_flags;
+	__u32			i_key;
+	__u32			o_key;
+	struct iphdr		iph;
+};
+
+static inline int iptnl_get_user_parms(struct ip_tunnel_parm *p,
+				       const void __user *up)
+{
+	if (!copy_from_user(p, up, sizeof(*p)))
+		return 0;
+
+	memset(p, 0, sizeof(*p));
+	return copy_from_user(p, up, sizeof(struct ip_tunnel_parm_v1)) ?
+		-EFAULT : 0;
+}
+
+static inline int iptnl_put_user_parms(void __user *up,
+				       const struct ip_tunnel_parm *p)
+{
+	if (copy_to_user(up, p, sizeof(*p)) &&
+	    copy_to_user(up, p, sizeof(struct ip_tunnel_parm_v1)))
+		return -EFAULT;
+	return 0;
+}
+
+#endif
===== include/linux/if_tunnel.h 1.1 vs edited =====
--- 1.1/include/linux/if_tunnel.h	2002-02-06 04:39:42 +11:00
+++ edited/include/linux/if_tunnel.h	2004-09-14 21:26:20 +10:00
@@ -24,6 +24,7 @@
 	__u32			i_key;
 	__u32			o_key;
 	struct iphdr		iph;
+	__u32			flags;
 };
 
 #endif /* _IF_TUNNEL_H_ */
===== net/ipv4/ip_gre.c 1.42 vs edited =====
--- 1.42/net/ipv4/ip_gre.c	2004-09-09 21:48:58 +10:00
+++ edited/net/ipv4/ip_gre.c	2004-09-14 21:36:21 +10:00
@@ -38,6 +38,7 @@
 #include <net/checksum.h>
 #include <net/inet_ecn.h>
 #include <net/xfrm.h>
+#include <net/ip_tunnel.h>
 
 #ifdef CONFIG_IPV6
 #include <net/ipv6.h>
@@ -896,17 +897,15 @@
 	case SIOCGETTUNNEL:
 		t = NULL;
 		if (dev == ipgre_fb_tunnel_dev) {
-			if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p))) {
-				err = -EFAULT;
+			err = iptnl_get_user_parms(&p, ifr->ifr_ifru.ifru_data);
+			if (err)
 				break;
-			}
 			t = ipgre_tunnel_locate(&p, 0);
 		}
 		if (t == NULL)
 			t = (struct ip_tunnel*)dev->priv;
 		memcpy(&p, &t->parms, sizeof(p));
-		if (copy_to_user(ifr->ifr_ifru.ifru_data, &p, sizeof(p)))
-			err = -EFAULT;
+		err = iptnl_put_user_parms(ifr->ifr_ifru.ifru_data, &p);
 		break;
 
 	case SIOCADDTUNNEL:
@@ -915,8 +914,8 @@
 		if (!capable(CAP_NET_ADMIN))
 			goto done;
 
-		err = -EFAULT;
-		if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p)))
+		err = iptnl_get_user_parms(&p, ifr->ifr_ifru.ifru_data);
+		if (err)
 			goto done;
 
 		err = -EINVAL;
@@ -973,8 +972,8 @@
 				t->parms.iph.tos = p.iph.tos;
 				t->parms.iph.frag_off = p.iph.frag_off;
 			}
-			if (copy_to_user(ifr->ifr_ifru.ifru_data, &t->parms, sizeof(p)))
-				err = -EFAULT;
+			err = iptnl_put_user_parms(ifr->ifr_ifru.ifru_data, 
+						   &t->parms);
 		} else
 			err = (cmd == SIOCADDTUNNEL ? -ENOBUFS : -ENOENT);
 		break;
@@ -985,8 +984,8 @@
 			goto done;
 
 		if (dev == ipgre_fb_tunnel_dev) {
-			err = -EFAULT;
-			if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p)))
+			err = iptnl_get_user_parms(&p, ifr->ifr_ifru.ifru_data);
+			if (err)
 				goto done;
 			err = -ENOENT;
 			if ((t = ipgre_tunnel_locate(&p, 0)) == NULL)
===== net/ipv4/ipip.c 1.44 vs edited =====
--- 1.44/net/ipv4/ipip.c	2004-09-09 21:48:58 +10:00
+++ edited/net/ipv4/ipip.c	2004-09-14 21:53:22 +10:00
@@ -116,6 +116,7 @@
 #include <net/ipip.h>
 #include <net/inet_ecn.h>
 #include <net/xfrm.h>
+#include <net/ip_tunnel.h>
 
 #define HASH_SIZE  16
 #define HASH(addr) ((addr^(addr>>4))&0xF)
@@ -667,17 +668,15 @@
 	case SIOCGETTUNNEL:
 		t = NULL;
 		if (dev == ipip_fb_tunnel_dev) {
-			if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p))) {
-				err = -EFAULT;
+			err = iptnl_get_user_parms(&p, ifr->ifr_ifru.ifru_data);
+			if (err)
 				break;
-			}
 			t = ipip_tunnel_locate(&p, 0);
 		}
 		if (t == NULL)
 			t = (struct ip_tunnel*)dev->priv;
 		memcpy(&p, &t->parms, sizeof(p));
-		if (copy_to_user(ifr->ifr_ifru.ifru_data, &p, sizeof(p)))
-			err = -EFAULT;
+		err = iptnl_put_user_parms(ifr->ifr_ifru.ifru_data, &p);
 		break;
 
 	case SIOCADDTUNNEL:
@@ -686,8 +685,8 @@
 		if (!capable(CAP_NET_ADMIN))
 			goto done;
 
-		err = -EFAULT;
-		if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p)))
+		err = iptnl_get_user_parms(&p, ifr->ifr_ifru.ifru_data);
+		if (err)
 			goto done;
 
 		err = -EINVAL;
@@ -729,8 +728,8 @@
 				t->parms.iph.tos = p.iph.tos;
 				t->parms.iph.frag_off = p.iph.frag_off;
 			}
-			if (copy_to_user(ifr->ifr_ifru.ifru_data, &t->parms, sizeof(p)))
-				err = -EFAULT;
+			err = iptnl_put_user_parms(ifr->ifr_ifru.ifru_data,
+						   &t->parms);
 		} else
 			err = (cmd == SIOCADDTUNNEL ? -ENOBUFS : -ENOENT);
 		break;
@@ -741,8 +740,8 @@
 			goto done;
 
 		if (dev == ipip_fb_tunnel_dev) {
-			err = -EFAULT;
-			if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p)))
+			err = iptnl_get_user_parms(&p, ifr->ifr_ifru.ifru_data);
+			if (err)
 				goto done;
 			err = -ENOENT;
 			if ((t = ipip_tunnel_locate(&p, 0)) == NULL)
===== net/ipv6/sit.c 1.41 vs edited =====
--- 1.41/net/ipv6/sit.c	2004-09-09 21:48:58 +10:00
+++ edited/net/ipv6/sit.c	2004-09-14 21:37:36 +10:00
@@ -50,6 +50,7 @@
 #include <net/ipip.h>
 #include <net/inet_ecn.h>
 #include <net/xfrm.h>
+#include <net/ip_tunnel.h>
 
 /*
    This version of net/ipv6/sit.c is cloned of net/ipv4/ip_gre.c
@@ -599,17 +600,15 @@
 	case SIOCGETTUNNEL:
 		t = NULL;
 		if (dev == ipip6_fb_tunnel_dev) {
-			if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p))) {
-				err = -EFAULT;
+			err = iptnl_get_user_parms(&p, ifr->ifr_ifru.ifru_data);
+			if (err)
 				break;
-			}
 			t = ipip6_tunnel_locate(&p, 0);
 		}
 		if (t == NULL)
 			t = (struct ip_tunnel*)dev->priv;
 		memcpy(&p, &t->parms, sizeof(p));
-		if (copy_to_user(ifr->ifr_ifru.ifru_data, &p, sizeof(p)))
-			err = -EFAULT;
+		err = iptnl_put_user_parms(ifr->ifr_ifru.ifru_data, &p);
 		break;
 
 	case SIOCADDTUNNEL:
@@ -618,8 +617,8 @@
 		if (!capable(CAP_NET_ADMIN))
 			goto done;
 
-		err = -EFAULT;
-		if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p)))
+		err = iptnl_get_user_parms(&p, ifr->ifr_ifru.ifru_data);
+		if (err)
 			goto done;
 
 		err = -EINVAL;
@@ -660,8 +659,8 @@
 				t->parms.iph.ttl = p.iph.ttl;
 				t->parms.iph.tos = p.iph.tos;
 			}
-			if (copy_to_user(ifr->ifr_ifru.ifru_data, &t->parms, sizeof(p)))
-				err = -EFAULT;
+			err = iptnl_put_user_parms(ifr->ifr_ifru.ifru_data,
+						   &t->parms);
 		} else
 			err = (cmd == SIOCADDTUNNEL ? -ENOBUFS : -ENOENT);
 		break;
@@ -672,8 +671,8 @@
 			goto done;
 
 		if (dev == ipip6_fb_tunnel_dev) {
-			err = -EFAULT;
-			if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p)))
+			err = iptnl_get_user_parms(&p, ifr->ifr_ifru.ifru_data);
+			if (err)
 				goto done;
 			err = -ENOENT;
 			if ((t = ipip6_tunnel_locate(&p, 0)) == NULL)

--d6Gm4EdcadzBjdND--
