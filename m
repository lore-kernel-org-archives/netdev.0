From: Michael Bellion and Thomas Heinz <nf@hipac.org>
Subject: Re: [RFC] High Performance Packet Classifiction for tc framework
Date: Wed, 06 Aug 2003 00:21:56 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F302E04.1090503@hipac.org>
References: <200307141045.40999.nf@hipac.org>	 <1058328537.1797.24.camel@jzny.localdomain>  <3F16A0E5.1080007@hipac.org>	 <1059934468.1103.41.camel@jzny.localdomain>  <3F2E5CD6.4030500@hipac.org> <1060012260.1103.380.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig2AA484285077C06548045724"
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1060012260.1103.380.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig2AA484285077C06548045724
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi Jamal

You wrote:
> I promise i will. I dont think i will do it justice spending 5 minutes
> on it. I take it you have written extensive docs too ;->

Of course ;-)
Well, actually we are going to present an overview of the hipac
algorithm at the netfilter developer workshop in Budapest.
Hope to see you there.

> Unfortunately it is more exciting to write code than documents. I almost
> got someone to document at least its proper usage but they backed away
> at the last minute.

lol

> I dont wanna go in a lot of details, but one important detail is that
> keynodes can also lead to other hash tables. So you can split the packet
> parsing across multiple hashes - this is where the comparison with
> chains comes in. There are several ways to do this. I'll show you the
> brute force way and you can make it more usable with "hashkey" and
> "sample" operator. Stealing from your example:
> 
> [example snipped]
> 
> Makes sense?

Yes, it does. Still the question is how to solve this
generally. Consider the following example ruleset:

1) src ip 10.0.0.0/30 dst ip 20.0.0.0/20
2) src ip 10.0.0.0/28 dst ip 20.0.0.0/22
3) src ip 10.0.0.0/26 dst ip 20.0.0.0/24
4) src ip 10.0.0.0/24 dst ip 20.0.0.0/26
5) src ip 10.0.0.0/22 dst ip 20.0.0.0/28
6) src ip 10.0.0.0/20 dst ip 20.0.0.0/30

So you have 1 src ip hash and #buckets(src ip hash) many
dst ip hashes. In order to achieve maximum performance
you have to minimize the number of collisions in the
hash buckets. How would you choose the hash function
and what would the construction look like?

In principle the tree of hashes approach is capable to
express a general access list like ruleset, i.e. a set
of terminal rules with different priorities. The problem
is that the approach is only efficient if the number of
collisions is O(1) -> no amortized analysis but rather
per bucket.

In theory you can do the following. Let's consider one
dimension. The matches in one dimension form a set of
elementary intervals which are overlapped by certain rules.
Example:

          |------|                      |---------|
      |----------------|
             |------------------|
                           |---------------|

|----|---|--|---|-----|---|----|-------|--|------|-------|

The '|-----|' reflect the matches and the bottom line
represents the set of elementary intervals introduced
by the matches. Now, you can decide for each elementary
interval which rule matches since the rules are terminal
and uniquely prioritized.

The next step would be to create a hash with #elementary
intervals many buckets and create a hash function which
maps the keys to the appropriate buckets like in the picture.
In this case you have exactly 1 entry per hash bucket.
Sounds fine BUT it is not possible to generically deduce
an easily (= fast) computable hash function with the
described requirements.

BTW, this approach can be extended to 2 or more dimensions
where the hash function for each hash has to meet the
requirement. Of course this information is not very helpful
since the problem of defining appropriate hash functions
remains ;)

Obviously this way is not viable but supposedly the only
one to achieve ultimate performance with the tree of hashes
concept.

BTW, the way hipac works is basically not so different
from the idea described above but since we use efficient
btrees we don't have to define hash functions.

> sure position could be used as a priority. It is easier/intuitive to
> just have explicit priorities.

Merely a matter of taste. The way iptables and nf-hipac use
priorities is somewhat more dynamic than the tc way because
they are automatically adjusted if a rule is inserted in between
others.

> What "optimizes" could be a user interface or the thread i was talking
> about earlier.

Hm, this rebalancing is not clear to us. Do you want to rebalance
the tree of hashes? This seems a little strange at the first
glance because the performance of the tree of hashes is dominated
by the number of collisions that need to be resolved and
not the depth of the tree.

> Is your plan to put this in other places other than Linux?

Currently we are working on the integration in linux.
In general the hipac core is OS and application independent,
so basically it could also be used for some userspace program
which is related to classification and of course in other OS's.

Any special reason why you are asking this question?

> So you got this thought from iptables and took it to the next level?

Well, in order to support iptables matches and targets we had
to create an appropriate abstraction for them on the hipac
layer. This abstraction can also be used for tc classifiers
if the tcf_result is ignored, i.e. you just consider whether
the filter matched or not.

> I am still not sure i understand why not use what already exists - but
> i'll just say i dont see it right now.

If hipac had no support for embedded classifiers you couldn't
express a ruleset like:
1) [native hipac matches] [u32 filter] [classid]
2) [native hipac matches] [classid]
You would have to construct rule 1) in a way that it "jumps"
to an external u32 filter. Unfortunately, you cannot jump
back to the hipac filter again in case the u32 filter does
not match so rule 2) is unreachable. This problem is caused
by the fact that cls_hipac can occur at most once per interface.

> It doesnt appear harmful to leave it there without destroying it.
> The next time someome adds a filter of the same protocol + priority, it
> will already exist. If you want to be accurate (because it does get
> destroyed when the init() fails), then destroy it but you need to put
> checks for "incase we have added a new tcf_proto" which may not look
> pretty. Is this causing you some discomfort?

No, actually not.


Regards,

+-----------------------+----------------------+
|   Michael Bellion     |     Thomas Heinz     |
| <mbellion@hipac.org>  |  <creatix@hipac.org> |
+-----------------------+----------------------+
|    High Performance Packet Classification    |
|       nf-hipac: http://www.hipac.org/        |
+----------------------------------------------+

--------------enig2AA484285077C06548045724
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)
Comment: Using GnuPG with Debian - http://enigmail.mozdev.org

iD8DBQE/MC4FtXh2AYIMjggRAvm5AJ4r5t7eKXHNt/mWCIcS93+l/Gh+tgCdH82Z
76Nh+wx5v75reDsjfY1SJY4=
=NW50
-----END PGP SIGNATURE-----

--------------enig2AA484285077C06548045724--
