From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: RFC: memory leak in udp_table_init
Date: Thu, 15 Mar 2012 10:44:23 -0700
Message-ID: <20120315174422.GG2381@linux.vnet.ibm.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B6E85@saturn3.aculab.com>
 <1330605218.2465.50.camel@edumazet-laptop>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Laight <David.Laight@ACULAB.COM>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>,
	paul.gortmaker@windriver.com, tim.bird@am.sony.com,
	kuznet@ms2.inr.ac.ru, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:60638 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1032066Ab2CORoa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Mar 2012 13:44:30 -0400
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 15 Mar 2012 11:44:29 -0600
Content-Disposition: inline
In-Reply-To: <1330605218.2465.50.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 01, 2012 at 04:33:38AM -0800, Eric Dumazet wrote:
> Le jeudi 01 mars 2012 =E0 08:55 +0000, David Laight a =E9crit :
> > > > The pid table is a good example of something where a hash
> > > > table is unnecessary.
> > > > Linux should steal the code I put into NetBSD :-)
> > >=20
> > > On this unrelated topic.  What algorithm did you use on NetBSD fo=
r
> > > dealing with pids?
> >=20
> > Basically I forced the hash chain length to one by allocating
> > a pid that hit an empty entry in the table.
> >=20
> > So you start off with (say) 64 entries and use the low 6
> > bits to index the table. The higher bits are incremented
> > each time a 'slot' is reused.
> > Free entries are kept in a FIFO list.
> > So each entry either contains a pointer to the process,
> > or the high bits and the index of the next free slot.
> > (and the PGID pointer).
> > When there are only (say) 2 free entries, then the table
> > size is doubled, the pointers moved to the correct places,
> > the free ist fixed up, and the minimum number of free entries
> > doubled.
> >=20
> > The overall effect:
> > - lookup is only ever a mask and index + compare.
> > - Allocate is always fast and fixed cost (except when
> >   the table size has to be doubled).
> > - A pid value will never be reused within (about) 2000
> >   allocates (for 16bit pids, much larger for 32bit ones).
> > - Allocated pid numbers tend to be random, certainly
> >   very difficult to predict.
> > - Small memory footprint for small systems.
> > For pids we normally avoid issuing large values, but
> > will do so to avoid immediate re-use on systems that
> > have 1000s of active processes.
> >=20
>=20
>=20
> You describe a hash table mechanism still, and you made chain lengthe=
s
> be 0 or 1.
>=20
> This GEN_ID/SLOT schem is the one used in IBM AIX for pid allocations
> (with a 31 (or was it 32) bit range). They did not use FIFO, because
> they tried to use lower slots of the proc table.
>=20
> Hashes values in network land are unpredictable, so we cannot make su=
re
> a slot contains at most one entry.
>=20
> Note: If you manage 4 million tcp sockets in your server, hash table
> must be at _least_ 4 million slots. I would not call that suboptimal =
as
> you said in your previous mail.
>=20
> We could argue that default sizes of these hash tables (ip route,
> tcp, ...) are now more suited for high end uses instead of
> desktop/embedded uses, because ram sizes increased so much last 10
> years.
>=20
> [ We added in commits 0ccfe61803ad & c9503e0fe05 a 512K limits for
> tcp/ip route hash tables to stop insanity, but thats it ]
>=20
> RCU lookups make dynamic resizes of these hash table a bit complex.
> IIRC David Miller have submitted a patch but this work was not
> completed. Not sure its an issue these days, as we prefer to work on =
ip
> route cache (and its associated hash table) removal anyway.

One approach is to put a pair of list_head structures in each object, t=
hen
proceed as Herbert Xu did: http://lists.openwall.net/netdev/2010/02/28/=
20.

There is another RCU-protected resizable hash table with the userspace
RCU library: http://lttng.org/urcu.  And another approach is described
in a USENIX paper:

http://www.usenix.org/event/atc11/tech/final_files/Triplett.pdf

						Thanx, Paul

> For UDP/UDPLite it certainly is not an issue, since max size is 65536
> slots. On a 32bit kernel, with at more 1GB of LOWMEM, max is 512 slot=
s.
>=20
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>=20
