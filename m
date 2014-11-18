From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH] [net]ip_tunnel: the lack of vti_link_ops' dellink() cause
 kernel panic
Date: Tue, 18 Nov 2014 15:25:38 -0800
Message-ID: <CAHA+R7NjO+bDhN5QX95d8V0VqvbacxCzoHWT5NpDaDn3YCtCeg@mail.gmail.com>
References: <1416307059-32732-1-git-send-email-lucien.xin@gmail.com>
	<546B8093.4080507@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Xin Long <lucien.xin@gmail.com>,
	network dev <netdev@vger.kernel.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f175.google.com ([209.85.216.175]:61668 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932401AbaKRXZj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2014 18:25:39 -0500
Received: by mail-qc0-f175.google.com with SMTP id b13so21331740qcw.34
        for <netdev@vger.kernel.org>; Tue, 18 Nov 2014 15:25:38 -0800 (PST)
In-Reply-To: <546B8093.4080507@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 18, 2014 at 9:23 AM, Nicolas Dichtel
<nicolas.dichtel@6wind.com> wrote:
>
> A quick look at the ipv6 side seems to show that there is the same problem.
> Can
> you provide the IPv6 patch too?
>

IPv6 doesn't use ip_tunnel library, so needs to provide its own implementation:

diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index ec84d03..3ae094b 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -911,6 +911,16 @@ static int vti6_newlink(struct net *src_net,
struct net_device *dev,
        return vti6_tnl_create2(dev);
 }

+static void vti6_dellink(struct net_device *dev, struct list_head *head)
+{
+       struct net *net = dev_net(dev);
+       struct vti6_net *ip6n = net_generic(net, vti6_net_id);
+
+       if (dev != ip6n->fb_tnl_dev)
+               unregister_netdevice_queue(dev, head);
+}
+
+
 static int vti6_changelink(struct net_device *dev, struct nlattr *tb[],
                           struct nlattr *data[])
 {
@@ -986,6 +996,7 @@ static struct rtnl_link_ops vti6_link_ops __read_mostly = {
        .setup          = vti6_dev_setup,
        .validate       = vti6_validate,
        .newlink        = vti6_newlink,
+       .dellink        = vti6_dellink,
        .changelink     = vti6_changelink,
        .get_size       = vti6_get_size,
        .fill_info      = vti6_fill_info,
