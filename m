From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net PATCH v3 2/5] net: virtio: wrap rtnl_lock in test for
 calling with lock already held
Date: Fri, 13 Jan 2017 15:56:06 -0800
Message-ID: <58796916.4020404@gmail.com>
References: <20170113024908.4535.8835.stgit@john-Precision-Tower-5810>
 <20170113025100.4535.35887.stgit@john-Precision-Tower-5810>
 <20170113083408.202d6e30@xeon-e3> <58790F02.8090409@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, mst@redhat.com, john.r.fastabend@intel.com,
        netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33862 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750729AbdAMX4m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 18:56:42 -0500
Received: by mail-pf0-f196.google.com with SMTP id y143so10260465pfb.1
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 15:56:28 -0800 (PST)
In-Reply-To: <58790F02.8090409@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-01-13 09:31 AM, John Fastabend wrote:
> On 17-01-13 08:34 AM, Stephen Hemminger wrote:
>> On Thu, 12 Jan 2017 18:51:00 -0800
>> John Fastabend <john.fastabend@gmail.com> wrote:
>>
>>>  
>>> -static void free_receive_bufs(struct virtnet_info *vi)
>>> +static void free_receive_bufs(struct virtnet_info *vi, bool need_lock)
>>>  {
>>>  	struct bpf_prog *old_prog;
>>>  	int i;
>>>  
>>> -	rtnl_lock();
>>> +	if (need_lock)
>>> +		rtnl_lock();
>>>  	for (i = 0; i < vi->max_queue_pairs; i++) {
>>>  		while (vi->rq[i].pages)
>>>  			__free_pages(get_a_page(&vi->rq[i], GFP_KERNEL), 0);
>>> @@ -1879,7 +1880,8 @@ static void free_receive_bufs(struct virtnet_info *vi)
>>>  		if (old_prog)
>>>  			bpf_prog_put(old_prog);
>>>  	}
>>> -	rtnl_unlock();
>>> +	if (need_lock)
>>> +		rtnl_unlock();
>>>  }
>>
>> Conditional locking is bad idea; sparse complains about it and is later source
>> of bugs. The more typical way of doing this in kernel is:
> 
> OK I'll use the normal form.
> 
>>
>> void _foo(some args)
>> {
>> 	ASSERT_RTNL();
>>
>> 	...
>> }
>>
>> void foo(some args)
>> {
>> 	rtnl_lock();
>> 	_foo(some args)
>> 	rtnl_unlock();
>> }
>>
>>
> 

Actually doing this without a rtnl_try_lock() is going to create two more
callbacks in virtio core just for virtio_net. All the other users do not
appear to have locking restrictions. How about the following it at least
helps in that there is no argument passing and if/else on the locks itself
but does use the if around rtnl_try_lock().

--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1864,12 +1864,11 @@ static void virtnet_free_queues(struct virtnet_info *vi)
        kfree(vi->sq);
 }

-static void free_receive_bufs(struct virtnet_info *vi)
+static void _free_receive_bufs(struct virtnet_info *vi)
 {
        struct bpf_prog *old_prog;
        int i;

-       rtnl_lock();
        for (i = 0; i < vi->max_queue_pairs; i++) {
                while (vi->rq[i].pages)
                        __free_pages(get_a_page(&vi->rq[i], GFP_KERNEL), 0);
@@ -1879,6 +1878,12 @@ static void free_receive_bufs(struct virtnet_info *vi)
                if (old_prog)
                        bpf_prog_put(old_prog);
        }
+}
+
+static void free_receive_bufs(struct virtnet_info *vi)
+{
+       rtnl_lock();
+       _free_receive_bufs(vi);
        rtnl_unlock();
 }

@@ -2358,7 +2363,10 @@ static void remove_vq_common(struct virtnet_info *vi)
        /* Free unused buffers in both send and recv, if any. */
        free_unused_bufs(vi);

-       free_receive_bufs(vi);
+       if (rtnl_is_locked());
+               _free_receive_bufs(vi);
+       else
+               free_receive_bufs(vi);

        free_receive_page_frags(vi);
