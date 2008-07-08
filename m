From: James Chapman <jchapman@katalix.com>
Subject: Re: data received but not detected
Date: Tue, 08 Jul 2008 10:37:51 +0100
Message-ID: <4873356F.5080402@katalix.com>
References: <1213740538.5771.192.camel@localhost.localdomain>	 <48583B37.5070708@candelatech.com>	 <1213743506.5771.220.camel@localhost.localdomain>	 <48584CAD.6010509@candelatech.com>	 <1213915992.9245.71.camel@localhost.localdomain>	 <485E185E.1090807@katalix.com> <1215467798.14023.130.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Travis Stratman <tstratman@emacinc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:36172 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751559AbYGHJiD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2008 05:38:03 -0400
In-Reply-To: <1215467798.14023.130.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Travis Stratman wrote:
> On Sun, 2008-06-22 at 10:16 +0100, James Chapman wrote:
>> I looked at macb.c and can see that it uses napi only for rx work, 
>> leaving tx interrupts enabled at all times. The interrupt handler reads 
>> the device interrupt status when a tx interrupt happens and may find rx 
>> bits also set. As a result, your netif_rx_schedule_prep() will sometimes 
>> return false because napi might be already scheduled. The code you have 
>> above (i.e. the "driver bug" case) is wrong.
> 
> Thanks for the reply James.
> 
> That is somewhat confusing to me because once an rx interrupt is
> detected and the rx interrupts are disabled the rx bits should not be
> set in the interrupt status register until they are re-enabled again
> after polling has finished. Can you explain your point a little more?

The rx and tx status are flagged in the same status register. The bits 
are set regardless of whether rx or tx interrupts are enabled in the 
device. So when you handle a tx interrupt, the interrupt routine will 
read the status register and may see rx bits also set.

You could mask the status register value that you read to ignore rx bits 
if rx interrupts are disabled (NAPI polled mode). But to be honest, I 
think it is simpler to handle rx _and_ tx work in the NAPI poll handler 
so you only get interrupts when not in NAPI polled mode. See tg3.c or 
e100.c for example.


-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

