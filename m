From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] ipv6: send Change Status Report after DAD is
 completed
Date: Thu, 16 Jan 2014 12:21:30 +0100
Message-ID: <52D7C0BA.7010908@redhat.com>
References: <1389813008-23851-1-git-send-email-fbl@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15481 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751632AbaAPLVi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jan 2014 06:21:38 -0500
In-Reply-To: <1389813008-23851-1-git-send-email-fbl@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/15/2014 08:10 PM, Flavio Leitner wrote:
> The RFC 3810 defines two type of messages for multicast
> listeners. The "Current State Report" message, as the name
> implies, refreshes the *current* state to the querier.
> Since the querier sends Query messages periodically, there
> is no need to retransmit the report.
>
> On the other hand, any change should be reported immediately
> using "State Change Report" messages. Since it's an event
> triggered by a change and that it can be affected by packet
> loss, the rfc states it should be retransmitted [RobVar] times
> to make sure routers will receive timely.
>
> Currently, we are sending "Current State Reports" after
> DAD is completed.  Before that, we send messages using
> unspecified address (::) which should be silently discarded
> by routers.
>
> This patch changes to send "State Change Report" messages
> after DAD is completed fixing the behavior to be RFC compliant
> and also to pass TAHI IPv6 testsuite.
>
> Signed-off-by: Flavio Leitner <fbl@redhat.com>
> ---
>   net/ipv6/mcast.c | 64 ++++++++++++++++++++++++++++++++++----------------------
>   1 file changed, 39 insertions(+), 25 deletions(-)
>
> diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
> index 99cd65c..8ac17f5 100644
> --- a/net/ipv6/mcast.c
> +++ b/net/ipv6/mcast.c
> @@ -1493,7 +1493,7 @@ static struct sk_buff *add_grhead(struct sk_buff *skb, struct ifmcaddr6 *pmc,
>   	skb_tailroom(skb)) : 0)
>
>   static struct sk_buff *add_grec(struct sk_buff *skb, struct ifmcaddr6 *pmc,
> -	int type, int gdeleted, int sdeleted)
> +	int type, int gdeleted, int sdeleted, int crsend)

Maybe we should convert the last three to 'bool' at some point in time?

Nit: argument indent

>   {
>   	struct inet6_dev *idev = pmc->idev;
>   	struct net_device *dev = idev->dev;
> @@ -1585,7 +1585,7 @@ empty_source:
>   		if (type == MLD2_ALLOW_NEW_SOURCES ||
>   		    type == MLD2_BLOCK_OLD_SOURCES)
>   			return skb;
> -		if (pmc->mca_crcount || isquery) {
> +		if (pmc->mca_crcount || isquery || crsend) {
>   			/* make sure we have room for group header */
>   			if (skb && AVAILABLE(skb) < sizeof(struct mld2_grec)) {
>   				mld_sendpack(skb);
> @@ -1602,6 +1602,28 @@ empty_source:
>   	return skb;
>   }
>
> +static void mld_send_initial_cr(struct inet6_dev *idev)
> +{
> +	struct sk_buff *skb;
> +	struct ifmcaddr6 *pmc;
> +	int type;
> +
> +	skb = NULL;
> +	read_lock_bh(&idev->lock);
> +	for (pmc=idev->mc_list; pmc; pmc=pmc->next) {
> +		spin_lock_bh(&pmc->mca_lock);
> +		if (pmc->mca_sfcount[MCAST_EXCLUDE])
> +			type = MLD2_CHANGE_TO_EXCLUDE;
> +		else
> +			type = MLD2_CHANGE_TO_INCLUDE;
> +		skb = add_grec(skb, pmc, type, 0, 0, 1);
> +		spin_unlock_bh(&pmc->mca_lock);
> +	}
> +	read_unlock_bh(&idev->lock);
> +	if (skb)
> +		mld_sendpack(skb);
> +}
> +
>   static void mld_send_report(struct inet6_dev *idev, struct ifmcaddr6 *pmc)
>   {
>   	struct sk_buff *skb = NULL;
> @@ -1617,7 +1639,7 @@ static void mld_send_report(struct inet6_dev *idev, struct ifmcaddr6 *pmc)
>   				type = MLD2_MODE_IS_EXCLUDE;
>   			else
>   				type = MLD2_MODE_IS_INCLUDE;
> -			skb = add_grec(skb, pmc, type, 0, 0);
> +			skb = add_grec(skb, pmc, type, 0, 0, 0);
>   			spin_unlock_bh(&pmc->mca_lock);
>   		}
>   	} else {
> @@ -1626,7 +1648,7 @@ static void mld_send_report(struct inet6_dev *idev, struct ifmcaddr6 *pmc)
>   			type = MLD2_MODE_IS_EXCLUDE;
>   		else
>   			type = MLD2_MODE_IS_INCLUDE;
> -		skb = add_grec(skb, pmc, type, 0, 0);
> +		skb = add_grec(skb, pmc, type, 0, 0, 0);
>   		spin_unlock_bh(&pmc->mca_lock);
>   	}
>   	read_unlock_bh(&idev->lock);
> @@ -1671,13 +1693,13 @@ static void mld_send_cr(struct inet6_dev *idev)
>   		if (pmc->mca_sfmode == MCAST_INCLUDE) {
>   			type = MLD2_BLOCK_OLD_SOURCES;
>   			dtype = MLD2_BLOCK_OLD_SOURCES;
> -			skb = add_grec(skb, pmc, type, 1, 0);
> -			skb = add_grec(skb, pmc, dtype, 1, 1);
> +			skb = add_grec(skb, pmc, type, 1, 0, 0);
> +			skb = add_grec(skb, pmc, dtype, 1, 1, 0);
>   		}
>   		if (pmc->mca_crcount) {
>   			if (pmc->mca_sfmode == MCAST_EXCLUDE) {
>   				type = MLD2_CHANGE_TO_INCLUDE;
> -				skb = add_grec(skb, pmc, type, 1, 0);
> +				skb = add_grec(skb, pmc, type, 1, 0, 0);
>   			}
>   			pmc->mca_crcount--;
>   			if (pmc->mca_crcount == 0) {
> @@ -1708,8 +1730,8 @@ static void mld_send_cr(struct inet6_dev *idev)
>   			type = MLD2_ALLOW_NEW_SOURCES;
>   			dtype = MLD2_BLOCK_OLD_SOURCES;
>   		}
> -		skb = add_grec(skb, pmc, type, 0, 0);
> -		skb = add_grec(skb, pmc, dtype, 0, 1);	/* deleted sources */
> +		skb = add_grec(skb, pmc, type, 0, 0, 0);
> +		skb = add_grec(skb, pmc, dtype, 0, 1, 0);	/* deleted sources */
>
>   		/* filter mode changes */
>   		if (pmc->mca_crcount) {
> @@ -1717,7 +1739,7 @@ static void mld_send_cr(struct inet6_dev *idev)
>   				type = MLD2_CHANGE_TO_EXCLUDE;
>   			else
>   				type = MLD2_CHANGE_TO_INCLUDE;
> -			skb = add_grec(skb, pmc, type, 0, 0);
> +			skb = add_grec(skb, pmc, type, 0, 0, 0);
>   			pmc->mca_crcount--;
>   		}
>   		spin_unlock_bh(&pmc->mca_lock);
> @@ -1825,27 +1847,19 @@ err_out:
>   	goto out;
>   }
>
> -static void mld_resend_report(struct inet6_dev *idev)
> +static void mld_resend_cr(struct inet6_dev *idev)
>   {
> -	if (MLD_V1_SEEN(idev)) {
> -		struct ifmcaddr6 *mcaddr;
> -		read_lock_bh(&idev->lock);
> -		for (mcaddr = idev->mc_list; mcaddr; mcaddr = mcaddr->next) {
> -			if (!(mcaddr->mca_flags & MAF_NOREPORT))
> -				igmp6_send(&mcaddr->mca_addr, idev->dev,
> -					   ICMPV6_MGM_REPORT);
> -		}
> -		read_unlock_bh(&idev->lock);
> -	} else {
> -		mld_send_report(idev, NULL);
> -	}
> +	if (MLD_V1_SEEN(idev))
> +		return;

$ git grep -n MLD_V1_SEEN
$

I believe I have removed that macro some time ago. ;)

I presume you mean rather: mld_in_v1_mode(idev)

> +	mld_send_initial_cr(idev);
>   }
>
>   void ipv6_mc_dad_complete(struct inet6_dev *idev)
>   {
>   	idev->mc_dad_count = idev->mc_qrv;
>   	if (idev->mc_dad_count) {
> -		mld_resend_report(idev);
> +		mld_resend_cr(idev);
>   		idev->mc_dad_count--;
>   		if (idev->mc_dad_count)
>   			mld_dad_start_timer(idev, idev->mc_maxdelay);
> @@ -1856,7 +1870,7 @@ static void mld_dad_timer_expire(unsigned long data)
>   {
>   	struct inet6_dev *idev = (struct inet6_dev *)data;
>
> -	mld_resend_report(idev);
> +	mld_resend_cr(idev);
>   	if (idev->mc_dad_count) {
>   		idev->mc_dad_count--;
>   		if (idev->mc_dad_count)
>
