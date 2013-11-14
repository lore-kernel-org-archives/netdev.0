From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net] sit: fix use after free of fb_tunnel_dev
Date: Thu, 14 Nov 2013 11:31:49 +0100
Message-ID: <5284A695.2090501@6wind.com>
References: <1384396058-26850-1-git-send-email-willemb@google.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Willem de Bruijn <willemb@google.com>, davem@davemloft.net,
	edumazet@google.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:62725 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752505Ab3KNKb5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 05:31:57 -0500
Received: by mail-wi0-f180.google.com with SMTP id ey16so487264wid.7
        for <netdev@vger.kernel.org>; Thu, 14 Nov 2013 02:31:56 -0800 (PST)
In-Reply-To: <1384396058-26850-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 14/11/2013 03:27, Willem de Bruijn a =C3=A9crit :
> Bug: The fallback device is created in sit_init_net and assumed to be
> freed in sit_exit_net. First, it is dereferenced in that function, in
> sit_destroy_tunnels:
>
>          struct net *net =3D dev_net(sitn->fb_tunnel_dev);
>
> Prior to this, rtnl_unlink_register has removed all devices that matc=
h
> rtnl_link_ops =3D=3D sit_link_ops.
>
> Commit 205983c43700 added the line
>
> +       sitn->fb_tunnel_dev->rtnl_link_ops =3D &sit_link_ops;
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
With your patch, it's no more possible to remove manually the fallback =
device:
'ip link del sit0', but it's better so ;-)

Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
