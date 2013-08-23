From: Chris Clark <chris.clark@alcatel-lucent.com>
Subject: sendto() bug?
Date: Fri, 23 Aug 2013 13:19:48 -0600 (MDT)
Message-ID: <alpine.DEB.2.02.1308231257140.10771@optio.utah.ind.alcatel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postal2.ind.alcatel.com ([198.206.184.238]:33562 "EHLO
	ind.alcatel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754093Ab3HWTvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 15:51:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

I've run across a problem with the sendto() system call that first
appeared with commit f8126f1d:

=================================================================
commit f8126f1d5136be1ca1a3536d43ad7a710b5620f8
Author: David S. Miller <davem@davemloft.net>
Date:   Fri Jul 13 05:03:45 2012 -0700

    ipv4: Adjust semantics of rt->rt_gateway.
=================================================================

The issue arises when sendto() is used on a SOCK_RAW IP socket opened
with the IP_HDRINCL option.  Instead of sending the packet to the
address given explicitly in the sendto() call, the kernel ignores the
given dest_addr and ARPs locally for the destination address given in
the constructed packet's IP header.  Because the IP header's
destination address is not on a local subnet, the bogus ARP never
resolves and the packet is never sent.

A subsequent commit addressed a similar problem in netfilter:

=================================================================
commit 2ad5b9e4bd314fc685086b99e90e5de3bc59e26b
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Tue Oct 16 22:33:29 2012 +0000

    netfilter: xt_TEE: don't use destination address found in header

    Torsten Luettgert bisected TEE regression starting with commit
    f8126f1d5136be1 (ipv4: Adjust semantics of rt->rt_gateway.)

    The problem is that it tries to ARP-lookup the original destination
    address of the forwarded packet, not the address of the gateway.

    Fix this using FLOWI_FLAG_KNOWN_NH Julian added in commit
    c92b96553a80c1 (ipv4: Add FLOWI_FLAG_KNOWN_NH), so that known
    nexthop (info->gw.ip) has preference on resolving.
=================================================================

In the same vein as 2ad5b9e4, I'm soliciting feedback on something
similar for raw_sendmsg():

=================================================================
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index dd44e0a..454d9c1 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -571,7 +571,9 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
        flowi4_init_output(&fl4, ipc.oif, sk->sk_mark, tos,
                           RT_SCOPE_UNIVERSE,
                           inet->hdrincl ? IPPROTO_RAW : sk->sk_protocol,
-                          inet_sk_flowi_flags(sk) | FLOWI_FLAG_CAN_SLEEP,
+                          inet_sk_flowi_flags(sk) | FLOWI_FLAG_CAN_SLEEP
+                           | ((msg->msg_namelen
+                               && (tos & RTO_ONLINK)) ? FLOWI_FLAG_KNOWN_NH : 0),
                           daddr, saddr, 0, 0);

        if (!inet->hdrincl) {
=================================================================

The thought here is to apply the FLOWI_FLAG_KNOWN_NH flag when:
 (a) The dest_addr is given explicitly (msg->msg_namelen), and
 (b) The socket is in MSG_DONTROUTE mode (tos & RTO_ONLINK).

This change fixes the problem because the FLOWI_FLAG_KNOWN_NH flag
ends up (very indirectly) triggering the following code in
rt_set_nexthop() which sets rt->rt_gateway to the address specified in
the sendto() call, which ultimately causes the packet to be forwarded
to that address rather than wrongly ARPing locally for the (different,
remote) address in the IP header:

=================================================================
        if (unlikely(!cached)) {
            /* Routes we intend to cache in nexthop exception or
             * FIB nexthop have the DST_NOCACHE bit clear.
             * However, if we are unsuccessful at storing this
             * route into the cache we really need to set it.
             */
            rt->dst.flags |= DST_NOCACHE;
            if (!rt->rt_gateway)
->              rt->rt_gateway = daddr;

=================================================================

While the diff resolves the particular problem that I encountered, I'm
soliciting feedback because I'm not sure it is necessary and
sufficient beyond my particular test case.

Thanks,
Chris
