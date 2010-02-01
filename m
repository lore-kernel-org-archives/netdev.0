From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 02/86] dccp: revert buggy auto-loading of dccp module
Date: Mon,  1 Feb 2010 07:18:07 +0100
Message-ID: <1265005087-5549-3-git-send-email-gerrit@erg.abdn.ac.uk>
References: <recent-dccp-bug-fixes-jan-2010>
 <1265005087-5549-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1265005087-5549-2-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:59484 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754388Ab0BAGby (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Feb 2010 01:31:54 -0500
In-Reply-To: <1265005087-5549-2-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit (38ff3e6bb987ec583268da8eb22628293095d43b) ("dccp_probe:
Fix module load dependencies between dccp and dccp_probe", from 15 Jan). Not
only does it not work:

% modprobe -v dccp_probe
kernel: [ 1431.442912] sys_init_module: 'dccp_probe'->init suspiciously \
 		      returned 1, it should follow 0/-E convention
kernel: [ 1431.442915] sys_init_module: loading module anyway...


... but it also causes a crash:

% rmmod dccp_probe
kernel: [ 1777.305846] kernel BUG at /usr/src/davem-2.6/mm/slab.c:521!
kernel: [ 1777.305852] invalid opcode: 0000 [#1] SMP
kernel: [ 1777.305861] last sysfs file: /sys/class/power_supply/BAT0/energy_full
kernel: [ 1777.305867] Modules linked in: dccp_probe(-) iwl3945 iwlcore [last unloaded: dccp]
kernel: [ 1777.305883]
kernel: [ 1777.305891] Pid: 12912, comm: rmmod Tainted: G  R        2.6.33-rc5 #6 2008URG/2008URG
kernel: [ 1777.305899] EIP: 0060:[<c01d5e43>] EFLAGS: 00010046 CPU: 1
kernel: [ 1777.305910] EIP is at kfree+0x73/0x150
kernel: [ 1777.305916] EAX: c1678c00 EBX: 00000000 ECX: c01d5e15 EDX: 40080000
kernel: [ 1777.305922] ESI: c015cb9a EDI: 080488a0 EBP: f4ffbf34 ESP: f4ffbf10
kernel: [ 1777.305929]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
kernel: [ 1777.305936] Process rmmod (pid: 12912, ti=f4ffb000 task=f61e8620 task.ti=f4ffb000)

==> After reverting the commit:

% modprobe -v dccp_probe
insmod /lib/modules/2.6.33-rc5/kernel/net/dccp/dccp.ko
insmod /lib/modules/2.6.33-rc5/kernel/net/dccp/dccp_probe.ko

% lsmod
Module                  Size  Used by
dccp_probe              2345  0
dccp                  120233  1 dccp_probe

Previously (during about 4 years of this module's history) there had never
been a problem with the 'silent dependency' that the commit tried to fix:
this dependency is deliberate and required, since dccp_probe performs probing
of dccp connections and hence needs to know about dccp internals.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/probe.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

--- a/net/dccp/probe.c
+++ b/net/dccp/probe.c
@@ -161,8 +161,7 @@ static __init int dccpprobe_init(void)
 	if (!proc_net_fops_create(&init_net, procname, S_IRUSR, &dccpprobe_fops))
 		goto err0;
 
-	ret = try_then_request_module((register_jprobe(&dccp_send_probe) == 0),
-					"dccp");
+	ret = register_jprobe(&dccp_send_probe);
 	if (ret)
 		goto err1;
 
