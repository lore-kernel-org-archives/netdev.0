From: David Ahern <dsa@cumulusnetworks.com>
Subject: local route left hanging around in wrong table
Date: Wed, 9 Dec 2015 16:32:07 -0700
Message-ID: <5668B9F7.4010400@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:34856 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750907AbbLIXcK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 18:32:10 -0500
Received: by obc18 with SMTP id 18so46360189obc.2
        for <netdev@vger.kernel.org>; Wed, 09 Dec 2015 15:32:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The VRF driver cycles netdevs (down then up) when an interface is 
enslaved or released -- the down event is used to flush neighbor and 
route tables and the up event effectively moves local and connected 
routes to the proper table.

As of 4f823defdd5b ("ipv4: fix to not remove local route on link down") 
the local route is left hanging around after a link down and when a 
netdev is moved from one VRF to another (or released altogether) the 
local route is in the wrong table:

root@kenny:~# ip link set dev eth1 master vrf-red

At this point all routes associated with eth1 should be in the vrf-red 
table. Yet:

root@kenny:~# ip ro ls table local | grep eth1
local 10.100.1.2 dev eth1  proto kernel  scope host  src 10.100.1.2


And it is in the vrf table as well:

root@kenny:~# ip ro ls table vrf-red
unreachable default
broadcast 10.100.1.0 dev eth1  proto kernel  scope link  src 10.100.1.2
10.100.1.0/24 dev eth1  proto kernel  scope link  src 10.100.1.2
local 10.100.1.2 dev eth1  proto kernel  scope host  src 10.100.1.2
broadcast 10.100.1.255 dev eth1  proto kernel  scope link  src 10.100.1.2

Unenslaving the device leaves the local route in the VRF table:

root@kenny:~# ip link set dev eth1 nomaster

root@kenny:~# ip ro ls table vrf-red
unreachable default
local 10.100.1.2 dev eth1  proto kernel  scope host  src 10.100.1.2


I realize Julian's patch was fixing a 'bug' introduced in June, so most 
likely can't do a revert of it. I am looking at a standalone notifier 
(e.g., NETDEV_VRF_CHANGE), but that patch seems a bit large for v4.4.

At this point I don't see a simple solution to fix this for v4.4 hence 
this email -- any thoughts? To be clear this is the change that causes 
the problem:

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index d97268e8ff10..1801519da446 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -1365,7 +1365,8 @@ int fib_sync_down_dev(struct net_device *dev, 
unsigned long event, bool force)
         struct hlist_head *head = &fib_info_devhash[hash];
         struct fib_nh *nh;

-       if (force)
+       if (event == NETDEV_UNREGISTER ||
+           event == NETDEV_DOWN)
                 scope = -1;

         hlist_for_each_entry(nh, head, nh_hash) {


David
