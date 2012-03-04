From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH 1/2] Netfilter: xt_LOG: Implement ring buffer support
Date: Sun, 04 Mar 2012 22:16:09 +0100
Message-ID: <4F53DB99.8040503@nod.at>
References: <1329348480-11147-1-git-send-email-richard@nod.at> <20120304190438.GA24722@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, eric.dumazet@gmail.com,
	jengelh@medozas.de, rostedt@goodmis.org, basti@b-bl.de
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120304190438.GA24722@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 04.03.2012 20:04, schrieb Pablo Neira Ayuso:
> Hi Richard,
>
> Several comments:
>
> On Thu, Feb 16, 2012 at 12:27:59AM +0100, Richard Weinberger wrote:
>> This patch introduces NETFILTER_XT_TARGET_LOG_RING.
>> It allows logging into various ring buffers which are
>> represented as pipe-like files in /proc/net/netfilter/xt_LOG_ring/.
>
> I prefer /proc/net/netfilter/nf_log_ring instead.

Okay.

> Please, add some short example usage, it can be of help for others.

I'll add one to the manpage and Kconfig.

>> Signed-off-by: Richard Weinberger<richard@nod.at>
>> ---
>>   include/linux/netfilter/xt_LOG.h |   12 +-
>>   include/net/netfilter/nf_log.h   |    1 +
>>   include/net/netfilter/xt_log.h   |   22 ++
>>   net/netfilter/Kconfig            |   13 +
>>   net/netfilter/xt_LOG.c           |  631 ++++++++++++++++++++++++++++++++++++-
>>   5 files changed, 660 insertions(+), 19 deletions(-)
>>
>> diff --git a/include/linux/netfilter/xt_LOG.h b/include/linux/netfilter/xt_LOG.h
>> index cac0790..e4b1177 100644
>> --- a/include/linux/netfilter/xt_LOG.h
>> +++ b/include/linux/netfilter/xt_LOG.h
>> @@ -8,7 +8,7 @@
>>   #define XT_LOG_UID		0x08	/* Log UID owning local socket */
>>   #define XT_LOG_NFLOG		0x10	/* Unsupported, don't reuse */
>>   #define XT_LOG_MACDECODE	0x20	/* Decode MAC header */
>> -#define XT_LOG_MASK		0x2f
>> +#define XT_LOG_MASK		0x6f
>
> Not directly related to this but, would you send me the timestamp
> patch before this one?

Sure.

>>   struct xt_log_info {
>>   	unsigned char level;
>> @@ -16,4 +16,14 @@ struct xt_log_info {
>>   	char prefix[30];
>>   };
>>
>> +struct xt_log_info_v1 {
>> +	unsigned char level;
>> +	unsigned char logflags;
>> +	char prefix[30];
>> +
>> +	char ring_name[30];
>> +	__aligned_u64 ring_size;
>> +	struct xt_LOG_ring_ctx *rctx __attribute__((aligned(8)));
>> +};
>> +
>>   #endif /* _XT_LOG_H */
>> diff --git a/include/net/netfilter/nf_log.h b/include/net/netfilter/nf_log.h
>> index e991bd0..18a94f9 100644
>> --- a/include/net/netfilter/nf_log.h
>> +++ b/include/net/netfilter/nf_log.h
>> @@ -14,6 +14,7 @@
>>
>>   #define NF_LOG_TYPE_LOG		0x01
>>   #define NF_LOG_TYPE_ULOG	0x02
>> +#define NF_LOG_TYPE_RING	0x04
>>
>>   struct nf_loginfo {
>>   	u_int8_t type;
>> diff --git a/include/net/netfilter/xt_log.h b/include/net/netfilter/xt_log.h
>> index 767e08d..c9a3718 100644
>> --- a/include/net/netfilter/xt_log.h
>> +++ b/include/net/netfilter/xt_log.h
>> @@ -55,3 +55,25 @@ static void __sb_close(struct sbuff *m, int print)
>>   }
>>
>>   #define sb_close(m)	__sb_close(m, 1)
>> +
>> +#ifdef CONFIG_NETFILTER_XT_TARGET_LOG_RING
>> +struct xt_LOG_ring_ctx;
>> +struct xt_LOG_ring_ctx *xt_LOG_ring_new_ctx(const char *name, size_t rb_size);
>> +int xt_LOG_ring_add_record(const struct xt_LOG_ring_ctx *rctx, const char *buf, \
>> +	unsigned int len);
>> +void xt_LOG_ring_get(struct xt_LOG_ring_ctx *ctx);
>> +void xt_LOG_ring_put(struct xt_LOG_ring_ctx *ctx);
>> +struct xt_LOG_ring_ctx *xt_LOG_ring_find_ctx(const char *name);
>> +
>> +void xt_LOG_ring_exit(void);
>> +int xt_LOG_ring_init(void);
>> +#else
>> +static inline void xt_LOG_ring_exit(void)
>> +{
>> +}
>> +
>> +static inline int xt_LOG_ring_init(void)
>> +{
>> +	return 0;
>> +}
>> +#endif
>
> I think this modification for the .h file is not required anymore,
> you don't need it anymore.

AFAIK I did not remove this to reduce the #ifdefs in the .c file.
Will recheck...

>> diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
>> index b895d8b..ac62599 100644
>> --- a/net/netfilter/Kconfig
>> +++ b/net/netfilter/Kconfig
>> @@ -533,6 +533,19 @@ config NETFILTER_XT_TARGET_LOG
>>
>>   	  To compile it as a module, choose M here.  If unsure, say N.
>>
>> +if NETFILTER_XT_TARGET_LOG
>> +
>> +config NETFILTER_XT_TARGET_LOG_RING
>> +	bool  'Ring buffer support'
>> +	default y
>> +	select RING_BUFFER
>
> Please, CC the ring buffer author, I'm not familar with that code and
> I'll be happy to have an acknowledgment from him stating that the ring
> buffer bits are OK.
>

Steve is already CC'ed. Steve, can you please review and ack this patch?
So far I have only an ack for the newly exported ring_buffer symbol.

Thanks,
//richrd
