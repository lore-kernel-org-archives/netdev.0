From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [PATCH v6 1/8] SUNRPC: introduce helpers for reference counted
 rpcbind clients
Date: Fri, 23 Sep 2011 18:41:21 +0400
Message-ID: <4E7C9A91.1060301@parallels.com>
References: <20110920101031.9861.18444.stgit@localhost6.localdomain6> <20110920101341.9861.51453.stgit@localhost6.localdomain6> <4E7899E7.9090809@parallels.com> <4E79A95F.8050304@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Pavel Emelianov <xemul@parallels.com>,
	"neilb@suse.de" <neilb@suse.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"bfields@fieldses.org" <bfields@fieldses.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4E79A95F.8050304@parallels.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Trond, is this patch version suits you now? Or not?
Please, comment somehow to let me know, may I proceed with further deve=
lopment=20
or not.

Sorry for disturbing (if so).

21.09.2011 13:07, Stanislav Kinsbursky =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> v6:
> 1) added write memory barrier to rpcb_set_local to make sure, that rp=
cbind
> clients become valid before rpcb_users assignment
> 2) explicitly set rpcb_users to 1 instead of incrementing it (looks c=
learer from
> my pow).
>
> Notice: write memory barrier after zeroing rpcbind clients in rpcb_pu=
t_local()
> is not required, since to users of them left. New user (service) will=
 create new
> clients before dereferencing them.
>
> This helpers will be used for dynamical creation and destruction of r=
pcbind
> clients.
> Variable rpcb_users is actually a counter of lauched RPC services. If=
 rpcbind
> clients has been created already, then we just increase rpcb_users.
>
> Signed-off-by: Stanislav Kinsbursky<skinsbursky@parallels.com>
>
> ---
>    net/sunrpc/rpcb_clnt.c |   54 ++++++++++++++++++++++++++++++++++++=
++++++++++++
>    1 files changed, 54 insertions(+), 0 deletions(-)
>
> diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
> index e45d2fb..9fcdb42 100644
> --- a/net/sunrpc/rpcb_clnt.c
> +++ b/net/sunrpc/rpcb_clnt.c
> @@ -114,6 +114,9 @@ static struct rpc_program	rpcb_program;
>    static struct rpc_clnt *	rpcb_local_clnt;
>    static struct rpc_clnt *	rpcb_local_clnt4;
>
> +DEFINE_SPINLOCK(rpcb_clnt_lock);
> +unsigned int			rpcb_users;
> +
>    struct rpcbind_args {
>    	struct rpc_xprt *	r_xprt;
>
> @@ -161,6 +164,57 @@ static void rpcb_map_release(void *data)
>    	kfree(map);
>    }
>
> +static int rpcb_get_local(void)
> +{
> +	int cnt;
> +
> +	spin_lock(&rpcb_clnt_lock);
> +	if (rpcb_users)
> +		rpcb_users++;
> +	cnt =3D rpcb_users;
> +	spin_unlock(&rpcb_clnt_lock);
> +
> +	return cnt;
> +}
> +
> +void rpcb_put_local(void)
> +{
> +	struct rpc_clnt *clnt =3D rpcb_local_clnt;
> +	struct rpc_clnt *clnt4 =3D rpcb_local_clnt4;
> +	int shutdown;
> +
> +	spin_lock(&rpcb_clnt_lock);
> +	if (--rpcb_users =3D=3D 0) {
> +		rpcb_local_clnt =3D NULL;
> +		rpcb_local_clnt4 =3D NULL;
> +	}
> +	shutdown =3D !rpcb_users;
> +	spin_unlock(&rpcb_clnt_lock);
> +
> +	if (shutdown) {
> +		/*
> +		 * cleanup_rpcb_clnt - remove xprtsock's sysctls, unregister
> +		 */
> +		if (clnt4)
> +			rpc_shutdown_client(clnt4);
> +		if (clnt)
> +			rpc_shutdown_client(clnt);
> +	}
> +	return;
> +}
> +
> +static void rpcb_set_local(struct rpc_clnt *clnt, struct rpc_clnt *c=
lnt4)
> +{
> +	/* Protected by rpcb_create_local_mutex */
> +	rpcb_local_clnt =3D clnt;
> +	rpcb_local_clnt4 =3D clnt4;
> +	smp_wmb();
> +	rpcb_users =3D 1;
> +	dprintk("RPC:       created new rpcb local clients (rpcb_local_clnt=
: "
> +			"%p, rpcb_local_clnt4: %p)\n", rpcb_local_clnt,
> +			rpcb_local_clnt4);
> +}
> +
>    /*
>     * Returns zero on success, otherwise a negative errno value
>     * is returned.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--=20
Best regards,
Stanislav Kinsbursky
