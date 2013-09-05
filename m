From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next 2/2] tuntap: orphan frags before trying to set
 tx timestamp
Date: Thu, 05 Sep 2013 17:59:06 +0800
Message-ID: <522855EA.1030807@redhat.com>
References: <1378269226-5969-1-git-send-email-jasowang@redhat.com> <1378269226-5969-2-git-send-email-jasowang@redhat.com> <52273525.7090501@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com,
	Richard Cochran <richardcochran@gmail.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52273525.7090501@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/04/2013 09:27 PM, Sergei Shtylyov wrote:
> Hello.
>
> On 04-09-2013 8:33, Jason Wang wrote:
>
>> sock_tx_timestamp() will clear all zerocopy flags of skb which may
>> lead the
>> frags never to be orphaned. This will break guest to guest traffic
>> when zerocopy
>> is enabled. Fix this by orphaning the frags before trying to set tx
>> time stamp.
>
>> The issue were introduced by commit
>> eda297729171fe16bf34fe5b0419dfb69060f623
>> (tun: Support software transmit time stamping).
>
>> Cc: Richard Cochran <richardcochran@gmail.com>
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>> ---
>>   drivers/net/tun.c |    9 +++++----
>>   1 files changed, 5 insertions(+), 4 deletions(-)
>
>> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
>> index 2dddb1b..af9a096 100644
>> --- a/drivers/net/tun.c
>> +++ b/drivers/net/tun.c
>> @@ -749,15 +749,16 @@ static netdev_tx_t tun_net_xmit(struct sk_buff
>> *skb, struct net_device *dev)
>>                 >= dev->tx_queue_len / tun->numqueues)
>>           goto drop;
>>
>> +    /* Orphan the skb - required as we might hang on to it
>> +     * for indefinite time. */
>
>    You could fix the comment style to the networking code default,
> while at: it:
>
> /* bla
>  * bla
>  */
>
>> +    if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
>> +        goto drop;
>> +
>>       if (skb->sk) {
>>           sock_tx_timestamp(skb->sk, &skb_shinfo(skb)->tx_flags);
>>           sw_tx_timestamp(skb);
>>       }
>>
>> -    /* Orphan the skb - required as we might hang on to it
>> -     * for indefinite time. */
>> -    if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
>> -        goto drop;
>
> WBR, Sergei
>
>
>

Sure will post V2.
