From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [PATCH v4 1/8] SUNRPC: introduce helpers for reference counted
 rpcbind clients
Date: Tue, 20 Sep 2011 17:34:49 +0400
Message-ID: <4E789679.1060601@parallels.com>
References: <20110920101031.9861.18444.stgit@localhost6.localdomain6> <20110920101341.9861.51453.stgit@localhost6.localdomain6> <4E788F8C.20103@netapp.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B47FD10@SACMVEXC2-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Pavel Emelianov <xemul@parallels.com>,
	"neilb@suse.de" <neilb@suse.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"bfields@fieldses.org" <bfields@fieldses.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B47FD10@SACMVEXC2-PRD.hq.netapp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

20.09.2011 17:15, Myklebust, Trond =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>> -----Original Message-----
>> From: Schumaker, Bryan
>> Sent: Tuesday, September 20, 2011 9:05 AM
>> To: Stanislav Kinsbursky
>> Cc: Myklebust, Trond; linux-nfs@vger.kernel.org; xemul@parallels.com=
;
>> neilb@suse.de; netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
>> bfields@fieldses.org; davem@davemloft.net
>> Subject: Re: [PATCH v4 1/8] SUNRPC: introduce helpers for reference
>> counted rpcbind clients
>>
>> On 09/20/2011 06:13 AM, Stanislav Kinsbursky wrote:
>>> This helpers will be used for dynamical creation and destruction of
>>> rpcbind clients.
>>> Variable rpcb_users is actually a counter of lauched RPC services. =
If
>>> rpcbind clients has been created already, then we just increase rpc=
b_users.
>>>
>>> Signed-off-by: Stanislav Kinsbursky<skinsbursky@parallels.com>
>>>
>>> ---
>>>   net/sunrpc/rpcb_clnt.c |   50
>> ++++++++++++++++++++++++++++++++++++++++++++++++
>>>   1 files changed, 50 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c index
>>> e45d2fb..8724780 100644
>>> --- a/net/sunrpc/rpcb_clnt.c
>>> +++ b/net/sunrpc/rpcb_clnt.c
>>> @@ -114,6 +114,9 @@ static struct rpc_program	rpcb_program;
>>>   static struct rpc_clnt *	rpcb_local_clnt;
>>>   static struct rpc_clnt *	rpcb_local_clnt4;
>>>
>>> +DEFINE_SPINLOCK(rpcb_clnt_lock);
>>> +unsigned int			rpcb_users;
>>> +
>>>   struct rpcbind_args {
>>>   	struct rpc_xprt *	r_xprt;
>>>
>>> @@ -161,6 +164,53 @@ static void rpcb_map_release(void *data)
>>>   	kfree(map);
>>>   }
>>>
>>> +static int rpcb_get_local(void)
>>> +{
>>> +	spin_lock(&rpcb_clnt_lock);
>>> +	if (rpcb_users)
>>> +		rpcb_users++;
>>> +	spin_unlock(&rpcb_clnt_lock);
>>> +
>>> +	return rpcb_users;
>>          ^^^^^^^^^^^^^^^^^^
>> Is it safe to use this variable outside of the rpcb_clnt_lock?
>>
> Nope. If rpcb_users was zero in the protected section above, nothing =
guarantees that it will still be zero here, and so the caller may get t=
he (wrong) impression that the counter was incremented.
>

Yep, you right. Will fix this races.

>>> +}
>>> +
>>> +void rpcb_put_local(void)
>>> +{
>>> +	struct rpc_clnt *clnt =3D rpcb_local_clnt;
>>> +	struct rpc_clnt *clnt4 =3D rpcb_local_clnt4;
>>> +	int shutdown;
>>> +
>>> +	spin_lock(&rpcb_clnt_lock);
>>> +	if (--rpcb_users =3D=3D 0) {
>>> +		rpcb_local_clnt =3D NULL;
>>> +		rpcb_local_clnt4 =3D NULL;
>>> +	}
>>> +	shutdown =3D !rpcb_users;
>>> +	spin_unlock(&rpcb_clnt_lock);
>>> +
>>> +	if (shutdown) {
>>> +		/*
>>> +		 * cleanup_rpcb_clnt - remove xprtsock's sysctls, unregister
>>> +		 */
>>> +		if (clnt4)
>>> +			rpc_shutdown_client(clnt4);
>>> +		if (clnt)
>>> +			rpc_shutdown_client(clnt);
>>> +	}
>>> +	return;
>>> +}
>>> +
>>> +static void rpcb_set_local(struct rpc_clnt *clnt, struct rpc_clnt
>>> +*clnt4) {
>>> +	/* Protected by rpcb_create_local_mutex */
>
> Doesn't it  need to be protected by rpcb_clnt_lock too?
>

Nope from my pow. It's protected by rpcb_create_local_mutex. I.e. no on=
e will=20
change rpcb_users since it's zero. If it's non zero - we willn't get to=
=20
rpcb_set_local().

>>> +	rpcb_local_clnt =3D clnt;
>>> +	rpcb_local_clnt4 =3D clnt4;
>>> +	rpcb_users++;
> ^^^^^^^^^^^^^^^^^^^
>
>>> +	dprintk("RPC:       created new rpcb local clients (rpcb_local_cl=
nt: "
>>> +			"%p, rpcb_local_clnt4: %p)\n", rpcb_local_clnt,
>>> +			rpcb_local_clnt4);
>>> +}
>>> +
>>>   /*
>>>    * Returns zero on success, otherwise a negative errno value
>>>    * is returned.
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs=
"
>>> in the body of a message to majordomo@vger.kernel.org More
>> majordomo
>>> info at  http://vger.kernel.org/majordomo-info.html
>
> =04=EF=BF=BD{.n=EF=BF=BD+=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=
=EF=BF=BD=EF=BF=BD+%=EF=BF=BD=EF=BF=BDlzwm=EF=BF=BD=EF=BF=BDb=EF=BF=BD=EB=
=A7=B2=EF=BF=BD=EF=BF=BDr=EF=BF=BD=EF=BF=BDzX=EF=BF=BD=EF=BF=BD=19=DF=B2=
)=EF=BF=BD=EF=BF=BD=EF=BF=BDw*=1Fjg=EF=BF=BD=EF=BF=BD=EF=BF=BD=1E=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=DD=A2j/=EF=BF=BD=EF=BF=BD=EF=BF=
=BDz=EF=BF=BD=DE=96=EF=BF=BD=EF=BF=BD2=EF=BF=BD=DE=99=EF=BF=BD=EF=BF=BD=
=EF=BF=BD&=EF=BF=BD)=DF=A1=EF=BF=BDa=EF=BF=BD=EF=BF=BD=7F=EF=BF=BD=EF=BF=
=BD=1E=EF=BF=BDG=EF=BF=BD=EF=BF=BD=EF=BF=BDh=EF=BF=BD=0F=EF=BF=BDj:+v=EF=
=BF=BD=EF=BF=BD=EF=BF=BDw=EF=BF=BD=D9=A5


--=20
Best regards,
Stanislav Kinsbursky
