From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PKT_SCHED]: Allow using nfmark as key in U32 classifier.
Date: Wed, 29 Dec 2004 13:48:42 +0100
Message-ID: <20041229124842.GI32419@postel.suug.ch>
References: <20041228161117.GD32419@postel.suug.ch> <1104251817.1090.164.camel@jzny.localdomain> <20041228192603.GE32419@postel.suug.ch> <1104268498.1090.254.camel@jzny.localdomain> <20041228221021.GF32419@postel.suug.ch> <1104275197.1100.276.camel@jzny.localdomain> <20041228231916.GG32419@postel.suug.ch> <1104277165.1100.291.camel@jzny.localdomain> <20041229000928.GH32419@postel.suug.ch> <1104282811.1090.314.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1104282811.1090.314.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1104282811.1090.314.camel@jzny.localdomain> 2004-12-28 20:13
> no problem ;-> I think the effort is the same as in doing it the other
> way - only result is more sophisticated. I havent investigated the other
> classifiers - u32 tends to be more complex, so solving it on u32 solves
> all the others typically.

OK, I've changed my mind after some thinking. It's little bit more work
but it's worth it. The ematch TLV contains an array of ematches, every
ematch contains the logic relation to the next (2 bits) and a flag to
invert the meaning (1 bit). A special ematch containing an index exists
to implement precdence.

A AND (B1 OR B2) AND C AND D


              ------->-PUSH-------
    -->--    /         -->--      \   -->--
   /     \  /         /     \      \ /     \
+-------+-------+-------+-------+-------+--------+
| A AND | B AND | C AND | D END | B1 OR | B2 END |
+-------+-------+-------+-------+-------+--------+
                    \                      /
                     --------<-POP---------

A simple check that a jump index is never smaller than the current
index (excluding backward jumps via stack) catches endless loop
and avoids the use of a ttl.


> Remember two levels: 
> 1) the classifier logical expressions (u32 and rsvp for example) - those
> belong to cls api.
> 
> if u32 match .. ... AND rsvp ... OR route ...
> evaluation is left to right with some brute logical OR and ANDs via the
> continue and reclassify codes.
> 
> 2) This issue is at a the single classifier/filter level, so its fair to
> push that into the classifier logic. an extended match cannot live by
> itself. Its parasitic on a real classifier - so the scope MUST be
> restricted to classifier as a matter of fact.

Absolutely agreed, I did a context switch without prior warning. ;->

> Or you could have:
> match u32 OR
> (ematch meta nfmark .. or string "...")
> match u32 ..
> 
> Recall, the opportunity to do more in terms of logical expressions within u32 
> exists because we can introduce more interesting keys ...

We could reuse the 8 unused bits after nkeys in tc_u32sel too. iproute2 sets
them to 0 so we can simply use them without anyone noticing.

> I dont know where you and Patrick are with the code but it think it
> would be safe for me to work off 2610-bk1. Tommorow i am working on some
> e1000 stuff - but day after i should be able to touch the action code. 

I'm not touching the action bits but Patrick is as far as I know.
