From: Per Cederqvist <ceder@ingate.com>
Subject: PROBLEM: ICMP redirect that violates RFC 1812 is sent
Date: 22 Jul 2004 17:00:42 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <x3u0w0xf1h.fsf@plebeian.ingate.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[1.] One line summary of the problem:    

ICMP redirect that violates RFC 1812 is sent

[2.] Full description of the problem/report:

RFC 1812, "Requirements for IP Version 4 Routers", states when ICMP
redirects should be sent (quoted from "5.2.7.2 Redirect"):

>    Routers MUST NOT generate a Redirect Message unless all the following
>    conditions are met:
> 
>    o The packet is being forwarded out the same physical interface that
>       it was received from,
> 
>    o The IP source address in the packet is on the same Logical IP
>       (sub)network as the next-hop IP address, and
> 
>    o The packet does not contain an IP source route option.

Linux 2.4.27 fails to check the middle condition.  I've looked at the
source code of Linux 2.6.7, and the problem seems to still be there.

There are two problems:

Problem 1 (less important): bad default value of shared_media

The default value of /proc/sys/net/ipv4/conf/*/shared_media is TRUE.
It should be FALSE for RFC 1812 compliance.  When it is TRUE, the
middle condition is intentionally not checked.

There may be later standards work that I'm not aware of that makes
this a valid default.  I've tried to locate such work, but failed.
RFC 1620 ("Internet Architecture Extensions for Shared Media")
suggests that this change could be made, but it is just an
informational RFC.

Problem 2 (more important): bug in route.c

Even when shared_media is FALSE, the middle condition fails, due to a
bug in route.c.  Consider this code:

	if (out_dev == in_dev && err && !(flags & (RTCF_NAT | RTCF_MASQ)) &&
	    (IN_DEV_SHARED_MEDIA(out_dev) ||
	     inet_addr_onlink(out_dev, saddr, FIB_RES_GW(res))))
		flags |= RTCF_DOREDIRECT;

If the next-hop IP address is on a different logical IP network, but
it still is on a network that is directly connected to the Linux box,
FIB_RES_GW(res) will return 0.  inet_addr_onlink() will always return
true in that case.  This means that RTFC_DOREDIRECT will be set, and
a standards-violating ICMP Redirect will be sent.

The enclosed patch changes the final argument of inet_addr_onlink()
to:

    FIB_RES_GW(res) ? FIB_RES_GW(res) : daddr

[3.] Keywords (i.e., modules, networking, kernel):

networking, icmp, redirect, non-compliant, RFC 1812

[4.] Kernel version (from /proc/version):

2.4.27.  Problem initially found on 2.4.26.
http://seclists.org/lists/linux-kernel/2000/Oct/0923.html indicates
that this bug was present in 2.2.17 as well.  Inspection of the 2.6.7
kernel indicates that it isn't fixed there either.

[5.] Output of Oops.. message (if applicable) with symbolic information 
     resolved (see Documentation/oops-tracing.txt)
[6.] A small shell script or example program which triggers the
     problem (if possible)

To trigger this, you need two linux boxes.  On the box acting as
router (it only needs one ethernet interface), do:

    ifconfig eth0 down
    ifconfig eth0 192.168.10.1 netmask 255.255.255.0
    ifconfig eth0:1 192.168.99.1 netmask 255.255.255.0
    echo 1 > /proc/sys/net/ipv4/ip_forward
    for f in /proc/sys/net/ipv4/conf/*/shared_media
    do
        echo 0 > $f
    done

On the other box, start a sniffer such as ethereal, and do:

    ifconfig eth0 down
    ifconfig eth0 192.168.10.2 netmask 255.255.255.0
    ping 192.168.99.2

You will see ICMP redirect packets similar to these:

> Frame 257 (242 bytes on wire, 242 bytes captured)
> Ethernet II, Src: 00:20:fc:1e:cc:c4, Dst: 00:03:e3:11:f4:31
> Internet Protocol, Src Addr: 192.168.10.1 (192.168.10.1), Dst Addr: 192.168.10.2 (192.168.10.2)
> Internet Control Message Protocol
>     Type: 5 (Redirect)
>     Code: 1 (Redirect for host)
>     Checksum: 0x252b (correct)
>     Gateway address: 192.168.99.2 (192.168.99.2)
>     [...]

[X.] Other notes, patches, fixes, workarounds:

Acknowledgement: Mario Lorenz (ml_at_vdazone.org) reported this
problem back in 2000, with a patch.  However, unfortunately apparently
nobody believed him.  See
http://seclists.org/lists/linux-kernel/2000/Oct/0923.html.

I've taken his patch, updated it for 2.4.17, and tested it.  As far as
I can tell, it works.  Here is the patch:

# This patch fixes a bug that caused Linux to send ICMP redirect
# when hosts on two directly connected networks attempted to talk
# to each other.  In that case, FIB_RES_GW(res) will be 0.0.0.0, and
# inet_addr_onlink will always return true.
#
# The patch was originally found on
# http://seclists.org/lists/linux-kernel/2000/Oct/0923.html and is
# written by Mario Lorenz (ml_at_vdazone.org) for Linux 2.2.17.  It
# was updated for Linux 2.4.27 by ceder@ingate.com on 2004-07-21.
#
--- linux-2.4.27/net/ipv4/route.c.orig	Fri Oct  6 13:41:50 2000
+++ linux-2.4.27/net/ipv4/route.c	Fri Oct  6 15:12:25 2000
@@ -1524,7 +1524,8 @@
 
 	if (out_dev == in_dev && err && !(flags & (RTCF_NAT | RTCF_MASQ)) &&
 	    (IN_DEV_SHARED_MEDIA(out_dev) ||
-	     inet_addr_onlink(out_dev, saddr, FIB_RES_GW(res))))
+	     inet_addr_onlink(out_dev, saddr, 
+				 FIB_RES_GW(res) ? FIB_RES_GW(res) : daddr)))
 		flags |= RTCF_DOREDIRECT;
 
 	if (skb->protocol != htons(ETH_P_IP)) {



Yours,
    /ceder
-- 
Per Cederqvist <ceder@ingate.com>, Chief Architect, Ingate Systems AB
