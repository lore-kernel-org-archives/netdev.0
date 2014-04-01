From: Michal Schmidt <mschmidt@redhat.com>
Subject: Re: [PATCH net-next] net-gro: restore frag0 optimization
Date: Tue, 01 Apr 2014 18:40:11 +0200
Message-ID: <533AEBEB.5020400@redhat.com>
References: <5334542F.1050702@redhat.com>	 <1395938874.12610.306.camel@edumazet-glaptop2.roam.corp.google.com>	 <53345A6C.5080008@redhat.com>	 <1395940898.12610.307.camel@edumazet-glaptop2.roam.corp.google.com> <1396153701.29410.27.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jerry Chu <hkchu@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63669 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751283AbaDARA5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Apr 2014 13:00:57 -0400
In-Reply-To: <1396153701.29410.27.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/30/2014 06:28 AM, Eric Dumazet wrote:
> Main difference between napi_frags_skb() and napi_gro_receive() is that
> the later is called while ethernet header was already pulled by the NIC
> driver (eth_type_trans() was called before napi_gro_receive())
> 
> Jerry Chu in commit 299603e8370a ("net-gro: Prepare GRO stack for the
> upcoming tunneling support") tried to remove this difference by calling
> eth_type_trans() from napi_frags_skb() instead of doing this later from
> napi_frags_finish()
> 
> Goal was that napi_gro_complete() could call 
> ptype->callbacks.gro_complete(skb, 0)  (offset of first network header =
> 0)
> 
> Also, xxx_gro_receive() handlers all use off = skb_gro_offset(skb) to
> point to their own header, for the current skb and ones held in gro_list
> 
> Problem is this cleanup work defeated the frag0 optimization:
> It turns out the consecutive pskb_may_pull() calls are too expensive.
> 
> This patch brings back the frag0 stuff in napi_frags_skb().
> 
> As all skb have their mac header in skb head, we no longer need
> skb_gro_mac_header()

Eric,
thank you. The patch improves the performance. Though it's still not as
fast as it was before the commit "net-gro: Prepare GRO stack for the
upcoming tunneling support". In repeated netperf runs my reporter now
sees occasional results above 9 Gb/s, but on average it's only 7 Gb/s.

With your patch only Ethernet headers (and not other headers) are copied
into skbs' heads, but this is done for all skbs. Previously (before
Jerry's patch) no copying was needed for skbs that were GRO_MERGED.
Is this correct?

Regards,
Michal
