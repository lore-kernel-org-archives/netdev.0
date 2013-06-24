From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v4 2/2] vxlan: allow specifying multiple
 default destinations
Date: Sun, 23 Jun 2013 17:14:40 -0700
Message-ID: <20130623171440.439356b7@nehalam.linuxnetplumber.net>
References: <1372004543-24675-1-git-send-email-mike.rapoport@ravellosystems.com>
	<1372004543-24675-3-git-send-email-mike.rapoport@ravellosystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Stevens <dlstevens@us.ibm.com>,
	Thomas Graf <tgraf@suug.ch>
To: Mike Rapoport <mike.rapoport@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f67.google.com ([209.85.160.67]:38490 "EHLO
	mail-pb0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751617Ab3FXAOp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Jun 2013 20:14:45 -0400
Received: by mail-pb0-f67.google.com with SMTP id rr13so5079870pbb.6
        for <netdev@vger.kernel.org>; Sun, 23 Jun 2013 17:14:44 -0700 (PDT)
In-Reply-To: <1372004543-24675-3-git-send-email-mike.rapoport@ravellosystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 23 Jun 2013 19:22:23 +0300
Mike Rapoport <mike.rapoport@ravellosystems.com> wrote:

> A list of multiple default destinations can be used in environments that
> disable multicast on the infrastructure level, e.g. public clouds.
> 
> Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>
> ---
>  drivers/net/vxlan.c          | 268 +++++++++++++++++++++++++++++++++++++++++--
>  include/uapi/linux/if_link.h |  17 +++
>  2 files changed, 276 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index e5fb6568..f57a0d94 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -103,6 +103,7 @@ struct vxlan_rdst {
>  	u32			 remote_vni;
>  	u32			 remote_ifindex;
>  	struct list_head	 list;
> +	struct rcu_head		 rcu;
>  };

The use of remotes_cnt here is not SMP safe.
You are using remotes_cnt to size the buffer for dumping, but then the list
of remotes might change during the dump.

There a a couple of alternatives here:
1. Put a hard limit on the number of remotes per MAC.
2. When there are multiple destnations, just dump multiple entries, like
   multipath routing does.

I prefer #2 because it also allows for a cleaner API on creation.
