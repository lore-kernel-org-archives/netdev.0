From: Jason Wang <jasowang@redhat.com>
Subject: Re: [REGRESSION] 362899b ("macvtap: switch to use skb array") causes
 oops during teardown
Date: Thu, 11 Aug 2016 16:58:44 +0800
Message-ID: <55867d3a-7668-7a77-ea51-3de76b1b6bda@redhat.com>
References: <20160810184032.51f5429e.cornelia.huck@de.ibm.com>
 <c78f4930-dae0-8cde-be6b-8975a1081d6f@redhat.com>
 <20160811101320.20f03b17.cornelia.huck@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Christian Borntraeger <borntraeger@de.ibm.com>
To: Cornelia Huck <cornelia.huck@de.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160811101320.20f03b17.cornelia.huck@de.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016年08月11日 16:13, Cornelia Huck wrote:
> On Thu, 11 Aug 2016 15:49:12 +0800
> Jason Wang <jasowang@redhat.com> wrote:
>
>> This looks like a use-after-free. Could you pls try the following patch
>> to see it if fixes your issue?
>>
>> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
>> index a38c0da..070e329 100644
>> --- a/drivers/net/macvtap.c
>> +++ b/drivers/net/macvtap.c
>> @@ -275,7 +275,6 @@ static void macvtap_put_queue(struct macvtap_queue *q)
>>           rtnl_unlock();
>>
>>           synchronize_rcu();
>> -       skb_array_cleanup(&q->skb_array);
>>           sock_put(&q->sk);
>>    }
>>
>> @@ -533,10 +532,8 @@ static void macvtap_sock_write_space(struct sock *sk)
>>    static void macvtap_sock_destruct(struct sock *sk)
>>    {
>>           struct macvtap_queue *q = container_of(sk, struct
>> macvtap_queue, sk);
>> -       struct sk_buff *skb;
>>
>> -       while ((skb = skb_array_consume(&q->skb_array)) != NULL)
>> -               kfree_skb(skb);
>> +       skb_array_cleanup(&q->skb_array);
>>    }
>>
>>    static int macvtap_open(struct inode *inode, struct file *file)
> Yes, that change fixes things for me.
>
> Tested-by: Cornelia Huck <cornelia.huck@de.ibm.com>
>
> Thanks for the quick reply!
>

Thanks for the testing.

Will send a formal patch shortly.
