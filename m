From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [RFC 7/9] net: dsa: mv88e6352: lock CPU port from learning addresses
Date: Tue, 02 Jun 2015 07:24:36 -0700
Message-ID: <556DBCA4.10203@roeck-us.net>
References: <1433208470-25338-1-git-send-email-vivien.didelot@savoirfairelinux.com> <1433208470-25338-8-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Jerome Oufella <jerome.oufella@savoirfairelinux.com>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	Chris Healy <cphealy@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:46976 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755833AbbFBOYk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 10:24:40 -0400
In-Reply-To: <1433208470-25338-8-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/01/2015 06:27 PM, Vivien Didelot wrote:
> This commit disables SA learning and refreshing for the CPU port.
>

Hi Vivien,

This patch also seems to be unrelated to the rest of the series.

Can you add an explanation why it is needed ?

With this in place, how does the CPU port SA find its way into the fdb ?
Do we assume that it will be configured statically ?
An explanation might be useful.

Thanks,
Guenter

> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>   drivers/net/dsa/mv88e6xxx.c | 8 +++++---
>   drivers/net/dsa/mv88e6xxx.h | 1 +
>   2 files changed, 6 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
> index d2beb10..ed49bd8 100644
> --- a/drivers/net/dsa/mv88e6xxx.c
> +++ b/drivers/net/dsa/mv88e6xxx.c
> @@ -1761,10 +1761,12 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
>   	/* Port Association Vector: when learning source addresses
>   	 * of packets, add the address to the address database using
>   	 * a port bitmap that has only the bit for this port set and
> -	 * the other bits clear.
> +	 * the other bits clear, except for the CPU port.
>   	 */
> -	ret = _mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_ASSOC_VECTOR,
> -				   1 << port);
> +	reg = BIT(port);
> +	if (dsa_is_cpu_port(ds, port))
> +		reg |= PORT_ASSOC_VECTOR_LOCKED_PORT;
> +	ret = _mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_ASSOC_VECTOR, reg);
>   	if (ret)
>   		goto abort;
>
> diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
> index 412d14e..e26eb0c 100644
> --- a/drivers/net/dsa/mv88e6xxx.h
> +++ b/drivers/net/dsa/mv88e6xxx.h
> @@ -144,6 +144,7 @@
>   #define PORT_RATE_CONTROL	0x09
>   #define PORT_RATE_CONTROL_2	0x0a
>   #define PORT_ASSOC_VECTOR	0x0b
> +#define PORT_ASSOC_VECTOR_LOCKED_PORT	BIT(13)
>   #define PORT_ATU_CONTROL	0x0c
>   #define PORT_PRI_OVERRIDE	0x0d
>   #define PORT_ETH_TYPE		0x0f
>
