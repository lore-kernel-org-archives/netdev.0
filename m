From: "Vegard Nossum" <vegard.nossum@gmail.com>
Subject: Re: [RFC][-rc9 PATCH] Bluetooth: fix oops in rfcomm
Date: Mon, 14 Jul 2008 08:23:40 +0200
Message-ID: <19f34abd0807132323r3c919aq88ecaf572da765cb@mail.gmail.com>
References: <20080713172318.GA6180@damson.getinternet.no>
	 <a8e1da0807131941n4697cb14g1cfbb0bb3ad74f50@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Soeren Sonnenburg" <kernel@nn7.de>,
	"Marcel Holtmann" <marcel@holtmann.org>,
	"David Woodhouse" <dwmw2@infradead.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Dave Young" <hidave.darkstar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.171]:53278 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752451AbYGNGXm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 02:23:42 -0400
Received: by wf-out-1314.google.com with SMTP id 27so4737399wfd.4
        for <netdev@vger.kernel.org>; Sun, 13 Jul 2008 23:23:40 -0700 (PDT)
In-Reply-To: <a8e1da0807131941n4697cb14g1cfbb0bb3ad74f50@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 14, 2008 at 4:41 AM, Dave Young <hidave.darkstar@gmail.com> wrote:
>> This patch attempts to correct this by only removing the device from the
>> internal rfcomm list of devices at the final unregister, so that the id
>> won't get reused until the device has been completely destructed.
>
> It looks good, I agree with your change.

Thanks for looking!

>        if (IS_ERR(dev->tty_dev)) {
>                err = PTR_ERR(dev->tty_dev);
>                list_del(&dev->list);
>                kfree(dev);
>                return err;
>        }
>
> The list_del need to be protected as well.

After looking at the code once again I wonder if we should not extend
the protection even a bit further. Just below, we have this:

        if (device_create_file(dev->tty_dev, &dev_attr_address) < 0)

..which means that we could theoretically get here, be preempted by
another process which 1. releases the device id, and 2. recreates the
same device id. When we resume execution of the first task,
device_create_file() would be called for a file that already exists.

Should the rfcomm_dev_lock be extended to include protecting these
things as well? It seems somehow wrong, but I am not sure how it
should be done correctly either.


Vegard

-- 
"The animistic metaphor of the bug that maliciously sneaked in while
the programmer was not looking is intellectually dishonest as it
disguises that the error is the programmer's own creation."
	-- E. W. Dijkstra, EWD1036
