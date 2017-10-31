From: Girish Moodalbail <girish.moodalbail@oracle.com>
Subject: [PATCH net 0/2] NULL pointer dereference in {ipvlan|macvlan}_port_destroy
Date: Tue, 31 Oct 2017 09:39:45 -0700
Message-ID: <1509467987-20050-1-git-send-email-girish.moodalbail@oracle.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:48636 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932386AbdJaRDJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 13:03:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From code inspection it appeared that there is a possibility where in
ipvlan_port_destroy() might be dealing with a port (struct ipvl_port)
that has already been destroyed and is therefore already NULL. However,
we don't check for NULL and continue to access the fields which results
in a kernel panic.

When call to register_netdevice() (called from ipvlan_link_new()) fails,
inside that function we call ipvlan_uninit() (through ndo_uninit()) to
destroy the ipvlan port. Upon returning unsuccessfully from
register_netdevice() we go ahead and call ipvlan_port_destroy() again
which causes NULL pointer dereference panic.

To test this theory, I loaded up netdev-notifier-error-inject.ko and did 

# echo -22 > /sys/kernel/debug/notifier-error-inject/\
  netdev/actions/NETDEV_POST_INIT/error

# ip li add ipvl0 link enp7s0 type ipvlan
<system panics>
BUG: unable to handle kernel NULL pointer dereference at 0000000000000820
IP: ipvlan_port_destroy+0x2a/0xf0 [ipvlan]

Similar issue exists in macvlan_port_destroy(). The following two
patches fixes ipvlan and macvlan module.

-----
Girish Moodalbail (2):
  ipvlan: NULL pointer dereference panic in ipvlan_port_destroy
  macvlan: NULL pointer dereference panic in macvlan_port_destroy

 drivers/net/ipvlan/ipvlan_main.c | 6 ++++++
 drivers/net/macvlan.c            | 5 ++++-
 2 files changed, 10 insertions(+), 1 deletion(-)

-- 
1.8.3.1
