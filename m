From: Richard Weinberger <richard.weinberger@gmail.com>
Subject: Re: net: GPF in __netlink_ns_capable
Date: Sat, 16 Jan 2016 01:08:33 +0100
Message-ID: <CAFLxGvzo6NRNsHsJwys6c+oSMUpQxdfDEkWG-qaSqqP=V3Sjdw@mail.gmail.com>
References: <CACT4Y+bS-hDuTWtXTR-n8i+tqkFcCYUxnj0QK3JsyWn25FzVRg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Thomas Graf <tgraf@suug.ch>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Ken-ichirou MATSUZAWA <chamaken@gmail.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Florian Westphal <fw@strlen.de>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Eric Dumazet <edumazet@google.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:34684 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757196AbcAPAIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2016 19:08:34 -0500
In-Reply-To: <CACT4Y+bS-hDuTWtXTR-n8i+tqkFcCYUxnj0QK3JsyWn25FzVRg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 15, 2016 at 11:31 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> Call Trace:
>  [<     inline     >] netlink_ns_capable net/netlink/af_netlink.c:1417
>  [<ffffffff8529c0a5>] netlink_capable+0x25/0x30 net/netlink/af_netlink.c:1432

Hmm, we're crashing because NETLINK_CB(skb).sk is NULL.
netlink_dump() creates a new skb without a netlink control block,
but infiniband's dump functions use netlink_capable() which needs a valid
NETLINK_CB(skb).sk.

What about something like that?

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 81dc1bb..bb40ec5 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -919,6 +919,7 @@ static void netlink_skb_set_owner_r(struct sk_buff
*skb, struct sock *sk)
 {
        WARN_ON(skb->sk != NULL);
        skb->sk = sk;
+       NETLINK_CB(skb).sk = sk;
        skb->destructor = netlink_skb_destructor;
        atomic_add(skb->truesize, &sk->sk_rmem_alloc);
        sk_mem_charge(sk, skb->truesize);
-- 
Thanks,
//richard
