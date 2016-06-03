From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 15/17] net: dsa: Add new binding implementation
Date: Fri, 3 Jun 2016 14:19:48 -0700
Message-ID: <5751F474.3050109@gmail.com>
References: <1464972256-10408-1-git-send-email-andrew@lunn.ch>
 <1464972256-10408-16-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:33877 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752857AbcFCVTw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 17:19:52 -0400
Received: by mail-pa0-f68.google.com with SMTP id x1so6722011pav.1
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 14:19:52 -0700 (PDT)
In-Reply-To: <1464972256-10408-16-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/03/2016 09:44 AM, Andrew Lunn wrote:
> The existing DSA binding has a number of limitations and problems. The
> main problem is that it cannot represent a switch as a linux device,
> hanging off some bus. It is limited to one CPU port. The DSA platform
> device is artificial, and does not really represent hardware.
> 
> Implement a new binding which can be embedded into any type of node on
> a bus to represent one switch device, and its links to other switches.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Just a few nits that I had not seen before...


> diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
> index 6c314f300424..d8cb2acd4f0a 100644
> --- a/net/dsa/dsa.c
> +++ b/net/dsa/dsa.c
> @@ -294,6 +294,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
>  			}
>  			dst->cpu_switch = index;
>  			dst->cpu_port = i;
> +			ds->cpu_port_mask |= 1 << i;
>  		} else if (!strcmp(name, "dsa")) {
>  			ds->dsa_port_mask |= 1 << i;
>  		} else {

We might want to undo setting the cpu_port_mask bit in
dsa_cpu_dsa_destroy()?

[snip]

> +static int dsa_ds_complete(struct dsa_switch_tree *dst, struct dsa_switch *ds)
> +{
> +	struct device_node *port;
> +	u32 index;
> +	int err;
> +
> +	for (index = 0; index < DSA_MAX_PORTS; index++) {
> +		port = ds->ports[index].dn;
> +		if (!port)
> +			continue;
> +
> +		if (!dsa_port_is_dsa(port))
> +			continue;
> +
> +		ds->dsa_port_mask |= 1 << index;
> +
> +		err = dsa_port_complete(dst, ds, port, index);
> +		if (err != 0)

Should we move ds->dsa_port_mask |= 1 << index into dsa_port_complete,
for a) symetry with code undoing this, and b) avoid letting this bit be
set in case dsa_port_complete() returns an error?
-- 
Florian
