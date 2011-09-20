From: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH v5 1/8] SUNRPC: introduce helpers for reference counted
 rpcbind clients
Date: Tue, 20 Sep 2011 18:43:45 +0400
Message-ID: <4E78A6A1.1000800@parallels.com>
References: <20110920101031.9861.18444.stgit@localhost6.localdomain6>	<20110920101341.9861.51453.stgit@localhost6.localdomain6>	<4E7899E7.9090809@parallels.com> <20110920102431.58ca1d96@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org" <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Pavel Emelianov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"neilb-l3A5Bk7waGM@public.gmane.org" <neilb-l3A5Bk7waGM@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110920102431.58ca1d96-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

20.09.2011 18:24, Jeff Layton =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Tue, 20 Sep 2011 17:49:27 +0400
> Stanislav Kinsbursky<skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>  wrote:
>
>> v5: fixed races with rpcb_users in rpcb_get_local()
>>
>> This helpers will be used for dynamical creation and destruction of =
rpcbind
>> clients.
>> Variable rpcb_users is actually a counter of lauched RPC services. I=
f rpcbind
>> clients has been created already, then we just increase rpcb_users.
>>
>> Signed-off-by: Stanislav Kinsbursky<skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
>>
>> ---
>>    net/sunrpc/rpcb_clnt.c |   53 +++++++++++++++++++++++++++++++++++=
+++++++++++++
>>    1 files changed, 53 insertions(+), 0 deletions(-)
>>
>> diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
>> index e45d2fb..5f4a406 100644
>> --- a/net/sunrpc/rpcb_clnt.c
>> +++ b/net/sunrpc/rpcb_clnt.c
>> @@ -114,6 +114,9 @@ static struct rpc_program	rpcb_program;
>>    static struct rpc_clnt *	rpcb_local_clnt;
>>    static struct rpc_clnt *	rpcb_local_clnt4;
>>    +DEFINE_SPINLOCK(rpcb_clnt_lock);
>> +unsigned int			rpcb_users;
>> +
>>    struct rpcbind_args {
>>    	struct rpc_xprt *	r_xprt;
>>    @@ -161,6 +164,56 @@ static void rpcb_map_release(void *data)
>>    	kfree(map);
>>    }
>>    +static int rpcb_get_local(void)
>> +{
>> +	int cnt;
>> +
>> +	spin_lock(&rpcb_clnt_lock);
>> +	if (rpcb_users)
>> +		rpcb_users++;
>> +	cnt =3D rpcb_users;
>> +	spin_unlock(&rpcb_clnt_lock);
>> +
>> +	return cnt;
>> +}
>> +
>> +void rpcb_put_local(void)
>> +{
>> +	struct rpc_clnt *clnt =3D rpcb_local_clnt;
>> +	struct rpc_clnt *clnt4 =3D rpcb_local_clnt4;
>> +	int shutdown;
>> +
>> +	spin_lock(&rpcb_clnt_lock);
>> +	if (--rpcb_users =3D=3D 0) {
>> +		rpcb_local_clnt =3D NULL;
>> +		rpcb_local_clnt4 =3D NULL;
>> +	}
>
> In the function below, you mention that the above pointers are
> protected by rpcb_create_local_mutex, but it looks like they get rese=
t
> here without that being held?
>

Assigning of them is protected by rpcb_create_local_mutex.
Dereferencing of them is protected by rpcb_clnt_lock.

> Might it be simpler to just protect rpcb_users with the
> rpcb_create_local_mutex and ensure that it's held whenever you call o=
ne
> of these routines? None of these are codepaths are particularly hot.
>

I just inherited this lock-mutex logic.
Actually, you right. This codepaths are used rarely.
But are use sure, that we need to remove this "speed-up" logic if we ta=
ke into=20
account that it was here already?

>> +	shutdown =3D !rpcb_users;
>> +	spin_unlock(&rpcb_clnt_lock);
>> +
>> +	if (shutdown) {
>> +		/*
>> +		 * cleanup_rpcb_clnt - remove xprtsock's sysctls, unregister
>> +		 */
>> +		if (clnt4)
>> +			rpc_shutdown_client(clnt4);
>> +		if (clnt)
>> +			rpc_shutdown_client(clnt);
>> +	}
>> +	return;
>> +}
>> +
>> +static void rpcb_set_local(struct rpc_clnt *clnt, struct rpc_clnt *=
clnt4)
>> +{
>> +	/* Protected by rpcb_create_local_mutex */
>> +	rpcb_local_clnt =3D clnt;
>> +	rpcb_local_clnt4 =3D clnt4;
>> +	rpcb_users++;
>> +	dprintk("RPC:       created new rpcb local clients (rpcb_local_cln=
t: "
>> +			"%p, rpcb_local_clnt4: %p)\n", rpcb_local_clnt,
>> +			rpcb_local_clnt4);
>> +}
>> +
>>    /*
>>     * Returns zero on success, otherwise a negative errno value
>>     * is returned.
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs"=
 in
>> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>


--=20
Best regards,
Stanislav Kinsbursky
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
