From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 0/1] netvsc: another VF datapath fix
Date: Tue, 8 Aug 2017 08:29:27 -0700
Message-ID: <20170808082927.128362aa@xeon-e3>
References: <20170807183000.10827-1-sthemmin@microsoft.com>
        <87ziba9mwj.fsf@vitty.brq.redhat.com>
        <20170808081506.38bea86c@xeon-e3>
        <87shh29j70.fsf@vitty.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com,
        devel@linuxdriverproject.org, netdev@vger.kernel.org
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:37046 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752070AbdHHP3a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 11:29:30 -0400
Received: by mail-pg0-f49.google.com with SMTP id y129so16165669pgy.4
        for <netdev@vger.kernel.org>; Tue, 08 Aug 2017 08:29:30 -0700 (PDT)
In-Reply-To: <87shh29j70.fsf@vitty.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 08 Aug 2017 17:24:03 +0200
Vitaly Kuznetsov <vkuznets@redhat.com> wrote:

> Stephen Hemminger <stephen@networkplumber.org> writes:
> 
> > On Tue, 08 Aug 2017 16:03:56 +0200
> > Vitaly Kuznetsov <vkuznets@redhat.com> wrote:
> >  
> >> Stephen Hemminger <stephen@networkplumber.org> writes:
> >>   
> >> > Previous fix was incomplete.
> >> >    
> >> 
> >> Not really related to this patch series (which btw fixes my issue,
> >> thanks!), but I found one addition issue. Systemd fails to rename VF
> >> interface:
> >> 
> >>  kernel: mlx4_core 0002:00:02.0 eth2: joined to eth1
> >>  kernel: hv_netvsc 33b7a6f9-6736-451f-8fce-b382eaa50bee eth1: VF registering: eth2
> >>  kernel: hv_netvsc 33b7a6f9-6736-451f-8fce-b382eaa50bee eth1: Data path switched to VF: eth2
> >>  kernel: mlx4_en: eth2: Link Up
> >>  NetworkManager[750]: <info>  [1502200557.0821] device (eth2): link connected
> >>  NetworkManager[750]: <info>  [1502200557.1004] manager: (eth2): new Ethernet device (/org/freedesktop/NetworkManager/Devices/6)
> >>  systemd-udevd[6942]: Error changing net interface name 'eth2' to 'enP2p0s2': Device or resource busy
> >>  systemd-udevd[6942]: could not rename interface '6' from 'eth2' to 'enP2p0s2': Device or resource busy
> >> 
> >> With some debug added I figured out what's wrong: __netvsc_vf_setup()
> >> does dev_open() which sets IFF_UP flag on the interface. When systemd
> >> tries to rename the interface we get into dev_change_name() and this
> >> fails with -EBUSY when (dev->flags & IFF_UP).
> >> 
> >> The issue is of less importance as we're not supposed to configure VF
> >> interface now. However, we may still want to get a stable name for it.
> >> 
> >> Any idea how this can be fixed?  
> >
> > The problem is Network Manager should ignore the VF device. I don't run NM on these
> > interfaces because it causes more issues than it helps (dueling userspace).
> >
> > The driver needs to have slave track the master interface. Relying on userspace
> > to bring interface up leads to all the issues the bonding script had.
> >
> > One option would be to delay the work of bringing up the slave device to allow
> > small window for renaming to run.  
> 
> Actually, I tried removing 'if (dev->flags & IFF_UP)' check from
> dev_change_name() and everything seems to work fine. The history of this
> code predates git so I have no idea why it's forbiden to change names of
> IFF_UP interfaces... I can send an RFC removing the check to figure out
> the truth :-)

That only works because NM by default brings everything up.
Many users don't use NM on servers.
