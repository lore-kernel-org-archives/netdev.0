From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [RFC PATCH 2/2] tcp: Early SYN limit and SYN cookie handling to mitigate SYN floods
Date: Wed, 30 May 2012 10:03:40 +0200
Message-ID: <201205301013.10797.hans.schillstrom@ericsson.com>
References: <20120528115102.12068.79994.stgit@localhost.localdomain> <m2bol6lqxo.fsf@firstfloor.org> <1338360073.2760.81.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	Jesper Dangaard Brouer <jbrouer@redhat.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Christoph Paasch <christoph.paasch@uclouvain.be>,
	"David S. Miller" <davem@davemloft.net>,
	Martin Topholm <mph@hoth.dk>, Florian Westphal <fw@strlen.de>,
	"opurdila@ixiacom.com" <opurdila@ixiacom.com>,
	Tom Herbert <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.ericsson.se ([193.180.251.45]:58414 "EHLO
	mailgw1.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750903Ab2E3INQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 04:13:16 -0400
In-Reply-To: <1338360073.2760.81.camel@edumazet-glaptop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 30 May 2012 08:41:13 Eric Dumazet wrote:
> On Tue, 2012-05-29 at 12:37 -0700, Andi Kleen wrote:
> 
> > So basically handling syncookie lockless? 
> > 
> > Makes sense. Syncookies is a bit obsolete these days of course, due
> > to the lack of options. But may be still useful for this.
> > 
> > Obviously you'll need to clean up the patch and support IPv6,
> > but the basic idea looks good to me.
> 
> Also TCP Fast Open should be a good way to make the SYN flood no more
> effective.
> 
> Yuchung Cheng and Jerry Chu should upstream this code in a very near
> future.
> 
> Another way to mitigate SYN scalability issues before the full RCU
> solution I was cooking is to either :
> 
> 1) Use a hardware filter (like on Intel NICS) to force all SYN packets
> going to one queue (so that they are all serviced on one CPU)

We have this option running right now, and it gave slightly higher values.
The upside is only one core is running at 100% load.

To be able to process more SYN an attempt was made to spread them with RPS to 
2 other cores gave 60% more SYN:s per sec
i.e. syn filter in NIC sending all irq:s to one core gave ~ 52k syn. pkts/sec
adding RPS and sending syn to two other core:s gave ~80k  syn. pkts/sec
Adding more cores than two didn't help that much.

> 2) Tweak RPS (__skb_get_rxhash()) so that SYN packets rxhash is not
> dependent on src port/address, to get same effect (All SYN packets
> processed by one cpu). Note this only address the SYN flood problem, not
> the general 3WHS scalability one, since if real connection is
> established, the third packet (ACK from client) will have the 'real'
> rxhash and will be processed by another cpu.

Neither the NIC:s SYN filter or this scale that well..

> (Of course, RPS must be enabled to benefit from this)
> 
> Untested patch to get the idea :
> 
>  include/net/flow_keys.h   |    1 +
>  net/core/dev.c            |    8 ++++++++
>  net/core/flow_dissector.c |    9 +++++++++
>  3 files changed, 18 insertions(+)
> 
> diff --git a/include/net/flow_keys.h b/include/net/flow_keys.h
> index 80461c1..b5bae21 100644
> --- a/include/net/flow_keys.h
> +++ b/include/net/flow_keys.h
> @@ -10,6 +10,7 @@ struct flow_keys {
>  		__be16 port16[2];
>  	};
>  	u8 ip_proto;
> +	u8 tcpflags;
>  };
>  
>  extern bool skb_flow_dissect(const struct sk_buff *skb, struct flow_keys *flow);
> diff --git a/net/core/dev.c b/net/core/dev.c
> index cd09819..c9c039e 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -135,6 +135,7 @@
>  #include <linux/net_tstamp.h>
>  #include <linux/static_key.h>
>  #include <net/flow_keys.h>
> +#include <net/tcp.h>
>  
>  #include "net-sysfs.h"
>  
> @@ -2614,6 +2615,12 @@ void __skb_get_rxhash(struct sk_buff *skb)
>  		return;
>  
>  	if (keys.ports) {
> +		if ((keys.tcpflags & (TCPHDR_SYN | TCPHDR_ACK)) == TCPHDR_SYN) {
> +			hash = jhash_2words((__force u32)keys.dst,
> +					    (__force u32)keys.port16[1],
> +					    hashrnd);
> +			goto end;
> +		}
>  		if ((__force u16)keys.port16[1] < (__force u16)keys.port16[0])
>  			swap(keys.port16[0], keys.port16[1]);
>  		skb->l4_rxhash = 1;
> @@ -2626,6 +2633,7 @@ void __skb_get_rxhash(struct sk_buff *skb)
>  	hash = jhash_3words((__force u32)keys.dst,
>  			    (__force u32)keys.src,
>  			    (__force u32)keys.ports, hashrnd);
> +end:
>  	if (!hash)
>  		hash = 1;
>  
> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
> index a225089..cd4aedf 100644
> --- a/net/core/flow_dissector.c
> +++ b/net/core/flow_dissector.c
> @@ -137,6 +137,15 @@ ipv6:
>  		ports = skb_header_pointer(skb, nhoff, sizeof(_ports), &_ports);
>  		if (ports)
>  			flow->ports = *ports;
> +		if (ip_proto == IPPROTO_TCP) {
> +			__u8 *tcpflags, _tcpflags;
> +
> +			tcpflags = skb_header_pointer(skb, nhoff + 13,
> +						      sizeof(_tcpflags),
> +						      &_tcpflags);
> +			if (tcpflags)
> +				flow->tcpflags = *tcpflags;
> +		}
>  	}
>  
>  	return true;
> 
> 
> 

-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
