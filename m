From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: [PATCH net] switchdev: bridge: Check return code is not
 EOPNOTSUPP
Date: Fri, 13 Nov 2015 13:34:45 +0100
Message-ID: <f9593252b8a9d4733dfa7d22dd71d803@eikelenboom.it>
References: <1447412772-29745-1-git-send-email-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	davem@davemloft.net, eladr@mellanox.com,
	Jiri Pirko <jiri@mellanox.com>
To: Ido Schimmel <idosch@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vserver.eikelenboom.it ([84.200.39.61]:38922 "EHLO
	smtp.eikelenboom.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754337AbbKMMhF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2015 07:37:05 -0500
In-Reply-To: <1447412772-29745-1-git-send-email-idosch@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015-11-13 12:06, Ido Schimmel wrote:
> When NET_SWITCHDEV=n, switchdev_port_attr_set simply returns 
> EOPNOTSUPP.
> In this case we should not emit errors and warnings to the kernel log.

Hi Ido,

Thanks for your patch!

It fixes these:
[  207.245442] vif vif-1-0 vif1.0: failed to set HW ageing time
[  207.245443] xen_bridge: error setting offload STP state on 
port1(vif1.0)

But i still have these:
[  335.412194] vif19.0-emu: set_features() failed (-1); wanted 
0x00000080000048c1, left 0x00000080001b48c9
[  335.412204] vif19.0-emu: set_features() failed (-1); wanted 
0x00000080000048c1, left 0x00000080001b48c9
[  335.412311] vif19.0-emu: set_features() failed (-1); wanted 
0x00000080000248c9, left 0x00000080001b48c9
[  335.412319] vif19.0-emu: set_features() failed (-1); wanted 
0x00000080000048c1, left 0x00000080001b48c9
[  335.412326] vif19.0-emu: set_features() failed (-1); wanted 
0x00000080000048c1, left 0x00000080001b48c9
[  335.535955] vif vif-19-0 vif19.0: set_features() failed (-1); wanted 
0x0000000400004803, left 0x0000000400114813
[  335.535965] vif vif-19-0 vif19.0: set_features() failed (-1); wanted 
0x0000000400004803, left 0x0000000400114813
[  335.615392] vif vif-19-0 vif19.0: set_features() failed (-1); wanted 
0x0000000400004803, left 0x0000000400114813
[  335.615401] xen_bridge: set_features() failed (-1); wanted 
0x000000801fdb78c9, left 0x000000801fff78e9

--
Sander

> Reported-by: Sander Eikelenboom <linux@eikelenboom.it>
> Fixes: 0bc05d585d38 ("switchdev: allow caller to explicitly request
> attr_set as deferred")
> Fixes: 6ac311ae8bfb ("Adding switchdev ageing notification on port
> bridged")
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  net/bridge/br_stp.c    | 2 +-
>  net/bridge/br_stp_if.c | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
> index f7e8dee..5f3f645 100644
> --- a/net/bridge/br_stp.c
> +++ b/net/bridge/br_stp.c
> @@ -48,7 +48,7 @@ void br_set_state(struct net_bridge_port *p,
> unsigned int state)
> 
>  	p->state = state;
>  	err = switchdev_port_attr_set(p->dev, &attr);
> -	if (err)
> +	if (err && err != -EOPNOTSUPP)
>  		br_warn(p->br, "error setting offload STP state on port %u(%s)\n",
>  				(unsigned int) p->port_no, p->dev->name);
>  }
> diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
> index fa53d7a..5396ff08 100644
> --- a/net/bridge/br_stp_if.c
> +++ b/net/bridge/br_stp_if.c
> @@ -50,7 +50,7 @@ void br_init_port(struct net_bridge_port *p)
>  	p->config_pending = 0;
> 
>  	err = switchdev_port_attr_set(p->dev, &attr);
> -	if (err)
> +	if (err && err != -EOPNOTSUPP)
>  		netdev_err(p->dev, "failed to set HW ageing time\n");
>  }
