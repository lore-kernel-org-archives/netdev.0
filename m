From: Julian Anastasov <ja@ssi.bg>
Subject: Re: routing bug report for 2.4
Date: Sun, 29 Jun 2003 10:28:18 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0306290930210.890-100000@u.domain.uli>
References: <3EFE131E.1080807@candelatech.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3EFE131E.1080807@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Sat, 28 Jun 2003, Ben Greear wrote:

> > - check for UP state (is it needed? return ENETDOWN?)
> > - check if target IP is local and select "lo" instead of oif

	First, here is what I mean (not compiled):

- ignore matching of the oif key for local destinations
- return ENETDOWN when the specified out_dev is down

	Dave, Alexey, can you judge on these issues because
they are not fatal corner cases and can be ignored.

--- v2.4.21/linux/net/ipv4/fib_semantics.c.orig	Sat Jun 14 08:42:55 2003
+++ v2.4.21/linux/net/ipv4/fib_semantics.c	Sun Jun 29 09:28:10 2003
@@ -603,7 +603,9 @@
 			for_nexthops(fi) {
 				if (nh->nh_flags&RTNH_F_DEAD)
 					continue;
-				if (!key->oif || key->oif == nh->nh_oif)
+				if (!key->oif ||
+				    key->oif == nh->nh_oif ||
+				    nh->nh_scope == RT_SCOPE_NOWHERE)
 					break;
 			}
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
--- v2.4.21/linux/net/ipv4/route.c.orig	Sat Jun 14 08:42:55 2003
+++ v2.4.21/linux/net/ipv4/route.c	Sun Jun 29 09:16:03 2003
@@ -1793,6 +1793,9 @@
 			dev_put(dev_out);
 			goto out;	/* Wrong error code */
 		}
+		err = -ENETDOWN;
+		if (!(dev_out->flags&IFF_UP))
+			goto out;

 		if (LOCAL_MCAST(oldkey->dst) || oldkey->dst == 0xFFFFFFFF) {
 			if (!key.src)

> Well, why should it try to route locally in this case (I'm assuming that
> by using 'lo' it will not try to send on the external link)

	No, it does not use "lo", "lo" replaces "dev" only if we get
RTN_LOCAL result. But "to local_IP dev different_device"
can escape from our host because we can not find route and thus we
can not override out_dev with lo.

> Why not instead make it send to the router for that source-ip, if it is
> configured.  If it is not configured, then I think arping is the best that

	What we have is that app uses BINDTODEVICE to send
packet with saddr=some_IP daddr=any_valid_local_IP. This is
confusing but I do not see any harm. But I think route request
"to local_IP" deserves "lo" result no matter the oif key.

> can be expected, as the behaviour becomes quite undefined and we really
> have 'no route to host'.

	The only reason can be to avoid confusions and to
make it symmetric with the source validation check. And yes,
this patch breaks your tests.

> My send-to-self patch that I have been using is attached.  I also have some other
> patches for mac-vlans and packet-gen applied, but I don't believe these will have any
> impact on the behaviour we have been discussing.

	I don't see anything in your patch that can disturb these
tests. The kernel is helpful enough to send your ARP probe for
local_IP on the LAN :) When I tested the first time, you claimed
-I local_IP1 local_IP2 causes the problem but as we see, it is
caused from -I dev

> Thanks,
> Ben

Regards

--
Julian Anastasov <ja@ssi.bg>
