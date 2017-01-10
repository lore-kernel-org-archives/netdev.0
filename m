From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v2 0/8] Switch BPF's digest to SHA256
Date: Tue, 10 Jan 2017 15:24:38 -0800
Message-ID: <cover.1484090585.git.luto@kernel.org>
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

I can imagine future uses for the new-in-4.10 BPF digest feature that
would be problematic if malicious users could produce collisions, and
SHA-1 is no longer consdiered to be collision-free.  Even without
needing collision resistance, SHA-1 is no longer recommended for new
applications.  Switch the BPF digest to SHA-256 instead.

The actual switchover is trivial.  Most of this series consists of
cleanups to the SHA256 code to make it usable as a standalone library
(since BPF should not depend on crypto).

The cleaned up library is much more user-friendly than the SHA-1 code,
so this also significantly tidies up the BPF digest code.

This is intended for 4.10.  If this series misses 4.10 and nothing
takes its place, then we'll have an unpleasant ABI stability
situation.

NB: I would be happy to make parallel changes to the SHA-512 code if
the crypto folks would like for me to do so.  I haven't yet because I
wanted to minimize churn.  Also, the changes will be essentially
identical to the SHA-256 changes and I want to get the latter
reviewed first.

Andy Lutomirski (8):
  crypto/sha256: Factor out the parts of base API that don't use
    shash_desc
  crypto/sha256: Export a sha256_{init,update,final}_direct() API
  crypto/sha256: Build the SHA256 core separately from the crypto module
  bpf: Use SHA256 instead of SHA1 for bpf digests
  bpf: Avoid copying the entire BPF program when hashing it
  bpf: Rename fdinfo's prog_digest to prog_sha256
  net: Rename TCA*BPF_DIGEST to ..._SHA256
  crypto/testmgr: Allocate only the required output size for hash tests

 crypto/Kconfig                     |   8 ++
 crypto/Makefile                    |   1 +
 crypto/sha256_direct.c             | 238 +++++++++++++++++++++++++++++++++++++
 crypto/sha256_generic.c            | 215 ++-------------------------------
 crypto/testmgr.c                   |   9 +-
 include/crypto/sha.h               |  24 ++++
 include/crypto/sha256_base.h       |  58 +++++----
 include/linux/filter.h             |  11 +-
 include/uapi/linux/pkt_cls.h       |   2 +-
 include/uapi/linux/tc_act/tc_bpf.h |   2 +-
 init/Kconfig                       |   1 +
 kernel/bpf/core.c                  |  63 +++-------
 kernel/bpf/syscall.c               |   2 +-
 net/sched/act_bpf.c                |   2 +-
 net/sched/cls_bpf.c                |   2 +-
 15 files changed, 343 insertions(+), 295 deletions(-)
 create mode 100644 crypto/sha256_direct.c

-- 
2.9.3
