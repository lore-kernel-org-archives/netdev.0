From: jamal <hadi@cyberus.ca>
Subject: Re: SIOCADDMULTI for unicast broken
Date: Mon, 6 Jan 2003 08:44:30 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030105213057.T55522@shell.cyberus.ca>
References: <Pine.LNX.4.44.0301051242180.1081-100000@u.domain.uli>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Donald Becker <becker@scyld.com>, Ben Greear <greearb@candelatech.com>,
   Jeff Garzik <jgarzik@pobox.com>,
   Alexandre Cassen <Alexandre.Cassen@wanadoo.fr>, "" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.44.0301051242180.1081-100000@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Sun, 5 Jan 2003, Julian Anastasov wrote:

>
> 	Hello,
>
> On Sat, 4 Jan 2003, jamal wrote:
>
> > > 	You can do it with arptables (still not sure how) or with
> >
> > I havent seen user-space arptables around.
>
> 	yes, that is what I mean
>
> > > http://www.ssi.bg/~ja/#iparp
> >
> > I like this concept. This + the patch i posted should resolve the problem
> > of getting multiple VRIDs on a single interface.
> > [Although you could do it in a lot less code, maybe 50%, using
> > some of the tc filter extensions i am working on; also a lot less code
> > than arptables]
>
> 	I hope there will be support for altering any bit
> in the skb->head - skb->end area, even by using negative offsets
> based on skb->nh.raw - this is needed for eth header manipulations.
> May be sort of: ... alter andmask 0xFF00 xormask 0x0023 at -4 ...
> i.e. syntax similar to ipchains TOS and u32 match.

I wanted to use u32 as the basis; which means u32 type matching is needed.
then use vi/sed type substitution s/OL/V where:
O =  offset (from skb->data, could be -ve),
L = length (cant go beyond head or end),
V is a static value configured (its size cant exceed L). V can also
be computed off something example the data at offset O. I am trying to
keep away from situations where L is larger or smaller than sizeof V
so theres no mucking with any of the skb pointers ore reallocing etc. In
the next iteration things could change. Note i havent written this but
will in the near future (so anyone is welcome to hack on it)
I didnt understand your andmask and xormask idea...

>
> 	As for VRRP I see it in this way. Note that I'm not a VRRP
> fan, I prefer the ARP methods for takeover, Of course, sometimes they
> can not work due to the bad non-Linux ARP stack implementations.
> As Alexandre noted once, the gratuitous ARP should not be slower
> than VRRP talks. Only that there are bad ARP cache implementations.
>

yes, this is a big problem. But also in some complex multi-vlan switches
grat arps are not sufficient.

> 1. if remote hosts asks for lladdr of VRIP tc should modify our
> ARP reply: the SMAC in the eth header (using negative offset) and the
> SMAC in the ARP header. This is analog to:
> ip arp add to VRIP llsrc VMAC
>

I really like the brevity of the above;
equivalent for me would be (my longterm plan to move ingress to below
IP has finaly found an excuse)
tc filter add <DEV x> parent x:y protocol arp prio 10 u32 flowid x:z \
match sip VRIP action edit s/smac/VMAC action edit s/SMAC/VMAC

u32 needs to be taught about ARP so it can understand different
ARP header bits like sip (shouldnt be that difficult)

>
> 2. if our IP stack sends packet with saddr=VRIP that leads to ARP
> probe sent from our host then we should modify the packet in
> the same way as (1). This is analog to:
> ip arp add table output from VRIP llsrc VMAC
>

Dont see the difference between 1) and 2)

> 3. Replace the src MAC with proper VMAC for all IP packets with
> saddr=VRIP. This can be a neighbouring code job but difficult to
> implement there.

tc filter add <DEV x> parent x:y protocol ip prio 10 u32 flowid x:z \
match ip src VRIP action edit s/smac/VMAC

Did i understand this correctly?

>
> 4. Not last: NIC should accept traffic for all VMACs (promisc
> when attached to switched hubs is enough?) and eth_type_trans to maintain
> list of MAC aliases. I'm not sure that such list/hashtable with MACs
> should be attached per device - may be VRRP needs to announce one
> MAC through different interfaces? Also think for the Bridging
> code which calls eth_type_trans too.

I plan to move ingress to below IP just before the bridging and tap
code; experiments shows this works just fine.
So all the filters + edits going there should work fine. Thoughts?


cheers,
jamal
