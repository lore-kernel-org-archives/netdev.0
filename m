From: Toby Corkindale <tjc@wintrmute.net>
Subject: Re: Regression in bonding driver - devices without set_mac
Date: Wed, 4 Nov 2015 18:45:43 +1100
Message-ID: <CABEgq97hxgNJWne48amV9M74VbMaTG7fuxfyRti0qCBFGAW1jg@mail.gmail.com>
References: <CABEgq95FYdt86-KEgkarUr-9g_mHoesV6B7OtrFut4pBR0UGcQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f172.google.com ([209.85.160.172]:35804 "EHLO
	mail-yk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751563AbbKDHpo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2015 02:45:44 -0500
Received: by ykek133 with SMTP id k133so58809535yke.2
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2015 23:45:43 -0800 (PST)
In-Reply-To: <CABEgq95FYdt86-KEgkarUr-9g_mHoesV6B7OtrFut4pBR0UGcQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4 November 2015 at 14:49, Toby Corkindale <tjc@wintrmute.net> wrote:
> Hi,
> I've subscribed to this list to try and sort out a regression in the
> bonding network driver.
> I originally reported this in Dec 2014, as:
> https://bugzilla.kernel.org/show_bug.cgi?id=89161
>
> The bug is still present in the 4.2 Linux kernel.
>
> If you look at the code, here:
> https://github.com/torvalds/linux/commit/f54424412b6b2f64cae4d7c39d981ca14ce0052c
>
> Then you see that the intention is for devices without set_mac support
> to be supported. Although in older code they DID work, and that
> ability died sometime near this commit. And has never returned since.
>
> The code path in current kernels does allow devices through that block
> of code, but it fails somewhere else -- the devices are not
> successfully added as slaves, but the only error printed is the
> warning about not supporting MAC address setting.
>
> Is there anything I can do to try and sort this regression out, with you?
>
> I can explain how to set up two virtual machines with PPPoE client and
> server in order to test, if you like? Or I can try out patches and
> give feedback.
>
> Cheers
> Toby


The following patch fixes the regression, for me, although I suspect
it's not suitable for direct application.
But maybe knowing that it fixes the issue, helps you create something
appropriate?

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 771a449..3f44875 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1460,8 +1460,8 @@ int bond_enslave(struct net_device *bond_dev,
struct net_device *slave_dev
)
       addr.sa_family = slave_dev->type;
       res = dev_set_mac_address(slave_dev, &addr);
       if (res) {
-           netdev_dbg(bond_dev, "Error %d calling set_mac_address\n", res);
-           goto err_restore_mtu;
+           netdev_warn(bond_dev, "Error %d calling set_mac_address\n", res);
       }
   }

diff --git a/drivers/net/bonding/bond_netlink.c
b/drivers/net/bonding/bond_netlink.c
index db760e8..e4ffc94 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -49,9 +49,8 @@ static int bond_fill_slave_info(struct sk_buff *skb,
           slave->link_failure_count))
       goto nla_put_failure;

-   if (nla_put(skb, IFLA_BOND_SLAVE_PERM_HWADDR,
-           slave_dev->addr_len, slave->perm_hwaddr))
-       goto nla_put_failure;
+   nla_put(skb, IFLA_BOND_SLAVE_PERM_HWADDR, slave_dev->addr_len,
slave->perm_hwaddr);

   if (nla_put_u16(skb, IFLA_BOND_SLAVE_QUEUE_ID, slave->queue_id))
       goto nla_put_failure;
