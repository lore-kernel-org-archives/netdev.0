From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net] core: Untag packets after rx_handler has run.
Date: Thu, 4 Sep 2014 21:05:24 +0200
Message-ID: <20140904190524.GA1938@nanopsycho.lan>
References: <1409856043-21840-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Vladislav Yasevich <vyasevic@redhat.com>,
	Florian Zumbiehl <florz@florz.de>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Matthew Rosato <mjrosato@linux.vnet.ibm.com>
To: Vladislav Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:47052 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755110AbaIDTF2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2014 15:05:28 -0400
Received: by mail-wi0-f173.google.com with SMTP id cc10so1703784wib.6
        for <netdev@vger.kernel.org>; Thu, 04 Sep 2014 12:05:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1409856043-21840-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Sep 04, 2014 at 08:40:43PM CEST, vyasevich@gmail.com wrote:
>Currently, we attempt to remove the vlan informaion from the packet
>before passing it to the rx_handler.  In most situations this works
>just fine since the rx_handlers are usually installed for the
>lower device and thus vlan device isn't found.  However, macvtap
>device is a bit different as it installs an rx_handler on top
>of a macvlan device.  As a result, if someone was define a vlan
>device on top of a macvap (for the purposes of enabling a VM
>to use vlans with macvtap), then the current code will result
>in passing an untagged packet to the macvtap rx_handler and the
>VM will not receive tagged traffic.

skb->vlan_tci is set. macvlan should work with that to pass the frame
correctly. This should be handled in macvtap code.

btw can you give me an example of setup where rx_handler is set for
macvlan device? I wonder what is could be.

>
>This patch moves the untaggin code to after the rx_handler for
>the current device has been called.  This still works for the
>existing rx_handlers (like bonding/teaming/bridging/etc) and
>also makes vlans on top of macvtap work as before.
>
>Fixes: 6acf54f1cf (macvtap: Add support of packet capture on macvtap device)
>Reported-by: Matthew Rosato <mjrosato@linux.vnet.ibm.com>
>Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
>---
> net/core/dev.c | 22 +++++++++++-----------
> 1 file changed, 11 insertions(+), 11 deletions(-)
>
>diff --git a/net/core/dev.c b/net/core/dev.c
>index ab9a165..54691d1 100644
>--- a/net/core/dev.c
>+++ b/net/core/dev.c
>@@ -3642,17 +3642,6 @@ ncls:
> 	if (pfmemalloc && !skb_pfmemalloc_protocol(skb))
> 		goto drop;
> 
>-	if (vlan_tx_tag_present(skb)) {
>-		if (pt_prev) {
>-			ret = deliver_skb(skb, pt_prev, orig_dev);
>-			pt_prev = NULL;
>-		}
>-		if (vlan_do_receive(&skb))
>-			goto another_round;
>-		else if (unlikely(!skb))
>-			goto unlock;
>-	}
>-
> 	rx_handler = rcu_dereference(skb->dev->rx_handler);
> 	if (rx_handler) {
> 		if (pt_prev) {
>@@ -3674,6 +3663,17 @@ ncls:
> 		}
> 	}
> 
>+	if (vlan_tx_tag_present(skb)) {
>+		if (pt_prev) {
>+			ret = deliver_skb(skb, pt_prev, orig_dev);
>+			pt_prev = NULL;
>+		}
>+		if (vlan_do_receive(&skb))
>+			goto another_round;
>+		else if (unlikely(!skb))
>+			goto unlock;
>+	}
>+

nack. This will definitelly break several stacked setups.


> 	if (unlikely(vlan_tx_tag_present(skb))) {
> 		if (vlan_tx_tag_get_id(skb))
> 			skb->pkt_type = PACKET_OTHERHOST;
>-- 
>1.9.3
>
