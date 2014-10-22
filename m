From: Crestez Dan Leonard <cdleonard@gmail.com>
Subject: Re: [RFC] tcp md5 use of alloc_percpu
Date: Thu, 23 Oct 2014 02:05:30 +0300
Message-ID: <5448383A.4090908@gmail.com>
References: <5447FDB2.2010906@gmail.com> <1414005158.9031.22.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-crypto@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1414005158.9031.22.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/22/2014 10:12 PM, Eric Dumazet wrote:
> On Wed, 2014-10-22 at 21:55 +0300, Crestez Dan Leonard wrote:
>> Hello,
>>
>> It seems that the TCP MD5 feature allocates a percpu struct
>> tcp_md5sig_pool and uses part of that memory for a scratch buffer to
>> do crypto on. Here is the relevant code:
>>
>> static int tcp_v4_md5_hash_pseudoheader(struct tcp_md5sig_pool *hp,
>>                                          __be32 daddr, __be32 saddr,
>> int nbytes)
>> {
>>          struct tcp4_pseudohdr *bp;
>>          struct scatterlist sg;
>>
>>          bp = &hp->md5_blk.ip4;
>>
>>          /*
>>           * 1. the TCP pseudo-header (in the order: source IP address,
>>           * destination IP address, zero-padded protocol number, and
>>           * segment length)
>>           */
>>          bp->saddr = saddr;
>>          bp->daddr = daddr;
>>          bp->pad = 0;
>>          bp->protocol = IPPROTO_TCP;
>>          bp->len = cpu_to_be16(nbytes);
>>
>>          sg_init_one(&sg, bp, sizeof(*bp));
>>          return crypto_hash_update(&hp->md5_desc, &sg, sizeof(*bp));
>> }
>>
>> sg_init_one does virt_addr on the pointer which assumes it is directly
>> accessible. But the tcp_md5sig_pool pointer comes from alloc_percpu
>> which can return memory from the vmalloc area after the
>> pcpu_first_chunk is exhausted. This looks wrong to me. I'm am getting
>> crashes on mips and I believe this to be the cause.
>>
>> Allocating a scratch buffer this way is very peculiar. The
>> tcp4_pseudohdr struct is only 12 bytes in length. Similar code in
>> tcp_v6_md5_hash_pseudoheader uses a 40 byte tcp6_pseudohdr. I think it
>> is perfectly reasonable to allocate this kind of stuff on the stack,
>> right? These pseudohdr structs are not used at all outside these two
>> static functions and it would simplify the code.
>>
> Yep, but the sg stuff does not allow for stack variables. Because of
> possible offloading and DMA, I dont know...
A stack buffer is used in tcp_md5_hash_header to add a tcphdr to the 
hash. A quick grep for sg_init_one find a couple of additional instances 
of what looks like doing crypto on small stack buffers:

net/bluetooth/smp.e:110
net/sunrpc/auth_gss/gss_krb5_crypto.c:194
net/rxrpc/rxkad.c:multiple

But those might also be bugs.

If the buffers passed to the crypto api need to be DMA-ble then wouldn't 
this also exclude DEFINE_PERCPU? The DMA-API-HOWTO mentions that items 
in data/text/bss might not be DMA-able, presumably depending on the 
architecture.

>> I'm not familiar with the linux crypto API. Isn't there an easier way
>> to get a temporary md5 hasher?
>
> You should CC crypto guys maybe ...
Added linux-crypto in CC. To summarize the question: What kind of memory 
can be passed to crypto api functions like crypto_hash_update?

 >> The whole notion of struct tcp_md5sig_pool seems dubious. This is a
 >> very tiny struct already and after removing the pseudohdr it shrinks
 >> to a percpu hash_desc for md5 (8 or 16 bytes). Wouldn't DEFINE_PERCPU
 >> be more appropriate?
 >
 > Sure. this would be the more appropriate fix IMO.
I'll post this as a patch if somebody can confirm that it is correct and 
portable.

Doing a temp kmalloc/kfree would also work, but it would hurt 
performance. It would be nice to have a generic way to ask for a small 
temporary DMA-ble buffer.

If DEFINE_PERCPU is not suitable then the tcp_md5sig_pool structs should 
be allocated via individual kmallocs for each cpu.

Regards,
Leonard
