From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 0/8] xdp: offload mode
Date: Wed, 21 Jun 2017 18:25:02 -0700
Message-ID: <20170622012510.5286-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kafai@fb.com, daniel@iogearbox.net,
        davem@davemloft.net, Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:33957 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751096AbdFVBZ4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 21:25:56 -0400
Received: by mail-pg0-f46.google.com with SMTP id e187so1210515pgc.1
        for <netdev@vger.kernel.org>; Wed, 21 Jun 2017 18:25:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

While we discuss the representors.. :)

This set adds XDP flag for forcing offload and a attachment mode
for reporting to user space that program has been offloaded.  The
nfp driver is modified to make use of the new flags, but also to
adhere to the DRV_MODE flag which should disable the HW offload.

The intended driver behaviour is:
            DRV mode   offload
no flags      yes     attempted
DRV_MODE      yes        no
 HW_MODE      no         yes

Where 'yes' means required, and error will be returned if setup fails.
'Attempted' means the offload will only happen automatically if HW is
capable and offloading the program will cause no change in system
behaviour (e.g. maps don't have to bound).

Thanks to loading the program both to the driver and HW by default we
can fallback to the driver mode without disruption in case user replaces
the program with one which cannot be offloaded later.

Note that the NFP driver currently claims XDP offload support but 
lacks most basic features like direct packet access.

Only change compared to the RFC is fixing the double bpf_prog_put()
which Daniel has spotted (patch 5).

Jakub Kicinski (8):
  xdp: pass XDP flags into install handlers
  xdp: add HW offload mode flag for installing programs
  nfp: xdp: move driver XDP setup into a separate function
  nfp: bpf: don't offload XDP programs in DRV_MODE
  nfp: bpf: release the reference on offloaded programs
  nfp: bpf: add support for XDP_FLAGS_HW_MODE
  xdp: add reporting of offload mode
  nfp: xdp: report if program is offloaded

 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  5 ++
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 62 +++++++++++++++-------
 include/linux/netdevice.h                          |  9 ++--
 include/uapi/linux/if_link.h                       |  8 ++-
 net/core/dev.c                                     | 15 +++---
 net/core/rtnetlink.c                               | 10 ++--
 6 files changed, 73 insertions(+), 36 deletions(-)

-- 
2.11.0
