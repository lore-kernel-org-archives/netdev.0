From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH 3/5] virtio_net: Add XDP support
Date: Fri, 18 Nov 2016 18:16:54 -0800
Message-ID: <582FB616.2060206@gmail.com>
References: <20161118185517.16137.92123.stgit@john-Precision-Tower-5810>
 <20161118190017.16137.13910.stgit@john-Precision-Tower-5810>
 <1479511316.8455.303.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, shm@cumulusnetworks.com,
        alexei.starovoitov@gmail.com, daniel@iogearbox.net,
        davem@davemloft.net, john.r.fastabend@intel.com,
        netdev@vger.kernel.org, bblanco@plumgrid.com, brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:32785 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752176AbcKSCRO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 21:17:14 -0500
Received: by mail-pg0-f66.google.com with SMTP id 3so22156612pgd.0
        for <netdev@vger.kernel.org>; Fri, 18 Nov 2016 18:17:14 -0800 (PST)
In-Reply-To: <1479511316.8455.303.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-11-18 03:21 PM, Eric Dumazet wrote:
> On Fri, 2016-11-18 at 11:00 -0800, John Fastabend wrote:
> 
> 
>>  static void free_receive_bufs(struct virtnet_info *vi)
>>  {
>> +	struct bpf_prog *old_prog;
>>  	int i;
>>  
>>  	for (i = 0; i < vi->max_queue_pairs; i++) {
>>  		while (vi->rq[i].pages)
>>  			__free_pages(get_a_page(&vi->rq[i], GFP_KERNEL), 0);
>> +
>> +		old_prog = rcu_dereference(vi->rq[i].xdp_prog);
> 
> Seems wrong to me.
> 

Yep it is wrong should be rtnl_dereference() here and the
rcu_dereference() calls earlier in the patch need to be _bh().

> Are you sure lockdep (with CONFIG_PROVE_RCU=y) was happy with this ?

oops you are right it was missing.

> 
>> +		RCU_INIT_POINTER(vi->rq[i].xdp_prog, NULL);
>> +		if (old_prog)
>> +			bpf_prog_put(old_prog);

bpf_prog_put() waits a grace period of ref count is zero. That said on
driver unload we need to protect the bpf_prog_put with RTNL_LOCK() as
well.

I'll send out a v2 in a bit.

Thanks a lot.

>>  	}
>>  }
>>  
>>
> 
> 
