From: Patrick Schaaf <bof@bof.de>
Subject: Re: TODO list before feature freeze
Date: Tue, 30 Jul 2002 14:27:58 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020730142758.A492@oknodo.bof.de>
References: <20020729182659.D570@oknodo.bof.de> <Pine.GSO.4.30.0207300750240.15727-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick Schaaf <bof@bof.de>, Andi Kleen <ak@suse.de>,
   Rusty Russell <rusty@rustcorp.com.au>, netfilter-devel@lists.netfilter.org,
   netdev@oss.sgi.com, netfilter-core@lists.netfilter.org
Return-path: <owner-netdev@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <Pine.GSO.4.30.0207300750240.15727-100000@shell.cyberus.ca>; from hadi@cyberus.ca on Tue, Jul 30, 2002 at 07:58:42AM -0400
List-Id: netdev.vger.kernel.org

> What i have seen and reported by many people (someone seems to have gone
> one step further and documented numbers, but cant find his email right
> now). Take Linux as a router, it routes at x% of wire rate. Load
> conntracking and watch it go down another 25% at least.

Unfortunately, this is insufficient information to pin down what was
happening. As Andi Kleen mentioned, a simple kernel profile from such
a test would be a good start.

Most likely things leading to such a result, in no specific suborder:

- skb linearization
- always-defragment
- ip_conntrack_lock contention
- per-packet timer management

I'm not personally interested in line rate routing, but I look forward
to further results from such setups. I concentrate on real server work-
loads, because that's where my job is.

> I think hashing is one of the problems. What performance improvemet are
> you seeing? (couldnt tell from looking at your data)

We found that the autosizing tends to make the bucket count a multiple
of two, and we found the currently used hash function does not like
that, resulting in longer average bucket list lengths than neccessary.
The crc32 hashes, and suitable modified abcd hashes, don't suffer from
this deficiency, and they are almost identical to random (a pseudohash
I used to depict the optimum).

However, the "badness" of the current hash, given my datasets, results
in less than one additional list element, on average. So we could save
one memory roundtrip. Given that with my netfilter hook statistics patch,
I see >3000 cycles (1Ghz processor) spent in ip_conntrack_in - about
10 memory round-trips - I don't think that you could measure the hash
function improvement, except for artificial test cases.

We can improve here, but not much. Changing the hash function is mostly
interesting to make hash bucket length attacks more unlikely.  The abcd
hash family, with boottime chosen multipliers, could be of use here.

best regards
  Patrick
