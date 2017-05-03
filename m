From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/16] Netfilter/IPVS/OVS fixes for net
Date: Wed,  3 May 2017 11:31:55 +0200
Message-ID: <1493803931-2837-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains a rather large batch of Netfilter, IPVS
and OVS fixes for your net tree. This includes fixes for ctnetlink, the
userspace conntrack helper infrastructure, conntrack OVS support,
ebtables DNAT target, several leaks in error path among other. More
specifically, they are:

1) Fix reference count leak in the CT target error path, from Gao Feng.

2) Remove conntrack entry clashing with a matching expectation, patch
   from Jarno Rajahalme.

3) Fix bogus EEXIST when registering two different userspace helpers,
   from Liping Zhang.

4) Don't leak dummy elements in the new bitmap set type in nf_tables,
   from Liping Zhang.

5) Get rid of module autoload from conntrack update path in ctnetlink,
   we don't need autoload at this late stage and it is happening with
   rcu read lock held which is not good. From Liping Zhang.

6) Fix deadlock due to double-acquire of the expect_lock from conntrack
   update path, this fixes a bug that was introduced when the central
   spinlock got removed. Again from Liping Zhang.

7) Safe ct->status update from ctnetlink path, from Liping. The expect_lock
   protection that was selected when the central spinlock was removed was
   not really protecting anything at all.

8) Protect sequence adjustment under ct->lock.

9) Missing socket match with IPv6, from Peter Tirsek.

10) Adjust skb->pkt_type of DNAT'ed frames from ebtables, from
    Linus Luessing.

11) Don't give up on evaluating the expression on new entries added via
    dynset expression in nf_tables, from Liping Zhang.

12) Use skb_checksum() when mangling icmpv6 in IPv6 NAT as this deals
    with non-linear skbuffs.

13) Don't allow IPv6 service in IPVS if no IPv6 support is available,
    from Paolo Abeni.

14) Missing mutex release in error path of xt_find_table_lock(), from
    Dan Carpenter.

15) Update maintainers files, Netfilter section. Add Florian to the
    file, refer to nftables.org and change project status from Supported
    to Maintained.

16) Bail out on mismatching extensions in element updates in nf_tables.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit 94836ecf1e7378b64d37624fbb81fe48fbd4c772:

  Merge tag 'nfsd-4.11-2' of git://linux-nfs.org/~bfields/linux (2017-04-21 16:37:48 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git HEAD

for you to fetch changes up to 9744a6fcefcb4d56501d69adb04c24559d353cad:

  netfilter: nf_tables: check if same extensions are set when adding elements (2017-05-03 10:58:00 +0200)

----------------------------------------------------------------
Dan Carpenter (1):
      netfilter: x_tables: unlock on error in xt_find_table_lock()

Dave Johnson (1):
      netfilter: Wrong icmp6 checksum for ICMPV6_TIME_EXCEED in reverse SNATv6 path

Gao Feng (1):
      netfilter: xt_CT: fix refcnt leak on error path

Jarno Rajahalme (1):
      openvswitch: Delete conntrack entry clashing with an expectation.

Linus Lüssing (1):
      bridge: ebtables: fix reception of frames DNAT-ed to bridge device/port

Liping Zhang (7):
      netfilter: nf_ct_helper: permit cthelpers with different names via nfnetlink
      netfilter: nft_set_bitmap: free dummy elements when destroy the set
      netfilter: ctnetlink: drop the incorrect cthelper module request
      netfilter: ctnetlink: fix deadlock due to acquire _expect_lock twice
      netfilter: ctnetlink: make it safer when updating ct->status
      netfilter: ctnetlink: acquire ct->lock before operating nf_ct_seqadj
      netfilter: nft_dynset: continue to next expr if _OP_ADD succeeded

Pablo Neira Ayuso (3):
      Merge tag 'ipvs-fixes-for-v4.11' of http://git.kernel.org/.../horms/ipvs
      netfilter: update MAINTAINERS file
      netfilter: nf_tables: check if same extensions are set when adding elements

Paolo Abeni (1):
      ipvs: explicitly forbid ipv6 service/dest creation if ipv6 mod is disabled

Peter Tirsek (1):
      netfilter: xt_socket: Fix broken IPv6 handling

 MAINTAINERS                                        |  4 +-
 include/uapi/linux/netfilter/nf_conntrack_common.h | 13 +++-
 net/bridge/netfilter/ebt_dnat.c                    | 20 +++++
 net/ipv6/netfilter/nf_nat_l3proto_ipv6.c           |  2 +-
 net/netfilter/ipvs/ip_vs_ctl.c                     | 22 ++++--
 net/netfilter/nf_conntrack_helper.c                | 26 +++++--
 net/netfilter/nf_conntrack_netlink.c               | 89 ++++++++++++----------
 net/netfilter/nf_tables_api.c                      |  5 ++
 net/netfilter/nft_dynset.c                         |  5 +-
 net/netfilter/nft_set_bitmap.c                     |  5 ++
 net/netfilter/x_tables.c                           |  4 +-
 net/netfilter/xt_CT.c                              | 11 ++-
 net/netfilter/xt_socket.c                          |  2 +-
 net/openvswitch/conntrack.c                        | 30 +++++++-
 14 files changed, 174 insertions(+), 64 deletions(-)
