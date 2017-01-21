From: Kevin Cernekee <cernekee@chromium.org>
Subject: [PATCH 0/4] Make xfrm usable by 32-bit programs
Date: Fri, 20 Jan 2017 16:05:03 -0800
Message-ID: <20170121000507.34381-1-cernekee@chromium.org>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        selinux@tycho.nsa.gov, fw@strlen.de, fan.du@windriver.com,
        dianders@chromium.org, dtor@chromium.org
To: steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        davem@davemloft.net, paul@paul-moore.com, sds@tycho.nsa.gov,
        eparis@parisplace.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Several of the xfrm netlink and setsockopt() interfaces are not usable
from a 32-bit binary running on a 64-bit kernel due to struct padding
differences.  This has been the case for many, many years[0].  This
patch series deprecates the broken netlink messages and replaces them
with packed structs that are compatible between 64-bit and 32-bit
programs.  It retains support for legacy user programs (i.e. anything
that is currently working today), and allows legacy support to be
compiled out via CONFIG_XFRM_USER_LEGACY if it becomes unnecessary in
the future.

Earlier attempts at fixing the problem had implemented a compat layer.
A compat layer is helpful because it avoids the need to recompile old
user binaries, but there are many challenges involved in implementing
it.  I believe a compat layer is of limited value in this instance
because anybody who really needed to solve the problem without
recompiling their binaries has almost certainly found another solution
in the ~7 years since the compat patches were first proposed.

A benefit of this approach is that long-term, the broken netlink messages
will no longer be used.  A drawback is that in the short term, user
programs that want to adopt the new message formats will require a
modern kernel.  Projects like strongSwan and iproute2 bundle the xfrm.h
header inside their own source trees, so they will need to make a
judgment call on when to remove support for kernels that do not support
the new messages.  And programs built against the new kernel headers
will not work on old kernels.  (Perhaps this is an argument for naming
the new messages _NEW, rather than renaming the old messages to
_LEGACY.)

The following netlink messages are affected:

    XFRM_MSG_NEWSA
    XFRM_MSG_UPDSA
    XFRM_MSG_DELSA
    XFRM_MSG_GETSA
    XFRM_MSG_NEWPOLICY
    XFRM_MSG_UPDPOLICY
    XFRM_MSG_DELPOLICY
    XFRM_MSG_GETPOLICY
    XFRM_MSG_ALLOCSPI
    XFRM_MSG_ACQUIRE
    XFRM_MSG_EXPIRE
    XFRM_MSG_POLEXPIRE

The following setsockopt() settings are affected:

    IP_XFRM_POLICY
    IPV6_XFRM_POLICY

The root cause of the problem involves padding and alignment
incompatibilities in the following structs:

    xfrm_usersa_info 220 bytes on i386 -> 224 bytes on amd64
    xfrm_userpolicy_info 164 -> 168
    xfrm_userspi_info 228 -> 232, offset mismatch on min
    xfrm_user_acquire 276 -> 280, offset mismatch on aalgos
    xfrm_user_expire 224 -> 232, offset mismatch on hard
    xfrm_user_polexpire 168 -> 176, offset mismatch on hard

Most xfrm netlink messages consist of an xfrm_* struct followed by
additional attributes (struct nlattr TLV), so even cases where the
struct layout (sans padding) is identical will result in incompatible
messages.

Some possible tweaks to this approach:

a) Name the new messages _NEW instead of renaming the old messages
_LEGACY.  This fixes the "new binary on old kernel" problem, but it
means that callers need to change every call site in their programs
to explicitly request the new interface.

b) Tweak xfrm.h so that user programs build against the legacy
interfaces by default, but can alter that behavior using a #define
flag.  Maybe in a few years, assume that everyone is running a modern
kernel and make the new interface the default.


[0] https://www.spinics.net/lists/netdev/msg126176.html


Kevin Cernekee (4):
  xfrm: Constify xfrm_user arguments and xfrm_mgr callback APIs
  xfrm_user: Allow common functions to be called from another file
  xfrm_user: Initial commit of xfrm_user_legacy.c
  xfrm_user: Add new 32/64-agnostic netlink messages

 include/net/xfrm.h          |   36 +-
 include/uapi/linux/xfrm.h   |  152 ++++--
 net/key/af_key.c            |   34 +-
 net/xfrm/Kconfig            |   14 +
 net/xfrm/Makefile           |    8 +-
 net/xfrm/xfrm_policy.c      |    8 +-
 net/xfrm/xfrm_state.c       |    2 +-
 net/xfrm/xfrm_user.c        |  587 +++++++++++++---------
 net/xfrm/xfrm_user.h        |  165 +++++++
 net/xfrm/xfrm_user_legacy.c | 1140 +++++++++++++++++++++++++++++++++++++++++++
 security/selinux/nlmsgtab.c |   61 ++-
 11 files changed, 1890 insertions(+), 317 deletions(-)
 create mode 100644 net/xfrm/xfrm_user.h
 create mode 100644 net/xfrm/xfrm_user_legacy.c

-- 
2.11.0.483.g087da7b7c-goog
