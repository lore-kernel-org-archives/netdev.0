From: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH 1/6] net: ethernet: ti: netcp: add support of cpts
Date: Wed, 30 Nov 2016 11:31:56 -0600
Message-ID: <4d69aff4-70a0-e6b8-38b0-8e95cfea7601@ti.com>
References: <20161128230428.6872-1-grygorii.strashko@ti.com>
 <20161128230428.6872-2-grygorii.strashko@ti.com>
 <20161130094441.GB28680@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>,
        Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Murali Karicheri <m-karicheri2-l0cyMroinI0@public.gmane.org>,
        Wingman Kwok <w-kwok2-l0cyMroinI0@public.gmane.org>
To: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161130094441.GB28680-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 11/30/2016 03:44 AM, Richard Cochran wrote:
> On Mon, Nov 28, 2016 at 05:04:23PM -0600, Grygorii Strashko wrote:
>> @@ -678,6 +744,9 @@ struct gbe_priv {
>>  	int				num_et_stats;
>>  	/*  Lock for updating the hwstats */
>>  	spinlock_t			hw_stats_lock;
>> +
>> +	int                             cpts_registered;
> 
> The usage of this counter is racy.
> 
>> +	struct cpts                     *cpts;
>>  };
> 
> This ++ and -- business ...
> 
>> +static void gbe_register_cpts(struct gbe_priv *gbe_dev)
>> +{
>> +	if (!gbe_dev->cpts)
>> +		return;
>> +
>> +	if (gbe_dev->cpts_registered > 0)
>> +		goto done;
>> +
>> +	if (cpts_register(gbe_dev->cpts)) {
>> +		dev_err(gbe_dev->dev, "error registering cpts device\n");
>> +		return;
>> +	}
>> +
>> +done:
>> +	++gbe_dev->cpts_registered;
>> +}
>> +
>> +static void gbe_unregister_cpts(struct gbe_priv *gbe_dev)
>> +{
>> +	if (!gbe_dev->cpts || (gbe_dev->cpts_registered <= 0))
>> +		return;
>> +
>> +	if (--gbe_dev->cpts_registered)
>> +		return;
>> +
>> +	cpts_unregister(gbe_dev->cpts);
>> +}
> 
> is invoked from your open() and close() methods, but those methods
> are not serialized among multiple ports.
> 

ok. Seems my assumption that ndo_open/ndo_close serialized by rtnl_lock is incorrect. Right?
net_device_ops.ndo_open ->
 netcp_ndo_open
 gbe_open
 gbe_register_cpts

-- 
regards,
-grygorii
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
