From: Aras Vaichas <arasv@magtech.com.au>
Subject: Re: [PATCH] at91_ether: multicast packet are not received due to
	incorrect setting of the multicast hashtable, kernel linux-2.6.17.3
Date: Mon, 27 Oct 2008 10:51:24 +1100
Message-ID: <4905027C.4080504@magtech.com.au>
References: <5f59dc1a0810261031w2fa3f40bne1edb2d710f64404@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk,
	Andrew Victor <avictor.za@gmail.com>
To: Leonid Slobodchikov <curvex@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.arm.linux.org.uk>
In-Reply-To: <5f59dc1a0810261031w2fa3f40bne1edb2d710f64404@mail.gmail.com>
List-Unsubscribe: <http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=unsubscribe>
List-Archive: <http://lists.arm.linux.org.uk/lurker/list/linux-arm-kernel.html>
List-Post: <mailto:linux-arm-kernel@lists.arm.linux.org.uk>
List-Help: <mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=help>
List-Subscribe: <http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.arm.linux.org.uk
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org+linux-arm-kernel=m.gmane.org@lists.arm.linux.org.uk
List-Id: netdev.vger.kernel.org

Leonid Slobodchikov wrote:
> Hello,
>
> Multicast packets are not received by the Ethernet driver for the
> Atmel AT91RM9200. This is due to incorrect mc_filter array index
> evaluation in the at91ether_sethashtable function. The point is that
> AT91_EMAC_HSH and AT91_EMAC_HSL registers are 64-bit length. So when
> evaluating the index the bit number must be diveded at 64, which is
> 2^6, not 2^5.
> The below is a fix for that issue.
>
>
> --- drivers/net/arm/at91_ether.c.orig	2006-06-30 20:37:38.000000000 +0300
> +++ drivers/net/arm/at91_ether.c	2008-10-26 17:35:50.000000000 +0200
> @@ -520,7 +520,7 @@ static void at91ether_sethashtable(struc
>  		if (!curr) break;	/* unexpected end of list */
>
>  		bitnr = hash_get_index(curr->dmi_addr);
> -		mc_filter[bitnr >> 5] |= 1 << (bitnr & 31);
> +		mc_filter[bitnr >> 6] |= 1 << (bitnr & 31);
>  	}
>
>  	at91_emac_write(AT91_EMAC_HSH, mc_filter[0]);
>   
Hmm, that is strange. I received a patch quite some time ago from Andrew
Victor to fix just such a problem. Maybe it reappeared? Or maybe I
didn't test my patch patch well enough?

--- SNIP ---

hi Aras,

> I'm using 2.6.16, at91rm9200 with a DM9161 PHY. I can't receive multicast
> packets on eth0 unless I enable "allmulti" using ifconfig - which I
shouldn't
> have to do.

Looks like the bug in the AT91RM9200 Ethernet driver's Multicast support
might have been found.

Since I know you use multicast, could you possibly test this patch
(without enabling "allmulti") and let me know?  Thanks.

Regards.
  Andrew Victor



--- linux-2.6/drivers/net/arm/at91_ether.c.orig  2007-04-25
09:46:29.000000000 +0200
+++ linux-2.6/drivers/net/arm/at91_ether.c      2007-04-25
10:00:25.000000000 +0200
@@ -535,8 +535,8 @@ static void at91ether_sethashtable(struc
                mc_filter[bitnr >> 5] |= 1 << (bitnr & 31);
        }

-       at91_emac_write(AT91_EMAC_HSH, mc_filter[0]);
-       at91_emac_write(AT91_EMAC_HSL, mc_filter[1]);
+       at91_emac_write(AT91_EMAC_HSL, mc_filter[0]);
+       at91_emac_write(AT91_EMAC_HSH, mc_filter[1]);
 }

 /*


______________________________________________________________________
This email has been scanned by the MessageLabs Email Security System.
For more information please visit http://www.messagelabs.com/email 
______________________________________________________________________

-------------------------------------------------------------------
List admin: http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel
FAQ:        http://www.arm.linux.org.uk/mailinglists/faq.php
Etiquette:  http://www.arm.linux.org.uk/mailinglists/etiquette.php
