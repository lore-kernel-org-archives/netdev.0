From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: e100 + VLANs?
Date: Tue, 11 Oct 2011 13:51:20 +0400
Message-ID: <4E941198.9000307@msgid.tls.msk.ru>
References: <4E90212D.8030009@msgid.tls.msk.ru> <1318091046.5276.22.camel@edumazet-laptop> <4E9097C0.2030307@gmail.com> <20111010101954.GB2840382@jupiter.n2.diac24.net> <4E9307CB.4050704@msgid.tls.msk.ru> <1318259152.3227.0.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <20111010151343.GB3260852@jupiter.n2.diac24.net> <4E932278.8010802@tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, jeffrey.t.kirsher@intel.com,
	netdev <netdev@vger.kernel.org>
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([86.62.121.231]:39262 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753913Ab1JKJvW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Oct 2011 05:51:22 -0400
In-Reply-To: <4E932278.8010802@tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

10.10.2011 20:51, Michael Tokarev wrote:
> 10.10.2011 19:13, David Lamparter wrote:
>> On Mon, Oct 10, 2011 at 05:05:52PM +0200, Eric Dumazet wrote:
>>>> When pinging this NIC from another machine over VLAN5, I see
>>>> ARP packets coming to it, gets recognized and replies going
>>>> back, all on vlan 5.  But on the other side, replies comes
>>>> WITHOUT a VLAN tag!
>>>>
>>>> From this NIC's point of view, capturing on whole ethX:
>>>>
>>>> 00:1f:c6:ef:e5:1b > ff:ff:ff:ff:ff:ff, ethertype 802.1Q (0x8100), length 60: vlan 5, p 0, ethertype ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 10.48.11.2 tell 10.48.11.1, length 42
>>>> 00:90:27:30:6d:1c > 00:1f:c6:ef:e5:1b, ethertype 802.1Q (0x8100), length 46: vlan 5, p 0, ethertype ARP, Ethernet (len 6), IPv4 (len 4), Reply 10.48.11.2 is-at 00:90:27:30:6d:1c, length 28
>>>>
>>>> From the partner point of view, also on whole ethX:
>>>>
>>>> 00:1f:c6:ef:e5:1b > ff:ff:ff:ff:ff:ff, ethertype 802.1Q (0x8100), length 46: vlan 5, p 0, ethertype ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 10.48.11.2 tell 10.48.11.1, length 28
>>>> 00:90:27:30:6d:1c > 00:1f:c6:ef:e5:1b, ethertype ARP (0x0806), length 60: Ethernet (len 6), IPv4 (len 4), Reply 10.48.11.2 is-at 00:90:27:30:6d:1c, length 46
>>>>
>>>> So, the tag gets eaten somewhere along the way... ;)
>>
>> Hmm. Looks like broken VLAN TX offload, but the driver doesn't even
>> implement VLAN offload. Maybe it's broken in its non-implementation...
>>
>> Your "partner" is a known-good setup and can be assumed to be working
>> correctly? This is over a crossover cable, no evil switches involved?
> 
> There are just two machines involved, both connected to the
> same _switch_ - no, it is not over cross-over cable.  It's a
> good idea to test one, I'll try it tomorrow (will insert a
> second "known good" nic into another machine).

Ok, I found the issue - it was my misconfiguration of vlan5 in the
switch.  So tags are correctly set and processed by e100 NIC and
the driver.

I tried direct (without a switch) connection, and it shows the same
problem - the MTU issues, large packets does not work, exactly as
shown below...

> The second machine, the "partner", has this NIC:
> 
> 02:00.0 Ethernet controller: Atheros Communications L1 Gigabit Ethernet (rev b0)
> 
> and it is a known-good implementation - it worked with and without vlan
> tags (we had a weird mixed tagged/untagged setup) for over 2 years without
> any issues, and which works now as well - it's our main server which is
> in two VLANs, connected to an interface marked as tagged in the switch.
> It communicates with the other machine when that other machine uses
> already mentioned VIA RhineIII NIC - which I used to replace this non-working
> E100.
> 
> So it's 2 machines, one with 2 nics - VIA Rhine (working) and e100 (non-working),
> both connected to two "tagged" ports in the switch.  And another, with atl1 NIC,
> also connected to a "tagged" port in the switch.
[]
> Ok.  So now I can reproduce the initial problem.
> 
> So, `ping -s 1469' from atl1 side, so that the resulting packet side
s/side/size/

> is 1497 bytes (1468 is the largest size that works) -- the packets
> does not arrive at e100 side at all - it's 100% quiet in tcpdump there.
> 
> When pinging from e100 side and tcpdump'ing on atl1 side (replies does
> not come back to e100):
> 
> 20:49:33.322646 00:90:27:30:6d:1c > 00:1f:c6:ef:e5:1b, ethertype 802.1Q (0x8100), length 1515: vlan 8, p 0, ethertype IPv4, (tos 0x0, ttl 64, id 0, offset 0, flags [DF], proto ICMP (1), length 1497)
>     10.48.8.2 > 10.48.8.1: ICMP echo request, id 5785, seq 72, length 1477
> 20:49:33.322691 00:1f:c6:ef:e5:1b > 00:90:27:30:6d:1c, ethertype 802.1Q (0x8100), length 1515: vlan 8, p 0, ethertype IPv4, (tos 0x0, ttl 64, id 23781, offset 0, flags [none], proto ICMP (1), length 1497)
>     10.48.8.1 > 10.48.8.2: ICMP echo reply, id 5785, seq 72, length 1477
> 
> So it appears that on e100 side, the _receive_ buffer is too small
> somehow.

So, is that a hardware limitation?

Thank you!

/mjt
