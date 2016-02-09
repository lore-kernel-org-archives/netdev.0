From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH 0/5] pre-decrement in error paths considered harmful
Date: Tue,  9 Feb 2016 21:11:11 +0100
Message-ID: <1455048677-19882-1-git-send-email-linux@rasmusvillemoes.dk>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>
To: dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org,
	intel-gfx@lists.freedesktop.org,
	netdev@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	linux-mm@kvack.org
Return-path: <owner-linux-mm@kvack.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

There are a few instances of

  for (i = 0; i < FOO; ++i) {
    ret = do_stuff(i)
    if (ret)
      goto err;
  }
  ...
  err:
  while (--i)
    undo_stuff(i);

At best, this fails to undo_stuff for i==0, but if i==0 was the case
that failed, we'll end up with an "infinite" loop in the error path
doing nasty stuff.

These were found with a simple coccinelle script

@@
expression i;
identifier l;
statement S;
@@
* l:
* while (--i)
    S

(and there were no false positives).

There's no dependencies between the patches; I just wanted to include
a common cover letter with a little background info.

Rasmus Villemoes (5):
  drm/gma500: fix error path in gma_intel_setup_gmbus()
  drm/i915: fix error path in intel_setup_gmbus()
  net/mlx4: fix some error handling in mlx4_multi_func_init()
  net: sxgbe: fix error paths in sxgbe_platform_probe()
  mm/backing-dev.c: fix error path in wb_init()

 drivers/gpu/drm/gma500/intel_gmbus.c                | 2 +-
 drivers/gpu/drm/i915/intel_i2c.c                    | 2 +-
 drivers/net/ethernet/mellanox/mlx4/cmd.c            | 4 ++--
 drivers/net/ethernet/samsung/sxgbe/sxgbe_platform.c | 4 ++--
 mm/backing-dev.c                                    | 2 +-
 5 files changed, 7 insertions(+), 7 deletions(-)

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
