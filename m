From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Fw: [Bug 43327] New: IP routing: cached route is applied to wrong
 network interface
Date: Thu, 31 May 2012 17:46:41 -0700
Message-ID: <20120531174641.2809b5c4@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44873 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932859Ab2FAAqs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 May 2012 20:46:48 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.vyatta.com (Postfix) with ESMTP id F3C3814105BE
	for <netdev@vger.kernel.org>; Thu, 31 May 2012 17:46:44 -0700 (PDT)
Received: from mail.vyatta.com ([127.0.0.1])
	by localhost (mail.vyatta.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id j4EXaE-3noZO for <netdev@vger.kernel.org>;
	Thu, 31 May 2012 17:46:43 -0700 (PDT)
Received: from nehalam.linuxnetplumber.net (static-50-53-80-93.bvtn.or.frontiernet.net [50.53.80.93])
	by mail.vyatta.com (Postfix) with ESMTPSA id 7719214103FB
	for <netdev@vger.kernel.org>; Thu, 31 May 2012 17:46:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Fri,  1 Jun 2012 00:18:37 +0000 (UTC)
From: bugzilla-daemon@bugzilla.kernel.org
To: shemminger@linux-foundation.org
Subject: [Bug 43327] New: IP routing: cached route is applied to wrong network interface


https://bugzilla.kernel.org/show_bug.cgi?id=43327

           Summary: IP routing: cached route is applied to wrong network
                    interface
           Product: Networking
           Version: 2.5
    Kernel Version: 3.1.10
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: dschnabel@appneta.com
        Regression: No


IP routing: cached route is applied to wrong network interface


Dynamic route changes like ICMP redirects are cached in the cache routing table
of the kernel. This cache table can be displayed using the command "route -nC"
or "ip route show cache".
Routes in this table are used before checking the Routing Policy Database
(RPDB). In a certain use case a wrong route entry is created in the cache
table.

This is my network setup:
* the Linux machine has 2 network interfaces (eth0 and eth1) with IP adresses
of different subnets
** eth0: 172.16.124.217/24 (Subnet A)
** eth1: 172.16.128.219/24 (Subnet B)
* IP rules to accomplish two default gateways
** root@myBox:~# ip rule show
0:      from all lookup local
32764:  from 172.16.128.219 lookup E1
32765:  from 172.16.124.217 lookup E0
32766:  from all lookup main
32767:  from all lookup default
** root@myBox:~# ip route show table E0
default via 172.16.124.254 dev eth0
** root@myBox:~# ip route show table E1
default via 172.16.128.254 dev eth1
* Both gateways are connected to Subnet C

This is how it looks like:

    ************                                                               
   #      ************
    * Subnet A *                                                               
   #      * Subnet C *
    ************             +-------------------+      +-------------------+  
   #      ************
                             |                   |      |                   |  
   #
         +-------------------+ GW 172.16.124.254 +------+ GW 172.16.124.18 
+------#---------------+
         | 172.16.124.217    |                   |      |                   |  
   #               |
  +------+--------+          +-------------------+      +---------+---------+  
   #               |
  |     eth0      |                                               |            
   #      +--------+----------+
  |               |                                               |            
   #      |      Target       |
  | Linux Machine |                                      ##################    
   #      |   IP 10.20.2.252  |
  |               |                                               |            
   #      +--------+----------+
  |     eth1      |                                               |            
   #
  +------+--------+          +-------------------+                |            
   #
         | 172.16.128.219    |                   |                |            
   #
         +-------------------+ GW 172.16.128.254 +----------------+            
   #
                             |                   |                             
   #
    ************             +-------------------+                             
   #
    * Subnet B *                                                               
   #
    ************                                                               
   #



I can ping the target from both interfaces:
ping 10.20.2.252 -I 172.16.124.217
ping 10.20.2.252 -I 172.16.128.219

When pining from eth0 (172.16.124.217) the Gateway 172.16.124.254 will return a
redirect to Gateway 172.16.124.18 since it's in the same network:
root@myBox:~# ping 10.20.2.252 -I 172.16.124.217
PING 10.20.2.252 (10.20.2.252) from 172.16.124.217 : 56(84) bytes of data.
64 bytes from 10.20.2.252: icmp_seq=1 ttl=63 time=81.4 ms
>From 172.16.124.254: icmp_seq=1 Redirect Host(New nexthop: 172.16.124.18)
64 bytes from 10.20.2.252: icmp_seq=2 ttl=63 time=0.277 ms
64 bytes from 10.20.2.252: icmp_seq=3 ttl=63 time=0.238 ms
64 bytes from 10.20.2.252: icmp_seq=4 ttl=63 time=0.236 ms

And this redirect will create a new entry in the cache table:
root@myBox:~# route -nC | grep 172.16.124.18
172.16.124.217  10.20.2.252     172.16.124.18         0      0        2 eth0

So far so good. Here comes the problem.

When I ping the same target now from eth1 (172.16.128.219) then it won't work
anymore:
root@myBox:~# ping 10.20.2.252 -I 172.16.128.219
PING 10.20.2.252 (10.20.2.252) from 172.16.128.219 : 56(84) bytes of data.
>From 172.16.128.219 icmp_seq=2 Destination Host Unreachable
>From 172.16.128.219 icmp_seq=3 Destination Host Unreachable
>From 172.16.128.219 icmp_seq=4 Destination Host Unreachable
^C
--- 10.20.2.252 ping statistics ---
4 packets transmitted, 0 received, +3 errors, 100% packet loss, time 2999ms

I check the cache table and notice another entry:
root@portwell19:~# route -nC | grep 172.16.124.18
172.16.124.217  10.20.2.252     172.16.124.18         0      0        2 eth0
172.16.128.219  10.20.2.252     172.16.124.18         0      0        7 eth1

That means eth1 is now trying to reach 10.20.2.252 using the gateway
172.16.124.18. It's obvious that this won't work since eth1 is in a different
subnet.
So the entry in the cache table is wrong. After clearing the cache with "ip
route flush table cache" the ping from eth1 works again.

I did some research:
The cache routing table works on an AVL tree of Internet Peers. Those peers are
stored in a structure called inet_peer (include/net/inetpeer.h). A lookup is
done by the call to inet_getpeer_v4() in net/ipv4/route.c which takes the
destination address (10.20.2.252 in my case) as the first argument. So if the
destination address matches then the peer is returned and saved to the cache
table regardless of the source address.

Two possible fixes I can think of:
* A peer lookup should be done not only by the destination address but also by
the source address (or netmask)
* The inet_peer structure should contain a field for the source address (or
netmask). Then after lookup via inet_getpeer_v4() check the source address (or
netmask) of the returned peer.

-- 
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.
