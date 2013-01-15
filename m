From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH V4 0/3] handle polling erros in vhost/vhost_net
Date: Tue, 15 Jan 2013 18:28:43 +0800
Message-ID: <1358245726-16250-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an update version of last version to fix the handling of polling errors
in vhost/vhost_net.

Currently, vhost and vhost_net ignore polling errors which can lead kernel
crashing when it tries to remove itself from waitqueue after the polling
failure. Fix this by:

- examing the POLLERR when set backend and report erros to userspace
- let tun always add to waitqueue in .poll() after the queue is created even if
  it was detached.

Changes from V3:
- make a smaller patch that doesn't touch the whole polling state and only check
  the polliner errors in backend setting.
- add a patch that allows tuntap to do polling/reading/writing when detached
  which could simplify the work of its user.

Changes from v2:
- check poll->wqh instead of the wrong assumption about POLLERR and waitqueue
- drop the whole tx polling state check since it was replaced by the wqh
  checking
- drop the buggy tuntap patch

Changes from v1:
- restore the state before the ioctl when vhost_init_used() fails
- log the error when meet polling errors in the data path
- don't put into waitqueue when tun_chr_poll() return POLLERR

Jason Wang (3):
  vhost_net: correct error handling in vhost_net_set_backend()
  vhost_net: handle polling errors when setting backend
  tuntap: allow polling/writing/reading when detached

 drivers/net/tun.c     |   18 +++++++++++-------
 drivers/vhost/net.c   |   41 ++++++++++++++++++++++++++++-------------
 drivers/vhost/vhost.c |   18 +++++++++++++++---
 drivers/vhost/vhost.h |    2 +-
 4 files changed, 55 insertions(+), 24 deletions(-)
