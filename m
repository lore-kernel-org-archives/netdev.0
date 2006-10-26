From: John Heffner <jheffner@psc.edu>
Subject: Re: [RFC] tcp: setsockopt congestion control autoload
Date: Thu, 26 Oct 2006 13:29:26 -0400
Message-ID: <4540F076.70801@psc.edu>
References: <20061025110843.0cbd18a7@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:8391 "EHLO mailer1.psc.edu")
	by vger.kernel.org with ESMTP id S1945906AbWJZR3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2006 13:29:48 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061025110843.0cbd18a7@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

My reservation in doing this would be that as an administrator, I may 
want to choose exactly what congestion control is available any any 
given time.  The different congestion control algorithms are not 
necessarily fair to each other.

If the modules are autoloaded, I could still enforce this by moving the 
modules out of /lib/modules, but I think it's cleaner to do it by 
loading/unloading modules as appropriate.

   -John


Stephen Hemminger wrote:
> If user asks for a congestion control type with setsockopt() then it
> may be available as a module not included in the kernel already. 
> It should be autoloaded if needed.  This is done already when
> the default selection is change with sysctl, but not when application
> requests via sysctl.
> 
> Only reservation is are there any bad security implications from this?
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
> 
> --- orig/net/ipv4/tcp_cong.c	2006-10-25 13:55:34.000000000 -0700
> +++ new/net/ipv4/tcp_cong.c	2006-10-25 13:58:39.000000000 -0700
> @@ -153,9 +153,19 @@
>  
>  	rcu_read_lock();
>  	ca = tcp_ca_find(name);
> +	/* no change asking for existing value */
>  	if (ca == icsk->icsk_ca_ops)
>  		goto out;
>  
> +#ifdef CONFIG_KMOD
> +	/* not found attempt to autoload module */
> +	if (!ca) {
> +		rcu_read_unlock();
> +		request_module("tcp_%s", name);
> +		rcu_read_lock();
> +		ca = tcp_ca_find(name);
> +	}
> +#endif
>  	if (!ca)
>  		err = -ENOENT;
>  
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

