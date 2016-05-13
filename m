From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next 06/13] ipv6: Fix nexthdr for reinjection
Date: Fri, 13 May 2016 14:00:14 +0300
Message-ID: <20160513140014.2d7706f4@halley>
References: <1462985253-2380625-1-git-send-email-tom@herbertland.com>
	<1462985253-2380625-7-git-send-email-tom@herbertland.com>
	<20160512232304.437eb3bc@halley>
	<CALx6S34BHQnxSBAW4n4k+pf0Zey+XaiLAVvU5k_zVVRz=jAJvw@mail.gmail.com>
	<20160513092850.1868a828@halley>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:37295 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751857AbcEMLAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 07:00:20 -0400
Received: by mail-wm0-f47.google.com with SMTP id a17so23858655wme.0
        for <netdev@vger.kernel.org>; Fri, 13 May 2016 04:00:19 -0700 (PDT)
In-Reply-To: <20160513092850.1868a828@halley>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, 13 May 2016 09:28:50 +0300 Shmulik Ladkani <shmulik.ladkani@gmail.com> wrote:
> On Thu, 12 May 2016 14:45:36 -0700 Tom Herbert <tom@herbertland.com> wrote:
> > Is there any reason why the EH handlers can't read the nexthdr and return that?  
> 
> One additional thing:
> 
> Seems the
> 
>     if (!pskb_pull(skb, skb_transport_offset(skb)))
> 
> located at the original resubmit label was also necessary, as the EH
> handlers may increment skb->transport_header (both ipv6_destopt_rcv and
> ipv6_rthdr_rcv do so).
> 
> So if we'd like to read the nexthdr at the EH handlers we should repeat
> the "skb pull; read nexthdr from skb_network_header(skb)[new nhoff];
> return nexhdr;" prior each positive return from EH handlers.

Alternatively, instead of modifying EH handlers adding this repeated
logic, we can rearrange ip6_input_finish code, under the premise that
"EH handling iff !INET6_PROTO_FINAL", as follows:

@@ -229,13 +229,14 @@ static int ip6_input_finish(struct net *net, struct sock *sk, struct sk_buff *sk
 	 */
 
 	rcu_read_lock();
-resubmit:
+nexthdr_read:
 	idev = ip6_dst_idev(skb_dst(skb));
 	if (!pskb_pull(skb, skb_transport_offset(skb)))
 		goto discard;
 	nhoff = IP6CB(skb)->nhoff;
 	nexthdr = skb_network_header(skb)[nhoff];
 
+resubmit:
 	raw = raw6_local_deliver(skb, nexthdr);
 	ipprot = rcu_dereference(inet6_protos[nexthdr]);
 	if (ipprot) {
@@ -263,8 +264,12 @@ resubmit:
 			goto discard;
 
 		ret = ipprot->handler(skb);
-		if (ret > 0)
+		if (ret > 0) {
+			if (!(ipprot->flags & INET6_PROTO_FINAL))
+				goto nexthdr_read;
+			nexthdr = ret;
 			goto resubmit;
+		}
 		else if (ret == 0)
 			__IP6_INC_STATS(net, idev, IPSTATS_MIB_INDELIVERS);

Meaning, for EH (identified by !INET6_PROTO_FINAL), act as originally
was (skbpull and refetch nexthdr); For non INET6_PROTO_FINAL, ret code
is the proto itself, so go directly to resubmit.

Less modifications, but (1) creates a coupling (wasn't there already?)
between EH handlers and the !INET6_PROTO_FINAL flag, (2) anchors the
dual semantics WRT ret code of inet6_protocol->handler.

Regards,
Shmulik
