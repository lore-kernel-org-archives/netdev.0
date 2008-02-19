From: Tony Battersby <tonyb@cybernetics.com>
Subject: Re: TG3 network data corruption regression 2.6.24/2.6.23.4
Date: Tue, 19 Feb 2008 11:16:44 -0500
Message-ID: <47BB00EC.3010607@cybernetics.com>
References: <47BA0984.2070306@cybernetics.com> <1203381120.13495.78.camel@dell> <20080218.163554.74130592.davem@davemloft.net> <1203383046.13495.87.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	netdev <netdev@vger.kernel.org>, gregkh@suse.de,
	linux-kernel@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host64.cybernetics.com ([70.169.137.4]:2556 "EHLO
	mail.cybernetics.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1751541AbYBSQQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2008 11:16:43 -0500
In-Reply-To: <1203383046.13495.87.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Chan wrote:
> On Mon, 2008-02-18 at 16:35 -0800, David Miller wrote:
>
>   
>> One consequence of Herbert's change is that the chip will see a
>> different datastream.  The initial skb->data linear area will be
>> smaller, and the transition to the fragmented area of pages will be
>> quicker.
>>
>>     
>
> I see.  Perhaps when we get to the end of the data-stream, there is a
> tiny frag that the chip cannot handle.  That's the only thing I can
> think of.
>
> Please try this patch to see if the problem goes away.  This will
> disable SG on 5701 so we always get linear SKBs.
>
> diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> index db606b6..bb37e76 100644
> --- a/drivers/net/tg3.c
> +++ b/drivers/net/tg3.c
> @@ -12717,6 +12717,9 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
>  	} else
>  		tp->tg3_flags &= ~TG3_FLAG_RX_CHECKSUMS;
>  
> +	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701)
> +		dev->features &= ~(NETIF_F_IP_CSUM | NETIF_F_SG);
> +
>  	/* flow control autonegotiation is default behavior */
>  	tp->tg3_flags |= TG3_FLAG_PAUSE_AUTONEG;
>  	tp->link_config.flowctrl = TG3_FLOW_CTRL_TX | TG3_FLOW_CTRL_RX;
>
>
>
>   
This patch does appear to fix the data corruption (tested with
2.6.24.2).  However, it results in performance problems with the iSCSI
application that I am trying to run on this machine.

The test program that I described in the previous message still gets
good performance in both directions.  "iperf -r" gets good performance
in both directions (940 Mbits/s or 117 MB/s).  However, my target-mode
iSCSI application (which obviously generates rx/tx traffic patterns more
complicated than the synthetic tests) gets very poor performance in one
direction but good performance in the other direction.  iSCSI
performance drops to 6 - 15 MB/s when the 3Com NIC is doing heavy rx
with light tx, but remains at a decent 115 MB/s when the 3Com NIC is
doing heavy tx with light rx.  When I revert Herbert's patch instead of
applying the patch above, I get 115 MB/s in both cases.  (With a stock
unpatched kernel, the test fails almost immediately because the iSCSI
control PDUs are corrupted, causing the TCP connection to be dropped.)

The SysKonnect NIC that does not exhibit this problem has a chip that
says "BCM5411KQM" "TT0128 P2Q" and "56975E".

Tony

