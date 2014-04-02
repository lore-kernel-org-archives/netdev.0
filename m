From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] vxlan: using AF_PACKET socket to send multicast packet
 cause WARNING
Date: Wed, 2 Apr 2014 07:51:06 -0700
Message-ID: <20140402075106.3eec7791@nehalam.linuxnetplumber.net>
References: <1396343330-23648-1-git-send-email-lucien.xin@gmail.com>
	<20140401.161047.854771903443514987.davem@davemloft.net>
	<CADvbK_dK_fBB3bQSWKkAk6adtgrHm553Hr3JGHsw67qeS0cQOw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	network dev <netdev@vger.kernel.org>
To: lucien xin <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:51132 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932195AbaDBOvL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 10:51:11 -0400
Received: by mail-pb0-f48.google.com with SMTP id md12so296254pbc.35
        for <netdev@vger.kernel.org>; Wed, 02 Apr 2014 07:51:11 -0700 (PDT)
In-Reply-To: <CADvbK_dK_fBB3bQSWKkAk6adtgrHm553Hr3JGHsw67qeS0cQOw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2 Apr 2014 13:31:59 +0800
lucien xin <lucien.xin@gmail.com> wrote:

> On Wed, Apr 2, 2014 at 4:10 AM, David Miller <davem@davemloft.net> wrote:
> > This is not the correct fix.
> >
> > If vxlan is going to reinject dev_hard_start_xmit() bound packets into
> > the ipv4 stack, it must make sure that they are well formed.
> >
> > The SKB traversing the ipv4 stack must either be bound to an ipv4/ipv6
> > socket or be orphaned.
> 
> yeah,  it's right. then I want to bound skb to vxlan's sock in
> vxlan_xmit_skb(), like this:
> 
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 1236812..8fd7e93 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -1755,6 +1755,8 @@ int vxlan_xmit_skb(struct vxlan_sock *vs,
>         if (err)
>                 return err;
> 
> +       skb_set_owner_w(skb, vs->sock->sk);
> +
>         return iptunnel_xmit(rt, skb, src, dst, IPPROTO_UDP, tos, ttl, df,
>                              false);
>  }
> 
> which can not only solve the issue, but also make the logic more correct.
> David, how do you think?

That breaks local socket accounting for tunneled packets.
The idea is that a TCP socket sending over vxlan will keep it's
memory accounting all the way until the device sends it.
