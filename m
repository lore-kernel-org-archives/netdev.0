From: Alex Zeffertt <alex.zeffertt@gmail.com>
Subject: kernel oops on gretap teardown
Date: Mon, 17 Mar 2014 11:03:32 +0000
Message-ID: <CA+OdkwFY3D3Ncj2w0MfGrgMOw3bqk=3AKKv1FEE-Na8c52TUaw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f172.google.com ([74.125.82.172]:61502 "EHLO
	mail-we0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932506AbaCQLDe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 07:03:34 -0400
Received: by mail-we0-f172.google.com with SMTP id t61so4438267wes.3
        for <netdev@vger.kernel.org>; Mon, 17 Mar 2014 04:03:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All,

I can reliably hang the kernel 3.11.0 kernel on my Ubuntu box by
shutting down multiple gretap interfaces (near) simultaneously.  The
gretap interfaces belong to LXC containers that are all running on the
same host, so they are all in different namespaces.

This crash only occurs if I shut down the containers (and therefore
the interfaces) forcibly using "lxc-stop -k".  If I omit the "-k" the
crash does not occur (and the shutdown takes *much* longer).


[  202.827256] BUG: unable to handle kernel NULL pointer dereference at 000000fc
[  202.828153] IP: [<f867c22a>] ip_tunnel_lookup+0x22a/0x2e0 [ip_tunnel]
[  202.831060] Call Trace:
[  202.831060]  [<f8685d66>] ipgre_rcv+0x86/0xe0 [ip_gre]
[  202.831060]  [<f86776a6>] gre_cisco_rcv+0x36/0x80 [gre]
[  202.831060]  [<f8677390>] gre_rcv+0x50/0x80 [gre]
[  202.831060]  [<c157d157>] ip_local_deliver_finish+0x97/0x220
[  202.831060]  [<c157d444>] ip_local_deliver+0x44/0x90

When I looked at the program counter in gdb I found that the crash was
due to the NULL pointer t->dev being dereferenced.  This lead me to
try the following patch, which "fixed" the problem.

 --- net/ipv4/ip_tunnel.c.orig 2014-03-14 14:22:08.254042459 +0000
+++ net/ipv4/ip_tunnel.c 2014-03-14 14:37:39.644441999 +0000
@@ -201,7 +201,7 @@
  goto skip_key_lookup;

  hlist_for_each_entry_rcu(t, head, hash_node) {
- if (t->parms.i_key != key ||
+ if (t->parms.i_key != key || !(t->dev) ||
     !(t->dev->flags & IFF_UP))
  continue;

However, I can't see where t->dev is getting cleared in the code.  Can
anybody suggest what the ultimate cause of the problem is?

Regards,

Alex
