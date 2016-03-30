From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: bpf: net/core/filter.c:2115 suspicious
 rcu_dereference_protected() usage!
Date: Wed, 30 Mar 2016 14:24:19 +0200
Message-ID: <20160330122418.GD15048@unicorn.suse.cz>
References: <56CB29D5.9090000@oracle.com>
 <20160329125823.GB15048@unicorn.suse.cz>
 <56FA8935.8030109@iogearbox.net>
 <56FA93AF.8060001@iogearbox.net>
 <20160330094224.GC15048@unicorn.suse.cz>
 <56FBB998.5090504@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sasha Levin <sasha.levin@oracle.com>, Jiri Slaby <jslaby@suse.cz>,
	"David S. Miller" <davem@davemloft.net>, ast@plumgrid.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <56FBB998.5090504@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 30, 2016 at 01:33:44PM +0200, Daniel Borkmann wrote:
> On 03/30/2016 11:42 AM, Michal Kubecek wrote:
> >
> >I'm just not sure checking if we hold the right lock depending on caller
> >is worth the extra complexity. After all, what is really needed is to
> >hold _some_ lock guaranteeing sk_attach_prog() and sk_detach_filter()
> >are safe so that just changing the condition in both to
> >
> >   sock_owned_by_user(sk) || lockdep_rtnl_is_held()
> 
> It would certainly silence it, but would be less accurate in terms of lock
> proving as opposed to the diff above. E.g. rntl could be held elsewhere,
> while someone attaches a socket filter w/o having locked the socket (currently
> not the case, but it would kind of defeat the purpose of rcu_dereference_protected()
> here). Was thinking about using a extra socket flag to indicate it's
> externally managed, but it's not really worth wasting sk's flags bit
> space just for this corner case.

Originally my reasoning was that to actually hide a locking issue from
lockdep, this would have to happen every time we get down into the
function which is unlikely. But thinking about it again, this code path
is not so frequent and the fuzzers tend to do strange things so that it
could really happen.

Sasha/Jiri, could you test the patch with your testcases? I received it
corrupted (strange leading whitespaces) so I better add cleaned up
version below.

                                                         Michal Kubecek


diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index afdf950617c3..510e90a6bb26 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -622,7 +622,8 @@ static int tun_attach(struct tun_struct *tun, struct file *file, bool skip_filte
 
 	/* Re-attach the filter to persist device */
 	if (!skip_filter && (tun->filter_attached == true)) {
-		err = sk_attach_filter(&tun->fprog, tfile->socket.sk);
+		err = __sk_attach_filter(&tun->fprog, tfile->socket.sk,
+					 lockdep_rtnl_is_held());
 		if (!err)
 			goto out;
 	}
@@ -1822,7 +1823,7 @@ static void tun_detach_filter(struct tun_struct *tun, int n)
 
 	for (i = 0; i < n; i++) {
 		tfile = rtnl_dereference(tun->tfiles[i]);
-		sk_detach_filter(tfile->socket.sk);
+		__sk_detach_filter(tfile->socket.sk, lockdep_rtnl_is_held());
 	}
 
 	tun->filter_attached = false;
@@ -1835,7 +1836,8 @@ static int tun_attach_filter(struct tun_struct *tun)
 
 	for (i = 0; i < tun->numqueues; i++) {
 		tfile = rtnl_dereference(tun->tfiles[i]);
-		ret = sk_attach_filter(&tun->fprog, tfile->socket.sk);
+		ret = __sk_attach_filter(&tun->fprog, tfile->socket.sk,
+					 lockdep_rtnl_is_held());
 		if (ret) {
 			tun_detach_filter(tun, i);
 			return ret;
diff --git a/include/linux/filter.h b/include/linux/filter.h
index 43aa1f8855c7..a51a5361695f 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -465,10 +465,14 @@ int bpf_prog_create_from_user(struct bpf_prog **pfp, struct sock_fprog *fprog,
 void bpf_prog_destroy(struct bpf_prog *fp);
 
 int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk);
+int __sk_attach_filter(struct sock_fprog *fprog, struct sock *sk,
+		       bool locked);
 int sk_attach_bpf(u32 ufd, struct sock *sk);
 int sk_reuseport_attach_filter(struct sock_fprog *fprog, struct sock *sk);
 int sk_reuseport_attach_bpf(u32 ufd, struct sock *sk);
 int sk_detach_filter(struct sock *sk);
+int __sk_detach_filter(struct sock *sk, bool locked);
+
 int sk_get_filter(struct sock *sk, struct sock_filter __user *filter,
 		  unsigned int len);
 
diff --git a/net/core/filter.c b/net/core/filter.c
index b7177d01ecb0..dfb4561a2247 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1149,7 +1149,8 @@ void bpf_prog_destroy(struct bpf_prog *fp)
 }
 EXPORT_SYMBOL_GPL(bpf_prog_destroy);
 
-static int __sk_attach_prog(struct bpf_prog *prog, struct sock *sk)
+static int __sk_attach_prog(struct bpf_prog *prog, struct sock *sk,
+			    bool locked)
 {
 	struct sk_filter *fp, *old_fp;
 
@@ -1165,10 +1166,8 @@ static int __sk_attach_prog(struct bpf_prog *prog, struct sock *sk)
 		return -ENOMEM;
 	}
 
-	old_fp = rcu_dereference_protected(sk->sk_filter,
-					   sock_owned_by_user(sk));
+	old_fp = rcu_dereference_protected(sk->sk_filter, locked);
 	rcu_assign_pointer(sk->sk_filter, fp);
-
 	if (old_fp)
 		sk_filter_uncharge(sk, old_fp);
 
@@ -1247,7 +1246,8 @@ struct bpf_prog *__get_filter(struct sock_fprog *fprog, struct sock *sk)
  * occurs or there is insufficient memory for the filter a negative
  * errno code is returned. On success the return is zero.
  */
-int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
+int __sk_attach_filter(struct sock_fprog *fprog, struct sock *sk,
+		       bool locked)
 {
 	struct bpf_prog *prog = __get_filter(fprog, sk);
 	int err;
@@ -1255,7 +1255,7 @@ int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
 	if (IS_ERR(prog))
 		return PTR_ERR(prog);
 
-	err = __sk_attach_prog(prog, sk);
+	err = __sk_attach_prog(prog, sk, locked);
 	if (err < 0) {
 		__bpf_prog_release(prog);
 		return err;
@@ -1263,7 +1263,12 @@ int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
 
 	return 0;
 }
-EXPORT_SYMBOL_GPL(sk_attach_filter);
+EXPORT_SYMBOL_GPL(__sk_attach_filter);
+
+int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
+{
+	return __sk_attach_filter(fprog, sk, sock_owned_by_user(sk));
+}
 
 int sk_reuseport_attach_filter(struct sock_fprog *fprog, struct sock *sk)
 {
@@ -1309,7 +1314,7 @@ int sk_attach_bpf(u32 ufd, struct sock *sk)
 	if (IS_ERR(prog))
 		return PTR_ERR(prog);
 
-	err = __sk_attach_prog(prog, sk);
+	err = __sk_attach_prog(prog, sk, sock_owned_by_user(sk));
 	if (err < 0) {
 		bpf_prog_put(prog);
 		return err;
@@ -2247,7 +2252,7 @@ static int __init register_sk_filter_ops(void)
 }
 late_initcall(register_sk_filter_ops);
 
-int sk_detach_filter(struct sock *sk)
+int __sk_detach_filter(struct sock *sk, bool locked)
 {
 	int ret = -ENOENT;
 	struct sk_filter *filter;
@@ -2255,8 +2260,7 @@ int sk_detach_filter(struct sock *sk)
 	if (sock_flag(sk, SOCK_FILTER_LOCKED))
 		return -EPERM;
 
-	filter = rcu_dereference_protected(sk->sk_filter,
-					   sock_owned_by_user(sk));
+	filter = rcu_dereference_protected(sk->sk_filter, locked);
 	if (filter) {
 		RCU_INIT_POINTER(sk->sk_filter, NULL);
 		sk_filter_uncharge(sk, filter);
@@ -2265,7 +2269,12 @@ int sk_detach_filter(struct sock *sk)
 
 	return ret;
 }
-EXPORT_SYMBOL_GPL(sk_detach_filter);
+EXPORT_SYMBOL_GPL(__sk_detach_filter);
+
+int sk_detach_filter(struct sock *sk)
+{
+	return __sk_detach_filter(sk, sock_owned_by_user(sk));
+}
 
 int sk_get_filter(struct sock *sk, struct sock_filter __user *ubuf,
 		  unsigned int len)
