From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] icmp: Fixed bug in raw sockets causing incorrect ICMP
 SNMP counter values
Date: Sun, 11 Oct 2015 16:09:29 -0700
Message-ID: <1444604969.27760.149.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151011205528.GA4322@benjojo.co.uk>
	 <1444601448.27760.143.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAL=9YSVgnCDzZkDM4JujD89V3GpUnDGXyMk7qMnWg7LtmT5G7w@mail.gmail.com>
	 <1444603382.27760.146.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1444603443.27760.147.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ben+patches@benjojo.co.uk,
	David L Stevens <dlstevens@us.ibm.com>
To: Ben Cox <ben@benjojo.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444603443.27760.147.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2015-10-11 at 15:44 -0700, Eric Dumazet wrote:
> On Sun, 2015-10-11 at 15:43 -0700, Eric Dumazet wrote:
> 
> > But your code reads 21th byte.
> 
> BTW, nice catch !

Maybe the following one.

1) We properly set transport header
2) We use icmp_hdr() helper.

diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 561cd4b8fc6e..ffe25cd1f0e0 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -406,11 +406,11 @@ static int raw_send_hdrinc(struct sock *sk, struct flowi4 *fl4,
 			ip_select_ident(net, skb, NULL);
 
 		iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
+		skb->transport_header += iphlen;
+		if (iph->protocol == IPPROTO_ICMP &&
+		    length >= iphlen + sizeof(struct icmphdr))
+			icmp_out_count(net, icmp_hdr(skb)->type);
 	}
-	if (iph->protocol == IPPROTO_ICMP)
-		icmp_out_count(net, ((struct icmphdr *)
-			skb_transport_header(skb))->type);
-
 	err = NF_HOOK(NFPROTO_IPV4, NF_INET_LOCAL_OUT, sk, skb,
 		      NULL, rt->dst.dev, dst_output_sk);
 	if (err > 0)
