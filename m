From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] sit: fix use after free of fb_tunnel_dev
Date: Thu, 14 Nov 2013 06:47:19 -0800
Message-ID: <1384440439.28716.0.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1384396058-26850-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, edumazet@google.com,
	nicolas.dichtel@6wind.com, netdev@vger.kernel.org
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:45345 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753555Ab3KNOrV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 09:47:21 -0500
Received: by mail-pa0-f53.google.com with SMTP id kq14so2167904pab.26
        for <netdev@vger.kernel.org>; Thu, 14 Nov 2013 06:47:20 -0800 (PST)
In-Reply-To: <1384396058-26850-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-11-13 at 21:27 -0500, Willem de Bruijn wrote:
> Bug: The fallback device is created in sit_init_net and assumed to be
> freed in sit_exit_net. First, it is dereferenced in that function, in
> sit_destroy_tunnels:
> 
>         struct net *net = dev_net(sitn->fb_tunnel_dev);
> 
> Prior to this, rtnl_unlink_register has removed all devices that match
> rtnl_link_ops == sit_link_ops.
> 
> Commit 205983c43700 added the line
> 
> +       sitn->fb_tunnel_dev->rtnl_link_ops = &sit_link_ops;
> 
> which cases the fallback device to match here and be freed before it
> is last dereferenced.
> 
> Fix: This commit adds an explicit .delllink callback to sit_link_ops
> that skips deallocation at rtnl_unlink_register for the fallback
> device. This mechanism is comparable to the one in ip_tunnel.
> 
> It also modifies sit_destroy_tunnels and its only caller sit_exit_net
> to avoid the offending dereference in the first place. That double
> lookup is more complicated than required.
> 
> Test: The bug is only triggered when CONFIG_NET_NS is enabled. It
> causes a GPF only when CONFIG_DEBUG_SLAB is enabled. Verified that
> this bug exists at the mentioned commit, at davem-net HEAD and at
> 3.11.y HEAD. Verified that it went away after applying this patch.
> 
> Fixes: 205983c43700 ("sit: allow to use rtnl ops on fb tunnel")
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> 
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
