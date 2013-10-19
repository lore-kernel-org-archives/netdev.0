From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 5/6] ipv4: Use math to point per net sysctls into the
	appropriate struct net.
Date: Sat, 19 Oct 2013 16:27:03 -0700
Message-ID: <87vc0sg7ug.fsf@xmission.com>
References: <87r4bghml4.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87r4bghml4.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> (Eric W. Biederman's message of
	"Sat, 19 Oct 2013 16:23:19 -0700")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org


Simplify maintenance of ipv4_net_table by using math to point the per
net sysctls into the appropriate struct net, instead of manually
reassinging all of the variables into hard coded table slots.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 net/ipv4/sysctl_net_ipv4.c |   23 +++++------------------
 1 files changed, 5 insertions(+), 18 deletions(-)

diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 635dd4d5edcf..5a17eb605f77 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -833,28 +833,15 @@ static __net_init int ipv4_sysctl_init_net(struct net *net)
 
 	table = ipv4_net_table;
 	if (!net_eq(net, &init_net)) {
+		int i;
+
 		table = kmemdup(table, sizeof(ipv4_net_table), GFP_KERNEL);
 		if (table == NULL)
 			goto err_alloc;
 
-		table[0].data =
-			&net->ipv4.sysctl_icmp_echo_ignore_all;
-		table[1].data =
-			&net->ipv4.sysctl_icmp_echo_ignore_broadcasts;
-		table[2].data =
-			&net->ipv4.sysctl_icmp_ignore_bogus_error_responses;
-		table[3].data =
-			&net->ipv4.sysctl_icmp_errors_use_inbound_ifaddr;
-		table[4].data =
-			&net->ipv4.sysctl_icmp_ratelimit;
-		table[5].data =
-			&net->ipv4.sysctl_icmp_ratemask;
-		table[6].data =
-			&net->ipv4.sysctl_ping_group_range;
-		table[7].data =
-			&net->ipv4.sysctl_tcp_ecn;
-		table[8].data =
-			&net->ipv4.sysctl_local_ports.range;
+		/* Update the variables to point into the current struct net */
+		for (i = 0; i < ARRAY_SIZE(ipv4_net_table) - 1; i++)
+			table[i].data += (void *)net - (void *)&init_net;
 
 		/* Don't export sysctls to unprivileged users */
 		if (net->user_ns != &init_user_ns)
-- 
1.7.5.4
