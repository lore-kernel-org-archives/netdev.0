From: "Bill Rugolsky Jr." <brugolsky@telemetry-investments.com>
Subject: no netlink message for neighbor route deletion if proto != kernel
Date: Mon, 17 May 2004 12:42:06 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040517164206.GC24080@ti64.telemetry-investments.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I've come across the following issue caused by Red Hat's /sbin/ifup.
The ifup script does the following:

   ip route replace ${NETWORK}/${PREFIX} ${SRC} ${WINDOW:+window $WINDOW} \
	dev ${REALDEVICE}

This has the side-effect of removing "proto kernel" from the neighbor route.
When the address is later removed in ifdown with "ip addr flush dev $REALDEVICE",
netlink does not generate a deletion message for the aforementioned route.

This unfortunately confuses Quagga, which expects matching add/delete
Netlink messages.  I can work around this by specifying "proto kernel"
in /sbin/ifup, but I'm wondering whether this is intended behavior. [I'm
mindful of Alexey's comments regarding routing daemons and netlink,
but that's not really the point of my question.]

In linux/net/ipv4/fib_frontend.c, fib_del_ifaddr() calls fib_magic(),
which sets

	req.rtm.rtm_protocol = RTPROT_KERNEL;

before calling fib_hash_delete():

        if (cmd == RTM_NEWROUTE)
                tb->tb_insert(tb, &req.rtm, &rta, &req.nlh, NULL);
        else
                tb->tb_delete(tb, &req.rtm, &rta, &req.nlh, NULL);


The route is not matched by fib_hash_delete(), but appears to be flushed
at the end if fib_delete_ifaddr(),

                if (inet_addr_type(ifa->ifa_local) != RTN_LOCAL) {
                        /* And the last, but not the least thing.
                           We must flush stray FIB entries.

                           First of all, we scan fib_info list searching
                           for stray nexthop entries, then ignite fib_flush.
                        */
                        if (fib_sync_down(ifa->ifa_local, NULL, 0))
                                fib_flush();

and rtmsg_fib(RTM_DELROUTE,...) is never called.

Is my analysis correct, and is this the intended behavior?
Or should fib_magic() look like:


--- linux/net/ipv4/fib_frontend.c	2004-04-03 22:38:24.000000000 -0500
+++ linux/net/ipv4/fib_frontend.c	2004-05-17 12:35:37.470324232 -0400
@@ -394,7 +394,6 @@
 
 	req.rtm.rtm_dst_len = dst_len;
 	req.rtm.rtm_table = tb->tb_id;
-	req.rtm.rtm_protocol = RTPROT_KERNEL;
 	req.rtm.rtm_scope = (type != RTN_LOCAL ? RT_SCOPE_LINK : RT_SCOPE_HOST);
 	req.rtm.rtm_type = type;
 
@@ -402,10 +401,13 @@
 	rta.rta_prefsrc = &ifa->ifa_local;
 	rta.rta_oif = &ifa->ifa_dev->dev->ifindex;
 
-	if (cmd == RTM_NEWROUTE)
+	if (cmd == RTM_NEWROUTE) {
+		req.rtm.rtm_protocol = RTPROT_KERNEL;
 		tb->tb_insert(tb, &req.rtm, &rta, &req.nlh, NULL);
-	else
+	} else {
+		req.rtm.rtm_protocol = RTPROT_UNSPEC;
 		tb->tb_delete(tb, &req.rtm, &rta, &req.nlh, NULL);
+	}
 }
 
 static void fib_add_ifaddr(struct in_ifaddr *ifa)

Regards,

	Bill Rugolsky
