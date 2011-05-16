From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next-2.6 v2] ipv4: more compliant RFC 3168 support
Date: Mon, 16 May 2011 12:17:46 -0700
Message-ID: <1305573466.2503.12.camel@Joe-Laptop>
References: <201105141938.28344.v13@v13.gr>
	 <1305464176.3120.113.camel@edumazet-laptop>
	 <1305466542.3120.129.camel@edumazet-laptop> <201105151808.39231.v13@v13.gr>
	 <1305475310.3120.146.camel@edumazet-laptop>
	 <1305566204.2898.49.camel@edumazet-laptop>
	 <1305571057.2581.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stefanos Harhalakis <v13@v13.gr>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1646 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754146Ab1EPTRs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 May 2011 15:17:48 -0400
In-Reply-To: <1305571057.2581.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-05-16 at 20:37 +0200, Eric Dumazet wrote:
> Commit 6623e3b24a5e (ipv4: IP defragmentation must be ECN aware) was an
> attempt to not lose "Congestion Experienced" (CE) indications when
> performing datagram defragmentation.
> Stefanos Harhalakis raised the point that RFC 3168 requirements were not
> completely met by this commit.
> In particular, we MUST detect invalid combinations and eventually drop
> illegal frames.
> Reported-by: Stefanos Harhalakis <v13@v13.gr>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> v2 : Use a table instead of a switch()

Just trivia:

bitmasks and hard coded constants can be a bit of a minefield.

> diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
> @@ -77,22 +77,42 @@ struct ipq {
[]
> +/* RFC 3168 support :
> + * We want to check ECN values of all fragments, do detect invalid combinations.
> + * In ipq->ecn, we store the OR value of each ip4_frag_ecn() fragment value.
> + */
> +enum {
> +	IPFRAG_ECN_NOT_ECT	= 0x01, /* one frag had ECN_NOT_ECT */
> +	IPFRAG_ECN_ECT_1	= 0x02, /* one frag had ECN_ECT_1 */
> +	IPFRAG_ECN_ECT_0	= 0x04, /* one frag had ECN_ECT_0 */
> +	IPFRAG_ECN_CE		= 0x08, /* one frag had ECN_CE */

Might be better to have a IPFRAG_ECN_TABLESIZE or some such.

	IPFRAG_ECN_TABLESIZE = 0x10,

> +static const u8 ip4_frag_ecn_table[16] = {

static const u8 ip4_frag_ecn_table[IPFRAG_ECN_TABLESIZE] = {


