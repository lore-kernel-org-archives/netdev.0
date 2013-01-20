From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next V6 02/14] bridge: Add vlan filtering
 infrastructure
Date: Sun, 20 Jan 2013 11:38:25 -0800
Message-ID: <20130120113825.759b4a58@nehalam.linuxnetplumber.net>
References: <1358360289-23249-1-git-send-email-vyasevic@redhat.com>
	<1358360289-23249-3-git-send-email-vyasevic@redhat.com>
	<CAHXqBFKg6Vp5=dprDYKON2LmshhX+nSPF7KRHiQmOS68PrQq-A@mail.gmail.com>
	<50FC307A.5090003@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-2?B?TWljaGGzIE1pcm9zs2F3?= <mirqus@gmail.com>,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	davem@davemloft.net, shemminger@vyatta.com, mst@redhat.com,
	shmulik.ladkani@gmail.com
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:46972 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752284Ab3ATTj5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2013 14:39:57 -0500
Received: by mail-pa0-f45.google.com with SMTP id bg2so2990283pad.32
        for <netdev@vger.kernel.org>; Sun, 20 Jan 2013 11:39:56 -0800 (PST)
In-Reply-To: <50FC307A.5090003@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 20 Jan 2013 12:59:22 -0500
Vlad Yasevich <vyasevic@redhat.com> wrote:

> On 01/17/2013 08:57 PM, Micha=B3 Miros=B3aw wrote:
> > 2013/1/16 Vlad Yasevich <vyasevic@redhat.com>:
> > [...]
> >> --- /dev/null
> >> +++ b/net/bridge/br_vlan.c
> > [...]
> >> +struct net_port_vlan *nbp_vlan_find(const struct net_port_vlans *=
v, u16 vid)
> >> +{
> >> +       struct net_port_vlan *pve;
> >> +
> >> +       /* Must be done either in rcu critical section or with RTN=
L held */
> >> +       WARN_ON_ONCE(!rcu_read_lock_held() && !rtnl_is_locked());
> >> +
> >> +       list_for_each_entry_rcu(pve, &v->vlan_list, list) {
> >> +               if (pve->vid =3D=3D vid)
> >> +                       return pve;
> >> +       }
> >> +
> >> +       return NULL;
> >> +}
> >
> > This looks expensive - it's O(n) with n =3D number of configured VL=
ANs on a port.
> > And this is called for every packet. The bridge already has a hash =
of VLAN
> > structures found by br_vlan_find(). You could add a second bitmap t=
here
> > (eg. ingres_ports[]) and check port's bit instead of walking the li=
st.
> > You would use a bit more memory (64 bytes minus the removed list-he=
ad)
> > per configured VLAN but save some cycles in hot path.
> >
>=20
> Technically wouldn't even need another bitmap as an existing membersh=
ip=20
> bitmap would cover this case.  I did some profiling and the list is=20
> faster for 3 vlans per port.  Hash is faster for more then 3 vlans.
>=20
> I can easily switch to hash if that is what others think.
>=20
> -vlad

Let's assume the people that really want this feature are using a lot
of vlan's. i.e n =3D 1000 or so. A bitmap is O(1). Any hash list would
incur a just a big memory penalty for the list head. In other words
a full bitmap is 4096 bits =3D 512 bytes.  If you use hash list,
then the equivalent memory size would be only 64 list heads, therefore
a bitmap is a better choice than a hlist.
