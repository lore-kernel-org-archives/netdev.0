From: Florian Westphal <fw@strlen.de>
Subject: Re: conntrack events over netlink flood
Date: Fri, 30 Sep 2011 14:59:56 +0200
Message-ID: <20110930125956.GD13047@Chamillionaire.breakpoint.cc>
References: <069917f11e06f3cf2e1ce9715f435b61@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <069917f11e06f3cf2e1ce9715f435b61@visp.net.lb>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Denys Fedoryshchenko <denys@visp.net.lb> wrote:

[ cc: netfilter-devel ]

>  After enabling events and running conntrack -E i notice flood in output 
>  of server that have PPPoE and PPTP connections. Here is the output:
> 
>  OfficeNAT ~ # conntrack  -E
>   [UPDATE] gre      47 17999 src=192.168.0.140 dst=192.168.0.1 
>  srckey=0x0 dstkey=0x3 src=192.168.0.1 dst=192.168.0.140 srckey=0x3 
>  dstkey=0x0 [ASSURED]
>   [UPDATE] gre      47 17999 src=192.168.0.140 dst=192.168.0.1 
>  srckey=0x0 dstkey=0x3 src=192.168.0.1 dst=192.168.0.140 srckey=0x3 
>  dstkey=0x0 [ASSURED]

[..]

>  Is it considered as a bug? I think it should not send on each packet 
>  conntrack event.

Bug. Update events should only be generated when something in the
conntrack has changed (e.g. the connmark).

Could you please try this patch (untested)?

Subject: [PATCH] netfilter: conntrack_gre: only create ct assured event once

diff --git a/net/netfilter/nf_conntrack_proto_gre.c b/net/netfilter/nf_conntrack_proto_gre.c
--- a/net/netfilter/nf_conntrack_proto_gre.c
+++ b/net/netfilter/nf_conntrack_proto_gre.c
@@ -241,8 +241,8 @@ static int gre_packet(struct nf_conn *ct,
 		nf_ct_refresh_acct(ct, ctinfo, skb,
 				   ct->proto.gre.stream_timeout);
 		/* Also, more likely to be important, and not a probe. */
-		set_bit(IPS_ASSURED_BIT, &ct->status);
-		nf_conntrack_event_cache(IPCT_ASSURED, ct);
+		if (!test_and_set_bit(IPS_ASSURED_BIT, &ct->status))
+			nf_conntrack_event_cache(IPCT_ASSURED, ct);
 	} else
 		nf_ct_refresh_acct(ct, ctinfo, skb,
 				   ct->proto.gre.timeout);
