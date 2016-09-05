From: Daniel Mack <daniel@zonque.org>
Subject: Re: [PATCH v3 3/6] bpf: add BPF_PROG_ATTACH and BPF_PROG_DETACH
 commands
Date: Mon, 5 Sep 2016 16:09:38 +0200
Message-ID: <7f69d0ee-df6e-0d30-7198-16a978e53068@zonque.org>
References: <1472241532-11682-1-git-send-email-daniel@zonque.org>
 <1472241532-11682-4-git-send-email-daniel@zonque.org>
 <57C4BE77.8070309@iogearbox.net>
 <9894ace9-06f7-4c41-e8fe-6047adad740e@zonque.org>
 <57CD798D.4040604@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, kafai@fb.com, fw@strlen.de,
        pablo@netfilter.org, harald@redhat.com, netdev@vger.kernel.org,
        sargun@sargun.me
To: Daniel Borkmann <daniel@iogearbox.net>, htejun@fb.com, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:57561 "EHLO mail.zonque.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932448AbcIEOJm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Sep 2016 10:09:42 -0400
In-Reply-To: <57CD798D.4040604@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/05/2016 03:56 PM, Daniel Borkmann wrote:
> On 09/05/2016 02:54 PM, Daniel Mack wrote:
>> On 08/30/2016 01:00 AM, Daniel Borkmann wrote:
>>> On 08/26/2016 09:58 PM, Daniel Mack wrote:
>>
>>>>    enum bpf_map_type {
>>>> @@ -147,6 +149,13 @@ union bpf_attr {
>>>>    		__aligned_u64	pathname;
>>>>    		__u32		bpf_fd;
>>>>    	};
>>>> +
>>>> +	struct { /* anonymous struct used by BPF_PROG_ATTACH/DETACH commands */
>>>> +		__u32		target_fd;	/* container object to attach to */
>>>> +		__u32		attach_bpf_fd;	/* eBPF program to attach */
>>>> +		__u32		attach_type;	/* BPF_ATTACH_TYPE_* */
>>>> +		__u64		attach_flags;
>>>
>>> Could we just do ...
>>>
>>> __u32 dst_fd;
>>> __u32 src_fd;
>>> __u32 attach_type;
>>>
>>> ... and leave flags out, since unused anyway? Also see below.
>>
>> I'd really like to keep the flags, even if they're unused right now.
>> This only adds 8 bytes during the syscall operation, so it doesn't harm.
>> However, we cannot change the userspace API after the fact, and who
>> knows what this (rather generic) interface will be used for later on.
> 
> With the below suggestion added, then flags doesn't need to be
> added currently as it can be done safely at a later point in time
> with respecting old binaries. See also the syscall handling code
> in kernel/bpf/syscall.c +825 and the CHECK_ATTR() macro. The
> underlying idea of this was taken from perf_event_open() syscall
> back then, see [1] for a summary.
> 
>    [1] https://lkml.org/lkml/2014/8/26/116

Yes, I know that's possible, and I like the idea, but I don't think any
new interface should come without flags really, as flags are something
that will most certainly be needed at some point anyway. I didn't have
them in my first shot, but Alexei pointed out that they should be added,
and I agree.

Also, this optimization wouldn't make the transported struct payload any
smaller anyway, because the member of that union used by BPF_PROG_LOAD
is still by far the biggest.

I really don't think it's worth sparing 8 bytes here and then do the
binary compat dance after flags are added, for no real gain.



Thanks,
Daniel
