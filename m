From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH net-next-2.6] IFix IPv6 GSO type checks in Intel
 ethernet drivers
Date: Tue, 19 Jan 2010 14:36:17 -0800
Message-ID: <1263940577.1635.29.camel@w-sridhar.beaverton.ibm.com>
References: <1263934927.1635.24.camel@w-sridhar.beaverton.ibm.com>
	 <alpine.WNT.2.00.1001191306450.5776@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	netdev <netdev@vger.kernel.org>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:39500 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754261Ab0ASWgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2010 17:36:35 -0500
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e33.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o0JMXKTv004117
	for <netdev@vger.kernel.org>; Tue, 19 Jan 2010 15:33:20 -0700
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o0JMaIQO069434
	for <netdev@vger.kernel.org>; Tue, 19 Jan 2010 15:36:20 -0700
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o0JMaIBQ029375
	for <netdev@vger.kernel.org>; Tue, 19 Jan 2010 15:36:18 -0700
In-Reply-To: <alpine.WNT.2.00.1001191306450.5776@jbrandeb-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-01-19 at 13:11 -0800, Brandeburg, Jesse wrote:
> 
> On Tue, 19 Jan 2010, Sridhar Samudrala wrote:
> 
> > Found this problem when testing IPv6 from a KVM guest to a remote
> > host via e1000e device on the host.
> > The following patch fixes the check for IPv6 GSO packet in Intel
> > ethernet drivers to use skb_is_gso_v6(). SKB_GSO_DODGY is also set
> > when packets are forwarded from a guest.
> > 
> > Signed-off-by: Sridhar Samudrala <sri@us.ibm.com
> 
> Looks fine, thanks!  The current code in net-next and 2.6.32 both have 
> exactly the same condition in skb_is_gso_v6, so I'm not sure that this 
> patch alone will fix any issues, FYI.  If this patch is part of another 
> set or dependent upon another for the actual change in behavior mentioned 
> in the comment, I think it should be noted or sent in a series.

The bug is in comparing the flag SKB_GSO_TCPV6 directly. I replaced the
compare with the call to skb_is_gso_v6.
This is not a regression and the bug is present even in 2.6.32 and
earlier kernels. So it would be good if this patch can go into 2.6.32
and also -stable kernels.

Thanks
Sridhar

> Ack-ed by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> > 
> > diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
> > index 3d57ca5..2353e95 100644
> > --- a/drivers/net/e1000e/netdev.c
> > +++ b/drivers/net/e1000e/netdev.c
> > @@ -3771,7 +3771,7 @@ static int e1000_tso(struct e1000_adapter *adapter,
> >  		                                         0, IPPROTO_TCP, 0);
> >  		cmd_length = E1000_TXD_CMD_IP;
> >  		ipcse = skb_transport_offset(skb) - 1;
> > -	} else if (skb_shinfo(skb)->gso_type == SKB_GSO_TCPV6) {
> > +	} else if (skb_is_gso_v6(skb)) {
> >  		ipv6_hdr(skb)->payload_len = 0;
> >  		tcp_hdr(skb)->check = ~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
> >  		                                       &ipv6_hdr(skb)->daddr,
> > diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
> > index d967949..d4bbdf0 100644
> > --- a/drivers/net/igb/igb_main.c
> > +++ b/drivers/net/igb/igb_main.c
> > @@ -3422,7 +3422,7 @@ static inline int igb_tso_adv(struct igb_ring *tx_ring,
> >  							 iph->daddr, 0,
> >  							 IPPROTO_TCP,
> >  							 0);
> > -	} else if (skb_shinfo(skb)->gso_type == SKB_GSO_TCPV6) {
> > +	} else if (skb_is_gso_v6(skb)) {
> >  		ipv6_hdr(skb)->payload_len = 0;
> >  		tcp_hdr(skb)->check = ~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
> >  						       &ipv6_hdr(skb)->daddr,
> > diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
> > index a6c3920..ce33671 100644
> > --- a/drivers/net/igbvf/netdev.c
> > +++ b/drivers/net/igbvf/netdev.c
> > @@ -1963,7 +1963,7 @@ static int igbvf_tso(struct igbvf_adapter *adapter,
> >  		                                         iph->daddr, 0,
> >  		                                         IPPROTO_TCP,
> >  		                                         0);
> > -	} else if (skb_shinfo(skb)->gso_type == SKB_GSO_TCPV6) {
> > +	} else if (skb_is_gso_v6(skb)) {
> >  		ipv6_hdr(skb)->payload_len = 0;
> >  		tcp_hdr(skb)->check = ~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
> >  		                                       &ipv6_hdr(skb)->daddr,
> > diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
> > index 81971ed..b2c0025 100644
> > --- a/drivers/net/ixgbe/ixgbe_main.c
> > +++ b/drivers/net/ixgbe/ixgbe_main.c
> > @@ -5113,7 +5113,7 @@ static int ixgbe_tso(struct ixgbe_adapter *adapter,
> >  			                                         iph->daddr, 0,
> >  			                                         IPPROTO_TCP,
> >  			                                         0);
> > -		} else if (skb_shinfo(skb)->gso_type == SKB_GSO_TCPV6) {
> > +		} else if (skb_is_gso_v6(skb)) {
> >  			ipv6_hdr(skb)->payload_len = 0;
> >  			tcp_hdr(skb)->check =
> >  			    ~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
> > diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
> > index 39544af..652b6f4 100644
> > --- a/drivers/net/ixgbevf/ixgbevf_main.c
> > +++ b/drivers/net/ixgbevf/ixgbevf_main.c
> > @@ -2756,7 +2756,7 @@ static int ixgbevf_tso(struct ixgbevf_adapter *adapter,
> >  								 IPPROTO_TCP,
> >  								 0);
> >  			adapter->hw_tso_ctxt++;
> > -		} else if (skb_shinfo(skb)->gso_type == SKB_GSO_TCPV6) {
> > +		} else if (skb_is_gso_v6(skb)) {
> >  			ipv6_hdr(skb)->payload_len = 0;
> >  			tcp_hdr(skb)->check =
> >  			    ~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
> > 
> > 
> > 

