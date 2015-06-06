From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH] net/bonding: fix propagation of user-specified bond MAC
Date: Sat, 6 Jun 2015 15:29:22 +0200
Message-ID: <CABQ03vG1L1TdmmxBNdbCOwHxkNZ5SokYCUhVLHKxp0Z0X9GNvA@mail.gmail.com>
References: <1433543047-34803-1-git-send-email-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org, Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	"open list:BONDING DRIVER" <netdev@vger.kernel.org>
To: Jarod Wilson <jarod@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:33462 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751528AbbFFN3W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Jun 2015 09:29:22 -0400
Received: by iebgx4 with SMTP id gx4so74062321ieb.0
        for <netdev@vger.kernel.org>; Sat, 06 Jun 2015 06:29:22 -0700 (PDT)
In-Reply-To: <1433543047-34803-1-git-send-email-jarod@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 6, 2015 at 12:24 AM, Jarod Wilson <jarod@redhat.com> wrote:
> Its possible for users to specify their own MAC address for a bonded link,
> and this used to work, until sometime in 2013...
>
> First, commit 409cc1f8a changed a condition to set the bond's mac to a
> slave device's, dropping the is_zero_ether_addr() check in favor of using
> bond->dev_addr_from_first.
>
> Next, commit 6c8c4e4c2 added a bond->slave_cnt == 0 condition.
>
> Then, commit 97a1e6396 removed dev_addr_from_first and keyed off of
> bond->dev->addr_assign_type.
>
> The other contitional in the check to call bond_set_dev_addr() has gone
>  through some permutations, finally landing at the following check:
>
>         if (!bond_has_slaves(bond) &&
>             bond->dev->addr_assign_type == NET_ADDR_RANDOM)
>                 bond_set_dev_addr(bond->dev, slave_dev);
>
> When the bond is initially brought up, with no active slaves, it gets
> assigned a random address, and addr_assign_type is set to NET_ADDR_RANDOM.
> Next up though, the user can provide their own MAC, which ultimately calls
> bond_set_mac_address(). However, because addr_assign_type isn't touched,
> the above conditions are still met, and the slave's MAC overwrites the
> user-provided MAC.
>
> The simple fix is to set addr_assign_type = NET_ADDR_SET at the tail end
> of bond_set_mac_address() doing its thing, and user-specified MAC
> addresses no longer get overwritten.
>
> Nb: this is slightly tricky to test on current Fedora, as nmcli seems to
> be braindead when it comes to setting a MAC address for a bond. I can do a
> "nmcli con edit bond0", set ethernet.mac-address "xx:yy:zz:aa:bb:cc", but
> it doesn't ever seem to do anything, and it doesn't persist to the next
> boot. Manual tinkering was required to verify the issue and the fix using
> ip link set commands.
>
> CC: Jay Vosburgh <j.vosburgh@gmail.com>
> CC: Veaceslav Falico <vfalico@gmail.com>
> CC: Andy Gospodarek <gospo@cumulusnetworks.com>
> CC: netdev@vger.kernel.org (open list:BONDING DRIVER)
> Signed-off-by: Jarod Wilson <jarod@redhat.com>
> ---

Hi Jarod,
When I did 97a1e6396, I tested all of these cases successfully and
they still work.
in net/core/dev.c, dev_set_mac_address() we have:
dev->addr_assign_type = NET_ADDR_SET;
So it's actually changed when the user sets the mac and you don't have
to do it in
bond_set_mac_address(). Just to confirm, I tried this just now:
# modprobe bonding
# ip l sh bond0
9: bond0: <NO-CARRIER,BROADCAST,MULTICAST,MASTER,UP> mtu 1500 qdisc
noqueue state DOWN mode DEFAULT group default
    link/ether d2:62:c7:90:93:b9 brd ff:ff:ff:ff:ff:ff
# ip l set dev bond0 address 00:11:22:33:44:55
# ip l sh bond0
9: bond0: <NO-CARRIER,BROADCAST,MULTICAST,MASTER,UP> mtu 1500 qdisc
noqueue state DOWN mode DEFAULT group default
    link/ether 00:11:22:33:44:55 brd ff:ff:ff:ff:ff:ff
# ifenslave bond0 enp6s0
# ip l sh bond0
9: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc
noqueue state UP mode DEFAULT group default
    link/ether 00:11:22:33:44:55 brd ff:ff:ff:ff:ff:ff

The user-specified mac address is kept.

Cheers,
 Nik
