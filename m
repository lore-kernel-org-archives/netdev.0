From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: fix tcp_mark_head_lost to check skb len
 before fragmenting
Date: Thu, 28 Jan 2016 16:03:23 -0800 (PST)
Message-ID: <20160128.160323.335514499563430972.davem@davemloft.net>
References: <1453759313-22681-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, edumazet@google.com
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60015 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751194AbcA2ADY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 19:03:24 -0500
In-Reply-To: <1453759313-22681-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Mon, 25 Jan 2016 14:01:53 -0800

> From: Neal Cardwell <ncardwell@google.com>
> 
> This commit fixes a corner case in tcp_mark_head_lost() which was
> causing the WARN_ON(len > skb->len) in tcp_fragment() to fire.
> 
> tcp_mark_head_lost() was assuming that if a packet has
> tcp_skb_pcount(skb) of N, then it's safe to fragment off a prefix of
> M*mss bytes, for any M < N. But with the tricky way TCP pcounts are
> maintained, this is not always true.
> 
> For example, suppose the sender sends 4 1-byte packets and have the
> last 3 packet sacked. It will merge the last 3 packets in the write
> queue into an skb with pcount = 3 and len = 3 bytes. If another
> recovery happens after a sack reneging event, tcp_mark_head_lost()
> may attempt to split the skb assuming it has more than 2*MSS bytes.
> 
> This sounds very counterintuitive, but as the commit description for
> the related commit c0638c247f55 ("tcp: don't fragment SACKed skbs in
> tcp_mark_head_lost()") notes, this is because tcp_shifted_skb()
> coalesces adjacent regions of SACKed skbs, and when doing this it
> preserves the sum of their packet counts in order to reflect the
> real-world dynamics on the wire. The c0638c247f55 commit tried to
> avoid problems by not fragmenting SACKed skbs, since SACKed skbs are
> where the non-proportionality between pcount and skb->len/mss is known
> to be possible. However, that commit did not handle the case where
> during a reneging event one of these weird SACKed skbs becomes an
> un-SACKed skb, which tcp_mark_head_lost() can then try to fragment.
> 
> The fix is to simply mark the entire skb lost when this happens.
> This makes the recovery slightly more aggressive in such corner
> cases before we detect reordering. But once we detect reordering
> this code path is by-passed because FACK is disabled.
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks everyone.
