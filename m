From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 1/3] net: Clean up SCM_CREDENTIALS code
Date: Thu, 21 Mar 2013 13:15:23 +1100 (EST)
Message-ID: <alpine.LRH.2.02.1303211315050.9518@tundra.namei.org>
References: <cover.1363815201.git.luto@amacapital.net> <3d7ffb6d9b73971f1a526fc490ef84ef7a33eecc.1363815201.git.luto@amacapital.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	David Howells <dhowells@redhat.com>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tundra.namei.org ([65.99.196.166]:42251 "EHLO tundra.namei.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752496Ab3CUCP1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Mar 2013 22:15:27 -0400
In-Reply-To: <3d7ffb6d9b73971f1a526fc490ef84ef7a33eecc.1363815201.git.luto@amacapital.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(adding David Howells)


On Wed, 20 Mar 2013, Andy Lutomirski wrote:

> I was curious whether the uids, gids, and pids passed around worked
> correctly in the presence of multiple namespaces.  I gave up trying
> to figure it out: there are two copies of the pid (one of which has
> type u32, which is odd), a struct cred * (!), and a separate kuid
> and kgid.  IOW, all of the relevant data is stored twice, and it's
> unclear which copy is used when.
> 
> I also wondered what prevented a SO_CREDENTIALS message from being
> recieved when the credentials weren't filled out.  Answer: not very
> much (and there have been serious security bugs here in the past).
> 
> So just rewrite the thing to store a pid_t relative to the init pid
> ns, a kuid, and a kgid, and to explicitly track whether the data is
> filled out.
> 
> I haven't played with the secid code.  I have no idea whether it has
> similar problems.
> 
> I haven't benchmarked this, but it should be a respectable speedup
> in the cases where the credentials are in use.
> 
> Signed-off-by: Andy Lutomirski <luto@amacapital.net>
> ---
> 
> Before, the program below printed this:
> 
> $ passcred
> My pid = 19873
> No SO_PASSCRED: uid=65534 gid=65534 pid=0  [this is a bug]
> SO_PASSCRED: uid=1000 gid=1000 pid=19873
> SO_PASSCRED, forked to pid 19874: uid=1000 gid=1000 pid=19874
> 
> # passcred
> My pid = 19886
> No SO_PASSCRED: uid=65534 gid=65534 pid=0
> SO_PASSCRED: uid=0 gid=0 pid=19886
> SO_PASSCRED, forked to pid 19887: uid=0 gid=0 pid=19887
> 
> 
> After:
> 
> # passcred
> My pid = 83
> No creds received
> SO_PASSCRED: uid=0 gid=0 pid=83
> SO_PASSCRED, forked to pid 84: uid=0 gid=0 pid=0
> 
> 
> #define _GNU_SOURCE
> #include <sys/types.h>
> #include <sys/wait.h>
> #include <sys/socket.h>
> #include <stdlib.h>
> #include <stdint.h>
> #include <stdbool.h>
> #include <stdio.h>
> #include <string.h>
> #include <unistd.h>
> #include <err.h>
> 
> static void send_str(int fd, const char *msg)
> {
> 	if (send(fd, msg, strlen(msg)+1, 0) < 0)
> 		err(1, "send");
> }
> 
> int main()
> {
> 	int fds[2];
> 	if (socketpair(AF_UNIX, SOCK_DGRAM, 0, fds))
> 		err(1, "socketpair");
> 
> 	send_str(fds[1], "No SO_PASSCRED");
> 
> 	int one = 1;
> 	if (setsockopt(fds[0], SOL_SOCKET, SO_PASSCRED, &one, sizeof(one)) != 0)
> 		err(1, "SO_PASSCRED");
> 
> 	send_str(fds[1], "SO_PASSCRED");
> 
> 	if (fork() == 0) {
> 		char msg[1024];
> 		sprintf(msg, "SO_PASSCRED, forked to pid %ld", (long)getpid());
> 		send_str(fds[1], msg);
> 		return 0;
> 	}
> 
> 	int status;
> 	wait(&status);
> 	printf("My pid = %ld\n", getpid());
> 
> 	for (int i = 0; i < 3; i++) {
> 		char buf[1024];
> 		char cbuf[CMSG_SPACE(sizeof(struct ucred))];
> 		struct iovec iov;
> 		iov.iov_base = &buf;
> 		iov.iov_len = sizeof(buf);
> 		struct msghdr hdr;
> 		memset(&hdr, 0, sizeof(hdr));
> 		hdr.msg_iov = &iov;
> 		hdr.msg_iovlen = 1;
> 		hdr.msg_control = cbuf;
> 		hdr.msg_controllen = sizeof(cbuf);
> 		ssize_t bytes = recvmsg(fds[0], &hdr, 0);
> 		if (bytes < 0)
> 			err(1, "recvmsg");
> 
> 		if (hdr.msg_flags & (MSG_TRUNC | MSG_CTRUNC))
> 			errx(1, "truncated");
> 
> 		struct ucred cred;
> 		bool ok = false;
> 
> 		for (struct cmsghdr *cmsg = CMSG_FIRSTHDR(&hdr); cmsg; cmsg = CMSG_NXTHDR(&hdr, cmsg)) {
> 			if (cmsg->cmsg_level == SOL_SOCKET &&
> 			    cmsg->cmsg_type == SCM_CREDENTIALS) {
> 				cred = *((struct ucred *)CMSG_DATA(cmsg));
> 				ok = true;
> 				break;
> 			}
> 		}
> 		if (!ok) {
> 			printf("No creds received\n");
> 		} else {
> 			printf("%s: uid=%ld gid=%ld pid=%ld\n",
> 			       buf, (long)cred.uid, (long)cred.gid, (long)cred.pid);
> 		}
> 	}
> 
> 	return 0;
> }
> 
> 
>  include/net/af_unix.h    |  6 ++--
>  include/net/scm.h        | 83 ++++++++++++++++++++++++++++++++----------------
>  net/core/scm.c           | 49 ++++++++++------------------
>  net/netlink/af_netlink.c | 14 +++++---
>  net/unix/af_unix.c       | 35 +++++++++-----------
>  5 files changed, 99 insertions(+), 88 deletions(-)
> 
> diff --git a/include/net/af_unix.h b/include/net/af_unix.h
> index 0a996a3..7874f3e 100644
> --- a/include/net/af_unix.h
> +++ b/include/net/af_unix.h
> @@ -27,12 +27,12 @@ struct unix_address {
>  	struct sockaddr_un name[0];
>  };
>  
> +/* This structure is identical to struct scm_cookie. */
>  struct unix_skb_parms {
> -	struct pid		*pid;		/* Skb credentials	*/
> -	const struct cred	*cred;
> +	struct scm_creds	creds;
>  	struct scm_fp_list	*fp;		/* Passed files		*/
>  #ifdef CONFIG_SECURITY_NETWORK
> -	u32			secid;		/* Security ID		*/
> +	u32			secid;		/* Passed security ID 	*/
>  #endif
>  };
>  
> diff --git a/include/net/scm.h b/include/net/scm.h
> index 975cca0..f6f0626 100644
> --- a/include/net/scm.h
> +++ b/include/net/scm.h
> @@ -13,9 +13,24 @@
>  #define SCM_MAX_FD	253
>  
>  struct scm_creds {
> -	u32	pid;
> -	kuid_t	uid;
> -	kgid_t	gid;
> +	bool has_creds;
> +
> +	/*
> +	 * Keeping reference counts (as to a struct pid *) in here is
> +	 * annoying -- things like skb_set_owner_[rw] and skb_clone assume
> +	 * that it's ok to memcpy skb->cb around.
> +	 *
> +	 * Fortunately (?) anything that uses the pid field in SCM_CREDENTIALS
> +	 * is fundamentally racy, since the networking code certainly isn't
> +	 * going to keep a reference alive *after* recvmsg.  So let's embrace
> +	 * the race condition at the cost of an extra hash lookup on receive.
> +	 *
> +	 * (There's an added benefit here: this approach doesn't write to
> +	 * any shared cachelines.)
> +	 */
> +	pid_t		init_ns_pid;
> +	kuid_t		uid;
> +	kgid_t		gid;
>  };
>  
>  struct scm_fp_list {
> @@ -25,15 +40,15 @@ struct scm_fp_list {
>  };
>  
>  struct scm_cookie {
> -	struct pid		*pid;		/* Skb credentials */
> -	const struct cred	*cred;
> +	struct scm_creds	creds;
>  	struct scm_fp_list	*fp;		/* Passed files		*/
> -	struct scm_creds	creds;		/* Skb credentials	*/
>  #ifdef CONFIG_SECURITY_NETWORK
>  	u32			secid;		/* Passed security ID 	*/
>  #endif
>  };
>  
> +#define SCM_COOKIE_INIT {}  /* All zeros is good. */
> +
>  extern void scm_detach_fds(struct msghdr *msg, struct scm_cookie *scm);
>  extern void scm_detach_fds_compat(struct msghdr *msg, struct scm_cookie *scm);
>  extern int __scm_send(struct socket *sock, struct msghdr *msg, struct scm_cookie *scm);
> @@ -50,39 +65,47 @@ static __inline__ void unix_get_peersec_dgram(struct socket *sock, struct scm_co
>  { }
>  #endif /* CONFIG_SECURITY_NETWORK */
>  
> -static __inline__ void scm_set_cred(struct scm_cookie *scm,
> -				    struct pid *pid, const struct cred *cred)
> +static __inline__ bool scm_creds_equal(const struct scm_creds *a,
> +                                       const struct scm_creds *b)
>  {
> -	scm->pid  = get_pid(pid);
> -	scm->cred = cred ? get_cred(cred) : NULL;
> -	scm->creds.pid = pid_vnr(pid);
> -	scm->creds.uid = cred ? cred->euid : INVALID_UID;
> -	scm->creds.gid = cred ? cred->egid : INVALID_GID;
> +	if (a->has_creds)
> +		return a->init_ns_pid == b->init_ns_pid &&
> +			uid_eq(a->uid, b->uid) && gid_eq(a->gid, b->gid);
> +	else
> +		return !b->has_creds;
>  }
>  
> -static __inline__ void scm_destroy_cred(struct scm_cookie *scm)
> +static __inline__ void scm_creds_from_current(struct scm_creds *creds)
>  {
> -	put_pid(scm->pid);
> -	scm->pid  = NULL;
> +	const struct cred *cred = get_current_cred();
> +	creds->has_creds = true;
> +	creds->init_ns_pid = task_tgid_nr(current);
> +	creds->uid = cred->uid;
> +	creds->gid = cred->gid;
> +}
>  
> -	if (scm->cred)
> -		put_cred(scm->cred);
> -	scm->cred = NULL;
> +static __inline__ void scm_creds_from_kernel(struct scm_creds *creds)
> +{
> +	creds->has_creds = true;
> +	creds->init_ns_pid = 0;
> +	creds->uid = GLOBAL_ROOT_UID;
> +	creds->gid = GLOBAL_ROOT_GID;
> +}
> +
> +static __inline__ void scm_creds_wipe(struct scm_creds *creds)
> +{
> +	creds->has_creds = false;
>  }
>  
>  static __inline__ void scm_destroy(struct scm_cookie *scm)
>  {
> -	scm_destroy_cred(scm);
>  	if (scm->fp)
>  		__scm_destroy(scm);
>  }
>  
>  static __inline__ int scm_send(struct socket *sock, struct msghdr *msg,
> -			       struct scm_cookie *scm, bool forcecreds)
> +			       struct scm_cookie *scm)
>  {
> -	memset(scm, 0, sizeof(*scm));
> -	if (forcecreds)
> -		scm_set_cred(scm, task_tgid(current), current_cred());
>  	unix_get_peersec_dgram(sock, scm);
>  	if (msg->msg_controllen <= 0)
>  		return 0;
> @@ -120,18 +143,22 @@ static __inline__ void scm_recv(struct socket *sock, struct msghdr *msg,
>  		return;
>  	}
>  
> -	if (test_bit(SOCK_PASSCRED, &sock->flags)) {
> +	if (test_bit(SOCK_PASSCRED, &sock->flags) && scm->creds.has_creds) {
>  		struct user_namespace *current_ns = current_user_ns();
>  		struct ucred ucreds = {
> -			.pid = scm->creds.pid,
>  			.uid = from_kuid_munged(current_ns, scm->creds.uid),
>  			.gid = from_kgid_munged(current_ns, scm->creds.gid),
>  		};
> +
> +		rcu_read_lock();
> +		/* On error, this will result in pid 0. */
> +		ucreds.pid = pid_vnr(find_pid_ns(scm->creds.init_ns_pid,
> +						 &init_pid_ns));
> +		rcu_read_unlock();
> +
>  		put_cmsg(msg, SOL_SOCKET, SCM_CREDENTIALS, sizeof(ucreds), &ucreds);
>  	}
>  
> -	scm_destroy_cred(scm);
> -
>  	scm_passec(sock, msg, scm);
>  
>  	if (!scm->fp)
> diff --git a/net/core/scm.c b/net/core/scm.c
> index 905dcc6..7dd7534 100644
> --- a/net/core/scm.c
> +++ b/net/core/scm.c
> @@ -157,8 +157,7 @@ int __scm_send(struct socket *sock, struct msghdr *msg, struct scm_cookie *p)
>  		case SCM_CREDENTIALS:
>  		{
>  			struct ucred creds;
> -			kuid_t uid;
> -			kgid_t gid;
> +			struct pid *pid;
>  			if (cmsg->cmsg_len != CMSG_LEN(sizeof(struct ucred)))
>  				goto error;
>  			memcpy(&creds, CMSG_DATA(cmsg), sizeof(struct ucred));
> @@ -166,41 +165,25 @@ int __scm_send(struct socket *sock, struct msghdr *msg, struct scm_cookie *p)
>  			if (err)
>  				goto error;
>  
> -			p->creds.pid = creds.pid;
> -			if (!p->pid || pid_vnr(p->pid) != creds.pid) {
> -				struct pid *pid;
> -				err = -ESRCH;
> -				pid = find_get_pid(creds.pid);
> -				if (!pid)
> -					goto error;
> -				put_pid(p->pid);
> -				p->pid = pid;
> -			}
> -
>  			err = -EINVAL;
> -			uid = make_kuid(current_user_ns(), creds.uid);
> -			gid = make_kgid(current_user_ns(), creds.gid);
> -			if (!uid_valid(uid) || !gid_valid(gid))
> +			p->creds.uid = make_kuid(current_user_ns(), creds.uid);
> +			p->creds.gid = make_kgid(current_user_ns(), creds.gid);
> +			if (!uid_valid(p->creds.uid) ||
> +			    !gid_valid(p->creds.gid))
>  				goto error;
>  
> -			p->creds.uid = uid;
> -			p->creds.gid = gid;
> -
> -			if (!p->cred ||
> -			    !uid_eq(p->cred->euid, uid) ||
> -			    !gid_eq(p->cred->egid, gid)) {
> -				struct cred *cred;
> -				err = -ENOMEM;
> -				cred = prepare_creds();
> -				if (!cred)
> -					goto error;
> -
> -				cred->uid = cred->euid = uid;
> -				cred->gid = cred->egid = gid;
> -				if (p->cred)
> -					put_cred(p->cred);
> -				p->cred = cred;
> +			rcu_read_lock();
> +			pid = find_vpid(creds.pid);
> +			if (!pid) {
> +				rcu_read_unlock();
> +				err = -ESRCH;
> +				goto error;
>  			}
> +			p->creds.init_ns_pid = pid_nr(pid);
> +			rcu_read_unlock();
> +
> +			p->creds.has_creds = true;
> +
>  			break;
>  		}
>  		default:
> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> index 1e3fd5b..8245f61 100644
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@ -936,7 +936,6 @@ static int netlink_unicast_kernel(struct sock *sk, struct sk_buff *skb,
>  	if (nlk->netlink_rcv != NULL) {
>  		ret = skb->len;
>  		skb_set_owner_r(skb, sk);
> -		NETLINK_CB(skb).ssk = ssk;
>  		nlk->netlink_rcv(skb);
>  		consume_skb(skb);
>  	} else {
> @@ -1368,7 +1367,7 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
>  	u32 dst_group;
>  	struct sk_buff *skb;
>  	int err;
> -	struct scm_cookie scm;
> +	struct scm_cookie scm = SCM_COOKIE_INIT;
>  
>  	if (msg->msg_flags&MSG_OOB)
>  		return -EOPNOTSUPP;
> @@ -1376,7 +1375,8 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
>  	if (NULL == siocb->scm)
>  		siocb->scm = &scm;
>  
> -	err = scm_send(sock, msg, siocb->scm, true);
> +	scm_creds_from_current(&siocb->scm->creds);
> +	err = scm_send(sock, msg, siocb->scm);
>  	if (err < 0)
>  		return err;
>  
> @@ -1411,7 +1411,9 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
>  
>  	NETLINK_CB(skb).portid	= nlk->portid;
>  	NETLINK_CB(skb).dst_group = dst_group;
> -	NETLINK_CB(skb).creds	= siocb->scm->creds;
> +
> +	/* This is mandatory. See netlink_recvmsg. */
> +	NETLINK_CB(skb).creds = siocb->scm->creds;
>  
>  	err = -EFAULT;
>  	if (memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len)) {
> @@ -1504,7 +1506,11 @@ static int netlink_recvmsg(struct kiocb *kiocb, struct socket *sock,
>  		memset(&scm, 0, sizeof(scm));
>  		siocb->scm = &scm;
>  	}
> +	/* skbs without creds are from the kernel. */
>  	siocb->scm->creds = *NETLINK_CREDS(skb);
> +	if (!siocb->scm->creds.has_creds)
> +		scm_creds_from_kernel(&siocb->scm->creds);
> +
>  	if (flags & MSG_TRUNC)
>  		copied = data_skb->len;
>  
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index 51be64f..0881739 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -1338,10 +1338,8 @@ static void unix_detach_fds(struct scm_cookie *scm, struct sk_buff *skb)
>  
>  static void unix_destruct_scm(struct sk_buff *skb)
>  {
> -	struct scm_cookie scm;
> -	memset(&scm, 0, sizeof(scm));
> -	scm.pid  = UNIXCB(skb).pid;
> -	scm.cred = UNIXCB(skb).cred;
> +	struct scm_cookie scm = SCM_COOKIE_INIT;
> +	scm.creds = UNIXCB(skb).creds;
>  	if (UNIXCB(skb).fp)
>  		unix_detach_fds(&scm, skb);
>  
> @@ -1391,9 +1389,7 @@ static int unix_scm_to_skb(struct scm_cookie *scm, struct sk_buff *skb, bool sen
>  {
>  	int err = 0;
>  
> -	UNIXCB(skb).pid  = get_pid(scm->pid);
> -	if (scm->cred)
> -		UNIXCB(skb).cred = get_cred(scm->cred);
> +	UNIXCB(skb).creds = scm->creds;
>  	UNIXCB(skb).fp = NULL;
>  	if (scm->fp && send_fds)
>  		err = unix_attach_fds(scm, skb);
> @@ -1410,13 +1406,12 @@ static int unix_scm_to_skb(struct scm_cookie *scm, struct sk_buff *skb, bool sen
>  static void maybe_add_creds(struct sk_buff *skb, const struct socket *sock,
>  			    const struct sock *other)
>  {
> -	if (UNIXCB(skb).cred)
> +	if (UNIXCB(skb).creds.has_creds)
>  		return;
>  	if (test_bit(SOCK_PASSCRED, &sock->flags) ||
>  	    !other->sk_socket ||
>  	    test_bit(SOCK_PASSCRED, &other->sk_socket->flags)) {
> -		UNIXCB(skb).pid  = get_pid(task_tgid(current));
> -		UNIXCB(skb).cred = get_current_cred();
> +		scm_creds_from_current(&UNIXCB(skb).creds);
>  	}
>  }
>  
> @@ -1438,14 +1433,14 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
>  	unsigned int hash;
>  	struct sk_buff *skb;
>  	long timeo;
> -	struct scm_cookie tmp_scm;
> +	struct scm_cookie tmp_scm = SCM_COOKIE_INIT;
>  	int max_level;
>  	int data_len = 0;
>  
>  	if (NULL == siocb->scm)
>  		siocb->scm = &tmp_scm;
>  	wait_for_unix_gc();
> -	err = scm_send(sock, msg, siocb->scm, false);
> +	err = scm_send(sock, msg, siocb->scm);
>  	if (err < 0)
>  		return err;
>  
> @@ -1607,14 +1602,14 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
>  	int err, size;
>  	struct sk_buff *skb;
>  	int sent = 0;
> -	struct scm_cookie tmp_scm;
> +	struct scm_cookie tmp_scm = SCM_COOKIE_INIT;
>  	bool fds_sent = false;
>  	int max_level;
>  
>  	if (NULL == siocb->scm)
>  		siocb->scm = &tmp_scm;
>  	wait_for_unix_gc();
> -	err = scm_send(sock, msg, siocb->scm, false);
> +	err = scm_send(sock, msg, siocb->scm);
>  	if (err < 0)
>  		return err;
>  
> @@ -1765,7 +1760,7 @@ static int unix_dgram_recvmsg(struct kiocb *iocb, struct socket *sock,
>  			      int flags)
>  {
>  	struct sock_iocb *siocb = kiocb_to_siocb(iocb);
> -	struct scm_cookie tmp_scm;
> +	struct scm_cookie tmp_scm = SCM_COOKIE_INIT;
>  	struct sock *sk = sock->sk;
>  	struct unix_sock *u = unix_sk(sk);
>  	int noblock = flags & MSG_DONTWAIT;
> @@ -1820,7 +1815,7 @@ static int unix_dgram_recvmsg(struct kiocb *iocb, struct socket *sock,
>  		siocb->scm = &tmp_scm;
>  		memset(&tmp_scm, 0, sizeof(tmp_scm));
>  	}
> -	scm_set_cred(siocb->scm, UNIXCB(skb).pid, UNIXCB(skb).cred);
> +	siocb->scm->creds = UNIXCB(skb).creds;
>  	unix_set_secdata(siocb->scm, skb);
>  
>  	if (!(flags & MSG_PEEK)) {
> @@ -1898,7 +1893,7 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
>  			       int flags)
>  {
>  	struct sock_iocb *siocb = kiocb_to_siocb(iocb);
> -	struct scm_cookie tmp_scm;
> +	struct scm_cookie tmp_scm = SCM_COOKIE_INIT;
>  	struct sock *sk = sock->sk;
>  	struct unix_sock *u = unix_sk(sk);
>  	struct sockaddr_un *sunaddr = msg->msg_name;
> @@ -1991,12 +1986,12 @@ again:
>  
>  		if (check_creds) {
>  			/* Never glue messages from different writers */
> -			if ((UNIXCB(skb).pid  != siocb->scm->pid) ||
> -			    (UNIXCB(skb).cred != siocb->scm->cred))
> +			if (!scm_creds_equal(&UNIXCB(skb).creds,
> +			                     &siocb->scm->creds));
>  				break;
>  		} else {
>  			/* Copy credentials */
> -			scm_set_cred(siocb->scm, UNIXCB(skb).pid, UNIXCB(skb).cred);
> +			siocb->scm->creds = UNIXCB(skb).creds;
>  			check_creds = 1;
>  		}
>  
> -- 
> 1.8.1.4
> 
> _______________________________________________
> Containers mailing list
> Containers@lists.linux-foundation.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
> 

-- 
James Morris
<jmorris@namei.org>
