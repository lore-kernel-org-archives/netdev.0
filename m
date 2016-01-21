From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net 2/3] sctp: hold transport before we access t->asoc in
 sctp proc
Date: Thu, 21 Jan 2016 15:53:47 -0200
Message-ID: <20160121175347.GE3452@mrl.redhat.com>
References: <cover.1453398443.git.lucien.xin@gmail.com>
 <4357f1f3ad90ffec1481a265d8ca198d75e25d07.1453398443.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44590 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755545AbcAURxu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jan 2016 12:53:50 -0500
Content-Disposition: inline
In-Reply-To: <4357f1f3ad90ffec1481a265d8ca198d75e25d07.1453398443.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 22, 2016 at 01:49:08AM +0800, Xin Long wrote:
> Previously, before rhashtable, /proc assoc listing was done by
> read-locking the entire hash entry and dumping all assocs at once, so we
> were sure that the assoc wasn't freed because it wouldn't be possible to
> remove it from the hash meanwhile.
> 
> Now we use rhashtable to list transports, and dump entries one by one.
> That is, now we have to check if the assoc is still a good one, as the
> transport we got may be being freed.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Reviewed-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

> ---
>  net/sctp/proc.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/net/sctp/proc.c b/net/sctp/proc.c
> index 684c5b3..c74a810 100644
> --- a/net/sctp/proc.c
> +++ b/net/sctp/proc.c
> @@ -380,6 +380,8 @@ static int sctp_assocs_seq_show(struct seq_file *seq, void *v)
>  	}
>  
>  	transport = (struct sctp_transport *)v;
> +	if (!sctp_transport_hold(transport))
> +		return 0;
>  	assoc = transport->asoc;
>  	epb = &assoc->base;
>  	sk = epb->sk;
> @@ -412,6 +414,8 @@ static int sctp_assocs_seq_show(struct seq_file *seq, void *v)
>  		sk->sk_rcvbuf);
>  	seq_printf(seq, "\n");
>  
> +	sctp_transport_put(transport);
> +
>  	return 0;
>  }
>  
> @@ -489,6 +493,8 @@ static int sctp_remaddr_seq_show(struct seq_file *seq, void *v)
>  	}
>  
>  	tsp = (struct sctp_transport *)v;
> +	if (!sctp_transport_hold(tsp))
> +		return 0;
>  	assoc = tsp->asoc;
>  
>  	list_for_each_entry_rcu(tsp, &assoc->peer.transport_addr_list,
> @@ -544,6 +550,8 @@ static int sctp_remaddr_seq_show(struct seq_file *seq, void *v)
>  		seq_printf(seq, "\n");
>  	}
>  
> +	sctp_transport_put(tsp);
> +
>  	return 0;
>  }
>  
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
