From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 2/4] macvlan: cleanup rx statistics
Date: Tue, 24 Nov 2009 08:45:14 +0000
Message-ID: <200911240845.14454.arnd@arndb.de>
References: <1259024166-28158-1-git-send-email-arnd@arndb.de> <1259024166-28158-3-git-send-email-arnd@arndb.de> <4B0B9639.4070607@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Anna Fischer <anna.fischer@hp.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	Mark Smith <lk-netdev@lk-netdev.nosense.org>,
	Gerhard Stenzel <gerhard.stenzel@de.ibm.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jens Osterkamp <jens@linux.vnet.ibm.com>,
	Patrick Mullaney <pmullaney@novell.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Edge Virtual Bridging <evb@yahoogroups.com>,
	David Miller <davem@davemloft.net>
To: virtualization@lists.linux-foundation.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932297AbZKXIpa@vger.kernel.org>
In-Reply-To: <4B0B9639.4070607@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 24 November 2009 08:15:53 Eric Dumazet wrote:
> Arnd Bergmann a =E9crit :
> > =20
> > +static inline void macvlan_count_rx(const struct macvlan_dev *vlan=
, int length,
> > +			     int success, int multicast)
>=20
> success and multicast should be declared as bool

ok

> > +{
> > +	struct macvlan_rx_stats *rx_stats;
> > +
> > +	rx_stats =3D per_cpu_ptr(vlan->rx_stats, smp_processor_id());
> > +	rx_stats->rx_packets +=3D success !=3D 0;
> > +	rx_stats->rx_bytes   +=3D success ? length : 0;
> > +	rx_stats->multicast  +=3D success && multicast;
> > +	rx_stats->rx_errors  +=3D !success;
> > +}
> > +
>=20
> I find following more readable, it probably generates more branches,
> but avoid dirtying rx_errors if it is in another cache line.
>=20
> if (likely(success)) {
> 	rx_stats->rx_packets++;
> 	rx_stats->rx_bytes +=3D length;
> 	if (multicast)
> 		rx_stats->multicast++;
> } else {
> 	rx_stats->rx_errors++;
> }

Given that the structure only has four members and alloc_percpu request=
s
cache aligned data, it is rather likely to be in the same cache line.

I'll have a look at what gcc generates on x86-64 for both versions
and use the version you suggested unless it looks significantly more
expensive.

Since we're into micro-optimization territory, do you think it should
be marked inline or not?
=20
> > -	rx_stats =3D per_cpu_ptr(vlan->rx_stats, smp_processor_id());
> >  	skb =3D skb_share_check(skb, GFP_ATOMIC);
> > -	if (skb =3D=3D NULL) {
> > -		rx_stats->rx_errors++;
> > -		return NULL;
> > -	}
> > -
> > -	rx_stats->rx_bytes +=3D skb->len + ETH_HLEN;
> > -	rx_stats->rx_packets++;
> > +	macvlan_count_rx(vlan, skb->len + ETH_HLEN, likely(skb !=3D NULL)=
, 0);
>=20
> its not _likely_ that skb !=3D NULL, its a fact :)
>=20
> -> macvlan_count_rx(vlan, skb->len + ETH_HLEN, true, false);

I don't understand. Note how I removed the check for NULL above and
the skb pointer may be the result of a failing skb_clone().

Looking at this again, I actually introduced a bug by calling netif_rx
on a possibly NULL skb, I'll fix that.

Thanks!

	Arnd <><
