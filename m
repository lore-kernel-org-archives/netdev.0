From: Valdis.Kletnieks@vt.edu
Subject: 2.6.24-rc6-mm1 - oddness with IPv4/v6 mapped sockets hanging...
Date: Sun, 13 Jan 2008 02:35:33 -0500
Message-ID: <30887.1200209733@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1200209733_18681P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from turing-police.cc.vt.edu ([128.173.14.107]:41271 "EHLO
	turing-police.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751097AbYAMHfi (ORCPT
	<RFC822;netdev@vger.kernel.org>); Sun, 13 Jan 2008 02:35:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1200209733_18681P
Content-Type: text/plain; charset=us-ascii

I'm seeing problems with Sendmail on 24-rc6-mm1, where the main Sendmail is
listening on ::1/25, and Fetchmail connects to 127.0.0.1:25 to inject mail it
has just fetched from an outside server via IMAP - it will often just hang and
not make any further progress. Looking at netstat shows something interesting:

% netstat -n -a -A inet | grep 25
tcp        0   5108 127.0.0.1:59355             127.0.0.1:25                ESTABLISHED 
% netstat -n -a -A inet6 | grep 25
tcp        0      0 :::25                       :::*                        LISTEN      
tcp        0      0 ::ffff:127.0.0.1:25         ::ffff:127.0.0.1:59355      ESTABLISHED 
% netstat -n -a -A inet | grep 25
tcp        0   5108 127.0.0.1:59355             127.0.0.1:25                ESTABLISHED 
% netstat -n -a -A inet6 | grep 25
tcp        0      0 :::25                       :::*                        LISTEN      
tcp        0      0 ::ffff:127.0.0.1:25         ::ffff:127.0.0.1:59355      ESTABLISHED 
% netstat -n -a -A inet | grep 25
tcp        0   5108 127.0.0.1:59355             127.0.0.1:25                ESTABLISHED 
% netstat -n -a -A inet6 | grep 25
tcp        0      0 :::25                       :::*                        LISTEN      
tcp        0      0 ::ffff:127.0.0.1:25         ::ffff:127.0.0.1:59355      ESTABLISHED 

On the IPv4 side, it thinks it's got 5108 bytes in the send queue - but on
the IPv6 side of that same connection, it's showing 0 in the receive queue,
and we're stuck there.

It's not consistent - sometimes Fetchmail will wedge on the very first mail,
and do so several times in a row.  Other times, it will do well for a while -
at the moment, it's gone through 471 of the 1,470 currently queued mails just
fine, only to get wedged again on number 472.

For what it's worth, here's what 'echo w > /proc/sysrq-trigger' got, although I
don't see anything that looks odd to me given the netstat output above -
procmail has sent data, and is waiting for a response back, and sendmail is
waiting for data to arrive:

fetchmail     S ffffffff8053c520  5360 17612   9902
 ffff81007d37bb08 0000000000000086 0000000000000000 000200d000000000
 ffff81006bf826c0 ffffffff80687360 ffff81006bf82918 0000000000000001
 0000000000000003 ffff81007d37bb88 0000000000000000 0000000000000000
Call Trace:
 [<ffffffff80522682>] schedule_timeout+0x22/0xb4
 [<ffffffff80523bd3>] _spin_lock_bh+0x11/0x38
 [<ffffffff80523ac4>] _spin_unlock_bh+0x1e/0x20
 [<ffffffff8047cec6>] release_sock+0xa3/0xac
 [<ffffffff8047d98f>] sk_wait_data+0x8a/0xcf
 [<ffffffff80249b99>] autoremove_wake_function+0x0/0x38
 [<ffffffff804abdca>] tcp_recvmsg+0x35a/0x86b
 [<ffffffff8047c7be>] sock_common_recvmsg+0x32/0x47
 [<ffffffff803288be>] selinux_socket_recvmsg+0x1d/0x1f
 [<ffffffff8047af38>] sock_recvmsg+0x10e/0x12f
 [<ffffffff80249b99>] autoremove_wake_function+0x0/0x38
 [<ffffffff8032425d>] avc_has_perm+0x4c/0x5e
 [<ffffffff803ac952>] pty_write+0x3a/0x44
 [<ffffffff80249dd8>] remove_wait_queue+0x2f/0x3b
 [<ffffffff8047c06b>] sys_recvfrom+0xa4/0xf5
 [<ffffffff8024c850>] hrtimer_start+0x11f/0x131
 [<ffffffff8023aa6e>] do_setitimer+0x184/0x326
 [<ffffffff8020c03b>] system_call_after_swapgs+0x7b/0x80

sendmail      S ffff81007d30a400  5360 17613  16992
 ffff81006bc419e8 0000000000000086 ffff81006bc41998 ffffffff8023f6a5
 ffff81007d30a400 ffff81007d24f200 ffff81007d30a658 0000000100000286
 ffff81006bc419e8 ffffffff8023f851 000000004789b768 ffff81000100eb20
Call Trace:
 [<ffffffff8023f6a5>] lock_timer_base+0x26/0x4a
 [<ffffffff8023f851>] __mod_timer+0xc4/0xd6
 [<ffffffff805226ed>] schedule_timeout+0x8d/0xb4
 [<ffffffff8023f37c>] process_timeout+0x0/0xb
 [<ffffffff805226e8>] schedule_timeout+0x88/0xb4
 [<ffffffff8029cd26>] do_select+0x4a9/0x50b
 [<ffffffff8029d22d>] __pollwait+0x0/0xdf
 [<ffffffff8022d7b9>] default_wake_function+0x0/0xf
 [<ffffffff80523bd3>] _spin_lock_bh+0x11/0x38
 [<ffffffff8047cf74>] lock_sock_nested+0xa5/0xb2
 [<ffffffff80523bd3>] _spin_lock_bh+0x11/0x38
 [<ffffffff80523ac4>] _spin_unlock_bh+0x1e/0x20
 [<ffffffff8047cec6>] release_sock+0xa3/0xac
 [<ffffffff804ac1c9>] tcp_recvmsg+0x759/0x86b
 [<ffffffff8047c7be>] sock_common_recvmsg+0x32/0x47
 [<ffffffff803288be>] selinux_socket_recvmsg+0x1d/0x1f
 [<ffffffff8047a924>] sock_aio_read+0x121/0x139
 [<ffffffff8032425d>] avc_has_perm+0x4c/0x5e
 [<ffffffff8029cf7a>] core_sys_select+0x1f2/0x2a0
 [<ffffffff80282f50>] page_add_new_anon_rmap+0x20/0x22
 [<ffffffff803251f5>] file_has_perm+0xa5/0xb4
 [<ffffffff80249b99>] autoremove_wake_function+0x0/0x38
 [<ffffffff8029d45c>] sys_select+0x150/0x17b
 [<ffffffff8020c03b>] system_call_after_swapgs+0x7b/0x80

Any ideas?

--==_Exmh_1200209733_18681P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.8 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFHib9FcC3lWbTT17ARApHPAJ41adCIQQPlwvolnOGw7ERE+dPRtACfVbP2
5YzB9vjZBc3kMZGAimOuUog=
=B5uG
-----END PGP SIGNATURE-----

--==_Exmh_1200209733_18681P--
