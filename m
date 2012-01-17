From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: race condition in ipv6 forwarding and
 disable_ipv6 parameters
Date: Tue, 17 Jan 2012 12:44:49 -0500 (EST)
Message-ID: <20120117.124449.1065919030248165158.davem@davemloft.net>
References: <CA+HUmGgLmsHsTUbKb=XB_Ow+BPajpu75B18Um0zRZRkof8rQmw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: fruggeri@aristanetworks.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+HUmGgLmsHsTUbKb=XB_Ow+BPajpu75B18Um0zRZRkof8rQmw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Francesco Ruggeri <fruggeri@aristanetworks.com>
Date: Mon, 16 Jan 2012 12:40:10 -0800

> -static int addrconf_fixup_forwarding(struct ctl_table *table, int *p, int old)
> +static int addrconf_fixup_forwarding(struct ctl_table *table, int *p, int newf)
 ...
> @@ -4257,9 +4259,17 @@ int addrconf_sysctl_forward(ctl_table *c
>  	int *valp = ctl->data;
>  	int val = *valp;
>  	loff_t pos = *ppos;
> +	ctl_table lctl;
>  	int ret;
> 
> -	ret = proc_dointvec(ctl, write, buffer, lenp, ppos);
> +	/*
> +	 * ctl->data points to idev->cnf.forwarding, we should
> +	 * not modify it until we get the rtnl lock.
> +	 */
> +	lctl = *ctl;
> +	lctl.data = &val;
> +
> +	ret = proc_dointvec(&lctl, write, buffer, lenp, ppos);
> 
>  	if (write)
>  		ret = addrconf_fixup_forwarding(ctl, valp, val);

I don't understand this at all.

"val" is still the old value, before proc_dointvec() runs, after your
changes.  So renaming the argument to addrconf_fixup_forwarding() as
"newf" and treating it as the new value doesn't make any sense at all.

Did you really test this patch?
