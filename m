From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [net PATCH v3 2/5] net: virtio: wrap rtnl_lock in test for
 calling with lock already held
Date: Fri, 13 Jan 2017 08:34:08 -0800
Message-ID: <20170113083408.202d6e30@xeon-e3>
References: <20170113024908.4535.8835.stgit@john-Precision-Tower-5810>
        <20170113025100.4535.35887.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, mst@redhat.com, john.r.fastabend@intel.com,
        netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:36337 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751261AbdAMQfK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 11:35:10 -0500
Received: by mail-pf0-f169.google.com with SMTP id 189so33610970pfu.3
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 08:34:17 -0800 (PST)
In-Reply-To: <20170113025100.4535.35887.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 Jan 2017 18:51:00 -0800
John Fastabend <john.fastabend@gmail.com> wrote:

>  
> -static void free_receive_bufs(struct virtnet_info *vi)
> +static void free_receive_bufs(struct virtnet_info *vi, bool need_lock)
>  {
>  	struct bpf_prog *old_prog;
>  	int i;
>  
> -	rtnl_lock();
> +	if (need_lock)
> +		rtnl_lock();
>  	for (i = 0; i < vi->max_queue_pairs; i++) {
>  		while (vi->rq[i].pages)
>  			__free_pages(get_a_page(&vi->rq[i], GFP_KERNEL), 0);
> @@ -1879,7 +1880,8 @@ static void free_receive_bufs(struct virtnet_info *vi)
>  		if (old_prog)
>  			bpf_prog_put(old_prog);
>  	}
> -	rtnl_unlock();
> +	if (need_lock)
> +		rtnl_unlock();
>  }

Conditional locking is bad idea; sparse complains about it and is later source
of bugs. The more typical way of doing this in kernel is:

void _foo(some args)
{
	ASSERT_RTNL();

	...
}

void foo(some args)
{
	rtnl_lock();
	_foo(some args)
	rtnl_unlock();
}
