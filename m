From: Frederik Deweerdt <deweerdt@free.fr>
Subject: [Oops] unix_dgram_connect locking problem?
Date: Fri, 11 May 2007 17:00:14 +0200
Message-ID: <20070511150014.GF23638@slug>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:25811 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756744AbXEKPBc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 11:01:32 -0400
Received: by ug-out-1314.google.com with SMTP id 44so835011uga
        for <netdev@vger.kernel.org>; Fri, 11 May 2007 08:01:25 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I'm seeing an Oops[1] with a 2.6.19.2 kernel:

BUG: unable to handle kernel NULL pointer dereference at virtual address 0000018c
 printing eip:
c01cc54f
*pde = 00000000
Oops: 0000 [#1]
PREEMPT SMP
Modules linked in: ipmi_si ipmi_devintf ipmi_msghandler nfsd exportfs i8xx_tco i2c_dev i2c_core nfs lockd sunrpc tg3 e1000 ip_conntrack_ftp iptable_nat ip_nat xt_state ip_conntrack xt_tcpudp iptable_filter ip_tables x_tables video thermal processor fan button battery asus_acpi ac parport_pc lp parport nvram ehci_hcd ohci_hcd uhci_hcd
CPU:    1
EIP:    0060:[<c01cc54f>]    Not tainted VLI
EFLAGS: 00210282   (2.6.19.2-Alcatel #1)
EIP is at selinux_socket_unix_may_send+0xc/0x58
eax: f5ab2500   ebx: f1e614b4   ecx: c03e20e0   edx: 00000000
esi: ee237300   edi: f78b0d00   ebp: ee21fee0   esp: ee21fe64
ds: 007b   es: 007b   ss: 0068
Process snmp_mgr (pid: 31449, ti=ee21e000 task=ee73bab0 task.ti=ee21e000)
Stack: f5ab2500 00000001 00000001 00000000 c01cc36d ee73bab0 f744f7f0 ee21fee0
       f744f77c f7b01980 c0142bcc 00000001 00000001 00000018 00000005 ee21ff18
       f5ab2500 f5ab2500 ee237300 f78b0d00 c034d8e7 0000000c ee21fec0 ffffffff
Call Trace:
 [<c01cc36d>] selinux_socket_connect+0x24/0xf7
 [<c0142bcc>] generic_file_aio_write+0x62/0xb7
 [<c034d8e7>] unix_dgram_connect+0xb7/0x146
 [<c02f25da>] sys_connect+0x82/0xad
 [<c02f386c>] release_sock+0x13/0xa3
 [<c034ddc7>] unix_write_space+0x15/0x74
 [<c02f494f>] sock_setsockopt+0x492/0x49c
 [<c015cc94>] get_empty_filp+0x99/0x18d
 [<c02f204d>] __sock_create+0x22e/0x2af
 [<c02f159d>] sockfd_lookup_light+0x24/0x3e
 [<c02f1717>] sys_setsockopt+0x6d/0xa7
 [<c02f2e39>] sys_socketcall+0xac/0x261
 [<c015a371>] filp_close+0x52/0x59
 [<c0102bc1>] sysenter_past_esp+0x56/0x79
 =======================
Code: 8b 8e 58 01 00 00 8b 53 10 89 51 08 83 c1 04 8b 45 10 e8 e5 7e 00 00 83 c4 4c 5b 5e 5f 5d c3 57 56 53 83 ec 44 8b 98 8c 01 00 00 <8b> b2 8c 01 00 00 8d 44 24 0c 89 44 24 08 31 c0 b9 0e 00 00 00
EIP: [<c01cc54f>] selinux_socket_unix_may_send+0xc/0x58 SS:ESP 0068:ee21fe64

I think that not unix_state_rlock'ing "other" in
unix_dgram_connect may cause it to become NULL while passing it to
selinux_socket_unix_may_send. With the following patch applied, I've
seen no oops so far (1-2 hours as opposed to a few minutes before applying
the patch). Any thoughts?

Thanks,
Frederik

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index b43a278..e533c7f 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -877,11 +877,20 @@ static int unix_dgram_connect(struct socket *sock, struct sockaddr *addr,
 		    !unix_sk(sk)->addr && (err = unix_autobind(sock)) != 0)
 			goto out;
 
+restart:
 		other=unix_find_other(sunaddr, alen, sock->type, hash, &err);
 		if (!other)
 			goto out;
 
 		unix_state_wlock(sk);
+		unix_state_rlock(other);
+
+		if (sock_flag(other, SOCK_DEAD)) {
+			unix_state_wunlock(sk);
+			unix_state_runlock(other);
+			sock_put(other);
+			goto restart;
+		}
 
 		err = -EPERM;
 		if (!unix_may_send(sk, other))
@@ -905,6 +914,8 @@ static int unix_dgram_connect(struct socket *sock, struct sockaddr *addr,
 	if (unix_peer(sk)) {
 		struct sock *old_peer = unix_peer(sk);
 		unix_peer(sk)=other;
+		if (other)
+			unix_state_runlock(other);
 		unix_state_wunlock(sk);
 
 		if (other != old_peer)
@@ -912,11 +923,14 @@ static int unix_dgram_connect(struct socket *sock, struct sockaddr *addr,
 		sock_put(old_peer);
 	} else {
 		unix_peer(sk)=other;
+		if (other)
+			unix_state_runlock(other);
 		unix_state_wunlock(sk);
 	}
  	return 0;
 
 out_unlock:
+	unix_state_runlock(other);
 	unix_state_wunlock(sk);
 	sock_put(other);
 out:
