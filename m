From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [Patch net-next v2] bridge: do not expire mdb entry as long as
 bridge still uses it
Date: Thu, 25 Apr 2013 16:30:37 +0400
Message-ID: <517921ED.6090701@cogentembedded.com>
References: <1366878083-22797-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.hengli.com.au>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Adam Baker <linux@baker-net.org.uk>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:49645 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752370Ab3DYMbx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 08:31:53 -0400
Received: by mail-la0-f53.google.com with SMTP id eg20so2550357lab.40
        for <netdev@vger.kernel.org>; Thu, 25 Apr 2013 05:31:52 -0700 (PDT)
In-Reply-To: <1366878083-22797-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 25-04-2013 12:21, Cong Wang wrote:

> This bug can be observed in virt environment, when a KVM guest
> communicates with the host via multicast. After some time (should
> be 260 sec, I didn't measure), the multicast traffic suddenly
> terminates.

> This is due to the mdb entry for bridge itself expires automatically,
> it should not expire as long as the bridge still generates multicast
> traffic. It should expire when the bridge leaves the multicast group,
> OR when there is no multicast traffic on this bridge.

> I fix this by adding another bool which is set when there is
> multicast traffic goes to the bridge, cleared in the expire timer and
> when IGMP leave is received. I ran omping for 15 minutes, everything
> looks good now.

> This might not be the best fix, but might be the simplest fix.

> (Adam, this problem is probably different with your problem,
> at least this problem can _not_ be workarounded by setting
> querier to 1.)

> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Adam Baker <linux@baker-net.org.uk>
> Signed-off-by: Cong Wang <amwang@redhat.com>
> ---
> v2: rename ->busy to ->for_br

> diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
> index 828e2bc..4f0e50f 100644
> --- a/net/bridge/br_input.c
> +++ b/net/bridge/br_input.c
> @@ -99,9 +99,12 @@ int br_handle_frame_finish(struct sk_buff *skb)
>   	else if (is_multicast_ether_addr(dest)) {
>   		mdst = br_mdb_get(br, skb, vid);
>   		if (mdst || BR_INPUT_SKB_CB_MROUTERS_ONLY(skb)) {
> -			if ((mdst && mdst->mglist) ||
> -			    br_multicast_is_router(br))
> +			bool to_br = mdst && mdst->mglist;

    Emoty line after declaration wouldn't hurt.

> +			if (to_br || br_multicast_is_router(br))
>   				skb2 = skb;

WBR, Sergei
