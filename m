From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: RFC: memory leak in udp_table_init
Date: Thu, 01 Mar 2012 04:33:38 -0800
Message-ID: <1330605218.2465.50.camel@edumazet-laptop>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B6E85@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>,
	paul.gortmaker@windriver.com, tim.bird@am.sony.com,
	kuznet@ms2.inr.ac.ru, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6E85@saturn3.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 01 mars 2012 =C3=A0 08:55 +0000, David Laight a =C3=A9crit :
> > > The pid table is a good example of something where a hash
> > > table is unnecessary.
> > > Linux should steal the code I put into NetBSD :-)
> >=20
> > On this unrelated topic.  What algorithm did you use on NetBSD for
> > dealing with pids?
>=20
> Basically I forced the hash chain length to one by allocating
> a pid that hit an empty entry in the table.
>=20
> So you start off with (say) 64 entries and use the low 6
> bits to index the table. The higher bits are incremented
> each time a 'slot' is reused.
> Free entries are kept in a FIFO list.
> So each entry either contains a pointer to the process,
> or the high bits and the index of the next free slot.
> (and the PGID pointer).
> When there are only (say) 2 free entries, then the table
> size is doubled, the pointers moved to the correct places,
> the free ist fixed up, and the minimum number of free entries
> doubled.
>=20
> The overall effect:
> - lookup is only ever a mask and index + compare.
> - Allocate is always fast and fixed cost (except when
>   the table size has to be doubled).
> - A pid value will never be reused within (about) 2000
>   allocates (for 16bit pids, much larger for 32bit ones).
> - Allocated pid numbers tend to be random, certainly
>   very difficult to predict.
> - Small memory footprint for small systems.
> For pids we normally avoid issuing large values, but
> will do so to avoid immediate re-use on systems that
> have 1000s of active processes.
>=20


You describe a hash table mechanism still, and you made chain lengthes
be 0 or 1.

This GEN_ID/SLOT schem is the one used in IBM AIX for pid allocations
(with a 31 (or was it 32) bit range). They did not use FIFO, because
they tried to use lower slots of the proc table.

Hashes values in network land are unpredictable, so we cannot make sure
a slot contains at most one entry.

Note: If you manage 4 million tcp sockets in your server, hash table
must be at _least_ 4 million slots. I would not call that suboptimal as
you said in your previous mail.

We could argue that default sizes of these hash tables (ip route,
tcp, ...) are now more suited for high end uses instead of
desktop/embedded uses, because ram sizes increased so much last 10
years.

[ We added in commits 0ccfe61803ad & c9503e0fe05 a 512K limits for
tcp/ip route hash tables to stop insanity, but thats it ]

RCU lookups make dynamic resizes of these hash table a bit complex.
IIRC David Miller have submitted a patch but this work was not
completed. Not sure its an issue these days, as we prefer to work on ip
route cache (and its associated hash table) removal anyway.

=46or UDP/UDPLite it certainly is not an issue, since max size is 65536
slots. On a 32bit kernel, with at more 1GB of LOWMEM, max is 512 slots.
