From: Ben Greear <greearb@candelatech.com>
Subject: Re: VRFs and the scalability of namespaces
Date: Mon, 29 Sep 2014 10:00:09 -0700
Message-ID: <54299019.3050604@candelatech.com>
References: <5425EAA6.7040302@gmail.com> <1411824598.2136890.172383085.705271DD@webmail.messagingengine.com> <54295971.2040402@gmail.com> <54298B66.8060807@candelatech.com> <CACP96tR_c3-nVEGhswm1qt1WGXPNzyXA61FCxPutCTPNomjy+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Ahern <dsahern@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	netdev <netdev@vger.kernel.org>
To: Sowmini Varadhan <sowmini05@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:50380 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753919AbaI2RAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 13:00:10 -0400
In-Reply-To: <CACP96tR_c3-nVEGhswm1qt1WGXPNzyXA61FCxPutCTPNomjy+g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/29/2014 09:50 AM, Sowmini Varadhan wrote:
> On Mon, Sep 29, 2014 at 12:40 PM, Ben Greear <greearb@candelatech.com> wrote:
>> On 09/29/2014 06:06 AM, David Ahern wrote:
> 
>>
>> We have implemented support for at least most of this (excepting duplicate IPs)
>> using routing tables, rules, and (optionally, xorp as the router).
>>
> 
> My undertanding of multiple routing-tables/rules was that they
> are closer in semantics to switch/router ACLs than to VRFs, eg.,
> one big difference is that an interface can belong to exactly one
> VRF at a time, which is not mandated by multiple routing-tables/rules.
> 
> Was I mistaken?

You can effectively force an interface to belong to a particular virtual
router (table).  It is not trivial to do, and possibly I have still not
covered every possible case.  Some rules grow somewhat exponentially as
interfaces are added to virtual routers (ie, preference 10 rules).

Here is our setup for a system with a single virtual router, which uses
table 10001.  vap0, vap1, and eth1 are in this virtual router.  There are other
interfaces on this system outside of the virtual router, so you can ignore rules
related to those.

You have to add CT zones for each virtual router as well.

[root@ath10k-2220 ~]# ip ru show
10:	from all to 5.1.1.1 iif eth1 lookup local
10:	from all to 4.1.0.1 iif vap0 lookup local
10:	from all to 4.2.0.1 iif vap0 lookup local
10:	from all to 4.2.0.1 iif vap1 lookup local
10:	from all to 5.1.1.1 iif vap0 lookup local
10:	from all to 4.1.0.1 iif vap1 lookup local
10:	from all to 4.1.0.1 iif vap1 lookup local
10:	from all to 5.1.1.1 iif vap1 lookup local
10:	from all to 4.1.0.1 iif eth1 lookup local
10:	from all to 4.2.0.1 iif vap0 lookup local
10:	from all to 4.2.0.1 iif eth1 lookup local
20:	from all iif eth1 lookup 10001
20:	from all iif vap0 lookup 10001
20:	from all iif vap1 lookup 10001
30:	from 5.1.1.1 lookup 10001
30:	from 4.1.0.1 lookup 10001
30:	from 4.2.0.1 lookup 10001
50:	from all oif rddVR0 lookup 6
50:	from all oif rddVR1 lookup 7
50:	from all oif rddVR2 lookup 8
50:	from all oif rddVR3 lookup 9
50:	from all oif wlan0 lookup 4
50:	from all oif wlan1 lookup 5
50:	from all oif eth1 lookup 10001
50:	from all oif vap0 lookup 10001
50:	from all oif vap1 lookup 10001
512:	from all lookup local
32766:	from all lookup main
32767:	from all lookup default

[root@ath10k-2220 ~]# ip -4 route show table all
unreachable default  table 10001
4.1.0.0/16 via 4.1.0.1 dev vap0  table 10001
4.2.0.0/16 via 4.2.0.1 dev vap1  table 10001
5.1.1.0/24 dev eth1  table 10001  scope link
default via 192.168.100.1 dev eth0
4.1.0.0/16 dev vap0  proto kernel  scope link  src 4.1.0.1
4.2.0.0/16 dev vap1  proto kernel  scope link  src 4.2.0.1
5.1.1.0/24 dev eth1  proto kernel  scope link  src 5.1.1.1
169.254.0.0/16 dev eth0  scope link  metric 1002
192.168.100.0/24 dev eth0  proto kernel  scope link  src 192.168.100.179
broadcast 4.1.0.0 dev vap0  table local  proto kernel  scope link  src 4.1.0.1
local 4.1.0.1 dev vap0  table local  proto kernel  scope host  src 4.1.0.1
broadcast 4.1.255.255 dev vap0  table local  proto kernel  scope link  src 4.1.0.1
broadcast 4.2.0.0 dev vap1  table local  proto kernel  scope link  src 4.2.0.1
local 4.2.0.1 dev vap1  table local  proto kernel  scope host  src 4.2.0.1
broadcast 4.2.255.255 dev vap1  table local  proto kernel  scope link  src 4.2.0.1
broadcast 5.1.1.0 dev eth1  table local  proto kernel  scope link  src 5.1.1.1
local 5.1.1.1 dev eth1  table local  proto kernel  scope host  src 5.1.1.1
broadcast 5.1.1.255 dev eth1  table local  proto kernel  scope link  src 5.1.1.1
broadcast 127.0.0.0 dev lo  table local  proto kernel  scope link  src 127.0.0.1
local 127.0.0.0/8 dev lo  table local  proto kernel  scope host  src 127.0.0.1
local 127.0.0.1 dev lo  table local  proto kernel  scope host  src 127.0.0.1
broadcast 127.255.255.255 dev lo  table local  proto kernel  scope link  src 127.0.0.1
broadcast 192.168.100.0 dev eth0  table local  proto kernel  scope link  src 192.168.100.179
local 192.168.100.179 dev eth0  table local  proto kernel  scope host  src 192.168.100.179
broadcast 192.168.100.255 dev eth0  table local  proto kernel  scope link  src 192.168.100.179

[root@ath10k-2220 ~]# ip route show table 10001
unreachable default
4.1.0.0/16 via 4.1.0.1 dev vap0
4.2.0.0/16 via 4.2.0.1 dev vap1
5.1.1.0/24 dev eth1  scope link


Thanks,
Ben

> 
> --Sowmini
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
