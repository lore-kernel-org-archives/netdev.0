From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH 2/2] xdp: adjust xdp redirect tracepoint to include return
 error code
Date: Thu, 17 Aug 2017 11:46:10 -0700
Message-ID: <5995E472.70609@gmail.com>
References: <150298692691.6608.11908184719252996949.stgit@firesoul> <150298695758.6608.7128764985631537683.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:37027 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753212AbdHQSqT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 14:46:19 -0400
Received: by mail-pg0-f68.google.com with SMTP id 83so11154513pgb.4
        for <netdev@vger.kernel.org>; Thu, 17 Aug 2017 11:46:19 -0700 (PDT)
In-Reply-To: <150298695758.6608.7128764985631537683.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/17/2017 09:22 AM, Jesper Dangaard Brouer wrote:
> The return error code need to be included in the tracepoint
> xdp:xdp_redirect, else its not possible to distinguish successful or
> failed XDP_REDIRECT transmits.
> 
> XDP have no queuing mechanism. Thus, it is fairly easily to overrun a
> NIC transmit queue.  The eBPF program invoking helpers (bpf_redirect
> or bpf_redirect_map) to redirect a packet doesn't get any feedback
> whether the packet was actually transmitted.
> 
> Info on failed transmits in the tracepoint xdp:xdp_redirect, is
> interesting as this opens for providing a feedback-loop to the
> receiving XDP program.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> ---

[...]

> @@ -2532,12 +2535,14 @@ int xdp_do_redirect(struct net_device *dev, struct xdp_buff *xdp,
>  	ri->map = NULL;
>  	if (unlikely(!fwd)) {
>  		bpf_warn_invalid_xdp_redirect(index);
> -		return -EINVAL;
> +		err = -EINVAL;
> +		goto out;

It doesn't look like there is a check in trace_xdp_redirect to
avoid dereferencing a NULL fwd pointer here (*to in trace code
path). Did I miss something?

>  	}
>  
> -	trace_xdp_redirect(dev, fwd, xdp_prog, XDP_REDIRECT);
> -
> -	return __bpf_tx_xdp(fwd, NULL, xdp, 0);
> +	err = __bpf_tx_xdp(fwd, NULL, xdp, 0);
> +out:
> +	trace_xdp_redirect(dev, fwd, xdp_prog, XDP_REDIRECT, err);
> +	return err;
>  }
>  EXPORT_SYMBOL_GPL(xdp_do_redirect);
>  
> 
