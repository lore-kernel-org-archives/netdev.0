From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] net: check for NULL net_device in FIB tables
Date: Tue, 5 Jul 2016 00:24:42 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1607050014000.2228@ja.home.ssi.bg>
References: <1467636446-6771-1-git-send-email-vegard.nossum@oracle.com> <alpine.LFD.2.11.1607042221290.2228@ja.home.ssi.bg> <577ABF71.6020002@oracle.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andy Gospodarek <gospo@cumulusnetworks.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Dinesh Dutt <ddutt@cumulusnetworks.com>,
	Scott Feldman <sfeldma@gmail.com>
To: Vegard Nossum <vegard.nossum@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:51941 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753490AbcGDVZC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jul 2016 17:25:02 -0400
In-Reply-To: <577ABF71.6020002@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Mon, 4 Jul 2016, Vegard Nossum wrote:

> Alright.
> 
> Thanks for the review! I can submit a new patch to only check the one
> place above that actually crashed. Otherwise, if you think it's better
> to go with your fc_flags suggestion, feel free to send a patch for that.
> As you can tell, I am not very familiar with this code :-) If you do
> send a patch, I can test it easily.

	Of course, here is untested version. May be I'll do some
testing this weekend and will submit with proper commit
message...

[PATCH RFC] ipv4: reject RTNH_F_LINKDOWN for incompatible routes

The RTNH_F_LINKDOWN flag is used only for link routes.
Reject it for error routes and local routes.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/ipv4/fib_semantics.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 2b68418..1f10c20 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -1113,7 +1113,8 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 	}
 
 	if (fib_props[cfg->fc_type].error) {
-		if (cfg->fc_gw || cfg->fc_oif || cfg->fc_mp)
+		if (cfg->fc_gw || cfg->fc_oif || cfg->fc_mp ||
+		    (fi->fib_nh->nh_flags & RTNH_F_LINKDOWN))
 			goto err_inval;
 		goto link_it;
 	} else {
@@ -1136,7 +1137,7 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 		struct fib_nh *nh = fi->fib_nh;
 
 		/* Local address is added. */
-		if (nhs != 1 || nh->nh_gw)
+		if (nhs != 1 || nh->nh_gw || (nh->nh_flags & RTNH_F_LINKDOWN))
 			goto err_inval;
 		nh->nh_scope = RT_SCOPE_NOWHERE;
 		nh->nh_dev = dev_get_by_index(net, fi->fib_nh->nh_oif);
-- 
1.9.3

Regards
