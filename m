From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] sunvnet: vnet_start_xmit() must hold a
 refcnt on port.
Date: Wed, 01 Oct 2014 12:05:24 -0700
Message-ID: <1412190324.16704.57.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141001185622.GI17706@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, raghuram.kothakota@oracle.com,
	netdev@vger.kernel.org
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:36332 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751420AbaJATFN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 15:05:13 -0400
Received: by mail-pd0-f171.google.com with SMTP id ft15so700821pdb.30
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2014 12:05:13 -0700 (PDT)
In-Reply-To: <20141001185622.GI17706@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-10-01 at 14:56 -0400, Sowmini Varadhan wrote:
> A vnet_port_remove could be triggered as a result of an ldm-unbind operation
> by the peer, or a module unload, or other changes to the inter-vnet-link
> configuration.  When this is concurrent with vnet_start_xmit(),
> the following sequence could occur
> 
>   thread 1                                    thread 2
> vnet_start_xmit
>  -> tx_port_find
>     spin_lock_irqsave(&vp->lock..)
>     ret = __tx_port_find(..)
>     spin_lock_irqrestore(&vp->lock..)
>                                            vio_remove -> ..
>                                                ->vnet_port_remove
>                                            spin_lock_irqsave(&vp->lock..)
>                                            cleanup
>                                            spin_lock_irqrestore(&vp->lock..)
>                                            kfree(port)
>  /* attempt to use ret will bomb */
> 
> This patch avoids the problem by holding/releasing a refcnt on
> the vnet_port.

Hmpff... This calls for rcu protection here !
