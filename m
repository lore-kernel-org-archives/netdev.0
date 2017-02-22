From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] l2tp: Avoid schedule while atomic in exit_net
Date: Wed, 22 Feb 2017 16:00:22 -0500 (EST)
Message-ID: <20170222.160022.281370505743926385.davem@davemloft.net>
References: <20170222015949.18641-1-ridge.kennedy@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ridge.kennedy@alliedtelesis.co.nz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43272 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754377AbdBVVAY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 16:00:24 -0500
In-Reply-To: <20170222015949.18641-1-ridge.kennedy@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ridge Kennedy <ridge.kennedy@alliedtelesis.co.nz>
Date: Wed, 22 Feb 2017 14:59:49 +1300

> While destroying a network namespace that contains a L2TP tunnel a
> "BUG: scheduling while atomic" can be observed.
> 
> Enabling lockdep shows that this is happening because l2tp_exit_net()
> is calling l2tp_tunnel_closeall() (via l2tp_tunnel_delete()) from
> within an RCU critical section.
 ...
> This bug can easily be reproduced with a few steps:
> 
>  $ sudo unshare -n bash  # Create a shell in a new namespace
>  # ip link set lo up
>  # ip addr add 127.0.0.1 dev lo
>  # ip l2tp add tunnel remote 127.0.0.1 local 127.0.0.1 tunnel_id 1 \
>     peer_tunnel_id 1 udp_sport 50000 udp_dport 50000
>  # ip l2tp add session name foo tunnel_id 1 session_id 1 \
>     peer_session_id 1
>  # ip link set foo up
>  # exit  # Exit the shell, in turn exiting the namespace
>  $ dmesg
>  ...
>  [942121.089216] BUG: scheduling while atomic: kworker/u16:3/13872/0x00000200
>  ...
> 
> To fix this, move the call to l2tp_tunnel_closeall() out of the RCU
> critical section, and instead call it from l2tp_tunnel_del_work(), which
> is running from the l2tp_wq workqueue.
> 
> Fixes: 2b551c6e7d5b ("l2tp: close sessions before initiating tunnel delete")
> Signed-off-by: Ridge Kennedy <ridge.kennedy@alliedtelesis.co.nz>

Applied and queued up for -stable, thanks.
