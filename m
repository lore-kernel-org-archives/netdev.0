From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH net-next V6 02/14] bridge: Add vlan filtering infrastructure
Date: Fri, 18 Jan 2013 02:57:14 +0100
Message-ID: <CAHXqBFKg6Vp5=dprDYKON2LmshhX+nSPF7KRHiQmOS68PrQq-A@mail.gmail.com>
References: <1358360289-23249-1-git-send-email-vyasevic@redhat.com> <1358360289-23249-3-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	davem@davemloft.net, shemminger@vyatta.com, mst@redhat.com,
	shmulik.ladkani@gmail.com
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f176.google.com ([209.85.216.176]:34090 "EHLO
	mail-qc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753637Ab3ARB5g convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 20:57:36 -0500
Received: by mail-qc0-f176.google.com with SMTP id n41so2066964qco.21
        for <netdev@vger.kernel.org>; Thu, 17 Jan 2013 17:57:35 -0800 (PST)
In-Reply-To: <1358360289-23249-3-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/1/16 Vlad Yasevich <vyasevic@redhat.com>:
[...]
> --- /dev/null
> +++ b/net/bridge/br_vlan.c
[...]
> +struct net_port_vlan *nbp_vlan_find(const struct net_port_vlans *v, =
u16 vid)
> +{
> +       struct net_port_vlan *pve;
> +
> +       /* Must be done either in rcu critical section or with RTNL h=
eld */
> +       WARN_ON_ONCE(!rcu_read_lock_held() && !rtnl_is_locked());
> +
> +       list_for_each_entry_rcu(pve, &v->vlan_list, list) {
> +               if (pve->vid =3D=3D vid)
> +                       return pve;
> +       }
> +
> +       return NULL;
> +}

This looks expensive - it's O(n) with n =3D number of configured VLANs =
on a port.
And this is called for every packet. The bridge already has a hash of V=
LAN
structures found by br_vlan_find(). You could add a second bitmap there
(eg. ingres_ports[]) and check port's bit instead of walking the list.
You would use a bit more memory (64 bytes minus the removed list-head)
per configured VLAN but save some cycles in hot path.

Best Regards,
Micha=B3 Miros=B3aw
