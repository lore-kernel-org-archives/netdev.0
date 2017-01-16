From: Juergen Gross <jgross@suse.com>
Subject: [PATCH v2 0/3] xen: optimize xenbus performance
Date: Mon, 16 Jan 2017 15:15:30 +0100
Message-ID: <20170116141533.8946-1-jgross@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: boris.ostrovsky@oracle.com, Juergen Gross <jgross@suse.com>,
        konrad.wilk@oracle.com, roger.pau@citrix.com, wei.liu2@citrix.com,
        paul.durrant@citrix.com, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38106 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750923AbdAPOPn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Jan 2017 09:15:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The xenbus driver used for communication with Xenstore (all kernel
accesses to Xenstore and in case of Xenstore living in another domain
all accesses of the local domain to Xenstore) is rather simple
especially regarding multiple concurrent accesses: they are just being
serialized in spite of Xenstore being capable to handle multiple
parallel accesses.

Clean up the external interface(s) of xenbus and optimize its
performance by allowing multiple concurrent accesses to Xenstore.

V2:
- patch 1: update commit message, re-add lost copyright
- patch 3: address comments of Boris Ostrovsky:
    - guard xs_request_id by lock
    - move state struct definitions to the place where they are being
      used
    - rate limit some warnings
    - use barrier() instead of cpu_relax()
    - add/remove some comments
    - minor changes like naming of variables

Juergen Gross (3):
  xen: clean up xenbus internal headers
  xen: modify xenstore watch event interface
  xen: optimize xenbus driver for multiple concurrent xenstore accesses

 drivers/block/xen-blkback/xenbus.c         |   6 +-
 drivers/net/xen-netback/xenbus.c           |   8 +-
 drivers/xen/cpu_hotplug.c                  |   5 +-
 drivers/xen/manage.c                       |   6 +-
 drivers/xen/xen-balloon.c                  |   2 +-
 drivers/xen/xen-pciback/xenbus.c           |   2 +-
 drivers/xen/xenbus/xenbus.h                | 135 +++++++
 drivers/xen/xenbus/xenbus_client.c         |   6 +-
 drivers/xen/xenbus/xenbus_comms.c          | 315 +++++++++++++++--
 drivers/xen/xenbus/xenbus_comms.h          |  51 ---
 drivers/xen/xenbus/xenbus_dev_backend.c    |   2 +-
 drivers/xen/xenbus/xenbus_dev_frontend.c   | 213 ++++++-----
 drivers/xen/xenbus/xenbus_probe.c          |  14 +-
 drivers/xen/xenbus/xenbus_probe.h          |  88 -----
 drivers/xen/xenbus/xenbus_probe_backend.c  |  11 +-
 drivers/xen/xenbus/xenbus_probe_frontend.c |  17 +-
 drivers/xen/xenbus/xenbus_xs.c             | 547 +++++++++++++----------------
 drivers/xen/xenfs/super.c                  |   2 +-
 drivers/xen/xenfs/xenstored.c              |   2 +-
 include/xen/xenbus.h                       |  18 +-
 20 files changed, 838 insertions(+), 612 deletions(-)
 create mode 100644 drivers/xen/xenbus/xenbus.h
 delete mode 100644 drivers/xen/xenbus/xenbus_comms.h
 delete mode 100644 drivers/xen/xenbus/xenbus_probe.h

Cc: konrad.wilk@oracle.com
Cc: roger.pau@citrix.com
Cc: wei.liu2@citrix.com
Cc: paul.durrant@citrix.com
Cc: netdev@vger.kernel.org
-- 
2.10.2
