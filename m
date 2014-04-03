From: "Ulrich Windl" <Ulrich.Windl@rz.uni-regensburg.de>
Subject: Q (somewhat long): Obscure socket send problem (process is
 killed)
Date: Thu, 03 Apr 2014 12:58:30 +0200
Message-ID: <533D5AF6020000A10001520A@gwsmtp1.uni-regensburg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrzmta2.uni-regensburg.de ([194.94.155.52]:48795 "EHLO
	rrzmta2.uni-regensburg.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751692AbaDCLF3 convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:1:1>);
	Thu, 3 Apr 2014 07:05:29 -0400
Received: from rrzmta2.uni-regensburg.de (localhost [127.0.0.1])
	by localhost (Postfix) with SMTP id A23EF4536B
	for <netdev@vger.kernel.org>; Thu,  3 Apr 2014 12:58:33 +0200 (CEST)
Received: from gwsmtp1.uni-regensburg.de (gwsmtp1.uni-regensburg.de [132.199.5.51])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(Client CN "gwsmtp.uni-regensburg.de", Issuer "Uni Regensburg CA - G01" (not verified))
	by rrzmta2.uni-regensburg.de (Postfix) with ESMTPS id 284604524A
	for <netdev@vger.kernel.org>; Thu,  3 Apr 2014 12:58:32 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

(apologies for trying innovative programming)

I have a network problem that I cannot explain, and I don't know what to do:
I am writing a program that (basically) copied from one socket-connection to another, full duplex. As opposed to the usual approach using select(), I run two additional threads (one for read, one for write) to handle the traffic (actually there is one process for each connection, starting two additional threads for the traffic). Basically that seems to work...

However if one thread discovers that the connection is closed, it uses shutdown() to close its direction. I'm observing that the writing-thread is unable to deliver all its data one the reading thread has shut down it's direction. To make matters worse, when the writer tries to send the rest, the pocess is killed. There are no syslog messages from the kernel when this happens...

The kernel used in that of SLES11 SP3 ( 3.0.101-0.15-xen), and my test machine is Xen paravirtualized with two virtual CPUs and 1GB of RAM (The Xen host is also running 3.0.101-0.15-xen, and there are no releated messages in syslog or xen dmesg).

Now my first question: Is it correct that send() has no error as long as the result is > 0?

The code that both threads use lokks like this (vlogf() is my variable-args printf()-like thread-safe logging function, and "handler" points to connection-releted data):
---
/* copy data from one socket to another */
static  int     socket_copy(int i_sock, int o_sock, const char *ID)
{
        int     result = 0;
        char    buffer[buffer_size];
        ssize_t sz;

        while ( (sz = recv(i_sock, buffer, sizeof(buffer), 0)) > 0 ) {
                ssize_t         osz;
                const char      *bp = buffer;

                vlogf(LOG_DEBUG, "%s: received %ld bytes from %d", ID, (long) sz, i_sock);
                while ( (osz = send(o_sock, bp, sz, 0)) != sz ) {
                        if ( osz <= 0 ) {
                                vlogf(LOG_ERR, "%s: failed to send %ld bytes to %d: %s", ID, (long) sz, o_sock, strerror(errno));
                                result = -1;
                                goto leave;
                        }
                        vlogf(LOG_INFO, "%s: sent %ld of %ld bytes", ID, (long) osz, (long) sz);
                        bp += osz;
                        sz -= osz;
                }
                vlogf(LOG_DEBUG, "%s: sent %ld bytes to %d", ID, (long) osz, o_sock);
        }
leave:
        vlogf(LOG_DEBUG, "%s: %s returns with size %ld result %d", ID, __func__, (long) sz, result);
        return(sz == 0 ? result : -1);
}
---

What my reading thread does is basically this (do_shutdown() is like shutdown(), but it would log any error):
---
        result = socket_copy(i_conn->sock, o_conn->sock, ID);
        vlogf(LOG_DEBUG, "%s: copy %d (%s) -> %d (%s) finished with %d",  ID, i_conn->sock, i_conn->r_addr.desc_real, o_conn->sock,  o_conn->r_addr.desc_real, result);
        vlogf(LOG_DEBUG, "%s: shutdown read direction", ID);
        if ( do_shutdown(i_conn->sock, SHUT_RD) != 0 )
                result = -1;
        if ( do_shutdown(o_conn->sock, SHUT_WR) != 0 )
                result = -1;
---

And the writing thread does this:
---
        result = socket_copy(o_conn->sock, i_conn->sock, ID);
        vlogf(LOG_DEBUG, "%s: copy %d (%s) -> %d (%s) finished with %d", ID, o_conn->sock, o_conn->r_addr.desc_real, i_conn->sock, i_conn->r_addr.desc_real, result);
        vlogf(LOG_DEBUG, "%s: shutdown write direction", ID);
        if ( do_shutdown(o_conn->sock, SHUT_RD) != 0 )
                result = -1;
        if ( do_shutdown(i_conn->sock, SHUT_WR) != 0 )
                result = -1;
---

Normally the log looks like this (my comments after ###):
---
sredir: (D)[0x7f14cfd34030:6167](172.20.64: create reader thread
sredir: (D)[0x7f14cfd34030:6167](172.20.64: create writer thread
sredir: (D)[6167](reader): received 474 bytes from 7
sredir: (D)[6167](reader): sent 474 bytes to 6
sredir: (D)[0x7f14cfd34030:6167](172.20.64: wait for reader thread
### the connection process waits for the reader thread to finish
### copying goes on...
sredir: (D)[6167](writer): received 16384 bytes from 6
sredir: (D)[6167](writer): sent 16384 bytes to 7
sredir: (D)[6167](writer): received 6328 bytes from 6
sredir: (D)[6167](writer): sent 6328 bytes to 7
sredir: (D)[6167](writer): received 7300 bytes from 6
sredir: (D)[6167](writer): sent 7300 bytes to 7
### (my receive buffer is 16kB)
---

Now when the reader thread finishes, the following happens:
---
sredir: (D)[6167](writer): received 16384 bytes from 6
sredir: (D)[6167](reader): socket_copy returns with size 0 result 0
sredir: (D)[6167](reader): copy 7 (172.20.64.67/54054) -> 6 (192.168.255.18/80) finished with 0
sredir: (D)[6167](reader): shutdown read direction
sredir: (D)[0x7f14cfd34030:6167](172.20.64: reader thread returned 0
sredir: (D)[0x7f14cfd34030:6167](172.20.64: wait for writer thread
### the connection process now waits for the writer thread to finish
---

Unfortunately the writer seems to get some problem:
---
sredir: (I)[6167](writer): sent 14684 of 16384 bytes
###(incomplete write, but no error, the writer should retry (see code)
sredir: (N)cleanup_thread: child PID 6167 terminated by signal 13
### the main listening process gets a child that was killed by signal 13, why?
sredir: (D)free_handler: free 0x7f14cfd34030 at 0 [1]
sredir: (D)cleanup_thread: 0 used connection entries
sredir: (D)cleanup_thread: leaves with -1: No child processes
### here the listening process waits for new connections
---

However the problem does not always appear; here's an example of a successful copy:
---
###...
sredir: (D)[6171](writer): received 8192 bytes from 6
sredir: (D)[6171](writer): sent 8192 bytes to 7
sredir: (D)[6171](reader): received 502 bytes from 7
sredir: (D)[6171](reader): sent 502 bytes to 6
sredir: (D)[6171](writer): received 371 bytes from 6
sredir: (D)[6171](writer): sent 371 bytes to 7
sredir: (D)[6171](writer): received 8192 bytes from 6
sredir: (D)[6171](writer): sent 8192 bytes to 7
sredir: (D)[6171](writer): received 8192 bytes from 6
sredir: (D)[6171](writer): sent 8192 bytes to 7
sredir: (D)[6171](writer): received 8192 bytes from 6
sredir: (D)[6171](writer): sent 8192 bytes to 7
sredir: (D)[6171](writer): received 8192 bytes from 6
sredir: (D)[6171](writer): sent 8192 bytes to 7
sredir: (D)[6171](writer): received 8192 bytes from 6
sredir: (D)[6171](writer): sent 8192 bytes to 7
sredir: (D)[6171](writer): received 8192 bytes from 6
sredir: (D)[6171](writer): sent 8192 bytes to 7
sredir: (D)[6171](writer): received 8192 bytes from 6
sredir: (D)[6171](writer): sent 8192 bytes to 7
sredir: (D)[6171](writer): received 8192 bytes from 6
sredir: (D)[6171](writer): sent 8192 bytes to 7
sredir: (D)[6171](reader): socket_copy returns with size 0 result 0
sredir: (D)[6171](reader): copy 7 (172.20.64.67/54055) -> 6 (192.168.255.18/80) finished with 0
sredir: (D)[6171](reader): shutdown read direction
sredir: (D)[0x7f14cfd34280:6171](172.20.64: reader thread returned 0
### reader finished without problems
sredir: (D)[0x7f14cfd34280:6171](172.20.64: wait for writer thread
sredir: (D)[6171](writer): socket_copy returns with size 0 result 0
sredir: (D)[6171](writer): copy 6 (192.168.255.18/80) -> 7 (172.20.64.67/54055) finished with 0
sredir: (D)[6171](writer): shutdown write direction
sredir: (N)do_shutdown: failed to shutdown socket 6 with 0: Transport endpoint is not connected
### I'm still investigating: Was the input closed by remote party already?
sredir: (D)[0x7f14cfd34280:6171](172.20.64: writer thread returned -1
### the error comed from do_shutdown()...
sredir: (D)[0x7f14cfd34280:6171](172.20.64: close inbound socket 7
sredir: (D)[0x7f14cfd34280:6171](172.20.64: close outbound socket 6
sredir: (D)connection_handler: [0x7f14cfd34280:6171](172.20.64 finished
sredir: (D)free_handler: free 0x7f14cfd34030 at 0 [1]
sredir: (D)cleanup_thread: 0 used connection entries
sredir: (D)cleanup_thread: leaves with -1: No child processes
---

Here are some more examples when the writer thread did not finish:
---
sredir: (D)[7016](writer): received 16384 bytes from 6
sredir: (D)[7016](writer): sent 16384 bytes to 7
sredir: (D)[7016](writer): received 16384 bytes from 6
sredir: (D)[7016](writer): sent 16384 bytes to 7
sredir: (D)[7016](writer): received 16384 bytes from 6
sredir: (D)[7016](reader): socket_copy returns with size 0 result 0
sredir: (D)[7016](reader): copy 7 (172.20.64.67/54093) -> 6 (192.168.255.18/80) finished with 0
sredir: (D)[7016](reader): shutdown read direction
sredir: (D)[0x7f4607b57030:7016](172.20.64: reader thread returned 0
sredir: (D)[0x7f4607b57030:7016](172.20.64: wait for writer thread
sredir: (I)[7016](writer): sent 3104 of 16384 bytes
sredir: (N)cleanup_thread: child PID 7016 terminated by signal 13
sredir: (D)free_handler: free 0x7f4607b57030 at 0 [1]
sredir: (D)cleanup_thread: 0 used connection entries
sredir: (D)cleanup_thread: leaves with -1: No child processes
---

---
sredir: (D)[7047](writer): sent 8192 bytes to 7
sredir: (D)[7047](writer): received 8192 bytes from 6
sredir: (D)[7047](writer): sent 8192 bytes to 7
sredir: (D)[7047](writer): received 8192 bytes from 6
sredir: (D)[7047](writer): sent 8192 bytes to 7
sredir: (D)[7047](reader): socket_copy returns with size 0 result 0
sredir: (D)[7047](reader): copy 7 (172.20.64.67/54100) -> 6 (192.168.255.18/80)\
 finished with 0
sredir: (D)[7047](reader): shutdown read direction
sredir: (D)[0x7f4607b57970:7047](172.20.64: reader thread returned 0
sredir: (D)[0x7f4607b57970:7047](172.20.64: wait for writer thread
sredir: (D)[7047](writer): received 8192 bytes from 6
sredir: (D)[7047](writer): sent 8192 bytes to 7
sredir: (D)[7047](writer): received 8192 bytes from 6
sredir: (D)[7047](writer): sent 8192 bytes to 7
sredir: (D)[7047](writer): received 5840 bytes from 6
sredir: (N)cleanup_thread: child PID 7047 terminated by signal 13
sredir: (D)free_handler: free 0x7f4607b57970 at 4 [6]
---

---
sredir: (D)[7042](writer): received 16384 bytes from 6
sredir: (D)[7042](writer): sent 16384 bytes to 7
sredir: (D)[7042](writer): received 16384 bytes from 6
sredir: (D)[7042](writer): sent 16384 bytes to 7
sredir: (D)[7042](writer): received 16384 bytes from 6
sredir: (D)[7042](reader): socket_copy returns with size 0 result 0
sredir: (D)[7042](reader): copy 7 (172.20.64.67/54097) -> 6 (192.168.255.18/80)\
 finished with 0
sredir: (D)[7042](reader): shutdown read direction
sredir: (D)[0x7f4607b57030:7042](172.20.64: reader thread returned 0
sredir: (D)[0x7f4607b57030:7042](172.20.64: wait for writer thread
sredir: (I)[7042](writer): sent 9748 of 16384 bytes
sredir: (N)cleanup_thread: child PID 7042 terminated by signal 13
sredir: (D)free_handler: free 0x7f4607b57030 at 0 [6]
---

---
sredir: (D)[6167](writer): sent 16384 bytes to 7
sredir: (D)[6167](writer): received 16384 bytes from 6
sredir: (D)[6167](writer): sent 16384 bytes to 7
sredir: (D)[6167](writer): received 16384 bytes from 6
sredir: (D)[6167](reader): socket_copy returns with size 0 result 0
sredir: (D)[6167](reader): copy 7 (172.20.64.67/54054) -> 6 (192.168.255.18/80)\
 finished with 0
sredir: (D)[6167](reader): shutdown read direction
sredir: (D)[0x7f14cfd34030:6167](172.20.64: reader thread returned 0
sredir: (D)[0x7f14cfd34030:6167](172.20.64: wait for writer thread
sredir: (I)[6167](writer): sent 14684 of 16384 bytes
sredir: (N)cleanup_thread: child PID 6167 terminated by signal 13
sredir: (D)free_handler: free 0x7f14cfd34030 at 0 [1]
---

I'd be happy if you tell me what stupid programming (or thinking) errror I made, but I'm afraid something does not work correctly.

Also my program is still in development, but I could provide a x86_64 binary for the parties interested to reproduce the problem or to fix it (if it's a kernel problem). Please refer to "Build: 0.0 (Git:shared-695a436+unstaged)" when addressing issues.

As I'm not subscribed to the network development list, please keep me on CC: -- thank you!)

Regards,
Ulrich Windl
