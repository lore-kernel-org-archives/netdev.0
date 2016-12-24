From: Andy Lutomirski <luto@kernel.org>
Subject: [RFC PATCH 4.10 0/6] Switch BPF's digest to SHA256
Date: Fri, 23 Dec 2016 18:22:26 -0800
Message-ID: <cover.1482545792.git.luto@kernel.org>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Biggers <ebiggers3@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        "David S. Miller" <davem@davemloft.net>,
        Andy Lutomirski <luto@kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>,
        Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since there are plenty of uses for the new-in-4.10 BPF digest feature
that would be problematic if malicious users could produce collisions,
the BPF digest should be collision-resistant.  SHA-1 is no longer
considered collision-resistant, so switch it to SHA-256.

The actual switchover is trivial.  Most of this series consists of
cleanups to the SHA256 code to make it usable as a standalone library
(since BPF should not depend on crypto).

The cleaned up library is much more user-friendly than the SHA-1 code,
so this also significantly tidies up the BPF digest code.

This is intended for 4.10.  If this series misses 4.10 and nothing
takes its place, then we'll have an unpleasant ABI stability
situation.

Andy Lutomirski (6):
  crypto/sha256: Refactor the API so it can be used without shash
  crypto/sha256: Make the sha256 library functions selectable
  bpf: Use SHA256 instead of SHA1 for bpf digests
  bpf: Avoid copying the entire BPF program when hashing it
  bpf: Rename fdinfo's prog_digest to prog_sha256
  net: Rename TCA*BPF_DIGEST to ..._SHA256

 arch/arm/crypto/sha2-ce-glue.c      | 10 +++---
 arch/arm/crypto/sha256_glue.c       | 23 +++++++++-----
 arch/arm/crypto/sha256_neon_glue.c  | 34 ++++++++++----------
 arch/arm64/crypto/sha2-ce-glue.c    | 13 ++++----
 arch/arm64/crypto/sha256-glue.c     | 59 +++++++++++++++++++---------------
 arch/x86/crypto/sha256_ssse3_glue.c | 46 ++++++++++++++++-----------
 arch/x86/purgatory/purgatory.c      |  2 +-
 arch/x86/purgatory/sha256.c         | 25 ++-------------
 arch/x86/purgatory/sha256.h         | 22 -------------
 crypto/Kconfig                      |  8 +++++
 crypto/Makefile                     |  2 +-
 crypto/sha256_generic.c             | 54 +++++++++++++++++++++++--------
 include/crypto/sha.h                | 33 ++++++++++++++++---
 include/crypto/sha256_base.h        | 40 +++++++----------------
 include/linux/filter.h              | 11 ++-----
 include/uapi/linux/pkt_cls.h        |  2 +-
 include/uapi/linux/tc_act/tc_bpf.h  |  2 +-
 init/Kconfig                        |  1 +
 kernel/bpf/core.c                   | 63 +++++++++----------------------------
 kernel/bpf/syscall.c                |  2 +-
 net/sched/act_bpf.c                 |  2 +-
 net/sched/cls_bpf.c                 |  2 +-
 22 files changed, 225 insertions(+), 231 deletions(-)
 delete mode 100644 arch/x86/purgatory/sha256.h

-- 
2.9.3
