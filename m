From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] bonding: Fix bonding crash
Date: Fri, 02 Sep 2016 08:21:58 -0700
Message-ID: <1472829718.5439.29.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1472793514-31850-1-git-send-email-mahesh@bandewar.net>
         <a045ae10-e002-6658-575b-109e66056d5f@cumulusnetworks.com>
         <1472827555.5439.22.camel@edumazet-glaptop3.roam.corp.google.com>
         <94a399f3-72b1-8895-b54f-c7d03878327e@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Mahesh Bandewar <mahesh@bandewar.net>,
        Jay Vosburgh <j.vosburgh@gmail.com>,
        Andy Gospodarek <gospo@cumulusnetworks.com>,
        Veaceslav Falico <vfalico@gmail.com>,
        David Miller <davem@davemloft.net>,
        Mahesh Bandewar <maheshb@google.com>,
        Eric Dumazet <edumazet@google.com>,
        netdev <netdev@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:33253 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932111AbcIBPWB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 11:22:01 -0400
Received: by mail-pf0-f170.google.com with SMTP id g202so20272470pfb.0
        for <netdev@vger.kernel.org>; Fri, 02 Sep 2016 08:22:00 -0700 (PDT)
In-Reply-To: <94a399f3-72b1-8895-b54f-c7d03878327e@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-09-02 at 08:57 -0600, David Ahern wrote:

> I hit this same problem yesterday but with the bridge. I forgot I had
> a macvlan device on an interface and tried to enslave it to a bridge.
> It failed with EBUSY without crashing the kernel so it is one example
> that handles the conflict, and the bridge also calls the register
> before the enslaving is done.
> 

Sure, some netdev_rx_handler_register() users are simpler than bonding,
this was the point Jiri raised. Hey guys just use team instead of
bonding ;)

If you carefully look at bridge code, you'll find other kind of errors
for sure ;)

For example, should dev_disable_lro() be called before or after
netdev_rx_handler_register()  ? ;)

Mahesh proposal allows for simplification, since one level can be
removed from the error rollback chain.

Ideally the netdev_rx_handler_register() should be called only when no
further errors can be detected in the 'enslaving' process, otherwise
some live packets could come and be incorrectly processed/dropped by a
not fully initialized driver.

So it is a chicken and egg problem, if you allow
netdev_rx_handler_register() to return an error, while it is so easy
to early check what could go wrong with it.
