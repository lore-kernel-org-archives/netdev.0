From: jamal <hadi@cyberus.ca>
Subject: Re: NAPI:  dev.c change to net_rx_action algorithm.
Date: Fri, 8 Nov 2002 23:32:02 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0211082326220.16986-100000@shell.cyberus.ca>
References: <3DCC8DC2.4020204@candelatech.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3DCC8DC2.4020204@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



The only thing i can think of is that if it was legal to flog people
youd be on my list. And i would hope you dont enjoy it.
Why do you like to put band-aids to things?
Find the real cause of why you may be having problems then cure it;
putting arbitrary hacks just because you can is rather against
the basic principles of engineering.

cheers,
jamal


On Fri, 8 Nov 2002, Ben Greear wrote:

> I tried making this change to dev.c in the net_rx_action method.
>
> So far, I have passed about 25 million packets and only dropped
> about 1.5k.  This is with 4 interfaces tx + rx 8kpps (757 byte packets).
>
> rx-ring size is 1024, weight is 24, skb-hotlist is 2048.  This is
> the best results so far, but it may be that this code change does
> not fare so well in other cases....
>
> Comments?
>
>
> /*
> 		if (dev->quota <= 0 || dev->poll(dev, &budget)) {
> 			local_irq_disable();
> 			list_del(&dev->poll_list);
> 			list_add_tail(&dev->poll_list, &queue->poll_list);
> 			if (dev->quota < 0)
>                                  dev->quota += dev->weight;
>                          else
>                                  dev->quota = dev->weight;
> 		} else {
> 			dev_put(dev);
> 			local_irq_disable();
> 		}
> */
>
>                  /* This scheme should allow devices to build up 2x their weight in quota
>                   * credit.  Heavy users will only get their normal quota.  This should
>                   * help let bursty traffic get higher priority. --Ben
>                   */
>                  if (dev->poll(dev, &budget)) {
>                          /* More to do, put these guys back on the poll list */
> 			local_irq_disable();
> 			list_del(&dev->poll_list);
> 			list_add_tail(&dev->poll_list, &queue->poll_list);
>                          dev->quota = dev->weight;
>                  }
>                  else {
>                          /* These guys are done, they come off of the poll list */
>                          if (dev->quota >= dev->weight) {
>                                  dev->quota = (dev->weight << 1); /* max quota of 2x weight */
>                          }
>                          else {
>                                  dev->quota += dev->weight;
>                          }
> 			dev_put(dev);
> 			local_irq_disable();
> 		}
>
> --
> Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
> President of Candela Technologies Inc      http://www.candelatech.com
> ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
>
>
>
