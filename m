From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net v5] bpf: add helper to compare network namespaces
Date: Fri, 24 Feb 2017 03:55:33 +1300
Message-ID: <87r32pufbu.fsf@xmission.com>
References: <1487208564-4666-1-git-send-email-dsa@cumulusnetworks.com>
        <58A57A13.9070906@iogearbox.net> <878tp1h4xs.fsf@xmission.com>
        <1a4f1938-6f2a-2c75-d45a-41c46baac039@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        davem@davemloft.net, ast@kernel.org, tj@kernel.org,
        luto@amacapital.net
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:36581 "EHLO
        out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751110AbdBWPVd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2017 10:21:33 -0500
In-Reply-To: <1a4f1938-6f2a-2c75-d45a-41c46baac039@cumulusnetworks.com> (David
        Ahern's message of "Wed, 22 Feb 2017 20:28:47 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Ahern <dsa@cumulusnetworks.com> writes:

> On 2/19/17 9:17 PM, Eric W. Biederman wrote:
>>>> @@ -2597,6 +2598,39 @@ static const struct bpf_func_proto bpf_xdp_event_output_proto = {
>>>>   	.arg5_type	= ARG_CONST_STACK_SIZE,
>>>>   };
>>>>
>>>> +BPF_CALL_3(bpf_sk_netns_cmp, struct sock *, sk,  u64, ns_dev, u64, ns_ino)
>>>> +{
>>>> +	return netns_cmp(sock_net(sk), ns_dev, ns_ino);
>>>> +}
>>>
>>> Is there anything that speaks against doing the comparison itself
>>> outside of the helper? Meaning, the helper would get a buffer
>>> passed from stack f.e. struct foo { u64 ns_dev; u64 ns_ino; }
>>> and fills both out with the netns info belonging to the sk/skb.
>> 
>> Yes.  The dev/ino pair is not necessarily unique so it is not at all
>> clear that the returned value would be what the program is expecting.
>
> How does the comparison inside a helper change the fact that a dev and
> inode number are compared? ie., inside or outside of a helper, the end
> result is that a bpf program has a dev/inode pair that is compared to
> that of a socket or skb.

With the comparison inside a helper if the kernel has more than one
dev+inode that maps to the same network namespace (as we had just
recently until the inodes were moved from proc to nsfs) then the helper
can lookup the the dev+inode and see which network namespace it maps
to and then compare network namespaces.  So logically the helper really
is doing more than more than comparing dev+inode.

With the helper doing the comparison the kernel implementation details
can change and everything will continue to work.

> Ideally, it would be nice to have a bpf equivalent to net_eq(), but it
> is not possible from a practical perspective to have bpf programs load a
> namespace reference (address really) from a given pid or fd.

Which is why I am not at all keen on support for maps etc.  It is not
clear how to do something more elegant.

If there was an environmental restriction on the bpf program where we
knew all references had to be from the perspective of the initial set of
namespaces there would be a unique dev+inode we could deal with.  But
again that obvious solution that works so often elsewhere appears to be
a non-starter here.

Eric
