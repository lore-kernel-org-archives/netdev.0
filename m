From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: 2.6.23-rc4-mm1: e1000e napi lockup
Date: Sun, 09 Sep 2007 15:50:38 -0700
Message-ID: <46E478BE.2030202@intel.com>
References: <46E0FB82.2040000@gmail.com> <46E3C3B9.4010500@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: no To-header on input
	<"unlisted-recipients:; "@doppio.foo-projects.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	Auke Kok <auke-jan.h.kok@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: Jiri Slaby <jirislaby@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms042pub.verizon.net ([206.46.252.42]:63393 "EHLO
	vms042pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752619AbXIIWuu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Sep 2007 18:50:50 -0400
Received: from ahkok-mobl.jf.intel.com ([71.182.85.189])
 by vms042.mailsrvcs.net
 (Sun Java System Messaging Server 6.2-6.01 (built Apr  3 2006))
 with ESMTPA id <0JO400EJ1I4NOTNC@vms042.mailsrvcs.net> for
 netdev@vger.kernel.org; Sun, 09 Sep 2007 17:50:48 -0500 (CDT)
In-reply-to: <46E3C3B9.4010500@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jiri Slaby wrote:
> On 09/07/2007 09:19 AM, Jiri Slaby wrote:
>> Hi,
>>
>> I found a regression in 2.6.23-rc4-mm1 (since -rc3-mm1) in e1000e driver.
>> napi_disable(&adapter->napi) in e1000_probe freezes the kernel on boot.
> 
> Ok, after these changes:
> diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
> index c1c64e2..f8ec537 100644
> --- a/drivers/net/e1000e/netdev.c
> +++ b/drivers/net/e1000e/netdev.c
> @@ -1693,10 +1693,7 @@ quit_polling:
>                 if (adapter->itr_setting & 3)
>                         e1000_set_itr(adapter);
>                 netif_rx_complete(poll_dev, napi);
> -               if (test_bit(__E1000_DOWN, &adapter->state))
> -                       atomic_dec(&adapter->irq_sem);
> -               else
> -                       e1000_irq_enable(adapter);
> +               e1000_irq_enable(adapter);
>                 return 0;
>         }
> 
> @@ -4257,7 +4254,6 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
>         /* tell the stack to leave us alone until e1000_open() is called */
>         netif_carrier_off(netdev);
>         netif_stop_queue(netdev);
> -       napi_disable(&adapter->napi);
> 
>         strcpy(netdev->name, "eth%d");
>         err = register_netdev(netdev);
> 
> 
> I still have problems with the driver. When I do `ip link set eth0 up', ksoftirq
> runs with 100 % cpu time, so I think you endlessly re-schedule some timer (or
> the new napi layer?)

something changed in the logic and e1000e apparently does something wrong. I'll 
look into it on monday and resubmit a fixup patch (see robert olsson's mail as 
well discussing this issue)

Auke
