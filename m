From: Flavio Leitner <fleitner@redhat.com>
Subject: Re: [PATCH] [NET]: fix multicast list when cloning sockets
Date: Tue, 31 Jul 2007 15:29:40 -0300
Message-ID: <20070731182940.GE4002@redhat.com>
References: <20070730160448.GA4002@redhat.com> <20070730.190144.26963470.davem@davemloft.net> <39e6f6c70707302000l52926c9ar927fd550467ce3e3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, dlstevens@us.ibm.com,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:42059 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763375AbXGaScl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jul 2007 14:32:41 -0400
Content-Disposition: inline
In-Reply-To: <39e6f6c70707302000l52926c9ar927fd550467ce3e3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 31, 2007 at 12:00:41AM -0300, Arnaldo Carvalho de Melo wrote:
> On 7/30/07, David Miller <davem@davemloft.net> wrote:
> > Allowing non-datagram sockets to end up with a non-NULL inet->mc_list
> > in the first place is a bug.
> >
> > Multicast subscriptions cannot even be used with TCP and DCCP, which
> > are the only two users of these connection oriented socket functions.
> >
> > The first thing that TCP and DCCP do, in fact, for input packet
> > processing is drop the packet if it is not unicast.
> >
> > Therefore the fix really is for the inet layer to reject multicast
> > subscription requests on sockets for which that absolutely does not
> > make sense.  There is no reason these functions in
> > inet_connection_sock.c should need to be mindful of multicast
> > state. :-)
> 
> Well, we can add a BUG_ON there then 8)
> 
> Flavio, take a look at  do_ip_setsockopt in net/ipv4/ip_sockglue.c, in
> the IP_{ADD,DROP}_MEMBERSHIP labels.
> 
> Don't forget IPV6 (net/ipv6/ipv6_sockglue.c)

yes, right. What about the one below?

[NET]: Fix IP_ADD/DROP_MEMBERSHIP to handle only connectionless

Fix IP[V6]_ADD_MEMBERSHIP and IP[V6]_DROP_MEMBERSHIP to
return -EPROTO for connection oriented sockets.

Signed-off-by: Flavio Leitner <fleitner@redhat.com>

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 4d54457..6b420ae 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -625,6 +625,10 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 	{
 		struct ip_mreqn mreq;
 
+		err = -EPROTO;
+		if (inet_sk(sk)->is_icsk)
+			break;
+
 		if (optlen < sizeof(struct ip_mreq))
 			goto e_inval;
 		err = -EFAULT;
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index d684639..350e584 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -554,6 +554,10 @@ done:
 	{
 		struct ipv6_mreq mreq;
 
+		retv = -EPROTO;
+		if (inet_sk(sk)->is_icsk)
+			break;
+
 		retv = -EFAULT;
 		if (copy_from_user(&mreq, optval, sizeof(struct ipv6_mreq)))
 			break;
-- 
1.5.2.4

-- 
Flavio
