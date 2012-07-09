From: Paul Moore <paul@paul-moore.com>
Subject: Re: [PATCH net-next 05/15] security: selinux: Add AF_BUS socket SELinux hooks
Date: Mon, 09 Jul 2012 14:38:44 -0400
Message-ID: <27959382.kdMZfHm1r3@sifl>
References: <1340988354-26981-1-git-send-email-vincent.sanders@collabora.co.uk> <1340988354-26981-6-git-send-email-vincent.sanders@collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Javier Martinez Canillas <javier.martinez@collabora.co.uk>
To: Vincent Sanders <vincent.sanders@collabora.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1340988354-26981-6-git-send-email-vincent.sanders@collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday, June 29, 2012 05:45:44 PM Vincent Sanders wrote:
> From: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
> 
> Add Security-Enhanced Linux (SELinux) hook for AF_BUS socket address family.
> 
> Signed-off-by: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
> Signed-off-by: Vincent Sanders <vincent.sanders@collabora.co.uk>

It would be very helpful to include a description of how the access controls 
would work.

>From looking at the other patches, it would appear that when a new socket 
tries to connect to the AF_BUS bus it is checked against the security label of 
the bus master, yes?  Further, if no bus master is present, the connect() is 
denied at the AF_BUS level in the bus_connect() function, yes?

Have you considered the socket_getpeersec_dgram() hook?  Since AF_BUS does not 
appear to be stream oriented I think you can safely ignore 
socket_getpeersec_stream().

Have you considered the unix_may_send() hook?  Ignoring the AF_UNIX specific 
name, it seems like a reasonable hook for AF_BUS; unless you don't expect to 
have any read-only AF_BUS clients in which case the connect() hook should be 
enough (it would implicitly grant read/write access to each socket in that 
case).

Finally, as others have said, you need to ensure that you CC the LSM and 
SELinux lists on the relevant patches as well as provide LSM hook 
implementations for LSMs other than SELinux where it makes sense (not all LSMs 
will require implementations for the new hooks). 

> ---
>  security/selinux/hooks.c |   35 +++++++++++++++++++++++++++++++++++
>  1 file changed, 35 insertions(+)
> 
> diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> index 4ee6f23..5bacbe2 100644
> --- a/security/selinux/hooks.c
> +++ b/security/selinux/hooks.c
> @@ -67,6 +67,7 @@
>  #include <linux/quota.h>
>  #include <linux/un.h>		/* for Unix socket types */
>  #include <net/af_unix.h>	/* for Unix socket types */
> +#include <net/af_bus.h>	/* for Bus socket types */
>  #include <linux/parser.h>
>  #include <linux/nfs_mount.h>
>  #include <net/ipv6.h>
> @@ -4101,6 +4102,39 @@ static int selinux_socket_unix_may_send(struct socket
> *sock, &ad);
>  }
> 
> +static int selinux_socket_bus_connect(struct sock *sock, struct sock
> *other, +				      struct sock *newsk)
> +{
> +	struct sk_security_struct *sksec_sock = sock->sk_security;
> +	struct sk_security_struct *sksec_other = other->sk_security;
> +	struct sk_security_struct *sksec_new = newsk->sk_security;
> +	struct common_audit_data ad;
> +	struct lsm_network_audit net = {0,};
> +	int err;
> +
> +	ad.type = LSM_AUDIT_DATA_NET;
> +	ad.u.net = &net;
> +	ad.u.net->sk = other;
> +
> +	err = avc_has_perm(sksec_sock->sid, sksec_other->sid,
> +			   sksec_other->sclass,
> +			   UNIX_STREAM_SOCKET__CONNECTTO, &ad);

See my earlier comments about the similarities between this new hook and the 
existing AF_UNIX hook.  The fact that you are reusing the 
UNIX_STREAM_SOCKET__CONNECTTO permission (which is likely a no-no BTW) only 
reinforces the similarities between the two.

> +	if (err)
> +		return err;
> +
> +	/* server child socket */
> +	sksec_new->peer_sid = sksec_sock->sid;
> +	err = security_sid_mls_copy(sksec_other->sid, sksec_sock->sid,
> +				    &sksec_new->sid);
> +	if (err)
> +		return err;
> +
> +	/* connecting socket */
> +	sksec_sock->peer_sid = sksec_new->sid;
> +
> +	return 0;
> +}
> +
>  static int selinux_inet_sys_rcv_skb(int ifindex, char *addrp, u16 family,
>  				    u32 peer_sid,
>  				    struct common_audit_data *ad)
> @@ -5643,6 +5677,7 @@ static struct security_operations selinux_ops = {
> 
>  	.unix_stream_connect =		selinux_socket_unix_stream_connect,
>  	.unix_may_send =		selinux_socket_unix_may_send,
> +	.bus_connect =		        selinux_socket_bus_connect,
> 
>  	.socket_create =		selinux_socket_create,
>  	.socket_post_create =		selinux_socket_post_create,

-- 
paul moore
www.paul-moore.com
