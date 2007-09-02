From: Satyam Sharma <satyam@infradead.org>
Subject: [PATCH -mm] sunrpc svc: Shut up bogus uninitialized variable
 warning
Date: Mon, 3 Sep 2007 01:39:04 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0709030137390.29617@enigma.security.iitk.ac.in>
References: <alpine.LFD.0.999.0709022344550.27844@enigma.security.iitk.ac.i
 n>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="464262402-445849459-1188763748=:29617"
Cc: Greg Banks <gnb@melbourne.sgi.com>,
	Olaf Kirch <olaf.kirch@oracle.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:37273 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752566AbXIBTz5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Sep 2007 15:55:57 -0400
In-Reply-To: <alpine.LFD.0.999.0709022344550.27844@enigma.security.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--464262402-445849459-1188763748=:29617
Content-Type: TEXT/PLAIN; charset=iso-2022-jp


net/sunrpc/svc.c: In function ‘__svc_create_thread’:
net/sunrpc/svc.c:550: warning: ‘oldmask.bits[0u]’ may be used uninitialized in this function

is a bogus warning, but gcc isn't smart enough to see why. We cannot just
reorganize the code in the function, because we want the set_cpus_allowed()
restore to happen only after the kernel_thread() is forked. Alas, we have
to use cpus_clear() to initialize oldmask instead to keep gcc happy.

Also add some comments to describe what's happening in the function.

Signed-off-by: Satyam Sharma <satyam@infradead.org>

---

 net/sunrpc/svc.c |    7 +++++++
 1 file changed, 7 insertions(+)

--- linux-2.6.23-rc4-mm1/net/sunrpc/svc.c~fix	2007-09-02 22:55:25.000000000 +0530
+++ linux-2.6.23-rc4-mm1/net/sunrpc/svc.c	2007-09-02 23:03:45.000000000 +0530
@@ -568,17 +568,24 @@ __svc_create_thread(svc_thread_fn func, 
 	rqstp->rq_server = serv;
 	rqstp->rq_pool = pool;
 
+	/* Only to prevent gcc warning */
+	cpus_clear(oldmask);
+
+	/* Temporarily change CPU affinity before forking svc thread */
 	if (serv->sv_nrpools > 1)
 		have_oldmask = svc_pool_map_set_cpumask(pool->sp_id, &oldmask);
 
+	/* Will inherit current->cpus_allowed */
 	error = kernel_thread((int (*)(void *)) func, rqstp, 0);
 
+	/* Restore old cpus_allowed */
 	if (have_oldmask)
 		set_cpus_allowed(current, oldmask);
 
 	if (error < 0)
 		goto out_thread;
 	svc_sock_update_bufs(serv);
+
 	error = 0;
 out:
 	return error;
--464262402-445849459-1188763748=:29617--
