From: Vladislav Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] dlm, sctp: Do not allocate a fd for peeloff
Date: Wed, 07 Mar 2012 11:29:20 -0500
Message-ID: <4F578CE0.6030106@hp.com>
References: <1331134862-14812-1-git-send-email-bpoirier@suse.de>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1331134862-14812-1-git-send-email-bpoirier@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/07/2012 10:41 AM, Benjamin Poirier wrote:
> avoids allocating a fd that a) propagates to every kernel thread and
> usermodehelper b) is not properly released.
> 
> References: http://article.gmane.org/gmane.linux.network.drbd/22529
> Signed-off-by: Benjamin Poirier <bpoirier@suse.de>

It might make sense to change sctp_do_peeloff to take the association id as
the first argument and not do the mapping from id to association yourself.
It's a bit ugly to expose internal sctp structures outside of SCTP.

-vlad

> ---
>  fs/dlm/lowcomms.c       |   28 ++++++++++++++--------------
>  include/net/sctp/sctp.h |    1 +
>  net/sctp/socket.c       |    5 +++--
>  3 files changed, 18 insertions(+), 16 deletions(-)
> 
> diff --git a/fs/dlm/lowcomms.c b/fs/dlm/lowcomms.c
> index 0b3109e..f6645b2 100644
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
> @@ -474,9 +475,8 @@ static void process_sctp_notification(struct connection *con,
>  			int prim_len, ret;
>  			int addr_len;
>  			struct connection *new_con;
> -			sctp_peeloff_arg_t parg;
> -			int parglen = sizeof(parg);
> -			int err;
> +			sctp_assoc_t associd;
> +			struct sctp_association *asoc;
>  
>  			/*
>  			 * We get this before any data for an association.
> @@ -525,23 +525,23 @@ static void process_sctp_notification(struct connection *con,
>  				return;
>  
>  			/* Peel off a new sock */
> -			parg.associd = sn->sn_assoc_change.sac_assoc_id;
> -			ret = kernel_getsockopt(con->sock, IPPROTO_SCTP,
> -						SCTP_SOCKOPT_PEELOFF,
> -						(void *)&parg, &parglen);
> +			sctp_lock_sock(con->sock->sk);
> +			associd = sn->sn_assoc_change.sac_assoc_id;
> +			asoc = sctp_id2assoc(con->sock->sk, associd);
> +			if (!asoc) {
> +				log_print("sctp_id2assoc error");
> +				sctp_release_sock(con->sock->sk);
> +				return;
> +			}
> +			ret = sctp_do_peeloff(asoc, &new_con->sock);
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
> +					  associd, nodeid, ret);
>  				return;
>  			}
>  			add_sock(new_con->sock, new_con);
> -			sockfd_put(new_con->sock);
>  
>  			log_print("connecting to %d sctp association %d",
>  				 nodeid, (int)sn->sn_assoc_change.sac_assoc_id);
> diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
> index d368561..31e36db 100644
> --- a/include/net/sctp/sctp.h
> +++ b/include/net/sctp/sctp.h
> @@ -413,6 +413,7 @@ static inline sctp_assoc_t sctp_assoc2id(const struct sctp_association *asoc)
>  /* Look up the association by its id.  */
>  struct sctp_association *sctp_id2assoc(struct sock *sk, sctp_assoc_t id);
>  
> +int sctp_do_peeloff(struct sctp_association *asoc, struct socket **sockp);
>  
>  /* A macro to walk a list of skbs.  */
>  #define sctp_skb_for_each(pos, head, tmp) \
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 408ebd0..ae8944c 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -239,6 +239,7 @@ struct sctp_association *sctp_id2assoc(struct sock *sk, sctp_assoc_t id)
>  
>  	return asoc;
>  }
> +EXPORT_SYMBOL(sctp_id2assoc);
>  
>  /* Look up the transport from an address and an assoc id. If both address and
>   * id are specified, the associations matching the address and the id should be
> @@ -4170,8 +4171,7 @@ static int sctp_getsockopt_autoclose(struct sock *sk, int len, char __user *optv
>  }
>  
>  /* Helper routine to branch off an association to a new socket.  */
> -SCTP_STATIC int sctp_do_peeloff(struct sctp_association *asoc,
> -				struct socket **sockp)
> +int sctp_do_peeloff(struct sctp_association *asoc, struct socket **sockp)
>  {
>  	struct sock *sk = asoc->base.sk;
>  	struct socket *sock;
> @@ -4206,6 +4206,7 @@ SCTP_STATIC int sctp_do_peeloff(struct sctp_association *asoc,
>  
>  	return err;
>  }
> +EXPORT_SYMBOL(sctp_do_peeloff);
>  
>  static int sctp_getsockopt_peeloff(struct sock *sk, int len, char __user *optval, int __user *optlen)
>  {
