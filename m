From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [RFC PATCH 0/2] mac80211: use crypto shash for AES cmac
Date: Fri,  3 Feb 2017 19:25:53 +0000
Message-ID: <1486149955-11825-1-git-send-email-ard.biesheuvel@linaro.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        jouni@qca.qualcomm.com, Ard Biesheuvel <ard.biesheuvel@linaro.org>
To: johannes@sipsolutions.net, linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:38856 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752012AbdBCT0T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 14:26:19 -0500
Received: by mail-wm0-f41.google.com with SMTP id r141so42027683wmg.1
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 11:26:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is something I spotted while working on AES in various modes for
ARM and arm64.

The mac80211 aes_cmac code reimplements the CMAC algorithm based on the
core AES cipher, which is rather restrictive in how platforms can satisfy
the dependency on this algorithm. For instance, SIMD implementations may
have a considerable setup time, which cannot be amortized over the entire
input when calling into the crypto API one block at a time. Also, it prevents
the use of more secure fixed time implementations, since not all AES drivers
expose the cipher interface.

So switch aes_cmac to use a cmac(aes) shash. This requires a preparatory
patch so that we can remove the open coded implementation, which it shares
with the fils aead driver. That driver could receive the same treatment, in
which case we could replace patch #1 with one that carries it over first.

Note that this is an RFC. I have no idea how I would go about testing this
code, but I am on a mission to remove as many dependencies on the generic
AES cipher as I can.

Ard Biesheuvel (2):
  mac80211: fils_aead: clone shared CMAC functions into private version
  mac80211: aes-cmac: switch to shash CMAC driver

 net/mac80211/Kconfig     |   1 +
 net/mac80211/aes_cmac.c  | 137 +++++---------------
 net/mac80211/aes_cmac.h  |  15 +--
 net/mac80211/fils_aead.c |  68 ++++++++++
 net/mac80211/key.h       |   2 +-
 5 files changed, 110 insertions(+), 113 deletions(-)

-- 
2.7.4
