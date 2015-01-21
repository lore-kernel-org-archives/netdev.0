From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] ipv4: try to cache dst_entries which would cause a
 redirect
Date: Wed, 21 Jan 2015 11:39:55 +0100
Message-ID: <1421836795.16127.0.camel@stressinduktion.org>
References: <16ab8e83e2c0719bd449f8e10f82637820624712.1421789827.git.hannes@stressinduktion.org>
	 <alpine.LFD.2.11.1501211041360.2329@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Marcelo Leitner <mleitner@redhat.com>,
	Florian Westphal <fw@strlen.de>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:46420 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750803AbbAUKj5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2015 05:39:57 -0500
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id 59F6920EEB
	for <netdev@vger.kernel.org>; Wed, 21 Jan 2015 05:39:57 -0500 (EST)
In-Reply-To: <alpine.LFD.2.11.1501211041360.2329@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Julian,

On Mi, 2015-01-21 at 10:56 +0200, Julian Anastasov wrote:
> On Tue, 20 Jan 2015, Hannes Frederic Sowa wrote:
> 
> > Not caching dst_entries which cause redirects could be exploited by hosts
> > on the same subnet, causing a severe DoS attack. This effect aggravated
> > since commit f88649721268999 ("ipv4: fix dst race in sk_dst_get()").
> > 
> > Lookups causing redirects will be allocated with DST_NOCACHE set which
> > will force dst_release to free them via RCU.  Unfortunately waiting for
> > RCU grace period just takes too long, we can end up with >1M dst_entries
> > waiting to be released and the system will run OOM. rcuos threads cannot
> > catch up under high softirq load.
> > 
> > Attaching the flag to emit a redirect later on to the specific skb allows
> > us to cache those dst_entries thus reducing the pressure on allocation
> > and deallocation.
> > 
> > This issue was discovered by Marcelo Leitner.
> 
> 	Change looks good to me but additional place
> should be changed too: inet_rtm_getroute() will call
> ip_route_input() and later rt_fill_info() will put
> rt_flags in rtm_flags. We have to set RTCF_DOREDIRECT
> just in rtm_flags depending on IPSKB_DOREDIRECT becuase
> iproute needs to print "redirect". You can test it with
> ip route get ... iif INDEV

Very good catch, thanks. Will post v2 soon.

Thanks,
Hannes
