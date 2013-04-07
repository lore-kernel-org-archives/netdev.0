From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH 00/16] info leak fixes in recvmsg
Date: Sun,  7 Apr 2013 13:51:46 +0200
Message-ID: <1365335522-29931-1-git-send-email-minipli@googlemail.com>
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Andy King <acking@vmware.com>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Dmitry Torokhov <dtor@vmware.com>,
	George Zhang <georgezhang@vmware.com>,
	Gustavo Padovan <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	Jon Maloy <jon.maloy@ericsson.com>,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Marcel Holtmann <marcel@holtmann.org>,
	Ralf Baechle <ralf@linux-mips.org>,
	Samuel Ortiz <sameo@linux.intel.com>,
	Samuel Ortiz <samuel@sortiz.org>,
	Sjur Braendeland <sjur.brandeland@stericsson.com>,
	Ursula Braun <ursula.braun@de.ibm.com>,
	Brad Spengler <spender@grsecurity.net>,
	Mathias Krause <minipli@googlemail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f53.google.com ([209.85.214.53]:55612 "EHLO
	mail-bk0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933425Ab3DGLwY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Apr 2013 07:52:24 -0400
Received: by mail-bk0-f53.google.com with SMTP id e19so2728252bku.12
        for <netdev@vger.kernel.org>; Sun, 07 Apr 2013 04:52:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

a few more info leak fixes in the recvmsg path. The error pattern here
is the protocol specific recvmsg function is missing the msg_namelen
assignment -- either completely or in early exit paths that do not
result in errors in __sys_recvmsg()/sys_recvfrom() and, in turn, make
them call move_addr_to_user(), leaking the then still uninitialized
sockaddr_storage stack variable to userland.

My audit was initiated by a rather coarse fix of the leak that can be
found in the grsecurity patch, putting a penalty on protocols complying
to the rules of recvmsg. So credits for finding the leak in the recvmsg
path in __sys_recvmsg() should go to Brad!

The buggy protocols/subsystems are rather obscure anyway. As a missing
assignment of msg_namelen coupled with a missing filling of msg_name
would only result in garbage -- the leak -- in case userland would care
about that information, i.e. would provide a msg_name pointer. But
obviously current userland does not.

While auditing the code for the above pattern I found a few more
'uninitialized members' kind of leaks related to the msg_name filling.
Those are fixed in this series, too.

I have to admit, I failed to test all of the patches due to missing
hardware, e.g. iucv depends on S390 -- hardware I've no access to :/


Please apply!


Mathias Krause (16):
  atm: update msg_namelen in vcc_recvmsg()
  ax25: fix info leak via msg_name in ax25_recvmsg()
  Bluetooth: fix possible info leak in bt_sock_recvmsg()
  Bluetooth: RFCOMM - Fix missing msg_namelen update in
    rfcomm_sock_recvmsg()
  Bluetooth: SCO - Fix missing msg_namelen update in sco_sock_recvmsg()
  caif: Fix missing msg_namelen update in caif_seqpkt_recvmsg()
  irda: Fix missing msg_namelen update in irda_recvmsg_dgram()
  iucv: Fix missing msg_namelen update in iucv_sock_recvmsg()
  l2tp: fix info leak in l2tp_ip6_recvmsg()
  llc: Fix missing msg_namelen update in llc_ui_recvmsg()
  netrom: fix info leak via msg_name in nr_recvmsg()
  NFC: llcp: fix info leaks via msg_name in llcp_sock_recvmsg()
  rose: fix info leak via msg_name in rose_recvmsg()
  tipc: fix info leaks via msg_name in recv_msg/recv_stream
  VSOCK: vmci - fix possible info leak in
    vmci_transport_dgram_dequeue()
  VSOCK: Fix missing msg_namelen update in vsock_stream_recvmsg()

 net/atm/common.c               |    2 ++
 net/ax25/af_ax25.c             |    1 +
 net/bluetooth/af_bluetooth.c   |    4 ++--
 net/bluetooth/rfcomm/sock.c    |    1 +
 net/bluetooth/sco.c            |    1 +
 net/caif/caif_socket.c         |    2 ++
 net/irda/af_irda.c             |    2 ++
 net/iucv/af_iucv.c             |    2 ++
 net/l2tp/l2tp_ip6.c            |    1 +
 net/llc/af_llc.c               |    2 ++
 net/netrom/af_netrom.c         |    1 +
 net/nfc/llcp/sock.c            |    3 +++
 net/rose/af_rose.c             |    1 +
 net/tipc/socket.c              |    7 +++++++
 net/vmw_vsock/af_vsock.c       |    2 ++
 net/vmw_vsock/vmci_transport.c |    3 ++-
 16 files changed, 32 insertions(+), 3 deletions(-)

-- 
1.7.10.4
