From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Move inetdev/ifa over to RCU
Date: Sun, 15 Aug 2004 23:21:53 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040815232153.54e95346.davem@redhat.com>
References: <20040812165954.00429e65.davem@redhat.com>
	<20040813090314.448c971d@dell_ss3.pdx.osdl.net>
	<20040813093838.6961c0d4.davem@redhat.com>
	<20040813215602.GA15870@gondor.apana.org.au>
	<20040813151923.3311b4f0.davem@redhat.com>
	<20040814003428.GA17760@gondor.apana.org.au>
	<20040815195820.6b79b3fc.davem@redhat.com>
	<20040816030826.GA8341@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040816030826.GA8341@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 16 Aug 2004 13:08:26 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> So we should reverse the two statements and add an smp_wmb().

I totally agree, and let's kill the lock too since it is
in fact useless now.  I've done this as follows:

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/08/15 23:08:21-07:00 davem@nuts.davemloft.net 
#   [IPV4]: Kill inetdev_lock, no longer needed.
#   
#   It no longer protects anything, all users held RTNL
#   semaphore to boot.  Also, fix a potential race in the
#   new RCU inetdev code, grab the reference on the idev
#   before attaching it via dev->ip_ptr.
#   
#   Based upon discussions with Herbert Xu.
#   
#   Signed-off-by: David S. Miller <davem@redhat.com>
# 
# net/ipv4/devinet.c
#   2004/08/15 23:07:17-07:00 davem@nuts.davemloft.net +6 -14
#   [IPV4]: Kill inetdev_lock, no longer needed.
# 
diff -Nru a/net/ipv4/devinet.c b/net/ipv4/devinet.c
--- a/net/ipv4/devinet.c	2004-08-15 23:08:59 -07:00
+++ b/net/ipv4/devinet.c	2004-08-15 23:08:59 -07:00
@@ -90,8 +90,6 @@
 
 /* Locks all the inet devices. */
 
-static spinlock_t inetdev_lock = SPIN_LOCK_UNLOCKED;
-
 static struct in_ifaddr *inet_alloc_ifa(void)
 {
 	struct in_ifaddr *ifa = kmalloc(sizeof(*ifa), GFP_KERNEL);
@@ -158,11 +156,12 @@
 	neigh_sysctl_register(dev, in_dev->arp_parms, NET_IPV4,
 			      NET_IPV4_NEIGH, "ipv4", NULL);
 #endif
-	spin_lock_bh(&inetdev_lock);
-	dev->ip_ptr = in_dev;
+
 	/* Account for reference dev->ip_ptr */
 	in_dev_hold(in_dev);
-	spin_unlock_bh(&inetdev_lock);
+	smp_wmb();
+	dev->ip_ptr = in_dev;
+
 #ifdef CONFIG_SYSCTL
 	devinet_sysctl_register(in_dev, &in_dev->cnf);
 #endif
@@ -201,10 +200,8 @@
 #ifdef CONFIG_SYSCTL
 	devinet_sysctl_unregister(&in_dev->cnf);
 #endif
-	spin_lock_bh(&inetdev_lock);
+
 	in_dev->dev->ip_ptr = NULL;
-	/* in_dev_put following below will kill the in_device */
-	spin_unlock_bh(&inetdev_lock);
 
 #ifdef CONFIG_SYSCTL
 	neigh_sysctl_unregister(in_dev->arp_parms);
@@ -248,9 +245,8 @@
 				ifap1 = &ifa->ifa_next;
 				continue;
 			}
-			spin_lock_bh(&inetdev_lock);
+
 			*ifap1 = ifa->ifa_next;
-			spin_unlock_bh(&inetdev_lock);
 
 			rtmsg_ifa(RTM_DELADDR, ifa);
 			notifier_call_chain(&inetaddr_chain, NETDEV_DOWN, ifa);
@@ -260,9 +256,7 @@
 
 	/* 2. Unlink it */
 
-	spin_lock_bh(&inetdev_lock);
 	*ifap = ifa1->ifa_next;
-	spin_unlock_bh(&inetdev_lock);
 
 	/* 3. Announce address deletion */
 
@@ -324,9 +318,7 @@
 	}
 
 	ifa->ifa_next = *ifap;
-	spin_lock_bh(&inetdev_lock);
 	*ifap = ifa;
-	spin_unlock_bh(&inetdev_lock);
 
 	/* Send message first, then call notifier.
 	   Notifier will trigger FIB update, so that
