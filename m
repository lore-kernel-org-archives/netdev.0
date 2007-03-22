From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [ANN] Unified dynamic storage for different socket types instead of separate hash tables.
Date: Thu, 22 Mar 2007 22:09:40 +0300
Message-ID: <20070322190939.GA18792@2ka.mipt.ru>
References: <20070322180957.GA17793@2ka.mipt.ru> <20070322114304.1e516507@freekitty> <20070322185944.GA3802@2ka.mipt.ru> <20070322.120346.41643926.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:35129 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965238AbXCVTJ6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Mar 2007 15:09:58 -0400
Content-Disposition: inline
In-Reply-To: <20070322.120346.41643926.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 22, 2007 at 12:03:46PM -0700, David Miller (davem@davemloft.net) wrote:
> From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> Date: Thu, 22 Mar 2007 21:59:44 +0300
> 
> > Yes, current code does not support statistics.
> > Existing stats run over whole hash table, I do not like such approach,
> > so I will introduce a per-protocol lists of all sockets, which can be
> > accessed from statistics code, but it is next step.
> 
> We are _NOT_ bloating up the socket structure even more because your
> data structure does not support a "iterate over all objects"
> operation.
> 
> We got rid of the linked list of all sockets per-protocol precisely
> for this reason 10 years ago, you cannot add it back, sorry.

Hmm...
My patch _removes_ them from socket structures!

--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -114,10 +114,12 @@ struct sock_common {
 	volatile unsigned char	skc_state;
 	unsigned char		skc_reuse;
 	int			skc_bound_dev_if;
-	struct hlist_node	skc_node;
 	struct hlist_node	skc_bind_node;
 	atomic_t		skc_refcnt;
+#ifndef CONFIG_MDT_LOOKUP
+	struct hlist_node	skc_node;
 	unsigned int		skc_hash;
+#endif
 	struct proto		*skc_prot;
 };

I specially have only one hash structure in the socket - skc_bind_node -
to be used for statistics and remove hash and skc_node (and for netlink
broadcasting too), so this code reduces socket structure by 12 bytes on
x86 (20 bytes on x86_64).

-- 
	Evgeniy Polyakov
