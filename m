From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH try#2] Blackfin ethernet driver: on chip ethernet MAC controller driver
Date: Sun, 15 Jul 2007 14:17:10 +0200
Message-ID: <200707151417.10964.mb@bu3sch.de>
References: <1184491629.3140.59.camel@roc-laptop> <200707151236.51779.mb@bu3sch.de> <1184501264.3140.71.camel@roc-laptop>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Mike Frysinger <vapier.adi@gmail.com>,
	Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: bryan.wu@analog.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:41246
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754451AbXGOMUa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jul 2007 08:20:30 -0400
In-Reply-To: <1184501264.3140.71.camel@roc-laptop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 15 July 2007 14:07:44 Bryan Wu wrote:
> @@ -483,9 +487,12 @@
>  
>  void setup_mac_addr(u8 * mac_addr)
>  {
> +	u32 addr_low = le32_to_cpu(*(u32 *) & mac_addr[0]);
> +	u16 addr_hi = le16_to_cpu(*(u16 *) & mac_addr[4]);
> +
>  	/* this depends on a little-endian machine */
> -	bfin_write_EMAC_ADDRLO(*(u32 *) & mac_addr[0]);
> -	bfin_write_EMAC_ADDRHI(*(u16 *) & mac_addr[4]);
> +	bfin_write_EMAC_ADDRLO(addr_low);
> +	bfin_write_EMAC_ADDRHI(addr_hi);
>  }
>  
>  static void adjust_tx_list(void)
> @@ -866,10 +873,10 @@
>  	int retval;
>  
>  	/* Grab the MAC address in the MAC */
> -	*(u32 *) (&(dev->dev_addr[0])) = bfin_read_EMAC_ADDRLO();
> -	*(u16 *) (&(dev->dev_addr[4])) = (u16) bfin_read_EMAC_ADDRHI();
> +	*(u32 *) (&(dev->dev_addr[0])) = cpu_to_le32(bfin_read_EMAC_ADDRLO());
> +	*(u16 *) (&(dev->dev_addr[4])) = cpu_to_le16((u16) bfin_read_EMAC_ADDRHI());

Try something like this:

@@ -483,9 +487,12 @@
 
 void setup_mac_addr(u8 * mac_addr)
 {
+       u32 addr_low = le32_to_cpu(*(__le32 *) & mac_addr[0]);
+       u16 addr_hi = le16_to_cpu(*(__le16 *) & mac_addr[4]);
+
-       /* this depends on a little-endian machine */
-       bfin_write_EMAC_ADDRLO(*(u32 *) & mac_addr[0]);
-       bfin_write_EMAC_ADDRHI(*(u16 *) & mac_addr[4]);
+       bfin_write_EMAC_ADDRLO(addr_low);
+       bfin_write_EMAC_ADDRHI(addr_hi);
 }
 
 static void adjust_tx_list(void)
@@ -866,10 +873,10 @@
        int retval;
 
        /* Grab the MAC address in the MAC */
-       *(u32 *) (&(dev->dev_addr[0])) = bfin_read_EMAC_ADDRLO();
-       *(u16 *) (&(dev->dev_addr[4])) = (u16) bfin_read_EMAC_ADDRHI();
+       *(__le32 *) (&(dev->dev_addr[0])) = cpu_to_le32(bfin_read_EMAC_ADDRLO());
+       *(__le16 *) (&(dev->dev_addr[4])) = cpu_to_le16((u16) bfin_read_EMAC_ADDRHI());

-- 
Greetings Michael.
