From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH rdma-next 11/19] RDMA/netlink: Convert LS to doit callback
Date: Wed, 21 Jun 2017 17:53:54 +0300
Message-ID: <20170621145354.GF1248@mtr-leonro.local>
References: <20170621060528.3752-1-leon@kernel.org>
 <20170621060528.3752-12-leon@kernel.org>
 <022a01d2ea99$3eed7150$bcc853f0$@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="pyE8wggRBhVBcj8z"
Cc: 'Doug Ledford' <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        'Chien Tin Tung' <chien.tin.tung-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        'Stephen Hemminger' <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        'Jiri Pirko' <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        'Ariel Almog' <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        'Linux Netdev' <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <022a01d2ea99$3eed7150$bcc853f0$@opengridcomputing.com>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--pyE8wggRBhVBcj8z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Jun 21, 2017 at 09:18:25AM -0500, Steve Wise wrote:
> > From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> >
> > RDMA_NL_LS protocol is actually is not dump anything,
>
> nit:  "is not" -> "does not"
>
> > but sets data and it should be handled by doit callback.
> >
> > This patch actually converts RDMA_NL_LS to doit callback, while
> > preserving IWCM and RDMA_CM flows through netlink_dump_start().
> >
> > Signed-off-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>
>
>
> > ---
> >  drivers/infiniband/core/addr.c      |  5 ++---
> >  drivers/infiniband/core/core_priv.h |  9 ++++++---
> >  drivers/infiniband/core/device.c    |  6 +++---
> >  drivers/infiniband/core/netlink.c   | 28 ++++++++++------------------
> >  drivers/infiniband/core/sa_query.c  |  8 ++++----
> >  5 files changed, 25 insertions(+), 31 deletions(-)
> >
> > diff --git a/drivers/infiniband/core/addr.c b/drivers/infiniband/core/addr.c
> > index 2cc23a26ce4f..0b283029bc61 100644
> > --- a/drivers/infiniband/core/addr.c
> > +++ b/drivers/infiniband/core/addr.c
> > @@ -129,10 +129,9 @@ static void ib_nl_process_good_ip_rsep(const struct
> > nlmsghdr *nlh)
> >  }
> >
> >  int ib_nl_handle_ip_res_resp(struct sk_buff *skb,
> > -			     struct netlink_callback *cb)
> > +			     struct nlmsghdr *nlh,
> > +			     struct netlink_ext_ack *extack)
> >  {
> > -	const struct nlmsghdr *nlh = (struct nlmsghdr *)cb->nlh;
> > -
> >  	if ((nlh->nlmsg_flags & NLM_F_REQUEST) ||
> >  	    !(NETLINK_CB(skb).sk))
> >  		return -EPERM;
> > diff --git a/drivers/infiniband/core/core_priv.h
> > b/drivers/infiniband/core/core_priv.h
> > index 049ccbfca988..0137aa1ec471 100644
> > --- a/drivers/infiniband/core/core_priv.h
> > +++ b/drivers/infiniband/core/core_priv.h
> > @@ -178,11 +178,14 @@ int ib_sa_init(void);
> >  void ib_sa_cleanup(void);
> >
> >  int ib_nl_handle_resolve_resp(struct sk_buff *skb,
> > -			      struct netlink_callback *cb);
> > +			      struct nlmsghdr *nlh,
> > +			      struct netlink_ext_ack *extack);
> >  int ib_nl_handle_set_timeout(struct sk_buff *skb,
> > -			     struct netlink_callback *cb);
> > +			     struct nlmsghdr *nlh,
> > +			     struct netlink_ext_ack *extack);
> >  int ib_nl_handle_ip_res_resp(struct sk_buff *skb,
> > -			     struct netlink_callback *cb);
> > +			     struct nlmsghdr *nlh,
> > +			     struct netlink_ext_ack *extack);
> >
> >  struct ib_device *__ib_device_get_by_name(const char *name);
> >  #endif /* _CORE_PRIV_H */
> > diff --git a/drivers/infiniband/core/device.c
> b/drivers/infiniband/core/device.c
> > index 4ec1b24258de..7317f203a315 100644
> > --- a/drivers/infiniband/core/device.c
> > +++ b/drivers/infiniband/core/device.c
> > @@ -1034,15 +1034,15 @@ EXPORT_SYMBOL(ib_get_net_dev_by_params);
> >
> >  static const struct rdma_nl_cbs ibnl_ls_cb_table[] = {
> >  	[RDMA_NL_LS_OP_RESOLVE] = {
> > -		.dump = ib_nl_handle_resolve_resp,
> > +		.doit = ib_nl_handle_resolve_resp,
> >  		.flags = RDMA_NL_ADMIN_PERM,
> >  	},
> >  	[RDMA_NL_LS_OP_SET_TIMEOUT] = {
> > -		.dump = ib_nl_handle_set_timeout,
> > +		.doit = ib_nl_handle_set_timeout,
> >  		.flags = RDMA_NL_ADMIN_PERM,
> >  	},
> >  	[RDMA_NL_LS_OP_IP_RESOLVE] = {
> > -		.dump = ib_nl_handle_ip_res_resp,
> > +		.doit = ib_nl_handle_ip_res_resp,
> >  		.flags = RDMA_NL_ADMIN_PERM,
> >  	},
> >  };
> > diff --git a/drivers/infiniband/core/netlink.c
> b/drivers/infiniband/core/netlink.c
> > index 73c74d1cd2a3..52fce73be9c1 100644
> > --- a/drivers/infiniband/core/netlink.c
> > +++ b/drivers/infiniband/core/netlink.c
> > @@ -154,38 +154,30 @@ static int rdma_nl_rcv_msg(struct sk_buff *skb, struct
> > nlmsghdr *nlh,
> >  	int type = nlh->nlmsg_type;
> >  	unsigned int index = RDMA_NL_GET_CLIENT(type);
> >  	unsigned int op = RDMA_NL_GET_OP(type);
> > -	struct netlink_callback cb = {};
> > -	struct netlink_dump_control c = {};
> >  	const struct rdma_nl_cbs *cb_table;
> > -	int ret;
> >
> >  	if (!is_nl_valid(index, op))
> >  		return -EINVAL;
> >
> > -	cb_table = rdma_nl_types[type].cb_table;
> > +	cb_table = rdma_nl_types[index].cb_table;
> >
> >  	if ((cb_table[op].flags & RDMA_NL_ADMIN_PERM) &&
> >  	    !netlink_capable(skb, CAP_NET_ADMIN))
> >  		return -EPERM;
> >
> > -	/*
> > -	 * For response or local service set_timeout request,
> > -	 * there is no need to use netlink_dump_start.
> > -	 */
> > -	if (!(nlh->nlmsg_flags & NLM_F_REQUEST) ||
> > -	    (index == RDMA_NL_LS && op == RDMA_NL_LS_OP_SET_TIMEOUT)) {
> > -		cb.skb = skb;
> > -		cb.nlh = nlh;
> > -		cb.dump = cb_table[op].dump;
> > -		return cb.dump(skb, &cb);
> > -	} else {
> > -		c.dump = cb_table[op].dump;
> > +	/* TODO: Convert IWCM to properly handle doit callbacks */
> > +	if ((nlh->nlmsg_flags & NLM_F_DUMP) || index == RDMA_NL_RDMA_CM
> > ||
> > +	    index == RDMA_NL_IWCM) {
> > +		struct netlink_dump_control c = {
> > +			.dump = cb_table[op].dump,
> > +		};
>
> Any reason you didn't fix IWCM as part of this series?  Or will you fix it in an
> upcoming series?  Also, isn't FIXME: the norm for these sorts of "I don't want
> to fix this now" comments?

I wanted to stop before it is growing into enormous series. There are
number of things which I wanted to discuss and fix before moving forward.

1. What should we do with exported RDMA-CM statistics and structures? I
have a very strong feeling that it is broken and anyway, I'm not going to
use it, because it doesn't follow netlink's TLV style.

2. How to handle IWCM code which sets manually MSG_DONE and isn't using
MULTI flag? It has very similar pattern to my "workarounds", when I didn't
handle properly end of message.

3. Need to remove nl_client from IWCM code.

Thanks

>
>

--pyE8wggRBhVBcj8z
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAllKiIIACgkQ5GN7iDZy
WKfomQ//YnsowHXS5W8TBb8/Q+NRJ0MQWulQZEQJmCH9ax5c0gWdORWohQJ0YMnv
3PBQ1rV5L97pNmg6UZinCVq2KgChJuyXTL39++cc+QHpGmrGExDVXPLwywTENQtq
dGfBROCW1WwtG9TzoQP2GeLRtyrPMlP/yLCGOMJ0cR8QXcPk7gg1qSvfMkf7Kdqb
Ouy6Y6vwtnILm4gpELyTTmXsMQGH3v1T7bHRWUzuGfeXp9BHnqM15CvBcnJ5Dj3H
jz+PdWy0KtPGWVEVK6oSEBYORD5JJoWEJF4PiZkLhinHd/TKj1Gz9AO64PCAWa2/
c4AQl89vje70blgiHwBbCiZn2fqoii58b+UVaurx7xsEht+DCMLZ0o8egHMTZBqx
dEVxMg/C1og0OwG/QDln8IO4Xv+znx5Ws0H9tfP0FCCyZRITZkh2C2/D8oGDnLw4
sHtxxZljCVYFRUIFmcmEIQQ5OAFPdpOr3DxqSypZy7JBmnKvxk8of+tT42OMqzKm
Y8MCkI5qrk+VbRqZwY5ej0fVyotABwt1j571r1Wk7VQ1LN07ww+5/Mu06V1R/QT2
DhbkvHSvmEcj4cCeDEM3Sb6we+SupksIDbCdV9A7/zBK5AqzOjDrv8lrzqRrLD20
oAundvCfieqvSXl9RSDNC7xsuLUycQzhq8PgT+pmeinCsb+Pg2Q=
=cPbK
-----END PGP SIGNATURE-----

--pyE8wggRBhVBcj8z--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
