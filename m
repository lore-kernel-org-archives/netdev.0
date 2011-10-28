From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [PATCH v6 4/8] SUNRPC: setup rpcbind clients if service requires
 it
Date: Fri, 28 Oct 2011 13:27:01 +0400
Message-ID: <4EAA7565.1040101@parallels.com>
References: <20111025100826.12689.46944.stgit@localhost6.localdomain6> <20111025101705.12689.68022.stgit@localhost6.localdomain6> <20111027212732.GC31669@fieldses.org>
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
	"davem@davemloft.net" <davem@davemloft.net>,
	"devel@openvz.org" <devel@openvz.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111027212732.GC31669@fieldses.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

28.10.2011 01:27, J. Bruce Fields =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Tue, Oct 25, 2011 at 02:17:08PM +0300, Stanislav Kinsbursky wrote:
>> New function ("svc_uses_rpcbind") will be used to detect, that new s=
ervice will
>> send portmapper register calls. For such services we will create rpc=
bind
>> clients and remove all stale portmap registrations.
>> Also, svc_rpcb_cleanup() will be set as sv_shutdown callback for suc=
h services
>> in case of this field wasn't initialized earlier. This will allow to=
 destroy
>> rpcbind clients when no other users of them left.
>>
>> Note: Currently, any creating service will be detected as portmap us=
er.
>> Probably, this is wrong. But now it depends on program versions "vs_=
hidden"
>> flag.
>>
>> Signed-off-by: Stanislav Kinsbursky<skinsbursky@parallels.com>
>>
>> ---
>>   net/sunrpc/svc.c |   11 +++++++++--
>>   1 files changed, 9 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
>> index d2d61bf..918edc3 100644
>> --- a/net/sunrpc/svc.c
>> +++ b/net/sunrpc/svc.c
>> @@ -454,8 +454,15 @@ __svc_create(struct svc_program *prog, unsigned=
 int bufsize, int npools,
>>   		spin_lock_init(&pool->sp_lock);
>>   	}
>>
>> -	/* Remove any stale portmap registrations */
>> -	svc_unregister(serv);
>> +	if (svc_uses_rpcbind(serv)) {
>> +	       	if (svc_rpcb_setup(serv)<  0) {
>> +			kfree(serv->sv_pools);
>> +			kfree(serv);
>> +			return NULL;
>
> Nit: could we convert this (and the previous failure to allocate
> sv_pools) to the usual pattern of collecting the cleanup at the end a=
nd
> jumping to it with a goto?
>

Sure, we can. I will implement this "goto pattern", is you insist.

> Looks fine otherwise.
>
> --b.
>
>> +		}
>> +		if (!serv->sv_shutdown)
>> +			serv->sv_shutdown =3D svc_rpcb_cleanup;
>> +	}
>>
>>   	return serv;
>>   }
>>


--=20
Best regards,
Stanislav Kinsbursky
