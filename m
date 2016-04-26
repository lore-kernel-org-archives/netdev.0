From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH 2/2] vhost: lockless enqueuing
Date: Tue, 26 Apr 2016 15:05:20 +0800
Message-ID: <571F1330.7030504@redhat.com>
References: <1461636873-45335-1-git-send-email-jasowang@redhat.com>
 <1461636873-45335-2-git-send-email-jasowang@redhat.com>
 <2033086948.46236145.1461651858100.JavaMail.zimbra@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Pankaj Gupta <pagupta@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2033086948.46236145.1461651858100.JavaMail.zimbra@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 04/26/2016 02:24 PM, Pankaj Gupta wrote:
> Hi Jason,
>
> Overall patches look good. Just one doubt I have is below:
>> We use spinlock to synchronize the work list now which may cause
>> unnecessary contentions. So this patch switch to use llist to remove
>> this contention. Pktgen tests shows about 5% improvement:
>>
>> Before:
>> ~1300000 pps
>> After:
>> ~1370000 pps
>>
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>> ---
>>  drivers/vhost/vhost.c | 52
>>  +++++++++++++++++++++++++--------------------------
>>  drivers/vhost/vhost.h |  7 ++++---
>>  2 files changed, 29 insertions(+), 30 deletions(-)

[...]

>> -		if (work) {
>> +		node = llist_del_all(&dev->work_list);
>> +		if (!node)
>> +			schedule();
>> +
>> +		node = llist_reverse_order(node);
> Can we avoid llist reverse here?
>

Probably not, this is because:

- we should process the work exactly the same order as they were queued,
otherwise flush won't work
- llist can only add a node to the head of list.

Thanks
