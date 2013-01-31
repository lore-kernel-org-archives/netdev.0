From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next] sctp: sctp_close: fix release of bindings for
 deferred call_rcu's
Date: Thu, 31 Jan 2013 14:49:03 -0500
Message-ID: <510ACAAF.8010902@gmail.com>
References: <cover.1359650254.git.dborkman@redhat.com> <13ea81dcf399f935bd8e048ce225411d8f29a792.1359650254.git.dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f177.google.com ([209.85.216.177]:64735 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751688Ab3AaTtI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2013 14:49:08 -0500
In-Reply-To: <13ea81dcf399f935bd8e048ce225411d8f29a792.1359650254.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/31/2013 11:51 AM, Daniel Borkmann wrote:
> It seems due to RCU usage, i.e. within SCTP's address binding list,
> a, say, ``behavioral change'' was introduced which does actually
> not conform to the RFC anymore. In particular consider the following
> (fictional) scenario to demonstrate this:
>
>    do:
>      Two SOCK_SEQPACKET-style sockets are openend (S1, S2)
>      S1 is bound to 127.0.0.1, port 1024 [server]
>      S2 is bound to 127.0.0.1, port 1025 [client]
>      listen(2) is invoked on S1
>      From S2 we call one sendmsg(2) with msg.msg_name and
>         msg.msg_namelen parameters set to the server's
>         address
>      S1, S2 are closed
>      goto do
>
> The first pass of this loop passes sucessful, while the second round
> fails during binding of S1 (address still in use). What is happening?
> In the first round, the initial handshake is being done, and, at the
> time close(2) is called on S1, a nongraceful shutdown is performed via
> ABORT since in S1's receive queue an unprocessed packet is present,
> thus stating an error condition. This can be considered as a correct
> behavior.
>
> During close also all bound addresses are freed, thus nothing *must*
> be active anymore.
>
>    After checking the Verification Tag, the receiving endpoint shall
>    remove the association from its record, and shall report the
>    termination to its upper layer. (RFC2960, 9.1 Abort of an Association)
>
> Also, no half-open states are supported, thus after an ungraceful
> shutdown, we leave nothing behind. However, this seems not to be
> happening though. In a real-world scenario, this is exactly where
> it breaks the lksctp-tools functional test suite, *for instance*:
>
>    ./test_sockopt
>    test_sockopt.c  1 PASS : getsockopt(SCTP_STATUS) on a socket with no assoc
>    test_sockopt.c  2 PASS : getsockopt(SCTP_STATUS)
>    test_sockopt.c  3 PASS : getsockopt(SCTP_STATUS) with invalid associd
>    test_sockopt.c  4 PASS : getsockopt(SCTP_STATUS) with NULL associd
>    test_sockopt.c  5 BROK : bind: Address already in use
>
> With this patch, the example above (which simulates a similar scenario
> as in the implementation of this test case) and therefore also this test
> runs successfully through.
>
> If one wants to fix this issue, an RCU barrier needs to be introduced
> within the sctp_close handler. One could argue that this is quite costly,
> which is true, but on the other hand, if an application calls close on
> its socket, it likely might be out of its critical path anyway.

Hi Daniel

The fact that we delay freeing bind_addr list due to rcu shouldn't 
change the endpoint destruction path.

The reason you'd get a EADDRINSUE would be that the 
sctp_endpoint_destroy() hasn't been triggered.  That means that 
something is still referencing the endpoint.  However, there doesn't
appear to be anything holding a reference to the association or the
endpoint from the bind address list.  So the fact that the entries might 
not have been kfreed yet shouldn't impact the binding of new sockets.

What is most likely happening instead is that we now have rcu delayed
transport destruction and in that path, we delay dropping the 
association refcount until after the rcu grace period.  That in turn 
causes delayed endpoint refcount drop, which in turn causes delayed 
removed of the socket from the port list.  This is the cause of the issue.

The right solution would be to see if we can drop the refcounts at 
delete instead of at destroy.  That should remove the delay.

-vlad

>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>   net/sctp/socket.c | 5 +++++
>   1 file changed, 5 insertions(+)
>
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 9e65758..a9c18b4 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -1536,6 +1536,11 @@ SCTP_STATIC void sctp_close(struct sock *sk, long timeout)
>
>   	sock_put(sk);
>
> +	/* There can still be (non-)TCP-style associations be waiting
> +	 * to be processed via deferred RCU.
> +	 */
> +	rcu_barrier();
> +
>   	SCTP_DBG_OBJCNT_DEC(sock);
>   }
>
>
