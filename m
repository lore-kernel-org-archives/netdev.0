From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next 8/8] vhost_net: use lockless peeking for skb
 array during busy polling
Date: Thu, 30 Mar 2017 10:16:15 +0800
Message-ID: <104c0c1f-e2fd-f5d0-0aae-c308d1f1373c@redhat.com>
References: <1490069087-4783-1-git-send-email-jasowang@redhat.com>
 <1490069087-4783-9-git-send-email-jasowang@redhat.com>
 <20170329150538-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170329150538-mutt-send-email-mst@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2017年03月29日 20:07, Michael S. Tsirkin wrote:
> On Tue, Mar 21, 2017 at 12:04:47PM +0800, Jason Wang wrote:
>> For the socket that exports its skb array, we can use lockless polling
>> to avoid touching spinlock during busy polling.
>>
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>> ---
>>   drivers/vhost/net.c | 7 +++++--
>>   1 file changed, 5 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
>> index 53f09f2..41153a3 100644
>> --- a/drivers/vhost/net.c
>> +++ b/drivers/vhost/net.c
>> @@ -551,10 +551,13 @@ static int peek_head_len(struct vhost_net_virtqueue *rvq, struct sock *sk)
>>   	return len;
>>   }
>>   
>> -static int sk_has_rx_data(struct sock *sk)
>> +static int sk_has_rx_data(struct vhost_net_virtqueue *rvq, struct sock *sk)
>>   {
>>   	struct socket *sock = sk->sk_socket;
>>   
>> +	if (rvq->rx_array)
>> +		return !__skb_array_empty(rvq->rx_array);
>> +
>>   	if (sock->ops->peek_len)
>>   		return sock->ops->peek_len(sock);
>>   
> I don't see which patch adds __skb_array_empty.

This is not something new, it was introduced by ad69f35d1dc0a 
("skb_array: array based FIFO for skbs").

Thanks

>
>> @@ -579,7 +582,7 @@ static int vhost_net_rx_peek_head_len(struct vhost_net *net,
>>   		endtime = busy_clock() + vq->busyloop_timeout;
>>   
>>   		while (vhost_can_busy_poll(&net->dev, endtime) &&
>> -		       !sk_has_rx_data(sk) &&
>> +		       !sk_has_rx_data(rvq, sk) &&
>>   		       vhost_vq_avail_empty(&net->dev, vq))
>>   			cpu_relax();
>>   
>> -- 
>> 2.7.4
