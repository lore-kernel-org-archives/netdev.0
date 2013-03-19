From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/4] flow_keys: include thoff into flow_keys
 for later usage
Date: Tue, 19 Mar 2013 06:55:39 -0700
Message-ID: <1363701339.2558.1.camel@edumazet-glaptop>
References: <cover.1363699285.git.dborkman@redhat.com>
	 <b80164aa55e82d0c3190fde317aed9bfc09d3fcb.1363699285.git.dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jasowang@redhat.com
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f43.google.com ([209.85.210.43]:53271 "EHLO
	mail-da0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213Ab3CSNzt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 09:55:49 -0400
Received: by mail-da0-f43.google.com with SMTP id u36so332957dak.16
        for <netdev@vger.kernel.org>; Tue, 19 Mar 2013 06:55:49 -0700 (PDT)
In-Reply-To: <b80164aa55e82d0c3190fde317aed9bfc09d3fcb.1363699285.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-03-19 at 14:28 +0100, Daniel Borkmann wrote:
> In skb_flow_dissect(), we perform a dissection of a skbuff. Since we're
> doing the work here anyway, also store thoff for a later usage, e.g. in
> the BPF filter. We need to reorder choke_skb_cb a bit, though. Also, by
> having thoff 16 Bit, we do not need to pack flow_keys.
> 
> Suggested-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  include/net/flow_keys.h   | 1 +
>  net/core/flow_dissector.c | 5 ++++-
>  net/sched/sch_choke.c     | 4 ++--
>  3 files changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/include/net/flow_keys.h b/include/net/flow_keys.h
> index 80461c1..bb8271d 100644
> --- a/include/net/flow_keys.h
> +++ b/include/net/flow_keys.h
> @@ -9,6 +9,7 @@ struct flow_keys {
>  		__be32 ports;
>  		__be16 port16[2];
>  	};
> +	u16 thoff;
>  	u8 ip_proto;
>  };
>  
> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
> index f8d9e03..eb9dde1 100644
> --- a/net/core/flow_dissector.c
> +++ b/net/core/flow_dissector.c
> @@ -23,7 +23,8 @@ static void iph_to_flow_copy_addrs(struct flow_keys *flow, const struct iphdr *i
>  
>  bool skb_flow_dissect(const struct sk_buff *skb, struct flow_keys *flow)
>  {
> -	int poff, nhoff = skb_network_offset(skb);
> +	int poff;
> +	u16 nhoff = skb_network_offset(skb);
>  	u8 ip_proto;
>  	__be16 proto = skb->protocol;
>  
> @@ -151,6 +152,8 @@ ipv6:
>  			flow->ports = *ports;
>  	}
>  
> +	flow->thoff = nhoff;
> +
>  	return true;
>  }
>  EXPORT_SYMBOL(skb_flow_dissect);
> diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
> index cc37dd5..9854c2b 100644
> --- a/net/sched/sch_choke.c
> +++ b/net/sched/sch_choke.c
> @@ -141,9 +141,9 @@ static void choke_drop_by_idx(struct Qdisc *sch, unsigned int idx)
>  }
>  
>  struct choke_skb_cb {
> -	u16			classid;
> -	u8			keys_valid;
>  	struct flow_keys	keys;
> +	u8			keys_valid;
> +	u16			classid;
>  };
>  
>  static inline struct choke_skb_cb *choke_skb_cb(const struct sk_buff *skb)

Hmm, we dont need to change choke_skb_cb, as the sizeof(keys) didnt
change

(its aligned on 4 bytes)

The first version of the patch needed this because we were using an u32
field for thoff
