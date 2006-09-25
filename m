From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 5/6] NetLabel: rework the Netlink attribute handling (part 2)
Date: Mon, 25 Sep 2006 11:43:11 +0200
Message-ID: <20060925094311.GO18349@postel.suug.ch>
References: <20060921165703.251871000@hp.com> <20060921170337.744519000@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: selinux@tycho.nsa.gov, netdev@vger.kernel.org, sds@epoch.ncsc.mil,
	jmorris@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:19873 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1750798AbWIYJmv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 05:42:51 -0400
To: paul.moore@hp.com
Content-Disposition: inline
In-Reply-To: <20060921170337.744519000@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* paul.moore@hp.com <paul.moore@hp.com> 2006-09-21 12:57
> At the suggestion of Thomas Graf, rewrite NetLabel's use of Netlink attributes
> to better follow the common Netlink attribute usage.
> 
> Signed-off-by: Paul Moore <paul.moore@hp.com>
> ---
>  net/netlabel/netlabel_cipso_v4.c  |  593 +++++++++++++++++++++++++-------------
>  net/netlabel/netlabel_cipso_v4.h  |  235 +++++----------
>  net/netlabel/netlabel_mgmt.c      |  531 +++++++++++++++++-----------------
>  net/netlabel/netlabel_mgmt.h      |  213 ++++---------
>  net/netlabel/netlabel_unlabeled.c |   77 ++--
>  net/netlabel/netlabel_unlabeled.h |   41 +-
>  6 files changed, 875 insertions(+), 815 deletions(-)
> 
> Index: net-2.6.19/net/netlabel/netlabel_cipso_v4.c
> ===================================================================
> --- net-2.6.19.orig/net/netlabel/netlabel_cipso_v4.c
> +++ net-2.6.19/net/netlabel/netlabel_cipso_v4.c
> @@ -41,15 +41,37 @@
>  #include "netlabel_user.h"
>  #include "netlabel_cipso_v4.h"
>  
> +/* Argument struct for cipso_v4_doi_walk() */
> +struct netlbl_cipsov4_doiwalk_arg {
> +	struct netlink_callback *nl_cb;
> +	struct sk_buff *skb;
> +	u32 seq;
> +};
> +
>  /* NetLabel Generic NETLINK CIPSOv4 family */
>  static struct genl_family netlbl_cipsov4_gnl_family = {
>  	.id = GENL_ID_GENERATE,
>  	.hdrsize = 0,
>  	.name = NETLBL_NLTYPE_CIPSOV4_NAME,
>  	.version = NETLBL_PROTO_VERSION,
> -	.maxattr = 0,
> +	.maxattr = NLBL_CIPSOV4_A_MAX,
>  };
>  
> +/* NetLabel Netlink attribute policy */
> +static struct nla_policy netlbl_cipsov4_genl_policy[NLBL_CIPSOV4_A_MAX + 1] = {
> +	[NLBL_CIPSOV4_A_DOI] = { .type = NLA_U32 },
> +	[NLBL_CIPSOV4_A_MTYPE] = { .type = NLA_U32 },
> +	[NLBL_CIPSOV4_A_TAG] = { .type = NLA_U8 },
> +	[NLBL_CIPSOV4_A_TAGLST] = { .type = NLA_NESTED },
> +	[NLBL_CIPSOV4_A_MLSLVLLOC] = { .type = NLA_U32 },
> +	[NLBL_CIPSOV4_A_MLSLVLREM] = { .type = NLA_U32 },
> +	[NLBL_CIPSOV4_A_MLSLVL] = { .type = NLA_NESTED },
> +	[NLBL_CIPSOV4_A_MLSLVLLST] = { .type = NLA_NESTED },
> +	[NLBL_CIPSOV4_A_MLSCATLOC] = { .type = NLA_U32 },
> +	[NLBL_CIPSOV4_A_MLSCATREM] = { .type = NLA_U32 },
> +	[NLBL_CIPSOV4_A_MLSCAT] = { .type = NLA_NESTED },
> +	[NLBL_CIPSOV4_A_MLSCATLST] = { .type = NLA_NESTED },
> +};
>  
>  /*
>   * Helper Functions
> @@ -81,16 +103,13 @@ static void netlbl_cipsov4_doi_free(stru
>  	kfree(ptr);
>  }
>  
> -
>  /*
>   * NetLabel Command Handlers
>   */
>  
>  /**
>   * netlbl_cipsov4_add_std - Adds a CIPSO V4 DOI definition
> - * @doi: the DOI value
> - * @msg: the ADD message data
> - * @msg_size: the size of the ADD message buffer
> + * @info: the Generic NETLINK info block
>   *
>   * Description:
>   * Create a new CIPSO_V4_MAP_STD DOI definition based on the given ADD message
> @@ -98,22 +117,31 @@ static void netlbl_cipsov4_doi_free(stru
>   * error.
>   *
>   */
> -static int netlbl_cipsov4_add_std(u32 doi, struct nlattr *msg, size_t msg_size)
> +static int netlbl_cipsov4_add_std(struct genl_info *info)
>  {
>  	int ret_val = -EINVAL;
> -	int msg_len = msg_size;
> -	u32 num_tags;
> -	u32 num_lvls;
> -	u32 num_cats;
>  	struct cipso_v4_doi *doi_def = NULL;
> -	u32 iter;
> -	u32 tmp_val_a;
> -	u32 tmp_val_b;
> -
> -	if (msg_len < NETLBL_LEN_U32)
> -		goto add_std_failure;
> -	num_tags = netlbl_getinc_u32(&msg, &msg_len);
> -	if (num_tags == 0 || num_tags > CIPSO_V4_TAG_MAXCNT)
> +	struct nlattr *nla_a;
> +	struct nlattr *nla_b;
> +	struct nlattr *nla_c;
> +	int nla_a_rem;
> +	int nla_b_rem;
> +	u32 iter = 0;
> +
> +	if (!info->attrs[NLBL_CIPSOV4_A_DOI] ||
> +	    !info->attrs[NLBL_CIPSOV4_A_TAGLST] ||
> +	    !info->attrs[NLBL_CIPSOV4_A_MLSLVLLST])
> +		goto add_std_failure;
> +
> +	if (nla_validate(nla_data(info->attrs[NLBL_CIPSOV4_A_TAGLST]),
> +			 nla_len(info->attrs[NLBL_CIPSOV4_A_TAGLST]),
> +			 NLBL_CIPSOV4_A_MAX,
> +			 netlbl_cipsov4_genl_policy) != 0)
> +		goto add_std_failure;
> +	if (nla_validate(nla_data(info->attrs[NLBL_CIPSOV4_A_MLSLVLLST]),
> +			 nla_len(info->attrs[NLBL_CIPSOV4_A_MLSLVLLST]),
> +			 NLBL_CIPSOV4_A_MAX,
> +			 netlbl_cipsov4_genl_policy) != 0)
>  		goto add_std_failure;
>  
>  	doi_def = kmalloc(sizeof(*doi_def), GFP_KERNEL);
> @@ -128,28 +156,44 @@ static int netlbl_cipsov4_add_std(u32 do
>  	}
>  	doi_def->type = CIPSO_V4_MAP_STD;
>  
> -	for (iter = 0; iter < num_tags; iter++) {
> -		if (msg_len < NETLBL_LEN_U8)
> -			goto add_std_failure;
> -		doi_def->tags[iter] = netlbl_getinc_u8(&msg, &msg_len);
> -		switch (doi_def->tags[iter]) {
> -		case CIPSO_V4_TAG_RBITMAP:
> -			break;
> -		default:
> -			goto add_std_failure;
> +	nla_for_each_attr(nla_a,
> +			  nla_data(info->attrs[NLBL_CIPSOV4_A_TAGLST]),
> +			  nla_len(info->attrs[NLBL_CIPSOV4_A_TAGLST]),
> +			  nla_a_rem)

You can use nla_for_each_nested() here.

> +		if (nla_a->nla_type == NLBL_CIPSOV4_A_TAG) {
> +			if (iter > CIPSO_V4_TAG_MAXCNT)
> +				goto add_std_failure;
> +			doi_def->tags[iter++] = nla_get_u8(nla_a);
>  		}

Perfectly validated against generic policy yet flexible, I
like this a lot.


> +	nla_for_each_attr(nla_a,
> +			  nla_data(info->attrs[NLBL_CIPSOV4_A_MLSLVLLST]),
> +			  nla_len(info->attrs[NLBL_CIPSOV4_A_MLSLVLLST]),
> +			  nla_a_rem)

Could use nla_for_each_nested() here as well.

> +		if (nla_a->nla_type == NLBL_CIPSOV4_A_MLSLVL) {
> +			nla_for_each_attr(nla_b,
> +					  nla_data(nla_a),
> +					  nla_len(nla_a),
> +					  nla_b_rem)

... and again :-)

> +				switch (nla_b->nla_type) {
> +				case NLBL_CIPSOV4_A_MLSLVLLOC:
> +					if (nla_get_u32(nla_b) >=

Attributes on this level are not yet validated. 

> +					    doi_def->map.std->lvl.local_size)
> +					     doi_def->map.std->lvl.local_size =
> +						     nla_get_u32(nla_b) + 1;
> +					break;
> +				case NLBL_CIPSOV4_A_MLSLVLREM:
> +					if (nla_get_u32(nla_b) >=
> +					    doi_def->map.std->lvl.cipso_size)
> +					     doi_def->map.std->lvl.cipso_size =
> +						     nla_get_u32(nla_b) + 1;
> +					break;
> +				}
> +		}
> @@ -168,68 +209,96 @@ static int netlbl_cipsov4_add_std(u32 do
>  		ret_val = -ENOMEM;
>  		goto add_std_failure;
>  	}
> +	nla_for_each_attr(nla_a,
> +			  nla_data(info->attrs[NLBL_CIPSOV4_A_MLSLVLLST]),
> +			  nla_len(info->attrs[NLBL_CIPSOV4_A_MLSLVLLST]),
> +			  nla_a_rem)

> +		if (nla_a->nla_type == NLBL_CIPSOV4_A_MLSLVL) {
> +			nla_b = nla_find_nested(nla_a,
> +						NLBL_CIPSOV4_A_MLSLVLLOC);
> +			nla_c = nla_find_nested(nla_a,
> +						NLBL_CIPSOV4_A_MLSLVLREM);

Maybe find better names for nla_a and nla_b, would enhance readability

> +			if (nla_b == NULL || nla_c == NULL)
> +				goto add_std_failure;
> +			doi_def->map.std->lvl.local[nla_get_u32(nla_b)] =
> +				nla_get_u32(nla_c);
> +			doi_def->map.std->lvl.cipso[nla_get_u32(nla_c)] =
> +				nla_get_u32(nla_b);
> +		}
>  
> -	num_cats = netlbl_getinc_u32(&msg, &msg_len);
> -	doi_def->map.std->cat.local_size = netlbl_getinc_u32(&msg, &msg_len);
> -	if (doi_def->map.std->cat.local_size > CIPSO_V4_MAX_LOC_CATS)
> -		goto add_std_failure;
> -	doi_def->map.std->cat.local = kcalloc(doi_def->map.std->cat.local_size,
> +	if (info->attrs[NLBL_CIPSOV4_A_MLSCATLST]) {
> +		if (nla_validate(
> +			    nla_data(info->attrs[NLBL_CIPSOV4_A_MLSCATLST]),
> +			    nla_len(info->attrs[NLBL_CIPSOV4_A_MLSCATLST]),
> +			    NLBL_CIPSOV4_A_MAX,
> +			    netlbl_cipsov4_genl_policy) != 0)

We might want to add nla_validate_nested() to the interface as this seems
to become a common usage.


> @@ -276,21 +345,20 @@ static int netlbl_cipsov4_add_pass(u32 d
>  	}
>  	doi_def->type = CIPSO_V4_MAP_PASS;
>  
> -	for (iter = 0; iter < num_tags; iter++) {
> -		if (msg_len < NETLBL_LEN_U8)
> -			goto add_pass_failure;
> -		doi_def->tags[iter] = netlbl_getinc_u8(&msg, &msg_len);
> -		switch (doi_def->tags[iter]) {
> -		case CIPSO_V4_TAG_RBITMAP:
> -			break;
> -		default:
> -			goto add_pass_failure;
> +	nla_for_each_attr(nla,
> +			  nla_data(info->attrs[NLBL_CIPSOV4_A_TAGLST]),
> +			  nla_len(info->attrs[NLBL_CIPSOV4_A_TAGLST]),
> +			  nla_rem)
> +		if (nla->nla_type == NLBL_CIPSOV4_A_TAG) {
> +			if (iter > CIPSO_V4_TAG_MAXCNT)
> +				goto add_pass_failure;
> +			doi_def->tags[iter++] = nla_get_u8(nla);
>  		}

This is duplicated code, put this into netlbl_cipsov4_get_tags()?



> @@ -353,84 +408,237 @@ add_return:
>   * @info: the Generic NETLINK info block
>   *
>   * Description:
> - * Process a user generated LIST message and respond accordingly.  Returns
> - * zero on success and negative values on error.
> + * Process a user generated LIST message and respond accordingly.  While the
> + * response message generated by the kernel is straightforward, determining
> + * before hand the size of the buffer to allocate is not (we have to generate
> + * the message to know the size).  In order to keep this function sane what we
> + * do is allocate a buffer of NLMSG_GOODSIZE and try to fit the response in
> + * that size, if we fail then we restart with a larger buffer and try again.
> + * We continue in this manner until we hit a limit of failed attempts then we
> + * give up and just send an error message.  Returns zero on success and
> + * negative values on error.
>   *
>   */
>  static int netlbl_cipsov4_list(struct sk_buff *skb, struct genl_info *info)
>  {
> -	int ret_val = -EINVAL;
> +	int ret_val;
> +	struct sk_buff *ans_skb = NULL;
> +	u32 nlsze_mult = 1;
> +	void *data;
>  	u32 doi;
> -	struct nlattr *msg = netlbl_netlink_payload_data(skb);
> -	struct sk_buff *ans_skb;
> +	struct nlattr *nla_a;
> +	struct nlattr *nla_b;
> +	struct cipso_v4_doi *doi_def;
> +	u32 iter;
>  
> -	if (netlbl_netlink_payload_len(skb) != NETLBL_LEN_U32)
> +	if (!info->attrs[NLBL_CIPSOV4_A_DOI]) {
> +		ret_val = -EINVAL;
>  		goto list_failure;
> +	}
>  
> -	doi = nla_get_u32(msg);
> -	ans_skb = cipso_v4_doi_dump(doi, NLMSG_SPACE(GENL_HDRLEN));
> +list_start:
> +	ans_skb = nlmsg_new(NLMSG_GOODSIZE * nlsze_mult, GFP_KERNEL);
>  	if (ans_skb == NULL) {
>  		ret_val = -ENOMEM;
>  		goto list_failure;
>  	}
> -	netlbl_netlink_hdr_push(ans_skb,
> -				info->snd_pid,
> -				0,
> -				netlbl_cipsov4_gnl_family.id,
> -				NLBL_CIPSOV4_C_LIST);
> +	data = netlbl_netlink_hdr_put(ans_skb,
> +				      info->snd_pid,
> +				      info->snd_seq,
> +				      netlbl_cipsov4_gnl_family.id,
> +				      0,
> +				      NLBL_CIPSOV4_C_LIST);
> +	if (data == NULL) {
> +		ret_val = -ENOMEM;
> +		goto list_failure;
> +	}
> +
> +	doi = nla_get_u32(info->attrs[NLBL_CIPSOV4_A_DOI]);
> +
> +	rcu_read_lock();
> +	doi_def = cipso_v4_doi_getdef(doi);
> +	if (doi_def == NULL) {
> +		ret_val = -EINVAL;
> +		goto list_failure;
> +	}
> +
> +	ret_val = nla_put_u32(ans_skb, NLBL_CIPSOV4_A_MTYPE, doi_def->type);
> +	if (ret_val != 0)
> +		goto list_failure_lock;
> +
> +	nla_a = nla_nest_start(ans_skb, NLBL_CIPSOV4_A_TAGLST);
> +	if (nla_a == NULL) {
> +		ret_val = -ENOMEM;
> +		goto list_failure_lock;
> +	}
> +	for (iter = 0;
> +	     iter < CIPSO_V4_TAG_MAXCNT &&
> +	       doi_def->tags[iter] != CIPSO_V4_TAG_INVALID;
> +	     iter++) {
> +		ret_val = nla_put_u8(ans_skb,
> +				     NLBL_CIPSOV4_A_TAG,
> +				     doi_def->tags[iter]);
> +		if (ret_val != 0)
> +			goto list_failure_lock;
> +	}
> +	nla_nest_end(ans_skb, nla_a);
>  
> -	ret_val = netlbl_netlink_snd(ans_skb, info->snd_pid);
> +	switch (doi_def->type) {
> +	case CIPSO_V4_MAP_STD:
> +		nla_a = nla_nest_start(ans_skb, NLBL_CIPSOV4_A_MLSLVLLST);
> +		if (nla_a == NULL) {
> +			ret_val = -ENOMEM;
> +			goto list_failure_lock;
> +		}
> +		for (iter = 0;
> +		     iter < doi_def->map.std->lvl.local_size;
> +		     iter++) {
> +			if (doi_def->map.std->lvl.local[iter] ==
> +			    CIPSO_V4_INV_LVL)
> +				continue;

Can you estimate the number of entries being dumped here and in the cat
list below?

> +
> +			nla_b = nla_nest_start(ans_skb, NLBL_CIPSOV4_A_MLSLVL);
> +			if (nla_b == NULL) {
> +				ret_val = -ENOMEM;
> +				goto list_retry;
> +			}
> +			ret_val = nla_put_u32(ans_skb,
> +					      NLBL_CIPSOV4_A_MLSLVLLOC,
> +					      iter);
> +			if (ret_val != 0)
> +				goto list_retry;
> +			ret_val = nla_put_u32(ans_skb,
> +					    NLBL_CIPSOV4_A_MLSLVLREM,
> +					    doi_def->map.std->lvl.local[iter]);
> +			if (ret_val != 0)
> +				goto list_retry;
> +			nla_nest_end(ans_skb, nla_b);
> +		}
> +		nla_nest_end(ans_skb, nla_a);
> +
> +		nla_a = nla_nest_start(ans_skb, NLBL_CIPSOV4_A_MLSCATLST);
> +		if (nla_a == NULL) {
> +			ret_val = -ENOMEM;
> +			goto list_retry;
> +		}
> +		for (iter = 0;
> +		     iter < doi_def->map.std->cat.local_size;
> +		     iter++) {
> +			if (doi_def->map.std->cat.local[iter] ==
> +			    CIPSO_V4_INV_CAT)
> +				continue;
> +
> +			nla_b = nla_nest_start(ans_skb, NLBL_CIPSOV4_A_MLSCAT);
> +			if (nla_b == NULL) {
> +				ret_val = -ENOMEM;
> +				goto list_retry;
> +			}
> +			ret_val = nla_put_u32(ans_skb,
> +					      NLBL_CIPSOV4_A_MLSCATLOC,
> +					      iter);
> +			if (ret_val != 0)
> +				goto list_retry;
> +			ret_val = nla_put_u32(ans_skb,
> +					    NLBL_CIPSOV4_A_MLSCATREM,
> +					    doi_def->map.std->cat.local[iter]);
> +			if (ret_val != 0)
> +				goto list_retry;
> +			nla_nest_end(ans_skb, nla_b);
> +		}
> +		nla_nest_end(ans_skb, nla_a);
> +
> +		break;
> +	}
> +	rcu_read_unlock();

What I meant in the previous posting is to put genlmsg_end() in here
like the rest of the code to be clear and symmetric.

The rest of the code has simliar issues, nevertheless this looks
really great. Everything is extendable and relatively easy to
maintain. This should definitely go into 2.6.19. Good work.
