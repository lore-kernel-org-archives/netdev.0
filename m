From: David Ahern <dsahern@gmail.com>
Subject: Re: [RFC net-next 1/4] net: ipv6: Make inet6addr_validator a blocking
 notifier
Date: Tue, 10 Oct 2017 13:32:22 -0600
Message-ID: <899f892c-1f1f-33dd-1d55-310c215c33e8@gmail.com>
References: <1507653665-20540-1-git-send-email-dsahern@gmail.com>
 <1507653665-20540-2-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: jiri@mellanox.com, kjlx@templeofstupid.com
To: netdev@vger.kernel.org, idosch@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35747 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754196AbdJJTcZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 15:32:25 -0400
Received: by mail-pf0-f196.google.com with SMTP id i23so37902804pfi.2
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 12:32:25 -0700 (PDT)
In-Reply-To: <1507653665-20540-2-git-send-email-dsahern@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/10/17 10:41 AM, David Ahern wrote:
> @@ -988,16 +987,23 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
>  		goto out2;
>  	}
>  
> -	i6vi.i6vi_addr = *addr;
> -	i6vi.i6vi_dev = idev;
> -	rcu_read_unlock_bh();
> +	/* validator notifier needs to be blocking;
> +	 * do not call in softirq context
> +	 */
> +	if (!in_softirq()) {
> +		struct in6_validator_info i6vi = {
> +			.i6vi_addr = *addr,
> +			.i6vi_dev = idev,
> +		};
>  
> -	err = inet6addr_validator_notifier_call_chain(NETDEV_UP, &i6vi);
> +		rcu_read_unlock_bh();
> +		err = inet6addr_validator_notifier_call_chain(NETDEV_UP, &i6vi);
> +		rcu_read_lock_bh();
>  
> -	rcu_read_lock_bh();
> -	err = notifier_to_errno(err);
> -	if (err)
> -		goto out2;
> +		err = notifier_to_errno(err);
> +		if (err)
> +			goto out2;
> +	}
>  
>  	spin_lock(&addrconf_hash_lock);
>  

The rcu_read_unlock_bh needs to be done before the in_softirq check.
With the change below I get the RIF overload with IPv6 addresses and I
verified the validator is skipped for RAs.

$ ip -batch vlan-ipv6-addr-batch
Error: spectrum: Exceeded number of supported router interfaces.
Command failed vlan-ipv6-addr-batch:683


diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 0bad4a800f73..d9c5b29a3b8b 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -988,6 +988,8 @@ ipv6_add_addr(struct inet6_dev *idev, const struct
in6_addr *addr,
                goto out2;
        }

+       rcu_read_unlock_bh();
+
        /* validator notifier needs to be blocking;
         * do not call in softirq context
         */
@@ -998,15 +1000,14 @@ ipv6_add_addr(struct inet6_dev *idev, const
struct in6_addr *addr,
                        .extack = extack,
                };

-               rcu_read_unlock_bh();
                err = inet6addr_validator_notifier_call_chain(NETDEV_UP,
&i6vi);
-               rcu_read_lock_bh();
-
                err = notifier_to_errno(err);
                if (err)
-                       goto out2;
+                       goto out1;
        }

+       rcu_read_lock_bh();
+
        spin_lock(&addrconf_hash_lock);

        /* Ignore adding duplicate addresses on an interface */
@@ -1079,7 +1080,7 @@ ipv6_add_addr(struct inet6_dev *idev, const struct
in6_addr *addr,
        write_unlock(&idev->lock);
 out2:
        rcu_read_unlock_bh();
-
+out1:
        if (likely(err == 0))
                inet6addr_notifier_call_chain(NETDEV_UP, ifa);
        else {
