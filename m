From: Petr Cvek <petr.cvek@tul.cz>
Subject: Re: [PATCH 2/3] net: irda: pxaficp_ir: convert to readl and writel
Date: Sat, 12 Sep 2015 06:18:32 +0200
Message-ID: <55F3A798.5090904@tul.cz>
References: <1441261251-19548-1-git-send-email-robert.jarzmik@free.fr>
 <1441261251-19548-3-git-send-email-robert.jarzmik@free.fr>
 <55EF43E9.2040000@tul.cz> <55EF8A0F.7070106@tul.cz>
 <87twr4un1h.fsf@belgarion.home> <55F11FDE.6050304@tul.cz>
 <87io7iv845.fsf@belgarion.home> <55F233D2.3020708@tul.cz>
 <87y4gdtr6e.fsf@belgarion.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Cc: zonque@gmail.com, ulf.hansson@linaro.org,
	Samuel Ortiz <samuel@sortiz.org>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>
To: Robert Jarzmik <robert.jarzmik@free.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87y4gdtr6e.fsf@belgarion.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dne 11.9.2015 v 08:18 Robert Jarzmik napsal(a):
> Petr Cvek <petr.cvek@tul.cz> writes:
> 
>>> Should have been posted to linux arm kernel mailing list, unless my mailer
>>> failed ...
>>>
>> Searching for:
>>
>> 	"ARM: pxa: add resources to pxaficp_ir"
>>
>> did not found anything, same was for "ficp" in the linux-arm-kernel/netdev/linux-kernel
>> mailing list archive.
> Ah ok, I'll resend it then.
> 
>>>> BTW This patch required update of my kernel repo. It seems that my:
>>>>
>>>> 	magician.c patches + ficp patch + new dma engine
>>>>
>>>> does not work for me at all. Kernel throws some panic about interrupts and then
>>>> it ends in an infinite stack dumping loop. Fault occurs before rootfs is
>>>> mounted, so probably around MMC init (with removed SD card it fails normally
>>>> with no rootfs found error).
>>> Could you send me (privately) the stack you're getting please. This is something
>>> I'd like to catch up early in the -rc releases.
>>
>> Well this will be problem as I cannot save anything to an SD card after and
>> during the failure.  Only viable interfaces would be earlycon on an infraport
>> or high speed camera on LCD :-).
> Ah just as on my mioa701. I ended up soldering a JTAG cable :)
Rather not :-D.

> 
>>> And it is true I have not tested the rootfs special case, where drivers are not
>>> yet initialized (and more specifically gpio and interrupt chip). Your backtrace
>>> should tell me if you fall into this category of issues ... but I digress, this
>>> has no link with pxaficp.
>>
>> Should I start new thread? (same bug can be present in the FICP too)
> Yes, this pxamci bothers me, it deserves a thread.

Will start soon.

>>
>> Anyway after mmc dma revert I was still not able to start FICP. There is an error:
>>
>> 	Unable to handle kernel paging request at virtual address 32e00004
>>
>> from pxa_irda_startup() and it seems it is caused by register definitions. For example:
>>
>> 	writel_relaxed((val), (irda)->stuart_base + (off));
>>
>> is called by
>>
>> 	stuart_writel(si, 0, STIER);
>>
>> but STIER is not just an offset, but full register address:
>> 	
>> 	__REG(0x40700004)
>>
>> So the definition should be changed, unless there is another patch I did not
>> received (in that case, send me full patchset again please) :-).
> Agreed, this is a bug in this patch. With this fix, is the pxaficp working or do
> you need a bit more time to experiment ?

I have tried with a nasty hack (use only lower part of address, it should equal with reg offset):
	#undef __REG
	-#define __REG(x) (x)
	+#define __REG(x) (x & 0xffff)

and it seems to work. The module inits and I am able to see IrDA traffic and ping other machine. FIR mode (mostly impacted by DMA) is still untested as magician unfortunately supports only SIR mode.

Petr
