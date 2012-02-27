From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [PATCH v2 2/4] NFS: release per-net clients lock before calling
 PipeFS dentries creation
Date: Mon, 27 Feb 2012 20:20:46 +0400
Message-ID: <4F4BAD5E.9000600@parallels.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B6E7E@saturn3.aculab.com>
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
	James Bottomley <jbottomley@parallels.com>,
	"bfields@fieldses.org" <bfields@fieldses.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"devel@openvz.org" <devel@openvz.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6E7E@saturn3.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

27.02.2012 19:59, David Laight =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>
>>   	spin_lock(&nn->nfs_client_lock);
>> -	list_for_each_entry(clp,&nn->nfs_client_list, cl_share_link) {
>> +	list_for_each_entry_safe(clp, tmp,&nn->nfs_client_list,
> cl_share_link) {
>>   		if (clp->rpc_ops !=3D&nfs_v4_clientops)
>>   			continue;
>> +		atomic_inc(&clp->cl_count);
>> +		spin_unlock(&nn->nfs_client_lock);
>>   		error =3D __rpc_pipefs_event(clp, event, sb);
>> +		nfs_put_client(clp);
>>   		if (error)
>>   			break;
>> +		spin_lock(&nn->nfs_client_lock);
>>   	}
>>   	spin_unlock(&nn->nfs_client_lock);
>>   	return error;
>
> The locking doesn't look right if the loop breaks on error.
> (Same applied to patch v2 1/4)
>

Thanks for the catch. I'll fix this.

> Although list_fo_each_entry_safe() allows the current entry
> to be freed, I don't believe it allows the 'next' to be freed.
> I doubt there is protection against that happening.
>

We need to use safe macro, because client can be destroyed on nfs_put_c=
lient() call.
About "protection against ... the 'next' to be freed" - I dont' think, =
that we=20
need any protection against it. This will be done under nfs_client_lock=
, and=20
current entry list pointers will be updated properly.

> Do you need to use an atomic_inc() for cl_count.
> I'd guess the nfs_client_lock is usually held?
>

Sorry, I don't understand this question.

--=20
Best regards,
Stanislav Kinsbursky
