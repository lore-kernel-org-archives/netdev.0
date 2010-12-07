From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [PATCH 2.6.36 stable] vlan: Avoid hwaccel vlan
 packets when vid not used.
Date: Tue, 7 Dec 2010 13:03:12 -0800
Message-ID: <20101207210312.GA14729@kroah.com>
References: <1289251381-6671-1-git-send-email-jesse@nicira.com>
 <20101207195019.GP13189@kroah.com>
 <1291755026.5324.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="VS++wcV0S1rZb1Fb"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Jesse Gross <jesse@nicira.com>,
	stable@kernel.org, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:48468 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754665Ab0LGVDf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Dec 2010 16:03:35 -0500
Content-Disposition: inline
In-Reply-To: <1291755026.5324.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--VS++wcV0S1rZb1Fb
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

On Tue, Dec 07, 2010 at 09:50:26PM +0100, Eric Dumazet wrote:
> Le mardi 07 décembre 2010 à 11:50 -0800, Greg KH a écrit :
> > On Mon, Nov 08, 2010 at 01:23:01PM -0800, Jesse Gross wrote:
> > > Normally hardware accelerated vlan packets are quickly dropped if
> > > there is no corresponding vlan device configured.  The one exception
> > > is promiscuous mode, where we allow all of these packets through so
> > > they can be picked up by tcpdump.  However, this behavior causes a
> > > crash if we actually try to receive these packets.  This fixes that
> > > crash by ignoring packets with vids not corresponding to a configured
> > > device in the vlan hwaccel routines and then dropping them before they
> > > get to consumers in the network stack.
> > > 
> > > This patch applies only to 2.6.36 stable.  The problem was introduced
> > > in that release and is already fixed by larger changes to the vlan
> > > code in 2.6.37.
> > 
> > Applied, thanks.
> > 
> 
> Oh well, which version ?
> 
> A new version of the patch was submitted 6 days ago .
> 
> http://patchwork.ozlabs.org/patch/73791/

I applied the one below.

If that is incorrect, please send me the correct one.

thanks,

greg k-h

--VS++wcV0S1rZb1Fb
Content-Type: text/x-patch; charset=us-ascii
Content-Disposition: attachment; filename="vlan-avoid-hwaccel-vlan-packets-when-vid-not-used.patch"

>From jesse@nicira.com  Tue Dec  7 11:49:39 2010
From: Jesse Gross <jesse@nicira.com>
Date: Mon,  8 Nov 2010 13:23:01 -0800
Subject: [stable] [PATCH 2.6.36 stable] vlan: Avoid hwaccel vlan packets when vid not used.
To: stable@kernel.org
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Message-ID: <1289251381-6671-1-git-send-email-jesse@nicira.com>

From: Jesse Gross <jesse@nicira.com>

[This patch applies only to 2.6.36 stable.  The problem was introduced
in that release and is already fixed by larger changes to the vlan
code in 2.6.37.]

Normally hardware accelerated vlan packets are quickly dropped if
there is no corresponding vlan device configured.  The one exception
is promiscuous mode, where we allow all of these packets through so
they can be picked up by tcpdump.  However, this behavior causes a
crash if we actually try to receive these packets.  This fixes that
crash by ignoring packets with vids not corresponding to a configured
device in the vlan hwaccel routines and then dropping them before they
get to consumers in the network stack.


Reported-by: Ben Greear <greearb@candelatech.com>
Tested-by: Nikola Ciprich <extmaillist@linuxbox.cz>
Signed-off-by: Jesse Gross <jesse@nicira.com>
Acked-by: David Miller <davem@davemloft.net>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 net/8021q/vlan_core.c |    3 +++
 net/core/dev.c        |   13 +++++++++++++
 2 files changed, 16 insertions(+)

--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -43,6 +43,9 @@ int vlan_hwaccel_do_receive(struct sk_bu
 	struct net_device *dev = skb->dev;
 	struct vlan_rx_stats     *rx_stats;
 
+	if (unlikely(!is_vlan_dev(dev)))
+		return 0;
+
 	skb->dev = vlan_dev_info(dev)->real_dev;
 	netif_nit_deliver(skb);
 
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2891,6 +2891,19 @@ static int __netif_receive_skb(struct sk
 ncls:
 #endif
 
+	/* If we got this far with a hardware accelerated VLAN tag, it means
+	 * that we were put in promiscuous mode but nobody is interested in
+	 * this vid.  Drop the packet now to prevent it from getting propagated
+	 * to other parts of the stack that won't know how to deal with packets
+	 * tagged in this manner.
+	 */
+	if (unlikely(vlan_tx_tag_present(skb))) {
+		if (pt_prev)
+			ret = pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
+		kfree_skb(skb);
+		goto out;
+	}
+
 	/* Handle special case of bridge or macvlan */
 	rx_handler = rcu_dereference(skb->dev->rx_handler);
 	if (rx_handler) {

--VS++wcV0S1rZb1Fb--
