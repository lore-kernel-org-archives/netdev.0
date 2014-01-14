From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 1/2] net: vxlan: when lower dev unregisters
 remove vxlan dev as well
Date: Mon, 13 Jan 2014 18:22:32 -0800
Message-ID: <20140113182232.355f9d20@nehalam.linuxnetplumber.net>
References: <1389634880-4138-1-git-send-email-dborkman@redhat.com>
	<1389634880-4138-2-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:49610 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751315AbaANCWg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 21:22:36 -0500
Received: by mail-pd0-f173.google.com with SMTP id p10so8201215pdj.4
        for <netdev@vger.kernel.org>; Mon, 13 Jan 2014 18:22:36 -0800 (PST)
In-Reply-To: <1389634880-4138-2-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 13 Jan 2014 18:41:19 +0100
Daniel Borkmann <dborkman@redhat.com> wrote:

> We can create a vxlan device with an explicit underlying carrier.
> In that case, when the carrier link is being deleted from the
> system (e.g. due to module unload) we should also clean up all
> created vxlan devices on top of it since otherwise we're in an
> inconsistent state in vxlan device. In that case, the user needs
> to remove all such devices, while in case of other virtual devs
> that sit on top of physical ones, it is usually the case that
> these devices do unregister automatically as well and do not
> leave the burden on the user.
> 
> This work is not necessary when vxlan device was not created with
> a real underlying device, as connections can resume in that case
> when driver is plugged again. But at least for the other cases,
> we should go ahead and do the cleanup on removal.
> 
> We don't register the notifier during vxlan_newlink() here since
> I consider this event rather rare, and therefore we should not
> bloat vxlan's core structure unecessary. Also, we can simply make
> use of unregister_netdevice_many() to batch that. fdb is flushed
> upon ndo_stop().
> 
> E.g. `ip -d link show vxlan13` after carrier removal before
> this patch:
> 
> 5: vxlan13: <BROADCAST,MULTICAST> mtu 1450 qdisc noop state DOWN mode DEFAULT group default
>     link/ether 1e:47:da:6d:4d:99 brd ff:ff:ff:ff:ff:ff promiscuity 0
>     vxlan id 13 group 239.0.0.10 dev 2 port 32768 61000 ageing 300
>                                  ^^^^^
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Since vxlan is running over UDP socket. I wonder if this could be
done better by implementing something equivalent to SO_BINDTODEVICE.

What happens to a user land application which has a UDP socket
and has done SO_BINDTODEVICE and device is removed? Is there an asynchronous
error, can the application recover? Why can't vxlan use the same mechanism?
