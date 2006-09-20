From: Kimitoshi Takahashi <ktaka@clustcom.com>
Subject: source ip selection for local route
Date: Wed, 20 Sep 2006 19:56:56 +0900
Message-ID: <45111E78.5090802@clustcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Kimitoshi Takahashi <ktaka@clustcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from i220-221-252-159.s30.a048.ap.plala.or.jp ([220.221.252.159]:24249
	"EHLO mail.m.clustcom.com") by vger.kernel.org with ESMTP
	id S1751091AbWITK47 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Sep 2006 06:56:59 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I have a question regarding the subject.
In the old threads it seemed to have concluded that ignoring preferred source in local route was a
bug and a pacth was proposed.

See,
http://marc.theaimsgroup.com/?l=linux-netdev&m=99985580920599&w=2

There, the following patch is proposed,
--- net/ipv4/route.c.x	Fri Sep  7 02:30:54 2001
+++ net/ipv4/route.c	Fri Sep  7 02:30:54 2001
@@ -1795,14 +1795,13 @@

 	if (res.type == RTN_LOCAL) {
 		if (!key.src)
-			key.src = key.dst;
+			key.src = res.fi->fib_prefsrc ? : key.dst;
 		if (dev_out)
 			dev_put(dev_out);
 		dev_out = &loopback_dev;
 		dev_hold(dev_out);
 		key.oif = dev_out->ifindex;
-		if (res.fi)
-			fib_info_put(res.fi);
+		fib_info_put(res.fi);
 		res.fi = NULL;
 		flags |= RTCF_LOCAL;
 		goto make_route;

However, in the relatively recent kernel (2.6.17.9) it seems that the patch hasn't been applied.

net/ipv4/route.c
   2508         if (res.type == RTN_LOCAL) {
   2509                 if (!fl.fl4_src)
   2510                         fl.fl4_src = fl.fl4_dst;
   2511                 if (dev_out)
   2512                         dev_put(dev_out);
   2513                 dev_out = &loopback_dev;
   2514                 dev_hold(dev_out);
   2515                 fl.oif = dev_out->ifindex;
   2516                 if (res.fi)
   2517                         fib_info_put(res.fi);
   2518                 res.fi = NULL;
   2519                 flags |= RTCF_LOCAL;
   2520                 goto make_route;
   2521         }

And actually the source IP of the comunication between two local interfaces is always that of
destination.

So the questions is why the patch hasn't been applied to the main line kernel, although deciding the
souce IP for local route based on routing table seemed more natural than makeing it IP of the
destination.


The actual problem I have is the following, (if you are interested,)
We have a nfs server whose IP address is shared among two hosts using vrrp and those two hosts also
act as nfs clients.

When the following host1 is a nfs server, the two hosts have following IPs.
host1  IP1, VRIP(nfs server's IP shared using vrrp)
host2  IP2

The nfs server and clients IP becomes as follows, because on host1 the source IP of nfs packet
becomes that of destination i.e. VRIP.
           nfs server IP   nfs client IP
on host1   VRIP            VRIP
on host2   VRIP            IP2

We also share the content of the rmtab which is something like
VRIP:/filesystem:0x00000001
IP2:/filesystem:0x00000001
(the first colummn is nfs client, the second is shared file system and the third column is the mount
count.)

When something happens to host1, the failover is triggered and the VRIP is moved to the host2,
host1  IP1
host2  IP2, VRIP(nfs server's IP shared using vrrp)

           nfs server IP   nfs client IP
on host1   VRIP            IP1
on host2   VRIP            VRIP

Accesses to the nfs mounted filesystem on host1 will be denied, if the content of the rmtab dosen't
change, because the nfs server on host2 thinks the clients are only VRIP and IP2.

Of course, it can be avoided, if we unmount and remount the files system on the client, or if we
appropriately change the content of the rmtab when the failover occurs.

However I think, it would be much nicer if the source IP of the client was always the primary IP of
a interface. This is realized if the source IP is determined by the preferred source in routing table.

Then the IPs of the nfs server and the clients are always like this, and this dosen't cause any
problem when the failover happens.
           nfs server IP   nfs client IP
on host1   VRIP            IP1
on host2   VRIP            IP2

Thanks in advance,
Kimitoshi Takahashi, Cluster Computing Inc., Japan

