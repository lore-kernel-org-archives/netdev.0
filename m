From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH]  802.1Q VLAN
Date: Fri, 29 Oct 2004 17:05:18 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4182DABE.7000502@candelatech.com>
References: <41797696.9070905@candelatech.com>	 <20041022214611.GA4948@electric-eye.fr.zoreil.com>	 <41798506.1030909@candelatech.com> <417D675F.3000909@candelatech.com>	 <4181838B.6040002@tpack.net>  <41818D99.9020300@candelatech.com> <1099038566.1813.99.camel@cyan.cph.tpack.net> <418281C1.9080707@candelatech.com> <4182D44E.7070507@tpack.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>,
        "Linux 802.1Q VLAN" <vlan@candelatech.com>,
        Francois Romieu <romieu@fr.zoreil.com>,
        "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Tommy Christensen <tommy.christensen@tpack.net>
In-Reply-To: <4182D44E.7070507@tpack.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Tommy Christensen wrote:
> Ben Greear wrote:
> 
>> Tommy Christensen wrote:

>>> A return value > zero doesn't mean failure. It indicates congestion.
>>
>>
>>
>> Ok, but the skb is always deleted by the net_queue_xmit code if the
>> return is not zero?  The difference between a hard-start-xmit failure
>> on eth0 when the hardware-queue is full and having a rate-limiting
>> queue drop a packet is virtually identical to me....
> 
> 
> For a virtual device: yes, dev_queue_xmit() drops the skb. What else
> could it do with it? The semantic is that dev_queue_xmit always consumes
> skb's given to it.
> 
> A physical device will have a qdisc attached to it, so you don't get to
> see that the hardware queue is full. qdisc handles this case for you by
> retrying the transmission later. This is not (yet) congestion.
> OTOH if qdisc doesn't have room for a new skb in its *software* queue,
> the skb is dropped and congestion is reported upwards the stack.

Can't you also add a queue to a VLAN device?

eth1.1009 Link encap:Ethernet  HWaddr 00:07:E9:1F:CE:02
           inet addr:172.100.1.109  Bcast:172.100.1.255  Mask:255.255.255.0
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:2000
           RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)

I see fairly high latency when I overdrive the network, but it does seem to
work just fine.


>> pktgen registers this hook on the physical device when it starts 
>> generating on
>> the physical device or any VLANs attached to it.  To make a scheme 
>> like this work
>> in general, we'd probably need a chain of callbacks instead of a 
>> single method
>> pointer...
> 
> 
> Nice. This idea is definitely worth persuing. However, ideally we
> would want to be notified when the *qdisc* queue opens up - this
> is our "tx ring buffer".

Maybe the qdisc could automatically flush what it could to lower
level devices/queues whenever it was asked to enqueue a packet?
This way, waking the writers could automatically wake the various
queues under the writers.

That could be happening already, and might explain why my pktgen hacks
work.

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
