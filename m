From: "Rami Rosen" <roszenrami@gmail.com>
Subject: Re: Get the IP address of an interface with a given name
Date: Tue, 20 Nov 2007 15:00:48 +0200
Message-ID: <b25312890711200500l862fcafy10c6e08b7072966a@mail.gmail.com>
References: <885896af0711200009idcc8bd9q781888efe84dc49c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Giacomo <delleceste@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:34000 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756876AbXKTNAz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 08:00:55 -0500
Received: by nf-out-0910.google.com with SMTP id g13so1736269nfb
        for <netdev@vger.kernel.org>; Tue, 20 Nov 2007 05:00:54 -0800 (PST)
In-Reply-To: <885896af0711200009idcc8bd9q781888efe84dc49c@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Giacomo,

  Consider using the dev_get_by_name/() kernel method; this is a
simplified example which works with device named "eth0" :

  struct net_device* device;
  struct in_device* in_dev;
  struct in_ifaddr* if_info;

  device = dev_get_by_name("eth0");
  in_dev = (struct in_device *)device->ip_ptr;
  if_info = in_dev->ifa_list;
	for (;if_info;if_info=if_info->ifa_next)
		{
		if (!(strcmp(if_info->ifa_label,"eth0")))
			{
			printk("if_info->ifa_address=%x\n",if_info->ifa_address);	
			break;
			}
		}


Yous should of course add check for NULL, etc.

Regards,
Rami Rosen


On Nov 20, 2007 10:09 AM, Giacomo <delleceste@gmail.com> wrote:
> Good morning.
>
>  I have written a kernel function which needs to get the IP address of
> an active network interface
>  given its name.
>
>  The actual implementation i have done is like this
>  but i suspect this does not always work.
>  Is there any API already provided by the kernel to do the same?
>
>  Thanks a lot
>
>  Giacomo
>
>  -- actual implementation: ---
>
>  /* returns in *addr the internet address having the name ifname */
>  int get_ifaddr_by_name(const char *ifname, __u32 * addr)
>  {
>         struct net_device *pnet_device;
>         struct in_device *pin_device;
>         struct in_ifaddr* inet_ifaddr;
>
>         read_lock_bh(&dev_base_lock);
>  #if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,22)
>         pnet_device = dev_base;
>  #else
>         pnet_device = first_net_device();
>  #endif
>         while (pnet_device != NULL)
>         {
>                 if ((netif_running(pnet_device))
>                                 && (pnet_device->ip_ptr != NULL)
>                                 && (strcmp(pnet_device->name, ifname) == 0))
>                 {
>                         pin_device =
>                                 (struct in_device *) pnet_device->ip_ptr;
>                         inet_ifaddr = pin_device->ifa_list;
>                         if(inet_ifaddr == NULL)
>                         {
>                                 printk("ifa_list is null!\n");
>                                 break;
>                         }
>                         /* ifa_local: ifa_address is the remote point in ppp */
>                         *addr = (inet_ifaddr->ifa_local);
>                           read_unlock_bh(&dev_base_lock);
>                         return 1;
>                 }
>  #if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,22)
>                 pnet_device = pnet_device->next;
>  #else
>                 pnet_device = next_net_device(pnet_device);
>  #endif
>
>         }
>
>         read_unlock_bh(&dev_base_lock);
>         return -1;              /* address not found! */
>  }
>
> --
> Giacomo S.
> http://www.giacomos.it
>
> - - - - - - - - - - - - - - - - - - - - - -
>
> IPFIREwall (http://www.giacomos.it/ipfire) viene presentato
> all'Universita` degli Studi di Udine, il 28 ottobre, in occasione del
> Linux Day 2006:
> http://iglu.cc.uniud.it/linuxday
>
> - - - - - - - - - - - - - - - - - - - - - -
>
>  . ''  `.
> :   :'    :
>  `.  ` '
>     `- Debian GNU/Linux -- The power of freedom
>         http://www.debian.org
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
