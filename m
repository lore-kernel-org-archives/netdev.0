From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [BNX2X RESUBMIT][PATCH 0/8] New driver for Broadcom 10Gb
 Ethernet, take two.
Date: Mon, 8 Oct 2007 12:08:55 -0700
Message-ID: <20071008120855.758d10e7@freepuppy.rosehill>
References: <470A23E5.6030102@broadcom.com>
	<20071008102919.1cbc7983@freepuppy.rosehill>
	<1191868481.29746.27.camel@eliezer>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"jeff@garzik.org" <jeff@garzik.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Michael Chan" <mchan@broadcom.com>, eilong@broadcom.com,
	vladz@broadcom.com, gertner@broadcom.com
To: "Eliezer" <eliezert@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:37351 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754616AbXJHTJ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 15:09:27 -0400
In-Reply-To: <1191868481.29746.27.camel@eliezer>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 08 Oct 2007 20:34:41 +0200
"Eliezer" <eliezert@broadcom.com> wrote:

> On Mon, 2007-10-08 at 10:29 -0700, Stephen Hemminger wrote:
> 
> > 
> > Looks good.  Some minor stuff:
> > * You can use network device stats in network device structure and
> >   no longer need the copy in bp
> 
> We can't use net device stats in the bp because the elements are also
> used by HW and we can't rearrange them. 
> struct bmac_stats and struct emac_stats are written to by the HW 
> struct nig_stats and struct bnx2x_eth_stats are read by HW
> (I would have loved to get rid of at least one of these long structs.)

Here:
static void bnx2x_update_net_stats(struct bnx2x *bp)
+{
+	struct bnx2x_eth_stats *estats = bnx2x_sp(bp, eth_stats);
+
+	bp->net_stats.rx_packets =
+		bnx2x_hilo(&estats->total_unicast_packets_received_hi) +
+		bnx2x_hilo(&estats->total_multicast_packets_received_hi) +
+		bnx2x_hilo(&estats->total_broadcast_packets_received_hi);
+
+	bp->net_stats.tx_packets =
+		bnx2x_hilo(&estats->total_unicast_packets_transmitted_hi) +
+		bnx2x_hilo(&estats->total_multicast_packets_transmitted_hi) +
+		bnx2x_hilo(&estats->total_broadcast_packets_transmitted_hi);
+
+	bp->net_stats.rx_bytes = bnx2x_hilo(&estats->total_bytes_received_hi);
+
+	bp->net_stats.tx_bytes =
+		bnx2x_hilo(&estats->total_bytes_transmitted_hi);
+
+	bp->net_stats.rx_dropped = estats->no_buff_discard;
+	bp->net_stats.tx_dropped = 0;

bp->net_stats could be replaced by dev->net_stats


> > * The MACRO's for 64 bit stats look like they could be done with 
> >   u64 and/or turned into inline's.
> 
> The MACRO's modify some of their arguments, plus they need to work on 32
> bit machines (are 64 bit counters always available on 32 bit machines?).
> so using an inline would allow the inline to be more readable but
> calling it would get ugly.
> I'm open to suggestions.
> 

u64 exists on all platforms (including 32 bit).

> > * RCS/CVS tags for date and version # are kind of ugly. They git system
> >   doesn't use them, perhaps you just want to track your internal version
> >   control information, but what happens when changes come from outside?
> 
> We need some way to correlate cvs to opensource to bug tracking tool.
> Note that driver and Microcode code are very tightly coupled on this
> device, so if I want to debug a microcode related problem I would need
> both CVS version and microcode version.
> 
> I agree that tags are ugly but can't think of a better way to do it.
> Changes coming from the outside are a problem, but using the cvs version
> as an anchor I can track them using git.
> Again, I'm open to suggestions and if someone can think of an elegant
> way of doing it, I will gladly use it.
> 

Leave them for now, but be careful about relying too strongly on
the version having any real meaning.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
