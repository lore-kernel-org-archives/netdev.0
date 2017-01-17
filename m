From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH v4 2/6] virtio_net: wrap rtnl_lock in test for
 calling with lock already held
Date: Tue, 17 Jan 2017 11:57:33 -0500 (EST)
Message-ID: <20170117.115733.428297564258724055.davem@davemloft.net>
References: <20170115235528.28980.85142.stgit@john-Precision-Tower-5810>
        <20170115235947.28980.92147.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, mst@redhat.com, john.r.fastabend@intel.com,
        netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39334 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750741AbdAQRG4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 12:06:56 -0500
In-Reply-To: <20170115235947.28980.92147.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Sun, 15 Jan 2017 15:59:47 -0800

> @@ -2358,7 +2371,10 @@ static void remove_vq_common(struct virtnet_info *vi)
>  	/* Free unused buffers in both send and recv, if any. */
>  	free_unused_bufs(vi);
>  
> -	free_receive_bufs(vi);
> +	if (rtnl_is_locked())
> +		_free_receive_bufs(vi);
> +	else
> +		free_receive_bufs(vi);
>  
>  	free_receive_page_frags(vi);
>  

This doesn't work.  rtnl_is_locked() doesn't tell if _you_ own the mutex, it
just says that someone does.

So if we now execute this code without taking the RTNL lock just because some
other thread of control holds it, we introduce a race.
