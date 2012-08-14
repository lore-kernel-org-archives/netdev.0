From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net PATCH v1 1/2] net: netprio: fix files lock and remove useless
	d_path bits
Date: Mon, 13 Aug 2012 18:39:39 -0700
Message-ID: <20120814013939.3144.13167.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, joe@perches.com
To: viro@ZenIV.linux.org.uk, nhorman@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add lock to prevent a race with a file closing and also remove
useless and ugly sscanf code. The extra code was never needed
and the case it supposedly protected against is in fact handled
correctly by sock_from_file as pointed out by Al Viro.

CC: Neil Horman <nhorman@tuxdriver.com>
Reported-by: Al Viro <viro@ZenIV.linux.org.uk>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 net/core/netprio_cgroup.c |   15 ++++-----------
 1 files changed, 4 insertions(+), 11 deletions(-)

diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index ed0c043..0323ec3 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -296,29 +296,22 @@ void net_prio_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
 			continue;
 		}
 
-		rcu_read_lock();
+		spin_lock(&files->file_lock);
 		fdt = files_fdtable(files);
 		for (fd = 0; fd < fdt->max_fds; fd++) {
-			char *path;
 			struct file *file;
 			struct socket *sock;
-			unsigned long s;
-			int rv, err = 0;
+			int err;
 
 			file = fcheck_files(files, fd);
 			if (!file)
 				continue;
 
-			path = d_path(&file->f_path, tmp, PAGE_SIZE);
-			rv = sscanf(path, "socket:[%lu]", &s);
-			if (rv <= 0)
-				continue;
-
 			sock = sock_from_file(file, &err);
-			if (!err)
+			if (sock)
 				sock_update_netprioidx(sock->sk, p);
 		}
-		rcu_read_unlock();
+		spin_unlock(&files->file_lock);
 		task_unlock(p);
 	}
 	kfree(tmp);
