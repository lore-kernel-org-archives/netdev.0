From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Move inetdev/ifa over to RCU
Date: Mon, 16 Aug 2004 13:23:44 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040816032344.GA8666@gondor.apana.org.au>
References: <20040813090314.448c971d@dell_ss3.pdx.osdl.net> <20040813093838.6961c0d4.davem@redhat.com> <20040813215602.GA15870@gondor.apana.org.au> <20040813151923.3311b4f0.davem@redhat.com> <20040814003428.GA17760@gondor.apana.org.au> <20040813173924.6d05be15.davem@redhat.com> <20040814005411.GA18350@gondor.apana.org.au> <20040814012513.GA721@gondor.apana.org.au> <20040814014048.GA2746@gondor.apana.org.au> <20040815200357.6593e861.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="+HP7ph2BbKc20aGI"
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040815200357.6593e861.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--+HP7ph2BbKc20aGI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sun, Aug 15, 2004 at 08:03:57PM -0700, David S. Miller wrote:
> On Sat, 14 Aug 2004 11:40:48 +1000
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > Since nobody calls inet_free_ifa directly anymore, we can
> > perform the following simplification.
> 
> You need to redo this patch because the 3-arg call_rcu() bits
> are in there.

Sorry.  Here it is again.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--+HP7ph2BbKc20aGI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=q

===== net/ipv4/devinet.c 1.34 vs 1.38 =====
--- 1.34/net/ipv4/devinet.c	2004-08-14 08:36:53 +10:00
+++ 1.38/net/ipv4/devinet.c	2004-08-14 14:50:31 +10:00
@@ -104,18 +104,17 @@
 	return ifa;
 }
 
-static inline void inet_free_ifa(struct in_ifaddr *ifa)
+static void inet_rcu_free_ifa(struct rcu_head *head)
 {
+	struct in_ifaddr *ifa = container_of(head, struct in_ifaddr, rcu_head);
 	if (ifa->ifa_dev)
 		in_dev_put(ifa->ifa_dev);
 	kfree(ifa);
 }
 
-static void inet_rcu_free_ifa(struct rcu_head *head)
+static inline void inet_free_ifa(struct in_ifaddr *ifa)
 {
-	struct in_ifaddr *ifa = container_of(head, struct in_ifaddr, rcu_head);
-
-	inet_free_ifa(ifa);
+	call_rcu(&ifa->rcu_head, inet_rcu_free_ifa);
 }
 
 void in_dev_finish_destroy(struct in_device *idev)
@@ -195,7 +194,7 @@
 
 	while ((ifa = in_dev->ifa_list) != NULL) {
 		inet_del_ifa(in_dev, &in_dev->ifa_list, 0);
-		call_rcu(&ifa->rcu_head, inet_rcu_free_ifa);
+		inet_free_ifa(ifa);
 	}
 
 #ifdef CONFIG_SYSCTL
@@ -255,7 +253,7 @@
 
 			rtmsg_ifa(RTM_DELADDR, ifa);
 			notifier_call_chain(&inetaddr_chain, NETDEV_DOWN, ifa);
-			call_rcu(&ifa->rcu_head, inet_rcu_free_ifa);
+			inet_free_ifa(ifa);
 		}
 	}
 
@@ -278,7 +276,7 @@
 	rtmsg_ifa(RTM_DELADDR, ifa1);
 	notifier_call_chain(&inetaddr_chain, NETDEV_DOWN, ifa1);
 	if (destroy) {
-		call_rcu(&ifa1->rcu_head, inet_rcu_free_ifa);
+		inet_free_ifa(ifa1);
 
 		if (!in_dev->ifa_list)
 			inetdev_destroy(in_dev);
@@ -293,7 +291,7 @@
 	ASSERT_RTNL();
 
 	if (!ifa->ifa_local) {
-		call_rcu(&ifa->rcu_head, inet_rcu_free_ifa);
+		inet_free_ifa(ifa);
 		return 0;
 	}
 
@@ -308,11 +306,11 @@
 		if (ifa1->ifa_mask == ifa->ifa_mask &&
 		    inet_ifa_match(ifa1->ifa_address, ifa)) {
 			if (ifa1->ifa_local == ifa->ifa_local) {
-				call_rcu(&ifa->rcu_head, inet_rcu_free_ifa);
+				inet_free_ifa(ifa);
 				return -EEXIST;
 			}
 			if (ifa1->ifa_scope != ifa->ifa_scope) {
-				call_rcu(&ifa->rcu_head, inet_rcu_free_ifa);
+				inet_free_ifa(ifa);
 				return -EINVAL;
 			}
 			ifa->ifa_flags |= IFA_F_SECONDARY;
@@ -347,7 +345,7 @@
 	if (!in_dev) {
 		in_dev = inetdev_init(dev);
 		if (!in_dev) {
-			call_rcu(&ifa->rcu_head, inet_rcu_free_ifa);
+			inet_free_ifa(ifa);
 			return -ENOBUFS;
 		}
 	}

--+HP7ph2BbKc20aGI--
