From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH RFC] netfilter: cacheline aligning in struct netns_ct
Date: Wed, 12 Mar 2014 10:26:47 +0100
Message-ID: <20140312102647.5758f95d@redhat.com>
References: <1394610994-22794-1-git-send-email-yizhouzhou@ict.ac.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <pablo@netfilter.org>, <jbenc@redhat.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Zhouyi Zhou <yizhouzhou@ict.ac.cn>, brouer@redhat.com
To: Zhouyi Zhou <zhouzhouyi@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394610994-22794-1-git-send-email-yizhouzhou@ict.ac.cn>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 12 Mar 2014 15:56:34 +0800
Zhouyi Zhou <zhouzhouyi@gmail.com> wrote:

> not frequently changing components should share same cachelines
> 
> Signed-off-by: Zhouyi Zhou <yizhouzhou@ict.ac.cn>
> ---
>  include/net/netns/conntrack.h |   12 ++++++++----
>  1 file changed, 8 insertions(+), 4 deletions(-)

NACK because I have already moved these "special" lists in commit:

https://git.kernel.org/cgit/linux/kernel/git/pablo/nf-next.git/commit/?id=b7779d06f9950e14a008a2de970b44233fe49c86

Next remember that this struct netns_ct, is inlined in struct net
(include/net/net_namespace.h).  Thus, the alignment is not quite as you
might expect...

> diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
> index fbcc7fa..69d2d58 100644
> --- a/include/net/netns/conntrack.h
> +++ b/include/net/netns/conntrack.h
> @@ -65,6 +65,12 @@ struct nf_ip_net {
>  struct netns_ct {
>  	atomic_t		count;
>  	unsigned int		expect_count;
> +	struct hlist_nulls_head	unconfirmed;
> +	struct hlist_nulls_head	dying;
> +	struct hlist_nulls_head tmpl;
> +
> +	/*  not frequently changing components should share same cachelines */
> +	struct nf_ip_net	nf_ct_proto ____cacheline_aligned_in_smp;
>  #ifdef CONFIG_SYSCTL
>  	struct ctl_table_header	*sysctl_header;
>  	struct ctl_table_header	*acct_sysctl_header;
> @@ -86,13 +92,11 @@ struct netns_ct {
>  	struct kmem_cache	*nf_conntrack_cachep;
>  	struct hlist_nulls_head	*hash;
>  	struct hlist_head	*expect_hash;
> -	struct hlist_nulls_head	unconfirmed;
> -	struct hlist_nulls_head	dying;
> -	struct hlist_nulls_head tmpl;
> +
>  	struct ip_conntrack_stat __percpu *stat;
>  	struct nf_ct_event_notifier __rcu *nf_conntrack_event_cb;
>  	struct nf_exp_event_notifier __rcu *nf_expect_event_cb;
> -	struct nf_ip_net	nf_ct_proto;
> +
>  #if defined(CONFIG_NF_CONNTRACK_LABELS)
>  	unsigned int		labels_used;
>  	u8			label_words;



-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
