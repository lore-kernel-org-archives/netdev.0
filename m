From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] net/openvswitch: replace memcmp() with
 specialized comparator
Date: Fri, 26 Apr 2013 15:59:42 -0700
Message-ID: <1367017182.8964.258.camel@edumazet-glaptop>
References: <1367012792-25335-1-git-send-email-pmk@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Peter Klausler <pmk-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1367012792-25335-1-git-send-email-pmk-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-04-26 at 17:46 -0400, Peter Klausler wrote:
> Tune flow table lookup in net/openvswitch, replacing a call to
> the slow-but-safe memcmp() in lib/string.c with a key comparator
> routine that presumes most comparisons will succeed.  Besides
> avoiding an early-exit test on each iteration, it also compares
> keys 4 or 8 bytes at a time on architectures that can load an
> unaligned long efficiently.
> 
> On a 3.2GHz Xeon (5679) this patch reduces the minimum back-to-back
> hot-cache latency of a 128-byte key comparison by 7x, from 130ns with
> the default byte-at-a-time memcmp() in lib/string.c down to 17ns.
> 
> More important, replacing the default memcmp() with this specialized
> routine speeds up openvswitch's packet rate by 10% in a closed-loop
> benchmark that simply routes traffic from one tap device to another.
> 
> Signed-off-by: Peter Klausler <pmk-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> ---
>  net/openvswitch/flow.c | 33 ++++++++++++++++++++++++++++++++-
>  1 file changed, 32 insertions(+), 1 deletion(-)
> 
> diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
> index 67a2b78..d5facf6 100644
> --- a/net/openvswitch/flow.c
> +++ b/net/openvswitch/flow.c
> @@ -764,6 +764,37 @@ u32 ovs_flow_hash(const struct sw_flow_key *key, int key_len)
>  	return jhash2((u32 *)key, DIV_ROUND_UP(key_len, sizeof(u32)), 0);
>  }
>  
> +/*
> + * Key comparison routine, optimized for the common case of
> + * equality due to low average hash collision frequency
> + * (1.5 mean items per nonempty bucket when total table item
> + * count equals the number of buckets, which is when openvswitch
> + * expands its hash table).
> + */
> +static bool equal_keys(const struct sw_flow_key *key1,
> +		       const struct sw_flow_key *key2,
> +		       size_t key_len)
> +{
> +	const char *cp1 = (const char *)key1;
> +	const char *cp2 = (const char *)key2;
> +	long diffs = 0;
> +
> +#ifdef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
> +	{
> +		const long *lp1 = (const long *)cp1;
> +		const long *lp2 = (const long *)cp2;
> +		for (; key_len >= sizeof(long); key_len -= sizeof(long))
> +			diffs |= *lp1++ ^ *lp2++;
> +		cp1 = (const char *)lp1;
> +		cp2 = (const char *)lp2;
> +	}
> +#endif

This seems a suboptimal condition, a bit tweaked for x86

Some 32bit arches do not have CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS,
still struct sw_flow_key is 32bit word aligned.

Either its a generic bcmp(s1,s2,len) function without any information on
s1/s2 alignment, and it should not a private ovs thing, 
or 
its OVS private helper, and you can make sure alignof(struct
sw_flow_key) == alignof(unsigned long) and remove the #ifdef
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS

Check include/net/flow.h for an example

struct flowi4 {
...
}  __attribute__((__aligned__(BITS_PER_LONG/8)));
