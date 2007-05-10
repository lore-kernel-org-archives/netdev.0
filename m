From: David Howells <dhowells@redhat.com>
Subject: [PATCH 1/2] AFS: Fix interminable loop in
	afs_write_back_from_locked_page()
Date: Thu, 10 May 2007 15:33:34 +0100
Message-ID: <20070510143334.19485.26042.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	dhowells@redhat.com
To: akpm@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52589 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755092AbXEJPXU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2007 11:23:20 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46ollowing bug was uncovered by compiling with '-W' flag:

  CC [M]  fs/afs/write.o
fs/afs/write.c: In function =E2=80=98afs_write_back_from_locked_page=E2=
=80=99:
fs/afs/write.c:398: warning: comparison of unsigned expression >=3D 0 i=
s always true

Loop variable 'n' is unsigned, so wraps around happily as far as I can
see. Trival fix attached (compile tested only).

Signed-Off-By: Mika Kukkonen <mikukkon@iki.fi>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/afs/write.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/afs/write.c b/fs/afs/write.c
index 67ae4db..28f3751 100644
--- a/fs/afs/write.c
+++ b/fs/afs/write.c
@@ -395,8 +395,9 @@ static int afs_write_back_from_locked_page(struct a=
fs_writeback *wb,
 		if (n =3D=3D 0)
 			goto no_more;
 		if (pages[0]->index !=3D start) {
-			for (n--; n >=3D 0; n--)
-				put_page(pages[n]);
+			do {
+				put_page(pages[--n]);
+			} while (n > 0);
 			goto no_more;
 		}
=20

