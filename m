From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [patch v1, kernel version 3.2.1] net/ipv4/ip_gre: Ethernet multipoint GRE over IP
Date: Mon, 16 Jan 2012 13:30:07 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6D8AF46@saturn3.aculab.com>
References: <1326719999.2255.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Alexey Kuznetsov" <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>,
	"James Morris" <jmorris@namei.org>,
	"Hideaki YOSHIFUJI" <yoshfuji@linux-ipv6.org>,
	"Patrick McHardy" <kaber@trash.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>,
	=?ISO-8859-2?Q?=A9tefan_Gula?= <steweg@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <1326719999.2255.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > +	for (i = 0; i < GRETAP_BR_HASH_SIZE; i++) {
> > +		struct ipgre_tap_bridge_entry *entry;
> > +		struct hlist_node *h, *n;
> > +		hlist_for_each_entry_safe(entry, h, n,
> > +			&tunnel->hash[i], hlist)
> > +		{
> > +			unsigned long this_timer;
> > +			this_timer = entry->ageing_timer + delay;
> > +			if (time_before_eq(this_timer, jiffies))
> > +				ipgre_tap_bridge_delete(entry);
> > +			else if (time_before(this_timer, next_timer))
> > +				next_timer = this_timer;
> > +		}
> > +	}
> > +	spin_unlock_bh(&tunnel->hash_lock);
> > +	mod_timer(&tunnel->gc_timer, round_jiffies(next_timer + HZ/4));
> 
> wow... why setup a 250 ms timer, if entries are valid 300 seconds ?

Isn't that code trying to wakeup 250ms after the first expiry of any
of its items?

Do you even need a timer at all?

It may be enough to just put a timestamp into each entry
and tidy up when scanning one of the hash chains in (say)
the 'add item' path - when you need write access anyway.

A hash table might not be the best structure either!
The hash lookup is still o(n) for n >> table_size.
It also may be likely that you'll do repeated lookups for a small
number of items - in which case using a hash to cache recent lookups
might be useful (maybe with some type of balanced tree structure)

	David
