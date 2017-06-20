From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [net,v2] ipv6: reorder ip6_route_dev_notifier after ipv6_dev_notf
Date: Mon, 19 Jun 2017 21:54:41 -0700
Message-ID: <CAM_iQpWN6qFsQ_oAMXjC7k00pf0j90zxdx6hzUS58MFn29QSbg@mail.gmail.com>
References: <1493919363-19989-1-git-send-email-xiyou.wangcong@gmail.com> <59489369.8000309@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>,
        David Ahern <dsahern@gmail.com>,
        Brian Norris <briannorris@chromium.org>,
        Douglas Anderson <dianders@chromium.org>
To: jeffy <jeffy.chen@rock-chips.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36405 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750929AbdFTEzD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 00:55:03 -0400
Received: by mail-wm0-f66.google.com with SMTP id d17so20605354wme.3
        for <netdev@vger.kernel.org>; Mon, 19 Jun 2017 21:55:02 -0700 (PDT)
In-Reply-To: <59489369.8000309@rock-chips.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Mon, Jun 19, 2017 at 8:15 PM, jeffy <jeffy.chen@rock-chips.com> wrote:
> but actually they are not guaranteed to be paired:
>
> the netdev_run_todo(see the first dump stack above) would call
> netdev_wait_allrefs to rebroadcast unregister notification multiple times,
> unless timed out or all of the "struct net_device"'s refs released:
>
>  * This is called when unregistering network devices.
>  *
>  * Any protocol or device that holds a reference should register
>  * for netdevice notification, and cleanup and put back the
>  * reference if they receive an UNREGISTER event.
>  * We can get stuck here if buggy protocols don't correctly
>  * call dev_put.
>  */
> static void netdev_wait_allrefs(struct net_device *dev)
> {
> ...
>         while (refcnt != 0) {
>                 if (time_after(jiffies, rebroadcast_time + 1 * HZ)) {
>                         rtnl_lock();
>
>                         /* Rebroadcast unregister notification */
>                         call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
>
>                         __rtnl_unlock();
>                         rcu_barrier();
>                         rtnl_lock();
>
>
> call_netdevice_notifiers(NETDEV_UNREGISTER_FINAL, dev);

Interesting, I didn't notice this corner-case, because normally
we would hit the one in rollback_registered_many(). Probably
we need to add a check

if (dev->reg_state == NETREG_UNREGISTERING)

in ip6_route_dev_notify(). Can you give it a try?

I guess we probably need to revise other NETDEV_UNREGISTER
handlers too.

I will send a patch tomorrow.

Thanks!
