From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: [Security, resend] Instant crash with rtl8169 and large packets
Date: Mon, 08 Jun 2009 23:57:00 +0400
Message-ID: <4A2D6D0C.6060206@msgid.tls.msk.ru>
References: <4A2D1147.8020101@msgid.tls.msk.ru> <4A2D1FE4.5030100@gmail.com> <4A2D25F6.9080300@msgid.tls.msk.ru> <4A2D2906.6090002@gmail.com> <4A2D301D.9040301@msgid.tls.msk.ru> <4A2D3568.6010901@gmail.com> <4A2D3BC6.3040904@msgid.tls.msk.ru> <4A2D4AA7.6020204@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([81.13.33.159]:57165 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751377AbZFHT47 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Jun 2009 15:56:59 -0400
In-Reply-To: <4A2D4AA7.6020204@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
[]
> OK I suspect driver is buggy since 2.6.10 days :)
> 
> Could you try this patch ?

Tried it, and it appears to work.  Tried various MTU combinations
and packet sizes.  Checked iperf too, with and without the patch
and with different MTU too, to be sure the patch does not introduce
any slowdowns - everything looks sane.  In case the incoming packet
is larger than the RX buffer size, `errors' and `frames' RX stats
gets incremented.

The only somewhat odd thing is that rx path accepts packets larger
than MTU by 3 bytes.  For example, if I set mtu to 2000, the
largest packet I can send is 2003 bytes; with mtu=2002, largest
actual packet size is 2005 bytes.  This is complete frame - in
terms of ping size (ping -s) it's 1975 and 1977 bytes.  That to
say, maybe we still have some corner case somewhere, for packets
larger than mtu by 1, 2 or 3 bytes.

Also I didn't try MTU < 1500.

Other than that,

Tested-By: Michael Tokarev <mjt@tls.msk.ru>

And by the way, your email client uses quoted-printable encoding.
I had to use trivial perl one-liner to convert your patches to
plaintext.  JFYI.

Thanks!

/mjt

> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index 8247a94..c5ab5a8 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -2357,10 +2357,10 @@ static u16 rtl_rw_cpluscmd(void __iomem *ioaddr)
>  	return cmd;
>  }
>  
> -static void rtl_set_rx_max_size(void __iomem *ioaddr)
> +static void rtl_set_rx_max_size(void __iomem *ioaddr, unsigned int rx_buf_sz)
>  {
>  	/* Low hurts. Let's disable the filtering. */
> -	RTL_W16(RxMaxSize, 16383);
> +	RTL_W16(RxMaxSize, rx_buf_sz);
>  }
>  
>  static void rtl8169_set_magic_reg(void __iomem *ioaddr, unsigned mac_version)
> @@ -2407,7 +2407,7 @@ static void rtl_hw_start_8169(struct net_device *dev)
>  
>  	RTL_W8(EarlyTxThres, EarlyTxThld);
>  
> -	rtl_set_rx_max_size(ioaddr);
> +	rtl_set_rx_max_size(ioaddr, tp->rx_buf_sz);
>  
>  	if ((tp->mac_version == RTL_GIGA_MAC_VER_01) ||
>  	    (tp->mac_version == RTL_GIGA_MAC_VER_02) ||
> @@ -2668,7 +2668,7 @@ static void rtl_hw_start_8168(struct net_device *dev)
>  
>  	RTL_W8(EarlyTxThres, EarlyTxThld);
>  
> -	rtl_set_rx_max_size(ioaddr);
> +	rtl_set_rx_max_size(ioaddr, tp->rx_buf_sz);
>  
>  	tp->cp_cmd |= RTL_R16(CPlusCmd) | PktCntrDisable | INTT_1;
>  
> @@ -2846,7 +2846,7 @@ static void rtl_hw_start_8101(struct net_device *dev)
>  
>  	RTL_W8(EarlyTxThres, EarlyTxThld);
>  
> -	rtl_set_rx_max_size(ioaddr);
> +	rtl_set_rx_max_size(ioaddr, tp->rx_buf_sz);
>  
>  	tp->cp_cmd |= rtl_rw_cpluscmd(ioaddr) | PCIMulRW;
>  
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

