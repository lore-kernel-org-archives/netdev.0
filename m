From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH] net/bonding: fix propagation of user-specified bond MAC
Date: Tue, 9 Jun 2015 14:49:44 +0200
Message-ID: <CABQ03vFDsremr4+uJgbb3-ZtnVQUEpUpfcK-Rkje7VaPp6fJkg@mail.gmail.com>
References: <1433543047-34803-1-git-send-email-jarod@redhat.com>
	<CABQ03vG1L1TdmmxBNdbCOwHxkNZ5SokYCUhVLHKxp0Z0X9GNvA@mail.gmail.com>
	<55738E41.1020702@redhat.com>
	<5575E828.9060900@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org, Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	"open list:BONDING DRIVER" <netdev@vger.kernel.org>
To: Jarod Wilson <jarod@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:32786 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754010AbbFIMtp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2015 08:49:45 -0400
Received: by igbpi8 with SMTP id pi8so12004585igb.0
        for <netdev@vger.kernel.org>; Tue, 09 Jun 2015 05:49:44 -0700 (PDT)
In-Reply-To: <5575E828.9060900@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 8, 2015 at 9:08 PM, Jarod Wilson <jarod@redhat.com> wrote:
> On 6/6/2015 8:20 PM, Jarod Wilson wrote:
>>
>> On 6/6/2015 9:29 AM, Nikolay Aleksandrov wrote:
>>>
>>> On Sat, Jun 6, 2015 at 12:24 AM, Jarod Wilson <jarod@redhat.com> wrote:
>>>>
>>>> Its possible for users to specify their own MAC address for a bonded
>>>> link,
>>>> and this used to work, until sometime in 2013...
>>>>
>>>> First, commit 409cc1f8a changed a condition to set the bond's mac to a
>>>> slave device's, dropping the is_zero_ether_addr() check in favor of
>>>> using
>>>> bond->dev_addr_from_first.
>>>>
>>>> Next, commit 6c8c4e4c2 added a bond->slave_cnt == 0 condition.
>>>>
>>>> Then, commit 97a1e6396 removed dev_addr_from_first and keyed off of
>>>> bond->dev->addr_assign_type.
>>>>
>>>> The other contitional in the check to call bond_set_dev_addr() has gone
>>>>   through some permutations, finally landing at the following check:
>>>>
>>>>          if (!bond_has_slaves(bond) &&
>>>>              bond->dev->addr_assign_type == NET_ADDR_RANDOM)
>>>>                  bond_set_dev_addr(bond->dev, slave_dev);
>>>>
>>>> When the bond is initially brought up, with no active slaves, it gets
>>>> assigned a random address, and addr_assign_type is set to
>>>> NET_ADDR_RANDOM.
>>>> Next up though, the user can provide their own MAC, which ultimately
>>>> calls
>>>> bond_set_mac_address(). However, because addr_assign_type isn't touched,
>>>> the above conditions are still met, and the slave's MAC overwrites the
>>>> user-provided MAC.
>>>>
>>>> The simple fix is to set addr_assign_type = NET_ADDR_SET at the tail end
>>>> of bond_set_mac_address() doing its thing, and user-specified MAC
>>>> addresses no longer get overwritten.
>>>>
>>>> Nb: this is slightly tricky to test on current Fedora, as nmcli seems to
>>>> be braindead when it comes to setting a MAC address for a bond. I can
>>>> do a
>>>> "nmcli con edit bond0", set ethernet.mac-address "xx:yy:zz:aa:bb:cc",
>>>> but
>>>> it doesn't ever seem to do anything, and it doesn't persist to the next
>>>> boot. Manual tinkering was required to verify the issue and the fix
>>>> using
>>>> ip link set commands.
>>>>
>>>> CC: Jay Vosburgh <j.vosburgh@gmail.com>
>>>> CC: Veaceslav Falico <vfalico@gmail.com>
>>>> CC: Andy Gospodarek <gospo@cumulusnetworks.com>
>>>> CC: netdev@vger.kernel.org (open list:BONDING DRIVER)
>>>> Signed-off-by: Jarod Wilson <jarod@redhat.com>
>>>> ---
>>>
>>>
>>> Hi Jarod,
>>> When I did 97a1e6396, I tested all of these cases successfully and
>>> they still work.
>>> in net/core/dev.c, dev_set_mac_address() we have:
>>> dev->addr_assign_type = NET_ADDR_SET;
>>> So it's actually changed when the user sets the mac and you don't have
>>> to do it in
>>> bond_set_mac_address(). Just to confirm, I tried this just now:
>>> # modprobe bonding
>>> # ip l sh bond0
>>> 9: bond0: <NO-CARRIER,BROADCAST,MULTICAST,MASTER,UP> mtu 1500 qdisc
>>> noqueue state DOWN mode DEFAULT group default
>>>      link/ether d2:62:c7:90:93:b9 brd ff:ff:ff:ff:ff:ff
>>> # ip l set dev bond0 address 00:11:22:33:44:55
>>> # ip l sh bond0
>>> 9: bond0: <NO-CARRIER,BROADCAST,MULTICAST,MASTER,UP> mtu 1500 qdisc
>>> noqueue state DOWN mode DEFAULT group default
>>>      link/ether 00:11:22:33:44:55 brd ff:ff:ff:ff:ff:ff
>>> # ifenslave bond0 enp6s0
>>> # ip l sh bond0
>>> 9: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc
>>> noqueue state UP mode DEFAULT group default
>>>      link/ether 00:11:22:33:44:55 brd ff:ff:ff:ff:ff:ff
>>>
>>> The user-specified mac address is kept.
>>
>>
>> Hrm. I was definitely able to make it fail. I may have been using a
>> combination of ip link set and nmcli though, and the bug could be in
>> nmcli, since it seems to completely lose track of a configured mac for a
>> bond. It definitely reproduces 100% of the time with an older kernel you
>> used to work on. ;)
>>
>> It may require a specific chain of commands to reproduce, so I think its
>> still probably a good idea to set _SET in bond_set_mac_address() for the
>> sake of completeness/consistency.
>>
>> I'll see if I can manage to re-reproduce it again with exact chain of
>> commands on Monday...
>
>
> I'll just wipe the egg off my face now. I can't come up with a sequence that
> fails if I don't involve nmcli.
>
> It *does* fail on some older kernels with bonding driver backports, but
> they're lacking some assignments of NET_ADDR_SET (will fix that), and I keep
> getting the eth0 address when networkmangler brings up the link, but I think
> that can be attributed to nm not actually paying attention to a
> user-specified mac address.
>
> So I guess this really does nothing in practice... (Even with this change,
> nmcli continues to ignore a user-specified ethernet.mac-address). But then
> why do the address copy in bond_set_mac_address() at all? Remnants of the
> past?
>
>
> --
> Jarod Wilson
> jarod@redhat.com

We need to copy the mac address in the ndo_set_mac_address() function because
dev_set_mac_address() doesn't do it for us.
