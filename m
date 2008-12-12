From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC] Add /proc/sys/net/sctp/sctp_ecn ECN control
Date: Fri, 12 Dec 2008 13:58:28 +0100
Message-ID: <20081212125828.GE10284@dhcp35.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vladislav.yasevich@hp.com, sri@us.ibm.com,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:44205 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757972AbYLLM6a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Dec 2008 07:58:30 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Resending again with lkml and netdev in CC for broader audience]

Hi,

could you have look at the patch bellow which adds
/proc/sys/net/sctp/sctp_ecn interface for explicit control over ECN
usage?

I have close to zero experiences with the SCTP so I assume that there
are some things to fix (I just mimicked tcp_ecn implementation), however
I thought that your ideas can help me to speed up with this to be
implemented. 

The patch is based on top of Linus git
7f0f598a0069d1ab072375965a4b69137233169c).

Just for background. We have customers who do have problems with routes
throwing out their packets because of ECT bits set and they need some
control over it (like for TCP protocol).

What do you think about the idea? What do you think about upstream
merging of this feature?

Thanks for any hints/comments

Best regards

---
commit 70525bca4ec7c86c7560405005f93ff89f642af6
Author: Michal Hocko <mhocko@suse.cz>
Date:   Thu Nov 20 14:03:27 2008 +0100

    [RFC] add /proc/sys/net/sctp/sctp_ecn
    
    Current sctp ECN implementation doesn't contain any way how to
    explicitly disable this flag for ECN capable devices. This makes sense
    when "dumb" routers are in the path which could drop all packets with
    this flag set.
    
    This implementation is motivated by sysctl_tcp_ecn and it basically
    exports sysctl_sctp_ecn (set to 1 by default) symbol and enables sysctl
    and /proc/sys/sctp interface for its value manipulation.
    
    sctp_v4_ecn_capable and sctp_v6_ecn_capable then use this value to
    determine whether enable standard path or not.
    
    Signed-off-by: Michal Hocko <mhocko@suse.cz>

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index ed71b11..0dd762a 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -187,6 +187,8 @@ void sctp_remaddr_proc_exit(void);
  * Module global variables
  */
 
+extern int sysctl_sctp_ecn;
+
  /*
   * sctp/protocol.c
   */
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 4124bbb..d621a52 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -732,7 +732,8 @@ static void sctp_v6_seq_dump_addr(struct seq_file *seq, union sctp_addr *addr)
 
 static void sctp_v6_ecn_capable(struct sock *sk)
 {
-	inet6_sk(sk)->tclass |= INET_ECN_ECT_0;
+	if (sysctl_sctp_ecn)
+		inet6_sk(sk)->tclass |= INET_ECN_ECT_0;
 }
 
 /* Initialize a PF_INET6 socket msg_name. */
diff --git a/net/sctp/output.c b/net/sctp/output.c
index c3f417f..740d171 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -547,7 +547,8 @@ int sctp_packet_transmit(struct sctp_packet *packet)
 	 *   data sender to indicate that the end-points of the
 	 *   transport protocol are ECN-capable."
 	 *
-	 * Now setting the ECT bit all the time, as it should not cause
+	 * Now setting the ECT bit all the time (except when forbidden
+	 * explicitly by sysctl_sctp_ecn), as it should not cause
 	 * any problems protocol-wise even if our peer ignores it.
 	 *
 	 * Note: The works for IPv6 layer checks this bit too later
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 0b65354..5a1a7ce 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -651,7 +651,8 @@ static void sctp_v4_seq_dump_addr(struct seq_file *seq, union sctp_addr *addr)
 
 static void sctp_v4_ecn_capable(struct sock *sk)
 {
-	INET_ECN_xmit(sk);
+	if (sysctl_sctp_ecn)
+		INET_ECN_xmit(sk);
 }
 
 /* Event handler for inet address addition/deletion events.
diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index 5291069..e76f423 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -55,6 +55,7 @@ static long sack_timer_max = 500;
 extern int sysctl_sctp_mem[3];
 extern int sysctl_sctp_rmem[3];
 extern int sysctl_sctp_wmem[3];
+int sysctl_sctp_ecn=1;
 
 static ctl_table sctp_table[] = {
 	{
@@ -272,6 +273,14 @@ static ctl_table sctp_table[] = {
 		.proc_handler	= &proc_dointvec,
 		.strategy	= &sysctl_intvec
 	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "sctp_ecn",
+		.data		= &sysctl_sctp_ecn,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec
+	},
 	{ .ctl_name = 0 }
 };
 
@@ -294,3 +303,5 @@ void sctp_sysctl_unregister(void)
 {
 	unregister_sysctl_table(sctp_sysctl_header);
 }
+
+EXPORT_SYMBOL(sysctl_sctp_ecn);

-- 
Michal Hocko
L3 team 
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic
