From: Shlomo Pongartz <shlomop@mellanox.com>
Subject: Re: getting warn once around skb_try_coalesce
Date: Tue, 10 Jul 2012 15:35:29 +0300
Message-ID: <4FFC2191.1040001@mellanox.com>
References: <4FFBFBD2.6030004@mellanox.com>  <1341915510.3265.4734.camel@edumazet-glaptop>  <1341918848.3265.4853.camel@edumazet-glaptop> <1341919328.3265.4871.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Erez Shitrit <erezsh@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog110.obsmtp.com ([207.126.144.129]:56918 "HELO
	eu1sys200aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752440Ab2GJMhk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 08:37:40 -0400
In-Reply-To: <1341919328.3265.4871.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/10/2012 2:22 PM, Eric Dumazet wrote:
> On Tue, 2012-07-10 at 13:14 +0200, Eric Dumazet wrote:
>> On Tue, 2012-07-10 at 12:18 +0200, Eric Dumazet wrote:
>>> On Tue, 2012-07-10 at 12:54 +0300, Or Gerlitz wrote:
>>>> Hi Dave, Eric,
>>>>
>>>> Another trace that I see here with net-next is this one-time warning. I
>>>> get it always
>>>> on the passive side of TCP, something that seems related to GRO, it
>>>> happens only with
>>>> IPoIB, not with mlx4_en and igb (when igb get to work on net-next...)
>>>>
>>>> The latest commit in this area is bad43ca8325f493dcaa0896c2f036276af059c7e
>>>> "net: introduce skb_try_coalesce()" from Eric.
>>>>
>>>> Or.
>>>>
>>>> -----------[ cut here ]------------
>>>> WARNING: at net/core/skbuff.c:3413 skb_try_coalesce+0x1f8/0x31d()
>>> This warning catch skb truesize offenders, most probably its a driver
>>> issue.
>>>
>> By the way, this driver allocates not enough tailroom in skbs, so IP/TCP
>> stacks need to reallocate skb head to pull IP/TCP headers. Thats not
>> efficient.
>>
>> I suggest using following patch :
> And of course we also can fix the truesize bug.
> (Not sure it will fix the warning, but worth trying)
>
> Since this driver allocates a full page, it must use the PAGE_SIZE, not
> the used part in the fragment
>
> diff --git a/drivers/infiniband/ulp/ipoib/ipoib_ib.c b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
> index 5c1bc99..e611a924 100644
> --- a/drivers/infiniband/ulp/ipoib/ipoib_ib.c
> +++ b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
> @@ -123,7 +123,7 @@ static void ipoib_ud_skb_put_frags(struct ipoib_dev_priv *priv,
>
>   		skb_frag_size_set(frag, size);
>   		skb->data_len += size;
> -		skb->truesize += size;
> +		skb->truesize += PAGE_SIZE;
>   	} else
>   		skb_put(skb, length);
>
> @@ -159,7 +159,7 @@ static struct sk_buff *ipoib_alloc_rx_skb(struct net_device *dev, int id)
>   	u64 *mapping;
>
>   	if (ipoib_ud_need_sg(priv->max_ib_mtu))
> -		buf_size = IPOIB_UD_HEAD_SIZE;
> +		buf_size = IPOIB_UD_HEAD_SIZE + 128; /* reserve some tailroom for IP/TCP headers */
>   	else
>   		buf_size = IPOIB_UD_BUF_SIZE(priv->max_ib_mtu);
>
>
>
>
> .
>
Hi,

I've applied the patch and there are no more warnings. Thanks.
Can you please elaborate on this issue which was there from day one and 
AFAIK never manifested itself.

Best regards,
S.P.
