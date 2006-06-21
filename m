From: Brice Goglin <brice@myri.com>
Subject: Re: + myri10ge-build-fix.patch added to -mm tree
Date: Wed, 21 Jun 2006 08:09:51 -0400
Message-ID: <4499370F.2020101@myri.com>
References: <200606210433.k5L4XgmP008626@shell0.pdx.osdl.net> <20060621044107.GB899@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, mm-commits@vger.kernel.org, davem@davemloft.net,
	jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:56481 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S1751515AbWFUMKk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2006 08:10:40 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060621044107.GB899@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Tue, Jun 20, 2006 at 09:33:42PM -0700, akpm@osdl.org wrote:
>> diff -puN drivers/net/myri10ge/myri10ge.c~myri10ge-build-fix
>> drivers/net/myri10ge/myri10ge.c
>> --- a/drivers/net/myri10ge/myri10ge.c~myri10ge-build-fix
>> +++ a/drivers/net/myri10ge/myri10ge.c
>> @@ -2120,7 +2120,7 @@ abort_linearize:
>> goto drop;
>> }
>>
>> - if (skb_linearize(skb, GFP_ATOMIC))
>> + if (skb_linearize(skb))
>> goto drop;
>
> Actually I think this driver (in conjunction with TSO) is buggy.
> It has a maximum segment count of 12. However TSO can send 13 pages
> or more of data on i386. If this happens it looks like this driver
> will go into an infinite loop forever trying to linearize the skb.
>
> Cheers,

Actually, we use 64 segments when TSO in enabled
(MYRI10GE_MAX_SEND_DESC_TSO):

#define MYRI10GE_MAX_SEND_DESC_TSO ((65536 / 2048) * 2)

<.....>

    max_segments = MXGEFW_MAX_SEND_DESC;

#ifdef NETIF_F_TSO
if (skb->len > (dev->mtu + ETH_HLEN)) {
    mss = skb_shinfo(skb)->tso_size;
    if (mss != 0)
        max_segments = MYRI10GE_MAX_SEND_DESC_TSO;
}
#endif /*NETIF_F_TSO */


And we never try to linearize a TSO frame:

if (skb_shinfo(skb)->tso_size) {
    printk(KERN_ERR "myri10ge: %s: TSO but wanted to linearize?!?!?\n",
        mgp->dev->name);
    goto drop;
}

Brice

