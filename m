From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: DDoS attack causing bad effect on conntrack searches
Date: Thu, 22 Apr 2010 09:34:32 -0700
Message-ID: <20100422163432.GE2524@linux.vnet.ibm.com>
References: <1271941082.14501.189.camel@jdb-workstation>
 <q2h412e6f7f1004220613m488c2ee4r6d24a8d1e65997d4@mail.gmail.com>
 <4BD04C74.9020402@trash.net>
 <1271946961.7895.5665.camel@edumazet-laptop>
 <1271948029.7895.5707.camel@edumazet-laptop>
 <20100422155123.GA2524@linux.vnet.ibm.com>
 <1271952128.7895.5851.camel@edumazet-laptop>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>, Changli Gao <xiaosuo@gmail.com>,
	hawk@comx.dk,
	Linux Kernel Network Hackers <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1271952128.7895.5851.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 22, 2010 at 06:02:08PM +0200, Eric Dumazet wrote:
> Le jeudi 22 avril 2010 =E0 08:51 -0700, Paul E. McKenney a =E9crit :
> > On Thu, Apr 22, 2010 at 04:53:49PM +0200, Eric Dumazet wrote:
> > > Le jeudi 22 avril 2010 =E0 16:36 +0200, Eric Dumazet a =E9crit :
> > >=20
> > > > If one hash slot is under attack, then there is a bug somewhere=
=2E
> > > >=20
> > > > If we cannot avoid this, we can fallback to a secure mode at th=
e second
> > > > retry, and take the spinlock.
> > > >=20
> > > > Tis way, most of lookups stay lockless (one pass), and some mig=
ht take
> > > > the slot lock to avoid the possibility of a loop.
> > > >=20
> > > > I suspect a bug elsewhere, quite frankly !
> > > >=20
> > > > We have a chain that have an end pointer that doesnt match the =
expected
> > > > one.
> > > >=20
> > >=20
> > > On normal situation, we always finish the lookup :
> > >=20
> > > 1) If we found the thing we were looking at.
> > >=20
> > > 2) We get the list end (item not found), we then check if it is t=
he
> > > expected end.
> > >=20
> > > It is _not_ the expected end only if some writer deleted/inserted=
 an
> > > element in _this_ chain during our lookup.
> >=20
> > So this situation uses SLAB_DESTROY_BY_RCU to quickly recycle delet=
ed
> > elements?  (Not obvious from the code, but my ignorance of the netw=
orking
> > code is such that many things in that part of the kernel are not ob=
vious
> > to me, I am afraid.)
>=20
> Yes, this uses SLAB_DESTROY_BY_RCU, like tcp/udp lookups.

OK, that will do it!!!  ;-)

One way of throttling the bad effects of updates on readers is to
periodically force updates through a grace period.  But this seems
to be a very big hammer, and likely to have little practical effect.

Another approach would be to have multiple list pointers per element,
so that a given element could be reused a small number of times without
messing up concurrent readers (sort of like Herbert's resizable hash
table).

But as you say, if some other bug is really behind this, better to fix
that bug than to work around it.

> > Otherwise, of course you would simply allow deleted elements to con=
tinue
> > pointing where they did previously, so that concurrent readers woul=
d not
> > miss anything.
>=20
> > Of course, the same potential might arise on insertion, but it is u=
sually
> > OK to miss an element that was inserted after you started searching=
=2E
> >=20
> > > Because our lookup is lockless, we then have to redo it because w=
e might
> > > miss the object we are looking for.
> >=20
> > Ah...  Is there also a resize operation?  Herbert did do a resizabl=
e
> > hash table recently, but I was under the impression that (1) it was=
 in
> > some other part of the networking stack and (2) it avoided the need=
 to
> > restart readers.
> >=20
> > > If we can do the 'retry' a 10 times, it means the attacker was re=
ally
> > > clever enough to inject new packets (new conntracks) at the right
> > > moment, in the right hash chain, and this sounds so higly incredi=
ble
> > > that I cannot believe it at all :)
> >=20
> > Or maybe the DoS attack is injecting so many new conntracks that a =
large
> > fraction of the hash chains are being modified at any given time?
>=20
> maybe hash table has one slot :)

;-) ;-) ;-)

							Thanx, Paul
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
