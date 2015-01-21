From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net] ipv4: try to cache dst_entries which would cause a
 redirect
Date: Wed, 21 Jan 2015 10:56:16 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1501211041360.2329@ja.home.ssi.bg>
References: <16ab8e83e2c0719bd449f8e10f82637820624712.1421789827.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Marcelo Leitner <mleitner@redhat.com>,
	Florian Westphal <fw@strlen.de>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:48465 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752202AbbAUI4t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jan 2015 03:56:49 -0500
In-Reply-To: <16ab8e83e2c0719bd449f8e10f82637820624712.1421789827.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 20 Jan 2015, Hannes Frederic Sowa wrote:

> Not caching dst_entries which cause redirects could be exploited by hosts
> on the same subnet, causing a severe DoS attack. This effect aggravated
> since commit f88649721268999 ("ipv4: fix dst race in sk_dst_get()").
> 
> Lookups causing redirects will be allocated with DST_NOCACHE set which
> will force dst_release to free them via RCU.  Unfortunately waiting for
> RCU grace period just takes too long, we can end up with >1M dst_entries
> waiting to be released and the system will run OOM. rcuos threads cannot
> catch up under high softirq load.
> 
> Attaching the flag to emit a redirect later on to the specific skb allows
> us to cache those dst_entries thus reducing the pressure on allocation
> and deallocation.
> 
> This issue was discovered by Marcelo Leitner.

	Change looks good to me but additional place
should be changed too: inet_rtm_getroute() will call
ip_route_input() and later rt_fill_info() will put
rt_flags in rtm_flags. We have to set RTCF_DOREDIRECT
just in rtm_flags depending on IPSKB_DOREDIRECT becuase
iproute needs to print "redirect". You can test it with
ip route get ... iif INDEV

Regards

--
Julian Anastasov <ja@ssi.bg>
