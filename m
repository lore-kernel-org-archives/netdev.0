From: Jan Kara <jack@suse.cz>
Subject: Re: [RFC 3/8] quota/genetlink: use proper genetlink multicast APIs
Date: Mon, 18 Nov 2013 13:34:03 +0100
Message-ID: <20131118123403.GC3921@quack.suse.cz>
References: <1384621429-24543-1-git-send-email-johannes@sipsolutions.net>
 <1384621429-24543-4-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Johannes Berg <johannes.berg@intel.com>,
	Jan Kara <jack@suse.cz>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:54138 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751266Ab3KRMeF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Nov 2013 07:34:05 -0500
Content-Disposition: inline
In-Reply-To: <1384621429-24543-4-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat 16-11-13 18:03:44, Johannes Berg wrote:
> From: Johannes Berg <johannes.berg@intel.com>
> 
> The quota code is abusing the genetlink API and is using
> its family ID as the multicast group ID, which is invalid
> and may belong to somebody else (and likely will.)
> 
> Make the quota code use the correct API, but since this
> is already used as-is by userspace, reserve a family ID
> for this code and also reserve that group ID to not break
> userspace assumptions.
  Ah, sorry for messing that up. When I was writing this, libnl didn't have
support for multicast groups and so I didn't figure out from its documentation
there are any multicast groups at all... I'd also mention that
documentation of generic netlink at
http://www.linuxfoundation.org/collaborate/workgroups/networking/generic_netlink_howto
(pointed to from Documenation/networking/generic_netlink.txt) doesn't
mention anything about multicast groups either. So chances for messing
things up are pretty high...

Anyway, I'll fix quota_nld (userspace daemon consuming quota netlink
messages) to use multicast groups properly with a fallback to previous
behavior in case that fails (to keep compatibility with older kernels) and
since I don't believe anyone else is using this interface (and even
quota_nld isn't widely used), I think we can remove this hack from generic
netlink layer in a couple of years (hurray to a paragraph long sentence
;).

Thanks for fixing this and you can add:
Acked-by: Jan Kara <jack@suse.cz>

								Honza
> 
> Cc: Jan Kara <jack@suse.cz>
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>
> ---
>  fs/quota/netlink.c             | 17 +++++++++++++++--
>  include/uapi/linux/genetlink.h |  1 +
>  net/netlink/genetlink.c        | 10 ++++++++--
>  3 files changed, 24 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/quota/netlink.c b/fs/quota/netlink.c
> index 16e8abb..b261ce4 100644
> --- a/fs/quota/netlink.c
> +++ b/fs/quota/netlink.c
> @@ -11,13 +11,23 @@
>  
>  /* Netlink family structure for quota */
>  static struct genl_family quota_genl_family = {
> -	.id = GENL_ID_GENERATE,
> +	/*
> +	 * Needed due to multicast group ID abuse - old code assumed
> +	 * the family ID was also a valid multicast group ID (which
> +	 * isn't true) and userspace might thus rely on it. Assign a
> +	 * static ID for this group to make dealing with that easier.
> +	 */
> +	.id = GENL_ID_VFS_DQUOT,
>  	.hdrsize = 0,
>  	.name = "VFS_DQUOT",
>  	.version = 1,
>  	.maxattr = QUOTA_NL_A_MAX,
>  };
>  
> +static struct genl_multicast_group quota_mcgrp = {
> +	.name = "VFS_DQUOT", /* not really used */
> +};
> +
>  /**
>   * quota_send_warning - Send warning to userspace about exceeded quota
>   * @type: The quota type: USRQQUOTA, GRPQUOTA,...
> @@ -78,7 +88,7 @@ void quota_send_warning(struct kqid qid, dev_t dev,
>  		goto attr_err_out;
>  	genlmsg_end(skb, msg_head);
>  
> -	genlmsg_multicast(skb, 0, quota_genl_family.id, GFP_NOFS);
> +	genlmsg_multicast(skb, 0, quota_mcgrp.id, GFP_NOFS);
>  	return;
>  attr_err_out:
>  	printk(KERN_ERR "VFS: Not enough space to compose quota message!\n");
> @@ -92,6 +102,9 @@ static int __init quota_init(void)
>  	if (genl_register_family(&quota_genl_family) != 0)
>  		printk(KERN_ERR
>  		       "VFS: Failed to create quota netlink interface.\n");
> +	if (genl_register_mc_group(&quota_genl_family, &quota_mcgrp))
> +		printk(KERN_ERR
> +		       "VFS: Failed to register quota mcast group.\n");
>  	return 0;
>  };
>  
> diff --git a/include/uapi/linux/genetlink.h b/include/uapi/linux/genetlink.h
> index c880a41..1af72d82 100644
> --- a/include/uapi/linux/genetlink.h
> +++ b/include/uapi/linux/genetlink.h
> @@ -27,6 +27,7 @@ struct genlmsghdr {
>   */
>  #define GENL_ID_GENERATE	0
>  #define GENL_ID_CTRL		NLMSG_MIN_TYPE
> +#define GENL_ID_VFS_DQUOT	(NLMSG_MIN_TYPE + 1)
>  
>  /**************************************************************************
>   * Controller
> diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
> index 8a2ed2c..d0757c6 100644
> --- a/net/netlink/genetlink.c
> +++ b/net/netlink/genetlink.c
> @@ -69,8 +69,11 @@ static struct list_head family_ht[GENL_FAM_TAB_SIZE];
>   * abuses the API and thinks it can statically use group 1.
>   * That group will typically conflict with other groups that
>   * any proper users use.
> + * Bit 17 is marked as already used since the VFS quota code
> + * also abused this API and relied on family == group ID, we
> + * cater to that by giving it a static family and group ID.
>   */
> -static unsigned long mc_group_start = 0x3;
> +static unsigned long mc_group_start = 0x3 | BIT(GENL_ID_VFS_DQUOT);
>  static unsigned long *mc_groups = &mc_group_start;
>  static unsigned long mc_groups_longs = 1;
>  
> @@ -130,7 +133,8 @@ static u16 genl_generate_id(void)
>  	int i;
>  
>  	for (i = 0; i <= GENL_MAX_ID - GENL_MIN_ID; i++) {
> -		if (!genl_family_find_byid(id_gen_idx))
> +		if (id_gen_idx != GENL_ID_VFS_DQUOT &&
> +		    !genl_family_find_byid(id_gen_idx))
>  			return id_gen_idx;
>  		if (++id_gen_idx > GENL_MAX_ID)
>  			id_gen_idx = GENL_MIN_ID;
> @@ -169,6 +173,8 @@ int genl_register_mc_group(struct genl_family *family,
>  		id = GENL_ID_CTRL;
>  	else if (strcmp(family->name, "NET_DM") == 0)
>  		id = 1;
> +	else if (strcmp(family->name, "VFS_DQUOT") == 0)
> +		id = GENL_ID_VFS_DQUOT;
>  	else
>  		id = find_first_zero_bit(mc_groups,
>  					 mc_groups_longs * BITS_PER_LONG);
> -- 
> 1.8.4.rc3
> 
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR
