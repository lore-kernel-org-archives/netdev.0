From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the tip tree
Date: Thu, 17 Nov 2016 14:22:27 +1100
Message-ID: <20161117142227.7753ef12@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Christian Borntraeger <borntraeger@de.ibm.com>,
        Eric Dumazet <edumazet@google.com>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
        "H. Peter Anvin" <hpa@zytor.com>,
        Peter Zijlstra <peterz@infradead.org>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

After merging the tip tree, today's linux-next build (arm
multi_v7_defconfig) failed like this:

net/core/dev.c: In function 'sk_busy_loop':
net/core/dev.c:5065:3: error: implicit declaration of function 'cpu_relax_lowlatency' [-Werror=implicit-function-declaration]
   cpu_relax_lowlatency();
   ^

Caused by commit

  5bd0b85ba8bb ("locking/core, arch: Remove cpu_relax_lowlatency()")

interacting with commit

  217f69743681 ("net: busy-poll: allow preemption in sk_busy_loop()")

from the net-next tree.

I have applied the following merge fix patch.

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 17 Nov 2016 14:13:05 +1100
Subject: [PATCH] net: busy-poll: fix up for cpu_relax_lowlatency() removal

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 net/core/dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index d29d538ec5ad..6b9f8eb55b62 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5062,7 +5062,7 @@ bool sk_busy_loop(struct sock *sk, int nonblock)
 				return rc;
 			goto restart;
 		}
-		cpu_relax_lowlatency();
+		cpu_relax();
 	}
 	if (napi_poll)
 		busy_poll_stop(napi, have_poll_lock);
-- 
2.10.2

-- 
Cheers,
Stephen Rothwell
