From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: DDoS attack causing bad effect on conntrack searches
Date: Tue, 01 Jun 2010 07:05:32 +0200
Message-ID: <1275368732.2478.88.camel@edumazet-laptop>
References: <1271941082.14501.189.camel@jdb-workstation>
	 <q2h412e6f7f1004220613m488c2ee4r6d24a8d1e65997d4@mail.gmail.com>
	 <4BD04C74.9020402@trash.net> <1271946961.7895.5665.camel@edumazet-laptop>
	 <1271948029.7895.5707.camel@edumazet-laptop>
	 <20100422155123.GA2524@linux.vnet.ibm.com>
	 <1271952128.7895.5851.camel@edumazet-laptop>
	 <Pine.LNX.4.64.1004222213290.10919@ask.diku.dk>
	 <1272056237.4599.7.camel@edumazet-laptop>
	 <Pine.LNX.4.64.1004241219280.32071@ask.diku.dk>
	 <1272139861.20714.525.camel@edumazet-laptop>
	 <1272292568.13192.43.camel@jdb-workstation>
	 <1275340896.2478.26.camel@edumazet-laptop>
	 <AANLkTikw3uonDB4nPXg8FVFN_07F_wq0SA_ayyAHL6VM@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hawk@comx.dk, Jesper Dangaard Brouer <hawk@diku.dk>,
	paulmck@linux.vnet.ibm.com, Patrick McHardy <kaber@trash.net>,
	Linux Kernel Network Hackers <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <AANLkTikw3uonDB4nPXg8FVFN_07F_wq0SA_ayyAHL6VM@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 01 juin 2010 =C3=A0 08:28 +0800, Changli Gao a =C3=A9crit :
> On Tue, Jun 1, 2010 at 5:21 AM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> >
> > I had a look at current conntrack and found the 'unconfirmed' list =
was
> > maybe a candidate for a potential blackhole.
> >
> > That is, if a reader happens to hit an entry that is moved from reg=
ular
> > hash table slot 'hash' to unconfirmed list,
>=20
> Sorry, but I can't find where we do this things. unconfirmed list is
> used to track the unconfirmed cts, whose corresponding skbs are still
> in path from the first to the last netfilter hooks. As soon as the
> skbs end their travel in netfilter, the corresponding cts will be
> confirmed(moving ct from unconfirmed list to regular hash table).
>=20

So netfilter is a monolithic thing.

When a packet begins its travel into netfilter, you guarantee that no
other packet can also begin its travel and find an unconfirmed
conntrack ?

I wonder why we use atomic ops then to track the confirmed bit :)


> unconfirmed list should be small, as networking receiving is in BH.

So according to you, netfilter/ct runs only in input path ?

So I assume a packet is handled by CPU X, creates a new conntrack
(possibly early droping an old entry that was previously in a standard
hash chain), inserted in unconfirmed list. _You_ guarantee another CPU
Y, handling another packet, possibly sent by a hacker reading your
netdev mails, cannot find the conntrack that was early dropped ?

> How about implementing unconfirmed list as a per cpu variable?

I first implemented such a patch to reduce cache line contention, then =
I
asked to myself : What is exactly an unconfirmed conntrack ? Can their
number be unbounded ? If yes, we have a problem, even on a two cpus
machine. Using two lists instead of one wont solve the fundamental
problem.

The real question is, why do we need this unconfirmed 'list' in the
first place. Is it really a private per cpu thing ? Can you prove this,
in respect of lockless lookups, and things like NFQUEUE ?=20

Each conntrack object has two list anchors. One for IP_CT_DIR_ORIGINAL,
one for IP_CT_DIR_REPLY.

Unconfirmed list use the first anchor. This means another cpu can
definitely find an unconfirmed item in a regular hash chain, since we
dont respect an RCU grace period before re-using an object.

If memory was not a problem, we probably would use a third anchor to
avoid this, or regular RCU instead of SLAB_DESTROY_BY_RCU variant.



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
