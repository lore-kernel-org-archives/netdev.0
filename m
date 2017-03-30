From: Jarod Wilson <jarod@redhat.com>
Subject: Re: bond procfs hw addr prints
Date: Thu, 30 Mar 2017 13:57:41 -0400
Message-ID: <e14fe219-cc4b-4015-0db3-02ef5e2eecde@redhat.com>
References: <597da6f1-c0fc-ae23-94d1-d0fb3abb3176@redhat.com>
 <10202.1489451284@famine> <8aa4aff4-e1b3-83b5-f453-c6485f540705@redhat.com>
 <88a9205f-363c-a6da-8db7-ee301bc080a1@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59806 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933150AbdC3R5k (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 30 Mar 2017 13:57:40 -0400
In-Reply-To: <88a9205f-363c-a6da-8db7-ee301bc080a1@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-03-13 11:26 PM, Jarod Wilson wrote:
> On 2017-03-13 10:06 PM, Jarod Wilson wrote:
>> On 2017-03-13 8:28 PM, Jay Vosburgh wrote:
>>> Jarod Wilson <jarod@redhat.com> wrote:
>>>
>>>> I've got a bug report for someone using a Intel OPA devices in a
>>>> bond, and
>>>> it appears these devices have a hardware address length of 20,
>>>> opposed to
>>>> the typical 6 on ethernet. When they dump /proc/net/bonding/bondX, it
>>>> only
>>>> prints the first 6 of the address, per %pM and mac_address_string(),
>>>> while
>>>> sysfs for the interface does print the right thing, since it uses
>>>> sysfs_print_mac(), which takes a length argument.
>>>
>>>     This (20 octet MAC length) is true for any Infiniband device.
>>>
>>>> So the question is... What's the best route to take here? Expand %pM to
>>>> support variable length hardware addresses? Use sysfs_* in procfs?
>>>> Reinvent the wheel? Nothing I've tinkered with just yet feels very
>>>> clean,
>>>> on top of not actually working yet. :)
>>>
>>>     sysfs_format_mac (not _print_mac) uses "%*phC", len, addr in its
>>> format string.  Perhaps that format would be a better choice than %pM
>>> for this case?
>>
>> Ah, I'd failed to fully grasp how %phC worked, had actually tried it w/o
>> the * in there, and only the first char of the addr was printing.
>> Working on an updated version that uses %*phC properly, which does look
>> like the way to go here. (Didn't help that I was also looking at an
>> older codebase that didn't have the sysfs_format_mac de-duplication).
>> I'll try to have a tested patch in flight tomorrow.
>
> Hm... One problem I'm seeing: perm_hwaddr[ETH_ALEN],
> partner_system[ETH_ALEN], mac_addr_value[ETH_ALEN]. Looks like just
> about all places where storage for only ETH_ALEN is available needs to
> be adjusted to maybe MAX_ADDR_LEN?
>
> So I have something tested that uses %*phC, but only on ethernet
> hardware so far, and I forsee bad juju for infiniband, because of that
> ETH_ALEN issue...

After some possibly incomplete hacking, I've got an Infiniband bond now 
spewing:

$ cat /proc/net/bonding/bond0
Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)

Bonding Mode: fault-tolerance (active-backup)
Primary Slave: mlx4_ib0 (primary_reselect always)
Currently Active Slave: mlx4_ib0
MII Status: up
MII Polling Interval (ms): 100
Up Delay (ms): 100
Down Delay (ms): 100

Slave Interface: mlx4_ib0
MII Status: up
Speed: Unknown
Duplex: Unknown
Link Failure Count: 0
Permanent HW addr: 
80:00:02:08:fe:80:00:00:00:00:00:00:e4:1d:2d:03:00:1d:67:01
Slave queue ID: 0

I need to do a lot more testing with this set, but basically, I've 
replaced ETH_ALEN with MAX_ADDR_LEN anywhere I can, and added a function 
that takes addr_len as a param for address copies and put that in place 
of ether_addr_copy(), the used %*phC in bond_procfs.c to get the above.

-- 
Jarod Wilson
jarod@redhat.com
