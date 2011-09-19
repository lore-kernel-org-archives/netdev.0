From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [PATCH v3 04/11] SUNRPC: parametrize svc creation calls with
 portmapper flag
Date: Mon, 19 Sep 2011 18:51:31 +0400
Message-ID: <4E7756F3.4080601@parallels.com>
References: <20110913180953.3961.69217.stgit@localhost6.localdomain6>	<20110913181351.3961.70207.stgit@localhost6.localdomain6> <20110919100811.0eaa39fe@tlielax.poochiereds.net>
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
In-Reply-To: <20110919100811.0eaa39fe@tlielax.poochiereds.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

19.09.2011 18:08, Jeff Layton =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Tue, 13 Sep 2011 22:13:51 +0400
> Stanislav Kinsbursky<skinsbursky@parallels.com>  wrote:
>
>> This new flag ("setup_rpcbind) will be used to detect, that new serv=
ice will
>> send portmapper register calls. For such services we will create rpc=
bind
>> clients and remove all stale portmap registrations.
>> Also, svc_rpcb_cleanup() will be set as sv_shutdown callback for suc=
h services
>> in case of this field wasn't initialized earlier. This will allow to=
 destroy
>> rpcbind clients when no other users of them left.
>>
>> Signed-off-by: Stanislav Kinsbursky<skinsbursky@parallels.com>
>>
>> ---
>>   include/linux/sunrpc/svc.h |    2 ++
>>   net/sunrpc/svc.c           |   21 ++++++++++++++-------
>>   2 files changed, 16 insertions(+), 7 deletions(-)
>>
>> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
>> index 223588a..528952a 100644
>> --- a/include/linux/sunrpc/svc.h
>> +++ b/include/linux/sunrpc/svc.h
>> @@ -402,11 +402,13 @@ struct svc_procedure {
>>    * Function prototypes.
>>    */
>>   struct svc_serv *svc_create(struct svc_program *, unsigned int,
>> +			    int setup_rpcbind,
> 				^^^
> 			Instead of adding this parameter, why not
> 			base this on the vs_hidden flag in the
> 			svc_version? IOW, have a function that looks at
> 			all the svc_versions for a particular
> 			svc_program, and returns "true" if any of them
> 			have vs_hidden unset? The mechanism you're
> 			proposing here has the potential to be out of
> 			sync with the vs_hidden flag.
>

Could you, please, clarify me this vs_hidden flag?
I understand, that it's used to avoid portmap registration.
But as I see, it's set only for nfs_callback_version1. But this svc_ver=
sion is a=20
part of nfs4_callback_program with nfs_callback_version4, which is not =
hidden.
Does this flag is missed here? If not, how we can return "true" from yo=
ur=20
proposed function if any of them have vs_hidden unset?

Also sockets for this program are created with SVC_SOCK_ANONYMOUS flag =
and we=20
will not register any of this program versions with portmapper.
Thus, from my pow, this vs_hidden flag affects only svc_unregister. And=
 only=20
nfs_callback_version1. This looks really strange.

I.e. if we use this flag only for passing through this versions during=20
svc_(un)register, and we actually also want to pass through=20
nfs_callback_version4 as well (but just missed this vs_hidden flag for =
it), then=20
with current patch-set we can move this flag from (vs_hidden) svc_versi=
on to=20
svc_program and check it during svc_create instead of my home-brew=20
"setup_rpcbind" variable.

> 			Also, if you're adding an argument to a
> 			function like this, you you really ought to
> 			change the callers in the same patch. Otherwise
> 			you'll cause a build break if someone tries to
> 			bisect and ends up between the patch that
> 			changes the function and the one that changes
> 			the callers.
>
>>   			void (*shutdown)(struct svc_serv *));
>>   struct svc_rqst *svc_prepare_thread(struct svc_serv *serv,
>>   					struct svc_pool *pool);
>>   void		   svc_exit_thread(struct svc_rqst *);
>>   struct svc_serv *  svc_create_pooled(struct svc_program *, unsigne=
d int,
>> +			int setup_rpcbind,
>>   			void (*shutdown)(struct svc_serv *),
>>   			svc_thread_fn, struct module *);
>>   int		   svc_set_num_threads(struct svc_serv *, struct svc_pool *, =
int);
>> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
>> index f31e5cc..03231d5 100644
>> --- a/net/sunrpc/svc.c
>> +++ b/net/sunrpc/svc.c
>> @@ -378,7 +378,7 @@ static void svc_rpcb_cleanup(struct svc_serv *se=
rv)
>>    */
>>   static struct svc_serv *
>>   __svc_create(struct svc_program *prog, unsigned int bufsize, int n=
pools,
>> -	     void (*shutdown)(struct svc_serv *serv))
>> +	     int setup_rpcbind, void (*shutdown)(struct svc_serv *serv))
>>   {
>>   	struct svc_serv	*serv;
>>   	unsigned int vers;
>> @@ -437,29 +437,36 @@ __svc_create(struct svc_program *prog, unsigne=
d int bufsize, int npools,
>>   		spin_lock_init(&pool->sp_lock);
>>   	}
>>
>> -	/* Remove any stale portmap registrations */
>> -	svc_unregister(serv);
>> +	if (setup_rpcbind) {
>> +	       	if (svc_rpcb_setup(serv)<  0) {
>> +			kfree(serv->sv_pools);
>> +			kfree(serv);
>> +			return NULL;
>> +		}
>> +		if (!serv->sv_shutdown)
>> +			serv->sv_shutdown =3D svc_rpcb_cleanup;
>> +	}
>>
>>   	return serv;
>>   }
>>
>>   struct svc_serv *
>>   svc_create(struct svc_program *prog, unsigned int bufsize,
>> -	   void (*shutdown)(struct svc_serv *serv))
>> +	   int setup_rpcbind, void (*shutdown)(struct svc_serv *serv))
>>   {
>> -	return __svc_create(prog, bufsize, /*npools*/1, shutdown);
>> +	return __svc_create(prog, bufsize, /*npools*/1, setup_rpcbind, shu=
tdown);
>>   }
>>   EXPORT_SYMBOL_GPL(svc_create);
>>
>>   struct svc_serv *
>>   svc_create_pooled(struct svc_program *prog, unsigned int bufsize,
>> -		  void (*shutdown)(struct svc_serv *serv),
>> +		  int setup_rpcbind, void (*shutdown)(struct svc_serv *serv),
>>   		  svc_thread_fn func, struct module *mod)
>>   {
>>   	struct svc_serv *serv;
>>   	unsigned int npools =3D svc_pool_map_get();
>>
>> -	serv =3D __svc_create(prog, bufsize, npools, shutdown);
>> +	serv =3D __svc_create(prog, bufsize, npools, setup_rpcbind, shutdo=
wn);
>>
>>   	if (serv !=3D NULL) {
>>   		serv->sv_function =3D func;
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs"=
 in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>


--=20
Best regards,
Stanislav Kinsbursky
