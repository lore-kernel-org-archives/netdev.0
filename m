From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next RESEND] net: Do not call ndo_dflt_fdb_dump if
 ndo_fdb_dump is defined.
Date: Wed, 10 Dec 2014 23:31:28 -0800
Message-ID: <54894850.5000603@cumulusnetworks.com>
References: <c6756bd161048ac4b4407e308045fe73.squirrel@poczta.wsisiz.edu.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <hadi@mojatatu.com>
To: Hubert Sokolowski <h.sokolowski@wit.edu.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:53720 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932171AbaLKHbc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 02:31:32 -0500
In-Reply-To: <c6756bd161048ac4b4407e308045fe73.squirrel@poczta.wsisiz.edu.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/10/14, 11:37 AM, Hubert Sokolowski wrote:
> This change restores the semantic that was present
> before 5e6d243587990a588143b9da3974833649595587
> "bridge: netlink dump interface at par with brctl"
> on how ndo_dflt_fdb_dump is called.
> This semantic is still used for add and del operations
> so let's keep it consistent.
> Driver can still call ndo_dflt_fdb_dump from inside
> its own fdb_dump routine when needed.
>
> Signed-off-by: Hubert Sokolowski <h.sokolowski@wit.edu.pl>
> ---
>   net/core/rtnetlink.c | 3 ++-
>   1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index eaa057f..a9e5c37 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -2692,10 +2692,11 @@ static int rtnl_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
>   							 idx);
>   		}
>
> -		idx = ndo_dflt_fdb_dump(skb, cb, dev, NULL, idx);
>   		if (dev->netdev_ops->ndo_fdb_dump)
>   			idx = dev->netdev_ops->ndo_fdb_dump(skb, cb, bdev, dev,
>   							    idx);
> +		else
> +			idx = ndo_dflt_fdb_dump(skb, cb, dev, NULL, idx);
>
>   		cops = NULL;
>   	}
I think commit
"5e6d243587990a588143b9da3974833649595587 "bridge: netlink dump 
interface at par with brctl" tried to make sure even the dflt entries 
(ie dev->uc and dev->mc) were also printed in the below case. ie the 
'self' entries in the below output.

# ./bridge fdb show brport eth1
02:00:00:12:01:02 vlan 0 master br0 permanent
00:17:42:8a:b4:05 vlan 0 master br0 permanent
00:17:42:8a:b4:07 self permanent
33:33:00:00:00:01 self permanent

Am guessing reverting the patch is going to make the 'self' entries in 
the above output to go away.
Can you please confirm ?.

Also, if i hear your concern correctly, for bridge ports that implement 
ndo_fdb_dump, with commit 5e6d243587990a588143b9da3974833649595587, we 
will get two entries for each 'self' entry above.
Can you also paste sample output for that ?.

Thanks,
Roopa
