From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: BUG: use-after-free in netlink_dump
Date: Mon, 16 May 2016 10:22:07 -0700
Message-ID: <CAM_iQpUaoOqeA2TUwdqDNULcRAQyh3Eb=qaoiSt_-2KAbf6e_Q@mail.gmail.com>
References: <573894B3.8030009@gmail.com> <CAM_iQpV90MKyP2X32yatwktO9Yk-CSb32Oaa+VpdU8e_k8m-yQ@mail.gmail.com>
 <20160516092816.GA2331@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Baozeng Ding <sploving1@gmail.com>,
	David Miller <davem@davemloft.net>, chamaken@gmail.com,
	Daniel Borkmann <daniel@iogearbox.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	fuzzyer0@gmail.com, Pravin B Shelar <pshelar@nicira.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.161.193]:35849 "EHLO
	mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753854AbcEPRW1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 13:22:27 -0400
Received: by mail-yw0-f193.google.com with SMTP id u62so20374664ywe.3
        for <netdev@vger.kernel.org>; Mon, 16 May 2016 10:22:27 -0700 (PDT)
In-Reply-To: <20160516092816.GA2331@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 16, 2016 at 2:28 AM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Sun, May 15, 2016 at 12:06:46PM -0700, Cong Wang wrote:
>>
>> Similar to what Richard reported, I think the problem is cb->skb,
>> which is exposed to other thread since cb is per netlink socket
>> (cb = &nlk->cb). IOW, the cb->skb is freed by one thread at the
>> end of netlink_dump() meanwhile the other thread is still using
>> it via NETLINK_CB(cb->skb).portid.
>
> You're on the right track.  I think what's happening is that the
> second thread is starting a new dump and the first thread ends up
> freeing the skb of the new dump and leaking the old skb.
>
> ---8<---
> Subject: netlink: Fix dump skb leak/double free
>
> When we free cb->skb after a dump, we do it after releasing the
> lock.  This means that a new dump could have started in the time
> being and we'll end up freeing their skb instead of ours.
>
> This patch saves the skb and module before we unlock so we free
> the right memory.

Yeah, this fix makes more sense than mine.

>
> Fixes: 16b304f3404f ("netlink: Eliminate kmalloc in netlink dump operation.")
> Reported-by: Baozeng Ding <sploving1@gmail.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: Cong Wang <xiyou.wangcong@gmail.com>

Thanks.
