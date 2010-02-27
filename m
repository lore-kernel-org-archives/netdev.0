From: "Kumar Gopalpet-B05799" <B05799@freescale.com>
Subject: RE: Gianfar driver failing on MPC8641D based board
Date: Sat, 27 Feb 2010 11:05:32 +0530
Message-ID: <9F4C7D19E8361D4C94921B95BE08B81BC93EC3@zin33exm22.fsl.freescale.net>
References: <20100225174935.GA32370@oksana.dev.rtsoft.ru> <7d1d9c251002251653n6473f01ex2d43933ec6aa010b@mail.gmail.com> <20100226031452.GA11319@oksana.dev.rtsoft.ru> <4B87B937.6010204@ge.com> <20100226143532.GA31622@oksana.dev.rtsoft.ru> <4B87E01E.4070704@windriver.com> <4B87E662.3080106@ge.com> <4B87E9EF.3010604@ge.com> <20100226161058.GA22954@oksana.dev.rtsoft.ru> <4B87F67E.5070601@windriver.com> <20100226213825.GA32363@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Martyn Welch" <martyn.welch@ge.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	"linuxppc-dev list" <linuxppc-dev@ozlabs.org>,
	<davem@davemloft.net>
To: <avorontsov@ru.mvista.com>,
	"Paul Gortmaker" <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:65342 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751436Ab0B0Fft convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2010 00:35:49 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20100226213825.GA32363@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 

>-----Original Message-----
>From: Anton Vorontsov [mailto:avorontsov@ru.mvista.com] 
>Sent: Saturday, February 27, 2010 3:08 AM
>To: Paul Gortmaker
>Cc: Martyn Welch; netdev@vger.kernel.org; 
>linux-kernel@vger.kernel.org; linuxppc-dev list; Kumar 
>Gopalpet-B05799; davem@davemloft.net
>Subject: Re: Gianfar driver failing on MPC8641D based board
>
>On Fri, Feb 26, 2010 at 11:27:42AM -0500, Paul Gortmaker wrote:
>> On 10-02-26 11:10 AM, Anton Vorontsov wrote:
>> > On Fri, Feb 26, 2010 at 03:34:07PM +0000, Martyn Welch wrote:
>> > [...]
>> >> Out of 10 boot attempts, 7 failed.
>> > 
>> > OK, I see why. With ip=on (dhcp boot) it's much harder to trigger 
>> > it. With static ip config can I see the same.
>> 
>> I'd kind of expected to see us stuck in gianfar on that 
>lock, but the 
>> SysRQ-T doesn't show us hung up anywhere in gianfar itself.
>> [This was on a base 2.6.33, with just a small sysrq fix patch]
>
>> [df841a30] [c0009fc4] __switch_to+0x8c/0xf8                  
>                   
>> [df841a50] [c0350160] schedule+0x354/0x92c                   
>                   
>> [df841ae0] [c0331394] rpc_wait_bit_killable+0x2c/0x54        
>                   
>> [df841af0] [c0350eb0] __wait_on_bit+0x9c/0x108               
>                   
>> [df841b10] [c0350fc0] out_of_line_wait_on_bit+0xa4/0xb4      
>                   
>> [df841b40] [c0331cf0] __rpc_execute+0x16c/0x398              
>                   
>> [df841b90] [c0329abc] rpc_run_task+0x48/0x9c                 
>                   
>> [df841ba0] [c0329c40] rpc_call_sync+0x54/0x88                
>                   
>> [df841bd0] [c015e780] nfs_proc_lookup+0x94/0xe8              
>                   
>> [df841c20] [c014eb60] nfs_lookup+0x12c/0x230                 
>                   
>> [df841d50] [c00b9680] do_lookup+0x118/0x288                  
>                   
>> [df841d80] [c00bb904] link_path_walk+0x194/0x1118            
>                   
>> [df841df0] [c00bcb08] path_walk+0x8c/0x168                   
>                   
>> [df841e20] [c00bcd6c] do_path_lookup+0x74/0x7c               
>                   
>> [df841e40] [c00be148] do_filp_open+0x5d4/0xba4               
>                   
>> [df841f10] [c00abe94] do_sys_open+0xac/0x190                 
>                   
>
>Yeah, I don't think this is gianfar-related. It must be 
>something else triggered by the fact that gianfar no longer 
>sends stuff.
>
>OK, I think I found what's happening in gianfar.
>
>Some background...
>
>start_xmit() prepares new skb for transmitting, generally it 
>does three things:
>
>1. sets up all BDs (marks them ready to send), except the first one.
>2. stores skb into tx_queue->tx_skbuff so that clean_tx_ring()
>   would cleanup it later.
>3. sets up the first BD, i.e. marks it ready.
>
>Here is what clean_tx_ring() does:
>
>1. reads skbs from tx_queue->tx_skbuff
>2. Checks if the *last* BD is ready. If it's still ready [to send]
>   then it it isn't transmitted, so clean_tx_ring() returns.
>   Otherwise it actually cleanups BDs. All is OK.
>
>Now, if there is just one BD, code flow:
>
>- start_xmit(): stores skb into tx_skbuff. Note that the first BD
>  (which is also the last one) isn't marked as ready, yet.
>- clean_tx_ring(): sees that skb is not null, *and* its lstatus
>  says that it is NOT ready (like if BD was sent), so it cleans
>  it up (bad!)
>- start_xmit(): marks BD as ready [to send], but it's too late.
>
>We can fix this simply by reordering lstatus/tx_skbuff writes.
>
>It works flawlessly on my p2020, please try it.

Anton,

Understood, and thanks for the explanation. Am I correct in saying that
this is
due to the out-of-order execution capability on powerpc ?

I have one more question, why don't we use use atomic_t for num_txbdfree
and
completely  do away with spin_locks in gfar_clean_tx_ring() and
gfar_start_xmit().
In an non-SMP, scenario I would feel there is absolutely no requirement
of spin_locks
and in case of SMP atomic operation would be much more safer on powerpc
rather than spin_locks.

What is your suggestion ?


--

Thanks
Sandeep

>
>Thanks!
>
>
>diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c 
>index 8bd3c9f..cccb409 100644
>--- a/drivers/net/gianfar.c
>+++ b/drivers/net/gianfar.c
>@@ -2021,7 +2021,6 @@ static int gfar_start_xmit(struct 
>sk_buff *skb, struct net_device *dev)
> 	}
> 
> 	/* setup the TxBD length and buffer pointer for the first BD */
>-	tx_queue->tx_skbuff[tx_queue->skb_curtx] = skb;
> 	txbdp_start->bufPtr = dma_map_single(&priv->ofdev->dev, 
>skb->data,
> 			skb_headlen(skb), DMA_TO_DEVICE);
> 
>@@ -2053,6 +2052,10 @@ static int gfar_start_xmit(struct 
>sk_buff *skb, struct net_device *dev)
> 
> 	txbdp_start->lstatus = lstatus;
> 
>+	eieio(); /* force lstatus write before tx_skbuff */
>+
>+	tx_queue->tx_skbuff[tx_queue->skb_curtx] = skb;
>+
> 	/* Update the current skb pointer to the next entry we will use
> 	 * (wrapping if necessary) */
> 	tx_queue->skb_curtx = (tx_queue->skb_curtx + 1) &
>
>
