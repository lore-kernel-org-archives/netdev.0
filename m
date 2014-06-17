From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next 1/6] Support for SCTP_RECVRCVINFO socket option
Date: Tue, 17 Jun 2014 09:57:01 -0400
Message-ID: <53A0492D.9010409@gmail.com>
References: <1403006273-27859-1-git-send-email-geirola@gmail.com> <1403006273-27859-2-git-send-email-geirola@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org
To: Geir Ola Vaagland <geirola@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f47.google.com ([209.85.216.47]:49370 "EHLO
	mail-qa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932133AbaFQN5F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 09:57:05 -0400
In-Reply-To: <1403006273-27859-2-git-send-email-geirola@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/17/2014 07:57 AM, Geir Ola Vaagland wrote:

Again,  some description and a pointer to RFC/Section
for what this patch is implementing.

> CC: Vlad Yasevich <vyasevich@gmail.com>
> Signed-off-by: Geir Ola Vaagland <geirola@gmail.com>
> ---
>  include/net/sctp/structs.h |  1 +
>  include/uapi/linux/sctp.h  |  2 ++
>  net/sctp/socket.c          | 48 ++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 51 insertions(+)
> 
> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> index 0a248b3..75c598a 100644
> --- a/include/net/sctp/structs.h
> +++ b/include/net/sctp/structs.h
> @@ -216,6 +216,7 @@ struct sctp_sock {
>  	__u8 frag_interleave;
>  	__u32 adaptation_ind;
>  	__u32 pd_point;
> +	__u8 recvrcvinfo;
>  
>  	atomic_t pd_mode;
>  	/* Receive to here while partial delivery is in effect. */
> diff --git a/include/uapi/linux/sctp.h b/include/uapi/linux/sctp.h
> index ca451e9..a7db3b3 100644
> --- a/include/uapi/linux/sctp.h
> +++ b/include/uapi/linux/sctp.h
> @@ -97,6 +97,8 @@ typedef __s32 sctp_assoc_t;
>  #define SCTP_AUTO_ASCONF       30
>  #define SCTP_PEER_ADDR_THLDS	31
>  
> +#define SCTP_RECVRCVINFO 32
> +

The above probably shouldn't have an empty line between options 31 and 32.

>  /* Internal Socket Options. Some of the sctp library functions are
>   * implemented using these socket options.
>   */
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 146b35d..1f3281b 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -3566,6 +3566,24 @@ static int sctp_setsockopt_paddr_thresholds(struct sock *sk,
>  	return 0;
>  }
>  
> +static int sctp_setsockopt_recvrcvinfo(struct sock *sk,
> +		char __user *optval,
> +		unsigned int optlen){

Coding style. Please put a space between ) and {.  Also,
please align definitions with above 'struct sock'.
As in:
+static int sctp_setsockopt_recvrcvinfo(struct sock *sk,
+		                        char __user *optval,
+		                        unsigned int optlen) {

For more info on coding style see Documentation/CodingStyle
in the kernel tree.

> +
> +	int val;
> +
> +	if(optlen < sizeof(int))
> +		return -EINVAL;
> +
> +	if(get_user(val, (int __user*)optval)){
> +		return -EFAULT;
> +	}
> +	sctp_sk(sk)->recvrcvinfo = (val == 0) ? 0 : 1;
> +	return 0;
> +}
> +
> +
> +
>  /* API 6.2 setsockopt(), getsockopt()
>   *
>   * Applications use setsockopt() and getsockopt() to set or retrieve
> @@ -3717,6 +3735,9 @@ static int sctp_setsockopt(struct sock *sk, int level, int optname,
>  	case SCTP_PEER_ADDR_THLDS:
>  		retval = sctp_setsockopt_paddr_thresholds(sk, optval, optlen);
>  		break;
> +	case SCTP_RECVRCVINFO:
> +		retval = sctp_setsockopt_recvrcvinfo(sk, optval, optlen);
> +		break;
>  	default:
>  		retval = -ENOPROTOOPT;
>  		break;
> @@ -3963,6 +3984,9 @@ static int sctp_init_sock(struct sock *sk)
>  	/* Enable Nagle algorithm by default.  */
>  	sp->nodelay           = 0;
>  
> +	/* No SCTP_RECVRCVINFO by default. */
> +	sp->recvrcvinfo = 0;
> +
>  	/* Enable by default. */
>  	sp->v4mapped          = 1;
>  
> @@ -5734,6 +5758,27 @@ static int sctp_getsockopt_assoc_stats(struct sock *sk, int len,
>  	return 0;
>  }
>  
> +static int sctp_getsockopt_recvrcvinfo(struct sock *sk,
> +		int len,
> +		char __user *optval,
> +		int __user *optlen){
> +

Indent issue.

-vlad

> +	int val;
> +
> +	if (len < sizeof(int))
> +		return -EINVAL;
> +
> +	len = sizeof(int);
> +	val = (sctp_sk(sk)->recvrcvinfo == 1);
> +	if (put_user(len, optlen))
> +		return -EFAULT;
> +	if (copy_to_user(optval, &val, len))
> +		return -EFAULT;
> +	return 0;
> +}
> +
> +
> +
>  static int sctp_getsockopt(struct sock *sk, int level, int optname,
>  			   char __user *optval, int __user *optlen)
>  {
> @@ -5877,6 +5922,9 @@ static int sctp_getsockopt(struct sock *sk, int level, int optname,
>  	case SCTP_GET_ASSOC_STATS:
>  		retval = sctp_getsockopt_assoc_stats(sk, len, optval, optlen);
>  		break;
> +	case SCTP_RECVRCVINFO:
> +		retval = sctp_getsockopt_recvrcvinfo(sk, len, optval, optlen);
> +		break;
>  	default:
>  		retval = -ENOPROTOOPT;
>  		break;
> 
