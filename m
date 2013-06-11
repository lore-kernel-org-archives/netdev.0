From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH] drivers/net/ethernet/3com: Drop EISA dependency from
 VORTEX
Date: Tue, 11 Jun 2013 16:16:20 -0400
Message-ID: <51B78594.5050903@windriver.com>
References: <1370962642-12097-1-git-send-email-markos.chandras@imgtec.com> <51B75088.8050800@windriver.com> <CAG2jQ8hACp_iGEXR7rXKR3sydK4O=y0paeh1FFgH2UisxWVxVA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Markos Chandras <markos.chandras@imgtec.com>,
	<linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Markos Chandras <markos.chandras@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAG2jQ8hACp_iGEXR7rXKR3sydK4O=y0paeh1FFgH2UisxWVxVA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13-06-11 01:48 PM, Markos Chandras wrote:
> On 11 June 2013 17:30, Paul Gortmaker <paul.gortmaker@windriver.com> wrote:
>> On 13-06-11 10:57 AM, Markos Chandras wrote:
>>> The Vortex driver depends on PCI with optional support for EISA.
>>>
>>> This fixes build problems when EISA is selected but not PCI.
>>>
>>> drivers/net/ethernet/3com/3c59x.c:1031:2: error: implicit declaration of
>>> function 'pci_iomap' [-Werror=implicit-function-declaration]
>>> drivers/net/ethernet/3com/3c59x.c:1044:3: error: implicit declaration of
>>> function 'pci_iounmap' [-Werror=implicit-function-declaration]
>>>
>>> Cc: David S. Miller <davem@davemloft.net>
>>> Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
>>> Cc: netdev@vger.kernel.org
>>> Signed-off-by: Markos Chandras <markos.chandras@imgtec.com>
>>> ---
>>>  drivers/net/ethernet/3com/Kconfig | 2 +-
>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> diff --git a/drivers/net/ethernet/3com/Kconfig b/drivers/net/ethernet/3com/Kconfig
>>> index 1c71c76..5c67f44 100644
>>> --- a/drivers/net/ethernet/3com/Kconfig
>>> +++ b/drivers/net/ethernet/3com/Kconfig
>>> @@ -66,7 +66,7 @@ config PCMCIA_3C589
>>>
>>>  config VORTEX
>>>       tristate "3c590/3c900 series (592/595/597) \"Vortex/Boomerang\" support"
>>> -     depends on (PCI || EISA) && HAS_IOPORT
>>> +     depends on PCI && HAS_IOPORT
>>
>> How can this fix it?  The way I read your change is that you
>> have now made it impossible to select for EISA=y and PCI=n,
>> thus breaking EISA only configurations who would find their
>> driver support gone when they run "make oldconfig".
>>
>> P.
>> --
>>
>>>       select NET_CORE
>>>       select MII
>>>       ---help---
>>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
> 
> Hi Paul,
> 
> The driver does not seem to build if you only have EISA=y and PCI=n.
> Does this driver really support EISA only

Yes.  Not that anyone really probably cares anymore.  EISA is dead.

> configurations? Reading the code it seems to me that the PCI support
> is mandatory for the driver to build and work.

Oh really?  Having PCI disabled seems fine on today's net-next tree
from what I see below:

--------------
paul@yow-lpgnfs-02:~/git/linux-head$ make -j20 > /dev/null
WARNING: modpost: Found 1 section mismatch(es).
To see full details build your kernel with:
'make CONFIG_DEBUG_SECTION_MISMATCH=y'
Setup is 15052 bytes (padded to 15360 bytes).
System is 1357 kB
CRC 9090cb73
paul@yow-lpgnfs-02:~/git/linux-head$ grep EISA .config
CONFIG_EISA=y
# CONFIG_EISA_VLB_PRIMING is not set
CONFIG_EISA_VIRTUAL_ROOT=y
CONFIG_EISA_NAMES=y
paul@yow-lpgnfs-02:~/git/linux-head$ grep PCI .config
# Bus options (PCI etc.)
# CONFIG_PCI is not set
CONFIG_PCI_LABEL=y
CONFIG_GENERIC_PCI_IOMAP=y
paul@yow-lpgnfs-02:~/git/linux-head$ git log --oneline -1
45203a3 net_sched: add 64bit rate estimators
paul@yow-lpgnfs-02:~/git/linux-head$ 
----------------

The .config is an allnoconfig, then turned on EISA, NETDEVICES, etc
and 3C900 support.  As you can see, PCI is not enabled, but the
GENERIC_PCI_IOMAP is (I didn't manually enable it, x86 selects it
via GENERIC_IOMAP).  Were you building for some other non x86 arch,
and simply didn't think it important to mention that?

Paul.
--

> 
> --
> Regards,
> Markos Chandras
> 
