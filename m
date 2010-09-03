From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: pskb_expand_head() optimization
Date: Fri, 03 Sep 2010 06:46:33 -0700 (PDT)
Message-ID: <20100903.064633.27806839.davem@davemloft.net>
References: <20100902.204332.02275687.davem@davemloft.net>
	<1283492880.3699.1437.camel@edumazet-laptop>
	<1283504972.2453.257.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59046
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752829Ab0ICNqQ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Sep 2010 09:46:16 -0400
In-Reply-To: <1283504972.2453.257.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 03 Sep 2010 11:09:32 +0200

> Le vendredi 03 septembre 2010 =E0 07:48 +0200, Eric Dumazet a =E9crit=
 :
>=20
>> David, I had this same idea some days ago when reviewing this code,
>> but when I came to conclusion we could not avoid the get_page /
>> put_page() on skb_shinfo(skb)->frags[i].page. I thought it was not w=
orth
>> trying to avoid the frag_list grab/release operation.
>>=20
>=20
> Here is the patch I cooked, for net-next-2.6
>=20
> [PATCH net-next-2.6] net: pskb_expand_head() optimization
>=20
> pskb_expand_head() blindly takes references on fragments before calli=
ng
> skb_release_data(), potentially releasing these references.
>=20
> We can add a fast path, avoiding these atomic operations, if we own t=
he
> last reference on skb->head.
>=20
> Based on a previous patch from David
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Ok, I see how this works now, thanks Eric.  But this looks to be a bit
too complicated to be worthwhile, I think, so let's hold off on this
optimization for a while.

Let me tell you why I was swimming around in this area and what my
ultimate motivation is :-)

In trying to eventually convert sk_buff to list_head one of the
troubling areas is this frag_list business.

Amusingly, if you look, virtually all of the code which constructs
frag_list SKBs wants a doubly linked list so it can insert at the tail
(all LRO gathering, GRO, you name it).

There are only two operations that make a double-linked list currently
impossible.  This pskb_expand_head() thing, and pskb_copy().

They cause the situation where the list is shared between multiple SKB
data shared areas.

And because of this a doubly-linked list like list_head won't work at
all.

=46or the optimized case of pskb_expand_head() you discovered we can av=
oid
this sharing.  And at this point I imagine that for the remaining cases
we can simply copy the full SKBs in the frag list to avoid this list
sharing.

So that's where I'm trying to go in all of this.
