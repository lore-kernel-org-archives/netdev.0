From: Eric Lemoine <Eric.Lemoine@sun.com>
Subject: Re: udp weirdness
Date: Mon, 30 Sep 2002 10:49:03 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020930084903.GA359@hookipa>
References: <20020927150412.GI30392@mea-ext.zmailer.org> <Pine.GSO.4.30.0209291044490.8253-200000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shell.cyberus.ca@shell.cyberus.ca, Eric Lemoine <Eric.Lemoine@ens-lyon.fr>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <Pine.GSO.4.30.0209291044490.8253-200000@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Ok, understood. Actually we already seem to have enobufs being returned.
> 
> Eric,
> Does the attached patch fix it? Not tested or even compiled.
> Someone going to change the manpages?

protinfo.af_inet.recverr is a flag (1-bit variable) to enable the
"extended reliable error message passing"; I dont see any reason 
for modifying it here. Setting this flag is the user's responsability, 
isn't it?

My patch would look like this:

--- ip_output.c.old     Mon Sep 30 10:34:07 2002
+++ ip_output.c Mon Sep 30 10:40:08 2002
@@ -604,7 +604,7 @@
                              skb->dst->dev, output_maybe_reroute);
                if (err) {
                        if (err > 0)
-                               err = sk->protinfo.af_inet.recverr ? net_xmit_errno(err) : 0;
+                               err = (err == NET_XMIT_DROP || sk->protinfo.af_inet.recverr ) ? net_xmit_errno(err) : 0;
                        if (err)
                                goto error;
                }
@@ -714,7 +714,7 @@
        err = NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL,
rt->u.dst.dev,
                      output_maybe_reroute);
        if (err > 0)
-               err = sk->protinfo.af_inet.recverr ? net_xmit_errno(err) : 0;
+               err = (err == NET_XMIT_DROP || sk->protinfo.af_inet.recverr ) ? net_xmit_errno(err) : 0;
        if (err)
                goto error;
 out:

> --- linux/net/ipv4/ip_output.c	2002/09/29 10:43:10	1.1
> +++ linux/net/ipv4/ip_output.c	2002/09/29 10:43:10
> @@ -603,8 +603,11 @@
>  		err = NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, 
>  			      skb->dst->dev, output_maybe_reroute);
>  		if (err) {
> -			if (err > 0)
> -				err = sk->protinfo.af_inet.recverr ? net_xmit_errno(err) : 0;
> +			if (err > 0) {
> +				err = net_xmit_errno(err);
> +				if (err && sk->protinfo.af_inet.recverr)
> +				       sk->protinfo.af_inet.recverr = err;
> +			}
>  			if (err)
>  				goto error;
>  		}
> @@ -713,8 +716,11 @@
>  
>  	err = NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
>  		      output_maybe_reroute);
> -	if (err > 0)
> -		err = sk->protinfo.af_inet.recverr ? net_xmit_errno(err) : 0;
> +	if (err > 0) {
> +		err = net_xmit_errno(err);
> +		if (err && sk->protinfo.af_inet.recverr)
> +		       	 sk->protinfo.af_inet.recverr = err;
> +	}
>  	if (err)
>  		goto error;
>  out:
