From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Soft lockup in sungem on Netra AC200 when switching interface
	up
Date: Sat, 7 Feb 2009 13:24:32 +0100
Message-ID: <20090207122432.GA2822@ami.dom.local>
References: <20090206.220101.239298299.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: itvirta@iki.fi, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f161.google.com ([209.85.218.161]:48299 "EHLO
	mail-bw0-f161.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754043AbZBGMa3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 07:30:29 -0500
Received: by bwz5 with SMTP id 5so239470bwz.13
        for <netdev@vger.kernel.org>; Sat, 07 Feb 2009 04:30:26 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20090206.220101.239298299.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote, On 02/07/2009 07:01 AM:

> From: Ilkka Virta <itvirta@iki.fi>
> Date: Fri, 6 Feb 2009 13:29:02 +0200
> 
>> Looking at gem_do_start() and gem_open(), it seems that the only thing
>> done while opening the device after the request_irq(), is a call to
>> napi_enable().
>>
>> I don't know what the ordering requirements are for the
>> initialization, but I boldly tried to move the napi_enable() call
>> inside gem_do_start() before the link state is checked and interrupts
>> subsequently enabled, and it seems to work for me. Doesn't even break
>> anything too obvious...
>>
>> Any ideas on how this really should be fixed?
> 
> Actually your fix looks good, I'll apply this :-)

Alas it could be not enough. It seems this problem is caused by not
serving interrupts if napi is disabled. This patch added napi_enable()
on one path, but e.g. here:

static int gem_close(struct net_device *dev)
{
        struct gem *gp = netdev_priv(dev);

        mutex_lock(&gp->pm_mutex);

        napi_disable(&gp->napi);

        gp->opened = 0;
        if (!gp->asleep)
                gem_do_stop(dev, 0);
...

similar storm can happen if an interrupt is triggered just after
napi_disable().

Jarek P.
