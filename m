From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/4 net-next] net: phy: add Generic Netlink Ethernet
 switch configuration API
Date: Sun, 27 Oct 2013 11:14:49 -0700
Message-ID: <CAGVrzcbmsMjB78_x8MoOf4C34OMMZ-+3RBbheA0bG=r5VUi4EQ@mail.gmail.com>
References: <1382466229-15123-1-git-send-email-f.fainelli@gmail.com>
 <1382466229-15123-2-git-send-email-f.fainelli@gmail.com> <5266D7D6.9000309@intel.com>
 <CAGVrzcZS4SGiUFoCnhau1Fvv9F4ffS7tA+PT4r-qLCj8HV8BqQ@mail.gmail.com>
 <20131022202537.GA16336@hmsreliant.think-freely.org> <CAGVrzcaXFboRDn40+VciTes09w-jqTASNZz2GZNpTxbaV6D0Lw@mail.gmail.com>
 <5267B764.305@mojatatu.com> <5267BB53.8030703@openwrt.org>
 <5267C6B9.4000704@mojatatu.com> <5267CFAB.9090100@openwrt.org>
 <5267D8AE.7080009@mojatatu.com> <5267DDE6.70600@openwrt.org>
 <526A5949.6040404@mojatatu.com> <526A6BB3.7050507@openwrt.org> <526D4B06.8040505@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Felix Fietkau <nbd@openwrt.org>,
	Neil Horman <nhorman@tuxdriver.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	John Crispin <blogic@openwrt.org>,
	Jonas Gorski <jogo@openwrt.org>,
	Gary Thomas <gary@mlbassoc.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:52013 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751936Ab3J0SP3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Oct 2013 14:15:29 -0400
Received: by mail-pa0-f53.google.com with SMTP id kx10so3458730pab.40
        for <netdev@vger.kernel.org>; Sun, 27 Oct 2013 11:15:29 -0700 (PDT)
In-Reply-To: <526D4B06.8040505@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/10/27 Jamal Hadi Salim <jhs@mojatatu.com>:
> On 10/25/13 09:01, Felix Fietkau wrote:
>>
>> On 2013-10-25 1:43 PM, Jamal Hadi Salim wrote:
>
>
>> I think it's common for the switch to have a global MAC address, not a
>> per-port one.
>
>
> Ok, I see. Real cheep.

They are yes, the only "fancy" features these switches allow is
basically to set a given's port vlan id, which is already a huge
improvement compared to the vendor provided firmware.

>
>
>> 'won't pass up the tag'? The switch is treated in pretty much the same
>> way as a normal managed standalone switch (you know, one you can buy in
>> a shop and plug your Ethernet cable into).
>> You simply tell it, which VLANs to put on which ports, and make the
>> ports tagged or untagged.
>> The link between the switch and the CPU is not really special, for the
>> switch it's just another port. This way of configuring works with pretty
>> much all switches that we're using.
>
>
> So does it get its own MAC address? Other than flooding broadcasts,
> how does one end up sending packets to the cpu?

The switch does have an address learning process which is usually not
controlled by software at all, so yes, flooding is usually the way to
get it to the CPU.

>
>
>> Yes, some switches have them, and they can be useful when dealing with
>> multiple VLANs.
>
>
> Very nice. So we go from one extreme of cheep to sophisticated ;->
> I think the only way you can achieve multiple tables on the bridge
> is by creating multiple bridges.
>
>
>> No, because the connection between the CPU and the switch is handled by
>> a normal Ethernet MAC. The Ethernet chip doesn't care if there's a
>> switch connected to it, or a regular PHY.
>> It's just a normal MII connection, nothing more.
>>
> [..]
>
>>
>> Right, the netdev that owns the PHY is a normal Ethernet MAC, running
>> any normal Linux Ethernet driver.
>>
> [..]
>
>> I remain absolutely unconvinced that this will make the end result
>> better. Right now, these switches act like separate devices, because
>> aside from the fact that they're put on the same board with other
>> components, they pretty much *are* separate devices.
>>
>> You seem to insist on treating it as a kind of port multiplexer + bridge
>> accelerator instead of a mostly standalone switch.
>>
>
>
> Yes, the above is the point i was making.
> I apologize for sounding like a broken record, but to just re-iterate:
> there are, if i recall correctly, several drivers  in the kernel
> which are challenged as such (with single entry point into the CPU)
> which expose multiple netdevs with the driver acting as mux point.

Which exact drivers are you refering to? If we are talking about DSA
then yes, this is correct, but it is completely Ethernet MAC driver
agnostic.

>
>
>> This may work for some devices, but on others this simply a model that
>> the hardware wasn't designed for.
>
>
> I agree. But what i just described above is not new. A lot of embedded
> multiport NICs tend to be handicapped in exactly the same way.

Why would we expose the hardware switch physical ports as netdevs if
we cannot even any control over their data-path? Unlike these
multiport NICs, the only traffic you see and you can control is the
one from your CPU port.

>
>
>> Sure, we could try to cram in all
>> those special cases, extra options, and hack through the layers where
>> they're in the way. If *all* you care about is being able to reuse the
>> existing interfaces, that might even seem like a good idea.
>>
>
> I do care a lot about using existing interfaces ;-> Great usability
> for someone to run a tool that has been around for 20 years and it
> works. If i can just reuse my scripts without having to invent
> new ones etc etc.

I do not really see how we could bend the existing interface (is it
rtnetlink we are talking about or something else btw?) to expose these
switches, maybe we could with iproute2, but still, the user-space
interface/tool is far from being the problem here.


>
>
>> On the other hand, I've pointed out quite a few examples where the model
>> of trying to cram it into the bridge API is just a bad fit in general.
>>
>
> Sorry Felix, nothing you described is insurmountable.
> The challenge here is non-technical:
> You already have code that has been proven and is deployed for what appears
> to be sometime now.
> I totally empathize.

I don't think at any point in this discussion there was a mention that
we do not want to change the user or kernel interface in OpenWrt
because we have been using this for the past 5 years, on the contrary,
if we are bringing this to a wide audience, this is to get some proper
review and eventually change it.
-- 
Florian
