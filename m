From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: rp_filter and ip rule break ipsec policy
Date: Fri, 11 Jan 2008 12:23:20 +0100
Message-ID: <BAY103-DAV74C2164B1205BADF62C17B24B0@phx.gbl>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc2-s12.bay0.hotmail.com ([65.54.246.148]:42582 "EHLO
	bay0-omc2-s12.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755785AbYAKLXZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 06:23:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello everybody.
AFAIK ipsec policy aren't related to routing
tables: if there is an ipsec policy to deliver
traffic, for example, from 192.168.0.0/16 to
10.0.0.0/8, xfrm will eat the packets ignoring
the routing table.

Here is the ipsec gateway schema:


     [-] cisco ISP router default gateway for
      |         the linux box ip=cisco-genova
      |
      |
      |
      |  _____ eth0 ip=osw-genova
      | /
      |/
   +--+--+
   |     |
   |     +---- eth1 dmz-genova/28 ip=osw-genova
   |     |
   +--+--+
      |
      |
      |------- eth2 172.23.0.0/23 ip=172.23.1.8


Take a look:

# ip ru sh
0:      from all lookup local
601:    from all to x.y.z.214 iif eth2 lookup test
32766:  from all lookup main
32767:  from all lookup default

# ip r sh table test
default via 172.23.1.254 dev eth2  metric 1

When I insert the rule number #601 packets to
x.y.z.214 aren't ate by xfrm anymore. This
happens when rp_filter is set to 1 on eth0.
Disabling rp_filter on eth0 resolve the problem:
xfrm eat the packets.
Is this the expected behaviour? Why should
rp_filter broken ipsec policy when rule #601
is inserted?

I have enabled log_martinans on eth0 and when
rp_filter is set to 1 I see this messages:

martian source 172.23.1.4 from x.y.z.214, on dev eth0
ll header: 00:30:05:cb:27:c1:00:1b:54:fb:fd:78:08:00
martian source 172.23.1.4 from x.y.z.214, on dev eth0
ll header: 00:30:05:cb:27:c1:00:1b:54:fb:fd:78:08:00

# ip x p
src x.y.z.214 dst 172.23.0.0/23
        dir in priority 2376 ptype main
        tmpl src osw-napoli dst osw-genova
                proto comp reqid 16390 mode tunnel
                level use
        tmpl src 0.0.0.0 dst 0.0.0.0
                proto esp reqid 16389 mode transport
src 172.23.0.0/23 dst x.y.z.214
        dir out priority 2376 ptype main
        tmpl src osw-genova dst osw-napoli
                proto comp reqid 16390 mode tunnel
        tmpl src 0.0.0.0 dst 0.0.0.0
                proto esp reqid 16389 mode transport
src x.y.z.214 dst 172.23.0.0/23
        dir fwd priority 2376 ptype main
        tmpl src osw-napoli dst osw-genova
                proto comp reqid 16390 mode tunnel
                level use
        tmpl src 0.0.0.0 dst 0.0.0.0
                proto esp reqid 16389 mode transport

Here are the others routing tables:

# ip r sh table main
cisco-genova dev eth0  scope link
dmz-genova/28 dev eth1  proto kernel  scope link  src osw-genova
172.23.0.0/23 dev eth2  proto kernel  scope link  src 172.23.1.8
127.0.0.0/8 dev lo  scope link
default via cisco-genova dev eth0  metric 1

# ip r sh table local
broadcast 127.255.255.255 dev lo  proto kernel  scope link  src
127.0.0.1
broadcast dmz-genova dev eth0  proto kernel  scope link  src osw-genova
broadcast dmz-genova dev eth1  proto kernel  scope link  src osw-genova
broadcast broadcast-genova dev eth0  proto kernel  scope link  src
osw-genova
broadcast broadcast-genova dev eth1  proto kernel  scope link  src
osw-genova
local osw-genova dev eth0  proto kernel  scope host  src osw-genova
local osw-genova dev eth1  proto kernel  scope host  src osw-genova
broadcast 172.23.0.0 dev eth2  proto kernel  scope link  src 172.23.1.8
broadcast 172.23.1.255 dev eth2  proto kernel  scope link  src
172.23.1.8
local 172.23.1.8 dev eth2  proto kernel  scope host  src 172.23.1.8
broadcast 127.0.0.0 dev lo  proto kernel  scope link  src 127.0.0.1
local 127.0.0.1 dev lo  proto kernel  scope host  src 127.0.0.1
local 127.0.0.0/8 dev lo  proto kernel  scope host  src 127.0.0.1


