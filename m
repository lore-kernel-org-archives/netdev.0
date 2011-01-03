From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 1/1 V3] bridge: fix br_multicast_ipv6_rcv for paged skbs
Date: Mon, 03 Jan 2011 10:34:14 +0100
Message-ID: <1294047254.4165.1.camel@jlt3.sipsolutions.net>
References: <1293999538-9298-1-git-send-email-tomas.winkler@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Tomas Winkler <tomas.winkler@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:57600 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751426Ab1ACJeU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jan 2011 04:34:20 -0500
In-Reply-To: <1293999538-9298-1-git-send-email-tomas.winkler@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-01-02 at 22:18 +0200, Tomas Winkler wrote:

>  	icmp6h = icmp6_hdr(skb2);
>  
>  	switch (icmp6h->icmp6_type) {
> @@ -1516,7 +1517,12 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
>  	switch (icmp6h->icmp6_type) {
>  	case ICMPV6_MGM_REPORT:
>  	    {
> -		struct mld_msg *mld = (struct mld_msg *)icmp6h;
> +		struct mld_msg *mld;
> +		if (!pskb_may_pull(skb2, sizeof(*mld))) {
> +			err = -EINVAL;
> +			goto out;
> +		}
> +		mld = (struct mld_msg *)icmp6h;

This (and the second instance) is incorrect afaict -- the pointer
"icmp6h" should be reloaded after the pskb_may_pull(), no?

Also, the "out_nopush" thing is pointless since the push is completely
unnecessary as "skb2 != skb" is always true.

johannes

