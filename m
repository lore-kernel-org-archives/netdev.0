From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH v9 00/20] simplify crypto wait for async op
Date: Sun, 15 Oct 2017 10:19:45 +0100
Message-ID: <1508059209-25529-1-git-send-email-gilad@benyossef.com>
Cc: Ofir Drang <ofir.drang@arm.com>, linux-crypto@vger.kernel.org,
        linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
        keyrings@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-mediatek@lists.infradead.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-fscrypt@vger.kernel.org,
        netdev@vger.kernel.org, linux-ima-devel@lists.sourceforge.net,
        linux-ima-user@lists.sourceforge.net,
        linux-security-module@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        Jonathan Corbet <corbet@lwn.net>,
        David Howells <dhowells@redhat.com>,
        Tom Lendacky <thomas.lendacky@amd.com>,
        Gary Hook <gary.hook@amd.com>,
        Boris Brezillon <boris.brezillon@free-electrons.com>,
        Arnaud Ebalard <arno@natisbad.org>,
        Matthias Brugger <matthias.bgg@gmail.com>,
        Alasdair Kergon <agk@redhat.com>,
        Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com,
        Steve French <sfrench@samba.org>,
        "Theodore Y. Ts'o" <tytso@mit.edu>,
        Jaegeuk Kim <jaegeuk@kernel.org>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Mimi Zohar <zohar@linux.vnet.ibm.com>,
        Dmitry Kasatkin <dmitry.ka
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Many users of kernel async. crypto services have a pattern of
starting an async. crypto op and than using a completion
to wait for it to end.

This patch set simplifies this common use case in two ways:

First, by separating the return codes of the case where a
request is queued to a backlog due to the provider being
busy (-EBUSY) from the case the request has failed due
to the provider being busy and backlogging is not enabled
(-EAGAIN).

Next, this change is than built on to create a generic API
to wait for a async. crypto operation to complete.

The end result is a smaller code base and an API that is
easier to use and more difficult to get wrong.

The patch set was boot tested on x86_64 and arm64 which
at the very least tests the crypto users via testmgr and
tcrypt but I do note that I do not have access to some
of the HW whose drivers are modified nor do I claim I was
able to test all of the corner cases.

The patch set is based upon linux-next release tagged
next-20171013.

Changes from v8:
- Remove the translation of EAGAIN return code to the
  previous return code of EBUSY for the user space
  interface of algif as no one seems to rely on it as
  requested by Herbert Xu.

Changes from v7:
- Turn -EBUSY to -EAGAIN also in crypto using net
  code which I missed before, as has been pointed
  out by Harsh Jain.

Changes from v6:
- Fix brown paper bag compile error on marvell/cesa
  code.

Changes from v5:
- Remove redundant new line as spotted by Jonathan
  Cameron.
- Reworded dm-verity change commit message to better
  clarify potential issue averted by change as
  pointed out by Mikulas Patocka.

Changes from v4:
- Rebase on top of latest algif changes from Stephan
  Mueller.
- Fix typo in ccp patch title.

Changes from v3:
- Instead of changing the return code to indicate
  backlog queueing, change the return code to indicate
  transient busy state, as suggested by Herbert Xu.

Changes from v2:
- Patch title changed from "introduce crypto wait for
  async op" to better reflect the current state.
- Rebase on top of latest linux-next.
- Add a new return code of -EIOCBQUEUED for backlog
  queueing, as suggested by Herbert Xu.
- Transform more users to the new API.
- Update the drbg change to account for new init as
  indicated by Stephan Muller.

Changes from v1:
- Address review comments from Eric Biggers.
- Separated out bug fixes of existing code and rebase
  on top of that patch set.
- Rename 'ecr' to 'wait' in fscrypto code.
- Split patch introducing the new API from the change
  moving over the algif code which it originated from
  to the new API.
- Inline crypto_wait_req().
- Some code indentation fixes.

Gilad Ben-Yossef (20):
  crypto: change transient busy return code to -EAGAIN
  crypto: ccp: use -EAGAIN for transient busy indication
  net: use -EAGAIN for transient busy indication
  crypto: remove redundant backlog checks on EBUSY
  crypto: marvell/cesa: remove redundant backlog checks on EBUSY
  crypto: introduce crypto wait for async op
  crypto: move algif to generic async completion
  crypto: move pub key to generic async completion
  crypto: move drbg to generic async completion
  crypto: move gcm to generic async completion
  crypto: move testmgr to generic async completion
  fscrypt: move to generic async completion
  dm: move dm-verity to generic async completion
  cifs: move to generic async completion
  ima: move to generic async completion
  crypto: tcrypt: move to generic async completion
  crypto: talitos: move to generic async completion
  crypto: qce: move to generic async completion
  crypto: mediatek: move to generic async completion
  crypto: adapt api sample to use async. op wait

 Documentation/crypto/api-samples.rst |  52 ++-------
 crypto/af_alg.c                      |  27 -----
 crypto/ahash.c                       |  12 +--
 crypto/algapi.c                      |   6 +-
 crypto/algif_aead.c                  |   8 +-
 crypto/algif_hash.c                  |  30 +++---
 crypto/algif_skcipher.c              |   9 +-
 crypto/api.c                         |  13 +++
 crypto/asymmetric_keys/public_key.c  |  28 +----
 crypto/cryptd.c                      |   4 +-
 crypto/cts.c                         |   6 +-
 crypto/drbg.c                        |  36 ++-----
 crypto/gcm.c                         |  32 ++----
 crypto/lrw.c                         |   8 +-
 crypto/rsa-pkcs1pad.c                |  16 +--
 crypto/tcrypt.c                      |  84 +++++----------
 crypto/testmgr.c                     | 204 ++++++++++++-----------------------
 crypto/xts.c                         |   8 +-
 drivers/crypto/ccp/ccp-crypto-main.c |   8 +-
 drivers/crypto/ccp/ccp-dev.c         |   7 +-
 drivers/crypto/marvell/cesa.c        |   3 +-
 drivers/crypto/marvell/cesa.h        |   2 +-
 drivers/crypto/mediatek/mtk-aes.c    |  31 +-----
 drivers/crypto/qce/sha.c             |  30 +-----
 drivers/crypto/talitos.c             |  38 +------
 drivers/md/dm-verity-target.c        |  81 ++++----------
 drivers/md/dm-verity.h               |   5 -
 fs/cifs/smb2ops.c                    |  30 +-----
 fs/crypto/crypto.c                   |  28 +----
 fs/crypto/fname.c                    |  36 ++-----
 fs/crypto/fscrypt_private.h          |  10 --
 fs/crypto/keyinfo.c                  |  21 +---
 include/crypto/drbg.h                |   3 +-
 include/crypto/if_alg.h              |  15 +--
 include/linux/crypto.h               |  40 +++++++
 net/ipv4/ah4.c                       |   2 +-
 net/ipv4/esp4.c                      |   2 +-
 net/ipv6/ah6.c                       |   2 +-
 net/ipv6/esp6.c                      |   2 +-
 security/integrity/ima/ima_crypto.c  |  56 +++-------
 40 files changed, 297 insertions(+), 738 deletions(-)

-- 
2.7.4
