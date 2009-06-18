From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 2/4] virtio_net: return NETDEV_TX_BUSY instead of queueing an extra skb.
Date: Thu, 18 Jun 2009 16:47:50 +0930
Message-ID: <200906181647.51045.rusty@rustcorp.com.au>
References: <200905292346.04815.rusty@rustcorp.com.au> <200906132200.38034.rusty@rustcorp.com.au> <20090614064528.GA29130@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	David Miller <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:52307 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751597AbZFRHR4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Jun 2009 03:17:56 -0400
In-Reply-To: <20090614064528.GA29130@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 14 Jun 2009 04:15:28 pm Herbert Xu wrote:
> On Sat, Jun 13, 2009 at 10:00:37PM +0930, Rusty Russell wrote:
> > But re your comment that the 67 drivers using TX_BUSY are doing it
> > because of driver bugs, that's hard to believe.  It either hardly ever
> > happens (in which case just drop the packet), or it happens (in which
> > case we should handle it correctly).
>
> Most of them just do this:
>
> start_xmit:
>
> if (unlikely(queue is full)) {
> 	/* This should never happen. */
> 	return TX_BUSY;
> }

OK, so I did a rough audit, trying to figure out the "never happens" ones (N, 
could be kfree_skb(skb); return NETDEV_TX_OK) from the "will actually happen" 
ones (Y).

One question: can netif_queue_stopped() ever be true inside start_xmit?  Some 
drivers test that, like sun3lance.c.

Some have multiple returns, and some are unclear, but my best guess on a 
quickish reading is below.

Summary: we still have about 54 in-tree drivers which actually use 
NETDEV_TX_BUSY for normal paths.  Can I fix it now?

Thanks,
Rusty.

sungem.c: Y, N
fs_enet: N
mace.c: N
sh_eth.c: Y
de620.c: N
acenic.c: N (but goes through stupid hoops to avoid it)
e1000_main.c: N, Y
korina.c: N (Buggy: frees skb and returns TX_BUSY.)
sky2.c: N
cassini.c: N
ixgbe: N
b44.c: N, Y, Y (last two buggy: OOM, does not stop q)
macb.c: N
niu.c: N
smctr.c: N
olympic.c: Y
tms380tr.c: N
3c359.c: Y
lanstreamer.c: Y
lib8390.c: N
xirc2ps_cs.c: Y
smc91c92_cs.c: N
fmvj18x_cs.c: N (and buggy: can't happen AFAICT, and return 0 above?)
axnet_cs.c: N
smsc9420.c: N (and buggy: doesn't stop q)
mkiss.c: N (In xmit, can netif_running be false? Can netif_queue_stopped?)
skge.c: N
qlge: N, N, Y, N (buggy, OOM, does not stop q) 
chelsio: N
s2io.c: Y, Y?
macmace.c: N
3c505.c: Y
defxx.c: Y
myri10ge: N
sbni.c: Y
wanxl.c: N
cycx_x25.c: N, N, Y?
dlci.c: Y
qla3xxx.c: N, N (buggy, OOM, does not stop q), Y, N, 
tlan.c: Y
skfp.c: N
cs89x0.c: N
smc9194.c: N
fec_mpc52xx.c: N
mv643xx_eth.c: N (buggy, OOM, does not stop q)
ll_temac_main.c: Y, Y
netxen: Y
tsi108_eth.c: N, N
ni65.c: N
sunhme.c: N
atl1c.c: Y
ps3_gelic_net.c: Y
igbvf: N
csgb3.c: N
ks8695net.c: N, N (buggy, neither stops q, latter OOM)
ether3.c: N
at91_ether.c: N
bnx2x_main.c: N, N
dm9000.c: N
jme.c: N
3c537.c: Y (plus, leak on skb_padto fail)
arcnet.c: N?
3c59x.c: N
au1000_eth.c: Y
ixgb: N
de600.c: N, N, N
myri_sbus.c: Y
bnx2.c: N
atl1e: Y
sonic.c: who cares, that won't even compile... (missing semicolon)
sun3_82586.c: N
3c515.c: N
ibm_newemac.c: Y
donaubae.c:Y?, Y?, Y?, Y (but never stops q)
sir_dev.c: Y
au1k_ir.c: Y, Y
cpmac.c: N (no stop q, and leak on skb_padto fail), Y
davinci_emac.c: N (no stop q), Y
de2104x.c: N
uli526x.c: N
dmfe.c: N
xircom_cb.c: N
iwmc3200wifi: Y
orinoco: N, N, N, N (no stop q)
atmel.c: Y
p54common.c: N, Y?
arlan-main.c: Y?
libipw_tx.c: Y (no stop q), N (alloc failure)
hostap_80211_tx.c: Y
strip.c: N
wavelan.c: N, N, N
at76c50x-usb.c: N
libertas/tx.c: Y
ray_cs.c: N, N
airo.c: Y, Y, Y
plip.c: N, N, N (starts q, BUSY on too big pkt?)
ns83820.c: N, N
ehea: Y, Y (no stop q)
rionet.c: N
enic: N
sis900.c: N
starfire.c: Y
r6040.c: N
sun3lance.c: N, N
sfc: Y, N, Y
mac89x0.c: N
sb1250-mac.c: Y
pasemi_mac.c: Y
8139cp.c: N
e1000e: N
r8169.c: N?
sis190.c: N
e100.c: N
tg3.c: N, Y?, N
fec.c: N (no stop q), N
hamachi.c: N
forcedeth.c: Y, Y
vxge: Y?, Y?
ks8842.c: Y
spider_net.c: Y
igb: N
ewrk3.c: N
gianfar.c: Y
sunvnet.c: N
mlx4: Y
atlx: Y, Y
