From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 1/2][NETLABEL]: Shrink the genl-ops registration code.
Date: Wed, 13 Feb 2008 08:33:08 -0500
Message-ID: <200802130833.09096.paul.moore@hp.com>
References: <47B2CFF8.50803@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:45986 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751696AbYBMNdW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2008 08:33:22 -0500
In-Reply-To: <47B2CFF8.50803@openvz.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 13 February 2008 6:09:44 am Pavel Emelyanov wrote:
> Turning them to array and registration in a loop saves
> 80 lines of code and ~300 bytes from text section.
>
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Definitely an improvement, thank you.

Acked-by: Paul Moore <paul.moore@hp.com>

> ---
>  net/netlabel/netlabel_cipso_v4.c  |   43 +++++++------------
>  net/netlabel/netlabel_mgmt.c      |   79 ++++++++++-----------------------
>  net/netlabel/netlabel_unlabeled.c |   86
> ++++++++++-------------------------- 3 files changed, 64 insertions(+), 144
> deletions(-)
>
> diff --git a/net/netlabel/netlabel_cipso_v4.c
> b/net/netlabel/netlabel_cipso_v4.c index c7ad64d..283ff4a 100644
> --- a/net/netlabel/netlabel_cipso_v4.c
> +++ b/net/netlabel/netlabel_cipso_v4.c
> @@ -718,36 +718,35 @@ static int netlbl_cipsov4_remove(struct sk_buff *skb,
> struct genl_info *info) * NetLabel Generic NETLINK Command Definitions
>   */
>
> -static struct genl_ops netlbl_cipsov4_genl_c_add = {
> +static struct genl_ops netlbl_cipsov4_ops[] = {
> +	{
>  	.cmd = NLBL_CIPSOV4_C_ADD,
>  	.flags = GENL_ADMIN_PERM,
>  	.policy = netlbl_cipsov4_genl_policy,
>  	.doit = netlbl_cipsov4_add,
>  	.dumpit = NULL,
> -};
> -
> -static struct genl_ops netlbl_cipsov4_genl_c_remove = {
> +	},
> +	{
>  	.cmd = NLBL_CIPSOV4_C_REMOVE,
>  	.flags = GENL_ADMIN_PERM,
>  	.policy = netlbl_cipsov4_genl_policy,
>  	.doit = netlbl_cipsov4_remove,
>  	.dumpit = NULL,
> -};
> -
> -static struct genl_ops netlbl_cipsov4_genl_c_list = {
> +	},
> +	{
>  	.cmd = NLBL_CIPSOV4_C_LIST,
>  	.flags = 0,
>  	.policy = netlbl_cipsov4_genl_policy,
>  	.doit = netlbl_cipsov4_list,
>  	.dumpit = NULL,
> -};
> -
> -static struct genl_ops netlbl_cipsov4_genl_c_listall = {
> +	},
> +	{
>  	.cmd = NLBL_CIPSOV4_C_LISTALL,
>  	.flags = 0,
>  	.policy = netlbl_cipsov4_genl_policy,
>  	.doit = NULL,
>  	.dumpit = netlbl_cipsov4_listall,
> +	},
>  };
>
>  /*
> @@ -764,28 +763,18 @@ static struct genl_ops netlbl_cipsov4_genl_c_listall
> = { */
>  int netlbl_cipsov4_genl_init(void)
>  {
> -	int ret_val;
> +	int ret_val, i;
>
>  	ret_val = genl_register_family(&netlbl_cipsov4_gnl_family);
>  	if (ret_val != 0)
>  		return ret_val;
>
> -	ret_val = genl_register_ops(&netlbl_cipsov4_gnl_family,
> -				    &netlbl_cipsov4_genl_c_add);
> -	if (ret_val != 0)
> -		return ret_val;
> -	ret_val = genl_register_ops(&netlbl_cipsov4_gnl_family,
> -				    &netlbl_cipsov4_genl_c_remove);
> -	if (ret_val != 0)
> -		return ret_val;
> -	ret_val = genl_register_ops(&netlbl_cipsov4_gnl_family,
> -				    &netlbl_cipsov4_genl_c_list);
> -	if (ret_val != 0)
> -		return ret_val;
> -	ret_val = genl_register_ops(&netlbl_cipsov4_gnl_family,
> -				    &netlbl_cipsov4_genl_c_listall);
> -	if (ret_val != 0)
> -		return ret_val;
> +	for (i = 0; i < ARRAY_SIZE(netlbl_cipsov4_ops); i++) {
> +		ret_val = genl_register_ops(&netlbl_cipsov4_gnl_family,
> +				&netlbl_cipsov4_ops[i]);
> +		if (ret_val != 0)
> +			return ret_val;
> +	}
>
>  	return 0;
>  }
> diff --git a/net/netlabel/netlabel_mgmt.c b/net/netlabel/netlabel_mgmt.c
> index e2258dc..05d9886 100644
> --- a/net/netlabel/netlabel_mgmt.c
> +++ b/net/netlabel/netlabel_mgmt.c
> @@ -517,68 +517,63 @@ version_failure:
>   * NetLabel Generic NETLINK Command Definitions
>   */
>
> -static struct genl_ops netlbl_mgmt_genl_c_add = {
> +static struct genl_ops netlbl_mgmt_genl_ops[] = {
> +	{
>  	.cmd = NLBL_MGMT_C_ADD,
>  	.flags = GENL_ADMIN_PERM,
>  	.policy = netlbl_mgmt_genl_policy,
>  	.doit = netlbl_mgmt_add,
>  	.dumpit = NULL,
> -};
> -
> -static struct genl_ops netlbl_mgmt_genl_c_remove = {
> +	},
> +	{
>  	.cmd = NLBL_MGMT_C_REMOVE,
>  	.flags = GENL_ADMIN_PERM,
>  	.policy = netlbl_mgmt_genl_policy,
>  	.doit = netlbl_mgmt_remove,
>  	.dumpit = NULL,
> -};
> -
> -static struct genl_ops netlbl_mgmt_genl_c_listall = {
> +	},
> +	{
>  	.cmd = NLBL_MGMT_C_LISTALL,
>  	.flags = 0,
>  	.policy = netlbl_mgmt_genl_policy,
>  	.doit = NULL,
>  	.dumpit = netlbl_mgmt_listall,
> -};
> -
> -static struct genl_ops netlbl_mgmt_genl_c_adddef = {
> +	},
> +	{
>  	.cmd = NLBL_MGMT_C_ADDDEF,
>  	.flags = GENL_ADMIN_PERM,
>  	.policy = netlbl_mgmt_genl_policy,
>  	.doit = netlbl_mgmt_adddef,
>  	.dumpit = NULL,
> -};
> -
> -static struct genl_ops netlbl_mgmt_genl_c_removedef = {
> +	},
> +	{
>  	.cmd = NLBL_MGMT_C_REMOVEDEF,
>  	.flags = GENL_ADMIN_PERM,
>  	.policy = netlbl_mgmt_genl_policy,
>  	.doit = netlbl_mgmt_removedef,
>  	.dumpit = NULL,
> -};
> -
> -static struct genl_ops netlbl_mgmt_genl_c_listdef = {
> +	},
> +	{
>  	.cmd = NLBL_MGMT_C_LISTDEF,
>  	.flags = 0,
>  	.policy = netlbl_mgmt_genl_policy,
>  	.doit = netlbl_mgmt_listdef,
>  	.dumpit = NULL,
> -};
> -
> -static struct genl_ops netlbl_mgmt_genl_c_protocols = {
> +	},
> +	{
>  	.cmd = NLBL_MGMT_C_PROTOCOLS,
>  	.flags = 0,
>  	.policy = netlbl_mgmt_genl_policy,
>  	.doit = NULL,
>  	.dumpit = netlbl_mgmt_protocols,
> -};
> -
> -static struct genl_ops netlbl_mgmt_genl_c_version = {
> +	},
> +	{
>  	.cmd = NLBL_MGMT_C_VERSION,
>  	.flags = 0,
>  	.policy = netlbl_mgmt_genl_policy,
>  	.doit = netlbl_mgmt_version,
>  	.dumpit = NULL,
> +	},
>  };
>
>  /*
> @@ -595,44 +590,18 @@ static struct genl_ops netlbl_mgmt_genl_c_version = {
>   */
>  int netlbl_mgmt_genl_init(void)
>  {
> -	int ret_val;
> +	int ret_val, i;
>
>  	ret_val = genl_register_family(&netlbl_mgmt_gnl_family);
>  	if (ret_val != 0)
>  		return ret_val;
>
> -	ret_val = genl_register_ops(&netlbl_mgmt_gnl_family,
> -				    &netlbl_mgmt_genl_c_add);
> -	if (ret_val != 0)
> -		return ret_val;
> -	ret_val = genl_register_ops(&netlbl_mgmt_gnl_family,
> -				    &netlbl_mgmt_genl_c_remove);
> -	if (ret_val != 0)
> -		return ret_val;
> -	ret_val = genl_register_ops(&netlbl_mgmt_gnl_family,
> -				    &netlbl_mgmt_genl_c_listall);
> -	if (ret_val != 0)
> -		return ret_val;
> -	ret_val = genl_register_ops(&netlbl_mgmt_gnl_family,
> -				    &netlbl_mgmt_genl_c_adddef);
> -	if (ret_val != 0)
> -		return ret_val;
> -	ret_val = genl_register_ops(&netlbl_mgmt_gnl_family,
> -				    &netlbl_mgmt_genl_c_removedef);
> -	if (ret_val != 0)
> -		return ret_val;
> -	ret_val = genl_register_ops(&netlbl_mgmt_gnl_family,
> -				    &netlbl_mgmt_genl_c_listdef);
> -	if (ret_val != 0)
> -		return ret_val;
> -	ret_val = genl_register_ops(&netlbl_mgmt_gnl_family,
> -				    &netlbl_mgmt_genl_c_protocols);
> -	if (ret_val != 0)
> -		return ret_val;
> -	ret_val = genl_register_ops(&netlbl_mgmt_gnl_family,
> -				    &netlbl_mgmt_genl_c_version);
> -	if (ret_val != 0)
> -		return ret_val;
> +	for (i = 0; i < ARRAY_SIZE(netlbl_mgmt_genl_ops); i++) {
> +		ret_val = genl_register_ops(&netlbl_mgmt_gnl_family,
> +				&netlbl_mgmt_genl_ops[i]);
> +		if (ret_val != 0)
> +			return ret_val;
> +	}
>
>  	return 0;
>  }
> diff --git a/net/netlabel/netlabel_unlabeled.c
> b/net/netlabel/netlabel_unlabeled.c index 3e745b7..f0f1322 100644
> --- a/net/netlabel/netlabel_unlabeled.c
> +++ b/net/netlabel/netlabel_unlabeled.c
> @@ -1553,68 +1553,63 @@ unlabel_staticlistdef_return:
>   * NetLabel Generic NETLINK Command Definitions
>   */
>
> -static struct genl_ops netlbl_unlabel_genl_c_staticadd = {
> +static struct genl_ops netlbl_unlabel_genl_ops[] = {
> +	{
>  	.cmd = NLBL_UNLABEL_C_STATICADD,
>  	.flags = GENL_ADMIN_PERM,
>  	.policy = netlbl_unlabel_genl_policy,
>  	.doit = netlbl_unlabel_staticadd,
>  	.dumpit = NULL,
> -};
> -
> -static struct genl_ops netlbl_unlabel_genl_c_staticremove = {
> +	},
> +	{
>  	.cmd = NLBL_UNLABEL_C_STATICREMOVE,
>  	.flags = GENL_ADMIN_PERM,
>  	.policy = netlbl_unlabel_genl_policy,
>  	.doit = netlbl_unlabel_staticremove,
>  	.dumpit = NULL,
> -};
> -
> -static struct genl_ops netlbl_unlabel_genl_c_staticlist = {
> +	},
> +	{
>  	.cmd = NLBL_UNLABEL_C_STATICLIST,
>  	.flags = 0,
>  	.policy = netlbl_unlabel_genl_policy,
>  	.doit = NULL,
>  	.dumpit = netlbl_unlabel_staticlist,
> -};
> -
> -static struct genl_ops netlbl_unlabel_genl_c_staticadddef = {
> +	},
> +	{
>  	.cmd = NLBL_UNLABEL_C_STATICADDDEF,
>  	.flags = GENL_ADMIN_PERM,
>  	.policy = netlbl_unlabel_genl_policy,
>  	.doit = netlbl_unlabel_staticadddef,
>  	.dumpit = NULL,
> -};
> -
> -static struct genl_ops netlbl_unlabel_genl_c_staticremovedef = {
> +	},
> +	{
>  	.cmd = NLBL_UNLABEL_C_STATICREMOVEDEF,
>  	.flags = GENL_ADMIN_PERM,
>  	.policy = netlbl_unlabel_genl_policy,
>  	.doit = netlbl_unlabel_staticremovedef,
>  	.dumpit = NULL,
> -};
> -
> -static struct genl_ops netlbl_unlabel_genl_c_staticlistdef = {
> +	},
> +	{
>  	.cmd = NLBL_UNLABEL_C_STATICLISTDEF,
>  	.flags = 0,
>  	.policy = netlbl_unlabel_genl_policy,
>  	.doit = NULL,
>  	.dumpit = netlbl_unlabel_staticlistdef,
> -};
> -
> -static struct genl_ops netlbl_unlabel_genl_c_accept = {
> +	},
> +	{
>  	.cmd = NLBL_UNLABEL_C_ACCEPT,
>  	.flags = GENL_ADMIN_PERM,
>  	.policy = netlbl_unlabel_genl_policy,
>  	.doit = netlbl_unlabel_accept,
>  	.dumpit = NULL,
> -};
> -
> -static struct genl_ops netlbl_unlabel_genl_c_list = {
> +	},
> +	{
>  	.cmd = NLBL_UNLABEL_C_LIST,
>  	.flags = 0,
>  	.policy = netlbl_unlabel_genl_policy,
>  	.doit = netlbl_unlabel_list,
>  	.dumpit = NULL,
> +	},
>  };
>
>  /*
> @@ -1631,51 +1626,18 @@ static struct genl_ops netlbl_unlabel_genl_c_list =
> { */
>  int netlbl_unlabel_genl_init(void)
>  {
> -	int ret_val;
> +	int ret_val, i;
>
>  	ret_val = genl_register_family(&netlbl_unlabel_gnl_family);
>  	if (ret_val != 0)
>  		return ret_val;
>
> -	ret_val = genl_register_ops(&netlbl_unlabel_gnl_family,
> -				    &netlbl_unlabel_genl_c_staticadd);
> -	if (ret_val != 0)
> -		return ret_val;
> -
> -	ret_val = genl_register_ops(&netlbl_unlabel_gnl_family,
> -				    &netlbl_unlabel_genl_c_staticremove);
> -	if (ret_val != 0)
> -		return ret_val;
> -
> -	ret_val = genl_register_ops(&netlbl_unlabel_gnl_family,
> -				    &netlbl_unlabel_genl_c_staticlist);
> -	if (ret_val != 0)
> -		return ret_val;
> -
> -	ret_val = genl_register_ops(&netlbl_unlabel_gnl_family,
> -				    &netlbl_unlabel_genl_c_staticadddef);
> -	if (ret_val != 0)
> -		return ret_val;
> -
> -	ret_val = genl_register_ops(&netlbl_unlabel_gnl_family,
> -				    &netlbl_unlabel_genl_c_staticremovedef);
> -	if (ret_val != 0)
> -		return ret_val;
> -
> -	ret_val = genl_register_ops(&netlbl_unlabel_gnl_family,
> -				    &netlbl_unlabel_genl_c_staticlistdef);
> -	if (ret_val != 0)
> -		return ret_val;
> -
> -	ret_val = genl_register_ops(&netlbl_unlabel_gnl_family,
> -				    &netlbl_unlabel_genl_c_accept);
> -	if (ret_val != 0)
> -		return ret_val;
> -
> -	ret_val = genl_register_ops(&netlbl_unlabel_gnl_family,
> -				    &netlbl_unlabel_genl_c_list);
> -	if (ret_val != 0)
> -		return ret_val;
> +	for (i = 0; i < ARRAY_SIZE(netlbl_unlabel_genl_ops); i++) {
> +		ret_val = genl_register_ops(&netlbl_unlabel_gnl_family,
> +				&netlbl_unlabel_genl_ops[i]);
> +		if (ret_val != 0)
> +			return ret_val;
> +	}
>
>  	return 0;
>  }



-- 
paul moore
linux security @ hp
