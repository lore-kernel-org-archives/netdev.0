From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH 3/3] vhost_net: tx support batching
Date: Fri, 11 Nov 2016 10:27:01 +0800
Message-ID: <04c299cb-7250-5fbf-cf1e-de0a31ece9bf@redhat.com>
References: <1478677113-13126-1-git-send-email-jasowang@redhat.com>
 <1478677113-13126-3-git-send-email-jasowang@redhat.com>
 <20161109215753-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161109215753-mutt-send-email-mst@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016年11月10日 04:05, Michael S. Tsirkin wrote:
> On Wed, Nov 09, 2016 at 03:38:33PM +0800, Jason Wang wrote:
>> This patch tries to utilize tuntap rx batching by peeking the tx
>> virtqueue during transmission, if there's more available buffers in
>> the virtqueue, set MSG_MORE flag for a hint for tuntap to batch the
>> packets. The maximum number of batched tx packets were specified
>> through a module parameter: tx_bached.
>>
>> When use 16 as tx_batched:
> When using
>
>> Pktgen test shows 16% on tx pps in guest.
>> Netperf test does not show obvious regression.
> Why doesn't netperf benefit?

This is probably because the tests (4VCPU, 1queue, TCP, mlx4) does not 
produce 100% stress on vhost thread. In pktgen test, 100% stress on 
vhost thread is achieved easily.

>
>> For safety, 1 were used as the default value for tx_batched.
> s/were used/is used/
>
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
> These tests unfortunately only run a single flow.
> The concern would be whether this increases latency when
> NIC is busy with other flows, so I think this is what
> you need to test.

Multiple flows were tested too, no obvious improvement/regression were 
found.


>
>
>> ---
>>   drivers/vhost/net.c   | 15 ++++++++++++++-
>>   drivers/vhost/vhost.c |  1 +
>>   drivers/vhost/vhost.h |  1 +
>>   3 files changed, 16 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
>> index 5dc128a..51c378e 100644
>> --- a/drivers/vhost/net.c
>> +++ b/drivers/vhost/net.c
>> @@ -35,6 +35,10 @@ module_param(experimental_zcopytx, int, 0444);
>>   MODULE_PARM_DESC(experimental_zcopytx, "Enable Zero Copy TX;"
>>   		                       " 1 -Enable; 0 - Disable");
>>   
>> +static int tx_batched = 1;
>> +module_param(tx_batched, int, 0444);
>> +MODULE_PARM_DESC(tx_batched, "Number of patches batched in TX");
>> +
>>   /* Max number of bytes transferred before requeueing the job.
>>    * Using this limit prevents one virtqueue from starving others. */
>>   #define VHOST_NET_WEIGHT 0x80000
> I think we should do some tests and find a good default.

Ok, will test 4 and 32 to see if there's any difference. (Btw, 16 were 
chosed since dpdk tends to batch 16 packet during TX).

Thanks
