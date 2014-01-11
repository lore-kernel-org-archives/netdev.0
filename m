From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH v3 net-next] net: vxlan: when lower dev unregisters remove
 vxlan dev as well
Date: Fri, 10 Jan 2014 16:49:11 -0800
Message-ID: <CAHA+R7NB8sz1-W=QEmGxQkRyUmcMM6BzE7pZNU0W2_jzDfJjNw@mail.gmail.com>
References: <1389393317-26563-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:65489 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757186AbaAKAtN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 19:49:13 -0500
Received: by mail-lb0-f171.google.com with SMTP id w7so3881790lbi.16
        for <netdev@vger.kernel.org>; Fri, 10 Jan 2014 16:49:11 -0800 (PST)
In-Reply-To: <1389393317-26563-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 10, 2014 at 2:35 PM, Daniel Borkmann <dborkman@redhat.com> wrote:
> @@ -2673,13 +2712,14 @@ static __net_init int vxlan_init_net(struct net *net)
>  static __net_exit void vxlan_exit_net(struct net *net)
>  {
>         struct vxlan_net *vn = net_generic(net, vxlan_net_id);
> -       struct vxlan_dev *vxlan;
> -       LIST_HEAD(list);
> +       struct vxlan_dev *vxlan, *next;
> +       LIST_HEAD(list_kill);
>
>         rtnl_lock();
> -       list_for_each_entry(vxlan, &vn->vxlan_list, next)
> -               unregister_netdevice_queue(vxlan->dev, &list);
> -       unregister_netdevice_many(&list);
> +       list_for_each_entry_safe(vxlan, next, &vn->vxlan_list, next)
> +               vxlan_dellink(vxlan->dev, &list_kill);
> +       unregister_netdevice_many(&list_kill);
> +       list_del(&list_kill);

The last list_del() looks suspicous... Since list_kill is a local list head,
why do we need to delete the head at the end??

Also, I still fail to see why you change vxlan_exit_net() here,
it looks a different bug irrelevant to netdev notifier.
