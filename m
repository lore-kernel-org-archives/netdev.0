From: jamal <hadi@cyberus.ca>
Subject: Re: SIOCADDMULTI for unicast broken
Date: Mon, 6 Jan 2003 12:23:19 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030106121218.R57730@shell.cyberus.ca>
References: <Pine.LNX.4.44.0301061624070.24805-100000@l>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Donald Becker <becker@scyld.com>, Ben Greear <greearb@candelatech.com>,
   Jeff Garzik <jgarzik@pobox.com>,
   Alexandre Cassen <Alexandre.Cassen@wanadoo.fr>, "" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.44.0301061624070.24805-100000@l>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Julian,

On Mon, 6 Jan 2003, Julian Anastasov wrote:

>
> 	Hello,
>
> On Mon, 6 Jan 2003, jamal wrote:
>
> > > May be sort of: ... alter andmask 0xFF00 xormask 0x0023 at -4 ...
> > > i.e. syntax similar to ipchains TOS and u32 match.
> >
> > I wanted to use u32 as the basis; which means u32 type matching is needed.
> > then use vi/sed type substitution s/OL/V where:
> > O =  offset (from skb->data, could be -ve),
>
> 	IMO, using skb->nh.raw as basis is preferred. By this way
> the filters can be used from different places in the net stack.

Makes sense, let me think about it more and maybe experiment.
"different places in the stack"? I was thinking only ingress or egress.

>
> > L = length (cant go beyond head or end),
> > V is a static value configured (its size cant exceed L). V can also
> > be computed off something example the data at offset O. I am trying to
> > keep away from situations where L is larger or smaller than sizeof V
> > so theres no mucking with any of the skb pointers ore reallocing etc. In
>
> 	Yes, changing skb len is problematic mostly for TCP. As
> for L and V: I assume they are HEX digits or there will be a way
> to encode alphanumeric chars?
>

We leave that to user space. User space can translate from strings for
example into hex. But yes, hex should be the default as is now.

> > the next iteration things could change. Note i havent written this but
> > will in the near future (so anyone is welcome to hack on it)
> > I didnt understand your andmask and xormask idea...
>
> The above example:
>
> - goto word at offset -4
> - AND the 2 bytes with FF00
> - XOR the 2 bytes with 0023
>
> AND+XOR allow any operations for bits:
>
> 1) preserving (AND 1 XOR 0)
> 2) inverting (AND 1 XOR 1)
> 3) setting (AND 0 XOR 1)
> 4) clearing (AND 0 XOR 0)
>

Ok, makes sense and oughta be used.

> > u32 needs to be taught about ARP so it can understand different
> > ARP header bits like sip (shouldnt be that difficult)
>
> 	Yes, we can teach u32 to know about ARP offsets,
> ethhdr offsets...

ethheaders are i think generic enough to be done first.

>
> > I plan to move ingress to below IP just before the bridging and tap
> > code; experiments shows this works just fine.
> > So all the filters + edits going there should work fine. Thoughts?
>
> 	I assume just after skb->nh.raw = skb->data;
> Also, before or after deliver to ptype_all?

yes before ptype_all i.e the first thing. But it could be a
programmability thing where you at least allow ptype_all to see things.

>
> 	I see one problem: egress is called after all csum calcs,
> bad for IP (if tc is going to damage the payload), good for ethhdr, ARP.
>

well unless you pass options to recalculate csums or make csum an
action by itself. I am thinking of "auxillary" actions which could
be done by all actions - this could be one of them; logging is another;
"change classid" is another.
Lets take this discussion offline, i think we have exceeded the topic
that started it all and people are hitting "D"s.

cheers,
jamal
