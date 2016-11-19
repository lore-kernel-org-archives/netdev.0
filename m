From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH 4/5] virtio_net: add dedicated XDP transmit queues
Date: Fri, 18 Nov 2016 18:43:55 -0800
Message-ID: <582FBC6B.8000902@gmail.com>
References: <20161118185517.16137.92123.stgit@john-Precision-Tower-5810>
 <20161118190041.16137.48399.stgit@john-Precision-Tower-5810>
 <20161118130953.7bf2d71d@laptop> <20161118181004.4c15a6a1@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, shm@cumulusnetworks.com,
        alexei.starovoitov@gmail.com, daniel@iogearbox.net,
        davem@davemloft.net, john.r.fastabend@intel.com,
        netdev@vger.kernel.org, bblanco@plumgrid.com, brouer@redhat.com
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36299 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752183AbcKSCoR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 21:44:17 -0500
Received: by mail-pg0-f67.google.com with SMTP id x23so22198994pgx.3
        for <netdev@vger.kernel.org>; Fri, 18 Nov 2016 18:44:17 -0800 (PST)
In-Reply-To: <20161118181004.4c15a6a1@laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-11-18 06:10 PM, Jakub Kicinski wrote:
> On Fri, 18 Nov 2016 13:09:53 -0800, Jakub Kicinski wrote:
>> Looks very cool! :)
>>
>> On Fri, 18 Nov 2016 11:00:41 -0800, John Fastabend wrote:
>>> @@ -1542,12 +1546,34 @@ static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
>>>  		return -EINVAL;
>>>  	}
>>>  
>>> +	curr_qp = vi->curr_queue_pairs - vi->xdp_queue_pairs;
>>> +	if (prog)
>>> +		xdp_qp = num_online_cpus();  
>>
>> Is num_online_cpus() correct here?
> 
> Sorry, I don't know the virto_net code, so I'm probably wrong.  I was
> concerned whether the number of cpus can change but also that the cpu
> mask may be sparse and therefore offsetting by smp_processor_id()
> into the queue table below could bring trouble.
> 

Seem like a valid concerns to me how about num_possible_cpus() instead.

> @@ -353,9 +381,15 @@ static u32 do_xdp_prog(struct virtnet_info *vi,
>  	switch (act) {
>  	case XDP_PASS:
>  		return XDP_PASS;
> +	case XDP_TX:
> +		qp = vi->curr_queue_pairs -
> +			vi->xdp_queue_pairs +
> +			smp_processor_id();
> +		xdp.data = buf + (vi->mergeable_rx_bufs ? 0 : 4);
> +		virtnet_xdp_xmit(vi, qp, &xdp);
> +		return XDP_TX;
>  	default:
>  		bpf_warn_invalid_xdp_action(act);
> -	case XDP_TX:
>  	case XDP_ABORTED:
>  	case XDP_DROP:
>  		return XDP_DROP;
> 
