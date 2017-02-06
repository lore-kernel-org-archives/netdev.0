From: Ard Biesheuvel <ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [PATCH v3 0/2] mac80211: use crypto shash for AES cmac
Date: Mon,  6 Feb 2017 10:49:26 +0000
Message-ID: <1486378168-31028-1-git-send-email-ard.biesheuvel@linaro.org>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        jouni-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org, Ard Biesheuvel <ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is something I spotted while working on AES in various modes for
ARM and arm64.

The mac80211 aes_cmac code reimplements the CMAC algorithm based on the
core AES cipher, which is rather restrictive in how platforms can satisfy
the dependency on this algorithm. For instance, SIMD implementations may
have a considerable setup time, which cannot be amortized over the entire
input when calling into the crypto API one block at a time. Also, it prevents
the use of more secure fixed time implementations, since not all AES drivers
expose the cipher interface.

So switch aes_cmac to use a cmac(aes) shash. Before updating the aes_cmac code
in patch #2, the FILS AEAD code is moved to using a cmac(aes) shash supplied by
the crypto API so that we can remove the open coded version entirely in the
second patch.

v3: - use more idiomatic SHASH_DESC_ON_STACK to allocate the shash descriptors
    - replace compound literal zero vectors with explicitly defined ones
    - drop a redundant memcpy() in #2

Ard Biesheuvel (2):
  mac80211: fils_aead: Use crypto api CMAC shash rather than bare cipher
  mac80211: aes-cmac: switch to shash CMAC driver

 net/mac80211/Kconfig     |   1 +
 net/mac80211/aes_cmac.c  | 126 ++++----------------
 net/mac80211/aes_cmac.h  |  15 +--
 net/mac80211/fils_aead.c |  74 +++++-------
 net/mac80211/key.h       |   2 +-
 5 files changed, 66 insertions(+), 152 deletions(-)

-- 
2.7.4
