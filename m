From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] [net-next] qlge: avoid memcpy buffer overflow
Date: Wed, 23 Aug 2017 15:59:49 +0200
Message-ID: <20170823135958.1379527-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, stable@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Kees Cook <keescook@chromium.org>,
        "Gustavo A. R. Silva" <gustavo@embeddedor.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Harish Patil <harish.patil@cavium.com>,
        Manish Chopra <manish.chopra@cavium.com>,
        Dept-GELinuxNICDev@cavium.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

gcc-8.0.0 (snapshot) points out that we copy a variable-length string
into a fixed length field using memcpy() with the destination length,
and that ends up copying whatever follows the string:

    inlined from 'ql_core_dump' at drivers/net/ethernet/qlogic/qlge/qlge_dbg.c:1106:2:
drivers/net/ethernet/qlogic/qlge/qlge_dbg.c:708:2: error: 'memcpy' reading 15 bytes from a region of size 14 [-Werror=stringop-overflow=]
  memcpy(seg_hdr->description, desc, (sizeof(seg_hdr->description)) - 1);

Changing it to use strncpy() will instead zero-pad the destination,
which seems to be the right thing to do here.

The bug is probably harmless, but it seems like a good idea to address
it in stable kernels as well, if only for the purpose of building with
gcc-8 without warnings.

Cc: stable@vger.kernel.org
Fixes: a61f80261306 ("qlge: Add ethtool register dump function.")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
Doesn't seem urgent to me, so please queue it for net-next if it
looks ok.

Interestingly, the hardened memcpy() functions in linux/string.h never
caught this problem event though I think they should have, but gcc-8
found it by default.
---
 drivers/net/ethernet/qlogic/qlge/qlge_dbg.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_dbg.c b/drivers/net/ethernet/qlogic/qlge/qlge_dbg.c
index 458d55ba423f..fe2599b83d09 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_dbg.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_dbg.c
@@ -705,7 +705,7 @@ static void ql_build_coredump_seg_header(
 	seg_hdr->cookie = MPI_COREDUMP_COOKIE;
 	seg_hdr->segNum = seg_number;
 	seg_hdr->segSize = seg_size;
-	memcpy(seg_hdr->description, desc, (sizeof(seg_hdr->description)) - 1);
+	strncpy(seg_hdr->description, desc, (sizeof(seg_hdr->description)) - 1);
 }
 
 /*
-- 
2.9.0
