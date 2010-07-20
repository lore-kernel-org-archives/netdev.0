From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] net: Add batman-adv meshing protocol
Date: Mon, 19 Jul 2010 21:26:25 -0700 (PDT)
Message-ID: <20100719.212625.255369607.davem@davemloft.net>
References: <1279291156-5297-1-git-send-email-sven.eckelmann@gmx.de>
	<1279291156-5297-2-git-send-email-sven.eckelmann@gmx.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwlltHuzzzSOjJt@public.gmane.org
To: sven.eckelmann-Mmb7MZpHnFY@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1279291156-5297-2-git-send-email-sven.eckelmann-Mmb7MZpHnFY@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Sven Eckelmann <sven.eckelmann-Mmb7MZpHnFY@public.gmane.org>
Date: Fri, 16 Jul 2010 16:39:16 +0200

> +/* count the hamming weight, how many good packets did we receive? just count
> + * the 1's. The inner loop uses the Kernighan algorithm, see
> + * http://graphics.stanford.edu/~seander/bithacks.html#CountBitsSetKernighan
> + */
> +int bit_packet_count(TYPE_OF_WORD *seq_bits)
> +{
> +	int i, hamming = 0;
> +	TYPE_OF_WORD word;
> +
> +	for (i = 0; i < NUM_WORDS; i++) {
> +		word = seq_bits[i];
> +
> +		while (word) {
> +			word &= word-1;
> +			hamming++;
> +		}
> +	}
> +	return hamming;
> +}

The kernel has a hamming weight library function which takes advantage
of population count instructions on cpus that suport it, and also has
a sw version than is faster than what you're doing here, please use
it.

The interfaces are called "hweight{8,16,32,64}()" where the number in
the name indicates the bit-size of the word the interface operates on.

I also notice that this code uses it's own internal buffering scheme
with kmalloc()'d buffers, then seperately allocates actual SKB's and
copies the data there.

Just use the SKB facilities how they were designed to be used, instead
of needlessly inventing new things.  Allocate your initial SKB and put
the initial forwarding header in it, then when you want to send a copy
off, skb_clone() it, and push the other bits you want at the head
and/or the tail of the cloned SKB, then simply send it off.
