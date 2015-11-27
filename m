From: Peter Hurley <peter@hurleysoftware.com>
Subject: [PATCH] wan/x25: Fix use-after-free in x25_asy_open_tty()
Date: Fri, 27 Nov 2015 14:18:39 -0500
Message-ID: <1448651919-4239-1-git-send-email-peter@hurleysoftware.com>
Cc: Jiri Slaby <jslaby@suse.cz>, David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Sasha Levin <sasha.levin@oracle.com>,
	Peter Hurley <peter@hurleysoftware.com>, stable@vger.kernel.org
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The N_X25 line discipline may access the previous line discipline's closed
and already-freed private data on open [1].

The tty->disc_data field _never_ refers to valid data on entry to the
line discipline's open() method. Rather, the ldisc is expected to
initialize that field for its own use for the lifetime of the instance
(ie. from open() to close() only).

[1]
    [  634.336761] ==================================================================
    [  634.338226] BUG: KASAN: use-after-free in x25_asy_open_tty+0x13d/0x490 at addr ffff8800a743efd0
    [  634.339558] Read of size 4 by task syzkaller_execu/8981
    [  634.340359] =============================================================================
    [  634.341598] BUG kmalloc-512 (Not tainted): kasan: bad access detected
    ...
    [  634.405018] Call Trace:
    [  634.405277] dump_stack (lib/dump_stack.c:52)
    [  634.405775] print_trailer (mm/slub.c:655)
    [  634.406361] object_err (mm/slub.c:662)
    [  634.406824] kasan_report_error (mm/kasan/report.c:138 mm/kasan/report.c:236)
    [  634.409581] __asan_report_load4_noabort (mm/kasan/report.c:279)
    [  634.411355] x25_asy_open_tty (drivers/net/wan/x25_asy.c:559 (discriminator 1))
    [  634.413997] tty_ldisc_open.isra.2 (drivers/tty/tty_ldisc.c:447)
    [  634.414549] tty_set_ldisc (drivers/tty/tty_ldisc.c:567)
    [  634.415057] tty_ioctl (drivers/tty/tty_io.c:2646 drivers/tty/tty_io.c:2879)
    [  634.423524] do_vfs_ioctl (fs/ioctl.c:43 fs/ioctl.c:607)
    [  634.427491] SyS_ioctl (fs/ioctl.c:622 fs/ioctl.c:613)
    [  634.427945] entry_SYSCALL_64_fastpath (arch/x86/entry/entry_64.S:188)

Reported-and-tested-by: Sasha Levin <sasha.levin@oracle.com>
Cc: <stable@vger.kernel.org>
Signed-off-by: Peter Hurley <peter@hurleysoftware.com>
---
 drivers/net/wan/x25_asy.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/drivers/net/wan/x25_asy.c b/drivers/net/wan/x25_asy.c
index 5c47b01..cd39025 100644
--- a/drivers/net/wan/x25_asy.c
+++ b/drivers/net/wan/x25_asy.c
@@ -549,16 +549,12 @@ static void x25_asy_receive_buf(struct tty_struct *tty,
 
 static int x25_asy_open_tty(struct tty_struct *tty)
 {
-	struct x25_asy *sl = tty->disc_data;
+	struct x25_asy *sl;
 	int err;
 
 	if (tty->ops->write == NULL)
 		return -EOPNOTSUPP;
 
-	/* First make sure we're not already connected. */
-	if (sl && sl->magic == X25_ASY_MAGIC)
-		return -EEXIST;
-
 	/* OK.  Find a free X.25 channel to use. */
 	sl = x25_asy_alloc();
 	if (sl == NULL)
-- 
2.6.3
