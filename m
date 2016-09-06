From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 0/2] fib4 offload: notifier to let hw to be aware of all prefixes
Date: Tue,  6 Sep 2016 14:01:38 +0200
Message-ID: <1473163300-2045-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        linville@tuxdriver.com, tgraf@suug.ch, gospo@cumulusnetworks.com,
        sfeldma@gmail.com, ast@plumgrid.com, edumazet@google.com,
        hannes@stressinduktion.org, f.fainelli@gmail.com,
        dsa@cumulusnetworks.com, jhs@mojatatu.com,
        vivien.didelot@savoirfairelinux.com, john.fastabend@intel.com,
        andrew@lunn.ch, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34825 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754722AbcIFMBq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 08:01:46 -0400
Received: by mail-wm0-f65.google.com with SMTP id a6so6889748wmc.2
        for <netdev@vger.kernel.org>; Tue, 06 Sep 2016 05:01:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This is RFC, unfinished. I came across some issues in the process so I would
like to share those and restart the fib offload discussion in order to make it
really usable.

So the goal of this patchset is to allow driver to propagate all prefixes
configured in kernel down HW. This is necessary for routing to work
as expected. If we don't do that HW might forward prefixes known to kernel
incorrectly. Take an example when default route is set in switch HW and there
is an IP address set on a management (non-switch) port.

Currently, only fibs related to the switch port netdev are offloaded using
switchdev ops. This model is not extendable so the first patch introduces
a replacement: notifier to propagate fib additions and removals to whoever
interested. The second patch makes mlxsw to adopt this new way, registering
one notifier block for each mlxsw (asic) instance.

Using switchdev ops, "abort" is called by switchdev core whenever there is
an error during fib add offload. This leads to removal of all offloaded fibs on
system by fib_trie code.

Now the new notifier assumes the driver takes care of the abort action.
Here's why:
1) The fact that one HW cannot offload fib does not mean that the others can't
   do it. So let only one entity to abort and leave the rest to work happily.
2) The driver knows what to in order to properly abort. For example, currently
   abort is broken for mlxsw as for Spectrum there is a need to set 0.0.0.0/0
   trap in RALUE register.

Issues:
1) RTNH_F_OFFLOAD is originally set in switchdev core. There the assumption is
   that only one offload device exists. But for fib notifier, we assume
   multiple offload devices. When should the offload flag be set and by who?
   I think that it would make sense to have a per-fib reference counter
   for this:
   0 means RTNH_F_OFFLOAD is not set, no device offloads this entry
   n means RTNH_F_OFFLOAD is set and the fib entry is offloaded by n devices

2) Unabort? Would be nice. Currently when add_failure->abort happens,
   user's only option is to reboot the machine. I would like to make this
   nicer for the fib notifier implementation. Perhaps to provide some button in
   devlink which would tell driver to try to offload entries again? Not sure.

3) Policies. Not directly connected to this patchset but this issues
   we have been discussing couple of times and I still believe that
   the current state is not good.
   Software-only forwarding now happens in case of abort and makes the ASIC
   ports to act like dummy separate NICs. In case of Spectrum, the bandwidth
   of CPU port is something around 4Gbit. For 32x100Gbit ports this is
   simply not possible to handle. In case of abort, the system is broken
   as it really could not forward packets at a speed not even close
   to the expected.
   Here the policies come to the picture, allowing the user to set the
   system to behave according his expectations. For example rather
   fail to add the route than to abort to software forward.
   This policy could be per-ASIC, configurable by devlink.

Thoughts please?

Jiri Pirko (2):
  fib: introduce fib notification infrastructure
  mlxsw: spectrum_router: Use FIB notifications instead of switchdev
    calls

 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |   8 +-
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 257 ++++++++++-----------
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   |   9 -
 include/net/ip_fib.h                               |  19 ++
 net/ipv4/fib_trie.c                                |  43 ++++
 5 files changed, 181 insertions(+), 155 deletions(-)

-- 
2.5.5
