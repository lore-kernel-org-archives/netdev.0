From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [v2 PATCH] ucc_geth: fix ethtool set ring param bug
Date: Thu, 02 Sep 2010 19:04:59 +0100
Message-ID: <1283450699.2272.18.camel@achroite.uk.solarflarecom.com>
References: <1283305429-8426-1-git-send-email-liang.li@windriver.com>
	 <1283443364-2136-1-git-send-email-liang.li@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: leoli@freescale.com, davem@davemloft.net, avorontsov@ru.mvista.com,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Liang Li <liang.li@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.covadwireless.com ([216.237.6.30]:41984 "EHLO
	smtp.covadwireless.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754446Ab0IBSFG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 14:05:06 -0400
Received: from mail.nextweb.net (mail.nextweb.net [216.237.6.33])
	by smtp.covadwireless.com (Spam & Virus Firewall) with ESMTP id 8B92B4AC3F7
	for <netdev@vger.kernel.org>; Thu,  2 Sep 2010 11:05:04 -0700 (PDT)
Received: from mail.nextweb.net (mail.nextweb.net [216.237.6.33]) by smtp.covadwireless.com with ESMTP id wptNQ4bme7Imi5Fl for <netdev@vger.kernel.org>; Thu, 02 Sep 2010 11:05:04 -0700 (PDT)
Received: from unknown (HELO exchange.solarflare.com) ([216.237.3.220])
          (envelope-sender <bhutchings@solarflare.com>)
          by mail.nextweb.net (qmail-ldap-1.03) with SMTP
          for <netdev@vger.kernel.org>; 2 Sep 2010 18:05:02 -0000
In-Reply-To: <1283443364-2136-1-git-send-email-liang.li@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-09-03 at 00:02 +0800, Liang Li wrote:
> It's common sense that when we should do change to driver ring
> desc/buffer etc only after 'stop/shutdown' the device. When we
> do change while devices/driver is running, kernel oops occur:
[...]
> +		printk(KERN_INFO "Reactivating interface %s.\n", netdev->name);
> +		ret = ucc_geth_open(netdev);
> +		if (ret) {
> +			printk(KERN_WARNING "uec_set_ringparam: set ring param for running"
> +					" interface %s failed. Please try again.\n", netdev->name);
> +			dev_close(netdev);
[...]

If ucc_geth_open() failed you MUST NOT call ucc_geth_close(), but that
is what dev_close() is going to do.  But the device is still flagged as
running so 'ifconfig down' is going to call dev_close() as well.  There
is no way out.

This is why I said you must call dev_close() and then dev_open()
instead.  Then if dev_open() fails, just print the error, e.g.:

               dev_close(netdev);
               ret = dev_open(netdev);
               if (ret)
                       netdev_err(netdev,
                                  "uec_set_ringparam: failed to restart"
                                  " interface with new ring parameters\n");

(And I think this really is a serious error, hence the 'err' rather than
'warning' severity.)

(By the way, I noticed there are other places where ucc_geth_close() and
ucc_geth_open() are called, without error checking.  These are also
bugs, but that doesn't justify adding new bugs.)

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

