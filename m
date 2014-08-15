From: christophe leroy <christophe.leroy@c-s.fr>
Subject: Re: Issue with commit 33c133cc7598e60976a phy: IRQ cannot be shared
Date: Fri, 15 Aug 2014 11:10:07 +0200
Message-ID: <53EDCE6F.9000307@c-s.fr>
References: <53EC57B9.8080903@c-s.fr> <53EC9783.3020809@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pegase1.c-s.fr ([93.17.236.30]:22187 "EHLO mailhub1.si.c-s.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750917AbaHOJKS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Aug 2014 05:10:18 -0400
In-Reply-To: <53EC9783.3020809@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Le 14/08/2014 13:03, Sergei Shtylyov a =E9crit :
> Hello.
>
> On 8/14/2014 10:31 AM, leroy christophe wrote:
>
>> I have an hardware with two ethernet interfaces, and with the two=20
>> PHYs inside
>> the same component INTEL LXT973 which has only one interrupt.
>> I also have another hardware with two ethernet interfaces and two=20
>> independant
>> PHYs. But the two PHYs are wired to the same interrupt.
>> This is working perfectly up to Linux 3.12.
>
>    Hm, I'm surprised it works. Are you sure you're getting interrupts=
=20
> from both PHYs? Because if both Ethernet controllers are active=20
> simultaneously, only the first registered PHY IRQ handler should get=20
> all the interrupts.
Yes it works. Why should only the first one get the interrupts ?=20
handle_irq_event_percpu() (from kernel/irq/handle.c, extract below)=20
calls all handlers regardless of whether they answer IRQ_NONE or=20
IRQ_HANDLED. The break applies to the switch(), not to the while(). So=20
all handlers are called.

irqreturn_t
handle_irq_event_percpu(struct irq_desc *desc, struct irqaction *action=
)
{
     irqreturn_t retval =3D IRQ_NONE;
     unsigned int flags =3D 0, irq =3D desc->irq_data.irq;

     do {
[...]
         switch (res) {
         case IRQ_WAKE_THREAD:
[...]
         case IRQ_HANDLED:
             flags |=3D action->flags;
             break;

         default:
             break;
         }

         retval |=3D res;
         action =3D action->next;
     } while (action);

>
>> But since your commit, introduced in Linux 3.13, my interfaces don't=
=20
>> work
>> anymore as the second PHYs can't register IRQ.
>
>    Strange too, the phylib should use polling in case request_irq()=20
> fails.
Well, you are right, I didn't check closely enough, was assuming they=20
didn't register due to the messages saying interrupt mismatch.
>
>> Reading the commit log, I can't really understand the reason for the=
=20
>> change.
>
>    The shared IRQ handler should check for IRQ from its device and=20
> return IRQ_NONE if there's no IRQ active; phy_interrupt() doesn't do=20
> that (this is pushed to the workqueue).
Well, as seen above, this has no impact on whether other handlers are=20
called or not.
>
>> Is it really worth it, and therefore how shall my case be handled ?
>
>    PHY IRQs are not necessary for the phylib state machine.
However, polling is less efficient than IRQs. It wastes CPU and link=20
loss detection is slower.
>
>> Christophe
>
> WBR, Sergei
>
BR
Christophe

---
Ce courrier =E9lectronique ne contient aucun virus ou logiciel malveill=
ant parce que la protection avast! Antivirus est active.
http://www.avast.com
