From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 9/9] make net/core/scm.c uid comparisons user namespace aware
Date: Wed, 19 Oct 2011 06:52:28 -0700
Message-ID: <m1sjmpytpf.fsf@fess.ebiederm.org>
References: <1318974898-21431-1-git-send-email-serge@hallyn.com>
	<1318974898-21431-10-git-send-email-serge@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	oleg@redhat.com, richard@nod.at, mikevs@xs4all.net,
	segoon@openwall.com, gregkh@suse.de, dhowells@redhat.com,
	eparis@redhat.com, "Serge E. Hallyn" <serge.hallyn@canonical.com>,
	netdev@vger.kernel.org
To: Serge Hallyn <serge@hallyn.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1318974898-21431-10-git-send-email-serge@hallyn.com> (Serge
	Hallyn's message of "Tue, 18 Oct 2011 21:54:58 +0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Serge Hallyn <serge@hallyn.com> writes:

> From: "Serge E. Hallyn" <serge.hallyn@canonical.com>
>
> Currently uids are compared without regard for the user namespace.
> Fix that to prevent tasks in a different user namespace from
> wrongly matching on SCM_CREDENTIALS.
>
> In the past, either your uids had to match, or you had to have
> CAP_SETXID.  In a namespaced world, you must either (both be in the
> same user namespace and have your uids match), or you must have
> CAP_SETXID targeted at the other user namespace.  The latter can
> happen for instance if uid 500 created a new user namespace and
> now interacts with uid 0 in it.

Serge this approach is wrong.

Because we pass the cred and the pid through the socket socket itself
is just a conduit and should be ignored in this context.

The only interesting test should be are you allowed to impersonate other
users in your current userk namespace.

So it should be possible to simplify the entire patch to just:
 static __inline__ int scm_check_creds(struct ucred *creds)
 {
 	const struct cred *cred = current_cred();
+	struct user_namespace *ns = cred->user_ns;

-	if ((creds->pid == task_tgid_vnr(current) || capable(CAP_SYS_ADMIN)) &&
-	    ((creds->uid == cred->uid   || creds->uid == cred->euid ||
-	      creds->uid == cred->suid) || capable(CAP_SETUID)) &&
-	    ((creds->gid == cred->gid   || creds->gid == cred->egid ||
-	      creds->gid == cred->sgid) || capable(CAP_SETGID))) {
+	if ((creds->pid == task_tgid_vnr(current) || ns_capable(ns, CAP_SYS_ADMIN)) &&
+	    ((creds->uid == cred->uid   || creds->uid == cred->euid ||
+	      creds->uid == cred->suid) || ns_capable(ns, CAP_SETUID)) &&
+	    ((creds->gid == cred->gid   || creds->gid == cred->egid ||
+	      creds->gid == cred->sgid) || ns_capable(ns, CAP_SETGID))) {
  	       return 0;
  	}
  	return -EPERM;
  }
