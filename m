From: Patrick Schaaf <bof@bof.de>
Subject: Re: TODO list before feature freeze
Date: Tue, 30 Jul 2002 09:26:24 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020730092624.A263@oknodo.bof.de>
References: <20020729131239.A5183@wotan.suse.de> <200207291525.g6TFPTTu011558@marajade.sandelman.ottawa.on.ca> <20020729225147.A24288@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com,
   netfilter-core@lists.netfilter.org
Return-path: <owner-netdev@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <20020729225147.A24288@wotan.suse.de>; from ak@suse.de on Mon, Jul 29, 2002 at 10:51:47PM +0200
List-Id: netdev.vger.kernel.org

> Unfortunately netfilter hash is a bad example for this, because its
> DoS handling requirements (LRU etc.) are more complex than what most other 
> linux hash tables need and I am not sure if it would make sense to 
> put it into generic code.

There is actually one issue with the current netfilter hash code:

The code intentionally does not 0 out the next pointer when
a conntrack is removed from the hashes; only new, never-yet-hashed
conntracks have their next field be 0, and the confirm logic relies
on that. Could be easily changed to use an appropriate flag bit in
struct ip_conntrack.

As a consequence, the single linked list I'm prototyping must be a
ring list, with the hash bucket pointer within the list - same scheme
as with the doubly linked list. It's oopsing on me as I type :)

A non-ring implementation would be smaller, so I think we really want
that flag bit for the confirmations.  Rusty?

All other cases could be handled by a general hash implementation
with per-list-entry user supplied comparison callback, and a
per-table hash function.

I'm sure that any real DoS handling will work by varying constants
used in the hash function. That's the result of the recent "abcd"
hashing work.

The thing that worries me, even with the current setup, is the idea of
a general boottime sizing of all such general hash tables.  The things
are hard to override once loaded, so sizes must fit what's needed in
the real world, and that's over a _mix_ of various tables that all
play together under this or that workload.  Maybe runtime rehashing
is the way to go here, to make this fully adaptive.

best regards
  Patrick
