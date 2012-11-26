From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] sctp: fix memory leak in sctp_datamsg_from_user() when
 copy from user space fails
Date: Mon, 26 Nov 2012 10:23:56 -0500
Message-ID: <20121126152355.GB8016@hmsreliant.think-freely.org>
References: <1353590491-12166-1-git-send-email-tt.rantala@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	Vlad Yasevich <vyasevich@gmail.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Dave Jones <davej@redhat.com>
To: Tommi Rantala <tt.rantala@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:34537 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754041Ab2KZPYN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 10:24:13 -0500
Content-Disposition: inline
In-Reply-To: <1353590491-12166-1-git-send-email-tt.rantala@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 22, 2012 at 03:21:31PM +0200, Tommi Rantala wrote:
> Trinity (the syscall fuzzer) discovered a memory leak in SCTP,
> reproducible e.g. with the sendto() syscall by passing invalid
> user space pointer in the second argument:
> 
>  #include <string.h>
>  #include <arpa/inet.h>
>  #include <sys/socket.h>
> 
>  int main(void)
>  {
>          int fd;
>          struct sockaddr_in sa;
> 
>          fd = socket(AF_INET, SOCK_STREAM, 132 /*IPPROTO_SCTP*/);
>          if (fd < 0)
>                  return 1;
> 
>          memset(&sa, 0, sizeof(sa));
>          sa.sin_family = AF_INET;
>          sa.sin_addr.s_addr = inet_addr("127.0.0.1");
>          sa.sin_port = htons(11111);
> 
>          sendto(fd, NULL, 1, 0, (struct sockaddr *)&sa, sizeof(sa));
> 
>          return 0;
>  }
> 
> As far as I can tell, the leak has been around since ~2003.
> 
> Signed-off-by: Tommi Rantala <tt.rantala@gmail.com>
> ---
>  net/sctp/chunk.c |    7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sctp/chunk.c b/net/sctp/chunk.c
> index 7c2df9c..d241ef5 100644
> --- a/net/sctp/chunk.c
> +++ b/net/sctp/chunk.c
> @@ -284,7 +284,7 @@ struct sctp_datamsg *sctp_datamsg_from_user(struct sctp_association *asoc,
>  			goto errout;
>  		err = sctp_user_addto_chunk(chunk, offset, len, msgh->msg_iov);
>  		if (err < 0)
> -			goto errout;
> +			goto errout_chunk_put;
>  
>  		offset += len;
>  
> @@ -324,7 +324,7 @@ struct sctp_datamsg *sctp_datamsg_from_user(struct sctp_association *asoc,
>  		__skb_pull(chunk->skb, (__u8 *)chunk->chunk_hdr
>  			   - (__u8 *)chunk->skb->data);
>  		if (err < 0)
> -			goto errout;
> +			goto errout_chunk_put;
>  
>  		sctp_datamsg_assign(msg, chunk);
>  		list_add_tail(&chunk->frag_list, &msg->chunks);
> @@ -332,6 +332,9 @@ struct sctp_datamsg *sctp_datamsg_from_user(struct sctp_association *asoc,
>  
>  	return msg;
>  
> +errout_chunk_put:
> +	sctp_chunk_put(chunk);
> +
>  errout:
>  	list_for_each_safe(pos, temp, &msg->chunks) {
>  		list_del_init(pos);
> -- 
> 1.7.9.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

I'm fine with it the way it is, but it might be nicer if you instead just moved
the list_add_tail call up between the if (!chunk) check and the
sctp_user_addto_chunk call.  That way the unwind loop at the errout label can
just free the chunk without the need for an extra label.

Neil
