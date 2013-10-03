From: Francesco Ruggeri <fruggeri@aristanetworks.com>
Subject: Re: [PATCH] net: Separate the close_list and the unreg_list
Date: Thu, 3 Oct 2013 14:51:34 -0700
Message-ID: <CA+HUmGgJYeCj-wod=FsWJuZXQN0Kgbwiv+7iY7r+0BCOdqTDvg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Cong Wang <amwang@redhat.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f51.google.com ([209.85.219.51]:39192 "EHLO
	mail-oa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755643Ab3JCVvf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Oct 2013 17:51:35 -0400
Received: by mail-oa0-f51.google.com with SMTP id h16so3056936oag.10
        for <netdev@vger.kernel.org>; Thu, 03 Oct 2013 14:51:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch from Eric may have fallen through the cracks.
At the time he submitted it I did verify it in some failures I was
seeing (I have not run extensive tests).

Francesco


On Mon, Sep 16, 2013 at 4:57 PM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
>
> Separate the unreg_list and the close_list in dev_close_many preventing
> dev_close_many from permuting the unreg_list.  The permutations of the
> unreg_list have resulted in cases where the loopback device is accessed
> it has been freed in code such as dst_ifdown.  Resulting in subtle
> memory corruption.
>
> This is the second bug from sharing the storage between the close_list
> and the unreg_list.  The issues that crop up with sharing are apparently
> too subtle to show up in normal testing or usage, so let's forget about
> being clever and use two separate lists.
>
> Cc: <stable@vger.kernel.org>
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
>
> Frencesco if you could test this patch and verify it fixes some of your
> issues that would be great.  I don't expect this fixes the fundamental
> problem you were seeing but it should solve some related issues.
>
>  include/linux/netdevice.h |    1 +
>  net/core/dev.c            |   25 +++++++++++++------------
>  net/sched/sch_generic.c   |    6 +++---
>  3 files changed, 17 insertions(+), 15 deletions(-)
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 0741a1e..7858bfc 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1106,6 +1106,7 @@ struct net_device {
>         struct list_head        dev_list;
>         struct list_head        napi_list;
>         struct list_head        unreg_list;
> +       struct list_head        close_list;
>         struct list_head        upper_dev_list; /* List of upper devices */
>
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index a3d8d44..5d702fe 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1307,7 +1307,7 @@ static int __dev_close_many(struct list_head *head)
>         ASSERT_RTNL();
>         might_sleep();
>
> -       list_for_each_entry(dev, head, unreg_list) {
> +       list_for_each_entry(dev, head, close_list) {
>                 call_netdevice_notifiers(NETDEV_GOING_DOWN, dev);
>
>                 clear_bit(__LINK_STATE_START, &dev->state);
> @@ -1323,7 +1323,7 @@ static int __dev_close_many(struct list_head *head)
>
>         dev_deactivate_many(head);
>
> -       list_for_each_entry(dev, head, unreg_list) {
> +       list_for_each_entry(dev, head, close_list) {
>                 const struct net_device_ops *ops = dev->netdev_ops;
>
>                 /*
> @@ -1351,7 +1351,7 @@ static int __dev_close(struct net_device *dev)
>         /* Temporarily disable netpoll until the interface is down */
>         netpoll_rx_disable(dev);
>
> -       list_add(&dev->unreg_list, &single);
> +       list_add(&dev->close_list, &single);
>         retval = __dev_close_many(&single);
>         list_del(&single);
>
> @@ -1362,21 +1362,21 @@ static int __dev_close(struct net_device *dev)
>  static int dev_close_many(struct list_head *head)
>  {
>         struct net_device *dev, *tmp;
> -       LIST_HEAD(tmp_list);
> +       LIST_HEAD(many);
>
> -       list_for_each_entry_safe(dev, tmp, head, unreg_list)
> -               if (!(dev->flags & IFF_UP))
> -                       list_move(&dev->unreg_list, &tmp_list);
> +       /* rollback_registered_many needs the original unmodified list */
> +       list_for_each_entry(dev, head, unreg_list)
> +               if (dev->flags & IFF_UP)
> +                       list_add_tail(&dev->close_list, &many);
>
> -       __dev_close_many(head);
> +       __dev_close_many(&many);
>
> -       list_for_each_entry(dev, head, unreg_list) {
> +       list_for_each_entry_safe(dev, tmp, &many, close_list) {
>                 rtmsg_ifinfo(RTM_NEWLINK, dev, IFF_UP|IFF_RUNNING);
>                 call_netdevice_notifiers(NETDEV_DOWN, dev);
> +               list_del_init(&dev->close_list);
>         }
>
> -       /* rollback_registered_many needs the complete original list */
> -       list_splice(&tmp_list, head);
>         return 0;
>  }
>
> @@ -1397,7 +1397,7 @@ int dev_close(struct net_device *dev)
>                 /* Block netpoll rx while the interface is going down */
>                 netpoll_rx_disable(dev);
>
> -               list_add(&dev->unreg_list, &single);
> +               list_add(&dev->close_list, &single);
>                 dev_close_many(&single);
>                 list_del(&single);
>
> @@ -5823,6 +5823,7 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
>
>         INIT_LIST_HEAD(&dev->napi_list);
>         INIT_LIST_HEAD(&dev->unreg_list);
> +       INIT_LIST_HEAD(&dev->close_list);
>         INIT_LIST_HEAD(&dev->link_watch_list);
>         INIT_LIST_HEAD(&dev->upper_dev_list);
>         dev->priv_flags = IFF_XMIT_DST_RELEASE;
> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> index 4626cef..dee62f4 100644
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -818,7 +818,7 @@ void dev_deactivate_many(struct list_head *head)
>         struct net_device *dev;
>         bool sync_needed = false;
>
> -       list_for_each_entry(dev, head, unreg_list) {
> +       list_for_each_entry(dev, head, close_list) {
>                 netdev_for_each_tx_queue(dev, dev_deactivate_queue,
>                                          &noop_qdisc);
>                 if (dev_ingress_queue(dev))
> @@ -837,7 +837,7 @@ void dev_deactivate_many(struct list_head *head)
>                 synchronize_net();
>
>         /* Wait for outstanding qdisc_run calls. */
> -       list_for_each_entry(dev, head, unreg_list)
> +       list_for_each_entry(dev, head, close_list)
>                 while (some_qdisc_is_busy(dev))
>                         yield();
>  }
> @@ -846,7 +846,7 @@ void dev_deactivate(struct net_device *dev)
>  {
>         LIST_HEAD(single);
>
> -       list_add(&dev->unreg_list, &single);
> +       list_add(&dev->close_list, &single);
>         dev_deactivate_many(&single);
>         list_del(&single);
>  }
> --
> 1.7.5.4
>
