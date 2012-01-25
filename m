From: Joseph Glanville <joseph.glanville@orionvm.com.au>
Subject: Re: [patch v4, kernel version 3.2.1] net/ipv4/ip_gre: Ethernet
 multipoint GRE over IP
Date: Wed, 25 Jan 2012 14:48:37 +1100
Message-ID: <CAOzFzEjE7b-Y+_vOWeBKbHDkURRcYXomSTcwB91vKHVWQxBVsg@mail.gmail.com>
References: <3900291.2831326843194846.JavaMail.root@5-MeO-DMT.ynet.sk>
	<CAGsizzLUwA_=fZFX-4ZnYU4K-nj1A2DV_BZKOMKxgQDh2Rs54g@mail.gmail.com>
	<1327327999.2525.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20120123.134352.1621146585245670953.davem@davemloft.net>
	<CAGsizzJnQ6b6eSC0ZnAtFguU7_xDfWFPSY6L4DWXc24F+Ts2XQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: =?ISO-8859-2?Q?=A9tefan_Gula?= <steweg@ynet.sk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGsizzJnQ6b6eSC0ZnAtFguU7_xDfWFPSY6L4DWXc24F+Ts2XQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I have conducted testing on this patch series and have found it to be s=
table.
It applies cleanly and doesn't introduce any noticable performance
impact over standard gretap interfaces.

The reason why this patch is useful is that it stands to be the only
true mulitpoint L2 VPN with a kernel space forwarding plane.
Almost all other VPN solutions use the TAP/TUN module - resulting in
barely 300-400mbits of performance even on powerful cores.
Many of these solutions implented in userspace still don't implement
MAC learning or any method of tunneling traffic directly to endpoints
rather than through some central server.
I measured this patch (and gretap in general) peaking at 4.7gbits on
my test hardware (reasonable i5 cores)
The iperf benchmark results are at the end of this email.

The merits of the solution are as follows:
- No userspace utilities required (other than ip)
- Stateless (gre) tunnels dont cause issues like TCP in TCP and are
well supported in hardware (unlike custom UDP encapsulation)
- Forwarding table automatically updated via multicast learning
- If included the Linux kernel is fully capable for being a multisite
Ethernet bridge with learning and unicast tunneling.

In contrast of other software being able to implement this solutoin:
- OpenVSwitch currently doesnt have NVGRE or VXLAN support (I'm
working on getting VXLAN support stable in the 1.4 branch however)
    - as a subpoint you can implement this using an Openflow
controller and OVS gre interfaces but it's well outside the effort
scope this patch is in
- Userspace solutions like OpenVPN that use the TUN interface are very
inefficient for high speed tunneling use and again are hard to
configure in multipoint mode without resuling in a star topology (very
inefficient for high b/w use)
- Other kernelspace tunneling isnt capable of forming a loop free
arbitary topology without STP or other protocol to ensure an acyclic
forwarding graph

Having this in the kernel eliminates the need for much more
complicated userspace utilities and the ip command makes for an
effective user interface.

Lastly here are the promised benchmarks, I can post test rig stats if
anyone is interested.

------------------------------------------------------------
Server listening on TCP port 5001
TCP window size: 85.3 KByte (default)
------------------------------------------------------------
[  4] local 192.168.1.2 port 5001 connected with 192.168.1.1 port 59819
[ ID] Interval       Transfer     Bandwidth
[  4]  0.0-10.0 sec  5.50 GBytes  4.72 Gbits/sec

Kind regards,
Joseph.

2012/1/24 =C5=A0tefan Gula <steweg@ynet.sk>:
> 2012/1/23 David Miller <davem@davemloft.net>:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Mon, 23 Jan 2012 15:13:19 +0100
>>
>>> Le lundi 23 janvier 2012 =C3=A0 14:12 +0100, =C5=A0tefan Gula a =C3=
=A9crit :
>>>
>>>> is there anything else needed from my side to get this code into t=
he
>>>> kernel or should I only wait for the maintainers to check it?
>>>
>>> net-next is/was not yet opened, you shall wait for the good time fr=
ame.
>>>
>>> Dont copy/paste a big message only to add one sentence at its end, =
its
>>> really a waste of time for many of us.
>>
>> Also you were told of other ways to achieve the things you want to d=
o,
>> and I haven't seen any reasonable response that supports still addin=
g
>> this new code.
> I am sorry about the mistakes I did (still new to kernel submitting
> processes). I believe that I also explain to everybody who says
> something similar that it is not entirely true and probably never wil=
l
> be as none of the current SW allows you to create L2 Ethernet
> Multipoint VPN solution in such simple way as almost all requires to
> run special kind of software in user-space to provide control-plane
> for such feature to work. This software must be able to run on variou=
s
> platforms/architectures which makes it sometimes problematic. My
> solution doesn't need this at all and extends the capability of greta=
p
> interfaces in proper manner to be aligned with other forwarding
> engines of gretap interfaces. I already have at least one successful
> test done in other environment other than my own. So I assume some
> people like this approach better than other solutions. For them and
> also for myself, I believe it should be added.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.ht=
ml
> Please read the FAQ at =C2=A0http://www.tux.org/lkml/



--=20
=46ounder | Director | VP Research
Orion Virtualisation Solutions=C2=A0|=C2=A0www.orionvm.com.au=C2=A0| Ph=
one: 1300 56
99 52 | Mobile: 0428 754 846
