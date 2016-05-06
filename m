From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net] netfilter: nf_conntrack: Use net_mutex for helper
 unregistration.
Date: Fri, 6 May 2016 13:03:25 +0200
Message-ID: <20160506110325.GA2420@salvia>
References: <1462488637-46877-1-git-send-email-joe@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	fw@strlen.de
To: Joe Stringer <joe@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58994 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751306AbcEFLFj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 May 2016 07:05:39 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id D41C2843A
	for <netdev@vger.kernel.org>; Fri,  6 May 2016 13:05:33 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id C5792A91C
	for <netdev@vger.kernel.org>; Fri,  6 May 2016 13:05:33 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id B454C6447A
	for <netdev@vger.kernel.org>; Fri,  6 May 2016 13:05:31 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <1462488637-46877-1-git-send-email-joe@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Joe,

On Thu, May 05, 2016 at 03:50:37PM -0700, Joe Stringer wrote:
> diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
> index 3b40ec575cd5..6860b19be406 100644
> --- a/net/netfilter/nf_conntrack_helper.c
> +++ b/net/netfilter/nf_conntrack_helper.c
> @@ -449,10 +449,10 @@ void nf_conntrack_helper_unregister(struct nf_conntrack_helper *me)
>  	 */
>  	synchronize_rcu();
>  
> -	rtnl_lock();
> +	mutex_lock(&net_mutex);
>  	for_each_net(net)
>  		__nf_conntrack_helper_unregister(me, net);
> -	rtnl_unlock();
> +	mutex_unlock(&net_mutex);

This simple solution works because we have no .exit callbacks in any
of our helpers. Otherwise, the helper code may be already gone by when
the worker has a chance to run to release the netns.

If so, probably I can append this as comment to this function so we
don't forget. If we ever have .exit callbacks (I don't expect so), we
would need to wait for worker completion.
