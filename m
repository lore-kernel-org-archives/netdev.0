From: Vladislav Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH v2 2/2] dlm: Do not allocate a fd for peeloff
Date: Thu, 08 Mar 2012 15:08:17 -0500
Message-ID: <4F5911B1.6050600@hp.com>
References: <20120308.002447.1062706659978103072.davem@davemloft.net> <1331222159-28980-1-git-send-email-bpoirier@suse.de> <1331222159-28980-2-git-send-email-bpoirier@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Christine Caulfield <ccaulfie@redhat.com>,
	David Teigland <teigland@redhat.com>,
	Sridhar Samudrala <sri@us.ibm.com>, cluster-devel@redhat.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Benjamin Poirier <bpoirier@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:20520 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758238Ab2CHUIX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2012 15:08:23 -0500
In-Reply-To: <1331222159-28980-2-git-send-email-bpoirier@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/08/2012 10:55 AM, Benjamin Poirier wrote:
> avoids allocating a fd that a) propagates to every kernel thread and
> usermodehelper b) is not properly released.
> 
> References: http://article.gmane.org/gmane.linux.network.drbd/22529
> Signed-off-by: Benjamin Poirier <bpoirier@suse.de>

Looks much better.

-vlad

> ---
>  fs/dlm/lowcomms.c |   22 ++++++++--------------
>  1 files changed, 8 insertions(+), 14 deletions(-)
> 
> diff --git a/fs/dlm/lowcomms.c b/fs/dlm/lowcomms.c
> index 0b3109e..ca0c59a 100644
> --- a/fs/dlm/lowcomms.c
> +++ b/fs/dlm/lowcomms.c
> @@ -52,6 +52,7 @@
>  #include <linux/mutex.h>
>  #include <linux/sctp.h>
>  #include <linux/slab.h>
> +#include <net/sctp/sctp.h>
>  #include <net/sctp/user.h>
>  #include <net/ipv6.h>
>  
> @@ -474,9 +475,6 @@ static void process_sctp_notification(struct connection *con,
>  			int prim_len, ret;
>  			int addr_len;
>  			struct connection *new_con;
> -			sctp_peeloff_arg_t parg;
> -			int parglen = sizeof(parg);
> -			int err;
>  
>  			/*
>  			 * We get this before any data for an association.
> @@ -525,23 +523,19 @@ static void process_sctp_notification(struct connection *con,
>  				return;
>  
>  			/* Peel off a new sock */
> -			parg.associd = sn->sn_assoc_change.sac_assoc_id;
> -			ret = kernel_getsockopt(con->sock, IPPROTO_SCTP,
> -						SCTP_SOCKOPT_PEELOFF,
> -						(void *)&parg, &parglen);
> +			sctp_lock_sock(con->sock->sk);
> +			ret = sctp_do_peeloff(con->sock->sk,
> +				sn->sn_assoc_change.sac_assoc_id,
> +				&new_con->sock);
> +			sctp_release_sock(con->sock->sk);
>  			if (ret < 0) {
>  				log_print("Can't peel off a socket for "
>  					  "connection %d to node %d: err=%d",
> -					  parg.associd, nodeid, ret);
> -				return;
> -			}
> -			new_con->sock = sockfd_lookup(parg.sd, &err);
> -			if (!new_con->sock) {
> -				log_print("sockfd_lookup error %d", err);
> +					  (int)sn->sn_assoc_change.sac_assoc_id,
> +					  nodeid, ret);
>  				return;
>  			}
>  			add_sock(new_con->sock, new_con);
> -			sockfd_put(new_con->sock);
>  
>  			log_print("connecting to %d sctp association %d",
>  				 nodeid, (int)sn->sn_assoc_change.sac_assoc_id);
