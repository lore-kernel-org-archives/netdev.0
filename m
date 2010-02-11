From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 2/4] C/R: Basic support for network namespaces and
	devices (v3)
Date: Thu, 11 Feb 2010 12:02:35 +0100
Message-ID: <20100211110234.GA14481@hawkmoon.kerlabs.com>
References: <1265750713-15749-1-git-send-email-danms@us.ibm.com>
	<1265750713-15749-3-git-send-email-danms@us.ibm.com>
	<87ljf1gemh.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2335866093290034840=="
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87ljf1gemh.fsf-FLMGYpZoEPULwtHQx/6qkW3U47Q5hpJU@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Mime-version: 1.0
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--===============2335866093290034840==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-30643-1265886087-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-30643-1265886087-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dan,

On 10/02/10  9:55 -0800, Dan Smith wrote:
> Guilt dropped the new checkpoint_dev.c file when I switched to the
> newer branch.  Sorry about that.  Updated patch included below.
>=20

[...]

> diff --git a/net/checkpoint_dev.c b/net/checkpoint_dev.c
> new file mode 100644
> index 0000000..0dddd15
> --- /dev/null
> +++ b/net/checkpoint_dev.c

[...]

> +
> +static struct nlmsghdr *rtnl_get_response(struct socket *rtnl,
> +					  struct sk_buff **skb)
> +{
> +	int ret;
> +	long timeo =3D MAX_SCHEDULE_TIMEOUT;
> +	struct nlmsghdr *nlh;
> +
> +	ret =3D sk_wait_data(rtnl->sk, &timeo);
> +	if (!ret)
> +		return ERR_PTR(-EPIPE);
> +
> +	*skb =3D skb_dequeue(&rtnl->sk->sk_receive_queue);
> +	if (!*skb)
> +		return ERR_PTR(-EPIPE);
> +
> +	ret =3D -EINVAL;
> +	nlh =3D nlmsg_hdr(*skb);
> +	if (!nlh)
> +		goto err;
> +
> +	if (nlh->nlmsg_type =3D=3D NLMSG_ERROR) {
> +		struct nlmsgerr *errmsg =3D nlmsg_data(nlh);
> +		ret =3D errmsg->error;
> +		goto err;
> +	}
> +
> +	return nlh;
> + err:
> +	kfree_skb(*skb);
> +	*skb =3D NULL;
> +
> +	return ERR_PTR(ret);
> +}
> +

[...]

> +
> +static struct sk_buff *new_link_message(char *this_name, char *peer_name)
> +{
> +	int ret =3D -ENOMEM;
> +	int flags =3D NLM_F_REQUEST | NLM_F_CREATE | NLM_F_ACK;
> +	struct nlmsghdr *nlh;
> +	struct sk_buff *skb;
> +	struct ifinfomsg *ifm;
> +	struct nlattr *linkinfo;
> +
> +	skb =3D nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
> +	if (!skb)
> +		goto out;
> +
> +	nlh =3D nlmsg_put(skb, 0, 0, RTM_NEWLINK, sizeof(*ifm), flags);
> +	if (!nlh)
> +		goto out;
> +
> +	ifm =3D nlmsg_data(nlh);
> +	memset(ifm, 0, sizeof(*ifm));
> +
> +	ret =3D nla_put_string(skb, IFLA_IFNAME, this_name);
> +	if (ret)
> +		goto out;
> +
> +	ret =3D -ENOMEM;
> +
> +	linkinfo =3D nla_nest_start(skb, IFLA_LINKINFO);
> +	if (!linkinfo)
> +		goto out;
> +
> +	if (nla_put_string(skb, IFLA_INFO_KIND, "veth") < 0)
> +		goto out;
> +
> +	ret =3D veth_peer_data(skb, peer_name);
> +	if (ret < 0)
> +		goto out;
> +
> +	nla_nest_end(skb, linkinfo);
> +	nlmsg_end(skb, nlh);
> +
> + out:
> +	if (ret < 0) {
> +		kfree(skb);

I'm definitely not a network expert, but this kfree(skb) should probably be
replaced by kfree_skb(skb).

> +		skb =3D ERR_PTR(ret);
> +	}
> +
> +	return skb;
> +}
> +
> +static struct net_device *new_veth_pair(char *this_name, char *peer_name)
> +{
> +	int ret =3D -ENOMEM;
> +	struct socket *rtnl;
> +	struct sk_buff *skb =3D NULL;
> +	struct nlmsghdr *nlh;
> +	struct msghdr msg;
> +	struct kvec kvec;
> +
> +	skb =3D new_link_message(this_name, peer_name);
> +	if (IS_ERR(skb)) {
> +		ret =3D PTR_ERR(skb);
> +		ckpt_debug("failed to create new link message: %i\n", ret);
> +		skb =3D NULL;
> +		goto out;
> +	}
> +
> +	memset(&msg, 0, sizeof(msg));
> +	kvec.iov_len =3D skb->len;
> +	kvec.iov_base =3D skb->head;
> +
> +	rtnl =3D rtnl_open();
> +	if (IS_ERR(rtnl)) {
> +		ret =3D PTR_ERR(rtnl);
> +		ckpt_debug("Unable to open rtnetlink socket: %i\n", ret);
> +		goto out_noclose;
> +	}
> +
> +	ret =3D kernel_sendmsg(rtnl, &msg, &kvec, 1, kvec.iov_len);
> +	if (ret < 0)
> +		goto out;
> +	else if (ret !=3D skb->len) {
> +		ret =3D -EIO;
> +		goto out;
> +	}
> +
> +	/* Free the send skb to make room for the receive skb */
> +	kfree(skb);

Ditto.

> +
> +	nlh =3D rtnl_get_response(rtnl, &skb);
> +	if (IS_ERR(nlh)) {
> +		ret =3D PTR_ERR(nlh);
> +		ckpt_debug("RTNETLINK said: %i\n", ret);
> +	}
> + out:
> +	rtnl_close(rtnl);
> + out_noclose:
> +	kfree(skb);

Ditto.

Thanks,

Louis

[...]

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-30643-1265886087-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAktz48oACgkQVKcRuvQ9Q1R8iwCg1NsXzt55ggYhsKiCGk78ipJr
tUMAoNFgktXPjrFBuCqUssHDHL6UpIqM
=0mK/
-----END PGP SIGNATURE-----

--=_bohort-30643-1265886087-0001-2--

--===============2335866093290034840==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============2335866093290034840==--
