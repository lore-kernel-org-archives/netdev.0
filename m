From: Julian Anastasov <ja@ssi.bg>
Subject: Re: SIOCADDMULTI for unicast broken
Date: Mon, 6 Jan 2003 17:00:30 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0301061624070.24805-100000@l>
References: <20030105213057.T55522@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Donald Becker <becker@scyld.com>, Ben Greear <greearb@candelatech.com>,
   Jeff Garzik <jgarzik@pobox.com>,
   Alexandre Cassen <Alexandre.Cassen@wanadoo.fr>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <20030105213057.T55522@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Mon, 6 Jan 2003, jamal wrote:

> > May be sort of: ... alter andmask 0xFF00 xormask 0x0023 at -4 ...
> > i.e. syntax similar to ipchains TOS and u32 match.
>
> I wanted to use u32 as the basis; which means u32 type matching is needed.
> then use vi/sed type substitution s/OL/V where:
> O =  offset (from skb->data, could be -ve),

	IMO, using skb->nh.raw as basis is preferred. By this way
the filters can be used from different places in the net stack.

> L = length (cant go beyond head or end),
> V is a static value configured (its size cant exceed L). V can also
> be computed off something example the data at offset O. I am trying to
> keep away from situations where L is larger or smaller than sizeof V
> so theres no mucking with any of the skb pointers ore reallocing etc. In

	Yes, changing skb len is problematic mostly for TCP. As
for L and V: I assume they are HEX digits or there will be a way
to encode alphanumeric chars?

> the next iteration things could change. Note i havent written this but
> will in the near future (so anyone is welcome to hack on it)
> I didnt understand your andmask and xormask idea...

The above example:

- goto word at offset -4
- AND the 2 bytes with FF00
- XOR the 2 bytes with 0023

AND+XOR allow any operations for bits:

1) preserving (AND 1 XOR 0)
2) inverting (AND 1 XOR 1)
3) setting (AND 0 XOR 1)
4) clearing (AND 0 XOR 0)

> equivalent for me would be (my longterm plan to move ingress to below
> IP has finaly found an excuse)
> tc filter add <DEV x> parent x:y protocol arp prio 10 u32 flowid x:z \
> match sip VRIP action edit s/smac/VMAC action edit s/SMAC/VMAC
>
> u32 needs to be taught about ARP so it can understand different
> ARP header bits like sip (shouldnt be that difficult)

	Yes, we can teach u32 to know about ARP offsets,
ethhdr offsets...

> > ip arp add table output from VRIP llsrc VMAC
> >
>
> Dont see the difference between 1) and 2)

	No difference for tc, only iparp has this difference because
it follows the routing

> > 3. Replace the src MAC with proper VMAC for all IP packets with
> > saddr=VRIP. This can be a neighbouring code job but difficult to
> > implement there.
>
> tc filter add <DEV x> parent x:y protocol ip prio 10 u32 flowid x:z \
> match ip src VRIP action edit s/smac/VMAC
>
> Did i understand this correctly?

	Yes

> > MAC through different interfaces? Also think for the Bridging
> > code which calls eth_type_trans too.
>
> I plan to move ingress to below IP just before the bridging and tap
> code; experiments shows this works just fine.
> So all the filters + edits going there should work fine. Thoughts?

	I assume just after skb->nh.raw = skb->data;
Also, before or after deliver to ptype_all?

	I see one problem: egress is called after all csum calcs,
bad for IP (if tc is going to damage the payload), good for ethhdr, ARP.

> cheers,
> jamal

Regards

--
Julian Anastasov <ja@ssi.bg>
