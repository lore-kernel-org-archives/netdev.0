From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net-next v1] bonding: Fix another case of LACPDU not sent
 on slave
Date: Tue, 31 Mar 2015 11:59:57 -0400
Message-ID: <20150331155956.GP1051@gospo>
References: <1427751076-4512-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>,
	Maciej Zenczykowski <maze@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f179.google.com ([209.85.216.179]:33195 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752726AbbCaQAB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 12:00:01 -0400
Received: by qcrf4 with SMTP id f4so4809358qcr.0
        for <netdev@vger.kernel.org>; Tue, 31 Mar 2015 09:00:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1427751076-4512-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 30, 2015 at 02:31:16PM -0700, Mahesh Bandewar wrote:
> When mii-mon discovers that the link is up, it will call
> bond_3ad_handle_link_change() but we forget to add the LACP_ENABLED
> flag when we discover the speed and duplex for the slave link are
> normal.
> 
> Change-Id: Ie8b268ecfeea0f99bf9fdcd72706c0653f9d9e49
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>

This won't make the state machine start-up more quickly will it?  Either
way...

Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>


> ---
>  drivers/net/bonding/bond_3ad.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
> index 4309b5a76708..30e8d118664b 100644
> --- a/drivers/net/bonding/bond_3ad.c
> +++ b/drivers/net/bonding/bond_3ad.c
> @@ -2436,12 +2436,15 @@ void bond_3ad_handle_link_change(struct slave *slave, char link)
>  		port->actor_admin_port_key &= ~AD_SPEED_KEY_MASKS;
>  		port->actor_oper_port_key = port->actor_admin_port_key |=
>  			(__get_link_speed(port) << 1);
> +		if (port->actor_oper_port_key & AD_DUPLEX_KEY_MASKS)
> +			port->sm_vars |= AD_PORT_LACP_ENABLED;
>  	} else {
>  		/* link has failed */
>  		port->is_enabled = false;
>  		port->actor_admin_port_key &= ~AD_DUPLEX_KEY_MASKS;
>  		port->actor_oper_port_key = (port->actor_admin_port_key &=
>  					     ~AD_SPEED_KEY_MASKS);
> +		port->sm_vars &= ~AD_PORT_LACP_ENABLED;
>  	}
>  	netdev_dbg(slave->bond->dev, "Port %d changed link status to %s\n",
>  		   port->actor_port_number,
> -- 
> 2.2.0.rc0.207.ga3a616c
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
