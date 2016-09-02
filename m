From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] bonding: Fix bonding crash
Date: Fri, 02 Sep 2016 07:45:55 -0700
Message-ID: <1472827555.5439.22.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1472793514-31850-1-git-send-email-mahesh@bandewar.net>
         <a045ae10-e002-6658-575b-109e66056d5f@cumulusnetworks.com>
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
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33253 "EHLO
        mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751454AbcIBOp6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 10:45:58 -0400
Received: by mail-pa0-f44.google.com with SMTP id cy9so41096355pac.0
        for <netdev@vger.kernel.org>; Fri, 02 Sep 2016 07:45:57 -0700 (PDT)
In-Reply-To: <a045ae10-e002-6658-575b-109e66056d5f@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-09-02 at 08:30 -0600, David Ahern wrote:

> This check duplicates what netdev_rx_handler_register does. Why not
> move the call to netdev_rx_handler_register here and then call
> unregister on failure paths?

As soon as you call netdev_rx_handler_register(), incoming packets will
hit your driver and we'll likely crash since the enslaving is not done
yet.

Really think about RCU, we do rcu_assign_pointer() because we want all
prior changes being committed to memory before 'enabling' readers to see
the updated rcu protected pointer.

There are 9 call sites where netdev_rx_handler_register() is used.

We can get rid of the extra check in netdev_rx_handler_register() once
all of them are using netdev_is_rx_handler_busy()

Since this patch takes care of bonding only, we need to keep the
existing check in netdev_rx_handler_register()

Anyway, we are speaking of control function, an extra check is simply
safer, like all the ASSERT_RTNL() we do have...
