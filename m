From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net 3/6] sctp: free msg->chunks when sctp_primitive_SEND
 return err
Date: Mon, 12 Sep 2016 16:41:42 -0300
Message-ID: <20160912194142.GD17689@localhost.localdomain>
References: <cover.1473326067.git.lucien.xin@gmail.com>
 <57412abf5d2b0526c28a2ff6a872d63335a45d61.1473326067.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        davem@davemloft.net, Vlad Yasevich <vyasevich@gmail.com>,
        daniel@iogearbox.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52508 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754618AbcILTlp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Sep 2016 15:41:45 -0400
Content-Disposition: inline
In-Reply-To: <57412abf5d2b0526c28a2ff6a872d63335a45d61.1473326067.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 08, 2016 at 05:31:47PM +0800, Xin Long wrote:
> Last patch "sctp: do not return the transmit err back to sctp_sendmsg"
> made sctp_primitive_SEND return err only when asoc state is unavailable.
> In this case, chunks are not enqueued, they have no chance to be freed if
> we don't take care of them later.
> 
> This Patch is actually to revert commit 1cd4d5c4326a ("sctp: remove the
> unused sctp_datamsg_free()") and commit 8b570dc9f7b6 ("sctp: only drop the
> reference on the datamsg after sending a msg"), to use sctp_datamsg_free to
> free the chunks of current msg.
> 

Considering the subsequent patches in this series are improving error
return and the first is a cleanup/optimization, Xin, this patch and the
previous one both deserve a Fixes tag too, for 8b570dc9f7b6. Thanks

> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>  include/net/sctp/structs.h |  1 +
>  net/sctp/chunk.c           | 13 +++++++++++++
>  net/sctp/socket.c          |  6 ++++--
>  3 files changed, 18 insertions(+), 2 deletions(-)
> 
> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> index ce93c4b..f61fb7c 100644
> --- a/include/net/sctp/structs.h
> +++ b/include/net/sctp/structs.h
> @@ -537,6 +537,7 @@ struct sctp_datamsg {
>  struct sctp_datamsg *sctp_datamsg_from_user(struct sctp_association *,
>  					    struct sctp_sndrcvinfo *,
>  					    struct iov_iter *);
> +void sctp_datamsg_free(struct sctp_datamsg *);
>  void sctp_datamsg_put(struct sctp_datamsg *);
>  void sctp_chunk_fail(struct sctp_chunk *, int error);
>  int sctp_chunk_abandoned(struct sctp_chunk *);
> diff --git a/net/sctp/chunk.c b/net/sctp/chunk.c
> index a55e547..af9cc80 100644
> --- a/net/sctp/chunk.c
> +++ b/net/sctp/chunk.c
> @@ -70,6 +70,19 @@ static struct sctp_datamsg *sctp_datamsg_new(gfp_t gfp)
>  	return msg;
>  }
>  
> +void sctp_datamsg_free(struct sctp_datamsg *msg)
> +{
> +	struct sctp_chunk *chunk;
> +
> +	/* This doesn't have to be a _safe vairant because
> +	 * sctp_chunk_free() only drops the refs.
> +	 */
> +	list_for_each_entry(chunk, &msg->chunks, frag_list)
> +		sctp_chunk_free(chunk);
> +
> +	sctp_datamsg_put(msg);
> +}
> +
>  /* Final destructruction of datamsg memory. */
>  static void sctp_datamsg_destroy(struct sctp_datamsg *msg)
>  {
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 9fc417a..9d8e2be 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -1970,13 +1970,15 @@ static int sctp_sendmsg(struct sock *sk, struct msghdr *msg, size_t msg_len)
>  	 * breaks.
>  	 */
>  	err = sctp_primitive_SEND(net, asoc, datamsg);
> -	sctp_datamsg_put(datamsg);
>  	/* Did the lower layer accept the chunk? */
> -	if (err)
> +	if (err) {
> +		sctp_datamsg_free(datamsg);
>  		goto out_free;
> +	}
>  
>  	pr_debug("%s: we sent primitively\n", __func__);
>  
> +	sctp_datamsg_put(datamsg);
>  	err = msg_len;
>  
>  	if (unlikely(wait_connect)) {
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
