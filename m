From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 11/13] net: dsa: lan9303: Added "alr_dump" sysfs port
 attribute
Date: Mon, 24 Jul 2017 09:54:17 -0700
Message-ID: <e5a1cefd-1e26-3a24-2928-3fd7d970d8a6@gmail.com>
References: <f69ce739a3aa42e9b1e03fc699282b3c@nooslMX1.zenitelcss.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Egil Hjelmeland <egil.hjelmeland@zenitel.com>, corbet@lwn.net,
        andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        davem@davemloft.net, kernel@pengutronix.de,
        linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <f69ce739a3aa42e9b1e03fc699282b3c@nooslMX1.zenitelcss.com>
Content-Language: en-US
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/20/2017 01:49 AM, Egil Hjelmeland wrote:
> Added read only file /sys/class/net/<port>/lan9303/alr_dump,
> that output 168 first ALR entires.
> 
> Currently "bridge fdb show" does not include the CPU port, while
> "alr_dump" list all three ports per entry.

Agreed, and this is a limitation we would probably want to remove in the
future, but duplicating what already exists with "bridge fdb show" into
a sysfs node is a non-starter.
> 
> Example output:
> 
> 9c:57:ad:79:d0:84  1  l
> 01:80:c2:00:00:00 0   s
> 00:13:cb:0d:01:95 0   s
> 10:f3:11:f5:6f:cf   2 l
> 48:4d:7e:f4:59:a8   2 l
> 01:00:5e:00:01:0a 0 2 s
> ec:f4:bb:0f:e2:fd   2 l



> 
> Signed-off-by: Egil Hjelmeland <egil.hjelmeland@zenitel.com>
> ---
>  Documentation/networking/dsa/lan9303.txt |  3 ++
>  drivers/net/dsa/lan9303-core.c           | 58 ++++++++++++++++++++++++++++++++
>  2 files changed, 61 insertions(+)
> 
> diff --git a/Documentation/networking/dsa/lan9303.txt b/Documentation/networking/dsa/lan9303.txt
> index 1fd72ff4b492..ace91c821ce7 100644
> --- a/Documentation/networking/dsa/lan9303.txt
> +++ b/Documentation/networking/dsa/lan9303.txt
> @@ -37,6 +37,9 @@ Sysfs nodes
>  When a user port is enabled, the driver creates sysfs directory
>  /sys/class/net/xxx/lan9303 with the following files:
>  
> + - alr_dump (RO): List the 168 first entries of the ALR table.
> +      Including port 0 entires. This file is identical for both ports.
> +      Format: MAC; list of ports; (l)earned / (s)tatic
>   - swe_bcst_throt (RW): Set/get 6.4.7 Broadcast Storm Control
>        Throttle Level for the port. Accesses the corresponding bits of
>        the SWE_BCST_THROT register (13.4.3.23).
> diff --git a/drivers/net/dsa/lan9303-core.c b/drivers/net/dsa/lan9303-core.c
> index ad7a4c72e1fb..b682aa4f1fca 100644
> --- a/drivers/net/dsa/lan9303-core.c
> +++ b/drivers/net/dsa/lan9303-core.c
> @@ -642,6 +642,47 @@ static void alr_loop_cb_fdb_port_dump(
>  	dump_ctx->cb(&fdb->obj);
>  }
>  
> +/* /sys/class/net/xxx/lan9303/alr_dump: display 168 first ALR entires,
> + * including cpu port
> + */
> +struct port_sysfs_dump_ctx {
> +	char *buf;
> +	int pos;
> +};
> +
> +static void alr_loop_cb_sysfs_dump(
> +	struct lan9303 *chip, u32 dat0, u32 dat1, int portmap, void *ctx)
> +{
> +#	define LINE_LEN 24
> +	struct port_sysfs_dump_ctx *dump_ctx = ctx;
> +	char *buf = dump_ctx->buf;
> +	int  pos =  dump_ctx->pos;
> +
> +	u8 mac[ETH_ALEN];
> +	int p;
> +	char ports[LAN9303_NUM_PORTS + 1];
> +	const char trunc_txt[] = "Truncated!\n";
> +
> +	if (pos >= PAGE_SIZE - LINE_LEN - (sizeof(trunc_txt) - 1)) {
> +		if (pos < PAGE_SIZE - LINE_LEN)
> +			pos += sprintf(buf + pos, trunc_txt);
> +		dump_ctx->pos = pos;
> +		return;
> +	}
> +
> +	_alr_reg_to_mac(dat0, dat1, mac);
> +
> +	/* print ports as list of port numbers: */
> +	for (p = 0; p < LAN9303_NUM_PORTS; p++)
> +		ports[p] = (portmap & BIT(p)) ? '0' + p : ' ';
> +	ports[LAN9303_NUM_PORTS] = 0;
> +
> +	pos += sprintf(buf + pos, "%pM %s %s\n",
> +	       mac, ports,
> +	       (dat1 & ALR_DAT1_STATIC) ? "s" : "l");
> +	dump_ctx->pos = pos;
> +}
> +
>  /* ALR: Add/modify/delete ALR entries */
>  
>  /* Set a static ALR entry. Delete entry if port_map is zero */
> @@ -931,8 +972,25 @@ swe_bcst_throt_store(struct device *dev, struct device_attribute *attr,
>  
>  static DEVICE_ATTR_RW(swe_bcst_throt);
>  
> +static ssize_t
> +alr_dump_show(struct device *dev, struct device_attribute *attr,
> +	      char *buf)
> +{
> +	struct dsa_port *dp = dsa_net_device_to_dsa_port(to_net_dev(dev));
> +	struct lan9303 *chip = dp->ds->priv;
> +	struct port_sysfs_dump_ctx dump_ctx = {
> +		.buf = buf,
> +		.pos = 0,
> +	};
> +
> +	lan9303_alr_loop(chip, alr_loop_cb_sysfs_dump, &dump_ctx);
> +	return dump_ctx.pos;
> +}
> +static DEVICE_ATTR_RO(alr_dump);
> +
>  static struct attribute *lan9303_attrs[] = {
>  	&dev_attr_swe_bcst_throt.attr,
> +	&dev_attr_alr_dump.attr,
>  	NULL
>  };
>  
> 


-- 
Florian
