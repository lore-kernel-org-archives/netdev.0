From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH 1/1] ixgbe: replace rtnl_lock with rcu_read_lock
Date: Sun, 5 Jun 2016 11:40:45 -0700
Message-ID: <CAKgT0UeF-Ktx5my99NAR4j7ATwUWx249yAZD+sMkQkjBJaeEdA@mail.gmail.com>
References: <1465118091-6233-1-git-send-email-zyjzyj2000@gmail.com> <1465118091-6233-2-git-send-email-zyjzyj2000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	Netdev <netdev@vger.kernel.org>
To: zhuyj <zyjzyj2000@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35792 "EHLO
	mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750956AbcFESkr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2016 14:40:47 -0400
Received: by mail-it0-f65.google.com with SMTP id z123so3888161itg.2
        for <netdev@vger.kernel.org>; Sun, 05 Jun 2016 11:40:47 -0700 (PDT)
In-Reply-To: <1465118091-6233-2-git-send-email-zyjzyj2000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 5, 2016 at 2:14 AM,  <zyjzyj2000@gmail.com> wrote:
> From: Zhu Yanjun <zyjzyj2000@gmail.com>
>
>
> Signed-off-by: Zhu Yanjun <zyjzyj2000@gmail.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index 088c47c..cb19cbc 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -6840,7 +6840,7 @@ static void ixgbe_watchdog_link_is_up(struct ixgbe_adapter *adapter)
>         netif_tx_wake_all_queues(adapter->netdev);
>
>         /* enable any upper devices */
> -       rtnl_lock();
> +       rcu_read_lock();
>         netdev_for_each_all_upper_dev_rcu(adapter->netdev, upper, iter) {
>                 if (netif_is_macvlan(upper)) {
>                         struct macvlan_dev *vlan = netdev_priv(upper);
> @@ -6849,7 +6849,7 @@ static void ixgbe_watchdog_link_is_up(struct ixgbe_adapter *adapter)
>                                 netif_tx_wake_all_queues(upper);
>                 }
>         }
> -       rtnl_unlock();
> +       rcu_read_unlock();
>
>         /* update the default user priority for VFs */
>         ixgbe_update_default_up(adapter);

The rtnl_lock is being used to prevent any changes to the upper
devices while the interface is going through and updating the Tx queue
configuration on them.  Without that lock you introduce possible bugs
since you could have queues freed or added while this loop is in the
middle of trying to update the state of it.

As a general rule you use rcu_read_lock when you are only reading an
RCU protected structure, you use rtnl_lock when you have to protect
the system from any other changes while you are updating network
configuration.  In this case netif_tx_wake_all_queues changes the
state of the upper device.  The use of rtnl_lock here is intentional
and it is best to just leave it as is unless you have some actual bug
you are seeing.

- Alex
