From: Andrew Dickinson <whydna@whydna.net>
Subject: BUG: secpath not clearing between namespaces
Date: Fri, 3 Dec 2010 08:47:37 -0800
Message-ID: <AANLkTinZJ9REmG0pHCVzEZ=tN-R4WuiQunuCBhmYtzyb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:34682 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752617Ab0LCQrj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Dec 2010 11:47:39 -0500
Received: by eye27 with SMTP id 27so5132564eye.19
        for <netdev@vger.kernel.org>; Fri, 03 Dec 2010 08:47:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I think I've found a bug in the xfrm stack relating to namespaces.  I
can reproduce this consistently (see below).

I have the 3 namespaces which I refer to as "CORE", "VPN1" and "VPN2".

VPN1 and VPN2 each have 1 veth interfaces, CORE has 2 veth interfaces.
 I'm using a pair of bridge (not in a namespace) to plumb the
namespaces together:

VPN1 and CORE are on 10.0.1.12/30 with each of their veth pairs in a
non-namespaced bridge.
VPN2 and CORE are on 10.0.1.16/30 with each of their veth pairs in a
different non-namespaced bridge.

VPN1 has an ipsec tunnel to 10.254.0.0/23
VPN2 has an ipsec tunnel to 10.254.2.0/23

What does work: From CORE, I can happily ping hosts on the far side of
either tunnel (as expected).  Likewise, from VPN1 I can ping hosts
down its tunnel and the same for VPN2. (again: as expected).

What DOESN'T work:  from VPN1 I can't ping a host on the far side of
VPN2 and visa-versa.

What I see is that when the traffic arrives at VPN2 it tries to ARP
for it's next-hop (which _should_ be encrypted and set across the
tunnel).  It appears that it's chosing to NOT encrypt the traffic and
perform normal IPv4 forwarding.  I suspect that this is because when
the frame was being processed in VPN1 it hit an SPD policy setting the
secpath action to "none":

The last few lines in VPN1's "setkey.conf" file:
spdadd 0.0.0.0/0 0.0.0.0/0 any -P in prio 10 none;
spdadd 0.0.0.0/0 0.0.0.0/0 any -P out prio 10 none;

As such, when the packet arrives on VPN2, VPN2 is seeing that the sp
is already set and not trying to re-compute the policy.

I can further confirm this by setting an SPD in CORE which does ONLY
the "none/none" policy and the traffic will instantly break;  clearing
the SPD and SAD in CORE restores service.  See here:

root@CORE:~# cat /etc/racoon/setkey.conf
flush;
spdflush;
spdadd 0.0.0.0/0 0.0.0.0/0 any -P in prio 10 none;
spdadd 0.0.0.0/0 0.0.0.0/0 any -P out prio 10 none;

root@CORE:~# ping -c1 10.254.2.5
PING 10.254.2.5 (10.254.2.5) 56(84) bytes of data.
>From 10.1.2.18: icmp_seq=1 Redirect Host(New nexthop: 169.254.254.5)
>From 10.1.2.18 icmp_seq=1 Destination Host Unreachable

--- 10.254.2.5 ping statistics ---
1 packets transmitted, 0 received, +1 errors, 100% packet loss, time 0ms

root@CORE:~# setkey -F; setkey -PF

root@CORE:~# ping -c1 10.254.2.5
PING 10.254.2.5 (10.254.2.5) 56(84) bytes of data.
64 bytes from 10.254.2.5: icmp_seq=1 ttl=62 time=186 ms

--- 10.254.2.5 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 186.187/186.187/186.187/0.000 ms


It seems like the xfrm code needs to validate that the sp that's set
belongs to the current namespace that's processing it???

-A
