From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 2/6] tcp_memcontrol: Remove setting cgroup settings via sysctl
Date: Sat, 19 Oct 2013 16:24:52 -0700
Message-ID: <87eh7ghmij.fsf@xmission.com>
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


The code is broken and does not constrain sysctl_tcp_mem as
tcp_update_limit does.  With the result that it allows the cgroup tcp
memory limits to be bypassed.

The semantics are broken as the settings are not per netns and are in a
per netns table, and instead looks at current.

Since the code is broken in both design and implementation and does not
implement the functionality for which it was written remove it.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 include/net/tcp_memcontrol.h |    1 -
 net/ipv4/sysctl_net_ipv4.c   |   39 ++-------------------------------------
 net/ipv4/tcp_memcontrol.c    |   14 --------------
 3 files changed, 2 insertions(+), 52 deletions(-)

diff --git a/include/net/tcp_memcontrol.h b/include/net/tcp_memcontrol.h
index 88cdd1cb992e..af0c0680a873 100644
--- a/include/net/tcp_memcontrol.h
+++ b/include/net/tcp_memcontrol.h
@@ -14,5 +14,4 @@ struct tcp_memcontrol {
 struct cg_proto *tcp_proto_cgroup(struct mem_cgroup *memcg);
 int tcp_init_cgroup(struct mem_cgroup *memcg, struct cgroup_subsys *ss);
 void tcp_destroy_cgroup(struct mem_cgroup *memcg);
-void tcp_prot_mem(struct mem_cgroup *memcg, long val, int idx);
 #endif /* _TCP_MEMCG_H */
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index c08f096d46b5..5f0bb8786929 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -204,43 +204,8 @@ static int ipv4_tcp_mem(struct ctl_table *ctl, int write,
 			   void __user *buffer, size_t *lenp,
 			   loff_t *ppos)
 {
-	int ret;
-	unsigned long vec[3];
-	struct net *net = current->nsproxy->net_ns;
-#ifdef CONFIG_MEMCG_KMEM
-	struct mem_cgroup *memcg;
-#endif
-
-	struct ctl_table tmp = {
-		.data = &vec,
-		.maxlen = sizeof(vec),
-		.mode = ctl->mode,
-	};
-
-	if (!write) {
-		ctl->data = &net->ipv4.sysctl_tcp_mem;
-		return proc_doulongvec_minmax(ctl, write, buffer, lenp, ppos);
-	}
-
-	ret = proc_doulongvec_minmax(&tmp, write, buffer, lenp, ppos);
-	if (ret)
-		return ret;
-
-#ifdef CONFIG_MEMCG_KMEM
-	rcu_read_lock();
-	memcg = mem_cgroup_from_task(current);
-
-	tcp_prot_mem(memcg, vec[0], 0);
-	tcp_prot_mem(memcg, vec[1], 1);
-	tcp_prot_mem(memcg, vec[2], 2);
-	rcu_read_unlock();
-#endif
-
-	net->ipv4.sysctl_tcp_mem[0] = vec[0];
-	net->ipv4.sysctl_tcp_mem[1] = vec[1];
-	net->ipv4.sysctl_tcp_mem[2] = vec[2];
-
-	return 0;
+	ctl->data = &current->nsproxy->net_ns->ipv4.sysctl_tcp_mem;
+	return proc_doulongvec_minmax(ctl, write, buffer, lenp, ppos);
 }
 
 static int proc_tcp_fastopen_key(struct ctl_table *ctl, int write,
diff --git a/net/ipv4/tcp_memcontrol.c b/net/ipv4/tcp_memcontrol.c
index 82985d1dc9af..e7c01fcf5716 100644
--- a/net/ipv4/tcp_memcontrol.c
+++ b/net/ipv4/tcp_memcontrol.c
@@ -226,20 +226,6 @@ static int tcp_cgroup_reset(struct cgroup_subsys_state *css, unsigned int event)
 	return 0;
 }
 
-void tcp_prot_mem(struct mem_cgroup *memcg, long val, int idx)
-{
-	struct tcp_memcontrol *tcp;
-	struct cg_proto *cg_proto;
-
-	cg_proto = tcp_prot.proto_cgroup(memcg);
-	if (!cg_proto)
-		return;
-
-	tcp = tcp_from_cgproto(cg_proto);
-
-	tcp->tcp_prot_mem[idx] = val;
-}
-
 static struct cftype tcp_files[] = {
 	{
 		.name = "kmem.tcp.limit_in_bytes",
-- 
1.7.5.4
