From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/3 v7] drivers: net: ethernet: qualcomm:
 rmnet: Initial implementation
Date: Thu, 24 Aug 2017 12:15:59 -0700 (PDT)
Message-ID: <20170824.121559.882635807428126397.davem@davemloft.net>
References: <1503355019-12236-1-git-send-email-subashab@codeaurora.org>
        <1503355019-12236-4-git-send-email-subashab@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fengguang.wu@intel.com, dcbw@redhat.com,
        jiri@resnulli.us, stephen@networkplumber.org,
        David.Laight@ACULAB.COM, marcel@holtmann.org
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50460 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751168AbdHXTQB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 15:16:01 -0400
In-Reply-To: <1503355019-12236-4-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Date: Mon, 21 Aug 2017 16:36:59 -0600

> diff --git a/drivers/net/ethernet/qualcomm/rmnet/Makefile b/drivers/net/ethernet/qualcomm/rmnet/Makefile
> new file mode 100644
> index 0000000..1c43e2f
> --- /dev/null
> +++ b/drivers/net/ethernet/qualcomm/rmnet/Makefile
> @@ -0,0 +1,12 @@
> +#
> +# Makefile for the RMNET module
> +#
> +
> +rmnet-y		 := rmnet_config.o
> +rmnet-y		 += rmnet_vnd.o
> +rmnet-y		 += rmnet_handlers.o
> +rmnet-y		 += rmnet_map_data.o
> +rmnet-y		 += rmnet_map_command.o
> +obj-$(CONFIG_RMNET) += rmnet.o
> +
> +CFLAGS_rmnet.o := -I$(src)

You do not need this CFLAGS rule, the local include files are included
using "" double quotes so it uses the local directory always.

> +static void rmnet_free_later(struct work_struct *work)
> +{
> +	struct rmnet_free_work *fwork;
> +
> +	fwork = container_of(work, struct rmnet_free_work, work);
> +
> +	rtnl_lock();
> +	rmnet_delink(fwork->rmnet_dev, NULL);
> +	rtnl_unlock();
> +
> +	kfree(fwork);
> +}

This is racy and doesn't work properly.

When you schedule this work, the RTNL mutex is dropped.  Meanwhile
another request can come in the associate this device.

Your work function will still run and erroneously unlink the object.

Furthermore, during this time that the RTNL mutex is dropped, people
will see the unassociated device in the lists.

You have to atomically remove the object from all possible locations
which provide external visibility of that object, before the RTNL
mutex is dropped.

So you can defer the freeing, but you cannot defer the unlink
operation.

You probably need to move to RCU as well in order for all of this to
work properly since scans of the lists occur in the data path which
is completely asynchronous and not protected by the RTNL mutex.
