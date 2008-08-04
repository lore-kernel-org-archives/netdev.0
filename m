From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH] inet6: Fix paramater issue of inet6_csk_xmit
Date: Mon, 04 Aug 2008 10:58:06 +0800
Message-ID: <4896703E.1070203@cn.fujitsu.com>
References: <E1KPpI7-0001jn-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58905 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753892AbYHDDAE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Aug 2008 23:00:04 -0400
In-Reply-To: <E1KPpI7-0001jn-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Herbert Xu:

> Vlad Yasevich <vladislav.yasevich@hp.com> wrote:
>   
>> Otherwise, all of my tests have passed.
>>     
>
> Thanks for testing, here is the corrected patch:
>
> sctp: Drop ipfargok in sctp_xmit function
>
> The ipfragok flag controls whether the packet may be fragmented
> either on the local host on beyond.  The latter is only valid on
> IPv4.
>
> In fact, we never want to do the latter even on IPv4 when PMTU is
> enabled.  This is because even though we can't fragment packets
> within SCTP due to the prtocol's inherent faults, we can still
> fragment it at IP layer.  By setting the DF bit we will improve
> the PMTU process.
>
> RFC 2960 only says that we SHOULD clear the DF bit in this case,
> so we're compliant even if we set the DF bit.  In fact RFC 4960
> no longer has this statement.
>
> Once we make this change, we only need to control the local
> fragmentation.  There is already a bit in the skb which controls
> that, local_df.  So this patch sets that instead of using the
> ipfragok argument.
>
> The only complication is that there isn't a struct sock object
> per transport, so for IPv4 we have to resort to changing the
> pmtudisc field for every packet.  This should be safe though
> as the protocol is single-threaded.
>
> Note that after this patch we can remove ipfragok from the rest
> of the stack too.
>
>   
You need this patch to let sctp under IPv6 do the correct thing.

ipv6: Do not drop packet if skb->local_df is set to true

The old code will drop IPv6 packet if ipfragok is not set, since ipfragok is
obsoleted, will be instead by used skb->local_df, so this check must be 
changed
to skb->local_df.

This patch fix this problem and not drop packet if skb->local_df is set to
true.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/ipv6/ip6_output.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 0969f2a..e9f2a35 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -269,7 +269,7 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl,
 	skb->mark = sk->sk_mark;
 
 	mtu = dst_mtu(dst);
-	if ((skb->len <= mtu) || ipfragok || skb_is_gso(skb)) {
+	if ((skb->len <= mtu) || skb->local_df || skb_is_gso(skb)) {
 		IP6_INC_STATS(ip6_dst_idev(skb->dst),
 			      IPSTATS_MIB_OUTREQUESTS);
 		return NF_HOOK(PF_INET6, NF_INET_LOCAL_OUT, skb, NULL, dst->dev,
-- 
1.5.3.8





