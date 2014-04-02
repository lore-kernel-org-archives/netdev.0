From: lucien xin <lucien.xin@gmail.com>
Subject: Re: [PATCH] vxlan: using AF_PACKET socket to send multicast packet
 cause WARNING
Date: Wed, 2 Apr 2014 13:31:59 +0800
Message-ID: <CADvbK_dK_fBB3bQSWKkAk6adtgrHm553Hr3JGHsw67qeS0cQOw@mail.gmail.com>
References: <1396343330-23648-1-git-send-email-lucien.xin@gmail.com>
	<20140401.161047.854771903443514987.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: network dev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:55424 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752492AbaDBFcA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 01:32:00 -0400
Received: by mail-wi0-f179.google.com with SMTP id z2so4584393wiv.0
        for <netdev@vger.kernel.org>; Tue, 01 Apr 2014 22:31:59 -0700 (PDT)
In-Reply-To: <20140401.161047.854771903443514987.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 2, 2014 at 4:10 AM, David Miller <davem@davemloft.net> wrote:
> This is not the correct fix.
>
> If vxlan is going to reinject dev_hard_start_xmit() bound packets into
> the ipv4 stack, it must make sure that they are well formed.
>
> The SKB traversing the ipv4 stack must either be bound to an ipv4/ipv6
> socket or be orphaned.

yeah,  it's right. then I want to bound skb to vxlan's sock in
vxlan_xmit_skb(), like this:

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 1236812..8fd7e93 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1755,6 +1755,8 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
        if (err)
                return err;

+       skb_set_owner_w(skb, vs->sock->sk);
+
        return iptunnel_xmit(rt, skb, src, dst, IPPROTO_UDP, tos, ttl, df,
                             false);
 }

which can not only solve the issue, but also make the logic more correct.
David, how do you think?
