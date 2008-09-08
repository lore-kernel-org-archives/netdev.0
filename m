From: "Dushan Tcholich" <dusanc@gmail.com>
Subject: Re: [PATCH] bridge: don't allow setting hello time to zero
Date: Mon, 8 Sep 2008 23:35:19 +0200
Message-ID: <a08621850809081435g6c0c9d5bwdd8cf937eec9e2db@mail.gmail.com>
References: <20080831100537.6929c51e@extreme> <20080831104309.780cc01f@extreme>
	 <20080904154709.48fe0775@extreme>
	 <20080908.134650.26179244.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, romieu@fr.zoreil.com, hancockr@shaw.ca,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.181]:45453 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754581AbYIHVfU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 17:35:20 -0400
Received: by wa-out-1112.google.com with SMTP id j37so1262771waf.23
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2008 14:35:19 -0700 (PDT)
In-Reply-To: <20080908.134650.26179244.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 8, 2008 at 10:46 PM, David Miller <davem@davemloft.net> wrote:
> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Thu, 4 Sep 2008 15:47:09 -0700
>
>> The bridge hello time can't be safely set to values less than 1 second,
>> otherwise it is possible to end up with a runaway timer.
>>
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>
> Applied, thanks Stephen.
>
> I added more information to the commit message so that Dushan's
> incredibly contribution to this bug getting fixed are mentioned.
> I don't see how we would have figured out Bridging as even the
> cause without his detective work.  So it's definitely wrong not
> to give him at least some mention in the commit message :-/
>

I don't know what to say :)

Thank you
> bridge: don't allow setting hello time to zero
>
> Dushan Tcholich reports that on his system ksoftirqd can consume
> between %6 to %10 of cpu time, and cause ~200 context switches per
> second.
>
A little nitpick: 200 times greater context switch rate :), like
100000 per second.

> He then correlated this with a report by bdupree@techfinesse.com:
>
>        http://marc.info/?l=linux-kernel&m=119613299024398&w=2
>
> and the culprit cause seems to be starting the bridge interface.
> In particular, when starting the bridge interface, his scripts
> are specifying a hello timer interval of "0".
>
> The bridge hello time can't be safely set to values less than 1
> second, otherwise it is possible to end up with a runaway timer.

Btw. is there a way to make the command to turn STP off work too?
brctl stp br0 off
Because AFAIK if I shut down STP the hello timer should shut down too,
but it still continues to work.

Thank you for your time and effort

Dushan Tcholich

>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  net/bridge/br_ioctl.c    |    8 +++++++-
>  net/bridge/br_sysfs_br.c |   26 ++++++++++++++++++--------
>  2 files changed, 25 insertions(+), 9 deletions(-)
>
> diff --git a/net/bridge/br_ioctl.c b/net/bridge/br_ioctl.c
> index eeee218..5bbf073 100644
> --- a/net/bridge/br_ioctl.c
> +++ b/net/bridge/br_ioctl.c
> @@ -188,15 +188,21 @@ static int old_dev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
>                return 0;
>
>        case BRCTL_SET_BRIDGE_HELLO_TIME:
> +       {
> +               unsigned long t = clock_t_to_jiffies(args[1]);
>                if (!capable(CAP_NET_ADMIN))
>                        return -EPERM;
>
> +               if (t < HZ)
> +                       return -EINVAL;
> +
>                spin_lock_bh(&br->lock);
> -               br->bridge_hello_time = clock_t_to_jiffies(args[1]);
> +               br->bridge_hello_time = t;
>                if (br_is_root_bridge(br))
>                        br->hello_time = br->bridge_hello_time;
>                spin_unlock_bh(&br->lock);
>                return 0;
> +       }
>
>        case BRCTL_SET_BRIDGE_MAX_AGE:
>                if (!capable(CAP_NET_ADMIN))
> diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
> index 27d6a51..158dee8 100644
> --- a/net/bridge/br_sysfs_br.c
> +++ b/net/bridge/br_sysfs_br.c
> @@ -29,11 +29,12 @@
>  */
>  static ssize_t store_bridge_parm(struct device *d,
>                                 const char *buf, size_t len,
> -                                void (*set)(struct net_bridge *, unsigned long))
> +                                int (*set)(struct net_bridge *, unsigned long))
>  {
>        struct net_bridge *br = to_bridge(d);
>        char *endp;
>        unsigned long val;
> +       int err;
>
>        if (!capable(CAP_NET_ADMIN))
>                return -EPERM;
> @@ -43,9 +44,9 @@ static ssize_t store_bridge_parm(struct device *d,
>                return -EINVAL;
>
>        spin_lock_bh(&br->lock);
> -       (*set)(br, val);
> +       err = (*set)(br, val);
>        spin_unlock_bh(&br->lock);
> -       return len;
> +       return err ? err : len;
>  }
>
>
> @@ -56,12 +57,13 @@ static ssize_t show_forward_delay(struct device *d,
>        return sprintf(buf, "%lu\n", jiffies_to_clock_t(br->forward_delay));
>  }
>
> -static void set_forward_delay(struct net_bridge *br, unsigned long val)
> +static int set_forward_delay(struct net_bridge *br, unsigned long val)
>  {
>        unsigned long delay = clock_t_to_jiffies(val);
>        br->forward_delay = delay;
>        if (br_is_root_bridge(br))
>                br->bridge_forward_delay = delay;
> +       return 0;
>  }
>
>  static ssize_t store_forward_delay(struct device *d,
> @@ -80,12 +82,17 @@ static ssize_t show_hello_time(struct device *d, struct device_attribute *attr,
>                       jiffies_to_clock_t(to_bridge(d)->hello_time));
>  }
>
> -static void set_hello_time(struct net_bridge *br, unsigned long val)
> +static int set_hello_time(struct net_bridge *br, unsigned long val)
>  {
>        unsigned long t = clock_t_to_jiffies(val);
> +
> +       if (t < HZ)
> +               return -EINVAL;
> +
>        br->hello_time = t;
>        if (br_is_root_bridge(br))
>                br->bridge_hello_time = t;
> +       return 0;
>  }
>
>  static ssize_t store_hello_time(struct device *d,
> @@ -104,12 +111,13 @@ static ssize_t show_max_age(struct device *d, struct device_attribute *attr,
>                       jiffies_to_clock_t(to_bridge(d)->max_age));
>  }
>
> -static void set_max_age(struct net_bridge *br, unsigned long val)
> +static int set_max_age(struct net_bridge *br, unsigned long val)
>  {
>        unsigned long t = clock_t_to_jiffies(val);
>        br->max_age = t;
>        if (br_is_root_bridge(br))
>                br->bridge_max_age = t;
> +       return 0;
>  }
>
>  static ssize_t store_max_age(struct device *d, struct device_attribute *attr,
> @@ -126,9 +134,10 @@ static ssize_t show_ageing_time(struct device *d,
>        return sprintf(buf, "%lu\n", jiffies_to_clock_t(br->ageing_time));
>  }
>
> -static void set_ageing_time(struct net_bridge *br, unsigned long val)
> +static int set_ageing_time(struct net_bridge *br, unsigned long val)
>  {
>        br->ageing_time = clock_t_to_jiffies(val);
> +       return 0;
>  }
>
>  static ssize_t store_ageing_time(struct device *d,
> @@ -180,9 +189,10 @@ static ssize_t show_priority(struct device *d, struct device_attribute *attr,
>                       (br->bridge_id.prio[0] << 8) | br->bridge_id.prio[1]);
>  }
>
> -static void set_priority(struct net_bridge *br, unsigned long val)
> +static int set_priority(struct net_bridge *br, unsigned long val)
>  {
>        br_stp_set_bridge_priority(br, (u16) val);
> +       return 0;
>  }
>
>  static ssize_t store_priority(struct device *d, struct device_attribute *attr,
> --
> 1.5.6.5.GIT
>
>
