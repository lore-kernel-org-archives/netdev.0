From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [PATCH v2 3/5] SUNRPC: make RPC service dependable on rpcbind
 clients creation
Date: Fri, 09 Sep 2011 20:41:56 +0400
Message-ID: <4E6A41D4.6090001@parallels.com>
References: <20110909115146.13697.71682.stgit@localhost6.localdomain6>	<20110909120844.13697.48102.stgit@localhost6.localdomain6> <20110909100745.7e2e8bf9@corrin.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Pavel Emelianov <xemul@parallels.com>,
	"neilb@suse.de" <neilb@suse.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"bfields@fieldses.org" <bfields@fieldses.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110909100745.7e2e8bf9@corrin.poochiereds.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

09.09.2011 18:07, Jeff Layton =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Fri, 09 Sep 2011 16:08:44 +0400
> Stanislav Kinsbursky<skinsbursky@parallels.com>  wrote:
>
>> Create rcbind clients or increase rpcbind users counter during RPC s=
ervice
>> creation and decrease this counter (and possibly destroy those clien=
ts) on RPC
>> service destruction.
>>
>> Signed-off-by: Stanislav Kinsbursky<skinsbursky@parallels.com>
>>
>> ---
>>   include/linux/sunrpc/clnt.h |    2 ++
>>   net/sunrpc/rpcb_clnt.c      |    2 +-
>>   net/sunrpc/svc.c            |   13 +++++++++++--
>>   3 files changed, 14 insertions(+), 3 deletions(-)
>>
>> diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt=
=2Eh
>> index db7bcaf..65a8115 100644
>> --- a/include/linux/sunrpc/clnt.h
>> +++ b/include/linux/sunrpc/clnt.h
>> @@ -135,10 +135,12 @@ void		rpc_shutdown_client(struct rpc_clnt *);
>>   void		rpc_release_client(struct rpc_clnt *);
>>   void		rpc_task_release_client(struct rpc_task *);
>>
>> +int		rpcb_create_local(void);
>>   int		rpcb_register(u32, u32, int, unsigned short);
>>   int		rpcb_v4_register(const u32 program, const u32 version,
>>   				 const struct sockaddr *address,
>>   				 const char *netid);
>> +void		rpcb_put_local(void);
>>   void		rpcb_getport_async(struct rpc_task *);
>>
>>   void		rpc_call_start(struct rpc_task *);
>> diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
>> index b4cc0f1..437ec60 100644
>> --- a/net/sunrpc/rpcb_clnt.c
>> +++ b/net/sunrpc/rpcb_clnt.c
>> @@ -318,7 +318,7 @@ out:
>>    * Returns zero on success, otherwise a negative errno value
>>    * is returned.
>>    */
>> -static int rpcb_create_local(void)
>> +int rpcb_create_local(void)
>>   {
>>   	static DEFINE_MUTEX(rpcb_create_local_mutex);
>>   	int result =3D 0;
>> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
>> index 6a69a11..9095c0e 100644
>> --- a/net/sunrpc/svc.c
>> +++ b/net/sunrpc/svc.c
>> @@ -367,8 +367,11 @@ __svc_create(struct svc_program *prog, unsigned=
 int bufsize, int npools,
>>   	unsigned int xdrsize;
>>   	unsigned int i;
>>
>> -	if (!(serv =3D kzalloc(sizeof(*serv), GFP_KERNEL)))
>> +	if (rpcb_create_local()<  0)
>>   		return NULL;
>> +
>> +	if (!(serv =3D kzalloc(sizeof(*serv), GFP_KERNEL)))
>> +		goto out_err;
>>   	serv->sv_name      =3D prog->pg_name;
>>   	serv->sv_program   =3D prog;
>>   	serv->sv_nrthreads =3D 1;
>> @@ -403,7 +406,7 @@ __svc_create(struct svc_program *prog, unsigned =
int bufsize, int npools,
>>   			GFP_KERNEL);
>>   	if (!serv->sv_pools) {
>>   		kfree(serv);
>> -		return NULL;
>> +		goto out_err;
>>   	}
>>
>>   	for (i =3D 0; i<  serv->sv_nrpools; i++) {
>> @@ -423,6 +426,10 @@ __svc_create(struct svc_program *prog, unsigned=
 int bufsize, int npools,
>>   	svc_unregister(serv);
>>
>>   	return serv;
>> +
>> +out_err:
>> +	rpcb_put_local();
>> +	return NULL;
>>   }
>>
>>   struct svc_serv *
>> @@ -491,6 +498,8 @@ svc_destroy(struct svc_serv *serv)
>>   	svc_unregister(serv);
>>   	kfree(serv->sv_pools);
>>   	kfree(serv);
>> +
>> +	rpcb_put_local();
>>   }
>>   EXPORT_SYMBOL_GPL(svc_destroy);
>>
>>
>
> I don't get it -- what's the advantage of creating rpcbind clients in
> __svc_create vs. the old way of creating them just before we plan to
> use them?
>

The main problem here is not in creation, but in destroying those clien=
ts.
Now rpcbind clients are created during rpcb_register(). I.e. once per e=
very family, program version and so on.
But can be unregistered for all protocol families by one call. So it's =
impossible to put reference counting for those clients in the place, wh=
ere they are created now.

> With this scheme, won't we end up creating rpcbind sockets even when =
we
> don't need them? For instance, if I create a callback socket for NFSv=
4
> then I don't really need to talk to rpcbind. With this patch I'll sti=
ll
> get the rpcbind clients created though.
>

Yep, you right. This is not a real problem from my pow.
But I'll think about how to avoid this creation for nfs callbacks.

> It would seem to me to make more sense to create the rpcbind clients
> somewhere closer to svc_setup_socket, and only if SVC_SOCK_ANONYMOUS =
is
> not set.
>

Probably. Will try to find better place.

--=20
Best regards,
Stanislav Kinsbursky
