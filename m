From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH] bonding: clear header_ops when last slave detached (v2)
Date: Thu, 20 Nov 2014 14:53:05 -0800
Message-ID: <23563.1416523985@famine>
References: <1416374292-10993-1-git-send-email-wen.gang.wang@oracle.com> <1416375565.14060.43.camel@edumazet-glaptop2.roam.corp.google.com> <546C4022.5010509@oracle.com> <CAHA+R7OyA_V149bpE8qUgG9epU-5UG8cf=zOgh5ZXVB3ZFZHUw@mail.gmail.com> <1416465685.8629.15.camel@edumazet-glaptop2.roam.corp.google.com> <CAHA+R7PKRbBNwfUWRAsVHQreKsGXBc8CHorZRuyCfvwL4O=y+g@mail.gmail.com> <1416516104.8629.39.camel@edumazet-glaptop2.roam.corp.google.com> <CAHA+R7Me4zPdGpeQVHFLLGVq=4cVar09jQFyjA81nxF_Fmuppw@mail.gmail.com> <1416521035.8629.49.camel@edumazet-glaptop2.roam.corp.google.com> <CAHA+R7P9XhGQZXFy6frxOyZJ4rX_MdVgY3kAPE1_wDNcvYd_yA@mail.gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Wengang <wen.gang.wang@oracle.com>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:59282 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756236AbaKTWxL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2014 17:53:11 -0500
In-reply-to: <CAHA+R7P9XhGQZXFy6frxOyZJ4rX_MdVgY3kAPE1_wDNcvYd_yA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <cwang@twopensource.com> wrote:

>Also, no one seems to care about my previous question:
>why only bonding has the problem?

	Bonding has the problem because it stashes a pointer to a data
structure (the header_ops) from another module, and when that module is
unloaded the dangling pointer may be dereferenced if it's not either
cleared or made to never go away.

	Setting the bonding->header_ops to NULL (to avoid the current
problem with pktgen) has a race in dev_hard_header between where the
header_ops pointer is checked and where the ->create function is called.

	This pointer business is the main reason the bonding path for
"not ARPHRD_ETHER" (i.e., ipoib) has extra complexity in the open/close
path, e.g.,

bond_slave_netdev_event():
[...]
        switch (event) {
        case NETDEV_UNREGISTER:
                if (bond_dev->type != ARPHRD_ETHER)
                        bond_release_and_destroy(bond_dev, slave_dev);
                else
                        bond_release(bond_dev, slave_dev);

	If the ipoib ops were static in vmlinux, that would resolve the
pktgen problem, and also may eliminate the need for some of the ugly
bits like what I've pasted in above.

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
