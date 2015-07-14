From: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v1 05/12] IB/cm: Share listening CM IDs
Date: Tue, 14 Jul 2015 11:45:15 +0300
Message-ID: <55A4CC1B.1060201@mellanox.com>
References: <1434976961-27424-1-git-send-email-haggaie@mellanox.com>
 <1434976961-27424-6-git-send-email-haggaie@mellanox.com>
 <20150713174837.GH23832@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150713174837.GH23832-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 13/07/2015 20:48, Jason Gunthorpe wrote:
> On Mon, Jun 22, 2015 at 03:42:34PM +0300, Haggai Eran wrote:
>>  		spin_lock_irq(&cm.lock);
>> +		if (--cm_id_priv->listen_sharecount > 0) {
>> +			/* The id is still shared. */
>> +			atomic_dec(&cm_id_priv->refcount);
> 
> Nit: This looks very strange not to be cm_deref_id .. Looks OK as is
> because we are sure refcount cannot be 0 here?

Yes, and because of the spin lock. But I'll change it to cm_deref_id()
so that it's more uniform.

> 
>> @@ -958,8 +988,10 @@ int ib_cm_listen(struct ib_cm_id *cm_id, __be64 service_id, __be64 service_mask,
>>  	}
>>  
>>  	cm_id->state = IB_CM_LISTEN;
>> +	++cm_id_priv->listen_sharecount;
>>
>> -	spin_lock_irqsave(&cm.lock, flags);
>> +	if (lock)
>> +		spin_lock_irqsave(&cm.lock, flags);
> 
> Hmm, I'd like to see the listen_sharecount consistently locked, so it
> should be manipulated only while cm.lock is held..

You're right. I'll move it inside the lock.

> 
>>  	if (service_id == IB_CM_ASSIGN_SERVICE_ID) {
>>  		cm_id->service_id = cpu_to_be64(cm.listen_service_id++);
>>  		cm_id->service_mask = ~cpu_to_be64(0);
>> @@ -968,18 +1000,98 @@ int ib_cm_listen(struct ib_cm_id *cm_id, __be64 service_id, __be64 service_mask,
>>  		cm_id->service_mask = service_mask;
>>  	}
>>  	cur_cm_id_priv = cm_insert_listen(cm_id_priv);
>> -	spin_unlock_irqrestore(&cm.lock, flags);
>> +	if (lock)
>> +		spin_unlock_irqrestore(&cm.lock, flags);
>>  
>>  	if (cur_cm_id_priv) {
>>  		cm_id->state = IB_CM_IDLE;
>> +		--cm_id_priv->listen_sharecount;
> 
> Ditto
Okay. I'll move the lock release to the end of the function.

> 
> Otherwise I don't see any other mechanical problems with this. Sean
> said he was happy with the idea right?
I assume he is, since he reviewed the patch and found that
listen_sharecount leak, but he can speak for himself.

> 
> Reviewed-By: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Thanks.
Can I add it with the modifications above?

Haggai
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
