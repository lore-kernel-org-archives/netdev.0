From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: weird behaviour, getting EAGAIN on a connect() call on a unix
 stream socket
Date: Sat, 02 Aug 2014 08:28:09 +0200
Message-ID: <1406960889.3178.60.camel@edumazet-glaptop2.roam.corp.google.com>
References: <53DC6039.2010002@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Chris Friesen <chris.friesen@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:50714 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750850AbaHBG2O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Aug 2014 02:28:14 -0400
Received: by mail-we0-f176.google.com with SMTP id q58so5220571wes.21
        for <netdev@vger.kernel.org>; Fri, 01 Aug 2014 23:28:12 -0700 (PDT)
In-Reply-To: <53DC6039.2010002@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-08-01 at 21:51 -0600, Chris Friesen wrote:
> Hi,
> 
> I'm trying to figure out what would case a connect() call on a unix stream
> socket to return EAGAIN.  (On a 3.4 kernel, if it matters.)
> 
> I've got two unix stream sockets on the system, created by two qemu instances
> as virtio-serial channels.
> 
> I've got an app that tries to connect() to both of them in turn.  The connect()
> to the first socket fails with EAGAIN, the second one succeeds, and all
> subsequent retries on the first fail.  Here's an strace() of the sequence:
> 
> socket(PF_FILE, SOCK_STREAM, 0)         = 6
> fcntl(6, F_GETFL)                       = 0x2 (flags O_RDWR)
> fcntl(6, F_SETFL, O_RDWR|O_NONBLOCK)    = 0

Non blocking socket : If listener queue is full, -EAGAIN is expected

> connect(6, {sa_family=AF_FILE, sun_path="/var/lib/libvirt/qemu/cgcs.messaging.instance-00000007.sock"}, 61) = -1 EAGAIN (Resource temporarily unavailable)
> clock_gettime(CLOCK_MONOTONIC, {158877, 262941763}) = 0
> socket(PF_FILE, SOCK_STREAM, 0)         = 7
> fcntl(7, F_GETFL)                       = 0x2 (flags O_RDWR)
> fcntl(7, F_SETFL, O_RDWR|O_NONBLOCK)    = 0
> connect(7, {sa_family=AF_FILE, sun_path="/var/lib/libvirt/qemu/cgcs.messaging.instance-00000008.sock"}, 61) = 0
> getdents(5, /* 0 entries */, 32768)     = 0
> close(5)                                = 0
> clock_gettime(CLOCK_MONOTONIC, {158877, 265359109}) = 0
> poll([{fd=3, events=POLLIN}, {fd=4, events=POLLIN}, {fd=7, events=POLLIN}], 3, 997) = 0 (Timeout)
> clock_gettime(CLOCK_MONOTONIC, {158878, 265914614}) = 0
> connect(6, {sa_family=AF_FILE, sun_path="/var/lib/libvirt/qemu/cgcs.messaging.instance-00000007.sock"}, 61) = -1 EAGAIN (Resource temporarily unavailable)
> 
> 
> With the app not running, netstat seems to show that something is trying to
> connect to the socket in question:
> 
> root@compute-0:~# netstat -ap unix |grep messaging
> unix  2      [ ACC ]     STREAM     LISTENING     1109818  17379/qemu-system-x /var/lib/libvirt/qemu/cgcs.messaging.instance-00000007.sock
> unix  2      [ ACC ]     STREAM     LISTENING     1110051  17425/qemu-system-x /var/lib/libvirt/qemu/cgcs.messaging.instance-00000008.sock
> unix  2      [ ]         STREAM     CONNECTING    0        -                   /var/lib/libvirt/qemu/cgcs.messaging.instance-00000007.sock
> unix  2      [ ]         STREAM     CONNECTING    0        -                   /var/lib/libvirt/qemu/cgcs.messaging.instance-00000007.sock
> unix  2      [ ]         STREAM     CONNECTED     1109848  17379/qemu-system-x /var/lib/libvirt/qemu/cgcs.messaging.instance-00000007.sock
> 
> 
> Here's /proc/net/unix for completeness:
> 
> root@compute-0:~/host-guest-comm# grep -a messaging /proc/net/unix
> ffff880045c35540: 00000002 00000000 00010000 0001 01 1109818 /var/lib/libvirt/qemu/cgcs.messaging.instance-00000007.sock
> ffff8800576b8a80: 00000002 00000000 00010000 0001 01 1110051 /var/lib/libvirt/qemu/cgcs.messaging.instance-00000008.sock
> ffff880045e2f040: 00000002 00000000 00000000 0001 02     0 /var/lib/libvirt/qemu/cgcs.messaging.instance-00000007.sock
> ffff88004bc5ea80: 00000002 00000000 00000000 0001 02     0 /var/lib/libvirt/qemu/cgcs.messaging.instance-00000007.sock
> ffff880045e2f540: 00000002 00000000 00000000 0001 03 1109848 /var/lib/libvirt/qemu/cgcs.messaging.instance-00000007.sock
> 
> 
> 
> The crazy thing is that I can't figure out what could be causing the
> CONNECTED/CONNECTING sockets.  There are no background processes of the
> connecting app running, no zombie processes, no forked children, etc.
> 
> Just to make things more interesting, I successfully ran this application
> several times (connecting to both sockets) before this behaviour started
> happening.  I was running it under strace and just killed it with ctrl-C.
> 
> Anyone got any ideas?   Please CC me since I'm not subscribed to the list.

The application might use a too small listen() backlog ?

Try this debugging patch : (note this might break some applications
parsing /proc/net/unix)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index e96884380732..78b7a7cf3071 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2380,6 +2380,8 @@ static int unix_seq_show(struct seq_file *seq, void *v)
 			for ( ; i < len; i++)
 				seq_putc(seq, u->addr->name->sun_path[i]);
 		}
+		seq_printf(seq, " %u/%u", skb_queue_len(&s->sk_receive_queue),
+			   s->sk_max_ack_backlog);
 		unix_state_unlock(s);
 		seq_putc(seq, '\n');
 	}
