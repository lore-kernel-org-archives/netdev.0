From: "Hans Schillstrom" <hans@schillstrom.com>
Subject: Re[2]:  [PATCH] netfilter: xt_HMARK: fix endian bugs and
	warnings
Date: Thu, 17 May 2012 10:07:39 +0200 (CEST)
Message-ID: <0k0r53l.31eb6e95218f4fe94cf5b24be0cb96d1@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: "Hans Schillstrom" <hans.schillstrom@ericsson.com>,
	kaber@trash.net, jengelh@medozas.de,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	dan.carpenter@oracle.com
To: "Pablo Neira Ayuso" <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>
>On Wed, May 16, 2012 at 05:00:42PM +0200, Hans Schillstrom wrote:
>> A mix of u32 and __be32 causes endian warning.
>> The hash value produced is now the same for big and little endian machines.
>> i.e. a mix of Big and Little endian in a cluster is now possible.
>> 
>> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
>> Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
>> ---
>>  include/linux/netfilter/xt_HMARK.h |    5 ++-
>>  net/netfilter/xt_HMARK.c           |   68 ++++++++++++++++++++---------------
>>  2 files changed, 42 insertions(+), 31 deletions(-)
>> 
>> diff --git a/include/linux/netfilter/xt_HMARK.h b/include/linux/netfilter/xt_HMARK.h
>> index abb1650..8b6307a 100644
>> --- a/include/linux/netfilter/xt_HMARK.h
>> +++ b/include/linux/netfilter/xt_HMARK.h
>> @@ -24,10 +24,11 @@ enum {
>>  
>>  union hmark_ports {
>>  	struct {
>> -		__u16	src;
>> -		__u16	dst;
>> +		__be16	src;
>> +		__be16	dst;
>>  	} p16;
>>  	__u32	v32;
>> +	__be32	b32;
>>  };
>>  
>>  struct xt_hmark_info {
>> diff --git a/net/netfilter/xt_HMARK.c b/net/netfilter/xt_HMARK.c
>> index 32fbd73..7bb7b5e 100644
>> --- a/net/netfilter/xt_HMARK.c
>> +++ b/net/netfilter/xt_HMARK.c
>> @@ -32,13 +32,13 @@ MODULE_ALIAS("ipt_HMARK");
>>  MODULE_ALIAS("ip6t_HMARK");
>>  
>>  struct hmark_tuple {
>> -	u32			src;
>> -	u32			dst;
>> +	__be32			src;
>> +	__be32			dst;
>>  	union hmark_ports	uports;
>>  	uint8_t			proto;
>>  };
>>  
>> -static inline u32 hmark_addr6_mask(const __u32 *addr32, const __u32 *mask)
>> +static inline __be32 hmark_addr6_mask(const __be32 *addr32, const __be32 *mask)
>>  {
>>  	return (addr32[0] & mask[0]) ^
>>  	       (addr32[1] & mask[1]) ^
>> @@ -46,8 +46,8 @@ static inline u32 hmark_addr6_mask(const __u32 *addr32, const __u32 *mask)
>>  	       (addr32[3] & mask[3]);
>>  }
>>  
>> -static inline u32
>> -hmark_addr_mask(int l3num, const __u32 *addr32, const __u32 *mask)
>> +static inline __be32
>> +hmark_addr_mask(int l3num, const __be32 *addr32, const __be32 *mask)
>>  {
>>  	switch (l3num) {
>>  	case AF_INET:
>> @@ -58,6 +58,25 @@ hmark_addr_mask(int l3num, const __u32 *addr32, const __u32 *mask)
>>  	return 0;
>>  }
>>  
>> +static inline void hmark_port_order(union hmark_ports *uports,
>
>comestical change, better call this hmark_swap_ports

>
>> +				    const struct xt_hmark_info *info)
>> +{
>> +	union hmark_ports hp;
>> +
>> +	hp.b32 = (uports->b32 & info->port_mask.b32) | info->port_set.b32;
>> +	hp.v32 = ntohl(hp.b32);
>> +	/* Make it endian safe into jhash() */
>> +#if defined(__LITTLE_ENDIAN)
>> +	if ((__force u16) uports->p16.dst >
>> +	    (__force u16) uports->p16.src)
>> +#else
>> +	if ((__force u16) uports->p16.src >
>> +	    (__force u16) uports->p16.dst)
>> +#endif
>
>This ifdef is ugly. 

Indeed,  but it saves some cpu cycles 

>I prefer if you use ntohs the ports and store the values in some local variable, 
>then compare and swap if required.
>
>Just like you do with the IPv4 address.

Ok, to make it endian safe a shift is required.
Like this:

        hp.b32 = (uports->b32 & info->port_mask.b32) | info->port_set.b32;
        src = ntohs(hp.b16.src);
        dst = ntohs(hp.b16.dst);

        if (dst > src)
                uports->v32 = (dst << 16) | src;
        else
                uports->v32 = (src << 16) | dst;

>
>> +		swap(hp.p16.src, hp.p16.dst);
>> +	uports->v32 = hp.v32;
>> +}
>> +

I'll re-spin the patch



