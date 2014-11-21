From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 9/9] netfilter: Replace smp_read_barrier_depends()
 with lockless_dereference()
Date: Fri, 21 Nov 2014 08:12:44 -0800
Message-ID: <1416586364.8629.104.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1416582363-20661-1-git-send-email-bobby.prani@gmail.com>
	 <1416582363-20661-10-git-send-email-bobby.prani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	"open list:NETWORKING [IPv4/..." <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>
To: Pranith Kumar <bobby.prani@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1416582363-20661-10-git-send-email-bobby.prani@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-11-21 at 10:06 -0500, Pranith Kumar wrote:
> Recently lockless_dereference() was added which can be used in place of
> hard-coding smp_read_barrier_depends(). The following PATCH makes the change.
> 
> Signed-off-by: Pranith Kumar <bobby.prani@gmail.com>
> ---
>  net/ipv4/netfilter/arp_tables.c | 3 +--
>  net/ipv4/netfilter/ip_tables.c  | 3 +--
>  net/ipv6/netfilter/ip6_tables.c | 3 +--
>  3 files changed, 3 insertions(+), 6 deletions(-)
> 
> diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
> index f95b6f9..fc7533d 100644
> --- a/net/ipv4/netfilter/arp_tables.c
> +++ b/net/ipv4/netfilter/arp_tables.c
> @@ -270,12 +270,11 @@ unsigned int arpt_do_table(struct sk_buff *skb,
>  
>  	local_bh_disable();
>  	addend = xt_write_recseq_begin();
> -	private = table->private;
>  	/*
>  	 * Ensure we load private-> members after we've fetched the base
>  	 * pointer.
>  	 */
> -	smp_read_barrier_depends();
> +	private = lockless_dereference(table->private);
>  	table_base = private->entries[smp_processor_id()];
>  


Please carefully read the code, before and after your change, then
you'll see this change broke the code.

Problem is that a bug like that can be really hard to diagnose and fix
later, so really you have to be very careful doing these mechanical
changes.

IMO, current code+comment is better than with this
lockless_dereference() which in this particular case obfuscates the
code. more than anything.

In this case we do have a lock (sort of), so lockless_dereference() is
quite misleading.


