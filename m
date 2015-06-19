From: =?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kvGyRCNUhGIzFRTEAbKEI=?=
	<hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH RFC net] neigh: do not modify unlinked entries
Date: Fri, 19 Jun 2015 16:14:05 +0900
Message-ID: <5583C13D.7050904@miraclelinux.com>
References: <1434484599-5875-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ying Xue <ying.xue@windriver.com>, alexei@purestorage.com,
	joern@purestorage.com
To: Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35374 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751484AbbFSHOK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2015 03:14:10 -0400
Received: by pacyx8 with SMTP id yx8so79363560pac.2
        for <netdev@vger.kernel.org>; Fri, 19 Jun 2015 00:14:10 -0700 (PDT)
In-Reply-To: <1434484599-5875-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Julian Anastasov wrote:
> The lockless lookups can return entry that is unlinked.
> Sometimes they get reference before last neigh_cleanup_and_release,
> sometimes they do not need reference. Later, any
> modification attempts may result in the following problems:
> 
> 1. entry is not destroyed immediately because neigh_update
> can start the timer for dead entry, eg. on change to NUD_REACHABLE
> state. As result, entry lives for some time but is invisible
> and out of control.
> 
> 2. __neigh_event_send can run in parallel with neigh_destroy
> while refcnt=0 but if timer is started and expired refcnt can
> reach 0 for second time leading to second neigh_destroy and
> possible crash.
> 
> Thanks to Eric Dumazet and Ying Xue for their work and analyze
> on the __neigh_event_send change.
> 
> Fixes: 767e97e1e0db ("neigh: RCU conversion of struct neighbour")
> Fixes: a263b3093641 ("ipv4: Make neigh lookups directly in output packet path.")
> Fixes: 6fd6ce2056de ("ipv6: Do not depend on rt->n in ip6_finish_output2().")
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Ying Xue <ying.xue@windriver.com>
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
>  net/core/neighbour.c | 13 +++++++++++++
>  1 file changed, 13 insertions(+)
> 
>   This is an RFC, so that it can get proper commit message,
> testing and reports. In fact, I'm interested to see valid
> stack dumps for the "NEIGH: BUG, double timer add, state is %x"
> message without this patch and without any debug patches that
> dump stack from neigh_hold or other places...
> 
> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
> index 3de6542..2237c1b 100644
> --- a/net/core/neighbour.c
> +++ b/net/core/neighbour.c
> @@ -957,6 +957,8 @@ int __neigh_event_send(struct neighbour *neigh, struct sk_buff *skb)
>  	rc = 0;
>  	if (neigh->nud_state & (NUD_CONNECTED | NUD_DELAY | NUD_PROBE))
>  		goto out_unlock_bh;
> +	if (neigh->dead)
> +		goto out_dead;
>  
>  	if (!(neigh->nud_state & (NUD_STALE | NUD_INCOMPLETE))) {
>  		if (NEIGH_VAR(neigh->parms, MCAST_PROBES) +
> @@ -1013,6 +1015,13 @@ out_unlock_bh:
>  		write_unlock(&neigh->lock);
>  	local_bh_enable();
>  	return rc;
> +
> +out_dead:
> +	if (neigh->nud_state & NUD_STALE)
> +		goto out_unlock_bh;
> +	write_unlock_bh(&neigh->lock);
> +	kfree_skb(skb);
> +	return 1;
>  }
>  EXPORT_SYMBOL(__neigh_event_send);
>  

Should we always drop the packet here since it is
already dead, shouldn't we?

--yoshfuji

> @@ -1076,6 +1085,8 @@ int neigh_update(struct neighbour *neigh, const u8 *lladdr, u8 new,
>  	if (!(flags & NEIGH_UPDATE_F_ADMIN) &&
>  	    (old & (NUD_NOARP | NUD_PERMANENT)))
>  		goto out;
> +	if (neigh->dead)
> +		goto out;
>  
>  	if (!(new & NUD_VALID)) {
>  		neigh_del_timer(neigh);
> @@ -1225,6 +1236,8 @@ EXPORT_SYMBOL(neigh_update);
>   */
>  void __neigh_set_probe_once(struct neighbour *neigh)
>  {
> +	if (neigh->dead)
> +		return;
>  	neigh->updated = jiffies;
>  	if (!(neigh->nud_state & NUD_FAILED))
>  		return;
> 

-- 
吉藤英明 <hideaki.yoshifuji@miraclelinux.com>
ミラクル・リナックス株式会社 技術本部 サポート部
