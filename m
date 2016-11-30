From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net-next PATCH v3 6/6] virtio_net: xdp, add slowpath case for
 non contiguous buffers
Date: Tue, 29 Nov 2016 16:37:57 -0800
Message-ID: <20161130003756.GD28238@ast-mbp.thefacebook.com>
References: <20161129200933.26851.41883.stgit@john-Precision-Tower-5810>
 <20161129201133.26851.31803.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, daniel@iogearbox.net,
        shm@cumulusnetworks.com, davem@davemloft.net, tgraf@suug.ch,
        john.r.fastabend@intel.com, netdev@vger.kernel.org,
        bblanco@plumgrid.com, brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33279 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752099AbcK3AiY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 19:38:24 -0500
Received: by mail-pg0-f68.google.com with SMTP id 3so17864828pgd.0
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 16:38:04 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20161129201133.26851.31803.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 29, 2016 at 12:11:33PM -0800, John Fastabend wrote:
> virtio_net XDP support expects receive buffers to be contiguous.
> If this is not the case we enable a slowpath to allow connectivity
> to continue but at a significan performance overhead associated with
> linearizing data. To make it painfully aware to users that XDP is
> running in a degraded mode we throw an xdp buffer error.
> 
> To linearize packets we allocate a page and copy the segments of
> the data, including the header, into it. After this the page can be
> handled by XDP code flow as normal.
> 
> Then depending on the return code the page is either freed or sent
> to the XDP xmit path. There is no attempt to optimize this path.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
...
> +/* The conditions to enable XDP should preclude the underlying device from
> + * sending packets across multiple buffers (num_buf > 1). However per spec
> + * it does not appear to be illegal to do so but rather just against convention.
> + * So in order to avoid making a system unresponsive the packets are pushed
> + * into a page and the XDP program is run. This will be extremely slow and we
> + * push a warning to the user to fix this as soon as possible. Fixing this may
> + * require resolving the underlying hardware to determine why multiple buffers
> + * are being received or simply loading the XDP program in the ingress stack
> + * after the skb is built because there is no advantage to running it here
> + * anymore.
> + */
...
>  		if (num_buf > 1) {
>  			bpf_warn_invalid_xdp_buffer();
> -			goto err_xdp;
> +
> +			/* linearize data for XDP */
> +			xdp_page = xdp_linearize_page(rq, num_buf,
> +						      page, offset, &len);
> +			if (!xdp_page)
> +				goto err_xdp;

in case when we're 'lucky' the performance will silently be bad.
Can we do warn_once here? so at least something in dmesg points out
that performance is not as expected. Am I reading it correctly that
you had to do a special kernel hack to trigger this situation and
in all normal cases it's not the case?
