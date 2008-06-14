From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: Added fix for device xmit call with irq
 disabled <resubmit>
Date: Fri, 13 Jun 2008 19:34:55 -0700 (PDT)
Message-ID: <20080613.193455.84871367.davem@davemloft.net>
References: <97949e3e0806131814j1f22fd72oce1541511d728120@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net, fubar@us.ibm.com,
	jgarzik@pobox.com
To: chavey@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36294
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754586AbYFNCez (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jun 2008 22:34:55 -0400
In-Reply-To: <97949e3e0806131814j1f22fd72oce1541511d728120@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Laurent Chavey" <chavey@google.com>
Date: Fri, 13 Jun 2008 18:14:55 -0700

Jay, the bonding maintainer, and Jeff Garzik, the
wires networking driver maintainer, added to CC:

> Resubmitting. Previous patch sent with html tags.
> 
> In some rare cases (i.e. netconsole), hard_start_xmit() may be
> called with interrupts disabled as such it cannot call the slave's
> dev_queue_xmit() with interrupts disabled. So instead, it calls the
> slave's hard_start_xmit().
> 
> Signed-off-by: Laurent Chavey <chavey@google.com>
> 
> --- linux-2.6.25.org/drivers/net/bonding/bond_main.c    2008-04-16
> 19:49:44.000000000 -0700
> +++ linux-2.6.25/drivers/net/bonding/bond_main.c        2008-06-13
> 17:37:10.000000000 -0700
> @@ -401,8 +401,21 @@
>                 skb->dev = slave_dev;
>         }
> 
> -       skb->priority = 1;
> -       dev_queue_xmit(skb);
> +       /* priority field is used by tc qdiscs for classifying
> +        * packets. See usage of TC_H_MAJ and TC_H_MIN in
> +        * /net/sched/sch_*.c files.
> +        */
> +       skb->priority |= 1;
> +
> +       /* In some rare cases (i.e. netconsole), hard_start_xmit() may be
> +        * called with interrupts disabled as such it cannot call the slave's
> +        * dev_queue_xmit() with interrupts disabled. So instead, it calls the
> +        * slave's hard_start_xmit().
> +        */
> +       if (unlikely(irqs_disabled()))
> +               slave_dev->hard_start_xmit(skb, slave_dev);
> +       else
> +               dev_queue_xmit(skb);
> 
>         return 0;
>  }
> 
> --
