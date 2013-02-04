From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next v3] sctp: sctp_close: fix release of bindings
 for deferred call_rcu's
Date: Mon, 4 Feb 2013 07:10:19 -0500
Message-ID: <20130204121019.GA19661@hmsreliant.think-freely.org>
References: <1359729463-11833-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:46470 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754460Ab3BDMKg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2013 07:10:36 -0500
Content-Disposition: inline
In-Reply-To: <1359729463-11833-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 01, 2013 at 03:37:43PM +0100, Daniel Borkmann wrote:
> It seems due to RCU usage, i.e. within SCTP's address binding list,
> a, say, ``behavioral change'' was introduced which does actually
> not conform to the RFC anymore. In particular consider the following
> (fictional) scenario to demonstrate this:
> 
>   do:
>     Two SOCK_SEQPACKET-style sockets are opened (S1, S2)
>     S1 is bound to 127.0.0.1, port 1024 [server]
>     S2 is bound to 127.0.0.1, port 1025 [client]
>     listen(2) is invoked on S1
>     From S2 we call one sendmsg(2) with msg.msg_name and
>        msg.msg_namelen parameters set to the server's
>        address
>     S1, S2 are closed
>     goto do
> 
> The first pass of this loop passes successful, while the second round
> fails during binding of S1 (address still in use). What is happening?
> In the first round, the initial handshake is being done, and, at the
> time close(2) is called on S1, a non-graceful shutdown is performed via
> ABORT since in S1's receive queue an unprocessed packet is present,
> thus stating an error condition. This can be considered as a correct
> behavior.
> 
> During close also all bound addresses are freed, thus nothing *must*
> be active anymore. In reference to RFC2960:
> 
>   After checking the Verification Tag, the receiving endpoint shall
>   remove the association from its record, and shall report the
>   termination to its upper layer. (9.1 Abort of an Association)
> 
> Also, no half-open states are supported, thus after an ungraceful
> shutdown, we leave nothing behind. However, this seems not to be
> happening though. In a real-world scenario, this is exactly where
> it breaks the lksctp-tools functional test suite, *for instance*:
> 
>   ./test_sockopt
>   test_sockopt.c  1 PASS : getsockopt(SCTP_STATUS) on a socket with no assoc
>   test_sockopt.c  2 PASS : getsockopt(SCTP_STATUS)
>   test_sockopt.c  3 PASS : getsockopt(SCTP_STATUS) with invalid associd
>   test_sockopt.c  4 PASS : getsockopt(SCTP_STATUS) with NULL associd
>   test_sockopt.c  5 BROK : bind: Address already in use
> 
> The underlying problem is that sctp_endpoint_destroy() hasn't been
> triggered yet while the next bind attempt is being done. It will be
> triggered eventually (but too late) by sctp_transport_destroy_rcu()
> after one RCU grace period:
> 
>   sctp_transport_destroy()
>     sctp_transport_destroy_rcu() ----.
>       sctp_association_put() [*]  <--+--> sctp_packet_free()
>         sctp_association_destroy()          [...]
>           sctp_endpoint_put()                 skb->destructor
>             sctp_endpoint_destroy()             sctp_wfree()
>               sctp_bind_addr_free()               sctp_association_put() [*]
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
> ---
>  net/sctp/transport.c | 9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/net/sctp/transport.c b/net/sctp/transport.c
> index 4e45bb6..ca5331c 100644
> --- a/net/sctp/transport.c
> +++ b/net/sctp/transport.c
> @@ -168,10 +168,6 @@ static void sctp_transport_destroy_rcu(struct rcu_head *head)
>  	struct sctp_transport *transport;
>  
>  	transport = container_of(head, struct sctp_transport, rcu);
> -	if (transport->asoc)
> -		sctp_association_put(transport->asoc);
> -
> -	sctp_packet_free(&transport->packet);
>  
>  	dst_release(transport->dst);
>  	kfree(transport);
> @@ -186,6 +182,11 @@ static void sctp_transport_destroy(struct sctp_transport *transport)
>  	SCTP_ASSERT(transport->dead, "Transport is not dead", return);
>  
>  	call_rcu(&transport->rcu, sctp_transport_destroy_rcu);
> +
> +	sctp_packet_free(&transport->packet);
> +
> +	if (transport->asoc)
> +		sctp_association_put(transport->asoc);
>  }
>  
Yup, this looks good, thanks!
Acked-by: Neil Horman <nhorman@tuxdriver.com>
