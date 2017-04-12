From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch iproute2/net-next repost] devlink: Add support for
 pipeline debug (dpipe)
Date: Wed, 12 Apr 2017 16:45:25 -0700
Message-ID: <20170412164525.1c0468d0@xeon-e3>
References: <1490714657-6116-1-git-send-email-jiri@resnulli.us>
        <1490714814-6724-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, arkadis@mellanox.com,
        idosch@mellanox.com, mlxsw@mellanox.com, jhs@mojatatu.com,
        ivecera@redhat.com, roopa@cumulusnetworks.com,
        f.fainelli@gmail.com, vivien.didelot@savoirfairelinux.com,
        john.fastabend@gmail.com, andrew@lunn.ch,
        simon.horman@netronome.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:35338 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754721AbdDLXp2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 19:45:28 -0400
Received: by mail-pg0-f53.google.com with SMTP id 72so13382722pge.2
        for <netdev@vger.kernel.org>; Wed, 12 Apr 2017 16:45:28 -0700 (PDT)
In-Reply-To: <1490714814-6724-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 28 Mar 2017 17:26:54 +0200
Jiri Pirko <jiri@resnulli.us> wrote:

>  
>  #define pr_err(args...) fprintf(stderr, ##args)
> -#define pr_out(args...) fprintf(stdout, ##args)
> +#define pr_out(args...)						\
> +	do {							\
> +		if (g_indent_newline) {				\
> +			fprintf(stdout, "%s", g_indent_str);	\
> +			g_indent_newline = false;		\
> +		}						\
> +		fprintf(stdout, ##args);			\
> +	} while (0)
> +
>  #define pr_out_sp(num, args...)					\
>  	do {							\
>  		int ret = fprintf(stdout, ##args);		\
> @@ -42,6 +50,35 @@
>  			fprintf(stdout, "%*s", num - ret, "");	\
>  	} while (0)
>  
> +static int g_indent_level;
> +static bool g_indent_newline;
> +#define INDENT_STR_STEP 2
> +#define INDENT_STR_MAXLEN 32
> +static char g_indent_str[INDENT_STR_MAXLEN + 1] = "";
> +
> +static void __pr_out_indent_inc(void)
> +{
> +	if (g_indent_level + INDENT_STR_STEP > INDENT_STR_MAXLEN)
> +		return;
> +	g_indent_level += INDENT_STR_STEP;
> +	memset(g_indent_str, ' ', sizeof(g_indent_str));
> +	g_indent_str[g_indent_level] = '\0';
> +}
> +
> +static void __pr_out_indent_dec(void)
> +{
> +	if (g_indent_level - INDENT_STR_STEP < 0)
> +		return;
> +	g_indent_level -= INDENT_STR_STEP;
> +	g_indent_str[g_indent_level] = '\0';
> +}
> +
> +static void __pr_out_newline(void)
> +{
> +	pr_out("\n");
> +	g_indent_newline = true;
> +}
> +

Thanks for adding the support. Like many reviews, I am fine with the
functionality but it is the details of the implementation that are of
concern.

Why this new set of output formatting routines, this doesn't resemble other code
in ip utilities. Looks more like you copied and pasted it from somewhere else.
The indentation in existing ip command output isn't pretty or fancy but it works.

Please try and make this code look like all the other code. Yes, I know it
may not be to your taste (it isn't mine either), but consistency is more important
than individual style.

> @ -314,6 +356,102 @@ static int attr_cb(const struct nlattr *attr, void *data)
>  	if (type == DEVLINK_ATTR_ESWITCH_INLINE_MODE &&
>  	    mnl_attr_validate(attr, MNL_TYPE_U8) < 0)
>  		return MNL_CB_ERROR;
> +	if (type == DEVLINK_ATTR_DPIPE_TABLES &&
> +	    mnl_attr_validate(attr, MNL_TYPE_NESTED) < 0)
> +		return MNL_CB_ERROR;
> +	if (type == DEVLINK_ATTR_DPIPE_TABLE &&
> +	    mnl_attr_validate(attr, MNL_TYPE_NESTED) < 0)
> +		return MNL_CB_ERROR;
> +	if (type == DEVLINK_ATTR_DPIPE_TABLE_NAME &&
> +	    mnl_attr_validate(attr, MNL_TYPE_STRING) < 0)
> +		return MNL_CB_ERROR;
> +	if (type == DEVLINK_ATTR_DPIPE_TABLE_SIZE &&
> +	    mnl_attr_validate(attr, MNL_TYPE_U64) < 0)
> +		return MNL_CB_ERROR;
> +	if (type == DEVLINK_ATTR_DPIPE_TABLE_MATCHES &&
> +	    mnl_attr_validate(attr, MNL_TYPE_NESTED) < 0)
> +		return MNL_CB_ERROR;
> +	if (type == DEVLINK_ATTR_DPIPE_TABLE_ACTIONS &&
> +	    mnl_attr_validate(attr, MNL_TYPE_NESTED) < 0)
> +		return MNL_CB_ERROR;
> +	if (type == DEVLINK_ATTR_DPIPE_TABLE_COUNTERS_ENABLED &&
> +	    mnl_attr_validate(attr, MNL_TYPE_U8) < 0)
> +		return MNL_CB_ERROR;
> +	if (type == DEVLINK_ATTR_DPIPE_ENTRIES &&
> +	    mnl_attr_validate(attr, MNL_TYPE_NESTED) < 0)
> +		return MNL_CB_ERROR;
> +	if (type == DEVLINK_ATTR_DPIPE_ENTRY &&
> +	    mnl_attr_validate(attr, MNL_TYPE_NESTED) < 0)
> +		return MNL_CB_ERROR;
> +	if (type == DEVLINK_ATTR_DPIPE_ENTRY_INDEX &&
> +	    mnl_attr_validate(attr, MNL_TYPE_U64) < 0)
> +		return MNL_CB_ERROR;
> +	if (type == DEVLINK_ATTR_DPIPE_ENTRY_MATCH_VALUES &&
> +	    mnl_attr_validate(attr, MNL_TYPE_NESTED) < 0)
> +		return MNL_CB_ERROR;
> +	if (type == DEVLINK_ATTR_DPIPE_ENTRY_ACTION_VALUES &&
> +	    mnl_attr_validate(attr, MNL_TYPE_NESTED) < 0)
> +		return MNL_CB_ERROR;
> +	if (type == DEVLINK_ATTR_DPIPE_ENTRY_COUNTER &&
> +	    mnl_attr_validate(attr, MNL_TYPE_U64) < 0)
> +		return MNL_CB_ERROR;
> +	if (type == DEVLINK_ATTR_DPIPE_MATCH &&
> +	    mnl_attr_validate(attr, MNL_TYPE_NESTED) < 0)
> +		return MNL_CB_ERROR;
> +	if (type == DEVLINK_ATTR_DPIPE_MATCH_VALUE &&
> +	    mnl_attr_validate(attr, MNL_TYPE_NESTED) < 0)
> +		return MNL_CB_ERROR;
> +	if (type == DEVLINK_ATTR_DPIPE_MATCH_TYPE &&
> +	    mnl_attr_validate(attr, MNL_TYPE_U32) < 0)
> +		return MNL_CB_ERROR;
> +	if (type == DEVLINK_ATTR_DPIPE_ACTION &&
> +	    mnl_attr_validate(attr, MNL_TYPE_NESTED) < 0)
> +		return MNL_CB_ERROR;
> +	if (type == DEVLINK_ATTR_DPIPE_ACTION_VALUE &&
> +	    mnl_attr_validate(attr, MNL_TYPE_NESTED) < 0)
> +		return MNL_CB_ERROR;
> +	if (type == DEVLINK_ATTR_DPIPE_ACTION_TYPE &&
> +	    mnl_attr_validate(attr, MNL_TYPE_U32) < 0)
> +		return MNL_CB_ERROR;
> +	if (type == DEVLINK_ATTR_DPIPE_VALUE_MAPPING &&
> +	    mnl_attr_validate(attr, MNL_TYPE_U32) < 0)
> +		return MNL_CB_ERROR;
> +	if (type == DEVLINK_ATTR_DPIPE_HEADERS &&
> +	    mnl_attr_validate(attr, MNL_TYPE_NESTED) < 0)
> +		return MNL_CB_ERROR;
> +	if (type == DEVLINK_ATTR_DPIPE_HEADER &&
> +	    mnl_attr_validate(attr, MNL_TYPE_NESTED) < 0)
> +		return MNL_CB_ERROR;
> +	if (type == DEVLINK_ATTR_DPIPE_HEADER_NAME &&
> +	    mnl_attr_validate(attr, MNL_TYPE_STRING) < 0)
> +		return MNL_CB_ERROR;
> +	if (type == DEVLINK_ATTR_DPIPE_HEADER_ID &&
> +	    mnl_attr_validate(attr, MNL_TYPE_U32) < 0)
> +		return MNL_CB_ERROR;
> +	if (type == DEVLINK_ATTR_DPIPE_HEADER_FIELDS &&
> +	    mnl_attr_validate(attr, MNL_TYPE_NESTED) < 0)
> +		return MNL_CB_ERROR;
> +	if (type == DEVLINK_ATTR_DPIPE_HEADER_GLOBAL &&
> +	    mnl_attr_validate(attr, MNL_TYPE_U8) < 0)
> +		return MNL_CB_ERROR;
> +	if (type == DEVLINK_ATTR_DPIPE_HEADER_INDEX &&
> +	    mnl_attr_validate(attr, MNL_TYPE_U32) < 0)
> +		return MNL_CB_ERROR;
> +	if (type == DEVLINK_ATTR_DPIPE_FIELD &&
> +	    mnl_attr_validate(attr, MNL_TYPE_NESTED) < 0)
> +		return MNL_CB_ERROR;
> +	if (type == DEVLINK_ATTR_DPIPE_FIELD_NAME &&
> +	    mnl_attr_validate(attr, MNL_TYPE_STRING) < 0)
> +		return MNL_CB_ERROR;
> +	if (type == DEVLINK_ATTR_DPIPE_FIELD_ID &&
> +	    mnl_attr_validate(attr, MNL_TYPE_U32) < 0)
> +		return MNL_CB_ERROR;
> +	if (type == DEVLINK_ATTR_DPIPE_FIELD_BITWIDTH &&
> +	    mnl_attr_validate(attr, MNL_TYPE_U32) < 0)
> +		return MNL_CB_ERROR;
> +	if (type == DEVLINK_ATTR_DPIPE_FIELD_MAPPING_TYPE &&
> +	    mnl_attr_validate(attr, MNL_TYPE_U32) < 0)
> +		return MNL_CB_ERROR;
>  	tb[type] = attr;
>  	return MNL_CB_OK;
>  }

Ok, this code has gotten so long that it really needs to be handled as a table
rather than linear sequence of if's.
