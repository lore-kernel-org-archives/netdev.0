From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: BUG: use-after-free in netlink_dump
Date: Mon, 16 May 2016 17:28:16 +0800
Message-ID: <20160516092816.GA2331@gondor.apana.org.au>
References: <573894B3.8030009@gmail.com>
 <CAM_iQpV90MKyP2X32yatwktO9Yk-CSb32Oaa+VpdU8e_k8m-yQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Baozeng Ding <sploving1@gmail.com>,
	David Miller <davem@davemloft.net>, chamaken@gmail.com,
	Daniel Borkmann <daniel@iogearbox.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	fuzzyer0@gmail.com, Pravin B Shelar <pshelar@nicira.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:53102 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753551AbcEPJ2e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 05:28:34 -0400
Content-Disposition: inline
In-Reply-To: <CAM_iQpV90MKyP2X32yatwktO9Yk-CSb32Oaa+VpdU8e_k8m-yQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 15, 2016 at 12:06:46PM -0700, Cong Wang wrote:
>
> Similar to what Richard reported, I think the problem is cb->skb,
> which is exposed to other thread since cb is per netlink socket
> (cb = &nlk->cb). IOW, the cb->skb is freed by one thread at the
> end of netlink_dump() meanwhile the other thread is still using
> it via NETLINK_CB(cb->skb).portid.

You're on the right track.  I think what's happening is that the
second thread is starting a new dump and the first thread ends up
freeing the skb of the new dump and leaking the old skb.

---8<---
Subject: netlink: Fix dump skb leak/double free

When we free cb->skb after a dump, we do it after releasing the
lock.  This means that a new dump could have started in the time
being and we'll end up freeing their skb instead of ours.

This patch saves the skb and module before we unlock so we free
the right memory.

Fixes: 16b304f3404f ("netlink: Eliminate kmalloc in netlink dump operation.")
Reported-by: Baozeng Ding <sploving1@gmail.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 215fc08..f8b50c1 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2059,6 +2059,7 @@ static int netlink_dump(struct sock *sk)
 	struct netlink_callback *cb;
 	struct sk_buff *skb = NULL;
 	struct nlmsghdr *nlh;
+	struct module *module;
 	int len, err = -ENOBUFS;
 	int alloc_min_size;
 	int alloc_size;
@@ -2134,9 +2135,11 @@ static int netlink_dump(struct sock *sk)
 		cb->done(cb);
 
 	nlk->cb_running = false;
+	module = cb->module;
+	skb = cb->skb;
 	mutex_unlock(nlk->cb_mutex);
-	module_put(cb->module);
-	consume_skb(cb->skb);
+	module_put(module);
+	consume_skb(skb);
 	return 0;
 
 errout_skb:
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
