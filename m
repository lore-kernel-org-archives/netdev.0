From: Nikolay Borisov <nborisov@suse.com>
Subject: [PATCH] igmp: Fix regression caused by igmp sysctl namespace code.
Date: Wed,  9 Aug 2017 08:52:55 +0300
Message-ID: <1502257975-32218-1-git-send-email-nborisov@suse.com>
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
        netdev@vger.kernel.org, Nikolay Borisov <nborisov@suse.com>,
        "# 4 . 6" <stable@vger.kernel.org>
To: davem@davemloft.net
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit dcd87999d415 ("igmp: net: Move igmp namespace init to correct file")
moved the igmp sysctls initialization from tcp_sk_init to igmp_net_init. This
function is only called as part of per-namespace initialization, only if
CONFIG_IP_MULTICAST is defined, otherwise igmp_mc_init() call in ip_init is
compiled out, casuing the igmp pernet ops to not be registerd and those sysctl
being left initialized with 0. However, there are certain functions, such as
ip_mc_join_group which are always compiled and make use of some of those
sysctls. Let's do a partial revert of the aforementioned commit and move the
sysctl initialization back into tcp_sk_init, that way they will always have
sane values.

Fixes: dcd87999d415 ("igmp: net: Move igmp namespace init to correct file")
Link: https://bugzilla.kernel.org/show_bug.cgi?id=196595
Reported-by: Gerardo Exequiel Pozzi <vmlinuz386@gmail.com>
Tested-by: Gerardo Exequiel Pozzi <vmlinuz386@gmail.com>
Signed-off-by: Nikolay Borisov <nborisov@suse.com>
Cc: <stable@vger.kernel.org> # 4.6
---
 net/ipv4/igmp.c     | 6 ------
 net/ipv4/tcp_ipv4.c | 6 ++++++
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 28f14afd0dd3..498706b072fb 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -2974,12 +2974,6 @@ static int __net_init igmp_net_init(struct net *net)
 		goto out_sock;
 	}
 
-	/* Sysctl initialization */
-	net->ipv4.sysctl_igmp_max_memberships = 20;
-	net->ipv4.sysctl_igmp_max_msf = 10;
-	/* IGMP reports for link-local multicast groups are enabled by default */
-	net->ipv4.sysctl_igmp_llm_reports = 1;
-	net->ipv4.sysctl_igmp_qrv = 2;
 	return 0;
 
 out_sock:
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index a20e7f03d5f7..64ba2c93d396 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2528,6 +2528,12 @@ static int __net_init tcp_sk_init(struct net *net)
 	net->ipv4.sysctl_tcp_window_scaling = 1;
 	net->ipv4.sysctl_tcp_timestamps = 1;
 
+	net->ipv4.sysctl_igmp_max_memberships = 20;
+	net->ipv4.sysctl_igmp_max_msf = 10;
+	/* IGMP reports for link-local multicast groups are enabled by default */
+	net->ipv4.sysctl_igmp_llm_reports = 1;
+	net->ipv4.sysctl_igmp_qrv = 2;
+
 	return 0;
 fail:
 	tcp_sk_exit(net);
-- 
2.7.4
