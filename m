From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 7/7] cxgb4: add support for drop and redirect
 actions
Date: Mon, 12 Sep 2016 10:52:53 +0200
Message-ID: <20160912085253.GF2021@nanopsycho>
References: <cover.1473667613.git.rahul.lakkireddy@chelsio.com>
 <13800cc26e45257999003861820b0bc65ab7a8d1.1473667613.git.rahul.lakkireddy@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        hariprasad@chelsio.com, leedom@chelsio.com, nirranjan@chelsio.com,
        indranil@chelsio.com
To: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33630 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751579AbcILIw5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 04:52:57 -0400
Received: by mail-wm0-f67.google.com with SMTP id b187so12575526wme.0
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 01:52:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <13800cc26e45257999003861820b0bc65ab7a8d1.1473667613.git.rahul.lakkireddy@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Sep 12, 2016 at 10:12:40AM CEST, rahul.lakkireddy@chelsio.com wrote:
>Add support for dropping matched packets in hardware.  Also add support
>for re-directing matched packets to a specified port in hardware.
>
>Signed-off-by: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
>Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
>---
> drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c | 63 +++++++++++++++++++++++
> 1 file changed, 63 insertions(+)
>
>diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c
>index 31847e3..584ccb3 100644
>--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c
>+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c
>@@ -32,6 +32,9 @@
>  * SOFTWARE.
>  */
> 
>+#include <net/tc_act/tc_gact.h>
>+#include <net/tc_act/tc_mirred.h>
>+
> #include "cxgb4.h"
> #include "cxgb4_tc_u32_parse.h"
> #include "cxgb4_tc_u32.h"
>@@ -83,6 +86,59 @@ static int fill_match_fields(struct adapter *adap,
> 	return 0;
> }
> 
>+/* Fill ch_filter_specification with parsed action. */
>+static int fill_action_fields(struct adapter *adap,
>+			      struct ch_filter_specification *fs,
>+			      struct tc_cls_u32_offload *cls)
>+{
>+	const struct tc_action *a;
>+	struct tcf_exts *exts;
>+	LIST_HEAD(actions);
>+	unsigned int num_actions = 0;
>+	bool found = false;
>+
>+	exts = cls->knode.exts;
>+	if (tc_no_actions(exts))
>+		return -EINVAL;
>+
>+	tcf_exts_to_list(exts, &actions);
>+	list_for_each_entry(a, &actions, list) {
>+		/* Don't allow more than one action per rule. */
>+		if (num_actions)
>+			return -EINVAL;


Looking at this, unrelated to this patch, we really need some advanced
reporting to user about what went wrong. Otherwise he's playing a
guessing game.



>+
>+		/* Drop in hardware. */
>+		if (is_tcf_gact_shot(a)) {
>+			fs->action = FILTER_DROP;
>+			found = true;
>+		}
>+
>+		/* Re-direct to specified port in hardware. */
>+		if (is_tcf_mirred_redirect(a)) {

		else if ?

>+			struct net_device *n_dev;
>+			unsigned int i, index;
>+
>+			index = tcf_mirred_ifindex(a);
>+			for_each_port(adap, i) {
>+				n_dev = adap->port[i];
>+				if (index == n_dev->ifindex) {
>+					fs->action = FILTER_SWITCH;
>+					fs->eport = i;
>+					break;
>+				}
>+			}
>+			found = true;
>+		}

You need to report an error in case you don't support the action. 




>+
>+		num_actions++;
>+	}
>+
>+	if (!found)
>+		return -EINVAL;

Oh, I guess this is to fail on unsupported action. Odd. Rather just
return directly the list_for_each_entry loop


>+
>+	return 0;
>+}
>+
> int cxgb4_config_knode(struct net_device *dev, __be16 protocol,
> 		       struct tc_cls_u32_offload *cls)
> {
>@@ -236,6 +292,13 @@ int cxgb4_config_knode(struct net_device *dev, __be16 protocol,
> 	if (ret)
> 		goto out;
> 
>+	/* Fill ch_filter_specification action fields to be shipped to
>+	 * hardware.
>+	 */
>+	ret = fill_action_fields(adapter, &fs, cls);
>+	if (ret)
>+		goto out;
>+
> 	/* The filter spec has been completely built from the info
> 	 * provided from u32.  We now set some default fields in the
> 	 * spec for sanity.
>-- 
>2.5.3
>
