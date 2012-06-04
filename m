From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH 3/7] netfilter: nf_ct_helper: implement variable length
 helper private data
Date: Mon, 4 Jun 2012 15:06:41 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1206041456480.16684@frira.zrqbmnf.qr>
References: <1338812485-4232-1-git-send-email-pablo@netfilter.org> <1338812485-4232-4-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from seven.medozas.de ([188.40.89.202]:46166 "EHLO seven.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753225Ab2FDNGo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2012 09:06:44 -0400
In-Reply-To: <1338812485-4232-4-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 2012-06-04 14:21, pablo@netfilter.org wrote:

>+static inline void *nfct_help_data(const struct nf_conn *ct)
>+{
>+	struct nf_conn_help *help;
>+
>+	help = nf_ct_ext_find(ct, NF_CT_EXT_HELPER);
>+
>+	return (void *)&help->data;
>+}

I think you wanted

	return help->data;

here. Remember that help->data is of type char[0] which is
convertible to char* - which is what you want,
while adding an extra & would turn that into the undesired (char[0])*.



>@@ -89,12 +59,13 @@ struct nf_conn_help {
> 	/* Helper. if any */
> 	struct nf_conntrack_helper __rcu *helper;
> 
>-	union nf_conntrack_help help;
>-
> 	struct hlist_head expectations;
> 
> 	/* Current number of expected connections */
> 	u8 expecting[NF_CT_MAX_EXPECT_CLASSES];
>+
>+	/* private helper information. */
>+	char data[0];

There is a now-standardized notation:

	char data[];



>@@ -218,13 +221,13 @@ int __nf_ct_try_assign_helper(struct nf_conn *ct, struct nf_conn *tmpl,
> 	}
> 
> 	if (help == NULL) {
>-		help = nf_ct_helper_ext_add(ct, flags);
>+		help = nf_ct_helper_ext_add(ct, helper, flags);
> 		if (help == NULL) {
> 			ret = -ENOMEM;
> 			goto out;
> 		}
> 	} else {
>-		memset(&help->help, 0, sizeof(help->help));
>+		memset(&help->data, 0, sizeof(helper->data_len));
> 	}

memset(help->data, 0, sizeof(helper->data_len));

>index 6f4b00a..30f5e12 100644
>--- a/net/netfilter/nf_conntrack_netlink.c
>+++ b/net/netfilter/nf_conntrack_netlink.c
>@@ -1218,7 +1218,7 @@ ctnetlink_change_helper(struct nf_conn *ct, const struct nlattr * const cda[])
> 		if (help->helper)
> 			return -EBUSY;
> 		/* need to zero data of old helper */
>-		memset(&help->help, 0, sizeof(help->help));
>+		memset(&help->data, 0, help->helper->data_len);

Here too.. memset(help->data,...
