From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [Patch net-next] net_sched: move the empty tp check from ->destroy()
 to ->delete()
Date: Thu, 24 Nov 2016 11:14:26 +0100
Message-ID: <5836BD82.6080407@iogearbox.net>
References: <1479952708-26763-1-git-send-email-xiyou.wangcong@gmail.com> <5836A4D4.2010500@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jiri@mellanox.com, John Fastabend <john.fastabend@gmail.com>
To: Roi Dayan <roid@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56558 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751990AbcKXKOa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 05:14:30 -0500
In-Reply-To: <5836A4D4.2010500@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/24/2016 09:29 AM, Roi Dayan wrote:
> Hi,
>
> I'm testing this patch with KASAN enabled and got into a new kernel crash I didn't hit before.
>
> [ 1860.725065] ==================================================================
> [ 1860.733893] BUG: KASAN: use-after-free in __netif_receive_skb_core+0x1ebe/0x29a0 at addr ffff880a68b04028
> [ 1860.745415] Read of size 8 by task CPU 0/KVM/5334
> [ 1860.751368] CPU: 8 PID: 5334 Comm: CPU 0/KVM Tainted: G O 4.9.0-rc3+ #18
> [ 1860.760547] Hardware name: HP ProLiant DL380p Gen8, BIOS P70 07/01/2015
> [ 1860.768036] Call Trace:
> [ 1860.771307]  [<ffffffffa9b6dc42>] dump_stack+0x63/0x81
> [ 1860.777167]  [<ffffffffa95fb751>] kasan_object_err+0x21/0x70
> [ 1860.783826]  [<ffffffffa95fb9dd>] kasan_report_error+0x1ed/0x4e0
> [ 1860.790640]  [<ffffffffa9b9b841>] ? csum_partial+0x11/0x20
> [ 1860.796871]  [<ffffffffaa44a6b9>] ? csum_partial_ext+0x9/0x10
> [ 1860.803571]  [<ffffffffaa453155>] ? __skb_checksum+0x115/0x8d0
> [ 1860.810370]  [<ffffffffa95fbe81>] __asan_report_load8_noabort+0x61/0x70
> [ 1860.818263]  [<ffffffffaa49c3fe>] ? __netif_receive_skb_core+0x1ebe/0x29a0
> [ 1860.826215]  [<ffffffffaa49c3fe>] __netif_receive_skb_core+0x1ebe/0x29a0
> [ 1860.833991]  [<ffffffffaa49a540>] ? netdev_info+0x100/0x100
> [ 1860.840529]  [<ffffffffaa671792>] ? udp4_gro_receive+0x802/0x1090
> [ 1860.847783]  [<ffffffffa9bb9a08>] ? find_next_bit+0x18/0x20
> [ 1860.854126]  [<ffffffffaa49cf04>] __netif_receive_skb+0x24/0x150
> [ 1860.861695]  [<ffffffffaa49d0d1>] netif_receive_skb_internal+0xa1/0x1d0
> [ 1860.869366]  [<ffffffffaa49d030>] ? __netif_receive_skb+0x150/0x150
> [ 1860.876464]  [<ffffffffaa49f7e9>] ? dev_gro_receive+0x969/0x1660
> [ 1860.883924]  [<ffffffffaa4a0e1f>] napi_gro_receive+0x1df/0x300
> [ 1860.890744]  [<ffffffffc02e885d>] mlx5e_handle_rx_cqe_rep+0x83d/0xd30 [mlx5_core]
>
> checking with gdb
>
> (gdb) l *(__netif_receive_skb_core+0x1ebe)
> 0xffffffff8249c3fe is in __netif_receive_skb_core (net/core/dev.c:3937).
> 3932                    *pt_prev = NULL;
> 3933            }
> 3934
> 3935            qdisc_skb_cb(skb)->pkt_len = skb->len;
> 3936            skb->tc_verd = SET_TC_AT(skb->tc_verd, AT_INGRESS);
> 3937            qdisc_bstats_cpu_update(cl->q, skb);
> 3938
> 3939            switch (tc_classify(skb, cl, &cl_res, false)) {
> 3940            case TC_ACT_OK:
> 3941            case TC_ACT_RECLASSIFY:

Can you elaborate some more on your test-case? Adding/dropping ingress qdisc with
some classifier on it in a loop while traffic goes through?

Thanks,
Daniel
