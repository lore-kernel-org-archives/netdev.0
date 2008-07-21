From: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Subject: Re: [crash] BUG: unable to handle kernel NULL pointer dereference
 at 0000000000000370
Date: Mon, 21 Jul 2008 23:35:29 +0200
Message-ID: <48850121.9090106@trash.net>
References: <4884F3D7.4070604@lwfinger.net>	<20080721.134608.75595942.davem@davemloft.net>	<4884F6E9.6090809@trash.net> <20080721.140120.135667045.davem@davemloft.net> <4884FA3F.70109@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020507030800020103000303"
Cc: Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, ischram-CNXmb7IdZIWZIoH1IeqzKA@public.gmane.org,
	torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, j@w1.fi
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4884FA3F.70109-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020507030800020103000303
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> David Miller wrote:
>> Maybe something like the following should do it?
> 
> 
> It looks correct in any case. I'm not sure whether it fixes
> this lockdep warning though, according to the backtrace and
> module list its b43 and dev_mc_sync in net/mac80211/main.c
> that are causing the error, which don't seem to be included
> in your patch. I'm unable to find where it previously
> initialized the xmit_lock lockdep class though, so I must
> be missing something :)

This is what I was missing, we're setting a lockdep class
by default depending on dev->type. This patch combined
with yours should fix all addr_list_lock warnings.



--------------020507030800020103000303
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

net: set lockdep class for dev->addr_list_lock

Initialize dev->addr_list_lock lockdep classes equally to dev->_xmit_lock.

Signed-off-by: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>

diff --git a/net/core/dev.c b/net/core/dev.c
index 2eed17b..9cfed90 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -299,6 +299,7 @@ static const char *netdev_lock_name[] =
 	 "_xmit_NONE"};
 
 static struct lock_class_key netdev_xmit_lock_key[ARRAY_SIZE(netdev_lock_type)];
+static struct lock_class_key netdev_addr_lock_key[ARRAY_SIZE(netdev_lock_type)];
 
 static inline unsigned short netdev_lock_pos(unsigned short dev_type)
 {
@@ -311,8 +312,8 @@ static inline unsigned short netdev_lock_pos(unsigned short dev_type)
 	return ARRAY_SIZE(netdev_lock_type) - 1;
 }
 
-static inline void netdev_set_lockdep_class(spinlock_t *lock,
-					    unsigned short dev_type)
+static inline void netdev_set_xmit_lockdep_class(spinlock_t *lock,
+						 unsigned short dev_type)
 {
 	int i;
 
@@ -320,9 +321,23 @@ static inline void netdev_set_lockdep_class(spinlock_t *lock,
 	lockdep_set_class_and_name(lock, &netdev_xmit_lock_key[i],
 				   netdev_lock_name[i]);
 }
+
+static inline void netdev_set_addr_lockdep_class(spinlock_t *lock,
+						 unsigned short dev_type)
+{
+	int i;
+
+	i = netdev_lock_pos(dev_type);
+	lockdep_set_class_and_name(lock, &netdev_addr_lock_key[i],
+				   netdev_lock_name[i]);
+}
 #else
-static inline void netdev_set_lockdep_class(spinlock_t *lock,
-					    unsigned short dev_type)
+static inline void netdev_set_xmit_lockdep_class(spinlock_t *lock,
+						 unsigned short dev_type)
+{
+}
+static inline void netdev_set_addr_lockdep_class(spinlock_t *lock,
+						 unsigned short dev_type)
 {
 }
 #endif
@@ -3843,14 +3858,15 @@ static void __netdev_init_queue_locks_one(struct net_device *dev,
 					  void *_unused)
 {
 	spin_lock_init(&dev_queue->_xmit_lock);
-	netdev_set_lockdep_class(&dev_queue->_xmit_lock, dev->type);
+	netdev_set_xmit_lockdep_class(&dev_queue->_xmit_lock, dev->type);
 	dev_queue->xmit_lock_owner = -1;
 }
 
-static void netdev_init_queue_locks(struct net_device *dev)
+static void netdev_init_locks(struct net_device *dev)
 {
 	netdev_for_each_tx_queue(dev, __netdev_init_queue_locks_one, NULL);
 	__netdev_init_queue_locks_one(dev, &dev->rx_queue, NULL);
+	netdev_set_addr_lockdep_class(&dev->addr_list_lock, dev->type);
 }
 
 /**
@@ -3888,7 +3904,7 @@ int register_netdevice(struct net_device *dev)
 	net = dev_net(dev);
 
 	spin_lock_init(&dev->addr_list_lock);
-	netdev_init_queue_locks(dev);
+	netdev_init_locks(dev);
 
 	dev->iflink = -1;
 

--------------020507030800020103000303--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
