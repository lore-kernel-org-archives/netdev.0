From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net PATCH v3 2/5] net: virtio: wrap rtnl_lock in test for
 calling with lock already held
Date: Fri, 13 Jan 2017 09:31:46 -0800
Message-ID: <58790F02.8090409@gmail.com>
References: <20170113024908.4535.8835.stgit@john-Precision-Tower-5810>
 <20170113025100.4535.35887.stgit@john-Precision-Tower-5810>
 <20170113083408.202d6e30@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, mst@redhat.com, john.r.fastabend@intel.com,
        netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36124 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750906AbdAMRcM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 12:32:12 -0500
Received: by mail-pf0-f196.google.com with SMTP id b22so9188250pfd.3
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 09:31:59 -0800 (PST)
In-Reply-To: <20170113083408.202d6e30@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-01-13 08:34 AM, Stephen Hemminger wrote:
> On Thu, 12 Jan 2017 18:51:00 -0800
> John Fastabend <john.fastabend@gmail.com> wrote:
> 
>>  
>> -static void free_receive_bufs(struct virtnet_info *vi)
>> +static void free_receive_bufs(struct virtnet_info *vi, bool need_lock)
>>  {
>>  	struct bpf_prog *old_prog;
>>  	int i;
>>  
>> -	rtnl_lock();
>> +	if (need_lock)
>> +		rtnl_lock();
>>  	for (i = 0; i < vi->max_queue_pairs; i++) {
>>  		while (vi->rq[i].pages)
>>  			__free_pages(get_a_page(&vi->rq[i], GFP_KERNEL), 0);
>> @@ -1879,7 +1880,8 @@ static void free_receive_bufs(struct virtnet_info *vi)
>>  		if (old_prog)
>>  			bpf_prog_put(old_prog);
>>  	}
>> -	rtnl_unlock();
>> +	if (need_lock)
>> +		rtnl_unlock();
>>  }
> 
> Conditional locking is bad idea; sparse complains about it and is later source
> of bugs. The more typical way of doing this in kernel is:

OK I'll use the normal form.

> 
> void _foo(some args)
> {
> 	ASSERT_RTNL();
> 
> 	...
> }
> 
> void foo(some args)
> {
> 	rtnl_lock();
> 	_foo(some args)
> 	rtnl_unlock();
> }
> 
> 
