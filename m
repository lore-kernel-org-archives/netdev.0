From: Matheos Worku <Matheos.Worku@Sun.COM>
Subject: Re: [PATCH]: Second preliminary release of Sun Neptune driver
Date: Fri, 28 Sep 2007 11:10:45 -0700
Message-ID: <46FD43A5.6070007@sun.com>
References: <20070927.220027.31653674.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=ISO-8859-1
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, Ariel.Hendel@Sun.COM, Greg.Onufer@Sun.COM,
	jeff@garzik.org, Ashley.Saulsbury@Sun.COM
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-1.Sun.COM ([192.18.43.132]:57759 "EHLO
	sca-es-mail-1.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754427AbXI1SRg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2007 14:17:36 -0400
Received: from fe-sfbay-10.sun.com ([192.18.43.129])
	by sca-es-mail-1.sun.com (8.13.7+Sun/8.12.9) with ESMTP id l8SIB9go011529
	for <netdev@vger.kernel.org>; Fri, 28 Sep 2007 11:11:09 -0700 (PDT)
Received: from conversion-daemon.fe-sfbay-10.sun.com by fe-sfbay-10.sun.com
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 id <0JP300K01BRESL00@fe-sfbay-10.sun.com>
 (original mail from Matheos.Worku@Sun.COM) for netdev@vger.kernel.org; Fri,
 28 Sep 2007 11:11:09 -0700 (PDT)
In-reply-to: <20070927.220027.31653674.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> Ok, this is rev2, changes:
>
> 1) Jumbo MTU support is now present.  I got stuck on this for
>    a while because I didn't realize that resetting the RX
>    XMAC would reset the XMAC_MAX register.  I thought that
>    was a TX XMAC resource, ho hum...
>
>    Fix this by re-initializing the TX MAC after resetting
>    the RX MAC.
>
> 2) Implementing support for jumbograms required a re-examination of
>    how TX queue handling was done.
>
>    Neptune can report the TX Head at a location which is in the middle
>    of a packet's group of descriptors for a multi segment packet.
>    Working around this would just overly complicate the code.
>
>    We don't need to use the TX Head register.  Instead, track the
>    "pkt_cnt" field of the TX_CS register.  The difference since the
>    last reading is the number of full TX frames we can reclaim from
>    the ring.
>
>    This is not only simpler, it allows us to only need one MMIO
>    access (for TX_CS) during a reclaim run instead of two (TX_CS
>    and TX_RING_HDL).
>
>    A side note, I'm purposefully not using TX mailbox support.  It's
>    broken in Neptune.  If you get the registers in the DMA mailbox, MK
>    and MMK are always both set in the TX_CS register.  So even if you
>    write the MK and MB bits back to TX_CS to clear the interrupt, the
>    MMK propagates to MK and you thus get another interrupt.  This
>    basically makes TX DMA mailbox support useless.
>
> 4) All register write accessors are now of the form xxx(reg, val)
>    instead of xxx(val, reg)
>
> 5) Kill PCI_DEVICE_ID_SUN_NEPTUNE define, unneeded.
>
> Performance isn't the best, but the driver is reasonably solid.  After
> I flesh out the remaining features that need to be implemented I'll
> take a closer look at that.
>
> Enjoy.
>
> commit 684a7c25fff607dc647f065761bb381f28bddbdb
> Author: David S. Miller <davem@sunset.davemloft.net>
> Date:   Thu Sep 27 21:43:57 2007 -0700
>
>     [NIU]: Add Sun Neptune ethernet driver.
>     
>     Signed-off-by: David S. Miller <davem@davemloft.net>
>
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index 467532c..3c94c8f 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -2601,6 +2601,13 @@ config NETXEN_NIC
>  	help
>  	  This enables the support for NetXen's Gigabit Ethernet card.
>  
> +config NIU
> +	tristate "Sun Neptune 10Gbit Ethernet support"
> +	depends on PCI
> +	help
> +	  This enables support for cards based upon Sun's
> +	  Neptune chipset.
> +
>  config PASEMI_MAC
>  	tristate "PA Semi 1/10Gbit MAC"
>  	depends on PPC64 && PCI
> diff --git a/drivers/net/Makefile b/drivers/net/Makefile
> index 6220c50..cce379b 100644
> --- a/drivers/net/Makefile
> +++ b/drivers/net/Makefile
> @@ -242,3 +242,4 @@ obj-$(CONFIG_NETCONSOLE) += netconsole.o
>  obj-$(CONFIG_FS_ENET) += fs_enet/
>  
>  obj-$(CONFIG_NETXEN_NIC) += netxen/
> +obj-$(CONFIG_NIU) += niu.o
> diff --git a/drivers/net/niu.c b/drivers/net/niu.c
> new file mode 100644
> index 0000000..5b89559
> --- /dev/null
> +++ b/drivers/net/niu.c
>   

Dave,
Couple of comments on Jumbo support

TX Side:
Can we rule of fragment size > MAX_TX_DESC_LEN? If that is not the case, 
then the frags my need the same tx post and reclaim logic as the skb->data

RX Side
    Since the MAC is set not to strip FCS bytes, the last page could 
contain just 1 - 4 bytes of FCS. Not only this wastes the page but may 
result on bug RX process where skb->len is wrong and a page with junk is 
passed to the stack. In our off-the-tree driver, we check this condition 
and repost the last page back to the rbr, if it contains just the FCS bytes.

Regards,
Matheos

