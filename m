From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] tc: bpf: generalize pedit action
Date: Fri, 27 Mar 2015 09:01:11 -0700
Message-ID: <55157EC7.9030700@plumgrid.com>
References: <1427424837-7757-1-git-send-email-ast@plumgrid.com> <55153425.2070502@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, Jamal Hadi Salim <jhs@mojatatu.com>,
	linux-api@vger.kernel.org, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:34890 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752756AbbC0QBP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2015 12:01:15 -0400
Received: by ierf6 with SMTP id f6so7002502ier.2
        for <netdev@vger.kernel.org>; Fri, 27 Mar 2015 09:01:15 -0700 (PDT)
In-Reply-To: <55153425.2070502@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/27/15 3:42 AM, Daniel Borkmann wrote:
> On 03/27/2015 03:53 AM, Alexei Starovoitov wrote:
>> existing TC action 'pedit' can munge any bits of the packet.
>> Generalize it for use in bpf programs attached as cls_bpf and act_bpf via
>> bpf_skb_store_bytes() helper function.
>>
>> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
>
> I like it.
>
>> pedit is limited to 32-bit masked rewrites. Here let it be flexible.
>>
>> ptr = skb_header_pointer(skb, offset, len, buf);
>> memcpy(ptr, from, len);
>> if (ptr == buf)
>>    skb_store_bits(skb, offset, ptr, len);
>>
>> ^^ logic is the same as in pedit.
>> shifts, mask, invert style of rewrite is easily done by the program.
>> Just like arbitrary parsing of the packet and applying rewrites on
>> demand.
> ...
>> +static u64 bpf_skb_store_bytes(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
>> +{
>> +    struct sk_buff *skb = (struct sk_buff *) (long) r1;
>> +    unsigned int offset = (unsigned int) r2;
>> +    void *from = (void *) (long) r3;
>> +    unsigned int len = (unsigned int) r4;
>> +    char buf[16];
>> +    void *ptr;
>> +
>> +    /* bpf verifier guarantees that:
>> +     * 'from' pointer points to bpf program stack
>> +     * 'len' bytes of it were initialized
>> +     * 'len' > 0
>> +     * 'skb' is a valid pointer to 'struct sk_buff'
>> +     *
>> +     * so check for invalid 'offset' and too large 'len'
>> +     */
>> +    if (offset > 0xffff || len > sizeof(buf))
>> +        return -EFAULT;
>
> Could you elaborate on the hard-coded 0xffff? Hm, perhaps better u16, or
> do you see any issues with wrong widening?

0xffff is the maximum packet size, of course.
Beyond basic sanity the above two conditions check for overflow
of offset+len automatically.
u16 won't work, since all the following functions are taking 'int' or
'unsigned int'. These checks are done first to make there are no wrap
arounds or other subtleties. Especially since skb_copy_bits is quite
complex inside.

> This check should probably be also unlikely().

I thought about it as well, but decided against it, since we don't
use likley/unlikely in skb_header_pointer, skb_copy_bits and others.
Better to be consistent.

> Ok, the sizeof(buf) could still be increased in future if truly necessary.

yes. correct.
I've decided to go small first and extend if necessary.

>> +    if (skb_cloned(skb) && !skb_clone_writable(skb, offset + len))
>> +        return -EFAULT;
>> +
>> +    ptr = skb_header_pointer(skb, offset, len, buf);
>> +    if (unlikely(!ptr))
>> +        return -EFAULT;
>> +
>> +    skb_postpull_rcsum(skb, ptr, len);
>> +
>> +    memcpy(ptr, from, len);
>> +
>> +    if (ptr == buf)
>> +        /* skb_store_bits cannot return -EFAULT here */
>> +        skb_store_bits(skb, offset, ptr, len);
>> +
>> +    if (skb->ip_summed == CHECKSUM_COMPLETE)
>> +        skb->csum = csum_add(skb->csum, csum_partial(ptr, len, 0));
>
> For egress, I think that CHECKSUM_PARTIAL does not need to be dealt
> with since the skb length doesn't change. Do you see an issue when
> cls_bpf/act_bpf would be attached to the ingress qdisc?

Well, this patch is packet writer only.
The checksum helpers and support for CHECKSUM_PARTIAL (similar to 
TP_STATUS_CSUMNOTREADY) are coming in the future patches.
They should be independent. Otherwise this simple writer function
would need to special case different offsets and tons of other
checks. Keep it simple principle.

> I was also thinking if it's worth it to split off the csum correction
> as a separate function if there are not too big performance implications?

yep. performance will suffer if we split it. Better to leave it as-is.

> That way, an action may also allow to intentionally test corruption of
> a part of the skb data together with the recent prandom function.

This writer can do that already, but it keeps skb->csum correct.
If you suggestion is to test corruption of skb->csum, then I don't
see why we would want that.
