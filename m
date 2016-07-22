From: Doug Applegate <doug.applegate@gmail.com>
Subject: [PATCH RFC 0/1] xfrm: dst lookup doesn't account for fwmark
Date: Fri, 22 Jul 2016 15:50:30 -0600
Message-ID: <CACwzwmXfY3rpWfaspveT3JvumhPXYrMCH3TUwM1WNgEFKZ_t4A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f196.google.com ([209.85.161.196]:36429 "EHLO
	mail-yw0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751493AbcGVVuc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2016 17:50:32 -0400
Received: by mail-yw0-f196.google.com with SMTP id u134so8194581ywg.3
        for <netdev@vger.kernel.org>; Fri, 22 Jul 2016 14:50:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I ran into an issue trying to route outgoing ipsec traffic from an
ipsec responder hub that uses fwmark to route out a specific
interface. The fwmark points to a route table that contains a default
route out a specific interface.  The fwmark is applied based on
incoming interface of incoming traffic. I noticed that the mark was
not being used when doing a route lookup. Is there any reason why this
is? If not does this patch look reasonable? I just followed similar
logic to how TOS was being used before route-lookup. I've only tested
on an earlier kernel (3.14) and it works. Thanks!

Here's an example:

The ipsec policy is simple, just a tunnel from 192.168.0.0/24 <-->
192.168.1.0/24 the ipsec hub is at 35.0.0.1 but when traffic is being
responded too, instead of the expected interface (eth2) we end it out
a different interface (eth0)

route table:
# ip rule list
0: from all lookup local
32766: from all lookup main
32767: from all lookup default
40000: from all fwmark 0x2 lookup 3
40000: from all fwmark 0x4 lookup 4
50000: from all lookup 3

# ip route
25.0.0.0/30 dev eth0  src 25.0.0.1
35.0.0.0/30 dev eth2  src 35.0.0.1
192.168.1.0/24 dev lan1  src 192.168.1.1

# ip route list table 4
default via 35.0.0.2 dev eth2 onlink
# ip route list table 3
default via 25.0.0.2 dev eth0 onlink

I noticed this in netfilter trace, traffic matches the ipsec policy:
[   85.910365] TRACE: mangle:PREROUTING:rule:4 IN=lan1 OUT=
MAC=00:30:44:ff:b6:43:42:17:87:41:3c:eb:08:00 SRC=192.168.1.5
DST=192.168.0.5 LEN=84 TOS=0x00 PREC=0x00 TTL=64 ID=35127 PROTO=ICMP
TYPE=0 CODE=0 ID=15069 SEQ=1 MARK=0x4
[   85.911895] TRACE: mangle:FORWARD:rule:2 IN=lan1 ***OUT=eth0***
MAC=00:30:44:ff:b6:43:42:17:87:41:3c:eb:08:00 SRC=192.168.1.5
DST=192.168.0.5 LEN=84 TOS=0x00 PREC=0x00 TTL=63 ID=35127 PROTO=ICMP
TYPE=0 CODE=0 ID=15069 SEQ=1 MARK=0x4
