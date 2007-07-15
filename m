From: Bryan Wu <bryan.wu@analog.com>
Subject: Re: [PATCH try#2] Blackfin ethernet driver: on chip ethernet MAC
	controller driver
Date: Sun, 15 Jul 2007 22:01:04 +0800
Message-ID: <1184508064.6030.6.camel@roc-laptop>
References: <1184491629.3140.59.camel@roc-laptop>
	 <200707151236.51779.mb@bu3sch.de> <1184501264.3140.71.camel@roc-laptop>
	 <200707151417.10964.mb@bu3sch.de>
Reply-To: bryan.wu@analog.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: bryan.wu@analog.com, Mike Frysinger <vapier.adi@gmail.com>,
	Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail11.analog.com ([137.71.25.57]:39176 "EHLO
	nwd2mail11.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753076AbXGOOB3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jul 2007 10:01:29 -0400
In-Reply-To: <200707151417.10964.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2007-07-15 at 14:17 +0200, Michael Buesch wrote:
> On Sunday 15 July 2007 14:07:44 Bryan Wu wrote:
> > @@ -483,9 +487,12 @@
> >  
> >  void setup_mac_addr(u8 * mac_addr)
> >  {
> > +	u32 addr_low = le32_to_cpu(*(u32 *) & mac_addr[0]);
> > +	u16 addr_hi = le16_to_cpu(*(u16 *) & mac_addr[4]);
> > +
> >  	/* this depends on a little-endian machine */
> > -	bfin_write_EMAC_ADDRLO(*(u32 *) & mac_addr[0]);
> > -	bfin_write_EMAC_ADDRHI(*(u16 *) & mac_addr[4]);
> > +	bfin_write_EMAC_ADDRLO(addr_low);
> > +	bfin_write_EMAC_ADDRHI(addr_hi);
> >  }
> >  
> >  static void adjust_tx_list(void)
> > @@ -866,10 +873,10 @@
> >  	int retval;
> >  
> >  	/* Grab the MAC address in the MAC */
> > -	*(u32 *) (&(dev->dev_addr[0])) = bfin_read_EMAC_ADDRLO();
> > -	*(u16 *) (&(dev->dev_addr[4])) = (u16) bfin_read_EMAC_ADDRHI();
> > +	*(u32 *) (&(dev->dev_addr[0])) = cpu_to_le32(bfin_read_EMAC_ADDRLO());
> > +	*(u16 *) (&(dev->dev_addr[4])) = cpu_to_le16((u16) bfin_read_EMAC_ADDRHI());
> 
> Try something like this:
> 
> @@ -483,9 +487,12 @@
>  
>  void setup_mac_addr(u8 * mac_addr)
>  {
> +       u32 addr_low = le32_to_cpu(*(__le32 *) & mac_addr[0]);
> +       u16 addr_hi = le16_to_cpu(*(__le16 *) & mac_addr[4]);
> +
> -       /* this depends on a little-endian machine */
> -       bfin_write_EMAC_ADDRLO(*(u32 *) & mac_addr[0]);
> -       bfin_write_EMAC_ADDRHI(*(u16 *) & mac_addr[4]);
> +       bfin_write_EMAC_ADDRLO(addr_low);
> +       bfin_write_EMAC_ADDRHI(addr_hi);
>  }
>  
>  static void adjust_tx_list(void)
> @@ -866,10 +873,10 @@
>         int retval;
>  
>         /* Grab the MAC address in the MAC */
> -       *(u32 *) (&(dev->dev_addr[0])) = bfin_read_EMAC_ADDRLO();
> -       *(u16 *) (&(dev->dev_addr[4])) = (u16) bfin_read_EMAC_ADDRHI();
> +       *(__le32 *) (&(dev->dev_addr[0])) = cpu_to_le32(bfin_read_EMAC_ADDRLO());
> +       *(__le16 *) (&(dev->dev_addr[4])) = cpu_to_le16((u16) bfin_read_EMAC_ADDRHI());
> 

Thanks a lot, Michael. 

I got a generic question about this endianess check. When should use it
in a driver or something else? I grep it in the driver/net/

---
drivers/net/e100.c:             ns->tx_window_errors += le32_to_cpu(s->tx_late_collisions);
drivers/net/e100.c:             ns->tx_carrier_errors += le32_to_cpu(s->tx_lost_crs);
drivers/net/e100.c:             ns->tx_fifo_errors += le32_to_cpu(s->tx_underruns);
drivers/net/e100.c:             ns->tx_errors += le32_to_cpu(s->tx_max_collisions) +
drivers/net/e100.c:                     le32_to_cpu(s->tx_lost_crs);
drivers/net/e100.c:             ns->rx_length_errors += le32_to_cpu(s->rx_short_frame_errors) +
drivers/net/e100.c:             ns->rx_crc_errors += le32_to_cpu(s->rx_crc_errors);
drivers/net/e100.c:             ns->rx_frame_errors += le32_to_cpu(s->rx_alignment_errors);
drivers/net/e100.c:             ns->rx_over_errors += le32_to_cpu(s->rx_overrun_errors);
drivers/net/e100.c:             ns->rx_fifo_errors += le32_to_cpu(s->rx_overrun_errors);
drivers/net/e100.c:             ns->rx_missed_errors += le32_to_cpu(s->rx_resource_errors);
drivers/net/e100.c:             ns->rx_errors += le32_to_cpu(s->rx_crc_errors) +
drivers/net/e100.c:                     le32_to_cpu(s->rx_alignment_errors) +
drivers/net/e100.c:                     le32_to_cpu(s->rx_short_frame_errors) +
drivers/net/e100.c:                     le32_to_cpu(s->rx_cdt_errors);
drivers/net/e100.c:             nic->tx_deferred += le32_to_cpu(s->tx_deferred);
drivers/net/e100.c:                     le32_to_cpu(s->tx_single_collisions);
drivers/net/e100.c:                     le32_to_cpu(s->tx_multiple_collisions);
drivers/net/e100.c:                     nic->tx_fc_pause += le32_to_cpu(s->fc_xmt_pause);
drivers/net/e100.c:                     nic->rx_fc_pause += le32_to_cpu(s->fc_rcv_pause);
drivers/net/e100.c:                             le32_to_cpu(s->fc_rcv_unsupported);
drivers/net/e100.c:                             le32_to_cpu(cb->u.tcb.tbd.buf_addr),
drivers/net/e100.c:                                     le32_to_cpu(cb->u.tcb.tbd.buf_addr),
---

Normally, it is used to protect some rx/tx status flags or dma buf addr.

Any guide line for this leXX_to_cpu usage?

Thanks again

- Bryan Wu
