From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 1/2] [RFC] NET: Implement a standard ndev_printk family
Date: Fri, 08 Jun 2007 20:06:30 -0700
Message-ID: <466A1936.7090701@intel.com>
References: <20070608220007.31573.14931.stgit@localhost.localdomain>	<20070608162415.1481dfec@localhost.localdomain>	<4669E967.5030708@intel.com> <20070608171040.2b4a2dd7@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, davem@davemloft.net,
	arjan@linux.intel.com
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:23299 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752351AbXFIDGj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jun 2007 23:06:39 -0400
In-Reply-To: <20070608171040.2b4a2dd7@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Fri, 08 Jun 2007 16:42:31 -0700
> "Kok, Auke" <auke-jan.h.kok@intel.com> wrote:
> 
>> Stephen Hemminger wrote:
>>>>  
>>>> +#define ndev_printk(kern_level, netif_level, netdev, format, arg...) \
>>>> +	do { if ((netdev)->msg_enable & NETIF_MSG_##netif_level) { \
>>>> +		printk(kern_level "%s: " format, \
>>>> +		(netdev)->name, ## arg); } } while (0)
>>> Could you make a version that doesn't evaluate the arguments twice?
>> hmm you lost me there a bit; Do you want me to duplicate this code for all the 
>> ndev_err/ndev_info functions instead so that ndev_err doesn't direct back to 
>> ndev_printk?
> 
> It is good practice in a macro to avoid potential problems with usage
> by only touching the arguments once. Otherwise, something (bogus) like
> 	ndev_printk(KERN_DEBUG, NETIF_MSG_PKTDATA, "got %d\n",
> 		    dev++, skb->len)
> would increment dev twice.

agreed, but

> My preference would be something more like dev_printk or even use that?
> You want to show both device name, and physical attachment in the message.

actually these ndev_* macros are almost an exact copy of dev_printk, which is 
how I modeled them in the first place!

See for yourself - here's the relevant snipplet from linux/device.h:

500 #define dev_printk(level, dev, format, arg...)  \
501         printk(level "%s %s: " format , dev_driver_string(dev) , 
(dev)->bus_id , ## arg)
502
503 #ifdef DEBUG
504 #define dev_dbg(dev, format, arg...)            \
505         dev_printk(KERN_DEBUG , dev , format , ## arg)
506 #else
507 #define dev_dbg(dev, format, arg...) do { (void)(dev); } while (0)
508 #endif
509
510 #define dev_err(dev, format, arg...)            \
511         dev_printk(KERN_ERR , dev , format , ## arg)
512 #define dev_info(dev, format, arg...)           \
513         dev_printk(KERN_INFO , dev , format , ## arg)
514 #define dev_warn(dev, format, arg...)           \
515         dev_printk(KERN_WARNING , dev , format , ## arg)
516 #define dev_notice(dev, format, arg...)         \
517         dev_printk(KERN_NOTICE , dev , format , ## arg)

using dev_printk however ignores msg_enable completely and also omits 
netdev->name, which may even change, so for netdevices it's much less suitable, 
maybe only at init time.

We can fix the dev_printk macro family as well, that's allright, but the need 
for a netdev-centric printk should be obvious: almost every netdevice driver has 
it's own variant :)

Auke
