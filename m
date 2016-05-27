From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH,RFC] macvlan: Handle broadcasts inline if we have only a
 few macvlans.
Date: Fri, 27 May 2016 10:56:44 -0700
Message-ID: <CAM_iQpWwX_tJVk-96v2Xjwrm+Nijk1AkRhe+aoNU6o_3bQh_BA@mail.gmail.com>
References: <20160526234433.GU8402@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Patrick McHardy <kaber@trash.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.161.193]:32931 "EHLO
	mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932516AbcE0R5F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2016 13:57:05 -0400
Received: by mail-yw0-f193.google.com with SMTP id y6so7238188ywe.0
        for <netdev@vger.kernel.org>; Fri, 27 May 2016 10:57:04 -0700 (PDT)
In-Reply-To: <20160526234433.GU8402@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 26, 2016 at 4:44 PM, Lennert Buytenhek
<buytenh@wantstofly.org> wrote:
> Commit 412ca1550cbecb2c ("macvlan: Move broadcasts into a work queue")
> moved processing of all macvlan multicasts into a work queue.  This
> causes a noticable performance regression when there is heavy multicast
> traffic on the underlying interface for multicast groups that the
> macvlan subinterfaces are not members of, in which case we end up
> cloning all those packets and then freeing them again from a work queue
> without really doing any useful work with them in between.

But we only queue up to 1000 packets in our backlog.

How about adding a quick check before cloning it?

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index cb01023..1c73d0f 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -315,6 +315,9 @@ static void macvlan_broadcast_enqueue(struct
macvlan_port *port,
        struct sk_buff *nskb;
        int err = -ENOMEM;

+       if (skb_queue_len(&port->bc_queue) >= MACVLAN_BC_QUEUE_LEN)
+               return;
+
        nskb = skb_clone(skb, GFP_ATOMIC);
        if (!nskb)
                goto err;
