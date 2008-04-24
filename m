From: Patrick McHardy <kaber@trash.net>
Subject: [RTNETLINK]: Fix bogus ASSERT_RTNL warning
Date: Thu, 24 Apr 2008 05:44:03 +0200
Message-ID: <48100203.2020606@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060006090803030302090809"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Denys <denys@visp.net.lb>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55657 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750952AbYDXDoA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 23:44:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060006090803030302090809
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

This patch should fix/silence the warning reported by Denys
Fedoryshchenko. Looking at kerneloops.org, there are also a
huge number of reports of this warning triggered by wireless,
so even if this is not the ideal solution, I think for now
we should just silence it.


--------------060006090803030302090809
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit 0d034d8ef5cc2f9f4df960d4f8625c1061282e69
Author: Patrick McHardy <kaber@trash.net>
Date:   Thu Apr 24 05:40:27 2008 +0200

    [RTNETLINK]: Fix bogus ASSERT_RTNL warning
    
    ASSERT_RTNL uses mutex_trylock to test whether the rtnl_mutex is
    held. This bogus warnings when running in atomic context, which
    f.e. happens when adding secondary unicast addresses through
    macvlan or vlan or when synchronizing multicast addresses from
    wireless devices.
    
    Mid-term we might want to consider moving all address updates
    to process context since the locking seems overly complicated,
    for now just fix the bogus warning by changing ASSERT_RTNL to
    use mutex_is_locked().
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index b9e1740..44c81c7 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -740,13 +740,13 @@ extern void rtmsg_ifinfo(int type, struct net_device *dev, unsigned change);
 extern void rtnl_lock(void);
 extern void rtnl_unlock(void);
 extern int rtnl_trylock(void);
+extern int rtnl_is_locked(void);
 
 extern void rtnetlink_init(void);
 extern void __rtnl_unlock(void);
 
 #define ASSERT_RTNL() do { \
-	if (unlikely(rtnl_trylock())) { \
-		rtnl_unlock(); \
+	if (unlikely(!rtnl_is_locked())) { \
 		printk(KERN_ERR "RTNL: assertion failed at %s (%d)\n", \
 		       __FILE__,  __LINE__); \
 		dump_stack(); \
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index bc39e41..cf857c4 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -82,6 +82,11 @@ int rtnl_trylock(void)
 	return mutex_trylock(&rtnl_mutex);
 }
 
+int rtnl_is_locked(void)
+{
+	return mutex_is_locked(&rtnl_mutex);
+}
+
 static struct rtnl_link *rtnl_msg_handlers[NPROTO];
 
 static inline int rtm_msgindex(int msgtype)
@@ -1402,6 +1407,7 @@ EXPORT_SYMBOL(rtnetlink_put_metrics);
 EXPORT_SYMBOL(rtnl_lock);
 EXPORT_SYMBOL(rtnl_trylock);
 EXPORT_SYMBOL(rtnl_unlock);
+EXPORT_SYMBOL(rtnl_is_locked);
 EXPORT_SYMBOL(rtnl_unicast);
 EXPORT_SYMBOL(rtnl_notify);
 EXPORT_SYMBOL(rtnl_set_sk_err);

--------------060006090803030302090809--
