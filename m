From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next] xen-netback: Grant copy the header instead of
 map and memcpy
Date: Thu, 27 Mar 2014 14:26:24 +0000
Message-ID: <53343510.9040306@citrix.com>
References: <1395868707-22683-1-git-send-email-zoltan.kiss@citrix.com>	 <1395920136.22909.76.camel@kazak.uk.xensource.com>	 <53341DA8.9010102@citrix.com> <1395924899.22909.120.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	<paul.durrant@citrix.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1395924899.22909.120.camel@kazak.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 27/03/14 12:54, Ian Campbell wrote:
> On Thu, 2014-03-27 at 12:46 +0000, Zoltan Kiss wrote:
>> On 27/03/14 11:35, Ian Campbell wrote:
>>> On Wed, 2014-03-26 at 21:18 +0000, Zoltan Kiss wrote:
>>>> An old inefficiency of the TX path that we are grant mapping the first slot,
>>>> and then copy the header part to the linear area. Instead, doing a grant copy
>>>> for that header straight on is more reasonable. Especially because there are
>>>> ongoing efforts to make Xen avoiding TLB flush after unmap when the page were
>>>> not touched in Dom0. In the original way the memcpy ruined that.
>>>> The key changes:
>>>> - the vif has a tx_copy_ops array again
>>>> - xenvif_tx_build_gops sets up the grant copy operations
>>>> - we don't have to figure out whether the header and first frag are on the same
>>>>     grant mapped page or not
>>>>
>>>> Unrelated, but I've made a small refactoring in xenvif_get_extras as well.
>>>
>>> Just a few thoughts, not really based on close review of the code.
>>>
>>> Do you have any measurements for this series or workloads where it is
>>> particularly beneficial?
>> My manual measurements showed that if I also use the Xen patch which
>> avoids TLB flush when the pages were not touched, I can easily get 9 -
>> 9.3 Gbps with iperf. But I'll run some more automated tests.
>
> I suppose these numbers are related because avoiding the memcpy avoids
> touching the page?
Yes

>>> Or (and I confess this is a skanky hack): we overlay tx_copy_ops and
>>> tx_map_ops in a union, and insert one set of ops from the front and the
>>> other from the end, taking great care around when and where they meet.
>> Unfortunately the hypercalls expect an array of _one_ of them, so we
>> can't put the 2 types into an union unless it's guaranteed that they
>> have the same size. And they are expected to be
>
> (was there more of this last sentence?)
>
> I was thinking
> 	union {
> 		struct gnt_map maps[NR_...];
> 		struct gnt_copy copy[NR_...];
> 	}
>
> Then you fill copy from 0..N and maps from M..NR_ and maintain the
> invariant that
>           (&maps[M] - &map[s0]) > &copy[N]
>
> and pass to the grant ops (&copy[0], N) and (&maps[M], NR_... - M)
> respectively.
>
> Too tricksy perhaps?

Yeah, this array is 30*256 bytes (7.5 kb) long, per vif, I don't think 
it worth the fuss.

>>>
>>>> +		vif->tx_copy_ops[*copy_ops].source.u.ref = txreq.gref;
>>>> +		vif->tx_copy_ops[*copy_ops].source.domid = vif->domid;
>>>> +		vif->tx_copy_ops[*copy_ops].source.offset = txreq.offset;
>>>> +
>>>> +		vif->tx_copy_ops[*copy_ops].dest.u.gmfn = virt_to_mfn(skb->data);
>>>> +		vif->tx_copy_ops[*copy_ops].dest.domid = DOMID_SELF;
>>>> +		vif->tx_copy_ops[*copy_ops].dest.offset = offset_in_page(skb->data);
>>>> +
>>>> +		vif->tx_copy_ops[*copy_ops].len = data_len;
>>>
>>> Do we want to copy the entire first frag even if it is e.g. a complete
>>> page?
>>>
>>> I'm not sure where the tradeoff lies between doing a grant copy of more
>>> than necessary and doing a map+memcpy when the map is already required
>>> for the page frag anyway.
>> I think we should only grant copy the parts which goes to the linear
>> part, because we would memcpy it anyway. It's expected that the stack
>> won't touch anything else while the packet passes through. data_len is
>> the size of the linear buffer here.
>>>
>>> What about the case where the first frag is less than PKT_PROT_LEN? I
>>> think you still do map+memcpy in that case?
>> Then data_len will be txreq.size, we allocate the skb for that, and
>> later on we call __pskb_pull_tail in xenvif_tx_submit to pull up for
>> that (which is essentially map+memcpy). It's not optimal, but it's like
>> that since the good old days. I agree it could be optimized, but let's
>> change it in a different patch!
>
> OK. Can you clarify the title and/or the commit log to make it obvious
> that we only copy (some portion of) the first frag and that we still map
> +memcpy the remainder of PKT_PROT_LEN if the first frag is not large
> enough.
Ok
