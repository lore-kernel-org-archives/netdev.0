From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next] change nfqueue failopen to apply also to
 receive message buffer in addition to queue size
Date: Mon, 21 Mar 2016 22:35:32 +0100
Message-ID: <20160321213532.GA1818@salvia>
References: <2ba8dceec36a41149598e43f09af048e@XCH-RTP-014.cisco.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="6c2NcOVqGQ03X4Wi"
Cc: "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"Florian Westphal (fw@strlen.de)" <fw@strlen.de>
To: "Yigal Reiss (yreiss)" <yreiss@cisco.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <2ba8dceec36a41149598e43f09af048e@XCH-RTP-014.cisco.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--6c2NcOVqGQ03X4Wi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Mar 21, 2016 at 11:23:43AM +0000, Yigal Reiss (yreiss) wrote:
> @@ -582,10 +585,17 @@ __nfqnl_enqueue_packet(struct net *net, struct nfqnl_instance *queue,
>  	*packet_id_ptr = htonl(entry->id);
>  
>  	/* nfnetlink_unicast will either free the nskb or add it to a socket */
> -	err = nfnetlink_unicast(nskb, net, queue->peer_portid, MSG_DONTWAIT);
> +	err = nfnetlink_unicast_nofree(nskb, net, queue->peer_portid, MSG_DONTWAIT);

This keeps nskb around, this skbuff contains the netlink message, not
the network packet itself that is located in entry->skb.

>  	if (err < 0) {
> -		queue->queue_user_dropped++;
> -		goto err_out_unlock;
> +		if (queue->flags & NFQA_CFG_F_FAIL_OPEN) {
> +		        queue->nobuf_failopened++;
> +		        failopen = 1;
> +			err = 0;

In case we couldn't deliver due to socket buffer overrun, if the
NFQA_CFG_F_FAIL_OPEN flag is set, you set failopen to 1.

> +		}
> +		else {
> +		    queue->queue_user_dropped++;
> +		}
> +		goto err_out_free_nskb;

And finally, jump to err_out_free_nskb.

>  	}
>  
>  	__enqueue_entry(queue, entry);
> @@ -595,7 +605,6 @@ __nfqnl_enqueue_packet(struct net *net, struct nfqnl_instance *queue,
>  
>  err_out_free_nskb:
>  	kfree_skb(nskb);

Which just releases the netlink skbuff.

> -err_out_unlock:
>  	spin_unlock_bh(&queue->lock);
>  	if (failopen)
>  		nf_reinject(entry, NF_ACCEPT);

And reinjects the packet.

So isn't the more simple patch that I'm attaching achieving what you need?

Let me know, thanks.

--6c2NcOVqGQ03X4Wi
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="x.patch"

diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 7542999..cb5b630 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -582,7 +582,12 @@ __nfqnl_enqueue_packet(struct net *net, struct nfqnl_instance *queue,
 	/* nfnetlink_unicast will either free the nskb or add it to a socket */
 	err = nfnetlink_unicast(nskb, net, queue->peer_portid, MSG_DONTWAIT);
 	if (err < 0) {
-		queue->queue_user_dropped++;
+		if (queue->flags & NFQA_CFG_F_FAIL_OPEN) {
+			failopen = 1;
+			err = 0;
+		} else {
+			queue->queue_user_dropped++;
+		}
 		goto err_out_unlock;
 	}
 

--6c2NcOVqGQ03X4Wi--
