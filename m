From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net v3] net: sctp: sctp_transport_destroy{,_rcu}: fix
 potential pointer corruption
Date: Fri, 09 Aug 2013 10:42:37 -0400
Message-ID: <5204FFDD.5060703@gmail.com>
References: <1376058321-2461-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f42.google.com ([209.85.212.42]:33978 "EHLO
	mail-vb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030282Ab3HIOmk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 10:42:40 -0400
In-Reply-To: <1376058321-2461-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/09/2013 10:25 AM, Daniel Borkmann wrote:
> Probably this one is quite unlikely to be triggered, but it's more safe
> to do the call_rcu() at the end after we have dropped the reference on
> the asoc and freed sctp packet chunks. The reason why is because in
> sctp_transport_destroy_rcu() the transport is being kfree()'d, and if
> we're unlucky enough we could run into corrupted pointers. Probably
> that's more of theoretical nature, but it's safer to have this simple fix.
>
> Introduced by commit 8c98653f ("sctp: sctp_close: fix release of bindings
> for deferred call_rcu's"). I also did the 8c98653f regression test and
> it's fine that way.
>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

-vlad

> ---
>   net/sctp/transport.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/net/sctp/transport.c b/net/sctp/transport.c
> index bdbbc3f..8fdd160 100644
> --- a/net/sctp/transport.c
> +++ b/net/sctp/transport.c
> @@ -181,12 +181,12 @@ static void sctp_transport_destroy(struct sctp_transport *transport)
>   		return;
>   	}
>
> -	call_rcu(&transport->rcu, sctp_transport_destroy_rcu);
> -
>   	sctp_packet_free(&transport->packet);
>
>   	if (transport->asoc)
>   		sctp_association_put(transport->asoc);
> +
> +	call_rcu(&transport->rcu, sctp_transport_destroy_rcu);
>   }
>
>   /* Start T3_rtx timer if it is not already running and update the heartbeat
>
