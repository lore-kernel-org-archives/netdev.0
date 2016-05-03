From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH 2/2] mac80211_hwsim: Allow managing radios from
 non-initial namespaces
Date: Tue, 03 May 2016 21:16:32 +0200
Message-ID: <1462302992.10444.11.camel@sipsolutions.net>
References: <1462258398-6749-1-git-send-email-martin@strongswan.org>
	 <1462258398-6749-3-git-send-email-martin@strongswan.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Martin Willi <martin-jzJueiEJWxp8fCCB1iTX4w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1462258398-6749-3-git-send-email-martin-jzJueiEJWxp8fCCB1iTX4w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-05-03 at 08:53 +0200, Martin Willi wrote:
>=C2=A0
> +static __net_init int hwsim_init_net(struct net *net)
> +{
> +	struct mac80211_hwsim_data *data;
> +	bool exists =3D true;
> +	int netgroup =3D 0;
> +
> +	spin_lock_bh(&hwsim_radio_lock);
> +	while (exists) {
> +		exists =3D false;
> +		list_for_each_entry(data, &hwsim_radios, list) {
> +			if (netgroup =3D=3D data->netgroup) {
> +				exists =3D true;
> +				netgroup++;
> +				break;
> +			}
> +		}
> +	}
> +	spin_unlock_bh(&hwsim_radio_lock);
> +
> +	*(int *)net_generic(net, hwsim_net_id) =3D netgroup;


This seems somewhat awkward. Why not just take the maximum of all the
netgroup IDs + 1? We'd run out of memory and radio IDs long before
netgroup IDs even that way, and they're not actually visible anywhere
so it doesn't matter.

Actually though, *both* your approach and my suggestion don't seem
safe: consider a new netns that doesn't have any hwsim radios yet. Now
you create *another* one, but it would get the same netgroup.

IOW, you should simply use a global counter. Surprising (net)
namespaces don't have an index like that already, but I don't see one.

> +static void __net_exit hwsim_exit_net(struct net *net)
> +{
> +	struct mac80211_hwsim_data *entry, *tmp;
> +
> +	spin_lock_bh(&hwsim_radio_lock);
> +	list_for_each_entry_safe(entry, tmp, &hwsim_radios, list) {
> +		if (net_eq(wiphy_net(entry->hw->wiphy), net)) {
> +			list_del(&entry->list);
> +			INIT_WORK(&entry->destroy_work,
> destroy_radio);
> +			schedule_work(&entry->destroy_work);
> +		}
> +	}
> +	spin_unlock_bh(&hwsim_radio_lock);
> +}

This changes today's default behaviour of moving the wiphys to the
default namespace. Did you intend to destroy them based on the
netgroup, i.e. based on the namespace that created them? Actually,
maybe they should move back to the namespace that created them, if the
namespace they are in is destroyed? But that's difficult, I don't mind
this behaviour, but I'm not sure it's what we want by default for
radios created in the init_net.

johannes
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
