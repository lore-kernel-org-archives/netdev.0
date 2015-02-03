From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] bridge: Let bridge not age 'externally' learnt
 FDB entries, they are removed when 'external' entity notifies the aging
Date: Tue, 03 Feb 2015 07:11:29 -0800
Message-ID: <54D0E521.6070100@cumulusnetworks.com>
References: <1422897714-5956-1-git-send-email-siva.mannem.lnx@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>
To: Siva Mannem <siva.mannem.lnx@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:50312 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752306AbbBCPLc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2015 10:11:32 -0500
Received: by mail-ie0-f179.google.com with SMTP id x19so25716135ier.10
        for <netdev@vger.kernel.org>; Tue, 03 Feb 2015 07:11:31 -0800 (PST)
In-Reply-To: <1422897714-5956-1-git-send-email-siva.mannem.lnx@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/2/15, 9:21 AM, Siva Mannem wrote:
>   When 'learned_sync' flag is turned on, the offloaded switch
>   port syncs learned MAC addresses to bridge's FDB via switchdev notifier
>   (NETDEV_SWITCH_FDB_ADD). Currently, FDB entries learnt via this mechanism are
>   wrongly being deleted by bridge aging logic. This patch ensures that FDB
>   entries synced from offloaded switch ports are not deleted by bridging logic.
>   Such entries can only be deleted via switchdev notifier
>   (NETDEV_SWITCH_FDB_DEL).

Your patch seems right and maintains symmetry for fdb add/del of 
externally learnt entries.
However, this could be made configurable. I think some drivers may rely 
on bridge driver aging these entries (The default setting needs more 
thought).
I am not sure what rocker does (CC'ed rocker maintainers). But, our 
driver does rely on the bridge driver aging these entries by default.
>
> Signed-off-by: Siva Mannem <siva.mannem.lnx@gmail.com>
> ---
>   net/bridge/br_fdb.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
> index 08bf04b..6eb94b5 100644
> --- a/net/bridge/br_fdb.c
> +++ b/net/bridge/br_fdb.c
> @@ -280,7 +280,7 @@ void br_fdb_cleanup(unsigned long _data)
>   
>   		hlist_for_each_entry_safe(f, n, &br->hash[i], hlist) {
>   			unsigned long this_timer;
> -			if (f->is_static)
> +			if (f->is_static || f->added_by_external_learn)
>   				continue;
>   			this_timer = f->updated + delay;
>   			if (time_before_eq(this_timer, jiffies))
