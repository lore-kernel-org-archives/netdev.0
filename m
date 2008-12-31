From: Speedster <speedster@haveacry.com>
Subject: Re: [Bugme-new] [Bug 12327] New: Intermittent TCP issues with =>
 2.6.27
Date: Thu, 01 Jan 2009 08:22:23 +0900
Message-ID: <495BFEAF.6000006@haveacry.com>
References: <bug-12327-10286@http.bugzilla.kernel.org/> <20081229214101.4c4f5ac1.akpm@linux-foundation.org> <Pine.LNX.4.64.0812311241490.3120@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>, bugme-daemon@bugzilla.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosted01.westnet.com.au ([203.10.1.211]:53856 "EHLO
	hosted01.westnet.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752164AbYLaX5U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2008 18:57:20 -0500
In-Reply-To: <Pine.LNX.4.64.0812311241490.3120@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=E4rvinen wrote:
> On Mon, 29 Dec 2008, Andrew Morton wrote:
>=20
>> (switched to email.  Please respond via emailed reply-to-all, not vi=
a the
>> bugzilla web interface).
>>
>> On Mon, 29 Dec 2008 18:52:40 -0800 (PST) bugme-daemon@bugzilla.kerne=
l.org wrote:
>>
>>> http://bugzilla.kernel.org/show_bug.cgi?id=3D12327
>>>
>>>            Summary: Intermittent TCP issues with =3D> 2.6.27
>>>            Product: Networking
>>>            Version: 2.5
>>>      KernelVersion: 2.6.27
>>>           Platform: All
>>>         OS/Version: Linux
>>>               Tree: Mainline
>>>             Status: NEW
>>>           Severity: normal
>>>           Priority: P1
>>>          Component: IPV4
>>>         AssignedTo: shemminger@linux-foundation.org
>>>         ReportedBy: speedster@haveacry.com
>>>
>>>
>>> Latest working kernel version: 2.6.26.8
>>> Earliest failing kernel version: 2.6.27
>>> Distribution: Ubuntu
>>> Hardware Environment: amd64, KVM
>>> Software Environment:
>>> Problem Description:
>>>
>>> As reported in LP #296767
>>> (https://bugs.launchpad.net/ubuntu/+source/linux/+bug/296767) I am =
experiencing
>>> intermittent TCP issues over a PPP ADSL2+ connection with the only =
change being
>>> an upgrade to 2.6.27.
>>>
>>> A number of websites, ping, traceroute work correctly but I simply =
can't
>>> connect to several including:
>>>
>>> - store.apple.com
>>> - youtube.com
>>> - ANZ internet banking (anz.com.au)
>>> - MSN messenger
>>>
>>> I have also tried compiling a generic 2.6.28-rc4 kernel and this st=
ill suffers
>>> from the same issue, however if I reboot into the previous Ubuntu k=
ernel
>>> (2.6.24) or a vanilla 2.6.26 kernel the issue disappears.
>>>
>>> Steps to reproduce:
>>>
>>> 1. Use a KVM guest as a gateway to a PPP internet connection
>>> 2. Boot with kernel <=3D 2.6.26
>>> 3. Observe functioning networking
>>> 4. Boot into 2.6.27+
>>> 5. Observe broken networking
>=20
> Can you please describe the full topology (which is connected to wher=
e and=20
> using what, and locations of nats, tun/taps, netfilter things, etc.).=
=2E.=20
> There's some contradiction between the ubuntu report description and =
what=20
> you're giving here.=20
>=20
> Based on your dumps I find it unlikely that the problem would be in t=
he=20
> end host tcp but I'll verify the packets field by field still to be=20
> absolutely sure. I'd guess that either the sent packet or reply gets=20
> lost somewhere since it never arrives with 2.6.27/2.6.28-rcx.
>=20

The gateway machine (whinge) runs as a KVM guest, and shares a physical=
=20
host with three other guests (one Windows, two Linux). Below are the=20
outputs of bridge topology and VLAN tagging on the physical host.

speedster@whimper:~$ brctl show
bridge name     bridge id               STP enabled     interfaces
dmz             8000.364121864f53       no              vnet0
                                                         vnet4
external                8000.00801e14ffc8       no              vlan50
                                                         vnet3
internal                8000.00801e14ffc8       no              vlan200
                                                         vnet1
                                                         vnet2
                                                         vnet5

-----------------------------------

speedster@whimper:~$ sudo cat /proc/net/vlan/config
VLAN Dev name    | VLAN ID
Name-Type: VLAN_NAME_TYPE_PLUS_VID_NO_PAD
vlan50         | 50  | eth1
vlan200        | 200  | eth1
vlan201        | 201  | eth1
vlan202        | 202  | eth1

-----------------------------------

Whinge (gateway) has three interfaces - one each that connect as taps o=
n=20
the DMZ (vnet4), internal (vnet5) and external (vnet3) bridges. vlan50=20
is connected to the ADSL2 modem. vlan200 is connected to a physical=20
switch that laptops, access points, other computers connect to.


Ifconfig output from whinge:

speedster@whinge:~$ ifconfig
eth0      Link encap:Ethernet  HWaddr 00:16:3e:24:f7:a1
           inet6 addr: fe80::216:3eff:fe24:f7a1/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:20302278 errors:0 dropped:0 overruns:0 frame:0
           TX packets:21094867 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:13224666138 (13.2 GB)  TX bytes:19329455294 (19.3 G=
B)

eth0:1    Link encap:Ethernet  HWaddr 00:16:3e:24:f7:a1
           inet addr:192.168.0.2  Bcast:192.168.0.255  Mask:255.255.255=
=2E0
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1

eth1      Link encap:Ethernet  HWaddr 00:16:3e:58:27:c4
           inet addr:203.26.xxx.xxx  Bcast:203.26.xxx.xxx=20
Mask:255.255.255.240
           inet6 addr: fe80::216:3eff:fe58:27c4/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:1602092 errors:0 dropped:0 overruns:0 frame:0
           TX packets:1352585 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:1078162279 (1.0 GB)  TX bytes:636885252 (636.8 MB)

eth2      Link encap:Ethernet  HWaddr 00:16:3e:61:48:91
           inet addr:192.168.200.1  Bcast:192.168.200.255=20
Mask:255.255.255.0
           inet6 addr: fe80::216:3eff:fe61:4891/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:21355818 errors:0 dropped:0 overruns:0 frame:0
           TX packets:20024872 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:18440347046 (18.4 GB)  TX bytes:13623311915 (13.6 G=
B)

lo        Link encap:Local Loopback
           inet addr:127.0.0.1  Mask:255.0.0.0
           inet6 addr: ::1/128 Scope:Host
           UP LOOPBACK RUNNING  MTU:16436  Metric:1
           RX packets:115 errors:0 dropped:0 overruns:0 frame:0
           TX packets:115 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:36784 (36.7 KB)  TX bytes:36784 (36.7 KB)

ppp0      Link encap:Point-to-Point Protocol
           inet addr:202.72.xxx.xxx  P-t-P:202.72.xxx.xxx=20
Mask:255.255.255.255
           UP POINTOPOINT RUNNING NOARP MULTICAST  MTU:1492  Metric:1
           RX packets:2053229 errors:0 dropped:0 overruns:0 frame:0
           TX packets:1432508 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:3
           RX bytes:1837869380 (1.8 GB)  TX bytes:637947402 (637.9 MB)

-----------------------------------

eth1 -> ppp0 does not pass through NAT; it is simply routed.
eth2 -> ppp0 passes through netfilter MASQUERADE in POSTROUTING

There is a netfilter firewall running on whinge, but I have tried=20
removing all rules, setting policies to ACCEPT and running a simple=20
masquerade rule from eth2 to ppp0

When the issue manifests itself there are connection issues to sites=20
from both physical machines, as well as KVM guests connected to both th=
e=20
DMZ and internal bridges.

I'd like to reiterate that throughout my testing, only whinge had=20
changes made to it (change kernel/reboot). The KVM host and network=20
topology remained unchanged throughout testing.

Please let me know if there is any more information required.
