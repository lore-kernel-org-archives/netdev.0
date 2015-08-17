From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] ppp: fix device unregistration upon netns
 deletion
Date: Mon, 17 Aug 2015 12:22:45 -0700 (PDT)
Message-ID: <20150817.122245.377868954143385043.davem@davemloft.net>
References: <47412a6103a73f33a6c167c86ee5790577c0a0ec.1439541453.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulus@samba.org
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35723 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750800AbbHQTWq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 15:22:46 -0400
In-Reply-To: <47412a6103a73f33a6c167c86ee5790577c0a0ec.1439541453.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Fri, 14 Aug 2015 10:42:56 +0200

> PPP devices may get automatically unregistered when their network
> namespace is getting removed. This happens if the ppp control plane
> daemon (e.g. pppd) exits while it is the last user of this namespace.
> 
> This leads to several races:
> 
>   * ppp_exit_net() may destroy the per namespace idr (pn->units_idr)
>     before all file descriptors were released. Successive ppp_release()
>     calls may then cleanup PPP devices with ppp_shutdown_interface() and
>     try to use the already destroyed idr.
> 
>   * Automatic device unregistration may also happen before the
>     ppp_release() call for that device gets executed. Once called on
>     the file owning the device, ppp_release() will then clean it up and
>     try to unregister it a second time.
> 
> To fix these issues, operations defined in ppp_shutdown_interface() are
> moved to the PPP device's ndo_uninit() callback. This allows PPP
> devices to be properly cleaned up by unregister_netdev() and friends.
> So checking for ppp->owner is now an accurate test to decide if a PPP
> device should be unregistered.
> 
> Setting ppp->owner is done in ppp_create_interface(), before device
> registration, in order to avoid unprotected modification of this field.
> 
> Finally, ppp_exit_net() now starts by unregistering all remaining PPP
> devices to ensure that none will get unregistered after the call to
> idr_destroy().
> 
> Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
> ---
> v2: remove unnecessary curly braces in idr_for_each_entry()

Applied, thank you.
