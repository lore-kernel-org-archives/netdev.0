From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH]  Break 'budget' dependency on netdev_max_backlog.
Date: Mon, 21 Oct 2002 08:51:46 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0210210850560.17911-100000@shell.cyberus.ca>
References: <3DB3A2DA.40108@candelatech.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>,
   Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3DB3A2DA.40108@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Patch looks fine except for the 300 number. What are you smoking?
Please retain the original value.

cheers,
jamal

On Sun, 20 Oct 2002, Ben Greear wrote:

> I want to have a very high netdev_max_backlog, but that makes
> NAPI with the tulip driver (and 4 running ports) drop packets,
> I assume because by the time it polls the first 3, the 4th has
> been neglected too long...
>
> So, this patch makes the budget NAPI variable independently tunable.
> The default of 300 seems to work well, and is the current default.
>
> In the future, I'm guessing we want a per-interface budget, because
> a high performance GigE NIC will want a higher budget that the
> venerable 100bt.
>
>
> --- linux-2.4.19.p3/include/linux/sysctl.h      Tue Oct 15 14:26:40 2002
> +++ linux-2.4.19.p4/include/linux/sysctl.h      Sun Oct 20 23:24:13 2002
> @@ -206,7 +206,8 @@
>          NET_CORE_NO_CONG=14,
>          NET_CORE_LO_CONG=15,
>          NET_CORE_MOD_CONG=16,
> -       NET_CORE_DEV_WEIGHT=17
> +       NET_CORE_DEV_WEIGHT=17,
> +       NET_CORE_MAX_POLL=18
>   };
>
>   /* /proc/sys/net/ethernet */
> --- linux-2.4.19.p3/net/core/dev.c      Tue Oct 15 14:23:39 2002
> +++ linux-2.4.19.p4/net/core/dev.c      Sun Oct 20 23:36:02 2002
> @@ -1092,6 +1092,7 @@
>     =======================================================================*/
>
>   int netdev_max_backlog = 300;
> +int netdev_max_poll = 300; /* 'Budget' for the NAPI poll method */
>   int weight_p = 64;            /* old backlog weight */
>   /* These numbers are selected based on intuition and some
>    * experimentatiom, if you have more scientific way of doing this
> @@ -1604,7 +1605,7 @@
>          int this_cpu = smp_processor_id();
>          struct softnet_data *queue = &softnet_data[this_cpu];
>          unsigned long start_time = jiffies;
> -       int budget = netdev_max_backlog;
> +       int budget = netdev_max_poll;
>
>          br_read_lock(BR_NETPROTO_LOCK);
>          local_irq_disable();
> --- linux-2.4.19.p3/net/core/sysctl_net_core.c  Wed Oct  9 00:24:02 2002
> +++ linux-2.4.19.p4/net/core/sysctl_net_core.c  Sun Oct 20 23:35:23 2002
> @@ -12,6 +12,7 @@
>   #ifdef CONFIG_SYSCTL
>
>   extern int netdev_max_backlog;
> +extern int netdev_max_poll;
>   extern int weight_p;
>   extern int no_cong_thresh;
>   extern int no_cong;
> @@ -54,6 +55,9 @@
>          {NET_CORE_MAX_BACKLOG, "netdev_max_backlog",
>           &netdev_max_backlog, sizeof(int), 0644, NULL,
>           &proc_dointvec},
> +       {NET_CORE_MAX_POLL, "netdev_max_poll",
> +        &netdev_max_poll, sizeof(int), 0644, NULL,
> +        &proc_dointvec},
>          {NET_CORE_NO_CONG_THRESH, "no_cong_thresh",
>           &no_cong, sizeof(int), 0644, NULL,
>           &proc_dointvec},
>
>
> --
> Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
> President of Candela Technologies Inc      http://www.candelatech.com
> ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
>
>
>
