From: Krishna Kumar <krkumar@us.ibm.com>
Subject: [PATCH] Hang in downing interface with IPv6 PRIVACY
Date: Fri, 7 Nov 2003 11:01:41 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0311071034230.1107-100000@linux.local>
References: <20031106115935.0cd56745.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <krkumar@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031106115935.0cd56745.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

While using PRIVACY extensions, I sometimes get a hang when I remove the
interface. But I can reproduce this every time using the test script at
the end of the mail (hang depends on the order of address deletion).

The bug is in ipv6_del_addr() where if a temp address is being deleted, it
does an __in6_ifa_put() of the main address from which it was derived
(basically the autoconf prefix address). So if the main address was
deleted first, it's ifp ref count would be 1 and it would 'wait' to be
freed till it's temp address was freed first. When the temp address is
deleted, the __put() routine drops the main address's ifp ref count to 0,
but not free it. unregister_netdevice() hangs giving message that ref
count is 1. Fix tested overnight.

Also, the code at the top of the routine is unnecessary, the same is being
done when the address is found a little later in that routine.

Thanks,

- KK

-------------------------- PATCH -----------------------------------------
diff -ruN linux-2.6.0-test9-bk9/net/ipv6/addrconf.c linux-2.6.0-test9-bk9.new/net/ipv6/addrconf.c
--- linux-2.6.0-test9-bk9/net/ipv6/addrconf.c	2003-11-07 10:56:42.000000000 -0800
+++ linux-2.6.0-test9-bk9.new/net/ipv6/addrconf.c	2003-11-07 10:56:50.000000000 -0800
@@ -571,15 +571,6 @@

 	ifp->dead = 1;

-#ifdef CONFIG_IPV6_PRIVACY
-	spin_lock_bh(&ifp->lock);
-	if (ifp->ifpub) {
-		__in6_ifa_put(ifp->ifpub);
-		ifp->ifpub = NULL;
-	}
-	spin_unlock_bh(&ifp->lock);
-#endif
-
 	write_lock_bh(&addrconf_hash_lock);
 	for (ifap = &inet6_addr_lst[hash]; (ifa=*ifap) != NULL;
 	     ifap = &ifa->lst_next) {
@@ -600,7 +591,7 @@
 			if (ifa == ifp) {
 				*ifap = ifa->tmp_next;
 				if (ifp->ifpub) {
-					__in6_ifa_put(ifp->ifpub);
+					in6_ifa_put(ifp->ifpub);
 					ifp->ifpub = NULL;
 				}
 				__in6_ifa_put(ifp);
----------------------- TEST PROGRAM ------------------------------------
insmod /lib/modules/2.6.0-test9-bk9/kernel/drivers/net/e100/e100.ko
ifup eth0

# enable privacy address creation
echo 1  > /proc/sys/net/ipv6/conf/eth0/use_tempaddr

# set router, get autoconf/privacy addresses
echo 1 > /proc/sys/net/ipv6/conf/all/forwarding
radvd
echo 0 > /proc/sys/net/ipv6/conf/all/forwarding

# wait for radvd to configure interface addresses
sleep 10

# kill radvd (paranoia)
kill `ps -ef|grep radvd|grep -v grep|awk '{print $2}'`

# delete last regular address first! (happens to be regular :-)
ifconfig eth0 del `ifconfig eth0 | grep Site | tail -1 | awk '{print $3}'`

# now delete all other addresses. bug happens here when the temp address
# is deleted, it doesn't free the regular addresses 'ifp'.
for i in `ifconfig eth0 | grep Site | awk '{print $3}'`
do
	ifconfig eth0 del $i
done

ifdown eth0
rmmod e100
