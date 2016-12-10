From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next] netfilter: nft_counter: rework atomic dump and
 reset
Date: Sat, 10 Dec 2016 15:16:55 +0100
Message-ID: <20161210141655.GA19963@salvia>
References: <1481378741-19871-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, arnd@arndb.de, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1481378741-19871-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 10, 2016 at 03:05:41PM +0100, Pablo Neira Ayuso wrote:
[...]
> -static void nft_counter_reset(struct nft_counter_percpu __percpu *counter,
> -			      struct nft_counter *total)
> -{
> -	struct nft_counter_percpu *cpu_stats;
> -	u64 bytes, packets;
> -	unsigned int seq;
> -	int cpu;
> -
> -	memset(total, 0, sizeof(*total));
> -	for_each_possible_cpu(cpu) {
> -		bytes = packets = 0;
> -
> -		cpu_stats = per_cpu_ptr(counter, cpu);
> -		do {
> -			seq	= u64_stats_fetch_begin_irq(&cpu_stats->syncp);
> -			packets	+= __nft_counter_reset(&cpu_stats->counter.packets);
> -			bytes	+= __nft_counter_reset(&cpu_stats->counter.bytes);
> -		} while (u64_stats_fetch_retry_irq(&cpu_stats->syncp, seq));
> -
> -		total->packets += packets;
> -		total->bytes += bytes;
> +			seq	= read_seqcount_begin(myseq);
> +			bytes	= this_cpu->bytes;
> +			packets	= this_cpu->packets;
> +		} while (read_seqcount_retry(myseq, seq));
> +
> +		total->bytes	+= bytes;
> +		total->packets	+= packets;
> +
> +		if (reset) {
> +			local_bh_disable();
> +			this_cpu->packets -= packets;
> +			this_cpu->bytes -= bytes;
> +			local_bh_enable();
> +		}

Actually this is not right either, Eric proposed this instead:

static void nft_counter_reset(struct nft_counter_percpu __percpu *counter,
                              struct nft_counter *total)
{
      struct nft_counter_percpu *cpu_stats;

      local_bh_disable();
      cpu_stats = this_cpu_ptr(counter);
      cpu_stats->counter.packets -= total->packets;
      cpu_stats->counter.bytes -= total->bytes;
      local_bh_enable();
}

The cpu that running over the reset code is guaranteed to own this
stats exclusively, but this is not guaranteed by my patch.

I'm going to send a v2. I think I need to turn packet and byte
counters into s64, otherwise a sufficient large total->packets may
underflow and confuse stats.
