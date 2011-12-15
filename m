From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: smatch stuff: qla3xxxx: locking problem in ql_adapter_initialize()
Date: Thu, 15 Dec 2011 11:16:22 +0300
Message-ID: <20111215081622.GA14587@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-driver@qlogic.com, netdev@vger.kernel.org
To: Ron Mercer <ron.mercer@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:18858 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752340Ab1LOIQc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2011 03:16:32 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ron,

The latest version of Smatch complains about this code which was merged
in 2009: 0f77ca928b "qla3xxx: Don't sleep while holding lock."

drivers/net/ethernet/qlogic/qla3xxx.c +3231 ql_adapter_initialize(221)
	error: calling 'spin_unlock_irqrestore()' with bogus flags

> commit 0f77ca928b5d1ea17afc7a95682b6534611a719c
> Author: Ron Mercer <ron.mercer@qlogic.com>
> Date:   Tue Jun 23 09:00:02 2009 +0000
> 
>     qla3xxx: Don't sleep while holding lock.
>     
>     Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
> index 68be714..3e4b67a 100644
> --- a/drivers/net/qla3xxx.c
> +++ b/drivers/net/qla3xxx.c
> @@ -3142,6 +3142,7 @@ static int ql_adapter_initialize(struct ql3_adapter *qdev)
>                                                 (void __iomem *)port_regs;
>         u32 delay = 10;
>         int status = 0;
> +       unsigned long hw_flags = 0;
>  
>         if(ql_mii_setup(qdev))
>                 return -1;
> @@ -3351,7 +3352,9 @@ static int ql_adapter_initialize(struct ql3_adapter *qdev)
>                 value = ql_read_page0_reg(qdev, &port_regs->portStatus);
>                 if (value & PORT_STATUS_IC)
>                         break;
> +               spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
                                                         ^^^^^^^^
This is zero here on the first iteration through the loop.  On x86 a
zero here means that it turns off IRQs.  (They are already off btw).

>                 msleep(500);
> +               spin_lock_irqsave(&qdev->hw_lock, hw_flags);
                                                    ^^^^^^^^
This is going save that the IRQs are disabled.

>         } while (--delay);
>  
>         if (delay == 0) {

My guess is that probably the intent was to enable IRQs during the
msleep().  We turn on IRQs again ql_adapter_up() so it doesn't cause a
deadlock but it's still not pretty.

regards,
dan carpetner
