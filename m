From: Michael Bellion and Thomas Heinz <nf@hipac.org>
Subject: Re: [RFC] High Performance Packet Classifiction for tc framework
Date: Thu, 17 Jul 2003 15:13:09 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F16A0E5.1080007@hipac.org>
References: <200307141045.40999.nf@hipac.org> <1058328537.1797.24.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig7E93A75E61DF18B37FB81F90"
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1058328537.1797.24.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig7E93A75E61DF18B37FB81F90
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi Jamal

You wrote:
> This is good.I may have emailed you about this topic before?

Yes, but at that time we had not any concrete plans to
integrate hipac into tc. We focussed on making nf-hipac as
expressive as iptables first.

> It's a classifier therefore it makes sense ;->

:-)

> nice. What would be interesting is to see your rule update rates vs
> iptables (i expect iptables to suck) - but how do you compare aginst any
> of the tc classifiers for example?

Regarding the rule update rates we have not done any measurements
yet but nf-hipac should be faster than iptables (even more when
we have implemented the selective cloning stuff). On the other
hand we are probably slower than tc because in addition to the
insert operation into an internal chain there is the actual hipac
insert operation. The insertion in the internal chain is quicker
than the tc insert operation because we use doubly linked lists.

Regarding the matching performance one has to consider a few things.
The currently existing tc classifiers are an abstraction for rules
(iptables "slang") whilst hipac is an abstraction for a set of rules
(including the chain semantics known from iptables), i.e. a table in
the iptables world. Of course it is possible to have some sort
of extended classifying in tc too, i.e. you can add several fw or u32
filters with the same prio which allows the filters to be hashed.
One disadvantage of this concept is that the hashed filters
must be compact, i.e. there cannot be other classifiers in between.
Another major disadvantage is caused by the hashing scheme.
If you use the hash for 1 dimension you have to make sure that
either all filters in a certain bucket are disjoint or you must have
an implicit ordering of the rules (according to the insertion order
or something). This scheme is not extendable to 2 or more dimensions,
i.e. 1 hash for src ip, #(src ip buckets) many dst ip hashes and so
on, because you simply cannot express arbitrary rulesets.

Another general problem is of course that the user has to manually
setup the hash which is rather inconvenient.

Now, what are the implications on the matching performance:
tc vs. nf-hipac? As long as the extended hashing stuff is not used
nf-hipac is clearly superior to tc. When hashing is used it _really_
depends. If there is only one classifier (with hashing) per interface
and the number of rules per bucket is very small the performance should
be comparable. As soon as you add other classifiers nf-hipac will
outperform tc again.

>>The tc framework is very flexible with respect to where filters can be
>>attached. Unfortunately this cannot be mapped into one HIPAC data
>>structure. Our current design allows to attach filters anywhere but
>>only the filters attached to the top level qdisc would benefit from the
>>HIPAC algorithm. Would this be a noticeable restriction?
> 
> I dont think so, but can ytou describe this restriction?

Well, we thought a little more about the design and came to the
conclusion that it is not necessary to have a HIPAC qdisc at root
but it suffices to ensure that the HIPAC classifier occurs only
once per interface. As you can guess from the last sentence we
dropped the HIPAC qdisc design and changed to the following scheme:

- there no special HIPAC qdisc at all :-)
- the HIPAC classifier is no longer a simple rule but represents
   the whole table
- the HIPAC classifier can occur in any qdisc but at most once
   per interface

So, basically HIPAC is just a normal classifier like any other
with two exceptions:
   a) it can occur only once per interface
   b) the rules within the classifier can contain other classifiers,
      e.g. u32, fw, tc_index, as matches

There is just one problem with the current tc framework. Once
a new filter is inserted into the chain it is not removed even
if the change function of the classifier returns < 0
(2.6.0-test1: net/sched/cls_api.c: line 280f).
This should be changed anyway, shouldn't it?

>>- new HIPAC classifier which supports all native nf-hipac matches
>>  (src/dst ip, proto, src/dst port, ttl, state, in_iface, icmp type,
>>  tcpflags, fragments) and additionally fwmark
> 
> I would think for cleanliness fwmark or any metadata related
> classification would be separate from one that is based on packet bits.

Since our classifier represents a table of rules and the rules are
based on different matches, like src/dst ip and also fwmark (native)
or u32 (subclassifier as match), this is definitely a clean design.

>>- the HIPAC classifier can only be attached to the HIPAC qdisc and vice
>>  versa the HIPAC qdisc only accepts HIPAC classifiers
> 
> <puke> 
> We do have an issue with being able to do extended classification
> but building a qdisc for it is a no no. Building a qdisc that will force
> other classifier to structure themselves after it is even a bigger sin.
> Look at the action code i have (i can send you an updated patch); a
> better idea is to make extended classifiers an action based on another
> filter match. At least this is what i have been toying with and i dont
> think it is clean enough. what we need is to extend the filtering
> framework itself to have extended classifiers.

The new design should be much cleaner. Originally we also thought about
making HIPAC a classifier only but we expected some problems related
to this approach. Finally we discovered that this is not the case :)


Regards,

+-----------------------+----------------------+
|   Michael Bellion     |     Thomas Heinz     |
| <mbellion@hipac.org>  |  <creatix@hipac.org> |
+-----------------------+----------------------+
|    High Performance Packet Classification    |
|       nf-hipac: http://www.hipac.org/        |
+----------------------------------------------+

--------------enig7E93A75E61DF18B37FB81F90
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)
Comment: Using GnuPG with Debian - http://enigmail.mozdev.org

iD8DBQE/FqDxtXh2AYIMjggRAnVNAKCYNTOiCa/Op3UREZhsVmSzfccRTgCgqaIO
uzyXIMuow/L2f4qAejQgTaQ=
=mgBg
-----END PGP SIGNATURE-----

--------------enig7E93A75E61DF18B37FB81F90--
