From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Get rid of rt_check_expire and rt_garbage_collect
Date: Sat, 02 Apr 2005 15:58:55 +0200
Message-ID: <424EA51F.6000300@cosmosbay.com>
References: <E1DHdsP-0003Lr-00@gondolin.me.apana.org.au> <424E641A.1020609@cosmosbay.com> <20050402112304.GA11321@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: davem@davemloft.net, netdev@oss.sgi.com, Robert.Olsson@data.slu.se,
        hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050402112304.GA11321@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu a =E9crit :
> On Sat, Apr 02, 2005 at 11:21:30AM +0200, Eric Dumazet wrote:
>=20
>>Well, I began my work because of the overflow bug in rt_check_expire().=
..
>>Then I realize this function could not work as expected. On a loaded=20
>>machine, one timer tick is 1 ms.
>>During this time, number of chains that are scanned is ridiculous.
>>With the standard timer of 60 second, fact is rt_check_expire() is usel=
ess.
>=20
>=20
> I see.  What we've got here is a scalability problem with respect
> to the number of hash buckets.  As the number of buckets increases,
> the amount of work the timer GC has to perform inreases proportionally.
>=20
> Since the timer GC parameters are fixed, this will eventually break.
>=20
> Rather than changing the timer GC so that it runs more often to keep
> up with the large routing cache, we should get out of this by reducing
> the amount of work we have to do.
>=20
> Imagine an ideal balanced hash table with 2.6 million entries.  That
> is, all incoming/outgoing packets belong to flows that are already in
> the hash table.  Imagine also that there is no PMTU/link failure taking
> place so all entries are valid forever.
>=20
> In this state there is absolutely no need to execute the timer GC.
>=20
> Let's remove one of those assumptions and allow there to be entries
> which need to expire after a set period.
>=20
> Instead of having the timer GC clean them up, we can move the expire
> check to the place where the entries are used.  That is, we make
> ip_route_input/ip_route_output/ipv4_dst_check check whether the
> entry has expired.
>=20
> On the face of it we're doing more work since every routing cache
> hit will need to check the validity of the dst.  However, because
> it's a single subtraction it is actually pretty cheap.  There is
> also no additional cache miss compared to doing it in the timer
> GC since we have to read the dst anyway.
>=20
> Let's go one step further and make the routing cache come to life.
> Now there are new entries coming in and we need to remove old ones
> in order to make room for them.
>=20
> That task is currently carried out by the timer GC in rt_check_expire
> and on demand by rt_garbage_collect.  Either way we have to walk the
> entire routing cache looking for entries to get rid of.
>=20
> This is quite expensive when the routing cache is large.  However,
> there is a better way.
>=20
> The reason we keep a cap on the routing cache (for a given hash size)
> is so that individual chains do not degenerate into long linked lists.
>=20
> In other words, we don't really care about how many entries there are
> in the routing cache.  But we do care about how long each hash chain
> is.
>=20
> So instead of walking the entire routing cache to keep the number of
> entries down, what we should do is keep each hash chain as short as
> possible.
>=20
> Assuming that the hash function is good, this should achieve the
> same end result.
>=20
> Here is how it can be done: Every time a routing entry is inserted into
> a hash chain, we perform GC on that chain unconditionally.
>=20
> It might seem that we're doing more work again.  However, as before
> because we're traversing the chain anyway, it is very cheap to perform
> the GC operations which mainly involve the checks in rt_may_expire.
>=20
> OK that's enough thinking and it's time to write some code to see
> whether this is all bullshit :)
>=20
> Cheers,

Well, it may work if you dont care about memory used.

# grep dst /proc/slabinfo
ip_dst_cache      2825575 2849590    384   10    1 : tunables   54   27  =
  8 : slabdata 284959 284959      0

On this machine, route cache takes 1.1 GB of ram... impressive.

Then if the network load decrease (or completely stop), only a timer driv=
en gc could purge the cache.

So rt_check_expire() is *needed*

You are right saying that gc parameters are fixed, thus gc breaks at high=
 load.


Eric
