From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: NET_NS: unregister_netdevice: waiting for lo to become free (adding ipv6 address to interface)
Date: Thu, 05 Aug 2010 12:57:59 -0700
Message-ID: <m1bp9g7ry0.fsf@fess.ebiederm.org>
References: <loom.20100708T183152-326@post.gmane.org>
	<20100709235744.GA12752@kroah.com>
	<20100710101540.2799c9ef@xenia.leun.net>
	<20100710140800.GA20424@kroah.com>
	<20100710165208.59272ae6@xenia.leun.net>
	<20100710235323.5336f627@xenia.leun.net>
	<20100711192939.1c25dcaf@xenia.leun.net>
	<20100804153543.56f6ecad@xenia.leun.net>
	<20100804214618.GA6289@kroah.com>
	<20100805001105.5a3453ed@xenia.leun.net>
	<m1lj8l29zm.fsf@fess.ebiederm.org>
	<20100805112538.60a46cb1@xenia.leun.net>
	<m1y6clz8ta.fsf_-_@fess.ebiederm.org>
	<20100805134707.0442a7b1@xenia.leun.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <greg@kroah.com>, netdev@vger.kernel.org,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Patrick McHardy <kaber@trash.net>
To: Michael Leun <lkml20100708@newton.leun.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100805134707.0442a7b1@xenia.leun.net> (Michael Leun's message of "Thu\, 5 Aug 2010 13\:47\:07 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Leun <lkml20100708@newton.leun.net> writes:

> On Thu, 05 Aug 2010 02:51:29 -0700
> ebiederm@xmission.com (Eric W. Biederman) wrote:
>
>> >> > Jul 10 20:02:36 doris kernel: unregister_netdevice: waiting for
>> >> > lo to become free. Usage count = 3 [repeated]
>> >> 
>> >> How many times?
>> >
>> > Unfortunately looks like indefinitely. Never watched longer so far
>> > (rebooted soon), but I'm seeing this message now repeated every 10
>> > secs for ~10 minutes on a idle system.
>> 
>> Ugh.  A real bug then.  These can be a pain to track down and fix. I
>> think the last one of these I tracked down took a couple of weeks.  I
>> will start digging in when I get back from vacation.
>
> OK, fortunately (hopefully) you have not put to much time onto that so
> far - because everything I told about usage of tun and difference
> between ssh and openvpn is complete nonsense.
>
> I happen to have an script in that openvpn config, which puts an ipv6
> address on the vpn device.
>
> Putting an ipv6 address on a device seems to be the trigger:
>
> OrigNS > # ip link add type veth
> OrigNS > # ip link set dev veth0 up
> OrigNS > # unshare -n /bin/bash
> NewNS > # echo $$
> <SomePID>
> OrigNS > # ip link set dev veth1 netns <SomePID> # this, of course is on a different terminal
> NewNS > # ip link set dev veth1 up
> NewNS > # ip -6 addr add dev veth1 fd50:dead:beef::1/64
> NewNS > # exit
>
> Yields
>
> kernel: unregister_netdevice: waiting for veth1 to become free. Usage count = 3
>
> Oh - its veth1 this time, not lo - add an "ip link set up dev lo" in the above scenario just after the unshare, and you get the message with lo.
>
> One might ask, if
>
>> # unshare -n /bin/bash
>> # ip link set up dev lo
>> # ip -6 addr add dev veth1 fd50:dead:beef::1/64
>> # exit
>
> also does the trick, so I tried it - and it does NOT.
>
> In the above scenario, not setting veth0 and veth1 up also makes it not happen. Only setting veth1 up also is not enough (seems to need to be "really up" what as you shurely know with veth is only the case when both sides are up).
>
> I hope, this makes it somewhat easier to track that down.

What puzzles me is that on a slightly patched 2.6.32 (so sysfs works)
and I am doing very similar things (openvpn tunnels, ipv6 to the
network as a whole etc), and I am not seeing the infinite
unregister_netdevice: messages you are talking about.

When a network device is removed most references to it are redirected
to the loopback device so a normal network device should not see the
worst of the problems.  That is why lo showed up.

In that context I'm a bit surprised you managed trigger a problem on veth1.

I wonder what has changed with ipv6 recently.

Eric
