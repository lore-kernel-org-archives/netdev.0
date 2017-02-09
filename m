From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH RFC v2 1/8] xdp: Infrastructure to generalize XDP
Date: Thu, 9 Feb 2017 14:22:34 +0000
Message-ID: <BL2PR07MB2306990912A16BD6B9A5FE3F8D450@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <20170208234127.3041579-1-tom@herbertland.com>
 <20170208234127.3041579-2-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "kernel-team@fb.com" <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0089.outbound.protection.outlook.com ([104.47.42.89]:60256
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751644AbdBIOXW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Feb 2017 09:23:22 -0500
In-Reply-To: <20170208234127.3041579-2-tom@herbertland.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> + * Fields:
> + *
> + *   priority - priority for insertion into set. The set is ordered lowe=
st to
> + *	highest priority.
> + *   is_bpf - indicates that the hook is a BPF program (priv refers to a
> + *	bpf_prog structure. This allows calling the BPF program directly
> + *	from xdp_run without a extra level of indirection.
> + *   hookfn - function to call when hook are run.
> + *   priv - private data associated with hook. This is passed as an argu=
ment
> + *	to the hook function (in the case of BPF this is a bpf_prog structure=
).
> + *   put_priv - function call when XDP is done with private data.
> + *   def - point to definitions of xdp_hook. The pointer value is saved =
as

def->template

> + *      a refernce the instance of hook loaded (used to find and unregis=
ter a
> + *      hook).
> + *   tag - readable tag for reporting purposes
> + */
> +struct xdp_hook {
> +	int priority;
> +	bool is_bpf;
> +	xdp_hookfn *hookfn;
> +	void __rcu *priv;
> +	xdp_put_privfn *put_priv;
> +	const struct xdp_hook *template;
> +	u8 tag[XDP_TAG_SIZE];
> +};

...

> +static inline int __xdp_run_one_hook(struct xdp_hook *hook,
> +				     struct xdp_buff *xdp)
> +{
> +	void *priv =3D rcu_dereference(hook->priv);
> +
> +	if (hook->is_bpf) {

Shouldn't this branch be 'likely' [until we have other flavors of xdp]?

> +		/* Run BPF programs directly do avoid one layer of
> +		 * indirection.
> +		 */
> +		return BPF_PROG_RUN((struct bpf_prog *)priv, (void *)xdp);
> +	} else {
> +		return hook->hookfn(priv, xdp);
> +	}
> +}
> +
> +/* Core function to run the XDP hooks. This must be as fast as possible
> +*/ static inline int __xdp_hook_run(struct xdp_hook_set *hook_set,
> +				 struct xdp_buff *xdp,
> +				 struct xdp_hook **last_hook)
> +{
> +	struct xdp_hook *hook;
> +	int i, ret;
> +
> +	if (unlikely(!hook_set))
> +		return XDP_PASS;
> +
> +	hook =3D &hook_set->hooks[0];
> +	ret =3D __xdp_run_one_hook(hook, xdp);
> +	*last_hook =3D hook;

Not setting last_hook in loop; Probably failing the 'last' intention.

> +	for (i =3D 1; i < hook_set->num; i++) {
> +		if (ret !=3D XDP_PASS)
> +			break;
> +		hook =3D &hook_set->hooks[i];
> +		ret =3D __xdp_run_one_hook(hook, xdp);
> +	}
> +
> +	return ret;
> +}
...

> +/* Run a BPF/XDP program. RCU read lock must be held */ static u32
> +dev_bpf_prog_run_xdp(const void *priv,
> +				struct xdp_buff *xdp)
> +{
> +	const struct bpf_prog *prog =3D (const struct bpf_prog *)priv;
> +
> +	return BPF_PROG_RUN(prog, (void *)xdp); }
> +
> +static void dev_bpf_prog_put_xdp(const void *priv) {
> +	bpf_prog_put((struct bpf_prog *)priv); }
> +
> +struct xdp_hook xdp_bpf_hook =3D {
> +	.hookfn =3D dev_bpf_prog_run_xdp,
> +	.put_priv =3D dev_bpf_prog_put_xdp,
> +	.priority =3D 0,
> +	.is_bpf =3D true
> +};

What's the purpose of populating hookfn,
if for performance you've chosen the function based on 'is_bpf'?

...

> -	if (!dev->netdev_ops->ndo_xdp)
> +	if (!(dev->features & NETIF_F_XDP))
>  		return 0;

This should probably go in the cleanup patch.
