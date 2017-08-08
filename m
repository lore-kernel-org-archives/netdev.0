From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH net-next 0/1] netvsc: another VF datapath fix
Date: Tue, 08 Aug 2017 17:24:03 +0200
Message-ID: <87shh29j70.fsf@vitty.brq.redhat.com>
References: <20170807183000.10827-1-sthemmin@microsoft.com>
        <87ziba9mwj.fsf@vitty.brq.redhat.com>
        <20170808081506.38bea86c@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain
Cc: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com,
        devel@linuxdriverproject.org, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58226 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752017AbdHHPYG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 8 Aug 2017 11:24:06 -0400
In-Reply-To: <20170808081506.38bea86c@xeon-e3> (Stephen Hemminger's message of
        "Tue, 8 Aug 2017 08:15:06 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <stephen@networkplumber.org> writes:

> On Tue, 08 Aug 2017 16:03:56 +0200
> Vitaly Kuznetsov <vkuznets@redhat.com> wrote:
>
>> Stephen Hemminger <stephen@networkplumber.org> writes:
>> 
>> > Previous fix was incomplete.
>> >  
>> 
>> Not really related to this patch series (which btw fixes my issue,
>> thanks!), but I found one addition issue. Systemd fails to rename VF
>> interface:
>> 
>>  kernel: mlx4_core 0002:00:02.0 eth2: joined to eth1
>>  kernel: hv_netvsc 33b7a6f9-6736-451f-8fce-b382eaa50bee eth1: VF registering: eth2
>>  kernel: hv_netvsc 33b7a6f9-6736-451f-8fce-b382eaa50bee eth1: Data path switched to VF: eth2
>>  kernel: mlx4_en: eth2: Link Up
>>  NetworkManager[750]: <info>  [1502200557.0821] device (eth2): link connected
>>  NetworkManager[750]: <info>  [1502200557.1004] manager: (eth2): new Ethernet device (/org/freedesktop/NetworkManager/Devices/6)
>>  systemd-udevd[6942]: Error changing net interface name 'eth2' to 'enP2p0s2': Device or resource busy
>>  systemd-udevd[6942]: could not rename interface '6' from 'eth2' to 'enP2p0s2': Device or resource busy
>> 
>> With some debug added I figured out what's wrong: __netvsc_vf_setup()
>> does dev_open() which sets IFF_UP flag on the interface. When systemd
>> tries to rename the interface we get into dev_change_name() and this
>> fails with -EBUSY when (dev->flags & IFF_UP).
>> 
>> The issue is of less importance as we're not supposed to configure VF
>> interface now. However, we may still want to get a stable name for it.
>> 
>> Any idea how this can be fixed?
>
> The problem is Network Manager should ignore the VF device. I don't run NM on these
> interfaces because it causes more issues than it helps (dueling userspace).
>
> The driver needs to have slave track the master interface. Relying on userspace
> to bring interface up leads to all the issues the bonding script had.
>
> One option would be to delay the work of bringing up the slave device to allow
> small window for renaming to run.

Actually, I tried removing 'if (dev->flags & IFF_UP)' check from
dev_change_name() and everything seems to work fine. The history of this
code predates git so I have no idea why it's forbiden to change names of
IFF_UP interfaces... I can send an RFC removing the check to figure out
the truth :-)

-- 
  Vitaly
