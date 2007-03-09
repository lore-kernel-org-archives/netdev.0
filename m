From: Norbert Eicker <n.eicker@fz-juelich.de>
Subject: Re: [PATCH] spidernet: Fix problem sending IP fragments
Date: Sat, 10 Mar 2007 00:16:57 +0100
Message-ID: <200703100016.58469.n.eicker@fz-juelich.de>
References: <20070308231556.GE30703@austin.ibm.com>
	<45F19103.3010100@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <45F19103.3010100@pobox.com>
Content-Disposition: inline
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Friday, 9. March 2007 17:53, Jeff Garzik wrote:
> Linas Vepstas wrote:
> > Jeff,
> >
> > Please apply. The rather long patch description is from the submitter,
> > Norbert Eicker, I don't know if that's alright, or if I should ask to
> > have it trimmed.
> >
> > Thanks,
> > --linas
> >
> > From: Norbert Eicker <n.eicker@fz-juelich.de>
> >
> >
> > Signed-off-by: Norbert Eicker <n.eicker@fz-juelich.de>
> > Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
>
> are you sure it can't send out fragmented IP frames?  what's really
> going on here?

Pretty sure that fragmented IP frames are not send out. Here's a small test 
using ttcp and tcpdump reproducing the problem (I assume a MTU of 1500):

You need two node, lets call them src and dest.

On dest run 'tcpdump -nvvv host src'.

Furthermore start on dest: 'ttcp -u -r -s'
and on src: 'ttcp -u -t -s -l 1472 -n 4 dest

tcpdump will show 10 frames received from src, one of size 32 (UDP length 4), 
four of size 1500 (UDP length 1472) (the payload), five more of size 32 (UDP 
length 4). The size 32 frames are some startup/closing frames of ttcp.

Start on dest again: 'ttcp -u -r -s'
and on src: 'ttcp -u -t -s -l 1473 -n 4 dest

Now tcpdump only sees the six startup/closing frames. The payload frames 
(which are fragmented by the IP-stack) disappear somehow.

With the patch applied you see in the second case the startup/closing frames 
plus 4 pairs of frames in between. Each pair consists of one frame of size 
1500 followed by one of size 21 (with an offset of 1480), i.e. the two 
fragments of the too large UDP-datagram.

On src tcpdump will show the fragmented IP-frames in both cases (with and 
without patch applied).

> patch was corrupted anyway, and could not be applied...

Whitespace problem? Let's try again...

Signed-off-by: Norbert Eicker <n.eicker@fz-juelich.de>

diff --git a/drivers/net/spider_net.c b/drivers/net/spider_net.c
index 3b91af8..e3019d5 100644
--- a/drivers/net/spider_net.c
+++ b/drivers/net/spider_net.c
@@ -719,7 +719,7 @@ spider_net_prepare_tx_descr(struct spide
 			SPIDER_NET_DESCR_CARDOWNED | SPIDER_NET_DMAC_NOCS;
 	spin_unlock_irqrestore(&chain->lock, flags);
 
-	if (skb->protocol == htons(ETH_P_IP))
+	if (skb->protocol == htons(ETH_P_IP) && skb->ip_summed == CHECKSUM_PARTIAL)
 		switch (skb->nh.iph->protocol) {
 		case IPPROTO_TCP:
 			hwdescr->dmac_cmd_status |= SPIDER_NET_DMAC_TCP;
 
-- 
Fon ++49-(0)2461/61-1492
http://www.fz-juelich.de
