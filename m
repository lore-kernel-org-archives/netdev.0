From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: BUG: use-after-free in netlink_dump
Date: Sun, 15 May 2016 12:06:46 -0700
Message-ID: <CAM_iQpV90MKyP2X32yatwktO9Yk-CSb32Oaa+VpdU8e_k8m-yQ@mail.gmail.com>
References: <573894B3.8030009@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>, chamaken@gmail.com,
	Daniel Borkmann <daniel@iogearbox.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	fuzzyer0@gmail.com
To: Baozeng Ding <sploving1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.161.193]:33555 "EHLO
	mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751160AbcEOTHH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 May 2016 15:07:07 -0400
Received: by mail-yw0-f193.google.com with SMTP id y6so16921848ywe.0
        for <netdev@vger.kernel.org>; Sun, 15 May 2016 12:07:07 -0700 (PDT)
In-Reply-To: <573894B3.8030009@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 15, 2016 at 8:24 AM, Baozeng Ding <sploving1@gmail.com> wrote:
> Hi all,
> I've got the following report (use-after-free in netlink_dump) while running
> syzkaller.
> Unfortunately no reproducer.The kernel version is 4.6.0-rc2+.
...
> Call Trace:
>  [<     inline     >] __dump_stack lib/dump_stack.c:15
>  [<ffffffff829557d1>] dump_stack+0xb3/0x112 lib/dump_stack.c:51
>  [<ffffffff8170fabd>] print_trailer+0x10d/0x190 mm/slub.c:667
>  [<ffffffff817165af>] object_err+0x2f/0x40 mm/slub.c:674
>  [<     inline     >] print_address_description mm/kasan/report.c:179
>  [<ffffffff81718dd8>] kasan_report_error+0x218/0x530 mm/kasan/report.c:275
>  [<     inline     >] kasan_report mm/kasan/report.c:297
>  [<ffffffff817191ae>] __asan_report_load4_noabort+0x3e/0x40
> mm/kasan/report.c:317
>  [<     inline     >] ? nlmsg_put_answer include/net/netlink.h:471
>  [<ffffffff84cdc34b>] ? netlink_dump+0x4eb/0xa40
> net/netlink/af_netlink.c:2120
>  [<     inline     >] nlmsg_put_answer include/net/netlink.h:471
>  [<ffffffff84cdc34b>] netlink_dump+0x4eb/0xa40 net/netlink/af_netlink.c:2120
>  [<ffffffff84cdd19b>] netlink_recvmsg+0x8fb/0xe00
> net/netlink/af_netlink.c:1869

Similar to what Richard reported, I think the problem is cb->skb,
which is exposed to other thread since cb is per netlink socket
(cb = &nlk->cb). IOW, the cb->skb is freed by one thread at the
end of netlink_dump() meanwhile the other thread is still using
it via NETLINK_CB(cb->skb).portid.

I am guessing we miss some skb_get():

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index aeefe12..142bb39 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2184,7 +2184,7 @@ int __netlink_dump_start(struct sock *ssk,
struct sk_buff *skb,
        cb->data = control->data;
        cb->module = control->module;
        cb->min_dump_alloc = control->min_dump_alloc;
-       cb->skb = skb;
+       cb->skb = skb_get(skb);

        nlk->cb_running = true;

meanwhile the cb->skb is still "freed" by the consume_skb(cb->skb).
