From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Move inetdev/ifa over to RCU
Date: Sat, 14 Aug 2004 11:25:13 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040814012513.GA721@gondor.apana.org.au>
References: <20040812165954.00429e65.davem@redhat.com> <20040813090314.448c971d@dell_ss3.pdx.osdl.net> <20040813093838.6961c0d4.davem@redhat.com> <20040813215602.GA15870@gondor.apana.org.au> <20040813151923.3311b4f0.davem@redhat.com> <20040814003428.GA17760@gondor.apana.org.au> <20040813173924.6d05be15.davem@redhat.com> <20040814005411.GA18350@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="5vNYLRcllDrimb99"
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040814005411.GA18350@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--5vNYLRcllDrimb99
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

I gave your patch to the compiler and it doesn't like it :)
call_rcu needs three arguments, not two.

Watch out, this will probably conflict with your in_dev typo fix.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--5vNYLRcllDrimb99
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=r

===== net/ipv4/devinet.c 1.34 vs edited =====
--- 1.34/net/ipv4/devinet.c	2004-08-14 08:36:53 +10:00
+++ edited/net/ipv4/devinet.c	2004-08-14 11:20:19 +10:00
@@ -111,10 +111,8 @@
 	kfree(ifa);
 }
 
-static void inet_rcu_free_ifa(struct rcu_head *head)
+static void inet_rcu_free_ifa(void *ifa)
 {
-	struct in_ifaddr *ifa = container_of(head, struct in_ifaddr, rcu_head);
-
 	inet_free_ifa(ifa);
 }
 
@@ -177,9 +175,8 @@
 	goto out;
 }
 
-static void in_dev_rcu_put(struct rcu_head *head)
+static void in_dev_rcu_put(void *idev)
 {
-	struct in_device *idev = container_of(head, struct in_device, rcu_head);
 	in_dev_put(idev);
 }
 
@@ -195,7 +192,7 @@
 
 	while ((ifa = in_dev->ifa_list) != NULL) {
 		inet_del_ifa(in_dev, &in_dev->ifa_list, 0);
-		call_rcu(&ifa->rcu_head, inet_rcu_free_ifa);
+		call_rcu(&ifa->rcu_head, inet_rcu_free_ifa, ifa);
 	}
 
 #ifdef CONFIG_SYSCTL
@@ -210,7 +207,7 @@
 	neigh_sysctl_unregister(in_dev->arp_parms);
 #endif
 	neigh_parms_release(&arp_tbl, in_dev->arp_parms);
-	call_rcu(&idev->rcu_head, in_dev_rcu_put);
+	call_rcu(&in_dev->rcu_head, in_dev_rcu_put, in_dev);
 }
 
 int inet_addr_onlink(struct in_device *in_dev, u32 a, u32 b)
@@ -255,7 +252,7 @@
 
 			rtmsg_ifa(RTM_DELADDR, ifa);
 			notifier_call_chain(&inetaddr_chain, NETDEV_DOWN, ifa);
-			call_rcu(&ifa->rcu_head, inet_rcu_free_ifa);
+			call_rcu(&ifa->rcu_head, inet_rcu_free_ifa, ifa);
 		}
 	}
 
@@ -278,7 +275,7 @@
 	rtmsg_ifa(RTM_DELADDR, ifa1);
 	notifier_call_chain(&inetaddr_chain, NETDEV_DOWN, ifa1);
 	if (destroy) {
-		call_rcu(&ifa1->rcu_head, inet_rcu_free_ifa);
+		call_rcu(&ifa1->rcu_head, inet_rcu_free_ifa, ifa1);
 
 		if (!in_dev->ifa_list)
 			inetdev_destroy(in_dev);
@@ -293,7 +290,7 @@
 	ASSERT_RTNL();
 
 	if (!ifa->ifa_local) {
-		call_rcu(&ifa->rcu_head, inet_rcu_free_ifa);
+		call_rcu(&ifa->rcu_head, inet_rcu_free_ifa, ifa);
 		return 0;
 	}
 
@@ -308,11 +305,13 @@
 		if (ifa1->ifa_mask == ifa->ifa_mask &&
 		    inet_ifa_match(ifa1->ifa_address, ifa)) {
 			if (ifa1->ifa_local == ifa->ifa_local) {
-				call_rcu(&ifa->rcu_head, inet_rcu_free_ifa);
+				call_rcu(&ifa->rcu_head, inet_rcu_free_ifa,
+					 ifa);
 				return -EEXIST;
 			}
 			if (ifa1->ifa_scope != ifa->ifa_scope) {
-				call_rcu(&ifa->rcu_head, inet_rcu_free_ifa);
+				call_rcu(&ifa->rcu_head, inet_rcu_free_ifa,
+					 ifa);
 				return -EINVAL;
 			}
 			ifa->ifa_flags |= IFA_F_SECONDARY;
@@ -347,7 +346,7 @@
 	if (!in_dev) {
 		in_dev = inetdev_init(dev);
 		if (!in_dev) {
-			call_rcu(&ifa->rcu_head, inet_rcu_free_ifa);
+			call_rcu(&ifa->rcu_head, inet_rcu_free_ifa, ifa);
 			return -ENOBUFS;
 		}
 	}

--5vNYLRcllDrimb99--
