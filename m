From: Eric Lemoine <Eric.Lemoine@sun.com>
Subject: Re: PATCH Re: udp weirdness
Date: Tue, 1 Oct 2002 08:35:57 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021001063557.GA331@hookipa>
References: <Pine.GSO.4.30.0209300822150.11444-100000@shell.cyberus.ca> <Pine.GSO.4.30.0209302017330.16713-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Lemoine <Eric.Lemoine@sun.com>,
   Eric Lemoine <Eric.Lemoine@ens-lyon.fr>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <Pine.GSO.4.30.0209302017330.16713-100000@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Eric,
> 
> you are right about sk->protinfo.af_inet.recverr ..
> I checked what other OSes do and i am convinced that the patch below
> at least makes us behave like the BSDs.
> Alexey/Dave, sk->protinfo.af_inet.recverr is not needed for enobufs to
> be propagated back to the socket level; please review and probably
> apply:

Jamal, 

Have you posted the right patch? I see that sk->protinfo.af_inet.recverr is
still around. Here follows the patch that I think is the correct one.
Please confirm. Thx.

--- ip_output.c.old     Mon Sep 30 10:34:07 2002
+++ ip_output.c Tue Oct  1 00:00:05 2002
@@ -604,7 +604,7 @@
                              skb->dst->dev, output_maybe_reroute);
                if (err) {
                        if (err > 0)
-                               err = sk->protinfo.af_inet.recverr ? net_xmit_errno(err) : 0;
+                               err = net_xmit_errno(err);
                        if (err)
                                goto error;
                }
@@ -714,7 +714,7 @@
        err = NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL,
rt->u.dst.dev,
                      output_maybe_reroute);
        if (err > 0)
-               err = sk->protinfo.af_inet.recverr ? net_xmit_errno(err) : 0;
+               err = net_xmit_errno(err);
        if (err)
                goto error;
 out:

> --- ip_output.c	2002/09/29 08:50:36	1.1
> +++ ip_output.c	2002/09/30 06:24:32
> @@ -603,8 +603,11 @@
>  		err = NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL,
>  			      skb->dst->dev, output_maybe_reroute);
>  		if (err) {
> -			if (err > 0)
> -				err = sk->protinfo.af_inet.recverr ? net_xmit_errno(err) : 0;
> +			if (err > 0) {
> +				err = net_xmit_errno(err);
> +				if (!err && sk->protinfo.af_inet.recverr)
> +				       err = sk->protinfo.af_inet.recverr;
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
> +		if (!err && sk->protinfo.af_inet.recverr)
> +		       	 err = sk->protinfo.af_inet.recverr;
> +	}
>  	if (err)
>  		goto error;
>  out:

-- 
Eric
