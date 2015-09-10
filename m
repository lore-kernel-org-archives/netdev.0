From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net] sctp: fix race on protocol/netns initialization
Date: Thu, 10 Sep 2015 15:47:54 -0300
Message-ID: <20150910184754.GE4496@localhost.localdomain>
References: <27f20cc781cac28bc2ce7229719748a2f6824bd8.1441827818.git.marcelo.leitner@gmail.com>
 <55F096EB.7000204@gmail.com>
 <55F09F57.6080602@gmail.com>
 <55F1847A.9010801@gmail.com>
 <55F19243.3010006@gmail.com>
 <55F1A6AE.2010804@gmail.com>
 <20150910162454.GB4496@localhost.localdomain>
 <20150910183520.GD4496@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
	linux-sctp@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56897 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751447AbbIJSr6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Sep 2015 14:47:58 -0400
Content-Disposition: inline
In-Reply-To: <20150910183520.GD4496@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 10, 2015 at 03:35:20PM -0300, Marcelo Ricardo Leitner wrote:
> On Thu, Sep 10, 2015 at 01:24:54PM -0300, Marcelo Ricardo Leitner wrote:
> > On Thu, Sep 10, 2015 at 11:50:06AM -0400, Vlad Yasevich wrote:
> > > On 09/10/2015 10:22 AM, Marcelo Ricardo Leitner wrote:
> > > > Em 10-09-2015 10:24, Vlad Yasevich escreveu:
> > ...
> > > >> Then you can order sctp_net_init() such that it happens first, then protosw registration
> > > >> happens, then control socket initialization happens, then inet protocol registration
> > > >> happens.
> > > >>
> > > >> This way, we are always guaranteed that by the time user calls socket(), protocol
> > > >> defaults are fully initialized.
> > > > 
> > > > Okay, that works for module loading stage, but then how would we handle new netns's? We
> > > > have to create the control socket per netns and AFAICT sctp_net_init() is the only hook
> > > > called when a new netns is being created.
> > > > 
> > > > Then if we move it a workqueue that is scheduled by sctp_net_init(), we loose the ability
> > > > to handle its errors by propagating through sctp_net_init() return value, not good.
> > > 
> > > Here is kind of what I had in mind.  It's incomplete and completely untested (not even
> > > compiled), but good enough to describe the idea:
> > ...
> > 
> > Ohh, ok now I get it, thanks. If having two pernet_subsys for a given
> > module is fine, that works for me. It's clearer and has no moment of
> > temporary failure.
> > 
> > I can finish this patch if everybody agrees with it.
> > 
> > > >>> I used the list pointer because that's null as that memory is entirely zeroed when alloced
> > > >>> and, after initialization, it's never null again. Works like a lock/condition without
> > > >>> using an extra field.
> > > >>>
> > > >>
> > > >> I understand this a well.  What I don't particularly like is that we are re-using
> > > >> a list without really stating why it's now done this way.  Additionally, it's not really
> > > >> the last that happens so it's seems kind of hacky...  If we need to add new
> > > >> per-net initializers, we now need to make sure that the code is put in the right
> > > >> place.  I'd just really like to have a cleaner solution...
> > > > 
> > > > Ok, got you. We could add a dedicated flag/bit for that then, if reusing the list is not
> > > > clear enough. Or, as we are discussing on the other part of thread, we could make it block
> > > > and wait for the initialization, probably using some wait_queue. I'm still thinking on
> > > > something this way, likely something more below than sctp then.
> > > > 
> > > 
> > > I think if we don the above, the second process calling socket() will either find the
> > > the protosw or will try to load the module also.  I think either is ok after
> > > request_module returns we'll look at the protosw and will find find things.
> > 
> > Seems so, yes. Nice.
> 
> I was testing with it, something is not good. I finished your patch and
> testing with a flooder like:

This is the patch I used. Mostly just fixed a few typos and added error handling.

diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 4345790ad326..8930046eaa1b 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -1178,7 +1178,7 @@ static void sctp_v4_del_protocol(void)
 	unregister_inetaddr_notifier(&sctp_inetaddr_notifier);
 }
 
-static int __net_init sctp_net_init(struct net *net)
+static int __net_init sctp_defaults_init(struct net *net)
 {
 	int status;
 
@@ -1271,12 +1271,6 @@ static int __net_init sctp_net_init(struct net *net)
 
 	sctp_dbg_objcnt_init(net);
 
-	/* Initialize the control inode/socket for handling OOTB packets.  */
-	if ((status = sctp_ctl_sock_init(net))) {
-		pr_err("Failed to initialize the SCTP control sock\n");
-		goto err_ctl_sock_init;
-	}
-
 	/* Initialize the local address list. */
 	INIT_LIST_HEAD(&net->sctp.local_addr_list);
 	spin_lock_init(&net->sctp.local_addr_lock);
@@ -1292,9 +1286,6 @@ static int __net_init sctp_net_init(struct net *net)
 
 	return 0;
 
-err_ctl_sock_init:
-	sctp_dbg_objcnt_exit(net);
-	sctp_proc_exit(net);
 err_init_proc:
 	cleanup_sctp_mibs(net);
 err_init_mibs:
@@ -1303,15 +1294,12 @@ err_sysctl_register:
 	return status;
 }
 
-static void __net_exit sctp_net_exit(struct net *net)
+static void __net_exit sctp_defaults_exit(struct net *net)
 {
 	/* Free the local address list */
 	sctp_free_addr_wq(net);
 	sctp_free_local_addr_list(net);
 
-	/* Free the control endpoint.  */
-	inet_ctl_sock_destroy(net->sctp.ctl_sock);
-
 	sctp_dbg_objcnt_exit(net);
 
 	sctp_proc_exit(net);
@@ -1319,9 +1307,32 @@ static void __net_exit sctp_net_exit(struct net *net)
 	sctp_sysctl_net_unregister(net);
 }
 
-static struct pernet_operations sctp_net_ops = {
-	.init = sctp_net_init,
-	.exit = sctp_net_exit,
+static struct pernet_operations sctp_defaults_ops = {
+	.init = sctp_defaults_init,
+	.exit = sctp_defaults_exit,
+};
+
+static int __net_init sctp_ctrlsock_init(struct net *net)
+{
+	int status;
+
+	/* Initialize the control inode/socket for handling OOTB packets.  */
+	status = sctp_ctl_sock_init(net);
+	if (status)
+		pr_err("Failed to initialize the SCTP control sock\n");
+
+	return status;
+}
+
+static void __net_init sctp_ctrlsock_exit(struct net *net)
+{
+	/* Free the control endpoint.  */
+	inet_ctl_sock_destroy(net->sctp.ctl_sock);
+}
+
+static struct pernet_operations sctp_ctrlsock_ops = {
+	.init = sctp_ctrlsock_init,
+	.exit = sctp_ctrlsock_exit,
 };
 
 /* Initialize the universe into something sensible.  */
@@ -1454,8 +1465,11 @@ static __init int sctp_init(void)
 	sctp_v4_pf_init();
 	sctp_v6_pf_init();
 
-	status = sctp_v4_protosw_init();
+	status = register_pernet_subsys(&sctp_defaults_ops);
+	if (status)
+		goto err_register_defaults;
 
+	status = sctp_v4_protosw_init();
 	if (status)
 		goto err_protosw_init;
 
@@ -1463,9 +1477,9 @@ static __init int sctp_init(void)
 	if (status)
 		goto err_v6_protosw_init;
 
-	status = register_pernet_subsys(&sctp_net_ops);
+	status = register_pernet_subsys(&sctp_ctrlsock_ops);
 	if (status)
-		goto err_register_pernet_subsys;
+		goto err_register_ctrlsock;
 
 	status = sctp_v4_add_protocol();
 	if (status)
@@ -1481,12 +1495,14 @@ out:
 err_v6_add_protocol:
 	sctp_v4_del_protocol();
 err_add_protocol:
-	unregister_pernet_subsys(&sctp_net_ops);
-err_register_pernet_subsys:
+	unregister_pernet_subsys(&sctp_ctrlsock_ops);
+err_register_ctrlsock:
 	sctp_v6_protosw_exit();
 err_v6_protosw_init:
 	sctp_v4_protosw_exit();
 err_protosw_init:
+	unregister_pernet_subsys(&sctp_defaults_ops);
+err_register_defaults:
 	sctp_v4_pf_exit();
 	sctp_v6_pf_exit();
 	sctp_sysctl_unregister();
@@ -1519,12 +1535,14 @@ static __exit void sctp_exit(void)
 	sctp_v6_del_protocol();
 	sctp_v4_del_protocol();
 
-	unregister_pernet_subsys(&sctp_net_ops);
+	unregister_pernet_subsys(&sctp_ctrlsock_ops);
 
 	/* Free protosw registrations */
 	sctp_v6_protosw_exit();
 	sctp_v4_protosw_exit();
 
+	unregister_pernet_subsys(&sctp_defaults_ops);
+
 	/* Unregister with socket layer. */
 	sctp_v6_pf_exit();
 	sctp_v4_pf_exit();
