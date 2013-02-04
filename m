From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] sctp: sctp_close: fix release of bindings
 for deferred call_rcu's
Date: Mon, 04 Feb 2013 13:23:02 -0500 (EST)
Message-ID: <20130204.132302.931092608711964255.davem@davemloft.net>
References: <1359729463-11833-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	vyasevich@gmail.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43987 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754787Ab3BDSXF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2013 13:23:05 -0500
In-Reply-To: <1359729463-11833-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Fri,  1 Feb 2013 15:37:43 +0100

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

Applied.
