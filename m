From: santosh prasad nayak <santoshprasadnayak@gmail.com>
Subject: Re: [PATCH 1/3] qla3xxx: ethernet: Fix bogus interrupt state flag.
Date: Fri, 2 Mar 2012 21:24:29 +0530
Message-ID: <CAOD=uF5ebyA-yd8T8nXd9vYRw1yvFKVQd9TmcBwMnxFs6enKvA@mail.gmail.com>
References: <1330700945-18195-1-git-send-email-santoshprasadnayak@gmail.com>
	<1330702146.2611.1.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jitendra.kalsaria@qlogic.com, ron.mercer@qlogic.com,
	linux-driver@qlogic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:36826 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758838Ab2CBPya convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2012 10:54:30 -0500
In-Reply-To: <1330702146.2611.1.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am getting following error :

"qla3xxx.c:3231 ql_adapter_initialize() error: calling
'spin_unlock_irqrestore()' with bogus flags"


In "ql_adapter_up"  locking and unlocking  are happening in proper
sequence and the interrupt
state saved in "hw_flags" is restored.

In "ql_adapter_initialize", first unlock is done by
"spin_unlock_irqrestore(&qdev->hw_lock, hw_flags)"
with "hw_flags =3D 0"   ("hw_flags" is local variable and initialized t=
o
zero.),   which is as good as
spin_unlock_irq.


To avoid the above error and  for better performance
'spin_unlock_irqrestore()' can be replaced
with 'spin_unlock_irq()' and 'spin_lock_irqsave()' can be replaced by
'spin_lock_irq()' in "ql_adapter_initialize()"


regards
santosh

On Fri, Mar 2, 2012 at 8:59 PM, Ben Hutchings <bhutchings@solarflare.co=
m> wrote:
> On Fri, 2012-03-02 at 20:39 +0530, santosh nayak wrote:
>> From: Santosh Nayak <santoshprasadnayak@gmail.com>
>>
>> In 'ql_adapter_initialize'
>> the first call for 'spin_unlock_irqrestore()' is with hw_flags =3D 0=
,
>> which is as good as 'spin_unlock_irq()' (unconditional interrupt
>> enabling). If this is intended, then for better performance
>> 'spin_unlock_irqrestore()' can be replaced with 'spin_unlock_irq()'
>> and 'spin_lock_irqsave()' can be replaced by 'spin_lock_irq()
>
> Maybe you should make the same change in ql_adapter_up(), which is th=
e
> caller that acquires this spinlock (and certainly shouldn't be called=
 in
> IRQ context).
>
> Ben.
>
>> Signed-off-by: Santosh Nayak <santoshprasadnayak@gmail.com>
>> ---
>> =A0drivers/net/ethernet/qlogic/qla3xxx.c | =A0 =A05 ++---
>> =A01 files changed, 2 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/qlogic/qla3xxx.c b/drivers/net/eth=
ernet/qlogic/qla3xxx.c
>> index d49f6da..8da3e41 100644
>> --- a/drivers/net/ethernet/qlogic/qla3xxx.c
>> +++ b/drivers/net/ethernet/qlogic/qla3xxx.c
>> @@ -3017,7 +3017,6 @@ static int ql_adapter_initialize(struct ql3_ad=
apter *qdev)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 (void __iomem *)port_regs;
>> =A0 =A0 =A0 u32 delay =3D 10;
>> =A0 =A0 =A0 int status =3D 0;
>> - =A0 =A0 unsigned long hw_flags =3D 0;
>>
>> =A0 =A0 =A0 if (ql_mii_setup(qdev))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -1;
>> @@ -3228,9 +3227,9 @@ static int ql_adapter_initialize(struct ql3_ad=
apter *qdev)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 value =3D ql_read_page0_reg(qdev, &port_=
regs->portStatus);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (value & PORT_STATUS_IC)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> - =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_irqrestore(&qdev->hw_lock, hw_=
flags);
>> + =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_irq(&qdev->hw_lock);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 msleep(500);
>> - =A0 =A0 =A0 =A0 =A0 =A0 spin_lock_irqsave(&qdev->hw_lock, hw_flags=
);
>> + =A0 =A0 =A0 =A0 =A0 =A0 spin_lock_irq(&qdev->hw_lock);
>> =A0 =A0 =A0 } while (--delay);
>>
>> =A0 =A0 =A0 if (delay =3D=3D 0) {
>
> --
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>
