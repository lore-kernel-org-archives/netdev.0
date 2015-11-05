From: William Dauchy <wdauchy@gmail.com>
Subject: Re: [PATCH 1/1] packet: race condition in packet_bind
Date: Thu, 5 Nov 2015 22:20:14 +0100
Message-ID: <CAJ75kXY2WiGYQn7Vs_mEh0xfmiw9D=2WRKEiOkFAXHwMFfL5=A@mail.gmail.com>
References: <20151105161614.9C57658016E@fruggeri-AK-3.18.sjc.aristanetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: edumazet@google.com, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org, noureddine@arista.com, fruggeri@arista.com
To: Francesco Ruggeri <fruggeri@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:34852 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750851AbbKEVUg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2015 16:20:36 -0500
Received: by lbbes7 with SMTP id es7so44782876lbb.2
        for <netdev@vger.kernel.org>; Thu, 05 Nov 2015 13:20:34 -0800 (PST)
In-Reply-To: <20151105161614.9C57658016E@fruggeri-AK-3.18.sjc.aristanetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Francesco,

On Thu, Nov 5, 2015 at 5:16 PM, Francesco Ruggeri
<fruggeri@aristanetworks.com> wrote:
> There is a race conditions between packet_notifier and packet_bind{_spkt}.
>
> It happens if packet_notifier(NETDEV_UNREGISTER) executes between the
> time packet_bind{_spkt} takes a reference on the new netdevice and the
> time packet_do_bind sets po->ifindex.
> In this case the notification can be missed.
> If this happens during a dev_change_net_namespace this can result in the
> netdevice to be moved to the new namespace while the packet_sock in the
> old namespace still holds a reference on it. When the netdevice is later
> deleted in the new namespace the deletion hangs since the packet_sock
> is not found in the new namespace' &net->packet.sklist.
> It can be reproduced with the script below.
>
> This patch makes packet_do_bind check again for the presence of the
> netdevice in the packet_sock's namespace after the synchronize_net
> in unregister_prot_hook.
> More in general it also uses the rcu lock for the duration of the bind
> to stop dev_change_net_namespace/rollback_registered_many from
> going past the synchronize_net following unlist_netdevice, so that
> no NETDEV_UNREGISTER notifications can happen on the new netdevice
> while the bind is executing. In order to do this some code from
> packet_bind{_spkt} is consolidated into packet_do_dev.

I was triggering the same kind of race but was unable to reproduce it reliably.

Tested on both v3.14.x and v4.1.x, looks good to me as well.

Thanks a lot for this work (and the attached test),
-- 
William
