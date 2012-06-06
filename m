From: Chris Metcalf <cmetcalf@tilera.com>
Subject: Re: [PATCH v9] tilegx network driver: initial support
Date: Wed, 6 Jun 2012 14:36:02 -0400
Message-ID: <4FCFA312.4020505@tilera.com>
References: <201205201636.q4KGaoA3003845@farm-0027.internal.tilera.com>  <20120520.165546.1211013675964130504.davem@davemloft.net>  <201205240115.q4O1FwqG006336@lab-41.internal.tilera.com>  <20120524.003148.700603156196416506.davem@davemloft.net>  <201205251853.q4PIrE7T000723@lab-41.internal.tilera.com>  <201206042023.q54KNEZp003834@farm-0002.internal.tilera.com> <1339004459.26966.31.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <bhutchings@solarflare.com>, <arnd@arndb.de>,
	David Miller <davem@davemloft.net>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1339004459.26966.31.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/6/2012 1:40 PM, Eric Dumazet wrote:
> On Mon, 2012-06-04 at 16:12 -0400, Chris Metcalf wrote:
>
>> +/* Allocate and push a buffer. */
>> +static bool tile_net_provide_buffer(bool small)
>> +{
>> +	int stack = small ? small_buffer_stack : large_buffer_stack;
>> +	const unsigned long buffer_alignment = 128;
>> +	struct sk_buff *skb;
>> +	int len;
>> +
>> +	len = sizeof(struct sk_buff **) + buffer_alignment;
>> +	len += (small ? 128 : 1664);
> 1664 is a magic number, it should be a nice define
>
> #define ..... ( ETH_DATA_LEN + .... )

Fair enough.  However, the magic-ness comes from the hardware header code
in arch/tile/gxio/mpipe.h, which provides a limited set of allowed buffer
sizes, including 1664.  But I can add these #defines at the top of this driver:

/* Buffer sizes and mpipe enum codes for buffer stacks.
 * See arch/tile/include/gxio/mpipe.h for the set of possible values.
 */
#define BUFFER_SIZE_SMALL_ENUM GXIO_MPIPE_BUFFER_SIZE_128
#define BUFFER_SIZE_SMALL 128
#define BUFFER_SIZE_LARGE_ENUM GXIO_MPIPE_BUFFER_SIZE_1664
#define BUFFER_SIZE_LARGE 1664


>> +	skb = dev_alloc_skb(len);
>> +	if (skb == NULL)
>> +		return false;
>> +
>> +	/* Make room for a back-pointer to 'skb' and guarantee alignment. */
>> +	skb_reserve(skb, sizeof(struct sk_buff **));
>> +	skb_reserve(skb, -(long)skb->data & (buffer_alignment - 1));
>> +
>> +	/* Save a back-pointer to 'skb'. */
>> +	*(struct sk_buff **)(skb->data - sizeof(struct sk_buff **)) = skb;
>> +
>> +	/* Make sure "skb" and the back-pointer have been flushed. */
>> +	wmb();
> Interesting, have you considered using build_skb() instead of this
> convoluted thing ?
>
> This could save some cache misses...

I hadn't looked at build_skb() before; we built up this driver mostly on a
base of 2.6.38, where it doesn't exist.  That said, it doesn't seem like it
matters; dev_alloc_skb() will just end up calling down to build_skb()
anyway, as far as I can tell.

The code where we do the two skb_reserves and then stuff in a backpointer
and do a barrier are because we track the skbuffs in hardware, and hardware
ignores the low 7 bits aof the address (thus the "buffer_alignment" part)
and we need to be able to pull the actual skb address out of the data when
the hardware returns a pointer to the data to us.

By the way, your question about tx_queue_len is a good one; I'm roping in
our other network developer folks to figure it out.  Originally it was a
performance optimization, I believe; I'm not sure it's still required. 
I'll follow up on that one when we've tracked it down.

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com
