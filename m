From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH + RFC] neighbour/ARP cache scalability
Date: Tue, 21 Sep 2004 20:31:18 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040921203118.734a0a7e.davem@davemloft.net>
References: <20040920225140.GH1307@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@gnumonks.org>
In-Reply-To: <20040920225140.GH1307@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Ok Harald, I did some snooping around and here is what
I've come up with.

1) We have 5 or 6 implementations of "walk neighbour hash
   table in sequence", that's rediculious and is the only
   reason that hashtable layout or number of entries is
   even known by code outside of net/core/neighbour.c

   In fact, many cases get it wrong :(  For example, the
   ARP seq_file stuff locks the normal hash table correctly
   but does zero locking when traversing the pneigh hashes.
   Oops.  Another reason to put this logic in a common spot.

   So I think the first thing to do is to write table
   walker functions generically inside of net/core/neighbour.c

   This is the first step.

1.5) tbl->ops->hash() should return the raw hash, the caller
     will do the necessary masking.

     At this point, there is no reason to declare
     {P,}NEIGH_HASHMASK in net/neighbour.h

2) We should size these hash table dynamically, growing them
   at neigh_create() time.

   This makes the most sense, and the scheme is similar to how
   net/ipv4/fib_hash.c works, for example.

3) If we have a sysctl for this stuff at all, it will be for
   the limit of the hash table growth, but I don't think that
   is necessary given #2

I like the jenkins hash change and yes I think it should be applied
elsewhere too.

I'll work on the set of patches implementing the above tomorrow
and will send it to the list for review and commentary.
