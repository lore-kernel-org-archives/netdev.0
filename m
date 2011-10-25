From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [PATCH v6 1/8] SUNRPC: introduce helpers for reference counted
 rpcbind clients
Date: Tue, 25 Oct 2011 16:41:43 +0400
Message-ID: <4EA6AE87.5000309@parallels.com>
References: <20111025100826.12689.46944.stgit@localhost6.localdomain6>	 <20111025101608.12689.68689.stgit@localhost6.localdomain6> <1319541369.2716.1.camel@lade.trondhjem.org>
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
	"davem@davemloft.net" <davem@davemloft.net>,
	"devel@openvz.org" <devel@openvz.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1319541369.2716.1.camel@lade.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

25.10.2011 15:16, Trond Myklebust =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Tue, 2011-10-25 at 14:16 +0300, Stanislav Kinsbursky wrote:
>> v6:
>> 1) added write memory barrier to rpcb_set_local to make sure, that r=
pcbind
>> clients become valid before rpcb_users assignment
>> 2) explicitly set rpcb_users to 1 instead of incrementing it (looks =
clearer from
>> my pow).
>>
>> v5: fixed races with rpcb_users in rpcb_get_local()
>>
>> This helpers will be used for dynamical creation and destruction of =
rpcbind
>> clients.
>> Variable rpcb_users is actually a counter of lauched RPC services. I=
f rpcbind
>> clients has been created already, then we just increase rpcb_users.
>>
>> Signed-off-by: Stanislav Kinsbursky<skinsbursky@parallels.com>
>>
>> ---
>>   net/sunrpc/rpcb_clnt.c |   54 ++++++++++++++++++++++++++++++++++++=
++++++++++++
>>   1 files changed, 54 insertions(+), 0 deletions(-)
>>
>> diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
>> index e45d2fb..9fcdb42 100644
>> --- a/net/sunrpc/rpcb_clnt.c
>> +++ b/net/sunrpc/rpcb_clnt.c
>> @@ -114,6 +114,9 @@ static struct rpc_program	rpcb_program;
>>   static struct rpc_clnt *	rpcb_local_clnt;
>>   static struct rpc_clnt *	rpcb_local_clnt4;
>>
>> +DEFINE_SPINLOCK(rpcb_clnt_lock);
>> +unsigned int			rpcb_users;
>> +
>>   struct rpcbind_args {
>>   	struct rpc_xprt *	r_xprt;
>>
>> @@ -161,6 +164,57 @@ static void rpcb_map_release(void *data)
>>   	kfree(map);
>>   }
>>
>> +static int rpcb_get_local(void)
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
>
> I'm removing this before applying...
>
Sorry, but I don't understand what exactly you are removing, and why?

>> +}
>> +
>


--=20
Best regards,
Stanislav Kinsbursky
