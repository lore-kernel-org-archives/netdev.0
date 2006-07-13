From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: [PATCH 10/10] MLSXFRM: Auto-labeling of child sockets
Date: Thu, 13 Jul 2006 09:48:38 -0400
Message-ID: <1152798518.10075.273.camel@moss-spartans.epoch.ncsc.mil>
References: <44B56655.9080303@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jmorris@namei.org, tjaeger@cse.psu.edu,
	selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from mummy.ncsc.mil ([144.51.88.129]:40426 "EHLO jazzhorn.ncsc.mil")
	by vger.kernel.org with ESMTP id S1751442AbWGMNqF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jul 2006 09:46:05 -0400
To: Venkat Yekkirala <vyekkirala@TrustedCS.com>
In-Reply-To: <44B56655.9080303@trustedcs.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-07-12 at 16:15 -0500, Venkat Yekkirala wrote:
> This automatically labels the TCP, Unix stream, and dccp child sockets
> as well as openreqs to be at the same MLS level as the peer.
> 
> Signed-off-by: Venkat Yekkirala <vyekkirala@TrustedCS.com>
> ---
>  include/linux/security.h        |   43 ++++++++++++++++++++++++++
>  include/net/request_sock.h      |    1 
>  include/net/sock.h              |    1 
>  net/dccp/ipv4.c                 |    3 +
>  net/dccp/ipv6.c                 |    7 +++-
>  net/ipv4/inet_connection_sock.c |    4 +-
>  net/ipv4/syncookies.c           |    6 +++
>  net/ipv4/tcp_ipv4.c             |    3 +
>  net/ipv6/tcp_ipv6.c             |    6 ++-
>  security/dummy.c                |   18 +++++++++++
>  security/selinux/hooks.c        |   49 +++++++++++++++++++++++++++++-
>  security/selinux/xfrm.c         |    1 
>  12 files changed, 134 insertions(+), 8 deletions(-)
> 

> --- linux-2.6.17.sk_policy/security/selinux/hooks.c	2006-07-12 09:18:59.000000000 -0500
> +++ linux-2.6.17/security/selinux/hooks.c	2006-07-12 14:55:16.000000000 -0500
> @@ -3324,7 +3324,12 @@ static int selinux_socket_unix_stream_co
>  	/* server child socket */
>  	ssec = newsk->sk_security;
>  	ssec->peer_sid = isec->sid;
> -	
> +	err = security_sid_mls_copy(other_isec->sid, ssec->peer_sid, &ssec->sid);
> +	if (err) {
> +		printk(KERN_ERR "ERROR: security_sid_mls_copy failed.");

Drop the printk please.  It isn't precisely a useful error message
anyway.  If you need to audit such failures, then do it within the
function and use audit_log, and make the message useful.

> +int selinux_inet_conn_request(struct sock *sk, struct sk_buff *skb, 
> +					   struct request_sock *req)
> +{
> +	struct sk_security_struct *sksec = sk->sk_security;
> +	int err;
> +	u32 newsid = 0;
> +	u32 peersid;
> +
> +	BUG_ON(selinux_xfrm_decode_session(skb, &peersid, 0));

Doesn't seem suitable for a BUG_ON.

> +
> +	err = security_sid_mls_copy(sksec->sid, peersid, &newsid);
> +	if (err) {
> +		printk(KERN_ERR "ERROR: security_sid_mls_copy failed.");

Drop the printk.

-- 
Stephen Smalley
National Security Agency

