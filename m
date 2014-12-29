From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH] bonding: move ipoib_header_ops to vmlinux
Date: Mon, 29 Dec 2014 13:32:50 -0800
Message-ID: <CAHA+R7M-Nm_R-AaKQ0nX4L3O=BN5_m1v-8sWJSaE_UmGyo8zwA@mail.gmail.com>
References: <1416893768-21369-1-git-send-email-wen.gang.wang@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, linux-rdma@vger.kernel.org
To: Wengang Wang <wen.gang.wang@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f172.google.com ([209.85.216.172]:36107 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752514AbaL2Vcv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2014 16:32:51 -0500
Received: by mail-qc0-f172.google.com with SMTP id m20so10052972qcx.3
        for <netdev@vger.kernel.org>; Mon, 29 Dec 2014 13:32:50 -0800 (PST)
In-Reply-To: <1416893768-21369-1-git-send-email-wen.gang.wang@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 24, 2014 at 9:36 PM, Wengang Wang <wen.gang.wang@oracle.com> wrote:
> When last slave of a bonding master is removed, the bonding then does not work.
> At the time if packet_snd is called against with a master net_device, it calls
> then header_ops->create which points to slave's header_ops. In case the slave
> is ipoib and the module is unloaded, header_ops would point to invalid address.
> Accessing it will cause problem.
> This patch tries to fix this issue by moving ipoib_header_ops to vmlinux to keep
> it valid even when ipoib module is unloaded.
>

I still don't think this is the right way to fix the bug, because
there are other modules which have the same bug, for example,
net/bluetooth/6lowpan.c (unless it can't be enslaved into a bond
of course, I haven't verified). We don't want to move them all
to builtin kernel, do we?

On the other hand, as Jay explained, bonding is probably
the only one which has the problem, why not solve it in bonding?
I mean why do we have to adjust other modules just for bonding?

When its slave device gets removed, some netdev event is sent
to the master, so why not reset the header_ops to ether header ops
up on this event? Something like below (not even compile tested):


diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 184c434..aedccae 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1726,6 +1726,7 @@ static int __bond_release_one(struct net_device *bond_dev,
        if (!bond_has_slaves(bond)) {
                bond_set_carrier(bond);
                eth_hw_addr_random(bond_dev);
+               ether_setup(bond_dev);
        }

        unblock_netpoll_tx();

It should solve more than just your ipoib case.

Last but not least, since you said you saw the crash in packet_snd(),
it would also be interesting to know why packet_snd() still picks this
bond dev after all its slaves are gone, after all it is not a functional
device without any slave (its carrier is off).

Thanks.
