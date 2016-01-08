From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: WARN trace - skb_warn_bad_offload - vxlan - large udp packet -
 udp checksum disabled
Date: Fri, 8 Jan 2016 20:14:58 +0100
Message-ID: <20160108191458.GA7266@unicorn.suse.cz>
References: <FC41C24E35F18A40888AACA1A36F3E418AFD00B5@fmsmsx115.amr.corp.intel.com>
 <568DCF2B.2090502@stressinduktion.org>
 <20160107064640.GA27753@unicorn.suse.cz>
 <20160107072742.GC27753@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Tom Herbert <tom@herbertland.com>,
	Jesse Gross <jesse@nicira.com>, Jiri Benc <jbenc@redhat.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: "Nelson, Shannon" <shannon.nelson@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:33083 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751213AbcAHTPC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jan 2016 14:15:02 -0500
Content-Disposition: inline
In-Reply-To: <20160107072742.GC27753@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 07, 2016 at 08:27:42AM +0100, Michal Kubecek wrote:
> On Thu, Jan 07, 2016 at 07:46:40AM +0100, Michal Kubecek wrote:
> > On Thu, Jan 07, 2016 at 03:36:27AM +0100, Hannes Frederic Sowa wrote:
> > > On 15.12.2015 02:35, Nelson, Shannon wrote:
> > > >Using a slightly modified version of udpspam (see diff below -
> > > >hopefully not mangled by corporate email servers), where I set the
> > > >SO_NO_CHECK socket option and can specify a large buffer size, I can
> > > >reliably get the following WARN trace.  I have reproduced this on
> > > >both ixgbe and i40e drivers using "udpspam-no-check <target-ip>
> > > >6000".
> > > >
> > > >It looks to me like this is in the Tx path before we get to the
> > > >actual NIC drivers, but I may be wrong.
> > > 
> > > Does UFO offloading on the tunnel interface fix this error?
> > > 
> > > ethtool -K vxlan ufo off
> > > 
> > > If yes we can't feed SO_NO_CHECK udp packets into UFO as gso/ufo
> > > requires CHECKSUM_PARTIAL (or add some more logic into the skb or
> > > query socket status from skb_gso_segment).
> > 
> > I believe you are right. This sounds like the issue addressed by commit
> > acf8dd0a9d0b ("udp: only allow UFO for packets from SOCK_DGRAM sockets")
> > except for a regular SOCK_DGRAM socket with SO_NO_CHECK option. If so,
> > changing both instances of the check
> > 
> > 	    (sk->sk_type == SOCK_DGRAM)
> > 
> > added by this commit to
> > 
> > 	    (sk->sk_type == SOCK_DGRAM) && !sk->sk_no_check_tx
> > 
> > should fix the problem (and it should be done even if the issue reported
> > here is caused by something else).
> 
> Correction: the IPv6 case will need "!udp_get_no_check6_tx(sk)" instead.

Shannon, if disabling UFO works around the problem, please check if this
patch helps:


From: Michal Kubecek <mkubecek@suse.cz>
Date: Fri, 8 Jan 2016 18:23:40 +0100
Subject: [PATCH] udp: disallow UFO for sockets with SO_NO_CHECK option

Commit acf8dd0a9d0b ("udp: only allow UFO for packets from SOCK_DGRAM
sockets") disallows UFO for packets sent from raw sockets. We need to do
the same also for SOCK_DGRAM sockets with SO_NO_CHECK option, even if
for a bit different reason: while such socket would override the
CHECKSUM_PARTIAL set by ip_ufo_append_data(), gso_size is still set and
bad offloading flags warning is triggered in __skb_gso_segment().

In the IPv6 case, SO_NO_CHECK option is ignored but we need to disallow
UFO for packets sent by sockets with UDP_NO_CHECK6_TX option.

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 net/ipv4/ip_output.c  | 2 +-
 net/ipv6/ip6_output.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 4233cbe47052..36ac9f3a6451 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -921,7 +921,7 @@ static int __ip_append_data(struct sock *sk,
 	if (((length > mtu) || (skb && skb_is_gso(skb))) &&
 	    (sk->sk_protocol == IPPROTO_UDP) &&
 	    (rt->dst.dev->features & NETIF_F_UFO) && !rt->dst.header_len &&
-	    (sk->sk_type == SOCK_DGRAM)) {
+	    (sk->sk_type == SOCK_DGRAM) && !sk->sk_no_check_tx) {
 		err = ip_ufo_append_data(sk, queue, getfrag, from, length,
 					 hh_len, fragheaderlen, transhdrlen,
 					 maxfraglen, flags);
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index e6a7bd15b9b7..6473889f1736 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1353,7 +1353,7 @@ emsgsize:
 	     (skb && skb_is_gso(skb))) &&
 	    (sk->sk_protocol == IPPROTO_UDP) &&
 	    (rt->dst.dev->features & NETIF_F_UFO) &&
-	    (sk->sk_type == SOCK_DGRAM)) {
+	    (sk->sk_type == SOCK_DGRAM) && !udp_get_no_check6_tx(sk)) {
 		err = ip6_ufo_append_data(sk, queue, getfrag, from, length,
 					  hh_len, fragheaderlen,
 					  transhdrlen, mtu, flags, fl6);
-- 
2.7.0
