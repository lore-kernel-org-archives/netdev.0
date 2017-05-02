From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v4 00/12] Fix possbile memleaks when fail to
 register_netdevice
Date: Tue, 02 May 2017 15:30:29 -0400 (EDT)
Message-ID: <20170502.153029.1605231216574026914.davem@davemloft.net>
References: <cover.1493699451.git.gfree.wind@foxmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, mareklindner@neomailbox.ch,
        sw@simonwunderlich.de, a@unstable.cc, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        netdev@vger.kernel.org
To: gfree.wind@foxmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53294 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750888AbdEBTac (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 15:30:32 -0400
In-Reply-To: <cover.1493699451.git.gfree.wind@foxmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: gfree.wind@foxmail.com
Date: Tue,  2 May 2017 13:58:42 +0800

> These following drivers allocate kinds of resources in its ndo_init
> func, free some of them or all in the destructor func. Then there is
> one memleak that some errors happen after register_netdevice invokes
> the ndo_init callback. Because only the ndo_uninit callback is invoked
> in the error handler of register_netdevice, but destructor not.
> 
> In my original approach, I tried to free the resources in the newlink
> func when fail to register_netdevice, like destructor did except not
> free the net_dev. This method is not good when destructor is changed,
> and the memleak could be not fixed when there is no newlink callback.
> 
> Now create one new func used to free the resources in the destructor,
> and the ndo_uninit func also could invokes it when fail to register
> the net_device by comparing the dev->reg_state with NETREG_UNINITIALIZED.
> If there is no existing ndo_uninit, just add one.
> 
> This solution doesn't only make sure free all resources in any case,
> but also follows the original desgin that some resources could be kept
> until the destructor executes normally after register the device
> successfully.

I want to think about this some more.

It is really unfortunate that resources are allocated strictly from
the ndo_init() yet released in two different callbacks which are
invoked only in certain (different) situations.

Just the fact that we have to make an internal netdev state test
in the ndo_uninit callback to get this right is a big red flag
to me.
