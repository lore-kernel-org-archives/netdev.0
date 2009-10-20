From: Ben Greear <greearb@candelatech.com>
Subject: Re: pktgen and spin_lock_bh in xmit path
Date: Mon, 19 Oct 2009 21:52:05 -0700
Message-ID: <4ADD41F5.5080707@candelatech.com>
References: <4ADD309B.1040505@candelatech.com> <4ADD32FA.6030409@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:40241 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751734AbZJTEwE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 00:52:04 -0400
In-Reply-To: <4ADD32FA.6030409@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Ben Greear a =E9crit :
>  =20
>> I'm having strange issues when running pktgen on 10G interfaces whil=
e
>> also running
>> pktgen on mac-vlans on that interface, when the mac-vlan pktgen thre=
ads
>> are on a different
>> CPU.
>>
>> First, lockdep gives up and says that things are not properly
>> annotated.  I believe this is because
>> the macvlan tx path will lock it's txq and will also lock the
>> lower-dev's txq.  To fix this, perhaps
>> we need some new lockdep aware primitives for netdev txq locking?
>>
>> Second, is using _bh() locking really sufficient if we have pktgen
>> writing to a physical device
>> and also have other pktgen threads writing to that same device thoug=
h
>> mac-vlans?   I'm seeing
>> deadlocks spinning on the _bh() lock in pktgen as well as strange
>> corruptions, so I think there
>> must be *some* problem somewhere, I just don't know quite what it is=
 yet.
>>
>>    =20
>
> Could you please give us a copy if your pktgen scripts ?
>  =20
I'm driving it with another program, and my pktgen is a bit hacked, but=
=20
the basic idea is:

1 pktgen connection on cpu 0 running as fast as it can (trying for=20
10Gbps, but getting maybe 3-4),
  running between two 10G ports (intel 82599).
  Multi-pkt is set to 10,000 on each side.
3 pairs of mac-vlans on each of the two physical 10G ports.
 3 pktgen 'connections' between these..each are running at about 1Gbps.
 These 3 pktgen connections are on CPU 4.
 Multi-pkt is set to 1 since multi-pkt is a very bad idea on virtual=20
devices.

1514 byte pkts.  No IPs on the interfaces, using ToS in pktgen, but=20
nothing else is configured to
care.

The two physical ports are cabled together directly with a fibre cable.

All pktgen connections are full duplex (both sides transmitting to each=
=20
other..and I have
rx logic to gather stats on received pkts as well).  With no kernel=20
debugging, this can run right at 10Gbps bi-directional,
with lockdep it gets around 5-6Gbps in each direction.

The lockup often occurs near starting/stopping pktgen, but also happens=
=20
while just normally
running under load, usually within 10 minutes.

I tried and failed to reproduce this on a 1G network, but maybe I'm jus=
t=20
not getting (un)lucky,
didn't try for too long.

Among other things, it appears as if the mac-vlan interfaces sometimes=20
become locked to transmit
by pktgen, but a raw socket in user-space can send on them fine.  I'm=20
going to add some debugging
for this particular issue tomorrow to try to figure out why that happen=
s.

Please note I have the rest of my network patches applied (but not usin=
g=20
any proprietary modules),
so it could easily be something I've caused.  I think fixing lockdep to=
=20
work with the txq _bh locks
would be a good first step to fixing this..

Thanks,
Ben

--=20
Ben Greear <greearb@candelatech.com>=20
Candela Technologies Inc  http://www.candelatech.com


