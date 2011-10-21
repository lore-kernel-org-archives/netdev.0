From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] dev: use name hash for dev_seq_ops
Date: Fri, 21 Oct 2011 10:07:59 -0700
Message-ID: <20111021100759.0a6bba45@s6510.linuxnetplumber.net>
References: <1319097717-14910-1-git-send-email-mmaruseac@ixiacom.com>
	<1319179510-10715-1-git-send-email-mmaruseac@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	mirq-linux@rere.qmqm.pl, therbert@google.com, jpirko@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dbaluta@ixiacom.com, Mihai Maruseac <mmaruseac@ixiacom.com>
To: Mihai Maruseac <mihai.maruseac@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1319179510-10715-1-git-send-email-mmaruseac@ixiacom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 21 Oct 2011 09:45:10 +0300
Mihai Maruseac <mihai.maruseac@gmail.com> wrote:

> Instead of using the dev->next chain and trying to resync at each call to
> dev_seq_start, use the name hash, keeping the bucket and the offset in
> seq->private field.
> 
> Tests revealed the following results for ifconfig > /dev/null
> 	* 1000 interfaces:
> 		* 0.114s without patch
> 		* 0.089s with patch
> 	* 3000 interfaces:
> 		* 0.489s without patch
> 		* 0.110s with patch
> 	* 5000 interfaces:
> 		* 1.363s without patch
> 		* 0.250s with patch
> 	* 128000 interfaces (other setup):
> 		* ~100s without patch
> 		* ~30s with patch
> 
> Signed-off-by: Mihai Maruseac <mmaruseac@ixiacom.com>
> ---
>  net/core/dev.c |   84 ++++++++++++++++++++++++++++++++++++++++++++++----------
>  1 files changed, 69 insertions(+), 15 deletions(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 70ecb86..6edbcc5 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4041,6 +4041,60 @@ static int dev_ifconf(struct net *net, char __user *arg)
>  }
>  
>  #ifdef CONFIG_PROC_FS
> +
> +#define BUCKET_SPACE (32 - NETDEV_HASHBITS)
> +
> +struct dev_iter_state {
> +	struct seq_net_private p;
> +	unsigned int pos; /* bucket << BUCKET_SPACE + offset */
> +};
> +
> +#define get_bucket(x) ((x) >> BUCKET_SPACE)
> +#define get_offset(x) ((x) & ((1 << BUCKET_SPACE) - 1))
> +#define set_bucket_offset(b, o) ((b) << BUCKET_SPACE | (o))
> +
> +static inline struct net_device *dev_from_same_bucket(struct seq_file *seq)
>

Why are all these function marked inline? They are big, hardly hot path
and better to not continue the bad practice of inlining too much code.
