From: Guenther Thomsen <gthomsen@bluearc.com>
Subject: Re: kernel panic (on DHCP discover?) in sky2 driver of 2.6.17-rc1
Date: Wed, 12 Apr 2006 15:26:51 -0700
Message-ID: <200604121526.51405.gthomsen@bluearc.com>
References: <200604121442.56750.gthomsen@bluearc.com> <20060412144812.6b679204@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgate.terastack.com ([195.173.195.66]:12293 "EHLO
	uk-mimesweeper.terastack.bluearc.com") by vger.kernel.org with ESMTP
	id S932362AbWDLW2o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Apr 2006 18:28:44 -0400
To: "Stephen Hemminger" <shemminger@osdl.org>
In-Reply-To: <20060412144812.6b679204@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 12 April 2006 14:48, Stephen Hemminger wrote:
> You need this patch, which Jeff hasn't applied yet.
> -----
> Subject: sky2: crash when bringing up second port
>
> Sky2 driver will oops referencing bad memory if used on
> a dual port card.  The problem is accessing past end of
> MIB counter space.
>
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
>
>
> --- test-2.6.orig/drivers/net/sky2.c
> +++ test-2.6/drivers/net/sky2.c
> @@ -579,8 +579,8 @@ static void sky2_mac_init(struct sky2_hw
>  	reg = gma_read16(hw, port, GM_PHY_ADDR);
>  	gma_write16(hw, port, GM_PHY_ADDR, reg | GM_PAR_MIB_CLR);
>
> -	for (i = 0; i < GM_MIB_CNT_SIZE; i++)
> -		gma_read16(hw, port, GM_MIB_CNT_BASE + 8 * i);
> +	for (i = GM_MIB_CNT_BASE; i <= GM_MIB_CNT_END; i += 4)
> +		gma_read16(hw, port, i);
>  	gma_write16(hw, port, GM_PHY_ADDR, reg);
>
>  	/* transmit control */
> --- test-2.6.orig/drivers/net/sky2.h
> +++ test-2.6/drivers/net/sky2.h
> @@ -1375,7 +1375,7 @@ enum {
>  	GM_PHY_ADDR	= 0x0088,	/* 16 bit r/w	GPHY Address Register */
>  /* MIB Counters */
>  	GM_MIB_CNT_BASE	= 0x0100,	/* Base Address of MIB Counters */
> -	GM_MIB_CNT_SIZE	= 256,
> +	GM_MIB_CNT_END	= 0x025C,	/* Last MIB counter */
>  };

Thanks for the very quick response. The patch indeed prevents the panic 
when bringing up the second interface, but now the host doesn't receive 
any packets anymore. It still sends packets (ARP requests, naturally). 
If I inject the Ethernet address of a second host into the arp table of 
the test subject, ICMP Echo requests are sent, but then sendmsg's 
buffer space is exhausted (?):
--8<--
[root@penguin1 ~]# arp -s 192.168.65.67 00:A0:D1:E1:F3:2C
[root@penguin1 ~]# ping 192.168.65.67
PING 192.168.65.67 (192.168.65.67) 56(84) bytes of data.
ping: sendmsg: No buffer space available
ping: sendmsg: No buffer space available
ping: sendmsg: No buffer space available
ping: sendmsg: No buffer space available
ping: sendmsg: No buffer space available
ping: sendmsg: No buffer space available

--- 192.168.65.67 ping statistics ---
19 packets transmitted, 0 received, 100% packet loss, time 37012ms
-->8--

There is no hint of a malfunction to be found in the kernel's message 
buffer.

best regards
	Guenther
