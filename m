From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/1] net: dsa: replacing the hard-coded sized array "dsa_switch"
 by dynamic one
Date: Tue, 02 Dec 2014 12:40:33 -0800
Message-ID: <547E23C1.2040007@gmail.com>
References: <547DD1C6.2090304@nexvision.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Andrey Volkov <andrey.volkov@nexvision.fr>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:57293 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932814AbaLBUkk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 15:40:40 -0500
Received: by mail-pa0-f41.google.com with SMTP id rd3so14268497pab.0
        for <netdev@vger.kernel.org>; Tue, 02 Dec 2014 12:40:40 -0800 (PST)
In-Reply-To: <547DD1C6.2090304@nexvision.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/12/14 06:50, Andrey Volkov wrote:
> Hello,
> 
> In time of developing one of our devices (with huge, more then 6, number of onboard switches),
> I've bumped with this ancient, I hope, restriction in the 'struct dsa_switch_tree' definition. 
> So this simple patch remove this restriction and make dsa_switch_tree more scalable for 
> the "usual" 1-2 switches configuration too.

Sounds reasonable to me, you probably want to resubmit and trim the
"Hello" form your commit message.

> 
> P.S. I've plans to fix hardcoded number of ports too, but it is not so easy as with number of switches.
> So if someone have any objections/suggestions I'll happy to discuss them.

I think the number of ports in a switch is something that should come
from the switch driver, and eventually intersected with what the
platform configuration has provided.

The difficulty is in case of sparse port number allocation because you
still want to allocate e.g: 6 ports even though Port 0 and 5 are used, I
don't think we want to introduce a logical to physical mapping, that
would be too error prone.

> 
> Signed-off-by: Andrey Volkov <andrey.volkov@nexvision.fr>                                                                                                                                                                                    
> ---                                                                                                                                                                                                                                          
>  include/net/dsa.h |    3 +--                                                                                                                                                                                                                
>  net/dsa/dsa.c     |    7 +++----                                                                                                                                                                                                            
>  2 files changed, 4 insertions(+), 6 deletions(-)                                                                                                                                                                                            
>                                                                                                                                                                                                                                              
> diff --git a/include/net/dsa.h b/include/net/dsa.h                                                                                                                                                                                           
> index ed3c34b..733db2e 100644                                                                                                                                                                                                                
> --- a/include/net/dsa.h
> +++ b/include/net/dsa.h
> @@ -28,7 +28,6 @@ enum dsa_tag_protocol {
>         DSA_TAG_PROTO_BRCM,
>  };
>  
> -#define DSA_MAX_SWITCHES       4
>  #define DSA_MAX_PORTS          12
>  
>  struct dsa_chip_data {
> @@ -117,7 +116,7 @@ struct dsa_switch_tree {
>         /*
>          * Data for the individual switch chips.
>          */
> -       struct dsa_switch       *ds[DSA_MAX_SWITCHES];
> +       struct dsa_switch       *ds[];
>  };
>  
>  struct dsa_switch {
> diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
> index 322c778..c081a19 100644
> --- a/net/dsa/dsa.c
> +++ b/net/dsa/dsa.c
> @@ -604,8 +604,6 @@ static int dsa_of_probe(struct platform_device *pdev)
>         pdev->dev.platform_data = pd;
>         pd->netdev = &ethernet_dev->dev;
>         pd->nr_chips = of_get_child_count(np);
> -       if (pd->nr_chips > DSA_MAX_SWITCHES)
> -               pd->nr_chips = DSA_MAX_SWITCHES;
>  
>         pd->chip = kcalloc(pd->nr_chips, sizeof(struct dsa_chip_data),
>                            GFP_KERNEL);
> @@ -717,7 +715,7 @@ static int dsa_probe(struct platform_device *pdev)
>                 pd = pdev->dev.platform_data;
>         }
>  
> -       if (pd == NULL || pd->netdev == NULL)
> +       if (pd == NULL || pd->netdev == NULL || pd->nr_chips == 0)
>                 return -EINVAL;
>  
>         dev = dev_to_net_device(pd->netdev);
> @@ -732,7 +730,8 @@ static int dsa_probe(struct platform_device *pdev)
>                 goto out;
>         }
>  
> -       dst = kzalloc(sizeof(*dst), GFP_KERNEL);
> +       dst = kzalloc(sizeof(*dst) +
> +                       sizeof(struct dsa_switch *) * pd->nr_chips, GFP_KERNEL);
>         if (dst == NULL) {
>                 dev_put(dev);
>                 ret = -ENOMEM;
> 
