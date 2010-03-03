From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [RFC v2 00/10] snet: Security for NETwork syscalls
Date: Wed, 03 Mar 2010 10:56:39 +0900
Message-ID: <201003030156.o231udx1023055@www262.sakura.ne.jp>
References: <1267561394-13626-1-git-send-email-sam@synack.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, hadi@cyberus.ca, kaber@trash.net,
	zbr@ioremap.net, nhorman@tuxdriver.com, root@localdomain.pl,
	linux-security-module@vger.kernel.org
To: sam@synack.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1267561394-13626-1-git-send-email-sam@synack.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.



Regarding [RFC v2 02/10] Revert "lsm: Remove the socket_post_accept() hook"
@@ -1538,6 +1538,8 @@ SYSCALL_DEFINE4(accept4, int, fd, struct sockaddr __user *, upeer_sockaddr,
 	fd_install(newfd, newfile);
 	err = newfd;
 
+	security_socket_post_accept(sock, newsock);
+
 out_put:
 	fput_light(sock->file, fput_needed);
 out:

Please move security_socket_post_accept() to before fd_install().
Otherwise, other threads which share fd tables can use
security-informations-not-yet-updated accept()ed sockets.





Regarding [RFC v2 04/10] snet: introduce snet_core
+static __init int snet_init(void)
+{
+	int ret;
+
+	pr_debug("initializing: event_hash_size=%u "
+		 "verdict_hash_size=%u verdict_delay=%usecs "
+		 "default_policy=%s\n",
+		 snet_evh_size, snet_vdh_size, snet_verdict_delay,
+		 snet_verdict_name(snet_verdict_policy));

Why not to stop here if snet_evh_size == 0 or snet_vdh_size == 0 in order to
avoid "division by 0".





Regarding [RFC v2 05/10] snet: introduce snet_event
+static rwlock_t snet_evh_lock = __RW_LOCK_UNLOCKED();

You can use "static DEFINE_RWLOCK(snet_evh_lock);".

+int snet_event_is_registered(const enum snet_syscall syscall, const u8 protocol)

Maybe rcu_read_lock() is better than rw spinlock because this function is
frequently called.





Regarding [RFC v2 06/10] snet: introduce snet_hooks
+                       if ((verdict = snet_ticket_check(&info)) != SNET_VERDICT_NONE)

Please avoid assignment in "if" statement, as scripts/checkpatch.pl suggests.





Regarding [RFC v2 09/10] snet: introduce snet_ticket
+enum snet_verdict snet_ticket_check(struct snet_info *info)
+{
+       struct snet_ticket *st = NULL;
+       unsigned int h = 0, verdict = SNET_VERDICT_NONE;
+       struct list_head *l = NULL;
+       struct snet_task_security *tsec = NULL;
+
+       if (snet_ticket_mode == SNET_TICKET_OFF)
+               goto out;
+
+       tsec = (struct snet_task_security*) current_security();
+
+       h = jhash_2words(info->syscall, info->protocol, 0) % HSIZE;
+       l = &tsec->hash[h];
+
+       read_lock_bh(&tsec->lock);

Credentials are allocated for copy-on-write basis.
Sharing "tsec" among multiple "struct task_struct" is what you intended?



Regards.
