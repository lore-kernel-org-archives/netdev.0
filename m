From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net] vhost_net: don't continue to call the recvmsg when
 meet errors
Date: Thu, 1 Dec 2016 11:15:00 +0800
Message-ID: <b0f0299d-efa1-daae-347f-cc2031bdb7cb@redhat.com>
References: <1480507857-22976-1-git-send-email-wangyunjian@huawei.com>
 <20161130152004-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        caihe@huawei.com
To: "Michael S. Tsirkin" <mst@redhat.com>,
        Yunjian Wang <wangyunjian@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161130152004-mutt-send-email-mst@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016年11月30日 21:40, Michael S. Tsirkin wrote:
> On Wed, Nov 30, 2016 at 08:10:57PM +0800, Yunjian Wang wrote:
>> When we meet an error(err=-EBADFD) recvmsg,
> How do you get EBADFD? Won't vhost_net_rx_peek_head_len
> return 0 in this case, breaking the loop?
>
>> the error handling in vhost
>> handle_rx() will continue. This will cause a soft CPU lockup in vhost thread.
>>
>> Signed-off-by: Yunjian Wang <wangyunjian@huawei.com>
>> ---
>>   drivers/vhost/net.c | 3 +++
>>   1 file changed, 3 insertions(+)
>>
>> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
>> index 5dc128a..edc470b 100644
>> --- a/drivers/vhost/net.c
>> +++ b/drivers/vhost/net.c
>> @@ -717,6 +717,9 @@ static void handle_rx(struct vhost_net *net)
>>   			pr_debug("Discarded rx packet: "
>>   				 " len %d, expected %zd\n", err, sock_len);
>>   			vhost_discard_vq_desc(vq, headcount);
>> +			/* Don't continue to do, when meet errors. */
>> +			if (err < 0)
>> +				goto out;
> You might get e.g. EAGAIN and I think you need to retry
> in this case.

Yes.

>>   			continue;
>>   		}
>>   		/* Supply virtio_net_hdr if VHOST_NET_F_VIRTIO_NET_HDR */
>> -- 
>> 1.9.5.msysgit.1
>>
