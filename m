From: KOVACS Krisztian <hidden@balabit.hu>
Subject: Re: [PATCH/RFC 01/10] Implement local diversion of IPv4 skbs
Date: Tue, 16 Jan 2007 13:49:20 +0100
Message-ID: <200701161349.21381@nienna>
References: <20070103163357.14635.37754.stgit@nienna.balabit> <200701101117.47576@nienna> <45A4D9DB.4000809@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@lists.netfilter.org, netdev@vger.kernel.org,
	Balazs Scheidler <bazsi@balabit.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:3382 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750749AbXAPMte (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jan 2007 07:49:34 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id 077AF4C168
	for <netdev@vger.kernel.org>; Tue, 16 Jan 2007 13:49:33 +0100 (CET)
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <45A4D9DB.4000809@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


  Hi,

On Wednesday 10 January 2007 13:19, Patrick McHardy wrote:
> >   Of course it's true that doing early lookups and storing that
> > reference in the skb widens the window considerably, but I think this
> > race is already handled. Or is there anything I don't see?
>
> You're right, it seems to be handled properly (except I think there is
> a race between sk_common_release calling xfrm_sk_free_policy and f.e.
> udp calling __xfrm_policy_check, will look into that).
>
> It probably shouldn't be cached anyway, with nf_queue for example
> the window could be _really_ large.

  Patrick, I seem to be out of ideas how this could be done 
without "caching" the socket lookup. The problem is that it's not only 
caching in some cases. For example we can do something like this:

  iptables -t tproxy -A PREROUTING -s X -d Y -p tcp --dport 80 \
           -j TPROXY --to proxy_ip:proxy_port

  In this case the TPROXY target does a socket lookup for 
proxy_ip:proxy_port and stores that socket reference in skb->sk. 
Obviously if you don't do this then TCP will do a lookup on the packet's 
original destination address/port and it won't work.

  Unfortunately I don't see any way how this could be solved without 
storing the result of the lookup... So while I agree that having that 
socket reference in the skb is risky, as previously skb->sk was unused on 
the input path, I simply don't have any other idea. (Unless your load 
iptable_tproxy skb->sk==NULL on input is still true with these patches, 
so I think there should be absolutely no problems with tproxy unused.)

  Other possible problems which came to my mind:

- The previous version was missing IPv4 fragment reassembly: we obviously 
need this to be able to do socket lookups, so now I've added this to 
iptable_tproxy.
- IP_FREEBIND does not require NET_ADMIN capability, combined with the 
relaxed source address on ip_output() this means that we provide a way to 
do IPv4 address forging for unprivileged users. As we must not break 
anything it looks like we need a separate socket option for disabling 
output source address checks (this would obviously require NET_ADMIN).

  Thoughts? I'd be especially interested in any ideas wrt. the socket 
reference problems, as the other two seems to be easier to solve.

-- 
 Regards,
  Krisztian Kovacs
