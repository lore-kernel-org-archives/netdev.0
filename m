From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net] ipv4: initialize flowi4_flags before calling
 fib_lookup()
Date: Tue, 22 Mar 2016 13:00:48 -0600
Message-ID: <56F19660.4040502@cumulusnetworks.com>
References: <1458673017-3528-1-git-send-email-lrichard@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Lance Richardson <lrichard@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:35473 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751604AbcCVTAw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2016 15:00:52 -0400
Received: by mail-ig0-f179.google.com with SMTP id cl4so61007577igb.0
        for <netdev@vger.kernel.org>; Tue, 22 Mar 2016 12:00:52 -0700 (PDT)
In-Reply-To: <1458673017-3528-1-git-send-email-lrichard@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/22/16 12:56 PM, Lance Richardson wrote:
> Field fl4.flowi4_flags is not initialized in fib_compute_spec_dst()
> before calling fib_lookup(), which means fib_table_lookup() is
> using non-deterministic data at this line:
>
> 	if (!(flp->flowi4_flags & FLOWI_FLAG_SKIP_NH_OIF)) {
>
> Fix by initializing the entire fl4 structure, which will prevent
> similar issues as fields are added in the future by ensuring that
> all fields are initialized to zero unless explicitly initialized
> to another value.
>
> Fixes: 58189ca7b2741 ("net: Fix vti use case with oif in dst lookups")
> Suggested-by: David Ahern <dsa@cumulusnetworks.com>
> Signed-off-by: Lance Richardson <lrichard@redhat.com>
> ---
>   net/ipv4/fib_frontend.c | 16 +++++++---------
>   1 file changed, 7 insertions(+), 9 deletions(-)
>
> diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
> index 21add55..8a9246d 100644
> --- a/net/ipv4/fib_frontend.c
> +++ b/net/ipv4/fib_frontend.c
> @@ -280,7 +280,6 @@ __be32 fib_compute_spec_dst(struct sk_buff *skb)
>   	struct in_device *in_dev;
>   	struct fib_result res;
>   	struct rtable *rt;
> -	struct flowi4 fl4;
>   	struct net *net;
>   	int scope;
>
> @@ -296,14 +295,13 @@ __be32 fib_compute_spec_dst(struct sk_buff *skb)
>
>   	scope = RT_SCOPE_UNIVERSE;
>   	if (!ipv4_is_zeronet(ip_hdr(skb)->saddr)) {
> -		fl4.flowi4_oif = 0;
> -		fl4.flowi4_iif = LOOPBACK_IFINDEX;
> -		fl4.daddr = ip_hdr(skb)->saddr;
> -		fl4.saddr = 0;
> -		fl4.flowi4_tos = RT_TOS(ip_hdr(skb)->tos);
> -		fl4.flowi4_scope = scope;
> -		fl4.flowi4_mark = IN_DEV_SRC_VMARK(in_dev) ? skb->mark : 0;
> -		fl4.flowi4_tun_key.tun_id = 0;
> +		struct flowi4 fl4 = {
> +			.flowi4_iif = LOOPBACK_IFINDEX,
> +			.daddr = ip_hdr(skb)->saddr,
> +			.flowi4_tos = RT_TOS(ip_hdr(skb)->tos),
> +			.flowi4_scope = scope,
> +			.flowi4_mark = IN_DEV_SRC_VMARK(in_dev) ? skb->mark : 0,
> +		};
>   		if (!fib_lookup(net, &fl4, &res, 0))
>   			return FIB_RES_PREFSRC(net, res);
>   	} else {
>

Acked-by: David Ahern <dsa@cumulusnetworks.com>

DaveM: this should go into stable releases back to v4.3.
