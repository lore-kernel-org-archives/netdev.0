From: Jason Lunz <lunz@falooley.org>
Subject: [PATCH RESEND 2.4, 2.5] dev->promiscuity refcounting broken in af_packet.c
Date: Tue, 8 Jul 2003 18:12:39 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030708221239.GA20633@orr.falooley.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jmorris@intercode.com.au, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


According to today's bkcvs, the below patch still hasn't been applied to
2.4 or 2.5 despite a -pre release or two,  Alexey reviewed it and
recommended for inclusion.

James, I know you applied it to your bk tree. Will that be enough to get
it into 2.4 and 2.5, or should I submit it elsewhere?

Jason


lunz@falooley.org said:
> The problem is that packet sockets are calling dev_set_promiscuity too
> many times. For example, if I take an unconfigured interface and do:
> 
> halfoat:~ # ip link show eth1
> 9: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast qlen 100
>     link/ether 00:30:48:41:62:12 brd ff:ff:ff:ff:ff:ff
> halfoat:~ # ip link set up eth1
> halfoat:~ # tcpdump -i eth1 &
> [1] 457
> tcpdump: WARNING: eth1: no IPv4 address assigned
> tcpdump: listening on eth1
> halfoat:~ # ip link set down eth1
> tcpdump: pcap_loop: recvfrom: Network is down
> [1]+  Exit 1                  tcpdump -i eth1
> halfoat:~ # ip link show eth1
> 9: eth1: <BROADCAST,MULTICAST,PROMISC> mtu 1500 qdisc pfifo_fast qlen 100
>     link/ether 00:30:48:41:62:12 brd ff:ff:ff:ff:ff:ff
> 
> eth1 is now in promiscuous mode because dev->promiscuity is -1 (!= 0).
> 
> When the interface goes down, dev_change_flags calls dev_close, which
> sends NETDEV_DOWN down the netdev notifier chain. Because tcpdump has a
> packet socket open, packet_notifier calls packet_dev_mclist ->
> packet_dev_mc -> dev_set_promiscuity.
> 
> When tcpdump gets ENETDOWN, it aborts, closing the packet socket.
> af_packet.c's proto_ops->release cleanup method is packet_release.  On
> close(), packet_release calls packet_flush_mclist, which again
> decrements dev->promiscuity, so when tcpdump exits, dev promiscuity is
> left at -1.
> 
> I can't see any reason to be mucking about with the device promiscuity
> on NETDEV_DOWN and NETDEV_UP events in the first place. The attached
> patch seems to fix all the cases I can think of. It works properly in
> both of the above cases, and has also been verified to do the right
> thing with NETDEV_UNREGISTER events.
> 
> Jason
> 

Index: linux-2.4/net/packet/af_packet.c
===================================================================
RCS file: /home/cvs/linux-2.4/net/packet/af_packet.c,v
retrieving revision 1.11
diff -u -p -r1.11 af_packet.c
--- linux-2.4/net/packet/af_packet.c	12 Jun 2002 23:10:34 -0000	1.11
+++ linux-2.4/net/packet/af_packet.c	1 Jul 2003 20:17:51 -0000
@@ -1378,8 +1378,13 @@ static int packet_notifier(struct notifi
 		po = sk->protinfo.af_packet;
 
 		switch (msg) {
-		case NETDEV_DOWN:
 		case NETDEV_UNREGISTER:
+#ifdef CONFIG_PACKET_MULTICAST
+			if (po->mclist)
+				packet_dev_mclist(dev, po->mclist, -1);
+			// fallthrough
+#endif
+		case NETDEV_DOWN:
 			if (dev->ifindex == po->ifindex) {
 				spin_lock(&po->bind_lock);
 				if (po->running) {
@@ -1396,10 +1401,6 @@ static int packet_notifier(struct notifi
 				}
 				spin_unlock(&po->bind_lock);
 			}
-#ifdef CONFIG_PACKET_MULTICAST
-			if (po->mclist)
-				packet_dev_mclist(dev, po->mclist, -1);
-#endif
 			break;
 		case NETDEV_UP:
 			spin_lock(&po->bind_lock);
@@ -1409,10 +1410,6 @@ static int packet_notifier(struct notifi
 				po->running = 1;
 			}
 			spin_unlock(&po->bind_lock);
-#ifdef CONFIG_PACKET_MULTICAST
-			if (po->mclist)
-				packet_dev_mclist(dev, po->mclist, +1);
-#endif
 			break;
 		}
 	}
