From: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: Re: [PATCH] Don't allow multiple TPGs or targets to share a portal
Date: Wed, 13 Feb 2013 12:31:56 -0800
Message-ID: <1360787516.13707.59.camel@haakon2.linux-iscsi.org>
References: <1360364708-26104-1-git-send-email-agrover@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: target-devel@vger.kernel.org, netdev@vger.kernel.org
To: Andy Grover <agrover@redhat.com>
Return-path: <target-devel-owner@vger.kernel.org>
In-Reply-To: <1360364708-26104-1-git-send-email-agrover@redhat.com>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-02-08 at 15:05 -0800, Andy Grover wrote:
> RFC 3720 says "Each Network Portal, as utilized by a given iSCSI Node,
> belongs to exactly one portal group within that node." therefore
> iscsit_add_np should not check for existing matching portals, it should
> just go ahead and try to make the portal, and then kernel_bind() will
> return the proper error.
> 
> Signed-off-by: Andy Grover <agrover@redhat.com>
> ---

NACK.  Your interpretation of RFC-3720 is incorrect.  There is nothing
that says that a single IP address cannot be shared across multiple
TargetName+TargetPortalGroupTag endpoints.

--nab

>  drivers/target/iscsi/iscsi_target.c |   64 -----------------------------------
>  1 files changed, 0 insertions(+), 64 deletions(-)
> 
> diff --git a/drivers/target/iscsi/iscsi_target.c b/drivers/target/iscsi/iscsi_target.c
> index 339f97f..73be05c 100644
> --- a/drivers/target/iscsi/iscsi_target.c
> +++ b/drivers/target/iscsi/iscsi_target.c
> @@ -264,64 +264,6 @@ int iscsit_deaccess_np(struct iscsi_np *np, struct iscsi_portal_group *tpg)
>  	return 0;
>  }
>  
> -static struct iscsi_np *iscsit_get_np(
> -	struct __kernel_sockaddr_storage *sockaddr,
> -	int network_transport)
> -{
> -	struct sockaddr_in *sock_in, *sock_in_e;
> -	struct sockaddr_in6 *sock_in6, *sock_in6_e;
> -	struct iscsi_np *np;
> -	int ip_match = 0;
> -	u16 port;
> -
> -	spin_lock_bh(&np_lock);
> -	list_for_each_entry(np, &g_np_list, np_list) {
> -		spin_lock(&np->np_thread_lock);
> -		if (np->np_thread_state != ISCSI_NP_THREAD_ACTIVE) {
> -			spin_unlock(&np->np_thread_lock);
> -			continue;
> -		}
> -
> -		if (sockaddr->ss_family == AF_INET6) {
> -			sock_in6 = (struct sockaddr_in6 *)sockaddr;
> -			sock_in6_e = (struct sockaddr_in6 *)&np->np_sockaddr;
> -
> -			if (!memcmp(&sock_in6->sin6_addr.in6_u,
> -				    &sock_in6_e->sin6_addr.in6_u,
> -				    sizeof(struct in6_addr)))
> -				ip_match = 1;
> -
> -			port = ntohs(sock_in6->sin6_port);
> -		} else {
> -			sock_in = (struct sockaddr_in *)sockaddr;
> -			sock_in_e = (struct sockaddr_in *)&np->np_sockaddr;
> -
> -			if (sock_in->sin_addr.s_addr ==
> -			    sock_in_e->sin_addr.s_addr)
> -				ip_match = 1;
> -
> -			port = ntohs(sock_in->sin_port);
> -		}
> -
> -		if ((ip_match == 1) && (np->np_port == port) &&
> -		    (np->np_network_transport == network_transport)) {
> -			/*
> -			 * Increment the np_exports reference count now to
> -			 * prevent iscsit_del_np() below from being called
> -			 * while iscsi_tpg_add_network_portal() is called.
> -			 */
> -			np->np_exports++;
> -			spin_unlock(&np->np_thread_lock);
> -			spin_unlock_bh(&np_lock);
> -			return np;
> -		}
> -		spin_unlock(&np->np_thread_lock);
> -	}
> -	spin_unlock_bh(&np_lock);
> -
> -	return NULL;
> -}
> -
>  struct iscsi_np *iscsit_add_np(
>  	struct __kernel_sockaddr_storage *sockaddr,
>  	char *ip_str,
> @@ -331,12 +273,6 @@ struct iscsi_np *iscsit_add_np(
>  	struct sockaddr_in6 *sock_in6;
>  	struct iscsi_np *np;
>  	int ret;
> -	/*
> -	 * Locate the existing struct iscsi_np if already active..
> -	 */
> -	np = iscsit_get_np(sockaddr, network_transport);
> -	if (np)
> -		return np;
>  
>  	np = kzalloc(sizeof(struct iscsi_np), GFP_KERNEL);
>  	if (!np) {
