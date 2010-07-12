From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] depca: fix leaks
Date: Sun, 11 Jul 2010 18:13:00 -0700 (PDT)
Message-ID: <20100711.181300.58435799.davem@davemloft.net>
References: <1278678986-7725-1-git-send-email-segooon@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, jpirko@redhat.com,
	joe@perches.com, shemminger@vyatta.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: segooon@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33093
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754491Ab0GLBMp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jul 2010 21:12:45 -0400
In-Reply-To: <1278678986-7725-1-git-send-email-segooon@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kulikov Vasiliy <segooon@gmail.com>
Date: Fri,  9 Jul 2010 16:36:25 +0400

> Since some of xxx_register_driver() can return error we must continue
> with already registered drivers. If any of xxx_register_driver()
> succeeded or depca_platform_probe() found any device then
> depca_module_init() returns ok. In depca_module_exit() we must
> unregister only registered drivers.
> 
> Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>

Driver registry should succeed except in cases that would indicate a
serious driver bug, such as trying to register the same driver twice.

Therefore if any registry fails, we should fail the entire probe.

This is the scheme used in just about any driver I've had any
involvement in, see for example drivers/net/niu.c:

--------------------
#ifdef CONFIG_SPARC64
	err = of_register_driver(&niu_of_driver, &of_bus_type);
#endif

	if (!err) {
		err = pci_register_driver(&niu_pci_driver);
#ifdef CONFIG_SPARC64
		if (err)
			of_unregister_driver(&niu_of_driver);
#endif
	}

	return err;
--------------------

Please do something similar here in depca, thanks.
