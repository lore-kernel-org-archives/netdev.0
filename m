From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH next v3] bonding: Display LACP info only to CAP_NET_ADMIN
 capable user
Date: Thu, 18 Jun 2015 23:00:11 -0400
Message-ID: <20150619030010.GP588@gospo.home.greyhouse.net>
References: <1434652254-17510-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:33170 "EHLO
	mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752261AbbFSDAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2015 23:00:15 -0400
Received: by qkhu186 with SMTP id u186so54565944qkh.0
        for <netdev@vger.kernel.org>; Thu, 18 Jun 2015 20:00:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1434652254-17510-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 18, 2015 at 11:30:54AM -0700, Mahesh Bandewar wrote:
> Actor and Partner details can be accessed via proc-fs, sys-fs
> entries or netlink interface. These interfaces are world readable
> at this moment. The earlier patch-series made the LACP communication
> secure to avoid nuisance attack from within the same L2 domain but
> it did not prevent "someone unprivileged" looking at that information
> on host and perform the same act.
> 
> This patch essentially avoids spitting those entries if the user
> in question does not have enough privileges.
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
>  drivers/net/bonding/bond_netlink.c |  23 +++++----
>  drivers/net/bonding/bond_procfs.c  | 101 +++++++++++++++++++------------------
>  drivers/net/bonding/bond_sysfs.c   |  12 ++---
>  3 files changed, 71 insertions(+), 65 deletions(-)
> 
[...]
> diff --git a/drivers/net/bonding/bond_procfs.c b/drivers/net/bonding/bond_procfs.c
> index e7f3047a26df..f514fe5e80a5 100644
> --- a/drivers/net/bonding/bond_procfs.c
> +++ b/drivers/net/bonding/bond_procfs.c
[...]
> @@ -199,33 +202,35 @@ static void bond_info_show_slave(struct seq_file *seq,
>  			seq_printf(seq, "Partner Churned Count: %d\n",
>  				   port->churn_partner_count);
>  
> -			seq_puts(seq, "details actor lacp pdu:\n");
> -			seq_printf(seq, "    system priority: %d\n",
> -				   port->actor_system_priority);
> -			seq_printf(seq, "    system mac address: %pM\n",
> -				   &port->actor_system);
> -			seq_printf(seq, "    port key: %d\n",
> -				   port->actor_oper_port_key);
> -			seq_printf(seq, "    port priority: %d\n",
> -				   port->actor_port_priority);
> -			seq_printf(seq, "    port number: %d\n",
> -				   port->actor_port_number);
> -			seq_printf(seq, "    port state: %d\n",
> -				   port->actor_oper_port_state);
> -
> -			seq_puts(seq, "details partner lacp pdu:\n");
> -			seq_printf(seq, "    system priority: %d\n",
> -				   port->partner_oper.system_priority);
> -			seq_printf(seq, "    system mac address: %pM\n",
> -				   &port->partner_oper.system);
> -			seq_printf(seq, "    oper key: %d\n",
> -				   port->partner_oper.key);
> -			seq_printf(seq, "    port priority: %d\n",
> -				   port->partner_oper.port_priority);
> -			seq_printf(seq, "    port number: %d\n",
> -				   port->partner_oper.port_number);
> -			seq_printf(seq, "    port state: %d\n",
> -				   port->partner_oper.port_state);
> +			if (capable(CAP_NET_ADMIN)) {
> +				seq_puts(seq, "details actor lacp pdu:\n");
> +				seq_printf(seq, "    system priority: %d\n",
> +					   port->actor_system_priority);
> +				seq_printf(seq, "    system mac address: %pM\n",
> +					   &port->actor_system);
> +				seq_printf(seq, "    port key: %d\n",
> +					   port->actor_oper_port_key);
> +				seq_printf(seq, "    port priority: %d\n",
> +					   port->actor_port_priority);
> +				seq_printf(seq, "    port number: %d\n",
> +					   port->actor_port_number);
> +				seq_printf(seq, "    port state: %d\n",
> +					   port->actor_oper_port_state);
> +
> +				seq_puts(seq, "details partner lacp pdu:\n");
> +				seq_printf(seq, "    system priority: %d\n",
> +					   port->partner_oper.system_priority);
> +				seq_printf(seq, "    system mac address: %pM\n",
> +					   &port->partner_oper.system);
> +				seq_printf(seq, "    oper key: %d\n",
> +					   port->partner_oper.key);
> +				seq_printf(seq, "    port priority: %d\n",
> +					   port->partner_oper.port_priority);
> +				seq_printf(seq, "    port number: %d\n",
> +					   port->partner_oper.port_number);
> +				seq_printf(seq, "    port state: %d\n",
> +					   port->partner_oper.port_state);
> +			}
>  		} else {
>  			seq_puts(seq, "Aggregator ID: N/A\n");
>  		}

With this patch, actor_oper_port_state and partner_oper.port_state are
not displayed in /proc, but that information is available via netlink
from bond_fill_slave_info().

I suspect you do not deem these two values as critical to the security
of the system, but wanted to confirm before ACKing.
