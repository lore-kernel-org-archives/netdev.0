From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [Xen-devel] [PATCH net-next v2 2/9] xen-netback: Change TX path
 from grant copy to mapping
Date: Mon, 30 Dec 2013 17:58:47 +0000
Message-ID: <52C1B457.90609@citrix.com>
References: <1386892097-15502-1-git-send-email-zoltan.kiss@citrix.com> <1386892097-15502-3-git-send-email-zoltan.kiss@citrix.com> <20131217214919.GC32553@phenom.dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131217214919.GC32553@phenom.dumpdata.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 17/12/13 21:49, Konrad Rzeszutek Wilk wrote:
> On Thu, Dec 12, 2013 at 11:48:10PM +0000, Zoltan Kiss wrote:
>> @@ -485,6 +520,22 @@ void xenvif_disconnect(struct xenvif *vif)
>>
>>   void xenvif_free(struct xenvif *vif)
>>   {
>> +	int i, unmap_timeout = 0;
>> +
>> +	for (i = 0; i < MAX_PENDING_REQS; ++i) {
>> +		if (vif->grant_tx_handle[i] != NETBACK_INVALID_HANDLE) {
>> +			i = 0;
>> +			unmap_timeout++;
>> +			msleep(1000);
>
> You don't want to use schedule() and a wakeup here to allow other threads
> to do their work?
Yep, schedule_timeout() would be nicer indeed

>
>> +			if (unmap_timeout > 9 &&
>> +				net_ratelimit())
>> +				netdev_err(vif->dev,
>> +					"Page still granted! Index: %x\n", i);
>> +		}
>> +	}
>> +
>> +	free_xenballooned_pages(MAX_PENDING_REQS, vif->mmap_pages);
>
> How about just stashing those pages on a 'I can't free them' list that will
> keep them forever. And if that list gets truly large then switch back to
> grant_copy?
But then what would you answer to the guest? You can't shoot the shared 
ring until there is an outstanding slot.
On the other hand, doing a copy would just move the memory leak into the 
backend, which could be problematic if a guest figures out how to make a 
packet which can get stucked somewhere in the backend.

Zoli
