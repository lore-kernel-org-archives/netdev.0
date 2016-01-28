From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net PATCH] fib_trie: Fix shift by 32 in fib_table_lookup
Date: Thu, 28 Jan 2016 13:42:24 -0800
Message-ID: <20160128214224.11296.99019.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, davem@davemloft.net,
	alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:36667 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755848AbcA1Vm1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 16:42:27 -0500
Received: by mail-pa0-f47.google.com with SMTP id yy13so29262306pab.3
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 13:42:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fib_table_lookup function had a shift by 32 that triggered a UBSAN
warning.  This was due to the fact that I had placed the shift first an=
d
then followed it with the check for the suffix length to ignore the
undefined behavior.  If we reorder this so that we verify the suffix is
less than 32 before shifting the value we can avoid the issue.

Reported-by: Toralf F=C3=B6rster <toralf.foerster@gmx.de>
Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 net/ipv4/fib_trie.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 744e5936c10d..22e73171ea63 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1396,9 +1396,10 @@ found:
 		struct fib_info *fi =3D fa->fa_info;
 		int nhsel, err;
=20
-		if ((index >=3D (1ul << fa->fa_slen)) &&
-		    ((BITS_PER_LONG > KEYLENGTH) || (fa->fa_slen !=3D KEYLENGTH)))
-			continue;
+		if ((BITS_PER_LONG > KEYLENGTH) || (fa->fa_slen < KEYLENGTH)) {
+			if (index >=3D (1ul << fa->fa_slen))
+				continue;
+		}
 		if (fa->fa_tos && fa->fa_tos !=3D flp->flowi4_tos)
 			continue;
 		if (fi->fib_dead)
