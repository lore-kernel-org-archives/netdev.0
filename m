From: Ivan Delalande <colona@arista.com>
Subject: [PATCH net-next v5 0/2] report TCP MD5 signing keys and addresses
Date: Thu, 31 Aug 2017 09:59:37 -0700
Message-ID: <20170831165939.5121-1-colona@arista.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
        Ivan Delalande <colona@arista.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mx.aristanetworks.com ([162.210.130.12]:59070 "EHLO
        prod-mx.aristanetworks.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751928AbdHaQ7k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 12:59:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow userspace to retrieve MD5 signature keys and addresses configured
on TCP sockets through inet_diag.

Thanks to Eric Dumazet and Stephen Hemminger for their useful
explanations and feedback.

v5: - memset the whole netlink payload after it has been nla_reserve-d
      in tcp_diag_put_md5sig (a third memset had to be added for
      tcpm_key so we might as well have just one for entire region).
    - move the nla_total_size call from inet_sk_attr_size to the
      idiag_get_aux_size defined by protocols as they could add multiple
      netlink attributes,
    - add check for net_admin in tcp_diag_get_aux_size.

v4: - add new struct tcp_diag_md5sig to report the data instead of
      tcp_md5sig to avoid wasting 112 bytes on every tcpm_addr,
    - memset tcpm_addr on IPv4 addresses to avoid leaks,
    - style fix in inet_diag_dump_one_icsk.

v3: - rename inet_diag_*md5sig in tcp_diag.c to tcp_diag_* for
      consistency,
    - don't lock the socket in tcp_diag_put_md5sig,
    - add checks on md5sig_count in tcp_diag_put_md5sig to not create
      the netlink attribute if the list is empty, and to avoid overflows
      or memory leaks if the list has changed in the meantime.

v2: - move changes to tcp_diag.c and extend inet_diag_handler to allow
      protocols to provide additional data on INET_DIAG_INFO,
    - lock socket before calling tcp_diag_put_md5sig.


I also have a patch for iproute2/ss to test this change, making it print
this new attribute. I'm planning to polish and send it if this series
gets applied.


Ivan Delalande (2):
  inet_diag: allow protocols to provide additional data
  tcp_diag: report TCP MD5 signing keys and addresses

 include/linux/inet_diag.h      |   7 +++
 include/uapi/linux/inet_diag.h |   1 +
 include/uapi/linux/tcp.h       |   9 ++++
 net/ipv4/inet_diag.c           |  22 +++++++--
 net/ipv4/tcp_diag.c            | 109 ++++++++++++++++++++++++++++++++++++++---
 5 files changed, 138 insertions(+), 10 deletions(-)

-- 
2.14.1
