From: Jason Wang <jasowang@redhat.com>
Subject: Re: [BUG] acess_ok() missing from zerocopy_sg_from_iovec()
Date: Tue, 04 Jun 2013 11:25:40 +0800
Message-ID: <51AD5E34.5040701@redhat.com>
References: <1370306052.24311.193.camel@edumazet-glaptop> <1370307969.24311.196.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16195 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754186Ab3FDD0E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jun 2013 23:26:04 -0400
In-Reply-To: <1370307969.24311.196.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/04/2013 09:06 AM, Eric Dumazet wrote:
> On Mon, 2013-06-03 at 17:34 -0700, Eric Dumazet wrote:
>> It looks like access_ok(VERIFY_READ, base, len) checks are missing in
>> drivers/net/tun.c & drivers/net/macvtap.c before the
>> get_user_pages_fast() calls.
>>
>> Or am I missing something ?
>>
> Patch would be :
>
> [PATCH] tun/macvtap: use access_ok(VERIFY_READ)
>
> Zero copy is good if only we make all needed security checks.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index 59e9605..d793b7d 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -522,6 +522,8 @@ static int zerocopy_sg_from_iovec(struct sk_buff *skb, const struct iovec *from,
>  		size = ((base & ~PAGE_MASK) + len + ~PAGE_MASK) >> PAGE_SHIFT;
>  		if (i + size > MAX_SKB_FRAGS)
>  			return -EMSGSIZE;
> +		if (!access_ok(VERIFY_READ, base, len))
> +			return -EFAULT;
>  		num_pages = get_user_pages_fast(base, size, 0, &page[i]);
>  		if (num_pages != size) {
>  			for (i = 0; i < num_pages; i++)
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 89776c5..7a7b3b1 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -1008,6 +1008,8 @@ static int zerocopy_sg_from_iovec(struct sk_buff *skb, const struct iovec *from,
>  		size = ((base & ~PAGE_MASK) + len + ~PAGE_MASK) >> PAGE_SHIFT;
>  		if (i + size > MAX_SKB_FRAGS)
>  			return -EMSGSIZE;
> +		if (!access_ok(VERIFY_READ, base, len))
> +			return -EFAULT;
>  		num_pages = get_user_pages_fast(base, size, 0, &page[i]);
>  		if (num_pages != size) {
>  			for (i = 0; i < num_pages; i++)
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Looks like vhost is the only user of zerocopy now, and it does this
check when virtqueue is initialized in vq_memory_access_ok().
