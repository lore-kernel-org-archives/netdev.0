From: Teco Boot <teco@inf-net.nl>
Subject: Linux IPV6_SUBTREES not functioning
Date: Fri, 2 Aug 2013 12:15:03 +0200
Message-ID: <8CBF8819-E1D9-445E-9E7C-793422934733@inf-net.nl>
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: boutier@pps.univ-paris-diderot.fr
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:38538 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030594Ab3HBKPI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 06:15:08 -0400
Received: by mail-pd0-f179.google.com with SMTP id v10so509029pde.10
        for <netdev@vger.kernel.org>; Fri, 02 Aug 2013 03:15:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For destination & source address routing, I prefer the single routing table approach with IPV6_SUBTREES over the multiple tables with ip rules approach.
Can some take a look at my findings? It looks broken. It seems the source address check in route cache is missing.

Teco


Output:
==========
this is my system:
Linux ubuntu 3.8.0-25-generic #37-Ubuntu SMP Thu Jun 6 20:47:30 UTC 2013 i686 i686 i686 GNU/Linux
CONFIG_IPV6_SUBTREES=y
... clean up for our experiment
... add a link-local
... add default
... add some source address specific defaults
====> now I have this routing table
default from 2001:db8:10::/48 via fe80::10 dev eth0  metric 1024 
default from 2001:db8:11::/48 via fe80::11 dev eth0  metric 1024 
default from 2001:db8:12::/48 via fe80::12 dev eth0  metric 1024 
fe80::1 dev eth0  proto kernel  metric 256 
default via fe80::ff dev eth0  metric 1024 
====> show route to same destination
2001:db8:babe::1 from 2001:db8:10::1 via fe80::10 dev eth0  metric 0 \    cache 
2001:db8:babe::1 from 2001:db8:11::1 via fe80::ff dev eth0  metric 0 \    cache 
2001:db8:babe::1 from 2001:db8:12::1 via fe80::ff dev eth0  metric 0 \    cache 
2001:db8:babe::1 from 2001:db8:1::1 via fe80::ff dev eth0  metric 0 \    cache 
2001:db8:babe::1 from :: via fe80::ff dev eth0  metric 0 \    cache 
====> show route to different destinations
2001:db8:cafe::10 from 2001:db8:10::1 via fe80::10 dev eth0  metric 0 \    cache 
2001:db8:cafe::11 from 2001:db8:11::1 via fe80::11 dev eth0  metric 0 \    cache 
2001:db8:cafe::12 from 2001:db8:12::1 via fe80::12 dev eth0  metric 0 \    cache 
2001:db8:cafe::21 from 2001:db8:1::1 via fe80::ff dev eth0  metric 0 \    cache 
2001:db8:cafe::22 from :: via fe80::ff dev eth0  metric 0 \    cache 
====> now the route cache is
2001:db8:babe::1 from 2001:db8:10::/48 via fe80::10 dev eth0  metric 0 \    cache 
2001:db8:babe::1 via fe80::ff dev eth0  metric 0 \    cache 
2001:db8:cafe::10 from 2001:db8:10::/48 via fe80::10 dev eth0  metric 0 \    cache 
2001:db8:cafe::11 from 2001:db8:11::/48 via fe80::11 dev eth0  metric 0 \    cache 
2001:db8:cafe::12 from 2001:db8:12::/48 via fe80::12 dev eth0  metric 0 \    cache 
2001:db8:cafe::21 via fe80::ff dev eth0  metric 0 \    cache 
2001:db8:cafe::22 via fe80::ff dev eth0  metric 0 \    cache 
 


My script:
=======
#!/bin/sh

echo "this is my system:" 
uname -a
grep IPV6_SUBTREES /boot/config-3.8.0-25-generic

echo ... clean up for our experiment
ip -6 address flush dev eth0
ip -6 route flush table all

echo ... add a link-local
ip address add fe80::1 dev eth0

echo ... add default
ip -6 route add default via fe80::ff dev eth0

echo ... add some source address specific defaults
ip -6 route add default from 2001:db8:10::/48 via fe80::10 dev eth0
ip -6 route add default from 2001:db8:11::/48 via fe80::11 dev eth0
ip -6 route add default from 2001:db8:12::/48 via fe80::12 dev eth0

echo -n "====> "
echo now I have this routing table
ip -6 -o route show table main

echo -n "====> "
echo show route to same destination
ip -6 -o route get 2001:db8:babe::1 from 2001:db8:10::1
ip -6 -o route get 2001:db8:babe::1 from 2001:db8:11::1
ip -6 -o route get 2001:db8:babe::1 from 2001:db8:12::1
ip -6 -o route get 2001:db8:babe::1 from 2001:db8:1::1
ip -6 -o route get 2001:db8:babe::1

echo -n "====> "
echo show route to different destinations
ip -6 -o route get 2001:db8:cafe::10 from 2001:db8:10::1
ip -6 -o route get 2001:db8:cafe::11 from 2001:db8:11::1
ip -6 -o route get 2001:db8:cafe::12 from 2001:db8:12::1
ip -6 -o route get 2001:db8:cafe::21 from 2001:db8:1::1
ip -6 -o route get 2001:db8:cafe::22
echo -n "====> "
echo now the route cache is
ip -6 -o route show cache
