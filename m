From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: bridge: Fix improper taking over HW learned
 FDB
Date: Thu, 27 Apr 2017 16:40:33 +0300
Message-ID: <45eb4630-0d54-bff4-2288-cf73f9807a3d@cumulusnetworks.com>
References: <1493280485-37845-1-git-send-email-arkadis@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, stephen@networkplumber.org,
        bridge@lists.linux-foundation.org,
        Ido Schimmel <idosch@mellanox.com>
To: Arkadi Sharshevsky <arkadis@mellanox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:38185 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751194AbdD0Nkg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 09:40:36 -0400
Received: by mail-wm0-f54.google.com with SMTP id r190so18894122wme.1
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 06:40:36 -0700 (PDT)
In-Reply-To: <1493280485-37845-1-git-send-email-arkadis@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27/04/17 11:08, Arkadi Sharshevsky wrote:
> Commit 7e26bf45e4cb ("net: bridge: allow SW learn to take over HW fdb
> entries") added the ability to "take over an entry which was previously
> learned via HW when it shows up from a SW port".
> 
> However, if an entry was learned via HW and then a control packet
> (e.g., ARP request) was trapped to the CPU, the bridge driver will
> update the entry and remove the externally learned flag, although the
> entry is still present in HW. Instead, only clear the externally learned
> flag in case of roaming.
> 
> Fixes: 7e26bf45e4cb ("net: bridge: allow SW learn to take over HW fdb entries")
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Arkadi Sharashevsky <arkadis@mellanox.com>
> Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---
>  net/bridge/br_fdb.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
> index 5a40a87..ab0c7cc 100644
> --- a/net/bridge/br_fdb.c
> +++ b/net/bridge/br_fdb.c
> @@ -589,14 +589,14 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
>  			if (unlikely(source != fdb->dst)) {
>  				fdb->dst = source;
>  				fdb_modified = true;
> +				/* Take over HW learned entry */
> +				if (unlikely(fdb->added_by_external_learn))
> +					fdb->added_by_external_learn = 0;
>  			}
>  			if (now != fdb->updated)
>  				fdb->updated = now;
>  			if (unlikely(added_by_user))
>  				fdb->added_by_user = 1;
> -			/* Take over HW learned entry */
> -			if (unlikely(fdb->added_by_external_learn))
> -				fdb->added_by_external_learn = 0;
>  			if (unlikely(fdb_modified))
>  				fdb_notify(br, fdb, RTM_NEWNEIGH);
>  		}
> 

Wait, this won't apply to latest net-next due to my patch that added
fdb_modified when changing the ext learned flag. I think you'll have to
respin on top of latest net-next.
