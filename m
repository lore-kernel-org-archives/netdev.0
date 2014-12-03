From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net] gso: do GSO for local skb with size bigger than MTU
Date: Wed, 3 Dec 2014 14:51:39 -0800
Message-ID: <CAEP_g=90nC2HhmBNKh-hKJ5MJ85Z-_ER14roDxMsZAKog+dFhw@mail.gmail.com>
References: <20141201135225.GA16814@casper.infradead.org> <20141202154839.GB5344@t520.home>
 <20141202170927.GA9457@casper.infradead.org> <20141202173401.GB4126@redhat.com>
 <20141202174158.GB9457@casper.infradead.org> <CAEP_g=-86Z6pxNow-wjnbx_v9er_TSn6x5waigqVqYHa7tEQJw@mail.gmail.com>
 <20141203090339.GA9299@redhat.com> <CAEP_g=9C+D3gbjJ4n1t6xuyjqEAMYi4ZfqPoe92UAoQJH-UsKg@mail.gmail.com>
 <20141203183859.GB16447@redhat.com> <CAEP_g=_Y2YQg0wDRJLXsNH6p3fOc5G0KSJb12x_b4OE238ophg@mail.gmail.com>
 <20141203220244.GA8822@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	"Du, Fan" <fan.du@intel.com>, Jason Wang <jasowang@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"fw@strlen.de" <fw@strlen.de>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	Pravin Shelar <pshelar@nicira.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog008.obsmtp.com ([74.125.150.56]:42949 "HELO
	na6sys009bog008.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751088AbaLCWwA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 17:52:00 -0500
Received: by mail-qg0-f48.google.com with SMTP id q107so11870515qgd.35
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 14:51:59 -0800 (PST)
In-Reply-To: <20141203220244.GA8822@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 3, 2014 at 2:02 PM, Thomas Graf <tgraf@suug.ch> wrote:
> On 12/03/14 at 11:38am, Jesse Gross wrote:
>> On Wed, Dec 3, 2014 at 10:38 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
>> > Both approaches seem strange. You are sending 1 packet an hour to
>> > some destination behind 100 tunnels. Why would you want to
>> > cut down your MTU for all packets? On the other hand,
>> > doubling the amount of packets because your MTU is off
>> > by a couple of bytes will hurt performance significantly.
>> >
>> > Still, if you want to cut down the MTU within guest,
>> > that's only an ifconfig away.
>> > Most people would not want to bother, I think it's a good
>> > idea to make PMTU work properly for them.
>>
>> I care about correctness first, which means that an Ethernet link
>> being exposed to the guest should behave like Ethernet. So, yes, IPX
>> should work if somebody chooses to do that.
>>
>> Your comments are about performance optimization. That's fine but
>> without a correct base to start from it seems like putting the cart
>> before the horse and is hard to reason about.
>
> I agree with Jesse in particular about correctnes but Michael has a
> point (which I thing nobod objects to) which is that it may not always
> make sense to force the MTU onto the guest. It clearly makes sense for
> the edge server connected to an overlay but it may not be ideal if
> WAN traffic is VXLAN encapped and local DC traffic is put onto a VLAN.

The question is whether you would do this in a single L2 segment. It's
possible, of course, but probably not a great idea and I'm not sure
that it's really worth optimizing for. We do have one existing example
of this type of MTU reduction - the bridge device when you attach
multiple devices with varying MTUs (including a VXLAN device). In that
case, the bridge device is effectively acting as a connection point,
similar to virtio in a VM.

My proposal would be something like this:
 * For L2, reduce the VM MTU to the lowest common denominator on the segment.
 * For L3, use path MTU discovery or fragment inner packet (i.e.
normal routing behavior).
 * As a last resort (such as if using an old version of virtio in the
guest), fragment the tunnel packet.
