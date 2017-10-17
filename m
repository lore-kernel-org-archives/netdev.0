From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net] sctp: do not peel off an assoc from one netns to
 another one
Date: Tue, 17 Oct 2017 13:33:25 -0400
Message-ID: <20171017173325.GA23530@hmswarspite.think-freely.org>
References: <e637d68ce6f4f94dce8cb30c647e672ebb1f0b7b.1508253970.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        chunwang@redhat.com, syzkaller@googlegroups.com
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:37178 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1763517AbdJQReD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 13:34:03 -0400
Content-Disposition: inline
In-Reply-To: <e637d68ce6f4f94dce8cb30c647e672ebb1f0b7b.1508253970.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 17, 2017 at 11:26:10PM +0800, Xin Long wrote:
> Now when peeling off an association to the sock in another netns, all
> transports in this assoc are not to be rehashed and keep use the old
> key in hashtable.
> 
> As a transport uses sk->net as the hash key to insert into hashtable,
> it would miss removing these transports from hashtable due to the new
> netns when closing the sock and all transports are being freeed, then
> later an use-after-free issue could be caused when looking up an asoc
> and dereferencing those transports.
> 
> This is a very old issue since very beginning, ChunYu found it with
> syzkaller fuzz testing with this series:
> 
>   socket$inet6_sctp()
>   bind$inet6()
>   sendto$inet6()
>   unshare(0x40000000)
>   getsockopt$inet_sctp6_SCTP_GET_ASSOC_ID_LIST()
>   getsockopt$inet_sctp6_SCTP_SOCKOPT_PEELOFF()
> 
> This patch is to block this call when peeling one assoc off from one
> netns to another one, so that the netns of all transport would not
> go out-sync with the key in hashtable.
> 
> Note that this patch didn't fix it by rehashing transports, as it's
> difficult to handle the situation when the tuple is already in use
> in the new netns. Besides, no one would like to peel off one assoc
> to another netns, considering ipaddrs, ifaces, etc. are usually
> different.
> 
> Reported-by: ChunYu Wang <chunwang@redhat.com>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>  net/sctp/socket.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index d4730ad..17841ab 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -4906,6 +4906,10 @@ int sctp_do_peeloff(struct sock *sk, sctp_assoc_t id, struct socket **sockp)
>  	struct socket *sock;
>  	int err = 0;
>  
> +	/* Do not peel off from one netns to another one. */
> +	if (!net_eq(current->nsproxy->net_ns, sock_net(sk)))
> +		return -EINVAL;
> +
>  	if (!asoc)
>  		return -EINVAL;
>  
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
