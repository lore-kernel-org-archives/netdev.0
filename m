From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH] sctp: fix -ENOMEM result with invalid user space pointer
 in sendto() syscall
Date: Mon, 26 Nov 2012 09:56:57 -0500
Message-ID: <50B38339.40105@gmail.com>
References: <1353590596-12216-1-git-send-email-tt.rantala@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	Neil Horman <nhorman@tuxdriver.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Dave Jones <davej@redhat.com>
To: Tommi Rantala <tt.rantala@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:59354 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754290Ab2KZO5C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 09:57:02 -0500
In-Reply-To: <1353590596-12216-1-git-send-email-tt.rantala@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/22/2012 08:23 AM, Tommi Rantala wrote:
> Consider the following program, that sets the second argument to the
> sendto() syscall incorrectly:
>
>   #include <string.h>
>   #include <arpa/inet.h>
>   #include <sys/socket.h>
>
>   int main(void)
>   {
>           int fd;
>           struct sockaddr_in sa;
>
>           fd = socket(AF_INET, SOCK_STREAM, 132 /*IPPROTO_SCTP*/);
>           if (fd < 0)
>                   return 1;
>
>           memset(&sa, 0, sizeof(sa));
>           sa.sin_family = AF_INET;
>           sa.sin_addr.s_addr = inet_addr("127.0.0.1");
>           sa.sin_port = htons(11111);
>
>           sendto(fd, NULL, 1, 0, (struct sockaddr *)&sa, sizeof(sa));
>
>           return 0;
>   }
>
> We get -ENOMEM:
>
>   $ strace -e sendto ./demo
>   sendto(3, NULL, 1, 0, {sa_family=AF_INET, sin_port=htons(11111), sin_addr=inet_addr("127.0.0.1")}, 16) = -1 ENOMEM (Cannot allocate memory)
>
> Propagate the error code from sctp_user_addto_chunk(), so that we will
> tell user space what actually went wrong:
>
>   $ strace -e sendto ./demo
>   sendto(3, NULL, 1, 0, {sa_family=AF_INET, sin_port=htons(11111), sin_addr=inet_addr("127.0.0.1")}, 16) = -1 EFAULT (Bad address)
>
> Noticed while running Trinity (the syscall fuzzer).
>
> Signed-off-by: Tommi Rantala <tt.rantala@gmail.com>

Looks good

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

-vlad

> ---
>   net/sctp/chunk.c  |   13 +++++++++----
>   net/sctp/socket.c |    4 ++--
>   2 files changed, 11 insertions(+), 6 deletions(-)
>
> diff --git a/net/sctp/chunk.c b/net/sctp/chunk.c
> index d241ef5..3952ca9 100644
> --- a/net/sctp/chunk.c
> +++ b/net/sctp/chunk.c
> @@ -183,7 +183,7 @@ struct sctp_datamsg *sctp_datamsg_from_user(struct sctp_association *asoc,
>
>   	msg = sctp_datamsg_new(GFP_KERNEL);
>   	if (!msg)
> -		return NULL;
> +		return ERR_PTR(-ENOMEM);
>
>   	/* Note: Calculate this outside of the loop, so that all fragments
>   	 * have the same expiration.
> @@ -280,8 +280,11 @@ struct sctp_datamsg *sctp_datamsg_from_user(struct sctp_association *asoc,
>
>   		chunk = sctp_make_datafrag_empty(asoc, sinfo, len, frag, 0);
>
> -		if (!chunk)
> +		if (!chunk) {
> +			err = -ENOMEM;
>   			goto errout;
> +		}
> +
>   		err = sctp_user_addto_chunk(chunk, offset, len, msgh->msg_iov);
>   		if (err < 0)
>   			goto errout_chunk_put;
> @@ -315,8 +318,10 @@ struct sctp_datamsg *sctp_datamsg_from_user(struct sctp_association *asoc,
>
>   		chunk = sctp_make_datafrag_empty(asoc, sinfo, over, frag, 0);
>
> -		if (!chunk)
> +		if (!chunk) {
> +			err = -ENOMEM;
>   			goto errout;
> +		}
>
>   		err = sctp_user_addto_chunk(chunk, offset, over,msgh->msg_iov);
>
> @@ -342,7 +347,7 @@ errout:
>   		sctp_chunk_free(chunk);
>   	}
>   	sctp_datamsg_put(msg);
> -	return NULL;
> +	return ERR_PTR(err);
>   }
>
>   /* Check whether this message has expired. */
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index a60d1f8..406d957 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -1915,8 +1915,8 @@ SCTP_STATIC int sctp_sendmsg(struct kiocb *iocb, struct sock *sk,
>
>   	/* Break the message into multiple chunks of maximum size. */
>   	datamsg = sctp_datamsg_from_user(asoc, sinfo, msg, msg_len);
> -	if (!datamsg) {
> -		err = -ENOMEM;
> +	if (IS_ERR(datamsg)) {
> +		err = PTR_ERR(datamsg);
>   		goto out_free;
>   	}
>
>
