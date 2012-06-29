From: pablo@netfilter.org
Subject: [PATCH 0/2] [net-next] Netlink updates
Date: Fri, 29 Jun 2012 18:15:20 +0200
Message-ID: <1340986522-3442-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi David,

The following two patches provides a couple of Netlink updates:

* One netlink update to introduce struct netlink_kernel_cfg:

struct netlink_kernel_cfg {
        unsigned int    groups;
        void            (*input)(struct sk_buff *skb);
        struct mutex    *cb_mutex;
};

This structure contains optional paramters to configure one netlink
kernel socket.

eg.

       struct netlink_kernel_cfg cfg = {
               .input  = crypto_netlink_rcv,
       };

       crypto_nlsk = netlink_kernel_create(&init_net, NETLINK_CRYPTO,
                                           THIS_MODULE, &cfg);

This should make easier in the future to add new optional
configuration parameters without touching the netlink_kernel_create
interface.

I converted all netlink_kernel_create invocations in your tree to
use the new one.

* One patch that adds the bind hook. This hook is used by nfnetlink
to auto-load the appropriate subsystem

The bind hook is called in the netlink_setsockopt and netlink_bind
paths. These are called when registering a user-space netlink event
listener.

Let me provide one example, to further clarify this. If you run:

 conntrack -E

And nf_conntrack_netlink is not loaded, the existing netlink autoload
code add nfnetlink, but we have no way to autoload nf_conntrack_netlink.

With this new chunk of code, we can run some code in nfnetlink to check
for the group that the user-space listener wants to subscribe to. Then,
it can check what module needs to be auto-loaded, if required.

We got users complaining on this behaviour in the past.

If you like them, please manually apply. I wanted to know if you are
happy with these before pushing them into my tree, as they include
netlink changes.

Thanks!

Pablo Neira Ayuso (2):
  netlink: add netlink_kernel_cfg parameter to netlink_kernel_create
  netlink: add nlk->netlink_bind hook for module auto-loading

 crypto/crypto_user.c                |    7 +++++--
 drivers/connector/connector.c       |   13 +++++++++----
 drivers/infiniband/core/netlink.c   |    7 +++++--
 drivers/scsi/scsi_netlink.c         |    7 +++++--
 drivers/scsi/scsi_transport_iscsi.c |    9 ++++++---
 drivers/staging/gdm72xx/netlink_k.c |    6 ++++--
 include/linux/netlink.h             |   16 +++++++++++-----
 kernel/audit.c                      |    7 +++++--
 lib/kobject_uevent.c                |    5 ++++-
 net/bridge/netfilter/ebt_ulog.c     |    6 ++++--
 net/core/rtnetlink.c                |    9 +++++++--
 net/core/sock_diag.c                |    8 ++++++--
 net/decnet/netfilter/dn_rtmsg.c     |    8 +++++---
 net/ipv4/fib_frontend.c             |    7 +++++--
 net/ipv4/netfilter/ipt_ULOG.c       |    8 +++++---
 net/netfilter/nfnetlink.c           |   36 +++++++++++++++++++++++++++++++++--
 net/netlink/af_netlink.c            |   35 ++++++++++++++++++++++++++++------
 net/netlink/genetlink.c             |   10 +++++++---
 net/xfrm/xfrm_user.c                |    7 +++++--
 security/selinux/netlink.c          |    6 +++++-
 20 files changed, 166 insertions(+), 51 deletions(-)

-- 
1.7.10

