From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC PATCH v2 1/5] bpf: add PHYS_DEV prog type for early driver
 filter
Date: Fri, 08 Apr 2016 13:09:30 +0200
Message-ID: <5707916A.2030305@iogearbox.net>
References: <1460090930-11219-1-git-send-email-bblanco@plumgrid.com> <20160408123614.2a15a346@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, tom@herbertland.com,
	alexei.starovoitov@gmail.com, ogerlitz@mellanox.com,
	eric.dumazet@gmail.com, ecree@solarflare.com,
	john.fastabend@gmail.com, tgraf@suug.ch, johannes@sipsolutions.net,
	eranlinuxmellanox@gmail.com, lorenzo@google.com
To: Jesper Dangaard Brouer <brouer@redhat.com>,
	Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33586 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757973AbcDHLJo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 07:09:44 -0400
In-Reply-To: <20160408123614.2a15a346@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/08/2016 12:36 PM, Jesper Dangaard Brouer wrote:
> On Thu,  7 Apr 2016 21:48:46 -0700
> Brenden Blanco <bblanco@plumgrid.com> wrote:
>
>> Add a new bpf prog type that is intended to run in early stages of the
>> packet rx path. Only minimal packet metadata will be available, hence a
>> new context type, struct bpf_phys_dev_md, is exposed to userspace. So
>> far only expose the readable packet length, and only in read mode.
>>
>> The PHYS_DEV name is chosen to represent that the program is meant only
>> for physical adapters, rather than all netdevs.
>>
>> While the user visible struct is new, the underlying context must be
>> implemented as a minimal skb in order for the packet load_* instructions
>> to work. The skb filled in by the driver must have skb->len, skb->head,
>> and skb->data set, and skb->data_len == 0.
>>
>> Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
>> ---
>>   include/uapi/linux/bpf.h | 14 ++++++++++
>>   kernel/bpf/verifier.c    |  1 +
>>   net/core/filter.c        | 68 ++++++++++++++++++++++++++++++++++++++++++++++++
>>   3 files changed, 83 insertions(+)
>>
>> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
>> index 70eda5a..3018d83 100644
>> --- a/include/uapi/linux/bpf.h
>> +++ b/include/uapi/linux/bpf.h
>> @@ -93,6 +93,7 @@ enum bpf_prog_type {
>>   	BPF_PROG_TYPE_SCHED_CLS,
>>   	BPF_PROG_TYPE_SCHED_ACT,
>>   	BPF_PROG_TYPE_TRACEPOINT,
>> +	BPF_PROG_TYPE_PHYS_DEV,
>>   };
>>
>>   #define BPF_PSEUDO_MAP_FD	1
>> @@ -368,6 +369,19 @@ struct __sk_buff {
>>   	__u32 tc_classid;
>>   };
>>
>> +/* user return codes for PHYS_DEV prog type */
>> +enum bpf_phys_dev_action {
>> +	BPF_PHYS_DEV_DROP,
>> +	BPF_PHYS_DEV_OK,
>> +};
>
> I can imagine these extra return codes:
>
>   BPF_PHYS_DEV_MODIFIED,   /* Packet page/payload modified */
>   BPF_PHYS_DEV_STOLEN,     /* E.g. forward use-case */
>   BPF_PHYS_DEV_SHARED,     /* Queue for async processing, e.g. tcpdump use-case */
>
> The "STOLEN" and "SHARED" use-cases require some refcnt manipulations,
> which we can look at when we get that far...

I'd probably let the tcpdump case be handled by the rest of the stack.
Forwarding could be to some txqueue or perhaps directly to a virtual net
device e.g. the veth end sitting in a container (where fake skb would
need to be promoted to a real one). Or, perhaps instead of veth end,
directly demuxed into a target socket queue in that container ...
Alternatively for tcpdump use-case, you could also do sampling on the
bpf_phy_dev with eBPF maps.

> For the "MODIFIED" case, people caring about checksumming, might want
> to voice their concern if we want additional info or return codes,
> indicating if software need to recalc CSUM (or e.g. if only IP-pseudo
> hdr was modified).
>
>> +/* user accessible metadata for PHYS_DEV packet hook
>> + * new fields must be added to the end of this structure
>> + */
>> +struct bpf_phys_dev_md {
>> +	__u32 len;
>> +};
>
> This is userspace visible.  I can easily imagine this structure will get
> extended.  How does a userspace eBPF program know that the struct got
> extended? (bet you got some scheme, normally I would add a "version" as
> first elem).
>
> BTW, how and where is this "struct bpf_phys_dev_md" allocated?

It isn't, see bpf_phys_dev_convert_ctx_access(). At load time the verifier
will convert/rewrite this based on offsetof() to a real access of the per
cpu sk_buff, that's the only purpose.

Cheers,
Daniel
