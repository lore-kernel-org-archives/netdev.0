From: Teco Boot <teco@inf-net.nl>
Subject: IPv6 subtrees bug report: source prefix cached, should be source address only
Date: Thu, 7 Nov 2013 16:51:40 -0800
Message-ID: <91F83ACD-AA02-4A10-B6B0-9545B7EEC324@inf-net.nl>
Mime-Version: 1.0 (Mac OS X Mail 7.0 \(1816\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f43.google.com ([209.85.214.43]:36844 "EHLO
	mail-bk0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754042Ab3KHAvq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 19:51:46 -0500
Received: by mail-bk0-f43.google.com with SMTP id mz13so523487bkb.30
        for <netdev@vger.kernel.org>; Thu, 07 Nov 2013 16:51:44 -0800 (PST)
Received: from dhcp-a43c.meeting.ietf.org (dhcp-a43c.meeting.ietf.org. [31.133.164.60])
        by mx.google.com with ESMTPSA id qg7sm3984866bkb.6.2013.11.07.16.51.42
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 07 Nov 2013 16:51:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For IPv6 source address dependent routing, FIB lookup is based on longest match destination address and as second step longest match source address. Results are stored in the cache. The cache entry has a *source prefix* stored, this should be a *source address*.

Below a test script and results. Two tests are performed, each on same routing table. Second test is same as first one, but lookups are in reverse order. Outcome of the test differs, this is wrong.

Suggested solution: do not store source prefix in route cache, but store the source address. Site effect would be increased cache size, but this is necessary. 

Teco


teco@ubuntu:~$ sudo ./ipv6-sadr.sh 
===> This is my system:
Linux ubuntu 3.11.0-12-generic #19-Ubuntu SMP Wed Oct 9 16:12:00 UTC 2013 i686 i686 i686 GNU/Linux
CONFIG_IPV6_SUBTREES=y
... clean up for our experiment
... add a link-local
... add some source address specific defaults
====> Now I have this routing table
2001:db8:3::/48 from 2001:db8:2:99::/64 via fe80::99 dev eth0  metric 1024 
2001:db8:3::/48 from 2001:db8:2::/48 via fe80::20 dev eth0  metric 1024 
2001:db8:3:3::/64 from 2001:db8:1::/48 via fe80::10 dev eth0  metric 1024 
fe80::1 dev eth0  proto kernel  metric 256 
====> Create cache entries, longest match first, result looks OK2001:db8:3:3::1 from 2001:db8:2:99::1 via fe80::99 dev eth0  src ::1  metric 0 \    cache 
2001:db8:3:3::1 from 2001:db8:2::1 via fe80::20 dev eth0  src ::1  metric 0 \    cache 
===> Now the route cache has two entries
===>
2001:db8:3:3::1 from 2001:db8:2:99::/64 via fe80::99 dev eth0  metric 0 \    cache 
2001:db8:3:3::1 from 2001:db8:2::/48 via fe80::20 dev eth0  metric 0 \    cache 
===>
... clean up for our experiment
... add a link-local
... add some source address specific defaults
====> Now I have this routing table
2001:db8:3::/48 from 2001:db8:2:99::/64 via fe80::99 dev eth0  metric 1024 
2001:db8:3::/48 from 2001:db8:2::/48 via fe80::20 dev eth0  metric 1024 
2001:db8:3:3::/64 from 2001:db8:1::/48 via fe80::10 dev eth0  metric 1024 
fe80::1 dev eth0  proto kernel  metric 256 
====> Create cache entries, longest match later on, result looks OK2001:db8:3:3::1 from 2001:db8:2::1 via fe80::20 dev eth0  src ::1  metric 0 \    cache 
2001:db8:3:3::1 from 2001:db8:2:99::1 via fe80::20 dev eth0  src ::1  metric 0 \    cache 
===> Now the route cache has only one entry
===>
2001:db8:3:3::1 from 2001:db8:2::/48 via fe80::20 dev eth0  metric 0 \    cache 
===>
... clean up for our experiment
... add a link-local



teco@ubuntu:~$ cat ipv6-sadr.sh 
#!/bin/bash

function ShowSystem {
 echo "===> This is my system:" 
 uname -a
 grep IPV6_SUBTREES /boot/config-`uname -r`
}

function ClearRouting {
 echo "... clean up for our experiment"
 ip -6 address flush dev eth0
 ip -6 route flush table all
 echo "... add a link-local"
 ip address add fe80::1 dev eth0
}

function SetupRouting {
 echo "... add some source address specific defaults"
 # from draft-baker-ipv6-ospf-dst-src-routing-03
 # 1.  2001:db8:1::/48 -> 2001:db8:3:3::/64
 ip -6 route add 2001:db8:3:3::/64 from 2001:db8:1::/48 via fe80::10 dev eth0
 # 2.  2001:db8:2::/48 -> 2001:db8:3::/48
 ip -6 route add 2001:db8:3::/48 from 2001:db8:2::/48 via fe80::20 dev eth0
 # add another route, for hitting wrong cache entry
 ip -6 route add 2001:db8:3::/48 from 2001:db8:2:99::/64 via fe80::99 dev eth0
 echo "====> Now I have this routing table"
 ip -6 -o route show table main
}

ShowSystem
ClearRouting
SetupRouting

echo -n "====> Create cache entries, longest match first, result looks OK"
ip -6 -o route get 2001:db8:3:3::1  from 2001:db8:2:99::1
ip -6 -o route get 2001:db8:3:3::1  from 2001:db8:2::1
echo "===> Now the route cache has two entries"
echo "===>"
ip -6 -o route show cache
echo "===>"

ClearRouting
SetupRouting

echo -n "====> Create cache entries, longest match later on, result looks OK"
ip -6 -o route get 2001:db8:3:3::1  from 2001:db8:2::1
ip -6 -o route get 2001:db8:3:3::1  from 2001:db8:2:99::1
echo "===> Now the route cache has only one entry"
echo "===>"
ip -6 -o route show cache
echo "===>"

ClearRouting
