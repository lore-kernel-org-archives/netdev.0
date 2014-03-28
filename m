From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next v4 0/9] BPF updates
Date: Fri, 28 Mar 2014 18:58:17 +0100
Message-ID: <1396029506-16776-1-git-send-email-dborkman@redhat.com>
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42486 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753230AbaC1R6b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2014 13:58:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We sat down and have heavily reworked the whole previous patchset
from v10 [1] to address all comments/concerns. This patchset therefore
*replaces* the internal BPF interpreter with the new layout as
discussed in [1], and migrates some exotic callers to properly use the
BPF API for a transparent upgrade. All other callers that already use
the BPF API in a way it should be used, need no further changes to run
the new internals. We also removed the sysctl knob entirely, and do not
expose any structure to userland, so that implementation details only
reside in kernel space. Since we are replacing the interpreter we had
to migrate seccomp in one patch along with the interpreter to not break
anything. When attaching a new filter, the flow can be described as
following: i) test if jit compiler is enabled and can compile the user
BPF, ii) if so, then go for it, iii) if not, then transparently migrate
the filter into the new representation, and run it in the interpreter.
Also, we have scratched the jit flag from the len attribute and made it
as initial patch in this series as Pablo has suggested in the last
feedback, thanks. For details, please refer to the patches themselves.

We did extensive testing of BPF and seccomp on the new interpreter
itself and also on the user ABIs and could not find any issues; new
performance numbers as posted in patch 8 are also still the same.

Please find more details in the patches themselves.

For all the previous history from v1 to v10, see [1]. We have decided
to drop the v11 as we have pedantically reworked the set, but of course,
included all previous feedback.

v3 -> v4:
 - Applied feedback from Dave regarding swap insns
 - Rebased on net-next
v2 -> v3:
 - Rebased to latest net-next (i.e. w/ rxhash->hash rename)
 - Fixed patch 8/9 commit message/doc as suggested by Dave
 - Rest is unchanged
v1 -> v2:
 - Rebased to latest net-next
 - Added static to ptp_filter as suggested by Dave
 - Fixed a typo in patch 8's commit message
 - Rest unchanged

Thanks !

  [1] http://thread.gmane.org/gmane.linux.kernel/1665858

Alexei Starovoitov (2):
  net: filter: rework/optimize internal BPF interpreter's instruction set
  doc: filter: extend BPF documentation to document new internals

Daniel Borkmann (7):
  net: filter: add jited flag to indicate jit compiled filters
  net: filter: keep original BPF program around
  net: filter: move filter accounting to filter core
  net: ptp: use sk_unattached_filter_create() for BPF
  net: ptp: do not reimplement PTP/BPF classifier
  net: ppp: use sk_unattached_filter api
  net: isdn: use sk_unattached_filter api

 Documentation/networking/filter.txt                |  125 ++
 arch/arm/net/bpf_jit_32.c                          |    3 +-
 arch/powerpc/net/bpf_jit_comp.c                    |    3 +-
 arch/s390/net/bpf_jit_comp.c                       |    5 +-
 arch/sparc/net/bpf_jit_comp.c                      |    3 +-
 arch/x86/net/bpf_jit_comp.c                        |    3 +-
 drivers/isdn/i4l/isdn_ppp.c                        |   61 +-
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |   11 +-
 drivers/net/ethernet/ti/cpts.c                     |   10 +-
 drivers/net/ethernet/xscale/ixp4xx_eth.c           |   11 +-
 drivers/net/ppp/ppp_generic.c                      |   60 +-
 include/linux/filter.h                             |  118 +-
 include/linux/isdn_ppp.h                           |    5 +-
 include/linux/ptp_classify.h                       |   14 +-
 include/linux/seccomp.h                            |    1 -
 include/net/sock.h                                 |   27 -
 kernel/seccomp.c                                   |  119 +-
 net/core/filter.c                                  | 1565 ++++++++++++++++----
 net/core/sock_diag.c                               |   23 +-
 net/core/timestamping.c                            |   27 +-
 20 files changed, 1658 insertions(+), 536 deletions(-)

-- 
1.7.11.7
