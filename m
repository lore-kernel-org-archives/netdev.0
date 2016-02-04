From: Salam Noureddine <noureddine@arista.com>
Subject: Re: [PATCH net-next 2/4] net: dev: add batching to net_device notifiers
Date: Wed, 3 Feb 2016 17:26:04 -0800
Message-ID: <CAO7SqHDZfxMHv4JE5x7QbuJaBAPiH1MUed5RkHwvMWDRtkLQaw@mail.gmail.com>
References: <1454365952-10324-1-git-send-email-noureddine@arista.com>
	<1454365952-10324-3-git-send-email-noureddine@arista.com>
	<alpine.LFD.2.11.1602022219010.2006@ja.home.ssi.bg>
	<CAO7SqHBKrPvaEhLeEJsCrjYEiPcZ6MpyfwY43NwhGLWhW4VTNQ@mail.gmail.com>
	<alpine.LFD.2.11.1602030950280.1736@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Network Development <netdev@vger.kernel.org>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:36142 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933034AbcBDB0F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 20:26:05 -0500
Received: by mail-wm0-f54.google.com with SMTP id p63so190561976wmp.1
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 17:26:04 -0800 (PST)
In-Reply-To: <alpine.LFD.2.11.1602030950280.1736@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 3, 2016 at 12:08 AM, Julian Anastasov <ja@ssi.bg> wrote:


>         Aha, I see, it is after NETDEV_UNREGISTER but may be
> the above loop should be changed to two loops so that
> NETDEV_UNREGISTER_BATCH is called exactly after all
> NETDEV_UNREGISTER and before all dev_*_flush and
> ndo_uninit calls to avoid any risks. I mean:
>
>         synchronize_net();
>
>         First part of loop:
>
>         list_for_each_entry(dev, head, unreg_list) {
>                 /* Shutdown queueing discipline. */
>                 dev_shutdown(dev);
>
>                 /* Notify protocols, that we are about to destroy
>                    this device. They should clean all the things.
>                 */
>                 call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
>         }
>
>         This is the same NETDEV_UNREGISTER_BATCH logic:
>
> +       list_for_each_entry(dev, head, unreg_list) {
> +               net_add_event_list(&net_head, dev_net(dev));
> +       }
> +       list_for_each_entry_safe(net, net_tmp, &net_head, event_list) {
> +               call_netdevice_notifiers(NETDEV_UNREGISTER_BATCH,
> +                                        net->loopback_dev);
> +               net_del_event_list(net);
> +       }
>
>         Second part of the loop:
>
>         list_for_each_entry(dev, head, unreg_list) {
>                 struct sk_buff *skb = NULL;
>
>                 if (!dev->rtnl_link_ops ||
>                 ...
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>

You're right. It is probably safer to organize the code the way you said.
Will change that, Thanks!

Salam
