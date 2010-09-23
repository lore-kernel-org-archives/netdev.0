From: Louis Rilling <Louis.Rilling@kerlabs.com>
Subject: Re: [PATCH 3/8] ns proc: Add support for the network namespace.
Date: Thu, 23 Sep 2010 13:27:39 +0200
Message-ID: <20100923112739.GD2211@hawkmoon.kerlabs.com>
References: <m1ocborgq7.fsf@fess.ebiederm.org> <m17hicrglt.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-26084-1285241231-0001-2"
Cc: linux-kernel@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Daniel Lezcano <daniel.lezcano@free.fr>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Michael Kerrisk <mtk.manpages@gmail.com>,
	Ulrich Drepper <drepper@gmail.com>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	David Miller <davem@davemloft.net>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Pavel Emelyanov <xemul@openvz.org>,
	Pavel Emelyanov <xemul@parallels.com>,
	Ben Greear <greearb@candelatech.com>,
	Matt Helsley <matthltc@us.ibm.com>,
	Jonathan Corbet <corbet@lwn.net>,
	Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>,
	Jan Engelhardt <jengelh@medozas.de>,
	Patrick McHardy <kaber@trash.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m17hicrglt.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-26084-1285241231-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 23/09/10  1:47 -0700, Eric W. Biederman wrote:
>=20
> Implementing file descriptors for the network namespace is simple and
> straight forward.
>=20
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

[...]

> diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
> index c988e68..581a088 100644
> --- a/net/core/net_namespace.c
> +++ b/net/core/net_namespace.c
> @@ -571,3 +571,33 @@ void unregister_pernet_device(struct pernet_operatio=
ns *ops)
>  	mutex_unlock(&net_mutex);
>  }
>  EXPORT_SYMBOL_GPL(unregister_pernet_device);
> +
> +#ifdef CONFIG_NET_NS
> +static void *netns_get(struct task_struct *task)
> +{
> +	struct net *net;
> +	rcu_read_lock();
> +	net =3D get_net(task->nsproxy->net_ns);

task could be exiting, so task->nsproxy could be NULL, right?
Maybe make proc_ns_instantiate() rcu_dereference task->nsproxy, check for it
being not NULL, and pass task->nsproxy to ns_ops->get()?

That could be an issue for the user namespace since it is not in nsproxy, b=
ut
maybe no reasonable usage of ns_ops with user namespaces is envisioned.
Otherwise, checking that task is alive with RCU locked in proc_ns_instantia=
te() should be enough to be
rely on task->cred when calling ns_ops->get().

Thanks,

Louis

> +	rcu_read_unlock();
> +	return net;
> +}
> +
> +static void netns_put(void *ns)
> +{
> +	put_net(ns);
> +}
> +
> +static int netns_install(struct nsproxy *nsproxy, void *ns)
> +{
> +	put_net(nsproxy->net_ns);
> +	nsproxy->net_ns =3D get_net(ns);
> +	return 0;
> +}
> +
> +const struct proc_ns_operations netns_operations =3D {
> +	.name		=3D PROC_NSNAME("net"),
> +	.get		=3D netns_get,
> +	.put		=3D netns_put,
> +	.install	=3D netns_install,
> +};
> +#endif
> --=20
> 1.6.5.2.143.g8cc62
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-26084-1285241231-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkybOasACgkQVKcRuvQ9Q1SeLQCeNJvD+892JCE+tRrk9KJXbkL0
CLUAn2HD5GwEA38yUyN2PlyF0yrwQc9j
=NeV1
-----END PGP SIGNATURE-----

--=_bohort-26084-1285241231-0001-2--
