From: Marc Haber <mh+linux-kernel@zugschlus.de>
Subject: Linux 3.2 and 3.3 not doing IPv6 ND when it should
Date: Sun, 25 Mar 2012 09:39:31 +0200
Message-ID: <20120325073931.GA12998@torres.zugschlus.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from torres.zugschlus.de ([85.214.131.164]:59238 "EHLO
	torres.zugschlus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752641Ab2CYHjd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Mar 2012 03:39:33 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

it's me again. I have nailed down my issue a little more. First, I now
see the issue happening with Linux 3.2.9 as well. Unfortunately, it is
still only a single box; the two other Linux hosts that have a
similiar setup (with native IPv6 on an Ethernet interface) are working
flawlessly.

To me, this looks like the ND entry for the default gateway expires
from the neighbour table and Linux doesn't bother to do a new Neighbor
Discovery, but allows the STALE neighbour entry to remain in the
table. Eventually, it feels like doing ND again and everything is fine.

In a packet dump (sorry for the long lines), this looks like 

No.     Time            Source                			Destination 			    Packet length Protocol Info
		    
   2937 15:48:39.725721 2001:db8:1320:0:718f:6a5a:5b60:5632 	2001:db8:40b7:9102::200:100 	    118           ICMPv6   Echo (ping) request id=0x2887, seq=263
   2938 15:48:39.725870 2001:db8:40b7:9102::200:100 		2001:db8:1320:0:718f:6a5a:5b60:5632 118           ICMPv6   Echo (ping) reply id=0x2887, seq=263
   2975 15:48:40.641202 2001:db8:1320:0:718f:6a5a:5b60:5632 	2001:db8:40b7:9101::1 		    118           ICMPv6   Echo (ping) request id=0x2887, seq=271
   2976 15:48:40.641302 2001:db8:40b7:9101::1 			2001:db8:1320:0:718f:6a5a:5b60:5632 118           ICMPv6   Echo (ping) reply id=0x2887, seq=271
   2982 15:48:40.703167 2001:db8:1320:0:718f:6a5a:5b60:5632 	2001:db8:40b7:9100::100:100 	    118           ICMPv6   Echo (ping) request id=0x2887, seq=275
   2983 15:48:40.703184 2001:db8:40b7:9100::100:100 		2001:db8:1320:0:718f:6a5a:5b60:5632 118           ICMPv6   Echo (ping) reply id=0x2887, seq=275
   2984 15:48:40.727155 2001:db8:1320:0:718f:6a5a:5b60:5632 	2001:db8:40b7:9102::200:100 	    118           ICMPv6   Echo (ping) request id=0x2887, seq=277
   2985 15:48:40.727284 2001:db8:40b7:9102::200:100 		2001:db8:1320:0:718f:6a5a:5b60:5632 118           ICMPv6   Echo (ping) reply id=0x2887, seq=277
   3006 15:48:40.944032 2001:db8:4071:3202::1f 			2001:db8:40b7:9102::200:100 	    130           ICMPv6   Echo (ping) request id=0x1932, seq=0
   3007 15:48:40.944114 2001:db8:40b7:9102::200:100 		2001:db8:4071:3202::1f 	    	    130           ICMPv6   Echo (ping) reply id=0x1932, seq=0
   3008 15:48:40.974015 2001:db8:4071:3202::1f 			2001:db8:40b7:9101::1 	    	    130           ICMPv6   Echo (ping) request id=0x1932, seq=1
   3009 15:48:40.974091 2001:db8:40b7:9101::1  			2001:db8:4071:3202::1f 	    	    130           ICMPv6   Echo (ping) reply id=0x1932, seq=1
   3010 15:48:41.000000 2001:db8:4071:3202::1f 			2001:db8:40b7:9100::100:100 	    130           ICMPv6   Echo (ping) request id=0x1932, seq=2
   3011 15:48:41.000009 2001:db8:40b7:9100::100:100 		2001:db8:4071:3202::1f 	    	    130           ICMPv6   Echo (ping) reply id=0x1932, seq=2
   3035 15:48:43.085816 2001:db8:4071:3202::1f 			2001:db8:40b7:9102::200:100 	    130           ICMPv6   Echo (ping) request id=0x1936, seq=0
   3036 15:48:43.085890 2001:db8:40b7:9102::200:100 		2001:db8:4071:3202::1f 	    	    130           ICMPv6   Echo (ping) reply id=0x1936, seq=0
   3037 15:48:43.115797 2001:db8:4071:3202::1f 			2001:db8:40b7:9101::1 	    	    130           ICMPv6   Echo (ping) request id=0x1936, seq=1
   3038 15:48:43.115901 2001:db8:40b7:9101::1 			2001:db8:4071:3202::1f 	    	    130           ICMPv6   Echo (ping) reply id=0x1936, seq=1
   3039 15:48:43.148781 2001:db8:4071:3202::1f 			2001:db8:40b7:9100::100:100 	    130           ICMPv6   Echo (ping) request id=0x1936, seq=2
   3040 15:48:43.148792 2001:db8:40b7:9100::100:100 		2001:db8:4071:3202::1f 	    	    130           ICMPv6   Echo (ping) reply id=0x1936, seq=2
   3062 15:48:45.232600 2001:db8:4071:3202::1f 			2001:db8:40b7:9102::200:100 	    130           ICMPv6   Echo (ping) request id=0x193a, seq=0
   3063 15:48:45.269577 2001:db8:4071:3202::1f 			2001:db8:40b7:9101::1 	    	    130           ICMPv6   Echo (ping) request id=0x193a, seq=1
   3064 15:48:45.297561 2001:db8:4071:3202::1f 			2001:db8:40b7:9100::100:100 	    130           ICMPv6   Echo (ping) request id=0x193a, seq=2
   3080 15:48:47.378381 2001:db8:4071:3202::1f 			2001:db8:40b7:9102::200:100 	    130           ICMPv6   Echo (ping) request id=0x193e, seq=0
   3081 15:48:47.409363 2001:db8:4071:3202::1f 			2001:db8:40b7:9101::1 	    	    130           ICMPv6   Echo (ping) request id=0x193e, seq=1
   3082 15:48:47.439346 2001:db8:4071:3202::1f 			2001:db8:40b7:9100::100:100 	    130           ICMPv6   Echo (ping) request id=0x193e, seq=2
   3098 15:48:49.528161 2001:db8:4071:3202::1f 			2001:db8:40b7:9102::200:100 	    130           ICMPv6   Echo (ping) request id=0x1942, seq=0
   3099 15:48:49.559143 2001:db8:4071:3202::1f 			2001:db8:40b7:9101::1 	    	    130           ICMPv6   Echo (ping) request id=0x1942, seq=1
   3100 15:48:49.589126 2001:db8:4071:3202::1f 			2001:db8:40b7:9100::100:100 	    130           ICMPv6   Echo (ping) request id=0x1942, seq=2
   3118 15:48:51.678941 2001:db8:4071:3202::1f 			2001:db8:40b7:9102::200:100 	    130           ICMPv6   Echo (ping) request id=0x1946, seq=0
   3119 15:48:51.709923 2001:db8:4071:3202::1f 			2001:db8:40b7:9101::1 	    	    130           ICMPv6   Echo (ping) request id=0x1946, seq=1
   3120 15:48:51.739905 2001:db8:4071:3202::1f 			2001:db8:40b7:9100::100:100 	    130           ICMPv6   Echo (ping) request id=0x1946, seq=2
<snip table part without packets originating at 2001:db8:40b7:9102::200:100>
   3647 15:49:43.319631 2001:db8:4071:3202::1f 			2001:db8:40b7:9100::100:100 	    130           ICMPv6   Echo (ping) request id=0x19bb, seq=2
   3693 15:49:45.469414 2001:db8:4071:3202::1f 			2001:db8:40b7:9102::200:100 	    130           ICMPv6   Echo (ping) request id=0x19bf, seq=0
   3694 15:49:45.469438 2001:db8:4071:3202::1f 			2001:db8:40b7:9101::1 	    	    130           ICMPv6   Echo (ping) request id=0x19bf, seq=1
   3695 15:49:45.469446 2001:db8:4071:3202::1f 			2001:db8:40b7:9100::100:100 	    130           ICMPv6   Echo (ping) request id=0x19bf, seq=2
   3696 15:49:45.469477 2001:db8:40b7:9100::100:100 		ff02::1:ff00:1        	    	     86           ICMPv6   Neighbor Solicitation
   3697 15:49:45.546365 fe80::1               			2001:db8:40b7:9100::100:100 	     86           ICMPv6   Neighbor Advertisement
   3698 15:49:45.546372 2001:db8:40b7:9100::100:100 		2001:db8:4071:3202::1f 	    	    130           ICMPv6   Echo (ping) reply id=0x19bf, seq=2
   3699 15:49:45.546373 2001:db8:40b7:9102::200:100 		2001:db8:4071:3202::1f 	    	    130           ICMPv6   Echo (ping) reply id=0x19bf, seq=0
   3700 15:49:45.546375 2001:db8:40b7:9101::1 			2001:db8:4071:3202::1f 	    	    130           ICMPv6   Echo (ping) reply id=0x19bf, seq=1
   3708 15:49:47.620190 2001:db8:4071:3202::1f			2001:db8:40b7:9102::200:100 	    130           ICMPv6   Echo (ping) request id=0x19c3, seq=0
   3709 15:49:47.620200 2001:db8:4071:3202::1f			2001:db8:40b7:9101::1 	    	    130           ICMPv6   Echo (ping) request id=0x19c3, seq=1
   3710 15:49:47.620280 2001:db8:40b7:9102::200:100	        2001:db8:4071:3202::1f 	    	    130           ICMPv6   Echo (ping) reply id=0x19c3, seq=0
   3711 15:49:47.620304 2001:db8:40b7:9101::1 			2001:db8:4071:3202::1f 	    	    130           ICMPv6   Echo (ping) reply id=0x19c3, seq=1

2001:db8:40b7:9102::200:100/64 is a local IPv6 address of my host (bound to br1)
2001:db8:40b7:9102::/64 has a number of KVM VMs running on the host (connected via br1)
2001:db8:40b7:9101::/64 has a number of KVM VMs running on the host (connected via br0)
2001:db8:3202::1f is my notebook which was running a ping for a number of IP addresses
2001:db8:1320:0:718f:6a5a:5b60:5632 is a smokeping host checking reachability

To confirm that this is indeed an ND issue, setting a static neighbor
entry for fe80::1 to the link level address of the current gateway
immediately fixed the issue. This is, unfortunately, not a permanent
solution since I don't want to rely on the hoster to keep their link
level addresses static.

If you need more information, please say so.

I'm going to post a similiar ND issue to a new thread soon. This may
be the same issue.

Greetings
Marc

-- 
-----------------------------------------------------------------------------
Marc Haber         | "I don't trust Computers. They | Mailadresse im Header
Mannheim, Germany  |  lose things."    Winona Ryder | Fon: *49 621 31958061
Nordisch by Nature |  How to make an American Quilt | Fax: *49 621 31958062
