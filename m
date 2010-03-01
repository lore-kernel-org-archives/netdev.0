From: Kenan Kalajdzic <kenan@unix.ba>
Subject: Re: [RFC][PATCH] af_unix: Add peer inode to /proc/net/unix
Date: Mon, 1 Mar 2010 16:09:36 +0100
Message-ID: <20100301150930.GA220@home.unix.ba>
References: <20100301045206.GB496@home.unix.ba>
 <412e6f7f1002282305i1d201d76h4085220f71fc76d0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-mail-359.bluehost.com ([66.147.249.253]:53345 "HELO
	outbound-mail-359.bluehost.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751118Ab0CAPMm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Mar 2010 10:12:42 -0500
Content-Disposition: inline
In-Reply-To: <412e6f7f1002282305i1d201d76h4085220f71fc76d0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 01, 2010 at 03:05:50PM +0800, Changli Gao wrote:

> If there are two read requests, the system maybe locked up. please use
> unix_state_double_lock()/unix_state_double_unlock(), instead. And the

Thanks for pointing this out.  The corrected patch is provided at the end.

> file isn't consistent with the old one. You'd better use a column
> title "Peer" instead of "peer=".

As far as the column name is concerned, I avoided adding a new column, since 
this would break userspace programs.  Instead, I reused empty space provided 
within the 'Path' column to add peer inode number for unbound sockets.  This 
makes it easy to match client and server sockets as well as unnamed socket 
pairs created with socketpair(2).

Here is an example of using the peer inode information from /proc/net/unix
to find all local X-clients:

(1)  Find all X-server sockets:

# strings /proc/net/unix | grep X11

e51ec8c0: 00000002 00000000 00010000 0001 01 12318 /tmp/.X11-unix/X0
d2ae98c0: 00000003 00000000 00000000 0001 03 16077 /tmp/.X11-unix/X0
d2b38e00: 00000003 00000000 00000000 0001 03 15858 /tmp/.X11-unix/X0
d2a3bc40: 00000003 00000000 00000000 0001 03 13828 /tmp/.X11-unix/X0
d2a3b1c0: 00000003 00000000 00000000 0001 03 13816 /tmp/.X11-unix/X0
d2909380: 00000003 00000000 00000000 0001 03 13802 /tmp/.X11-unix/X0
d299da80: 00000003 00000000 00000000 0001 03 13728 /tmp/.X11-unix/X0
d299d540: 00000003 00000000 00000000 0001 03 13722 /tmp/.X11-unix/X0
d293f380: 00000003 00000000 00000000 0001 03 13715 /tmp/.X11-unix/X0
d2957700: 00000003 00000000 00000000 0001 03 13644 /tmp/.X11-unix/X0
d291fa80: 00000003 00000000 00000000 0001 03 13585 /tmp/.X11-unix/X0
d290de00: 00000003 00000000 00000000 0001 03 13573 /tmp/.X11-unix/X0
d9fea700: 00000003 00000000 00000000 0001 03 13550 /tmp/.X11-unix/X0
d9fea000: 00000003 00000000 00000000 0001 03 13531 /tmp/.X11-unix/X0
d28b5e00: 00000003 00000000 00000000 0001 03 13465 /tmp/.X11-unix/X0
e541e540: 00000003 00000000 00000000 0001 03 13277 /tmp/.X11-unix/X0
d2898e00: 00000003 00000000 00000000 0001 03 13269 /tmp/.X11-unix/X0
e42ee000: 00000003 00000000 00000000 0001 03 12376 /tmp/.X11-unix/X0

(2)  Using inode number of each of the listed X-server sockets, find the 
     corresponding peer socket.  Here we make use of the fact that the peer
     inode number is recorded within the 'Path' column of client sockets:

# strings /proc/net/unix | egrep 'peer=(12318|16077|15858|13828|13816|13802'\
> '|13728|13722|13715|13644|13585|13573|13550|13531|13465|13277|13269|12376)$'

d2ae9700: 00000003 00000000 00000000 0001 03 16076 peer=16077
d2b38c40: 00000003 00000000 00000000 0001 03 15857 peer=15858
d2a3ba80: 00000003 00000000 00000000 0001 03 13827 peer=13828
d2a3b000: 00000003 00000000 00000000 0001 03 13815 peer=13816
d29091c0: 00000003 00000000 00000000 0001 03 13801 peer=13802
d299d8c0: 00000003 00000000 00000000 0001 03 13727 peer=13728
d299d380: 00000003 00000000 00000000 0001 03 13721 peer=13722
d293fc40: 00000003 00000000 00000000 0001 03 13714 peer=13715
d29578c0: 00000003 00000000 00000000 0001 03 13643 peer=13644
d291f8c0: 00000003 00000000 00000000 0001 03 13584 peer=13585
d290dc40: 00000003 00000000 00000000 0001 03 13572 peer=13573
d9fea540: 00000003 00000000 00000000 0001 03 13549 peer=13550
d28a98c0: 00000003 00000000 00000000 0001 03 13530 peer=13531
d9fe5e00: 00000003 00000000 00000000 0001 03 13464 peer=13465
e541e700: 00000003 00000000 00000000 0001 03 13276 peer=13277
d28988c0: 00000003 00000000 00000000 0001 03 13268 peer=13269
e51ece00: 00000003 00000000 00000000 0001 03 12320 peer=12376

(3)  Using the peer inode numbers, find the corresponding process(es)
     through /proc/<PID>/fd/*:

# ls -l /proc/*/fd/* 2>/dev/null | egrep 'socket:.(16076|'\
> '15857|13827|13815|13801|13727|13721|13714|13643|13584|'\
> '13572|13549|13530|13464|13276|13268|12320)'

lr-x------ 1 root root 64 Mar  1 15:07 /proc/4101/fd/3 -> socket:[12320]
lrwx------ 1 root root 64 Mar  1 15:20 /proc/4243/fd/3 -> socket:[13276]
lrwx------ 1 root root 64 Mar  1 15:24 /proc/4311/fd/4 -> socket:[13268]
lrwx------ 1 root root 64 Mar  1 15:24 /proc/4323/fd/3 -> socket:[13464]
lrwx------ 1 root root 64 Mar  1 15:24 /proc/4338/fd/12 -> socket:[13530]
lrwx------ 1 root root 64 Mar  1 15:24 /proc/4342/fd/3 -> socket:[13549]
lrwx------ 1 root root 64 Mar  1 15:24 /proc/4344/fd/3 -> socket:[13572]
lrwx------ 1 root root 64 Mar  1 15:24 /proc/4351/fd/3 -> socket:[13584]
lrwx------ 1 root root 64 Mar  1 15:24 /proc/4353/fd/3 -> socket:[13643]
lrwx------ 1 root root 64 Mar  1 15:24 /proc/4371/fd/8 -> socket:[13721]
lrwx------ 1 root root 64 Mar  1 15:24 /proc/4374/fd/3 -> socket:[13727]
lrwx------ 1 root root 64 Mar  1 15:24 /proc/4387/fd/4 -> socket:[13827]
lrwx------ 1 root root 64 Mar  1 15:24 /proc/4389/fd/3 -> socket:[13815]
lrwx------ 1 root root 64 Mar  1 15:24 /proc/4393/fd/3 -> socket:[13801]
lrwx------ 1 root root 64 Mar  1 15:24 /proc/4401/fd/3 -> socket:[13714]
lrwx------ 1 root root 64 Mar  1 15:24 /proc/4477/fd/3 -> socket:[15857]
lrwx------ 1 root root 64 Mar  1 15:24 /proc/4488/fd/3 -> socket:[16076]

(4)  Finally, use the PIDs obtained in previous step to get a readable
     list of X-clients:

# ps -eo pid,args | awk '$1 ~ "^(4101|4243|4311|4323|4338|4342|'\
> '4344|4351|4353|4371|4374|4387|4389|4393|4401|4477|4488)$"'

 4101 /usr/sbin/gdm-binary -nodaemon
 4243 /usr/bin/gnome-session
 4311 /usr/bin/dbus-launch --exit-with-session /etc/X11/xinit/Xclients
 4323 /usr/libexec/gnome-settings-daemon
 4338 metacity --sm-client-id=default1
 4342 gnome-panel --sm-client-id default2
 4344 nautilus --no-default-window --sm-client-id default3
 4351 gnome-volume-manager --sm-client-id default5
 4353 eggcups --sm-client-id default4
 4371 ./escd --key_Inserted="/usr/bin/esc" --on_Signal="/usr/bin/esc"
 4374 bt-applet --sm-disable
 4387 /usr/bin/python -tt /usr/bin/puplet
 4389 nm-applet --sm-disable
 4393 pam-panel-icon --sm-client-id default0
 4401 gnome-power-manager
 4477 gnome-screensaver
 4488 gnome-terminal


Signed-off-by: Kenan Kalajdzic <kenan@unix.ba>
---
 net/unix/af_unix.c |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index f255119..cee957a 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2157,9 +2157,14 @@ static int unix_seq_show(struct seq_file *seq, void *v)
 		seq_puts(seq, "Num       RefCount Protocol Flags    Type St "
 			 "Inode Path\n");
 	else {
-		struct sock *s = v;
+		struct sock *s = v, *peer;
 		struct unix_sock *u = unix_sk(s);
+
 		unix_state_lock(s);
+		peer = unix_peer(s);
+		unix_state_unlock(s);
+
+		unix_state_double_lock(s, peer);
 
 		seq_printf(seq, "%p: %08X %08X %08X %04X %02X %5lu",
 			s,
@@ -2186,8 +2191,10 @@ static int unix_seq_show(struct seq_file *seq, void *v)
 			}
 			for ( ; i < len; i++)
 				seq_putc(seq, u->addr->name->sun_path[i]);
-		}
-		unix_state_unlock(s);
+		} else if (peer)
+			seq_printf(seq, " peer=%lu", sock_i_ino(peer));
+
+		unix_state_double_unlock(s, peer);
 		seq_putc(seq, '\n');
 	}
 
-- 
1.6.4
