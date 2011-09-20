From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [PATCH v5 1/8] SUNRPC: introduce helpers for reference counted
 rpcbind clients
Date: Tue, 20 Sep 2011 19:38:49 +0400
Message-ID: <4E78B389.3000307@parallels.com>
References: <20110920101031.9861.18444.stgit@localhost6.localdomain6>	<20110920101341.9861.51453.stgit@localhost6.localdomain6>	<4E7899E7.9090809@parallels.com> <20110920102431.58ca1d96@tlielax.poochiereds.net> <4E78A6A1.1000800@parallels.com> <4E78AA09.1000209@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Layton <jlayton@redhat.com>,
	"Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Pavel Emelianov <xemul@parallels.com>,
	"neilb@suse.de" <neilb@suse.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"bfields@fieldses.org" <bfields@fieldses.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Bryan Schumaker <bjschuma@netapp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4E78AA09.1000209@netapp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

20.09.2011 18:58, Bryan Schumaker =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On 09/20/2011 10:43 AM, Stanislav Kinsbursky wrote:
>> 20.09.2011 18:24, Jeff Layton =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>>> On Tue, 20 Sep 2011 17:49:27 +0400
>>> Stanislav Kinsbursky<skinsbursky@parallels.com>   wrote:
>>>
>>>> v5: fixed races with rpcb_users in rpcb_get_local()
>>>>
>>>> This helpers will be used for dynamical creation and destruction o=
f rpcbind
>>>> clients.
>>>> Variable rpcb_users is actually a counter of lauched RPC services.=
 If rpcbind
>>>> clients has been created already, then we just increase rpcb_users=
=2E
>>>>
>>>> Signed-off-by: Stanislav Kinsbursky<skinsbursky@parallels.com>
>>>>
>>>> ---
>>>>     net/sunrpc/rpcb_clnt.c |   53 ++++++++++++++++++++++++++++++++=
++++++++++++++++
>>>>     1 files changed, 53 insertions(+), 0 deletions(-)
>>>>
>>>> diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
>>>> index e45d2fb..5f4a406 100644
>>>> --- a/net/sunrpc/rpcb_clnt.c
>>>> +++ b/net/sunrpc/rpcb_clnt.c
>>>> @@ -114,6 +114,9 @@ static struct rpc_program    rpcb_program;
>>>>     static struct rpc_clnt *    rpcb_local_clnt;
>>>>     static struct rpc_clnt *    rpcb_local_clnt4;
>>>>     +DEFINE_SPINLOCK(rpcb_clnt_lock);
>>>> +unsigned int            rpcb_users;
>>>> +
>>>>     struct rpcbind_args {
>>>>         struct rpc_xprt *    r_xprt;
>>>>     @@ -161,6 +164,56 @@ static void rpcb_map_release(void *data)
>>>>         kfree(map);
>>>>     }
>>>>     +static int rpcb_get_local(void)
>>>> +{
>>>> +    int cnt;
>>>> +
>>>> +    spin_lock(&rpcb_clnt_lock);
>>>> +    if (rpcb_users)
>>>> +        rpcb_users++;
>>>> +    cnt =3D rpcb_users;
>>>> +    spin_unlock(&rpcb_clnt_lock);
>>>> +
>>>> +    return cnt;
>>>> +}
>>>> +
>>>> +void rpcb_put_local(void)
>>>> +{
>>>> +    struct rpc_clnt *clnt =3D rpcb_local_clnt;
>>>> +    struct rpc_clnt *clnt4 =3D rpcb_local_clnt4;
>>>> +    int shutdown;
>>>> +
>>>> +    spin_lock(&rpcb_clnt_lock);
>>>> +    if (--rpcb_users =3D=3D 0) {
>>>> +        rpcb_local_clnt =3D NULL;
>>>> +        rpcb_local_clnt4 =3D NULL;
>>>> +    }
>>>
>>> In the function below, you mention that the above pointers are
>>> protected by rpcb_create_local_mutex, but it looks like they get re=
set
>>> here without that being held?
>>>
>>
>> Assigning of them is protected by rpcb_create_local_mutex.
>> Dereferencing of them is protected by rpcb_clnt_lock.
>
> Shouldn't you be using the same lock for assigning and dereferencing?=
  Otherwise one thread could change these variables while another is us=
ing them.

Probably I wasn't clear with my previous explanation.
Actually, we use only spinlock to make sure, that the pointers are vali=
d when we=20
dereferencing them. Synchronization point here is rpcb_users counter.
IOW, we use these pointers only from svc code and only after service al=
ready=20
started. And with this patch-set we can be sure, that this pointers has=
 been=20
created already to the point, when this service starts.

But when this counter is zero, we can experience races with assigning t=
hose=20
pointers. It takes a lot of time, so we use local mutex here instead of=
 spinlock.

Have I answered your question?

--=20
Best regards,
Stanislav Kinsbursky
