From: Julian Anastasov <ja@ssi.bg>
Subject: Re: SIOCADDMULTI for unicast broken
Date: Sun, 5 Jan 2003 13:45:45 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0301051242180.1081-100000@u.domain.uli>
References: <20030104135539.C48869@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Donald Becker <becker@scyld.com>, Ben Greear <greearb@candelatech.com>,
   Jeff Garzik <jgarzik@pobox.com>,
   Alexandre Cassen <Alexandre.Cassen@wanadoo.fr>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <20030104135539.C48869@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Sat, 4 Jan 2003, jamal wrote:

> > 	You can do it with arptables (still not sure how) or with
>
> I havent seen user-space arptables around.

	yes, that is what I mean

> > http://www.ssi.bg/~ja/#iparp
>
> I like this concept. This + the patch i posted should resolve the problem
> of getting multiple VRIDs on a single interface.
> [Although you could do it in a lot less code, maybe 50%, using
> some of the tc filter extensions i am working on; also a lot less code
> than arptables]

	I hope there will be support for altering any bit
in the skb->head - skb->end area, even by using negative offsets
based on skb->nh.raw - this is needed for eth header manipulations.
May be sort of: ... alter andmask 0xFF00 xormask 0x0023 at -4 ...
i.e. syntax similar to ipchains TOS and u32 match.

	As for VRRP I see it in this way. Note that I'm not a VRRP
fan, I prefer the ARP methods for takeover, Of course, sometimes they
can not work due to the bad non-Linux ARP stack implementations.
As Alexandre noted once, the gratuitous ARP should not be slower
than VRRP talks. Only that there are bad ARP cache implementations.

1. if remote hosts asks for lladdr of VRIP tc should modify our
ARP reply: the SMAC in the eth header (using negative offset) and the
SMAC in the ARP header. This is analog to:
ip arp add to VRIP llsrc VMAC

2. if our IP stack sends packet with saddr=VRIP that leads to ARP
probe sent from our host then we should modify the packet in
the same way as (1). This is analog to:
ip arp add table output from VRIP llsrc VMAC

3. Replace the src MAC with proper VMAC for all IP packets with
saddr=VRIP. This can be a neighbouring code job but difficult to
implement there.

4. Not last: NIC should accept traffic for all VMACs (promisc
when attached to switched hubs is enough?) and eth_type_trans to maintain
list of MAC aliases. I'm not sure that such list/hashtable with MACs
should be attached per device - may be VRRP needs to announce one
MAC through different interfaces? Also think for the Bridging
code which calls eth_type_trans too.

5. Enough from one who don't like VRRP :)

> With two conecpts being addressed i.e patch like that you have +
> the patch i posted i dont see any orther reason VRRP to be hindered.

	Not sure, may be the only remaining is (3).

> cheers,
> jamal

Regards

--
Julian Anastasov <ja@ssi.bg>
