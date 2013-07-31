From: Roman Gushchin <klamm@yandex-team.ru>
Subject: [PATCH] net: check net.core.somaxconn sysctl values
Date: Wed, 31 Jul 2013 17:57:35 +0400
Message-ID: <51F917CF.7010905@yandex-team.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, raise.sail@gmail.com,
	ebiederm@xmission.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It's possible to assign an invalid value to the net.core.somaxconn
sysctl variable, because there is no checks at all.

The sk_max_ack_backlog field of the sock structure is defined as
unsigned short. Therefore, the backlog argument in inet_listen()
shouldn't exceed USHRT_MAX. The backlog argument in the listen() syscall
is truncated to the somaxconn value. So, the somaxconn value shouldn't
exceed 65535 (USHRT_MAX).
Also, negative values of somaxconn are meaningless.

before:
$ sysctl -w net.core.somaxconn=256
net.core.somaxconn = 256
$ sysctl -w net.core.somaxconn=65536
net.core.somaxconn = 65536
$ sysctl -w net.core.somaxconn=-100
net.core.somaxconn = -100

after:
$ sysctl -w net.core.somaxconn=256
net.core.somaxconn = 256
$ sysctl -w net.core.somaxconn=65536
error: "Invalid argument" setting key "net.core.somaxconn"
$ sysctl -w net.core.somaxconn=-100
error: "Invalid argument" setting key "net.core.somaxconn"

Signed-off-by: Roman Gushchin <klamm@yandex-team.ru>
---
  net/core/sysctl_net_core.c | 6 +++++-
  1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index cfdb46a..2ff093b 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -20,7 +20,9 @@
  #include <net/sock.h>
  #include <net/net_ratelimit.h>

+static int zero = 0;
  static int one = 1;
+static int ushort_max = USHRT_MAX;

  #ifdef CONFIG_RPS
  static int rps_sock_flow_sysctl(ctl_table *table, int write,
@@ -204,7 +206,9 @@ static struct ctl_table netns_core_table[] = {
  		.data		= &init_net.core.sysctl_somaxconn,
  		.maxlen		= sizeof(int),
  		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.extra1		= &zero,
+		.extra2		= &ushort_max,
+		.proc_handler	= proc_dointvec_minmax
  	},
  	{ }
  };
-- 
1.8.1.2
