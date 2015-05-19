From: Baptiste Covolato <baptiste@arista.com>
Subject: [PATCH net-next 0/3] Unserialize netdev_run_todo
Date: Tue, 19 May 2015 16:24:50 -0700
Message-ID: <1432077893-4431-1-git-send-email-baptiste@arista.com>
Cc: Francesco Ruggeri <fruggeri@arista.com>,
	Eric Mowat <mowat@arista.com>,
	Adrien Schildknecht <adrien+dev@schischi.me>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:34780 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751080AbbESXZS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 19:25:18 -0400
Received: by pdbnk13 with SMTP id nk13so44726526pdb.1
        for <netdev@vger.kernel.org>; Tue, 19 May 2015 16:25:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Interface deletion can be done in bulk for multiple
interfaces (e.g. rollback_registered_many), reducing the number of calls
needed to synchronize_net and rcu_barrier.
This logic is not used during the last phase of interface deletion after
the rtnl mutex has been released in netdev_run_todo. In this case the
deletion is done one interface at a time, resulting in multiple calls to
on_each_cpu as well as rcu_barrier if notifications have to be
rebroadcast. If any one interface's deletion is delayed, all interfaces
following it will also be delayed. This series of patches allows for the
last stage of interface deletion to also be done in bulk. In order to do
this it also modifies flush_backlog to delete packets for all interfaces
in NETREG_UNREGISTERED state.

Early work done by Adrien Schildknecht.

Signed-off-by: Baptiste Covolato <baptiste@arista.com>
Signed-off-by: Francesco Ruggeri <fruggeri@arista.com>

Baptiste Covolato (3):
  net: Flush all skbs related to an unregistered device
  net: Inline netdev_wait_allrefs inside netdev_run_todo
  net: Make netdev_run_todo call notifiers in parallel.

 net/core/dev.c | 183 +++++++++++++++++++++++++++++----------------------------
 1 file changed, 93 insertions(+), 90 deletions(-)

-- 
2.4.1
