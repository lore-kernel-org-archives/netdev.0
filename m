From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: neighbour table RCU
Date: Tue, 1 Sep 2009 14:24:06 -0700
Message-ID: <20090901142406.70015a4f@nehalam>
References: <20090831150453.3437a65c@nehalam>
	<4A9CC429.5020803@gmail.com>
	<20090901085921.2c836dac@nehalam>
	<4A9D4834.4090902@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54465 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752302AbZIAVYJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 17:24:09 -0400
In-Reply-To: <4A9D4834.4090902@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 01 Sep 2009 18:13:40 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Stephen Hemminger a =C3=A9crit :
> > On Tue, 01 Sep 2009 08:50:17 +0200
> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >=20
> >> Stephen Hemminger a =C3=A9crit :
> >>> Looking at the neighbour table, it should be possible to get
> >>> rid of the two reader/writer locks.  The hash table lock is prett=
y
> >>> amenable to RCU, but the dynamic resizing makes it non-trivial.
> >>> Thinking of using a combination of RCU and sequence counts so tha=
t the
> >>> reader would just rescan if resize was in progress.
> >> I am not sure neigh_tbl_lock rwlock should be changed, I did not
> >> see any contention on it.
> >>
> >>> The reader/writer lock on the neighbour entry is more of a proble=
m.
> >>> Probably would be simpler/faster to change it into a spinlock and
> >>> be done with it.
> >>>
> >>> The reader/writer lock is also used for the proxy list hash table=
,
> >>> but that can just be a simple spinlock.
> >>>
> >> This is probably is the only thing we want to do at this moment,
> >> halving atomic ops on neigh_resolve_output()
> >>
> >> But why neigh_resolve_output() was called so much in the bench
> >> is the question...
> >>
> >=20
> > Every packet has to have an ARP resolution.
> >=20
>=20
> Sure, but I thought we had a cache ?
>=20
> static inline int ip_finish_output2(struct sk_buff *skb)
> {
> ...
> 	if (dst->hh)
> 		return neigh_hh_output(dst->hh, skb);
> 	else if (dst->neighbour)
> 		return dst->neighbour->output(skb);  << should fill cache first tim=
e >>
> ...
> }
>=20
> in my pktgen benches, I always hit same dst so should take the hh cac=
he ?

I ping the remote host before starting pktgen, that way I figure
the ARP and cache is available.

--=20
