From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] pch_gbe: Adding read memory barriers
Date: Wed, 9 May 2012 11:47:42 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F602CD83CB@saturn3.aculab.com>
References: <4FA822C4.60809@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <tshimizu818@gmail.com>
To: "Erwan Velu" <erwanaliasr1@gmail.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:46774 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751501Ab2EIKsH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2012 06:48:07 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 11794-04 for <netdev@vger.kernel.org>;
 Wed,  9 May 2012 11:48:04 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <4FA822C4.60809@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> Under a strong incoming packet stream and/or high cpu usage,
> the pch_gbe driver reports "Receive CRC Error" and discards packet.
> 
> It occurred on an Intel ATOM E620T while running a 
> 300mbit/sec multicast
> network stream leading to a ~100% cpu usage.
> 
> Adding rmb() calls before considering the network card's status solve
> this issue.
> 
> Getting it into stable would be perfect as it solves 
> reliability issues.
> 
> Signed-off-by: Erwan Velu <erwan.velu@zodiacaerospace.com>
> ---
>   .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |    3 +++
>   1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c 
> b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> index 8035e5f..ace3654 100644
> --- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> +++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> @@ -1413,6 +1413,7 @@ static irqreturn_t pch_gbe_intr(int 
> irq, void *data)
>   			pch_gbe_mac_set_pause_packet(hw);
>   		}
>   	}
> +	smp_rmb(); /* prevent any other reads before*/

Under the assumption that your memory references are uncached,
you only need to stop gcc reordering the object code,
Rather than actually adding one of the 'fence' instructions.

So you should only need: asm volatile(:::"memory")
NFI which define generates that, the defines in the copy of
sysdep.h I just looked at always include one of the fences.

	David
