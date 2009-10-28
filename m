From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: Do Tx handling in a separate tasklet.
Date: Wed, 28 Oct 2009 02:57:42 -0700 (PDT)
Message-ID: <20091028.025742.32857568.davem@davemloft.net>
References: <8628FE4E7912BF47A96AE7DD7BAC0AADCB2CFF2028@SJEXCHCCR02.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: IMCEAMAILTO-davem+40davemloft+2Enet@broadcom.com,
	eilong@broadcom.com, netdev@vger.kernel.org
To: vladz@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52175
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753155AbZJ1J5S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 05:57:18 -0400
In-Reply-To: <8628FE4E7912BF47A96AE7DD7BAC0AADCB2CFF2028@SJEXCHCCR02.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Vladislav Zolotarov" <vladz@broadcom.com>
Date: Wed, 28 Oct 2009 02:54:37 -0700

> I'd like to start from your last remark: you r absolutely right, and this is the problem we have in the current net-next driver. More than that, this patch is fixing this problem: it moved liberation of Tx SKBs from hardIRQ context (ISR) to the softIRQ context (tasklet) thereby resolving the problem u've mentioned. So, total agreement with u on this one. I must have named the patch differently to emphasize it.
> 
> I'd like to summarize the patch I've sent:
> - Take Tx SKB liberation out of hardIRQ.
> - Instead schedule a DPC that handles Tx work.
> - Optimize the access to status block indices: read only the index we are about to use in the current context.
> 
> So, could u, pls., apply the patch in order to fix the problem we currently have in bnx2x?

There is no reason not to use NAPI to achieve this objective and that's
the main objection I have to your patch.

Using NAPI will not only allow you to move the SKB freeing to softirq
context but it will also provide fairness between multiple NAPI
contexts active at the same time on the same cpu.

Furthermore, if you combine RX and TX NAPI work for a specific queue
into the same NAPI context, TX liberation can run first and provide
fresh CPU local SKBs for RX packet input processing created replies
to allocate.

You haven't addressed any of that, and I am not going to apply your
patch becuase I don't want your driver to set a precedence here.
