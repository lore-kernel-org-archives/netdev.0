From: Kenan Kalajdzic <kenan@unix.ba>
Subject: [RFC][PATCH] af_unix: Add peer inode to /proc/net/unix
Date: Mon, 1 Mar 2010 05:52:07 +0100
Message-ID: <20100301045206.GB496@home.unix.ba>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-mail-360.bluehost.com ([66.147.249.254]:51010 "HELO
	outbound-mail-360.bluehost.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750717Ab0CAFBl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Mar 2010 00:01:41 -0500
Received: from [89.146.189.194] (helo=home.unix.ba)
	by box598.bluehost.com with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.69)
	(envelope-from <kenan@unix.ba>)
	id 1Nlxel-00049f-T3
	for netdev@vger.kernel.org; Sun, 28 Feb 2010 21:55:01 -0700
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recently, I had a problem identifying local X-clients on a desktop system from 
within a userspace application.  So, I thought it may be a good idea to add the 
peer inode field to /proc/net/unix.

Instead of adding a new column to /proc/net/unix (which breaks important 
userspace programs, including 'netstat' and 'lsof'), we can make use of the 
fact that most client sockets (including these of X-clients) and anonymous 
sockets have an empty path field in /proc/net/unix, which can be used for 
specifying the peer inode.  In order to differentiate between a regular path 
and an entry which contains the inode number of the peer socket, I chose to 
simply add the 'peer=' prefix to the peer inode number.

Signed-off-by: Kenan Kalajdzic <kenan@unix.ba>
---
 net/unix/af_unix.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index f255119..e778428 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2157,7 +2157,7 @@ static int unix_seq_show(struct seq_file *seq, void *v)
 		seq_puts(seq, "Num       RefCount Protocol Flags    Type St "
 			 "Inode Path\n");
 	else {
-		struct sock *s = v;
+		struct sock *s = v, *peer;
 		struct unix_sock *u = unix_sk(s);
 		unix_state_lock(s);
 
@@ -2186,6 +2186,13 @@ static int unix_seq_show(struct seq_file *seq, void *v)
 			}
 			for ( ; i < len; i++)
 				seq_putc(seq, u->addr->name->sun_path[i]);
+		} else {
+			peer = unix_peer(s);
+			if (peer) {
+				unix_state_lock(peer);
+				seq_printf(seq, " peer=%lu", sock_i_ino(peer));
+				unix_state_unlock(peer);
+			}
 		}
 		unix_state_unlock(s);
 		seq_putc(seq, '\n');
-- 
1.6.4
