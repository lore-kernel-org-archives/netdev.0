From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net] lwtunnel: fix autoload of lwt modules
Date: Mon, 16 Jan 2017 21:33:05 -0800
Message-ID: <1484631185-9428-1-git-send-email-dsa@cumulusnetworks.com>
Cc: rshearma@brocade.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:33740 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750820AbdAQFeZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 00:34:25 -0500
Received: by mail-pf0-f174.google.com with SMTP id y143so59190611pfb.0
        for <netdev@vger.kernel.org>; Mon, 16 Jan 2017 21:33:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Trying to add an mpls encap route when the MPLS modules are not loaded
hangs. For example:

    CONFIG_MPLS=y
    CONFIG_NET_MPLS_GSO=m
    CONFIG_MPLS_ROUTING=m
    CONFIG_MPLS_IPTUNNEL=m

    $ ip route add 10.10.10.10/32 encap mpls 100 via inet 10.100.1.2

The ip command hangs:
root       880   826  0 21:25 pts/0    00:00:00 ip route add 10.10.10.10/32 encap mpls 100 via inet 10.100.1.2

    $ cat /proc/880/stack
    [<ffffffff81065a9b>] call_usermodehelper_exec+0xd6/0x134
    [<ffffffff81065efc>] __request_module+0x27b/0x30a
    [<ffffffff814542f6>] lwtunnel_build_state+0xe4/0x178
    [<ffffffff814aa1e4>] fib_create_info+0x47f/0xdd4
    [<ffffffff814ae451>] fib_table_insert+0x90/0x41f
    [<ffffffff814a8010>] inet_rtm_newroute+0x4b/0x52
    ...

modprobe is trying to load rtnl-lwt-MPLS:

root       881     5  0 21:25 ?        00:00:00 /sbin/modprobe -q -- rtnl-lwt-MPLS

and it hangs after loading mpls_router:

    $ cat /proc/881/stack
    [<ffffffff81441537>] rtnl_lock+0x12/0x14
    [<ffffffff8142ca2a>] register_netdevice_notifier+0x16/0x179
    [<ffffffffa0033025>] mpls_init+0x25/0x1000 [mpls_router]
    [<ffffffff81000471>] do_one_initcall+0x8e/0x13f
    [<ffffffff81119961>] do_init_module+0x5a/0x1e5
    [<ffffffff810bd070>] load_module+0x13bd/0x17d6
    ...

The problem is that lwtunnel_build_state is called with rtnl lock
held preventing mpls_init from registering. Fix by dropping the
lock before invoking request_module.

Fixes: 745041e2aaf1 ("lwtunnel: autoload of lwt modules")
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
This is a best guess at the Fixes.

 net/core/lwtunnel.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/core/lwtunnel.c b/net/core/lwtunnel.c
index a5d4e866ce88..c14ee4d62a8a 100644
--- a/net/core/lwtunnel.c
+++ b/net/core/lwtunnel.c
@@ -120,7 +120,9 @@ int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
 
 		if (encap_type_str) {
 			rcu_read_unlock();
+			__rtnl_unlock();
 			request_module("rtnl-lwt-%s", encap_type_str);
+			rtnl_lock();
 			rcu_read_lock();
 			ops = rcu_dereference(lwtun_encaps[encap_type]);
 		}
-- 
2.1.4
