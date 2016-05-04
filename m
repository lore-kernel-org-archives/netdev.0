From: Martin Willi <martin-jzJueiEJWxp8fCCB1iTX4w@public.gmane.org>
Subject: Re: [PATCH 2/2] mac80211_hwsim: Allow managing radios from
 non-initial namespaces
Date: Wed, 04 May 2016 10:33:19 +0200
Message-ID: <1462350799.2546.31.camel@strongswan.org>
References: <1462258398-6749-1-git-send-email-martin@strongswan.org>
	 <1462258398-6749-3-git-send-email-martin@strongswan.org>
	 <1462302992.10444.11.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1462302992.10444.11.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=C2=A0
> > +static __net_init int hwsim_init_net(struct net *net)
> > +{
> > +	struct mac80211_hwsim_data *data;
> > +	bool exists =3D true;
> > +	int netgroup =3D 0;
> > +
> > +	spin_lock_bh(&hwsim_radio_lock);
> > +	while (exists) {
> > +		exists =3D false;
> > +		list_for_each_entry(data, &hwsim_radios, list) {
> > +			if (netgroup =3D=3D data->netgroup) {
> > +				exists =3D true;
> > +				netgroup++;
> > +				break;
> > +			}
> > +		}
> > +	}
> > +	spin_unlock_bh(&hwsim_radio_lock);
> > +
> > +	*(int *)net_generic(net, hwsim_net_id) =3D netgroup;
>=20
> This seems somewhat awkward. Why not just take the maximum of all the
> netgroup IDs + 1? We'd run out of memory and radio IDs long before
> netgroup IDs even that way

My intention was to reuse netgroups for the case many namespaces come
and go, but I agree that it is not optimal.

> consider a new netns that doesn't have any hwsim radios yet.
> Now you create *another* one, but it would get the same netgroup.

Correct, that is indeed broken if there are no radios.

> IOW, you should simply use a global counter. Surprising (net)
> namespaces don't have an index like that already, but I don't see
> one.

Ok, will do that in a v2.

> > +static void __net_exit hwsim_exit_net(struct net *net)
> > +{
> > +	struct mac80211_hwsim_data *entry, *tmp;
> > +
> > +	spin_lock_bh(&hwsim_radio_lock);
> > +	list_for_each_entry_safe(entry, tmp, &hwsim_radios, list) {
> > +		if (net_eq(wiphy_net(entry->hw->wiphy), net)) {
> > +			list_del(&entry->list);
> > +			INIT_WORK(&entry->destroy_work, destroy_radio);
> > +			schedule_work(&entry->destroy_work);
> > +		}
> > +	}
> > +	spin_unlock_bh(&hwsim_radio_lock);
> > +}

> This changes today's default behaviour of moving the wiphys to the
> default namespace. Did you intend to destroy them based on the
> netgroup, i.e. based on the namespace that created them? Actually,
> maybe they should move back to the namespace that created them, if
> the namespace they are in is destroyed? But that's difficult, I don't
> mind this behaviour, but I'm not sure it's what we want by default
> for radios created in the init_net.

With the proposed approach I destroy all radios if the owning namespace
gets deleted, because we probably don't want them landing in init_net
if they are created from a (unprivileged) userns process. I think this
is what other "virtual" interfaces do (gre tunnels, veth etc.). If we
think of hwsim radios as such a "virtual" device, that makes IMO sense
to delete them.

If we want to keep the existing behavior, we could move radios
belonging to the init_net-associated netgroup back to init_net, that
shouldn't be too difficult.

Moving the radio back to the creators namespace would be the most
consistent behavior, so I'll check how difficult such a reverse lookup
is. We then would delete the radio only if it is in the creators
namespace, or if the creators namespace is gone. Does that make sense?

Martin
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
