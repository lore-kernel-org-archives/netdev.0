From: "Kumar Gopalpet-B05799" <B05799@freescale.com>
Subject: RE: Gianfar driver failing on MPC8641D based board
Date: Fri, 26 Feb 2010 10:28:46 +0530
Message-ID: <9F4C7D19E8361D4C94921B95BE08B81BC93E3A@zin33exm22.fsl.freescale.net>
References: <4B6C2488.3060403@ge.com> <4B865176.7080806@ge.com> <4B86A97E.6050509@ge.com> <20100225165141.GA9686@oksana.dev.rtsoft.ru> <20100225174935.GA32370@oksana.dev.rtsoft.ru> <7d1d9c251002251653n6473f01ex2d43933ec6aa010b@mail.gmail.com> <20100226031452.GA11319@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Martyn Welch" <martyn.welch@ge.com>,
	"linuxppc-dev list" <linuxppc-dev@ozlabs.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<davem@davemloft.net>, "Kumar Gala" <galak@kernel.crashing.org>
To: <avorontsov@ru.mvista.com>,
	"Paul Gortmaker" <paul.gortmaker@windriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <20100226031452.GA11319@oksana.dev.rtsoft.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 

>-----Original Message-----
>From: Anton Vorontsov [mailto:avorontsov@ru.mvista.com] 
>Sent: Friday, February 26, 2010 8:45 AM
>To: Paul Gortmaker
>Cc: Martyn Welch; linuxppc-dev list; netdev@vger.kernel.org; 
>linux-kernel@vger.kernel.org; Kumar Gopalpet-B05799; 
>davem@davemloft.net; Kumar Gala
>Subject: Re: Gianfar driver failing on MPC8641D based board
>
>On Thu, Feb 25, 2010 at 07:53:30PM -0500, Paul Gortmaker wrote:
>[...]
>> I was able to reproduce it on an 8641D and bisected it down to this:
>> 
>> -----------
>> commit a3bc1f11e9b867a4f49505ecac486a33af248b2e
>> Author: Anton Vorontsov <avorontsov@ru.mvista.com>
>> Date:   Tue Nov 10 14:11:10 2009 +0000
>> 
>>     gianfar: Revive SKB recycling
>
>Thanks for the bisect. I have a guess why tx hangs in SMP 
>case. Could anyone try the patch down below?
>
>[...]
>> ...which probably explains why you weren't seeing it on non-SMP.
>> I'd imagine it would show up on any of the e500mc boards too.
>
>Yeah.. Pity, I don't have SMP boards anymore. I'll try to get 
>one though.
>
>
>diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c 
>index 8bd3c9f..3ff3bd0 100644
>--- a/drivers/net/gianfar.c
>+++ b/drivers/net/gianfar.c
>@@ -2614,6 +2614,8 @@ static int gfar_poll(struct napi_struct 
>*napi, int budget)
> 			tx_queue = priv->tx_queue[rx_queue->qindex];
> 
> 			tx_cleaned += gfar_clean_tx_ring(tx_queue);
>+			if (!tx_cleaned && !tx_queue->num_txbdfree)
>+				tx_cleaned += 1; /* don't 
>complete napi */
> 			rx_cleaned_per_queue = 
>gfar_clean_rx_ring(rx_queue,
> 							
>budget_per_queue);
> 			rx_cleaned += rx_cleaned_per_queue;
>

Anton, 

There is also one more issue that I have been observing with the patch
"gianfar: Revive SKB recycling".
The issue is when I do a IPV4 forwarding test scenario with
bidirectional flows (SMP environment). I am using Spirent smart bits
(smartflow) for automation testing and I frequently observe smart flow
reporting "Rx packet counte greater than Tx packet count. Duplicate
packets might have been received".

To just get over the issue I have removed this patch and I didn't see
the issue.

To a certain extent I could get over the problem by using atomic_t for
num_txbdfree (atomic_add and atomic_dec instructions for updating the
num_txbdfree) and completely removing the spin_locks in the tx routines.

Also, I feel we might want to make some more changes to the
gfar_clean_tx_ring( ) and gfar_start_xmit() routines so that they can
operate parallely. 

I am really sorry for not posting it a bit earlier as I am caught up
with some urgent issues.

--

Thanks
Sandeep
