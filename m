From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] genetlink: fix usage of NLM_F_EXCL or NLM_F_REPLACE
Date: Tue, 12 Nov 2013 17:12:06 -0500 (EST)
Message-ID: <20131112.171206.591427230164167273.davem@davemloft.net>
References: <20130731.170348.1752477967026355787.davem@davemloft.net>
	<20130801003710.GA19777@localhost>
	<20130801020049.GA4067@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37703 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757101Ab3KLWMJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 17:12:09 -0500
In-Reply-To: <20130801020049.GA4067@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Thu, 1 Aug 2013 04:00:49 +0200

> @@ -571,7 +571,8 @@ static int genl_family_rcv_msg(struct genl_family *family,
>  	    !capable(CAP_NET_ADMIN))
>  		return -EPERM;
>  
> -	if ((nlh->nlmsg_flags & NLM_F_DUMP) == NLM_F_DUMP) {
> +	if ((ops->flags & GENL_CMD_CAP_DUMP) &&
> +	    nlh->nlmsg_flags & NLM_F_DUMP) {
>  		struct netlink_dump_control c = {
>  			.dump = ops->dumpit,
>  			.done = ops->done,

Sorry for taking so long to get back to you on this, it looks perfect!

I did some auditing of other uses, and briefly crypto does the same:

crypto/crypto_user.c:

	if ((type == (CRYPTO_MSG_GETALG - CRYPTO_MSG_BASE) &&
	    (nlh->nlmsg_flags & NLM_F_DUMP))) {

"If this is a GET command, test dump flag"

Same thing for net/xfrm/xfrm_user.c:

	if ((type == (XFRM_MSG_GETSA - XFRM_MSG_BASE) ||
	     type == (XFRM_MSG_GETPOLICY - XFRM_MSG_BASE)) &&
	    (nlh->nlmsg_flags & NLM_F_DUMP)) {

Similarly all of the netfilter stuff performs this NLM_F_DUMP bit
test in contexts where we are processing some GET command.

All the "diag" modules are implicitly processing GET commands.

Pablo, could you please retest and resubmit this patch?  I will
apply it and push to -stable as well.

Thanks!
