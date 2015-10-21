From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH v4 1/2] geneve: implement support for IPv6-based tunnels
Date: Wed, 21 Oct 2015 14:58:38 -0400
Message-ID: <20151021185838.GA2940@tuxdriver.com>
References: <1443638045-27229-1-git-send-email-linville@tuxdriver.com>
 <1445353866-32710-1-git-send-email-linville@tuxdriver.com>
 <5626EFEB.9050906@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Dave Miller <davem@davemloft.net>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>, Jiri Benc <jbenc@redhat.com>
To: YOSHIFUJI =?utf-8?B?SGlkZWFraS/lkInol6Toi7HmmI4=?=
	<hideaki.yoshifuji@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38423 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753716AbbJUTAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 15:00:20 -0400
Content-Disposition: inline
In-Reply-To: <5626EFEB.9050906@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 21, 2015 at 10:52:43AM +0900, YOSHIFUJI Hideaki/=E5=90=89=E8=
=97=A4=E8=8B=B1=E6=98=8E wrote:
> Hi,

Yoshifuji-san -- thank you for taking a look at my proposed patch!

> John W. Linville wrote:
> > Signed-off-by: John W. Linville <linville@tuxdriver.com>
> > ---
> > v4:
> > - treat mode field of ip_tunnel_info as flags
> > - add a missing IS_ENABLED(CONFIG_IPV6) to geneve_rx
> > - remove unneeded flags field in geneve_dev
> > - NULL-check parameter for __geneve_sock_release
> > - check remote socket family for AF_UNSPEC in geneve_configure
> > - rename geneve_get_{rt,dst} as geneve_get_{v4_rt,v6_dst}
> > - refactor some error handling in the xmit paths
> >=20
> > v3:
> > - declare geneve_remote_unspec as static
> >=20
> > v2:
> > - do not require remote address for tx on metadata tunnels
> > - pass correct sockaddr family to udp_tun_rx_dst in geneve_rx
> > - accommodate both ipv4 and ipv6 sockets open on same tunnel
> > - move declaration of geneve_get_dst for aesthetic purposes
> >=20
> >  drivers/net/geneve.c         | 459 +++++++++++++++++++++++++++++++=
++++--------
> >  include/uapi/linux/if_link.h |   1 +
> >  2 files changed, 377 insertions(+), 83 deletions(-)
> >=20
> > diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
> > index 8f5c02eed47d..217b472ab9e7 100644
> > --- a/drivers/net/geneve.c
> > +++ b/drivers/net/geneve.c
> > @@ -46,16 +46,25 @@ struct geneve_net {
> > =20
> >  static int geneve_net_id;
> > =20
> > +union geneve_addr {
> > +	struct sockaddr_in sin;
> > +	struct sockaddr_in6 sin6;
> > +	struct sockaddr sa;
> > +};
> > +
> > +static union geneve_addr geneve_remote_unspec =3D { .sa.sa_family =
=3D AF_UNSPEC, };
> > +
> >  /* Pseudo network device */
> >  struct geneve_dev {
> >  	struct hlist_node  hlist;	/* vni hash table */
> >  	struct net	   *net;	/* netns for packet i/o */
> >  	struct net_device  *dev;	/* netdev for geneve tunnel */
> > -	struct geneve_sock *sock;	/* socket used for geneve tunnel */
> > +	struct geneve_sock *sock4;	/* IPv4 socket used for geneve tunnel =
*/
> > +	struct geneve_sock *sock6;	/* IPv6 socket used for geneve tunnel =
*/
> >  	u8                 vni[3];	/* virtual network ID for tunnel */
> >  	u8                 ttl;		/* TTL override */
> >  	u8                 tos;		/* TOS override */
> > -	struct sockaddr_in remote;	/* IPv4 address for link partner */
> > +	union geneve_addr  remote;	/* IP address for link partner */
> >  	struct list_head   next;	/* geneve's per namespace list */
> >  	__be16		   dst_port;
> >  	bool		   collect_md;
> > @@ -103,11 +112,32 @@ static struct geneve_dev *geneve_lookup(struc=
t geneve_sock *gs,
> >  	vni_list_head =3D &gs->vni_list[hash];
> >  	hlist_for_each_entry_rcu(geneve, vni_list_head, hlist) {
> >  		if (!memcmp(vni, geneve->vni, sizeof(geneve->vni)) &&
> > -		    addr =3D=3D geneve->remote.sin_addr.s_addr)
> > +		    addr =3D=3D geneve->remote.sin.sin_addr.s_addr)
> > +			return geneve;
> > +	}
> > +	return NULL;
> > +}
> > +
> > +#if IS_ENABLED(CONFIG_IPV6)
> > +static struct geneve_dev *geneve6_lookup(struct geneve_sock *gs,
> > +					 struct in6_addr addr6, u8 vni[])
> > +{
> > +	struct hlist_head *vni_list_head;
> > +	struct geneve_dev *geneve;
> > +	__u32 hash;
> > +
> > +	/* Find the device for this VNI */
> > +	hash =3D geneve_net_vni_hash(vni);
> > +	vni_list_head =3D &gs->vni_list[hash];
> > +	hlist_for_each_entry_rcu(geneve, vni_list_head, hlist) {
> > +		if (!memcmp(vni, geneve->vni, sizeof(geneve->vni)) &&
> > +		    !memcmp(&addr6, &geneve->remote.sin6.sin6_addr,
> > +			    sizeof(addr6)))
>=20
> Please use ipv6_addr_equal().

Sure, no problem.

> How do you handle link-local addresses here?

Hmmmm...TBH, I had completely overlooked link-local addresses.
Do you have any suggestions for how to address this shortcoming?

Thanks,

John
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
