From: Vladislav Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] scpt: Allow struct sctp_event_subscribe to grow without
 breaking binaries
Date: Wed, 04 Apr 2012 09:52:04 -0400
Message-ID: <4F7C5204.9040703@hp.com>
References: <20120404081753.GA5124@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:42757 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756327Ab2DDN7t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 09:59:49 -0400
In-Reply-To: <20120404081753.GA5124@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/04/2012 04:17 AM, Thomas Graf wrote:
> getsockopt(..., SCTP_EVENTS, ...) performs a length check and returns
> an error if the user provides less bytes than the size of struct
> sctp_event_subscribe.
> 
> Struct sctp_event_subscribe needs to be extended by an u8 for every
> new event or notification type that is added.
> 
> This obviously makes getsockopt fail for binaries that are compiled
> against an older versions of <net/sctp/user.h> which do not contain
> all event types.
> 
> This patch changes getsockopt behaviour to no longer return an error
> if not enough bytes are being provided by the user. Instead, it
> returns as much of sctp_event_subscribe as fits into the provided buffer.
> 
> This leads to the new behavior that users see what they have been aware
> of at compile time.
> 
> The setsockopt(..., SCTP_EVENTS, ...) API is already behaving like this.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>

-vlad

> ---
>  net/sctp/socket.c |    5 +++--
>  1 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 06b42b7..92ba71d 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -4133,9 +4133,10 @@ static int sctp_getsockopt_disable_fragments(struct sock *sk, int len,
>  static int sctp_getsockopt_events(struct sock *sk, int len, char __user *optval,
>  				  int __user *optlen)
>  {
> -	if (len < sizeof(struct sctp_event_subscribe))
> +	if (len <= 0)
>  		return -EINVAL;
> -	len = sizeof(struct sctp_event_subscribe);
> +	if (len > sizeof(struct sctp_event_subscribe))
> +		len = sizeof(struct sctp_event_subscribe);
>  	if (put_user(len, optlen))
>  		return -EFAULT;
>  	if (copy_to_user(optval, &sctp_sk(sk)->subscribe, len))
> 
