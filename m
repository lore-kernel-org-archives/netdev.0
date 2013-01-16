From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC(v2) net-next 08/13] ipv6: Do not deoend on rt->n in ip6_dst_lookup_tail().
Date: Wed, 16 Jan 2013 14:49:58 +0800
Message-ID: <50F64D96.4090709@gmail.com>
References: <50F587CF.1090306@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f49.google.com ([209.85.210.49]:43722 "EHLO
	mail-da0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752251Ab3APGuI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 01:50:08 -0500
Received: by mail-da0-f49.google.com with SMTP id v40so432316dad.36
        for <netdev@vger.kernel.org>; Tue, 15 Jan 2013 22:50:07 -0800 (PST)
In-Reply-To: <50F587CF.1090306@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

s/deoend/depend/ in $subject...

On 01/16/2013 12:46 AM, YOSHIFUJI Hideaki wrote:
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> ---
>   net/ipv6/ip6_output.c |    8 ++++++--
>   1 file changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> index 9fc5d1d..b2fe048 100644
> --- a/net/ipv6/ip6_output.c
> +++ b/net/ipv6/ip6_output.c
> @@ -921,8 +921,12 @@ static int ip6_dst_lookup_tail(struct sock *sk,
>   	 * dst entry of the nexthop router
>   	 */
>   	rt = (struct rt6_info *) *dst;
> -	n = rt->n;
> -	if (n && !(n->nud_state & NUD_VALID)) {
> +	rcu_read_lock_bh();
> +	n = __ipv6_neigh_lookup_noref(rt->dst.dev, rt6_nexthop(rt, &fl6->daddr));
> +	err = n && !(n->nud_state & NUD_VALID) ? -EINVAL : 0;
> +	rcu_read_unlock_bh();
> +
> +	if (err) {

Are you sure the logic here equals?

In the original code, we could return 0 even we enter this if branch,
but after your patch, it seems it will return -EINVAL?
