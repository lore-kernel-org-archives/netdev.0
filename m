From: Oren Laadan <orenl@librato.com>
Subject: Re: [PATCH 3/3] Save and restore UNIX socket peer credentials (v2)
Date: Tue, 25 Aug 2009 01:54:07 -0400
Message-ID: <4A937C7F.5020008@librato.com>
References: <1251134884-24491-1-git-send-email-danms@us.ibm.com> <1251134884-24491-4-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, netdev@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp111.iad.emailsrvr.com ([207.97.245.111]:48781 "EHLO
	smtp111.iad.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754486AbZHYFyq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 01:54:46 -0400
In-Reply-To: <1251134884-24491-4-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Added, thanks.

Dan Smith wrote:
> This saves the uid/gid of the sk_peercred structure in the checkpoint
> stream.  On restart, it uses may_setuid() and may_setgid() to determine
> if the uid/gid from the checkpoint stream may be used.
> 
> Changes in v3:
>  - Fix error path when may_setuid() or may_setgid() fail
> 
> Changes in v2:
>  - Adjust for may_setgid() change
> 
> Acked-by: Serge Hallyn <serue@us.ibm.com>
> Signed-off-by: Dan Smith <danms@us.ibm.com>
> ---
>  include/linux/checkpoint_hdr.h |    2 ++
>  net/unix/checkpoint.c          |   30 +++++++++++++++++-------------
>  2 files changed, 19 insertions(+), 13 deletions(-)
> 
> diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
> index 4d5c22a..78f1f27 100644
> --- a/include/linux/checkpoint_hdr.h
> +++ b/include/linux/checkpoint_hdr.h
> @@ -414,6 +414,8 @@ struct ckpt_hdr_socket_unix {
>  	struct ckpt_hdr h;
>  	__s32 this;
>  	__s32 peer;
> +	__u32 peercred_uid;
> +	__u32 peercred_gid;
>  	__u32 flags;
>  	__u32 laddr_len;
>  	__u32 raddr_len;
> diff --git a/net/unix/checkpoint.c b/net/unix/checkpoint.c
> index 81252e3..4aff931 100644
> --- a/net/unix/checkpoint.c
> +++ b/net/unix/checkpoint.c
> @@ -3,6 +3,7 @@
>  #include <linux/fs_struct.h>
>  #include <linux/checkpoint.h>
>  #include <linux/checkpoint_hdr.h>
> +#include <linux/user.h>
>  #include <net/af_unix.h>
>  #include <net/tcp_states.h>
>  
> @@ -94,6 +95,9 @@ int unix_checkpoint(struct ckpt_ctx *ctx, struct socket *sock)
>  		goto out;
>  	}
>  
> +	un->peercred_uid = sock->sk->sk_peercred.uid;
> +	un->peercred_gid = sock->sk->sk_peercred.gid;
> +
>  	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) un);
>  	if (ret < 0)
>  		goto out;
> @@ -217,19 +221,6 @@ static int unix_join(struct ckpt_ctx *ctx,
>  	unix_sk(a)->peer = b;
>  	unix_sk(b)->peer = a;
>  
> -	/* TODO:
> -	 * Checkpoint the credentials, restore them here if the values match
> -	 * the restored creds or we may_setuid()
> -	 */
> -
> -	a->sk_peercred.pid = task_tgid_vnr(current);
> -	a->sk_peercred.uid = ctx->realcred->uid;
> -	a->sk_peercred.gid = ctx->realcred->gid;
> -
> -	b->sk_peercred.pid = a->sk_peercred.pid;
> -	b->sk_peercred.uid = a->sk_peercred.uid;
> -	b->sk_peercred.gid = a->sk_peercred.gid;
> -
>  	if (!UNIX_ADDR_EMPTY(un->raddr_len))
>  		addr = unix_makeaddr(&un->raddr, un->raddr_len);
>  	else if (!UNIX_ADDR_EMPTY(un->laddr_len))
> @@ -295,6 +286,19 @@ static int unix_restore_connected(struct ckpt_ctx *ctx,
>  		goto out;
>  	}
>  
> +	this->sk_peercred.pid = task_tgid_vnr(current);
> +
> +	if (may_setuid(ctx->realcred->user->user_ns, un->peercred_uid) &&
> +	    may_setgid(un->peercred_gid)) {
> +		this->sk_peercred.uid = un->peercred_uid;
> +		this->sk_peercred.gid = un->peercred_gid;
> +	} else {
> +		ckpt_debug("peercred %i:%i would require setuid",
> +			   un->peercred_uid, un->peercred_gid);
> +		ret = -EPERM;
> +		goto out;
> +	}
> +
>  	/* Prime the socket's buffer limit with the maximum.  These will be
>  	 * overwritten with the values in the checkpoint stream in a later
>  	 * phase.
