From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: Re: [PATCH] Fix ARM BUILD_BUG_ON() errors with
	batman-adv
Date: Mon, 2 Dec 2013 18:58:47 +0100
Message-ID: <201312021858.48074.sw@simonwunderlich.de>
References: <20131130191553.GA16735@n2100.arm.linux.org.uk>
 <20131130.160547.837987320410619405.davem@davemloft.net>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org, mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org, antonio-x4xJYDvStAgysxA8WJXlww@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20131130.160547.837987320410619405.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

David,

> From: Russell King - ARM Linux <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
> Date: Sat, 30 Nov 2013 19:15:53 +0000
> 
> > so there should be no undesired side effect from this packing.
> 
> There is a huge side effect from ever using the packed attribute, in
> that the compiler can assume absolutely nothing about the alignment of
> any object or sub-object of the type you apply this attribute to.
> 
> Even if it is "obvious" that some members will be aligned, the
> compiler cannot take advantage of this assumption because this
> attribute also means that an array of such elements might have
> arbitrary alignment.  So you when you get a pointer to one of these
> objects, the compiler has to assume the worst possible case.
> 
> This means using 4 byte loads to load a 32-bit quantity, always,
> unconditionally, no matter what.
> 
> That's why we should do whatever is necessary to align things properly
> by hand, and use packed only as the last possible and least desirable
> resort.

so far we have two feasible options how to handle batadv_header:

 1) Russells patch
 2) unrolling these 3 bytes of header into every packet structure

I understand your concerns for __packed in generally, but in this case it 
might not be that bad:

 * batadv_header is only used by embedding it in other structs (like 
batadv_unicast_packet, batadv_broadcast_packet ...) which are well aligned - I 
guess there should be no performance problem when accessing through the parent 
structure (like unicast_packet->header.version)
 * there is one exception in batadv_interface_rx() where we use this 
batadv_header directly, but we can easily replace that by using e.g. 
batadv_bcast_packet instead.
 * It's easier to read and maintain than copying these 3 bytes in every other 
structure.

Therefore I'd suggest to pick Russels patch, I can send a fix for 
batadv_interface_rx() later, too.

Thanks,
    Simon
