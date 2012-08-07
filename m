From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 4/5 (resend)] net: Make ifindex generation per-net
 namespace
Date: Tue, 07 Aug 2012 14:11:06 +0200
Message-ID: <1344341466.28967.78.camel@edumazet-glaptop>
References: <501FD0F2.4040609@parallels.com> <501FD15F.70604@parallels.com>
	 <5020F5C3.8010107@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:45488 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753384Ab2HGMLL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2012 08:11:11 -0400
Received: by bkwj10 with SMTP id j10so1415777bkw.19
        for <netdev@vger.kernel.org>; Tue, 07 Aug 2012 05:11:10 -0700 (PDT)
In-Reply-To: <5020F5C3.8010107@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-08-07 at 15:02 +0400, Pavel Emelyanov wrote:
> Strictly speaking this is only _really_ required for checkpoint-restore to
> make loopback device always have the same index.
> 
> This change appears to be safe wrt "ifindex should be unique per-system"
> concept, as all the ifindex usage is either already made per net namespace
> of is explicitly limited with init_net only.
> 
> There are two cool side effects of this. The first one -- ifindices of
> devices in container are always small, regardless of how many containers
> we've started (and re-started) so far. The second one is -- we can speed
> up the loopback ifidex access as shown in the next patch.
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
> ---
>  include/net/net_namespace.h |    1 +
>  net/core/dev.c              |    4 ++--
>  2 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
> index ae1cd6c..c5fbebf 100644
> --- a/include/net/net_namespace.h
> +++ b/include/net/net_namespace.h
> @@ -62,6 +62,7 @@ struct net {
>  	struct sock 		*rtnl;			/* rtnetlink socket */
>  	struct sock		*genl_sock;
>  
> +	int			ifindex;

could you place ifindex right after dev_base_seq : avoid two holes
and use the same cache line, dirtied in
list_netdevice()/unlist_netdevice()

>  	struct list_head 	dev_base_head;
>  	struct hlist_head 	*dev_name_head;
>  	struct hlist_head	*dev_index_head;
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 3ca300d..1f06df8 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -5221,12 +5221,12 @@ int dev_ioctl(struct net *net, unsigned int cmd, void __user *arg)
>   */
>  static int dev_new_index(struct net *net)
>  {
> -	static int ifindex;
> +	int ifindex = net->ifindex;
>  	for (;;) {
>  		if (++ifindex <= 0)
>  			ifindex = 1;
>  		if (!__dev_get_by_index(net, ifindex))
> -			return ifindex;
> +			return net->ifindex = ifindex;
>  	}
>  }
>  
