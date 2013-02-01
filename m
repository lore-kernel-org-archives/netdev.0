From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next v3] sctp: sctp_close: fix release of bindings
 for deferred call_rcu's
Date: Fri, 01 Feb 2013 09:55:10 -0500
Message-ID: <510BD74E.3010409@gmail.com>
References: <1359729463-11833-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f182.google.com ([209.85.210.182]:41256 "EHLO
	mail-ia0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751246Ab3BAOzO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2013 09:55:14 -0500
In-Reply-To: <1359729463-11833-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/01/2013 09:37 AM, Daniel Borkmann wrote:
>
> The underlying problem is that sctp_endpoint_destroy() hasn't been
> triggered yet while the next bind attempt is being done. It will be
> triggered eventually (but too late) by sctp_transport_destroy_rcu()
> after one RCU grace period:
>
>    sctp_transport_destroy()
>      sctp_transport_destroy_rcu() ----.
>        sctp_association_put() [*]  <--+--> sctp_packet_free()
>          sctp_association_destroy()          [...]
>            sctp_endpoint_put()                 skb->destructor
>              sctp_endpoint_destroy()             sctp_wfree()
>                sctp_bind_addr_free()               sctp_association_put() [*]
>
> Thus, we move out the condition with sctp_association_put() as well as
> the sctp_packet_free() invocation and the issue can be solved. We also
> better free the SCTP chunks first before putting the ref of the association.
>
> With this patch, the example above (which simulates a similar scenario
> as in the implementation of this test case) and therefore also the test
> suite run successfully through. Tested by myself.
>
> Cc: Vlad Yasevich <vyasevich@gmail.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

-vlad

> ---
>   net/sctp/transport.c | 9 +++++----
>   1 file changed, 5 insertions(+), 4 deletions(-)
>
> diff --git a/net/sctp/transport.c b/net/sctp/transport.c
> index 4e45bb6..ca5331c 100644
> --- a/net/sctp/transport.c
> +++ b/net/sctp/transport.c
> @@ -168,10 +168,6 @@ static void sctp_transport_destroy_rcu(struct rcu_head *head)
>   	struct sctp_transport *transport;
>
>   	transport = container_of(head, struct sctp_transport, rcu);
> -	if (transport->asoc)
> -		sctp_association_put(transport->asoc);
> -
> -	sctp_packet_free(&transport->packet);
>
>   	dst_release(transport->dst);
>   	kfree(transport);
> @@ -186,6 +182,11 @@ static void sctp_transport_destroy(struct sctp_transport *transport)
>   	SCTP_ASSERT(transport->dead, "Transport is not dead", return);
>
>   	call_rcu(&transport->rcu, sctp_transport_destroy_rcu);
> +
> +	sctp_packet_free(&transport->packet);
> +
> +	if (transport->asoc)
> +		sctp_association_put(transport->asoc);
>   }
>
>   /* Start T3_rtx timer if it is not already running and update the heartbeat
>
