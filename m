From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [BUG] bd4265fe36 bridge: Only flood unreg groups... breaks DHCP
 setup
Date: Tue, 5 Jul 2011 22:35:51 -0700
Message-ID: <20110705223551.5e1053af@nehalam.ftrdhcpuser.net>
References: <20110705204200@it-loops.com>
	<20110705235833.GA5599@gondor.apana.org.au>
	<20110705.184044.1261486363010308552.davem@davemloft.net>
	<20110705220636.6afeb81c@nehalam.ftrdhcpuser.net>
	<20110706050848.GA7564@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, mike@it-loops.com,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42608 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752444Ab1GFFfx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jul 2011 01:35:53 -0400
In-Reply-To: <20110706050848.GA7564@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 6 Jul 2011 13:08:48 +0800
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Tue, Jul 05, 2011 at 10:06:36PM -0700, Stephen Hemminger wrote:
> > On Tue, 05 Jul 2011 18:40:44 -0700 (PDT)
> > David Miller <davem@davemloft.net> wrote:
> > 
> > > From: Herbert Xu <herbert@gondor.hengli.com.au>
> > > Date: Wed, 6 Jul 2011 07:58:33 +0800
> > > 
> > > > bridge: Always flood broadcast packets
> > > > 
> > > > As is_multicast_ether_addr returns true on broadcast packets as
> > > > well, we need to explicitly exclude broadcast packets so that
> > > > they're always flooded.  This wasn't an issue before as broadcast
> > > > packets were considered to be an unregistered multicast group,
> > > > which were always flooded.  However, as we now only flood such
> > > > packets to router ports, this is no longer acceptable.
> > > > 
> > > > Reported-by: Michael Guntsche <mike@it-loops.com>
> > > > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> > > 
> > > Applied.
> > 
> > Obviously needs to go to stable as well.
> 
> I don't think the buggy patch has made it to a release kernel
> yet.
> 
> Thanks,

The bisected commit bd4265fe36 is in 3.0-rc4 but the input code
path still treats multicast and broadcast the same which means
there are some other possible cases where broadcast doesn't get
forwarded.

Wouldn't it make more sense to force input path to always forward
broadcasts. It would also save a lookup of mdb entry.

--- a/net/bridge/br_input.c	2011-07-05 22:28:30.111995701 -0700
+++ b/net/bridge/br_input.c	2011-07-05 22:34:08.259995671 -0700
@@ -77,7 +77,9 @@ int br_handle_frame_finish(struct sk_buf
 
 	dst = NULL;
 
-	if (is_multicast_ether_addr(dest)) {
+	if (is_broadcast_ether_addr(dest))
+		skb2 = skb;
+	else if (is_multicast_ether_addr(dest)) {
 		mdst = br_mdb_get(br, skb);
 		if (mdst || BR_INPUT_SKB_CB_MROUTERS_ONLY(skb)) {
 			if ((mdst && mdst->mglist) ||

