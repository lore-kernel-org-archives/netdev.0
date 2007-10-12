From: kristrev@student.matnat.uio.no
Subject: Re: Non-linear SKBs
Date: Fri, 12 Oct 2007 15:15:27 +0200 (CEST)
Message-ID: <50601.129.240.228.53.1192194927.squirrel@webmail.uio.no>
References: <470EA9AD.4020304@ifi.uio.no>
    <20071011.170024.38701852.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: kristrev@student.matnat.uio.no, netdev@vger.kernel.org,
	linux-net@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <20071011.170024.38701852.davem@davemloft.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> If the underlying device can do scatter-gather and checksumming,
> the TCP code builds outgoing packets by copying user date into
> full system pages, and then attaching those pages into the SKB.
> The protocol headers sit under the skb->data linear area, and
> the user data mostly sits in the user pages under
> skb_shinfo(skb)->frags[]
>
> This increases the density of data packed into the memory allocated
> compared to using skb->data for it.  It also enormously simplifies
> the logic necessary to support TSO.

Thank you very much, I think I am starting to get it now and coming to
think of it this will make my patch much more elegant. I have spent the
day reading more code, and am wondering if something along the likes of
this piece of code will do what I want ("copy" the data from the next skb
in the retransmission queue into this skb):

//Do preliminary checks to see if the "new" packet will be within mss,
that this_skb->nr_frags + next_skb->nr_frags < MAX_SKB_FRAGS and so on

int i;
int this_frags = this_skb->nr_frags;

for(i=0; i<next_skb->nr_frags; i++)
        //Does the "copy"
        this_skb->frags[this_frags + i] = next_skb->frags[i];

this_skb->data_len += next_skb->data_len;
this_skb->truesize += next_skb->data_len;
this_skb->nr_frags += next_skb->nr_frags;

//Update TSO?

By the way, am I correct in my assumption that one SKB's frags is stored
linearly in the frags-array? Or have I made a horrible misunderstanding?
:)

One of the things that I have yet to understand is the frag_list in the
skb_shared_info-struct. Does this contain all skb's that "use" this frag
and works as a sort of referance counter (frag won't be removed until the
variable is NULL and I have to append this_skb to the list), or is it
something else?

Thanks again for all help.

-Kristian

