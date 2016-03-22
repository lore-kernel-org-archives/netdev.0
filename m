From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net] ipv4: initialize flowi4_flags before calling
 fib_lookup()
Date: Tue, 22 Mar 2016 12:29:02 -0600
Message-ID: <56F18EEE.4070000@cumulusnetworks.com>
References: <1458660679-7279-1-git-send-email-lrichard@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Lance Richardson <lrichard@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:35275 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750735AbcCVS3F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2016 14:29:05 -0400
Received: by mail-ig0-f174.google.com with SMTP id cl4so60494850igb.0
        for <netdev@vger.kernel.org>; Tue, 22 Mar 2016 11:29:04 -0700 (PDT)
In-Reply-To: <1458660679-7279-1-git-send-email-lrichard@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/22/16 9:31 AM, Lance Richardson wrote:
> Field fl4.flowi4_flags is not initialized in fib_compute_spec_dst()
> before calling fib_lookup(), which means fib_table_lookup() is
> using non-deterministic data at this line:
>
> 	if (!(flp->flowi4_flags & FLOWI_FLAG_SKIP_NH_OIF)) {
>
> Fix by initializing fl4.flowi4_flags to zero.
>
> Signed-off-by: Lance Richardson <lrichard@redhat.com>
> ---
>   net/ipv4/fib_frontend.c | 1 +
>   1 file changed, 1 insertion(+)
>
> diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
> index 21add55..896844a 100644
> --- a/net/ipv4/fib_frontend.c
> +++ b/net/ipv4/fib_frontend.c
> @@ -304,6 +304,7 @@ __be32 fib_compute_spec_dst(struct sk_buff *skb)
>   		fl4.flowi4_scope = scope;
>   		fl4.flowi4_mark = IN_DEV_SRC_VMARK(in_dev) ? skb->mark : 0;
>   		fl4.flowi4_tun_key.tun_id = 0;
> +		fl4.flowi4_flags = 0;
>   		if (!fib_lookup(net, &fl4, &res, 0))
>   			return FIB_RES_PREFSRC(net, res);
>   	} else {
>

Fixes: 58189ca7b2741 ("net: Fix vti use case with oif in dst lookups")

I think a more robust solution is to move fl4 to this if case and init 
when it is declared:

	struct flowi4 fl4 = {
		.flowi4_iif = LOOPBACK_IFINDEX,
		.daddr = ip_hdr(skb)->saddr,
		.flowi4_tos = RT_TOS(ip_hdr(skb)->tos),
		.flowi4_scope = scope,
		.flowi4_mark = IN_DEV_SRC_VMARK(in_dev) ? skb->mark : 0,
	};
