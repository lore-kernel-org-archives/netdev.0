From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH] net: dsa: mv88e6xxx: call _mv88e6xxx_stats_wait with
 SMI lock held
Date: Mon, 03 Aug 2015 08:01:24 -0700
Message-ID: <55BF8244.4010509@roeck-us.net>
References: <1438607864-17829-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:33366 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753585AbbHCPBe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 11:01:34 -0400
In-Reply-To: <1438607864-17829-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/03/2015 06:17 AM, Vivien Didelot wrote:
> At switch setup, _mv88e6xxx_stats_wait was called without holding the
> SMI mutex. Fix this by requesting the lock for this call.
>
> Also, return the _mv88e6xxx_stats_wait code, since it may fail.
>
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Not strictly needed because the mutex is initialized in the same call
sequence, but it doesn't hurt and is technically ok (and may prevent others
from submitting the same patch again ;-)

Reviewed-by: Guenter Roeck <linux@roeck-us.net>

> ---
>   drivers/net/dsa/mv88e6xxx.c | 7 +++++--
>   1 file changed, 5 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
> index 5e1dce1..8966cf2 100644
> --- a/drivers/net/dsa/mv88e6xxx.c
> +++ b/drivers/net/dsa/mv88e6xxx.c
> @@ -1938,6 +1938,7 @@ int mv88e6xxx_setup_common(struct dsa_switch *ds)
>   int mv88e6xxx_setup_global(struct dsa_switch *ds)
>   {
>   	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
> +	int ret;
>   	int i;
>
>   	/* Set the default address aging time to 5 minutes, and
> @@ -2036,9 +2037,11 @@ int mv88e6xxx_setup_global(struct dsa_switch *ds)
>   	REG_WRITE(REG_GLOBAL, GLOBAL_STATS_OP, GLOBAL_STATS_OP_FLUSH_ALL);
>
>   	/* Wait for the flush to complete. */
> -	_mv88e6xxx_stats_wait(ds);
> +	mutex_lock(&ps->smi_mutex);
> +	ret = _mv88e6xxx_stats_wait(ds);
> +	mutex_unlock(&ps->smi_mutex);
>
> -	return 0;
> +	return ret;
>   }
>
>   int mv88e6xxx_switch_reset(struct dsa_switch *ds, bool ppu_active)
>
