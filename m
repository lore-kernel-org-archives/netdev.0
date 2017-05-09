From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net v2] driver: vrf: Fix one possible use-after-free issue
Date: Tue, 9 May 2017 09:51:38 -0700
Message-ID: <43be9c0c-2cee-5d05-0908-53b81b4ebbba@gmail.com>
References: <1494325653-39885-1-git-send-email-gfree.wind@vip.163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: gfree.wind@vip.163.com, shm@cumulusnetworks.com,
        davem@davemloft.net, fw@strlen.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36149 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754517AbdEIQvl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 12:51:41 -0400
Received: by mail-pg0-f66.google.com with SMTP id 64so618301pgb.3
        for <netdev@vger.kernel.org>; Tue, 09 May 2017 09:51:41 -0700 (PDT)
In-Reply-To: <1494325653-39885-1-git-send-email-gfree.wind@vip.163.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/9/17 3:27 AM, gfree.wind@vip.163.com wrote:
> diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
> index ceda586..db88249 100644
> --- a/drivers/net/vrf.c
> +++ b/drivers/net/vrf.c
> @@ -989,6 +989,7 @@ static u32 vrf_fib_table(const struct net_device *dev)
>  
>  static int vrf_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
>  {
> +	kfree_skb(skb);
>  	return 0;
>  }
>  
> @@ -998,7 +999,7 @@ static struct sk_buff *vrf_rcv_nfhook(u8 pf, unsigned int hook,
>  {
>  	struct net *net = dev_net(dev);
>  
> -	if (NF_HOOK(pf, hook, net, NULL, skb, dev, NULL, vrf_rcv_finish) < 0)
> +	if (nf_hook(pf, hook, net, NULL, skb, dev, NULL, vrf_rcv_finish) != 1)
>  		skb = NULL;    /* kfree_skb(skb) handled by nf code */
>  
>  	return skb;
> 

I'm clearly misunderstanding something ...

With the current code:
- nf_hook returns 1, NF_HOOK invokes vrf_rcv_finish as the okfn, it
returns 0, skb passes on.

- nf_hook returns 0, vrf_rcv_finish has been called by the nf_hook tree,
vrf_rcv_finish returns 0, skb passes on

- nf_hook returns < 0,  vrf_rcv_finish is not called, skb is freed by
netfilter code, vrf_rcv_nfhook returns NULL

What am I missing?

With the above, if nf_hook returns 1, vrf_rcv_finish is not called.
