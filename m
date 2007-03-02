From: Ben Greear <greearb@candelatech.com>
Subject: Re: ppp and routing table rules.
Date: Thu, 01 Mar 2007 22:29:51 -0800
Message-ID: <45E7C45F.9080805@candelatech.com>
References: <45E7AC31.9030309@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:35987 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422963AbXCBG1t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 01:27:49 -0500
Received: from [71.112.198.166] (pool-71-112-198-166.sttlwa.dsl-w.verizon.net [71.112.198.166])
	(authenticated bits=0)
	by ns2.lanforge.com (8.13.4/8.13.4) with ESMTP id l226Rnqx006529
	for <netdev@vger.kernel.org>; Thu, 1 Mar 2007 22:27:49 -0800
In-Reply-To: <45E7AC31.9030309@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> Hello!
>
> I have a suspicion (but no proof at this time) that a rule like this:
>
> 20:     from all iif ppp400 lookup 10001
>
> is not actually working for ppp interfaces.  Before I go adding printk 
> statements, are there any
> stats that would show if packets are hitting a particular rule or 
> routing table?
Ok, the rule is working and the routing table is being used.  But, 
weirdness abounds.

Here is my setup:

I have ppp401 (11.1.1.3/32) connected to ppp400 (11.1.1.2/32), over a 
cross-over T1 NIC (ie, this is going to the same machine).
Anything coming in on ppp400, uses a particular routing table, whose 
routes look like this:

10.1.1.3 via 172.1.2.2 dev rddVR4
11.1.1.2 via 11.1.1.2 dev ppp400
172.1.2.0/24 via 172.1.2.1 dev rddVR4
172.1.1.0/24 via 172.1.2.2 dev rddVR4
10.0.0.0/8 via 172.1.2.2 dev rddVR4
11.0.0.0/8 via 11.1.1.2 dev ppp400
default via 11.1.1.2 dev ppp400

If all worked as planned, the packets would traverse several other 
routing tables, the final which
has another pair of ppp links in it (ppp200, 10.1.1.2/32  connected to 
ppp201, 10.1.1.3/23).

I am sending udp packets through ppp400, and I see them appear on ppp401 
as expected.

The thing that is bothering me is that all I see on rddVR4 (172.1.2.1) 
is arps for 172.1.2.2, but the 'tell' IP is that of the
originating ppp400 link, not the IP of rddVR4, as I expected:

21:47:16.119640 arp who-has 172.1.2.2 tell 11.1.1.3
21:47:17.119371 arp who-has 172.1.2.2 tell 11.1.1.3
21:47:18.119254 arp who-has 172.1.2.2 tell 11.1.1.3
21:47:19.273118 arp who-has 172.1.2.2 tell 11.1.1.3

Unless I'm missing something dumb, a similar setup with all ethernet-ish 
network devices
works fine.

I have also enabled arp filtering:
# Only answer ARPs if it is for the IP on our own interface.
echo 2 > /proc/sys/net/ipv4/conf/all/arp_ignore
and for every device used in these routing tables:
echo 1 > /proc/sys/net/ipv4/conf/[dev]/arp_filter

Any idea what I need to do in order to make  the source IP for the ARP 
packet correct?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


