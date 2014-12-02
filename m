From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] rtnetlink: delay RTM_DELLINK notification
 until after ndo_uninit()
Date: Tue, 02 Dec 2014 08:52:40 -0800
Message-ID: <1417539160.5303.73.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1417499650-29176-1-git-send-email-maheshb@google.com>
	 <547DE418.9000309@cumulusnetworks.com>
	 <1417537150.5303.67.camel@edumazet-glaptop2.roam.corp.google.com>
	 <547DEBAC.5000005@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Mahesh Bandewar <maheshb@google.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:42175 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932228AbaLBQwm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 11:52:42 -0500
Received: by mail-ie0-f170.google.com with SMTP id rd18so12121503iec.1
        for <netdev@vger.kernel.org>; Tue, 02 Dec 2014 08:52:42 -0800 (PST)
In-Reply-To: <547DEBAC.5000005@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-12-02 at 08:41 -0800, Roopa Prabhu wrote:

> fair point. But the commit that moved things around was done to handle 
> cases where,
> the ndo_uninit() already sends some notifications to userspace for the 
> changes
> during uninit (example bond driver).
> 
> The only point i was making was that the dellink after the ndo_uninit in 
> your
> case now contains state that was prior to uninit for these drivers.

I think Mahesh forgot to mention your patch probably broke some drivers.

calling rtmsg_ifinfo() after uninit() is probably breaking dummy device,
as it does :

static void dummy_dev_uninit(struct net_device *dev)
{
	free_percpu(dev->dstats);
}

It looks like 'fixing' ipvlan is not going to help.

Instead of checking all drivers for such interesting side effects,
and revert your patch, we had the idea of this solution.
