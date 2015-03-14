From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v2] Configure bridge FDB ageing time using netlink.
Date: Sat, 14 Mar 2015 15:17:18 -0700
Message-ID: <CAE4R7bCAfrJDMZMEKhurd2axe0vpo+peZt7DdUMKwWhtwNaMnw@mail.gmail.com>
References: <1426297229-21122-1-git-send-email-siva.mannem.lnx@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>
To: Siva Mannem <siva.mannem.lnx@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f51.google.com ([209.85.192.51]:36243 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751986AbbCNWRT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2015 18:17:19 -0400
Received: by qgg60 with SMTP id 60so13579402qgg.3
        for <netdev@vger.kernel.org>; Sat, 14 Mar 2015 15:17:18 -0700 (PDT)
In-Reply-To: <1426297229-21122-1-git-send-email-siva.mannem.lnx@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 13, 2015 at 6:40 PM, Siva Mannem <siva.mannem.lnx@gmail.com> wrote:
> This patch allows user to configure bridge's FDB ageing using
> netlink(for ex, iproute2). Allowed range is 10 seconds to 1000000 seconds
> as per ieee8021QBridgeFdbAgingTime.
>
> Signed-off-by: Siva Mannem <siva.mannem.lnx@gmail.com>
> ---
> Changes in v2:
>  - Added commit message.
>  - Fix style problems reported by checkpatch.pl.


> +
> +int br_set_ageing_time(struct net_bridge *br, unsigned long val)
> +{
> +       unsigned long t = clock_t_to_jiffies(val);
> +
> +       if (t < BR_MIN_AGEING_TIME || t > BR_MAX_AGEING_TIME)
> +               return -ERANGE;
> +
> +       spin_lock_bh(&br->lock);
> +       br->ageing_time = t;

I wonder if you need to call mod_timer(&br->gc_timer, jiffies) after
adjusting the time, to make new ageing_time effective?  The worst-case
scenario I'm thinking about is if the initial br->ageing_time is the
max value (1000000 seconds) and the user changes it the min value (10
seconds), will the original 1000000 seconds need to expire before the
gc_timer is called again and reset to 10 seconds?

> +       spin_unlock_bh(&br->lock);
> +       return 0;
> +}
> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
> index 8bc6b67..d80e802 100644
