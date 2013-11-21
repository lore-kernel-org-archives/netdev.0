From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 7/8] openvswitch: Drop user features if old
 user space attempted to create datapath
Date: Thu, 21 Nov 2013 18:23:17 +0000
Message-ID: <1385058197.1586.15.camel@bwh-desktop.uk.level5networks.com>
References: <cover.1385057355.git.tgraf@suug.ch>
	 <68ddfb6e0ef4401f246f2599ade5c15b25063736.1385057355.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <jesse@nicira.com>, <davem@davemloft.net>, <dev@openvswitch.org>,
	<netdev@vger.kernel.org>, <dborkman@redhat.com>,
	<ffusco@redhat.com>, <fleitner@redhat.com>,
	<eric.dumazet@gmail.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:30252 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753041Ab3KUSXX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 13:23:23 -0500
In-Reply-To: <68ddfb6e0ef4401f246f2599ade5c15b25063736.1385057355.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-21 at 19:13 +0100, Thomas Graf wrote:
> Drop user features if an outdated user space instance that does not
> understand the concept of user_features attempted to create a new
> datapath.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> Reviewed-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  include/uapi/linux/openvswitch.h | 11 ++++++++++-
>  net/openvswitch/datapath.c       | 10 ++++++++++
>  2 files changed, 20 insertions(+), 1 deletion(-)
> 
> diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
> index 07ef2c3..4f74c2c 100644
> --- a/include/uapi/linux/openvswitch.h
> +++ b/include/uapi/linux/openvswitch.h
> @@ -40,7 +40,16 @@ struct ovs_header {
>  
>  #define OVS_DATAPATH_FAMILY  "ovs_datapath"
>  #define OVS_DATAPATH_MCGROUP "ovs_datapath"
> -#define OVS_DATAPATH_VERSION 0x1
> +
> +/**
> + * V2:

This is not kernel-doc format so don't use '/**'.

> + *   - API users are expected to provide OVS_DP_ATTR_USER_FEATURES
> + *     with NLM_F_REPLACE when creating the datapath.
> + */
> +#define OVS_DATAPATH_VERSION 2
> +
> +/* First OVS datapath version to support features */
> +#define OVS_DP_VER_FEATURES 2
>  
>  enum ovs_datapath_cmd {
>  	OVS_DP_CMD_UNSPEC,
> diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
> index 3f1fb87..72cdffb 100644
> --- a/net/openvswitch/datapath.c
> +++ b/net/openvswitch/datapath.c
> @@ -1198,6 +1198,16 @@ static int ovs_dp_create_or_update(struct sk_buff *skb, struct genl_info *info,
>  		if (info->nlhdr->nlmsg_flags & NLM_F_REPLACE)
>  			goto update;
>  
> +		/* An outdated user space instance that does not understand
> +		 * the concept of user_features has attempted to create a new
> +		 * datapath. Drop all user features.
> +		 */
> +		if (info->genlhdr->version < OVS_DP_VER_FEATURES) {
> +			WARN_ONCE(dp->user_features, "Dropping previously "
> +				  "announced user features");

Log messages shouldn't be split like this as it makes them harder to
find.  There should also be a newline at the end of the message.

Ben.

> +			dp->user_features = 0;
> +		}
> +
>  		err = -EEXIST;
>  		goto err_unlock_ovs;
>  	}

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
