From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net] net: nsid cannot be allocated for a dead netns
Date: Wed, 16 Nov 2016 15:00:26 +0300
Message-ID: <0cdeb416-5d40-df05-70ac-6e527ce38c4f@cogentembedded.com>
References: <CANaxB-yaizaZbUi-OaJLzy+k2fNOkTCb8L8uwBCw4L5axOCzdg@mail.gmail.com>
 <1479285671-1298-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>, avagin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f182.google.com ([209.85.216.182]:33412 "EHLO
        mail-qt0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750961AbcKPMA2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 07:00:28 -0500
Received: by mail-qt0-f182.google.com with SMTP id p16so97385283qta.0
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 04:00:27 -0800 (PST)
In-Reply-To: <1479285671-1298-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 11/16/2016 11:41 AM, Nicolas Dichtel wrote:

> Andrei reports the following kmemleak error:
> unreferenced object 0xffff91badb543950 (size 2096):
>   comm "kworker/u4:0", pid 6, jiffies 4295152553 (age 28.418s)
>   hex dump (first 32 bytes):
>     00 00 00 00 00 00 00 00 00 cb 5f df ba 91 ff ff  .........._.....
>     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
>   backtrace:
>     [<ffffffffb1865bea>] kmemleak_alloc+0x4a/0xa0
>     [<ffffffffb1243b38>] kmem_cache_alloc+0x128/0x280
>     [<ffffffffb142f5ab>] idr_layer_alloc+0x2b/0x90
>     [<ffffffffb142f9cd>] idr_get_empty_slot+0x34d/0x370
>     [<ffffffffb142fa4e>] idr_alloc+0x5e/0x110
>     [<ffffffffb170ac3d>] __peernet2id_alloc+0x6d/0x90
>     [<ffffffffb170bda5>] peernet2id_alloc+0x55/0xb0
>     [<ffffffffb1731216>] rtnl_fill_ifinfo+0xaa6/0x10a0
>     [<ffffffffb1733073>] rtmsg_ifinfo_build_skb+0x73/0xd0
>     [<ffffffffb17125d5>] rollback_registered_many+0x295/0x390
>     [<ffffffffb1712765>] unregister_netdevice_many+0x25/0x80
>     [<ffffffffb17138a5>] default_device_exit_batch+0x145/0x170
>     [<ffffffffb170ae52>] ops_exit_list.isra.4+0x52/0x60
>     [<ffffffffb170c17f>] cleanup_net+0x1bf/0x2a0
>     [<ffffffffb10b616f>] process_one_work+0x1ff/0x660
>     [<ffffffffb10b661e>] worker_thread+0x4e/0x480
>
> There is no reason to try to allocate an nsid for a netns which is dying.
>
> Reported-by: Andrei Vagin <avagin@gmail.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>
> Thank you for the report. Can you test this patch?
>
> Regards,
> Nicolas
>
>  net/core/net_namespace.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
> index f61c0e02a413..f1340ed0d8df 100644
> --- a/net/core/net_namespace.c
> +++ b/net/core/net_namespace.c
> @@ -159,6 +159,9 @@ static int alloc_netid(struct net *net, struct net *peer, int reqid)
>  		max = reqid + 1;
>  	}
>
> +	if (!atomic_read(&net->count) || !&atomic_read(peer->count))

    Looks like & is misplaced in the second case?

MBR, Sergei
