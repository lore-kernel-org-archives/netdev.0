From: Haggai Eran <haggaie@mellanox.com>
Subject: Re: [PATCH v3 for-next 05/13] IB/cm: Reference count ib_cm_ids
Date: Tue, 12 May 2015 09:50:51 +0300
Message-ID: <5551A2CB.1010407@mellanox.com>
References: <1431253604-9214-1-git-send-email-haggaie@mellanox.com>
 <1431253604-9214-6-git-send-email-haggaie@mellanox.com>
 <20150511183459.GB25405@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Doug Ledford <dledford@redhat.com>, <linux-rdma@vger.kernel.org>,
	<netdev@vger.kernel.org>, Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0076.outbound.protection.outlook.com ([157.56.112.76]:47578
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752418AbbELGvJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 May 2015 02:51:09 -0400
In-Reply-To: <20150511183459.GB25405@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/05/2015 21:34, Jason Gunthorpe wrote:
> On Sun, May 10, 2015 at 01:26:36PM +0300, Haggai Eran wrote:
>> Add reference count (kref) to the ib_cm_id to allow automatic destruction
>> of an ib_cm_id. This will allow multiple RDMA CM IDs to use a single
>> ib_cm_id when they are on different network namespaces.
>>
>> Signed-off-by: Haggai Eran <haggaie@mellanox.com>
>>  drivers/infiniband/core/cm.c | 41 +++++++++++++++++++++++++++++++++++++----
>>  include/rdma/ib_cm.h         | 10 +++++++---
>>  2 files changed, 44 insertions(+), 7 deletions(-)
>>
>> diff --git a/drivers/infiniband/core/cm.c b/drivers/infiniband/core/cm.c
>> index 08b18044552a..6b68402fd6df 100644
>> +++ b/drivers/infiniband/core/cm.c
>> @@ -711,6 +711,7 @@ struct ib_cm_id *ib_create_cm_id(struct ib_device *device,
>>  	cm_id_priv->id.cm_handler = cm_handler;
>>  	cm_id_priv->id.context = context;
>>  	cm_id_priv->id.remote_cm_qpn = 1;
>> +	kref_init(&cm_id_priv->id.ref);
>>  	ret = cm_alloc_id(cm_id_priv);
>>  	if (ret)
>>  		goto error;
> 
> Idiomatically, once kref_init is called, kfree should not be used, you
> have to kref_put to destroy it, this error path calls kfree directly.
> 
> Probably best to just move the kref_init to after the failable call.

Sure.

> 
>> -void ib_destroy_cm_id(struct ib_cm_id *cm_id)
>> +static void __ib_destroy_cm_id(struct kref *ref)
>>  {
>> +	struct ib_cm_id *cm_id = container_of(ref, struct ib_cm_id, ref);
>> +
>>  	cm_destroy_id(cm_id, 0);
>>  }
> 
> Hum, this is quite a heavy free function. Did you check that this is
> safe to do asynchronously, that there are no implicit kref's being
> held by the caller?

I'm not sure what you mean. The function is called by the last kref_put,
and destroys the ID synchronously.

Looking at the code though, I now notice that the other call site to
cm_destroy_id, from within the error path of cm_process_work could now
theoretically destroy an ID with existing references. Is that what you
meant?

Since only listening CM IDs are now shared in RDMA CM, this should not
happen in this patch-set, but perhaps the code can be changed to make
sure it is safe even if that changes. How about if we decrease the
reference count in cm_process_work instead of calling cm_destroy_id
directly? The error code could be stored in the ID.

Alternatively, I can add a WARN macro similar to the one I added in
ib_destroy_cm_id, to verify the reference count is zero when reaching
cm_destroy_id.

Haggai
