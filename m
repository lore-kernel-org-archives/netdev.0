From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.6 05/31] kcm: fix /proc memory leak
Date: Wed,  6 Jul 2016 18:18:55 -0700
Message-ID: <20160707011557.740286994@linuxfoundation.org>
References: <20160707011557.518104444@linuxfoundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	stable@vger.kernel.org, Jiri Slaby <jslaby@suse.cz>,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <tom@herbertland.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:50102 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933176AbcGGBTn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2016 21:19:43 -0400
In-Reply-To: <20160707011557.518104444@linuxfoundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

4.6-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Jiri Slaby <jslaby@suse.cz>

[ Upstream commit d19af0a76444fde629667ecb823c0ee28f9f67d8 ]

Every open of /proc/net/kcm leaks 16 bytes of memory as is reported by
kmemleak:
unreferenced object 0xffff88059c0e3458 (size 192):
  comm "cat", pid 1401, jiffies 4294935742 (age 310.720s)
  hex dump (first 32 bytes):
    28 45 71 96 05 88 ff ff 00 10 00 00 00 00 00 00  (Eq.............
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
  backtrace:
    [<ffffffff8156a2de>] kmem_cache_alloc_trace+0x16e/0x230
    [<ffffffff8162a479>] seq_open+0x79/0x1d0
    [<ffffffffa0578510>] kcm_seq_open+0x0/0x30 [kcm]
    [<ffffffff8162a479>] seq_open+0x79/0x1d0
    [<ffffffff8162a8cf>] __seq_open_private+0x2f/0xa0
    [<ffffffff81712548>] seq_open_net+0x38/0xa0
...

It is caused by a missing free in the ->release path. So fix it by
providing seq_release_net as the ->release method.

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Fixes: cd6e111bf5 (kcm: Add statistics and proc interfaces)
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Tom Herbert <tom@herbertland.com>
Cc: netdev@vger.kernel.org
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 net/kcm/kcmproc.c |    1 +
 1 file changed, 1 insertion(+)

--- a/net/kcm/kcmproc.c
+++ b/net/kcm/kcmproc.c
@@ -241,6 +241,7 @@ static const struct file_operations kcm_
 	.open		= kcm_seq_open,
 	.read		= seq_read,
 	.llseek		= seq_lseek,
+	.release	= seq_release_net,
 };
 
 static struct kcm_seq_muxinfo kcm_seq_muxinfo = {
