From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] net: vxlan: when lower dev unregisters remove
 vxlan dev as well
Date: Fri, 10 Jan 2014 11:10:56 -0800
Message-ID: <20140110111056.3dd5ad6f@nehalam.linuxnetplumber.net>
References: <1389358907-19885-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:44547 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751258AbaAJTK7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 14:10:59 -0500
Received: by mail-pb0-f51.google.com with SMTP id up15so4792801pbc.24
        for <netdev@vger.kernel.org>; Fri, 10 Jan 2014 11:10:58 -0800 (PST)
In-Reply-To: <1389358907-19885-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 10 Jan 2014 14:01:47 +0100
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
> `ip -d link show vxlan13` after carrier removal before this patch:
> 
> 5: vxlan13: <BROADCAST,MULTICAST> mtu 1450 qdisc noop state DOWN mode DEFAULT group default
>     link/ether 1e:47:da:6d:4d:99 brd ff:ff:ff:ff:ff:ff promiscuity 0
>     vxlan id 13 group 239.0.0.10 dev 2 port 32768 61000 ageing 300
>                                  ^^^^^
> While at it, we should also use vxlan_dellink() handler in
> vxlan_exit_net() as otherwise we seem to leak memory on module
> unload since only half of the cleanup is being done.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

The issue is generic to all tunnels
