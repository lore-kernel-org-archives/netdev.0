From: David Laight <David.Laight@ACULAB.COM>
Subject: sock_create_kern() and (lack of) get_net()
Date: Wed, 3 May 2017 11:39:30 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFFE4805@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.182]:53635 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751354AbdECLjg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 07:39:36 -0400
Received: from 1d5sd3-00009g-UV by out6c.electric.net with emc1-ok (Exim 4.87)
        (envelope-from <David.Laight@ACULAB.COM>)
        id 1d5sd3-0000BY-Va
        for netdev@vger.kernel.org; Wed, 03 May 2017 04:39:33 -0700
Received: from [213.249.233.130] (helo=AcuExch.aculab.com)
        by out6c.electric.net with esmtps (TLSv1:AES128-SHA:128)
        (Exim 4.87)
        (envelope-from <David.Laight@ACULAB.COM>)
        id 1d5sd3-00009g-UV
        for netdev@vger.kernel.org; Wed, 03 May 2017 04:39:33 -0700
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sock_create_kern() passes 'kern=1' to __sock_create().
sock_create() passes 'kern=0' and uses current->nsproxy->ns_net.

The 'kern' parameter is passed to security_socket_create() and
security_socket_post_create() - I think this is just checking
whether the call is allowed.

The 'kern' parameter is also passed through to sk_alloc() and
controls whether the socket holds a reference count to the namespace.

The latter 'feature' is there because some sockets are used within
the protocol stack itself and the network namespace needs to be
deleteable while those sockets exits.
Prior to 4.2 get_get() was called when all sockets were created and
a 'dance' was done is a few places to drop the reference.
These sockets are still inside the namespace - so must be deleted
by the code that deletes the namespace.

I suspect that many of the sockets created with 'kern=1' are not 'special'
and should hold a reference to the namespace.

In particular code that calls sock_create_kern() and then uses the
kernel_xxx() socket functions at the bottom of net/socket.c probably
want to hold a reference to the network namespace.
I'm pretty sure the socket can still exist (eg draining data) after
sock_release() is called - so the driver can't hold the namespace
reference on behalf of the socket.

A quick audit shows calls to __sock_create(..., 1) at:
  ./fs/cifs/connect.c:3176
  ./net/wireless/nl80211.c:10022
  ./net/sunrpc/svcsock.c:1516
  ./net/sunrpc/clnt.c:1247
  ./net/sunrpc/xprtsock.c:1952
  ./net/sunrpc/xprtsock.c:2019
  ./net/9p/trans_fd.c:948
  ./net/9p/trans_fd.c:996
and calls to sock_create_kern() at:
  ./drivers/infiniband/sw/rxe/rxe_qp.c:233
  ./drivers/block/drbd/drbd_receiver.c:631
  ./drivers/block/drbd/drbd_receiver.c:726
  ./fs/dlm/lowcomms.c:732
  ./fs/dlm/lowcomms.c:1053
  ./fs/dlm/lowcomms.c:1134
  ./fs/dlm/lowcomms.c:1221
  ./fs/dlm/lowcomms.c:1303
  ./fs/afs/rxrpc.c:68
  ./net/ceph/messenger.c:480
  ./net/rds/tcp_connect.c
  ./net/rds/tcp_connect.c:108
  ./net/rds/tcp_listen.c:128
  ./net/rds/tcp_listen.c:247
  ./net/rxrpc/local_object.c:117
  ./net/smc/af_smc.c:1317
  ./net/l2tp/l2tp_core.c:1506
  ./net/l2tp/l2tp_core.c:1534
All of which look to me like code that is using IP connections and
would need to be shut down before any namespace could be deleted.

There are also calls to sock_create_kern() in:
  ./net/tipc/server.c:330
  ./net/ipv6/ip6_udp_tunnel.c:22
  ./net/ipv4/udp_tunnel.c:19
  ./net/ipv4/af_inet.c:1529
  ./net/bluetooth/rfcomm/core.c:203
  ./net/netfilter/ipvs/ip_vs_sync.c:1503
  ./net/netfilter/ipvs/ip_vs_sync.c:1560
These might all be internal to the protocol stack.

I suspect that the 'kern' parameter to __sock_create() needs changing
to 'flags' with:
  1 - traditional 'kernel' socket, pass '1' to security_socket_create().
  2 - 'protocol internal' socket, don't hold a net_ns reference count.
The call sites would then need auditing to see which value they should
pass.

As usual I've probably missed something obvious...

	David
