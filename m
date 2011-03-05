From: ebiederm@xmission.com (Eric W. Biederman)
Subject: FYI: tftp-hpa breaks when used on secondary ip addresses
Date: Fri, 04 Mar 2011 16:58:55 -0800
Message-ID: <m1sjv2qt68.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joel Sing <jsing@google.com>, David Miller <davem@davemloft.net>
To: "H. Peter Anvin" <hpa@zytor.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:46571 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760039Ab1CEA7B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2011 19:59:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


tftp-hpa has code to test to see if the address it received a connection
on is a local address.  I don't have a clue why tftp-hpa doesn't trust
the kernel but the code looks like:

static int address_is_local(const struct sockaddr_in *addr)
{
        struct sokcaddr sa;
        int sockfd = -1;
        sockfd = socket(AF_INET, SOCK_DGRAM, 0);
        connect(sockfd, (struct sockaddr *)&addr, sizeof(*addr));
        getsockname(sockfd, (struct sockaddr *)&sa, sizeof(sa));
        return sa.sin_addr.s_addr == addr->sin_addr.s_addr;
}

Which if fails now if you happen to be running tftp-hpa on a secondary
ip address on the same subnet as your first ip.  Because pref_source
in the routing table points at the first ip.

The change in kernel behavior appears to be from the commit below to
honor the preferred source address in local connections.

This all seems very fuzzy to me and mostly this appears to be a bug in
tftp-hpa but since I tracked it down I figured I would let everyone
know what happened.

Eric



commit 9fc3bbb4a752f108cf096d96640f3b548bbbce6c
Author: Joel Sing <jsing@google.com>
Date:   Mon Jan 3 20:24:20 2011 +0000

    ipv4/route.c: respect prefsrc for local routes
    
    The preferred source address is currently ignored for local routes,
    which results in all local connections having a src address that is the
    same as the local dst address. Fix this by respecting the preferred source
    address when it is provided for local routes.
    
    This bug can be demonstrated as follows:
    
     # ifconfig dummy0 192.168.0.1
     # ip route show table local | grep local.*dummy0
     local 192.168.0.1 dev dummy0  proto kernel  scope host  src
     # 192.168.0.1
     # ip route change table local local 192.168.0.1 dev dummy0 \
         proto kernel scope host src 127.0.0.1
     # ip route show table local | grep local.*dummy0
     local 192.168.0.1 dev dummy0  proto kernel  scope host  src
     # 127.0.0.1
    
    We now establish a local connection and verify the source IP
    address selection:
    
     # nc -l 192.168.0.1 3128 &
     # nc 192.168.0.1 3128 &
     # netstat -ant | grep 192.168.0.1:3128.*EST
     tcp        0      0 192.168.0.1:3128        192.168.0.1:33228
     # ESTABLISHED
     tcp        0      0 192.168.0.1:33228       192.168.0.1:3128
     # ESTABLISHED
    
    Signed-off-by: Joel Sing <jsing@google.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index df948b0..93bfd95 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2649,8 +2649,12 @@ static int ip_route_output_slow(struct net *net,
struct rtable **rp,
        }
 
        if (res.type == RTN_LOCAL) {
-               if (!fl.fl4_src)
-                       fl.fl4_src = fl.fl4_dst;
+               if (!fl.fl4_src) {
+                       if (res.fi->fib_prefsrc)
+                               fl.fl4_src = res.fi->fib_prefsrc;
+                       else
+                               fl.fl4_src = fl.fl4_dst;
+               }
                dev_out = net->loopback_dev;
                fl.oif = dev_out->ifindex;
                res.fi = NULL;

