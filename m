From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [PATCH v2 3/5] SUNRPC: make RPC service dependable on rpcbind
 clients creation
Date: Mon, 12 Sep 2011 15:22:49 +0400
Message-ID: <4E6DEB89.7080407@parallels.com>
References: <20110909115146.13697.71682.stgit@localhost6.localdomain6>	 <20110909120844.13697.48102.stgit@localhost6.localdomain6>	 <20110909100745.7e2e8bf9@corrin.poochiereds.net>	 <4E6A41D4.6090001@parallels.com>	 <1315593874.17611.19.camel@lade.trondhjem.org>	 <20110909150104.5a83c60d@tlielax.poochiereds.net> <1315596308.17611.46.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Layton <jlayton@redhat.com>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Pavel Emelianov <xemul@parallels.com>,
	"neilb@suse.de" <neilb@suse.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"bfields@fieldses.org" <bfields@fieldses.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1315596308.17611.46.camel@lade.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

09.09.2011 23:25, Trond Myklebust =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Fri, 2011-09-09 at 15:01 -0400, Jeff Layton wrote:
>> On Fri, 09 Sep 2011 14:44:34 -0400
>> Trond Myklebust<Trond.Myklebust@netapp.com>  wrote:
>>
>>> On Fri, 2011-09-09 at 20:41 +0400, Stanislav Kinsbursky wrote:
>>>> 09.09.2011 18:07, Jeff Layton =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>>>>> On Fri, 09 Sep 2011 16:08:44 +0400
>>>>> Stanislav Kinsbursky<skinsbursky@parallels.com>   wrote:
>>>>>
>>>>>> Create rcbind clients or increase rpcbind users counter during R=
PC service
>>>>>> creation and decrease this counter (and possibly destroy those c=
lients) on RPC
>>>>>> service destruction.
>>>>>>
>>>>>> Signed-off-by: Stanislav Kinsbursky<skinsbursky@parallels.com>
>>>>>>
>>>>>> ---
>>>>>>    include/linux/sunrpc/clnt.h |    2 ++
>>>>>>    net/sunrpc/rpcb_clnt.c      |    2 +-
>>>>>>    net/sunrpc/svc.c            |   13 +++++++++++--
>>>>>>    3 files changed, 14 insertions(+), 3 deletions(-)
>>>>>>
>>>>>> diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/=
clnt.h
>>>>>> index db7bcaf..65a8115 100644
>>>>>> --- a/include/linux/sunrpc/clnt.h
>>>>>> +++ b/include/linux/sunrpc/clnt.h
>>>>>> @@ -135,10 +135,12 @@ void		rpc_shutdown_client(struct rpc_clnt =
*);
>>>>>>    void		rpc_release_client(struct rpc_clnt *);
>>>>>>    void		rpc_task_release_client(struct rpc_task *);
>>>>>>
>>>>>> +int		rpcb_create_local(void);
>>>>>>    int		rpcb_register(u32, u32, int, unsigned short);
>>>>>>    int		rpcb_v4_register(const u32 program, const u32 version,
>>>>>>    				 const struct sockaddr *address,
>>>>>>    				 const char *netid);
>>>>>> +void		rpcb_put_local(void);
>>>>>>    void		rpcb_getport_async(struct rpc_task *);
>>>>>>
>>>>>>    void		rpc_call_start(struct rpc_task *);
>>>>>> diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
>>>>>> index b4cc0f1..437ec60 100644
>>>>>> --- a/net/sunrpc/rpcb_clnt.c
>>>>>> +++ b/net/sunrpc/rpcb_clnt.c
>>>>>> @@ -318,7 +318,7 @@ out:
>>>>>>     * Returns zero on success, otherwise a negative errno value
>>>>>>     * is returned.
>>>>>>     */
>>>>>> -static int rpcb_create_local(void)
>>>>>> +int rpcb_create_local(void)
>>>>>>    {
>>>>>>    	static DEFINE_MUTEX(rpcb_create_local_mutex);
>>>>>>    	int result =3D 0;
>>>>>> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
>>>>>> index 6a69a11..9095c0e 100644
>>>>>> --- a/net/sunrpc/svc.c
>>>>>> +++ b/net/sunrpc/svc.c
>>>>>> @@ -367,8 +367,11 @@ __svc_create(struct svc_program *prog, unsi=
gned int bufsize, int npools,
>>>>>>    	unsigned int xdrsize;
>>>>>>    	unsigned int i;
>>>>>>
>>>>>> -	if (!(serv =3D kzalloc(sizeof(*serv), GFP_KERNEL)))
>>>>>> +	if (rpcb_create_local()<   0)
>>>>>>    		return NULL;
>>>>>> +
>>>>>> +	if (!(serv =3D kzalloc(sizeof(*serv), GFP_KERNEL)))
>>>>>> +		goto out_err;
>>>>>>    	serv->sv_name      =3D prog->pg_name;
>>>>>>    	serv->sv_program   =3D prog;
>>>>>>    	serv->sv_nrthreads =3D 1;
>>>>>> @@ -403,7 +406,7 @@ __svc_create(struct svc_program *prog, unsig=
ned int bufsize, int npools,
>>>>>>    			GFP_KERNEL);
>>>>>>    	if (!serv->sv_pools) {
>>>>>>    		kfree(serv);
>>>>>> -		return NULL;
>>>>>> +		goto out_err;
>>>>>>    	}
>>>>>>
>>>>>>    	for (i =3D 0; i<   serv->sv_nrpools; i++) {
>>>>>> @@ -423,6 +426,10 @@ __svc_create(struct svc_program *prog, unsi=
gned int bufsize, int npools,
>>>>>>    	svc_unregister(serv);
>>>>>>
>>>>>>    	return serv;
>>>>>> +
>>>>>> +out_err:
>>>>>> +	rpcb_put_local();
>>>>>> +	return NULL;
>>>>>>    }
>>>>>>
>>>>>>    struct svc_serv *
>>>>>> @@ -491,6 +498,8 @@ svc_destroy(struct svc_serv *serv)
>>>>>>    	svc_unregister(serv);
>>>>>>    	kfree(serv->sv_pools);
>>>>>>    	kfree(serv);
>>>>>> +
>>>>>> +	rpcb_put_local();
>>>>>>    }
>>>>>>    EXPORT_SYMBOL_GPL(svc_destroy);
>>>>>>
>>>>>>
>>>>>
>>>>> I don't get it -- what's the advantage of creating rpcbind client=
s in
>>>>> __svc_create vs. the old way of creating them just before we plan=
 to
>>>>> use them?
>>>>>
>>>>
>>>> The main problem here is not in creation, but in destroying those =
clients.
>>>> Now rpcbind clients are created during rpcb_register(). I.e. once =
per every family, program version and so on.
>>>> But can be unregistered for all protocol families by one call. So =
it's impossible to put reference counting for those clients in the plac=
e, where they are created now.
>>>
>>> Could we perhaps set up a 'struct pernet_operations' to create a
>>> destructor for them?
>>>
>>
>> An even easier idea might be to just not take a reference to the
>> rpcbind client for svc_programs that have vs_hidden set on every
>> version.
>
> Isn't the problem that Stanislav is trying to solve that we need to b=
e
> able to register and unregister RPC services to the correct rpcbind
> server, depending on which net namespace we are in?
>

Yes, it is.
I'm going to make rpcbind clients per net namespace.

> My understanding is that the current code will register everything to
> whatever rpcbind server is running in the init net namespace because
> that's what rpcb_create_local() uses.
>
> My suggestion is to use a struct pernet_operations to detect when a n=
et
> namespace is being created or destroyed, so that the rpcbind client c=
ode
> knows when to create or destroy a connection to the server that is
> running in that namespace.
>

But as Pavel mentioned already, we can't use netns destructor for rpcbi=
nd=20
clients because they holds netns reference.
That's why we have to untie netns from rpbind clients first.
Another solution is to not increment netns ref counter for rpcbind sock=
ets as,=20
again, Pavel already mentioned.
But first approach looks clearer from my pow. That's why I'm trying to =
make=20
rcpbind client's self-destructible.After achieving this we can just mak=
e this=20
rpcbind clients per netns and then we can virtualize lockd.

I've tried to find some better place for creating rpcbind clients (inst=
ead of=20
__svc_create()). But this place looks like the best one for current sol=
ution.

About avoiding of creation of rpcbind clients for nfs 4.* callbacks.
Probably, we can implement init-fini calls for svc_program structure=20
(rpcb_create_local() and rpcb_put_local() will be used in our case) and=
 then=20
inherit them for svc_serv. This will allow us to call this hooks only i=
f they=20
defined and thus avoid rpcbind clients creation for nfs callbacks.

What all of you think about this hook's idea?

> Cheers
>    Trond


--=20
Best regards,
Stanislav Kinsbursky
