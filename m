From: Jan Kiszka <jan.kiszka@web.de>
Subject: Re: [PATCH] d80211: ieee80211_hw handlers should be allowed to sleep
Date: Wed, 18 Oct 2006 20:10:02 +0200
Message-ID: <45366DFA.7030707@web.de>
References: <200610071123.15561.IvDoorn@gmail.com> <20061018150609.6542af30@griffin.suse.cz> <200610181927.37471.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigE51ED86AA498855649A991B4"
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate03.web.de ([217.72.192.234]:34501 "EHLO
	fmmailgate03.web.de") by vger.kernel.org with ESMTP
	id S1422748AbWJRSKM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Oct 2006 14:10:12 -0400
To: Ivo van Doorn <ivdoorn@gmail.com>
In-Reply-To: <200610181927.37471.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigE51ED86AA498855649A991B4
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

Ivo van Doorn wrote:
> On Wednesday 18 October 2006 15:06, Jiri Benc wrote:
>> On Sat, 7 Oct 2006 11:23:15 +0200, Ivo van Doorn wrote:
>>> --- a/net/d80211/ieee80211.c
>>> +++ b/net/d80211/ieee80211.c
>>> @@ -2075,15 +2075,15 @@ void ieee80211_if_shutdown(struct net_de
>>>  	case IEEE80211_IF_TYPE_STA:
>>>  	case IEEE80211_IF_TYPE_IBSS:
>>>  		sdata->u.sta.state =3D IEEE80211_DISABLED;
>>> -		del_timer_sync(&sdata->u.sta.timer);
>>> +		cancel_delayed_work(&sdata->u.sta.work);
>>>  		if (local->scan_work.data =3D=3D sdata->dev) {
>>>  			local->sta_scanning =3D 0;
>>>  			cancel_delayed_work(&local->scan_work);
>>> -			flush_scheduled_work();
>>>  			/* see comment in ieee80211_unregister_hw to
>>>  			 * understand why this works */
>>>  			local->scan_work.data =3D NULL;
>>>  		}
>>> +		flush_scheduled_work();
>> This is racy. local->scan_work.data can be set to NULL only after
>> flush_scheduled_work().
>=20
> Would something like the patch below be better?
> It keeps the flush_scheduled_work() at the same location, but a second
> is added in case local->scan_work.data !=3D sdata->dev
>=20
> Jan, was there any particular reason to move flush_cheduled_work() outs=
ide of the if-statement?

It is needed unconditionally now, so I moved it out without knowing
about this side effect. Your approach looks good to me.

>=20
> Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>
>=20
> ---
>=20
> diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
> index 32a1ba7..cb1180c 100644
> --- a/net/d80211/ieee80211.c
> +++ b/net/d80211/ieee80211.c
> @@ -2075,7 +2075,7 @@ void ieee80211_if_shutdown(struct net_de
>  	case IEEE80211_IF_TYPE_STA:
>  	case IEEE80211_IF_TYPE_IBSS:
>  		sdata->u.sta.state =3D IEEE80211_DISABLED;
> -		del_timer_sync(&sdata->u.sta.timer);
> +		cancel_delayed_work(&sdata->u.sta.work);
>  		if (local->scan_work.data =3D=3D sdata->dev) {
>  			local->sta_scanning =3D 0;
>  			cancel_delayed_work(&local->scan_work);
> @@ -2083,7 +2083,8 @@ void ieee80211_if_shutdown(struct net_de
>  			/* see comment in ieee80211_unregister_hw to
>  			 * understand why this works */
>  			local->scan_work.data =3D NULL;
> -		}
> +		} else
> +			flush_scheduled_work();
>  		break;
>  	}
>  }
> @@ -4605,8 +4606,8 @@ void ieee80211_unregister_hw(struct net_
>  		flush_scheduled_work();
>  		/* The scan_work is guaranteed not to be called at this
>  		 * point. It is not scheduled and not running now. It can be
> -		 * scheduled again only by some sta_timer (all of them are
> -		 * stopped by now) or under rtnl lock. */
> +		 * scheduled again only by sta_work (stopped by now) or under
> +		 * rtnl lock. */
>  	}
> =20
>  	ieee80211_rx_bss_list_deinit(dev);
> diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
> index 89666ec..5b48ce2 100644
> --- a/net/d80211/ieee80211_i.h
> +++ b/net/d80211/ieee80211_i.h
> @@ -240,7 +240,7 @@ struct ieee80211_if_sta {
>  		IEEE80211_ASSOCIATE, IEEE80211_ASSOCIATED,
>  		IEEE80211_IBSS_SEARCH, IEEE80211_IBSS_JOINED
>  	} state;
> -	struct timer_list timer;
> +	struct work_struct work;
>  	u8 bssid[ETH_ALEN], prev_bssid[ETH_ALEN];
>  	u8 ssid[IEEE80211_MAX_SSID_LEN];
>  	size_t ssid_len;
> @@ -621,7 +621,7 @@ int ieee80211_set_compression(struct iee
>  			      struct net_device *dev, struct sta_info *sta);
>  int ieee80211_init_client(struct net_device *dev);
>  /* ieee80211_sta.c */
> -void ieee80211_sta_timer(unsigned long ptr);
> +void ieee80211_sta_work(void *ptr);
>  void ieee80211_sta_rx_mgmt(struct net_device *dev, struct sk_buff *skb=
,
>  			   struct ieee80211_rx_status *rx_status);
>  int ieee80211_sta_set_ssid(struct net_device *dev, char *ssid, size_t =
len);
> diff --git a/net/d80211/ieee80211_iface.c b/net/d80211/ieee80211_iface.=
c
> index 9a187af..4dd480f 100644
> --- a/net/d80211/ieee80211_iface.c
> +++ b/net/d80211/ieee80211_iface.c
> @@ -194,9 +194,7 @@ void ieee80211_if_set_type(struct net_de
>  		struct ieee80211_if_sta *ifsta;
> =20
>  		ifsta =3D &sdata->u.sta;
> -		init_timer(&ifsta->timer);
> -		ifsta->timer.data =3D (unsigned long) dev;
> -		ifsta->timer.function =3D ieee80211_sta_timer;
> +		INIT_WORK(&ifsta->work, ieee80211_sta_work, dev);
> =20
>  		ifsta->capab =3D WLAN_CAPABILITY_ESS;
>  		ifsta->auth_algs =3D IEEE80211_AUTH_ALG_OPEN |
> diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
> index cc336bd..bf74b6b 100644
> --- a/net/d80211/ieee80211_sta.c
> +++ b/net/d80211/ieee80211_sta.c
> @@ -457,7 +457,7 @@ static void ieee80211_authenticate(struc
> =20
>  	ieee80211_send_auth(dev, ifsta, 1, NULL, 0, 0);
> =20
> -	mod_timer(&ifsta->timer, jiffies + IEEE80211_AUTH_TIMEOUT);
> +	schedule_delayed_work(&ifsta->work, IEEE80211_AUTH_TIMEOUT);
>  }
> =20
> =20
> @@ -677,7 +677,7 @@ static void ieee80211_associate(struct n
> =20
>  	ieee80211_send_assoc(dev, ifsta);
> =20
> -	mod_timer(&ifsta->timer, jiffies + IEEE80211_ASSOC_TIMEOUT);
> +	schedule_delayed_work(&ifsta->work, IEEE80211_ASSOC_TIMEOUT);
>  }
> =20
> =20
> @@ -735,11 +735,11 @@ static void ieee80211_associated(struct=20
>  		memset(wrqu.ap_addr.sa_data, 0, ETH_ALEN);
>  		wrqu.ap_addr.sa_family =3D ARPHRD_ETHER;
>  		wireless_send_event(dev, SIOCGIWAP, &wrqu, NULL);
> -		mod_timer(&ifsta->timer,
> -			  jiffies + IEEE80211_MONITORING_INTERVAL + 30 * HZ);
> +		schedule_delayed_work(&ifsta->work,
> +				      IEEE80211_MONITORING_INTERVAL + 30 * HZ);
>  	} else {
> -		mod_timer(&ifsta->timer,
> -			  jiffies + IEEE80211_MONITORING_INTERVAL);
> +		schedule_delayed_work(&ifsta->work,
> +				      IEEE80211_MONITORING_INTERVAL);
>  	}
>  }
> =20
> @@ -1019,8 +1019,8 @@ static void ieee80211_rx_mgmt_deauth(str
>  	    ifsta->state =3D=3D IEEE80211_ASSOCIATE ||
>  	    ifsta->state =3D=3D IEEE80211_ASSOCIATED) {
>  		ifsta->state =3D IEEE80211_AUTHENTICATE;
> -		mod_timer(&ifsta->timer,
> -			  jiffies + IEEE80211_RETRY_AUTH_INTERVAL);
> +		schedule_delayed_work(&ifsta->work,
> +				      IEEE80211_RETRY_AUTH_INTERVAL);
>  	}
> =20
>  	ieee80211_set_associated(dev, ifsta, 0);
> @@ -1062,8 +1062,8 @@ static void ieee80211_rx_mgmt_disassoc(s
> =20
>  	if (ifsta->state =3D=3D IEEE80211_ASSOCIATED) {
>  		ifsta->state =3D IEEE80211_ASSOCIATE;
> -		mod_timer(&ifsta->timer,
> -			  jiffies + IEEE80211_RETRY_AUTH_INTERVAL);
> +		schedule_delayed_work(&ifsta->work,
> +				      IEEE80211_RETRY_AUTH_INTERVAL);
>  	}
> =20
>  	ieee80211_set_associated(dev, ifsta, 0);
> @@ -1829,7 +1829,7 @@ static void ieee80211_sta_expire(struct=20
>  static void ieee80211_sta_merge_ibss(struct net_device *dev,
>  				     struct ieee80211_if_sta *ifsta)
>  {
> -	mod_timer(&ifsta->timer, jiffies + IEEE80211_IBSS_MERGE_INTERVAL);
> +	schedule_delayed_work(&ifsta->work, IEEE80211_IBSS_MERGE_INTERVAL);
> =20
>  	ieee80211_sta_expire(dev);
>  	if (ieee80211_sta_active_ibss(dev))
> @@ -1841,20 +1841,19 @@ static void ieee80211_sta_merge_ibss(str
>  }
> =20
> =20
> -void ieee80211_sta_timer(unsigned long ptr)
> +void ieee80211_sta_work(void *ptr)
>  {
> -	struct net_device *dev;
> +	struct net_device *dev =3D ptr;
>  	struct ieee80211_sub_if_data *sdata;
>  	struct ieee80211_if_sta *ifsta;
> =20
> -	dev =3D (struct net_device *) ptr;
>  	if (!netif_running(dev))
>  		return;
> =20
>  	sdata =3D IEEE80211_DEV_TO_SUB_IF(dev);
>  	if (sdata->type !=3D IEEE80211_IF_TYPE_STA &&
>  	    sdata->type !=3D IEEE80211_IF_TYPE_IBSS) {
> -		printk(KERN_DEBUG "%s: ieee80211_sta_timer: non-STA interface "
> +		printk(KERN_DEBUG "%s: ieee80211_sta_work: non-STA interface "
>  		       "(type=3D%d)\n", dev->name, sdata->type);
>  		return;
>  	}
> @@ -1879,7 +1878,7 @@ void ieee80211_sta_timer(unsigned long p
>  		ieee80211_sta_merge_ibss(dev, ifsta);
>  		break;
>  	default:
> -		printk(KERN_DEBUG "ieee80211_sta_timer: Unknown state %d\n",
> +		printk(KERN_DEBUG "ieee80211_sta_work: Unknown state %d\n",
>  		       ifsta->state);
>  		break;
>  	}
> @@ -2107,7 +2106,7 @@ static int ieee80211_sta_join_ibss(struc
>  	}
> =20
>  	ifsta->state =3D IEEE80211_IBSS_JOINED;
> -	mod_timer(&ifsta->timer, jiffies + IEEE80211_IBSS_MERGE_INTERVAL);
> +	schedule_delayed_work(&ifsta->work, IEEE80211_IBSS_MERGE_INTERVAL);
> =20
>  	ieee80211_rx_bss_put(dev, bss);
> =20
> @@ -2224,8 +2223,8 @@ #endif /* CONFIG_D80211_IBSS_DEBUG */
>  	/* Selected IBSS not found in current scan results - try to scan */
>  	if (ifsta->state =3D=3D IEEE80211_IBSS_JOINED &&
>  	    !ieee80211_sta_active_ibss(dev)) {
> -		mod_timer(&ifsta->timer,
> -			  jiffies + IEEE80211_IBSS_MERGE_INTERVAL);
> +		schedule_delayed_work(&ifsta->work,
> +				      IEEE80211_IBSS_MERGE_INTERVAL);
>  	} else if (time_after(jiffies, local->last_scan_completed +
>  			      IEEE80211_SCAN_INTERVAL)) {
>  		printk(KERN_DEBUG "%s: Trigger new scan to find an IBSS to "
> @@ -2253,7 +2252,7 @@ #endif /* CONFIG_D80211_IBSS_DEBUG */
>  		}
> =20
>  		ifsta->state =3D IEEE80211_IBSS_SEARCH;
> -		mod_timer(&ifsta->timer, jiffies + interval);
> +		schedule_delayed_work(&ifsta->work, interval);
>  		return 0;
>  	}
> =20



--------------enigE51ED86AA498855649A991B4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (MingW32)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFFNm36niDOoMHTA+kRAuVLAJ9ByN+hi15Crr4oS2J+/LugA9A1tQCfeQS+
/WBYOK3625Ib/2rx+3aDiTQ=
=hFHV
-----END PGP SIGNATURE-----

--------------enigE51ED86AA498855649A991B4--
