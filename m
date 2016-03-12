From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH V7] netfilter: h323: avoid potential attack
Date: Sat, 12 Mar 2016 13:19:02 +0100
Message-ID: <20160312121902.GA2398@salvia>
References: <1455984239-5807-1-git-send-email-zhouzhouyi@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, kaber@trash.net, kadlec@blackhole.kfki.hu,
	davem@davemloft.net, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fw@strlen.de,
	gnomes@lxorguk.ukuu.org.uk, sergei.shtylyov@cogentembedded.com,
	Zhouyi Zhou <yizhouzhou@ict.ac.cn>
To: Zhouyi Zhou <zhouzhouyi@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1455984239-5807-1-git-send-email-zhouzhouyi@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 21, 2016 at 12:03:59AM +0800, Zhouyi Zhou wrote:
> I think hackers chould build a malicious h323 packet to overflow
> the pointer p which will panic during the memcpy(addr, p, len)
> For example, he may fabricate a very large taddr->ipAddress.ip in
> function get_h225_addr.
> 
> To avoid above, I add buffer boundary checking both in get addr
> functions and set addr functions.
> 
> Because the temporary h323 buffer is dynamiclly allocated, I remove
> the h323 spin lock in my patch.
> 
> Signed-off-by: Zhouyi Zhou <yizhouzhou@ict.ac.cn>
> ---
>  include/linux/netfilter/nf_conntrack_h323.h |  17 +-
>  net/ipv4/netfilter/nf_nat_h323.c            |  33 ++-
>  net/netfilter/nf_conntrack_h323_main.c      | 328 +++++++++++++++++-----------
>  3 files changed, 244 insertions(+), 134 deletions(-)
> 
> diff --git a/include/linux/netfilter/nf_conntrack_h323.h b/include/linux/netfilter/nf_conntrack_h323.h
> index 858d9b2..6c6fea1 100644
> --- a/include/linux/netfilter/nf_conntrack_h323.h
> +++ b/include/linux/netfilter/nf_conntrack_h323.h
> @@ -27,11 +27,17 @@ struct nf_ct_h323_master {
>  	};
>  };
>  
> +struct h323_ct_state {
> +	unsigned char *buf;
> +	unsigned char *data;
> +	int buflen;
> +};
> +
>  struct nf_conn;
>  
>  int get_h225_addr(struct nf_conn *ct, unsigned char *data,
>  		  TransportAddress *taddr, union nf_inet_addr *addr,
> -		  __be16 *port);
> +		  __be16 *port, struct h323_ct_state *ctstate);
>  void nf_conntrack_h245_expect(struct nf_conn *new,
>  			      struct nf_conntrack_expect *this);
>  void nf_conntrack_q931_expect(struct nf_conn *new,
> @@ -50,12 +56,14 @@ extern int (*set_sig_addr_hook) (struct sk_buff *skb,
>  				 struct nf_conn *ct,
>  				 enum ip_conntrack_info ctinfo,
>  				 unsigned int protoff, unsigned char **data,
> -				 TransportAddress *taddr, int count);
> +				 TransportAddress *taddr, int count,
> +				 struct h323_ct_state *ctstate);
>  extern int (*set_ras_addr_hook) (struct sk_buff *skb,
>  				 struct nf_conn *ct,
>  				 enum ip_conntrack_info ctinfo,
>  				 unsigned int protoff, unsigned char **data,
> -				 TransportAddress *taddr, int count);
> +				 TransportAddress *taddr, int count,
> +				 struct h323_ct_state *ctstate);
>  extern int (*nat_rtp_rtcp_hook) (struct sk_buff *skb,
>  				 struct nf_conn *ct,
>  				 enum ip_conntrack_info ctinfo,
> @@ -90,7 +98,8 @@ extern int (*nat_q931_hook) (struct sk_buff *skb, struct nf_conn *ct,
>  			     unsigned int protoff,
>  			     unsigned char **data, TransportAddress *taddr,
>  			     int idx, __be16 port,
> -			     struct nf_conntrack_expect *exp);
> +			     struct nf_conntrack_expect *exp,
> +			     struct h323_ct_state *ctstate);
>  
>  #endif
>  
> diff --git a/net/ipv4/netfilter/nf_nat_h323.c b/net/ipv4/netfilter/nf_nat_h323.c
> index 574f7eb..5ed2d70 100644
> --- a/net/ipv4/netfilter/nf_nat_h323.c
> +++ b/net/ipv4/netfilter/nf_nat_h323.c
> @@ -33,12 +33,20 @@ static int set_addr(struct sk_buff *skb, unsigned int protoff,
>  	} __attribute__ ((__packed__)) buf;
>  	const struct tcphdr *th;
>  	struct tcphdr _tcph;
> +	int datalen;
> +	struct iphdr *iph = ip_hdr(skb);
>  
>  	buf.ip = ip;
>  	buf.port = port;
>  	addroff += dataoff;
>  
>  	if (ip_hdr(skb)->protocol == IPPROTO_TCP) {
> +		th = (void *)iph + iph->ihl * 4;
> +		datalen = skb->len - (iph->ihl * 4 + th->doff * 4);

You cannot trust the information that is available in the header. If
this is bogus this check will be defeated. That's why we pass this
protoff parameters to each function.

You also refer to get_h225_addr() in your description. That function
always copies 4 or 16 bytes, so I would appreciate if you can describe
the possible issue further.

Thanks.
