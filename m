From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC ] net: sched: tbf: fix the calculation of max_size
Date: Mon, 09 Dec 2013 07:12:06 -0800
Message-ID: <1386601926.30495.323.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1386313205-87660-1-git-send-email-yangyingliang@huawei.com>
	 <1386313205-87660-2-git-send-email-yangyingliang@huawei.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B7468@saturn3.aculab.com>
	 <52A5384A.8050106@huawei.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B7471@saturn3.aculab.com>
	 <52A5B5D9.7000204@huawei.com> <52A5C12D.8080008@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	David Laight <David.Laight@ACULAB.COM>, brouer@redhat.com,
	jpirko@redhat.com, jbrouer@redhat.com
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:51087 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753731Ab3LIPML (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 10:12:11 -0500
Received: by mail-pb0-f48.google.com with SMTP id md12so5624211pbc.7
        for <netdev@vger.kernel.org>; Mon, 09 Dec 2013 07:12:10 -0800 (PST)
In-Reply-To: <52A5C12D.8080008@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-12-09 at 21:10 +0800, Yang Yingliang wrote:
> From: Yang Yingliang <yangyingliang@huawei.com>
> 
> Current max_size is caluated from rate table. Now, the rate table
> has been replaced and it's wrong to caculate max_size based on this
> rate table. It can lead wrong calculation of max_size.
> 
> The burst in kernel may be lower than user asked, because burst may gets
> some loss when transform it to buffer(E.g. "burst 40kb rate 30mbit/s")
> and it seems we cannot avoid this loss. Burst's value(max_size) based on
> rate table may be equal user asked. If a packet's length is max_size, this
> packet will be stalled in tbf_dequeue() because its length is above the
> burst in kernel so that it cannot get enough tokens. The max_size guards
> against enqueuing packet sizes above q->buffer "time" in tbf_enqueue().
> 
> To make consistent with the calculation of tokens, this patch add a helper
> psched_ns_t2l() to calculate burst(max_size) directly to fix this problem.
> 
> After this fix, we can support to using 64bit rates to calculate burst as well.
> 
> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
> ---
>  net/sched/sch_tbf.c | 203 +++++++++++++++++++++++++++++++++++++++-------------
>  1 file changed, 155 insertions(+), 48 deletions(-)


There is no way I am going to study this patch.

There is no way 32bit * 32bit multiply can overflow 64bit.

If the user gave a stupid input, like a buffer bigger than 4 sec, just
say no. Nobody ever did such stupid things in the past, and nobody will
do in the future because it is so wrong and useless.

q->mtu = max_t(u64, ~0U, PSCHED_TICKS2NS(qopt->mtu));

q->buffer = max_t(u64, ~0U, PSCHED_TICKS2NS(qopt->buffer));

Could we keep this code understandable, please ?
