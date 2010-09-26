From: Willy Tarreau <w@1wt.eu>
Subject: TCP: orphans broken by RFC 2525 #2.17
Date: Sun, 26 Sep 2010 15:17:17 +0200
Message-ID: <20100926131717.GA13046@1wt.eu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MGYHOYXEY6WxJCY8"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:45689 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757821Ab0IZNRT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Sep 2010 09:17:19 -0400
Received: (from willy@localhost)
	by mail.home.local (8.14.4/8.14.4/Submit) id o8QDHHRN013333
	for netdev@vger.kernel.org; Sun, 26 Sep 2010 15:17:17 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--MGYHOYXEY6WxJCY8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

one haproxy user was reporting occasionally truncated responses to
HTTP POST requests exclusively. After he took many captures, we
could verify that the strace dumps were showing all data to be
emitted, but network captures showed that an RST was emitted before
the end of the data.

Looking more closely, I noticed that in traces showing the issue,
the client was sending an additional CRLF after the data in a
separate packet (permitted eventhough not recommended).

I could thus finally understand what happens and I'm now able to
reproduce it very easily using the attached program. What happens
is that haproxy sends the last data to the client, followed by a
shutdown()+close(). This is mimmicked by the attached program,
which is connected to by a simple netcat from another machine
sending two distinct chunks :

server:$ ./abort-data
client:$ (echo "req1";usleep 200000; echo "req2") | nc6 server 8000
block1
("block2" is missing here)
client:$

It gives the following capture, with client=10.8.3.4 and server=10.8.3.1 :

reading from file abort-linux.cap, link-type EN10MB (Ethernet)
10:47:07.057793 IP (tos 0x0, ttl 64, id 57159, offset 0, flags [DF], proto TCP (6), length 60)
    10.8.3.4.39925 > 10.8.3.1.8000: Flags [S], cksum 0xdad9 (correct), seq 2570439277, win 5840, options [mss 1460,sackOK,TS val 138417450 ecr 0,nop,wscale 6], length 0
10:47:07.058015 IP (tos 0x0, ttl 64, id 0, offset 0, flags [DF], proto TCP (6), length 60)
    10.8.3.1.8000 > 10.8.3.4.39925: Flags [S.], cksum 0x3851 (correct), seq 1066199564, ack 2570439278, win 5792, options [mss 1460,sackOK,TS val 295921514 ecr 138417450,nop,wscale 7], length 0
10:47:07.058071 IP (tos 0x0, ttl 64, id 57160, offset 0, flags [DF], proto TCP (6), length 52)
    10.8.3.4.39925 > 10.8.3.1.8000: Flags [.], cksum 0x7d60 (correct), seq 2570439278, ack 1066199565, win 92, options [nop,nop,TS val 138417451 ecr 295921514], length 0
10:47:07.058213 IP (tos 0x0, ttl 64, id 57161, offset 0, flags [DF], proto TCP (6), length 57)
    10.8.3.4.39925 > 10.8.3.1.8000: Flags [P.], cksum 0x1a40 (incorrect -> 0x8fbc), seq 2570439278:2570439283, ack 1066199565, win 92, options [nop,nop,TS val 138417451 ecr 295921514], length 5
10:47:07.058410 IP (tos 0x0, ttl 64, id 36199, offset 0, flags [DF], proto TCP (6), length 52)
    10.8.3.1.8000 > 10.8.3.4.39925: Flags [.], cksum 0x7d89 (correct), seq 1066199565, ack 2570439283, win 46, options [nop,nop,TS val 295921514 ecr 138417451], length 0
10:47:07.253294 IP (tos 0x0, ttl 64, id 57162, offset 0, flags [DF], proto TCP (6), length 53)
    10.8.3.4.39925 > 10.8.3.1.8000: Flags [P.], cksum 0x1a3c (incorrect -> 0x7321), seq 2570439283:2570439284, ack 1066199565, win 92, options [nop,nop,TS val 138417500 ecr 295921514], length 1
10:47:07.253468 IP (tos 0x0, ttl 64, id 36200, offset 0, flags [DF], proto TCP (6), length 52)
    10.8.3.1.8000 > 10.8.3.4.39925: Flags [.], cksum 0x7d27 (correct), seq 1066199565, ack 2570439284, win 46, options [nop,nop,TS val 295921562 ecr 138417500], length 0
10:47:08.060213 IP (tos 0x0, ttl 64, id 36201, offset 0, flags [DF], proto TCP (6), length 59)
    10.8.3.1.8000 > 10.8.3.4.39925: Flags [P.], cksum 0x354c (correct), seq 1066199565:1066199572, ack 2570439284, win 46, options [nop,nop,TS val 295921765 ecr 138417500], length 7
10:47:08.060270 IP (tos 0x0, ttl 64, id 57163, offset 0, flags [DF], proto TCP (6), length 52)
    10.8.3.4.39925 > 10.8.3.1.8000: Flags [.], cksum 0x7b5e (correct), seq 2570439284, ack 1066199572, win 92, options [nop,nop,TS val 138417701 ecr 295921765], length 0
10:47:08.060298 IP (tos 0x0, ttl 64, id 36202, offset 0, flags [DF], proto TCP (6), length 52)
    10.8.3.1.8000 > 10.8.3.4.39925: Flags [R.], cksum 0x7c51 (correct), seq 1066199572, ack 2570439284, win 46, options [nop,nop,TS val 295921765 ecr 138417500], length 0
10:47:08.060613 IP (tos 0x0, ttl 64, id 0, offset 0, flags [DF], proto TCP (6), length 40)
    10.8.3.1.8000 > 10.8.3.4.39925: Flags [R], cksum 0xb0f5 (correct), seq 1066199572, win 0, length 0
.

The connection should in theory become an orphan. I'm saying "in theory",
because since the following test was added to tcp_close(), if the client
happens to send any data between the last recv() and the close(), we
immediately send an RST to it, regardless of any pending outgoing data :

        /* As outlined in RFC 2525, section 2.17, we send a RST here because
         * data was lost. To witness the awful effects of the old behavior of
         * always doing a FIN, run an older 2.1.x kernel or 2.0.x, start a bulk
         * GET in an FTP client, suspend the process, wait for the client to
         * advertise a zero window, then kill -9 the FTP client, wheee...
         * Note: timeout is always zero in such a case.
         */
        if (data_was_unread) {
                /* Unread data was tossed, zap the connection. */
                NET_INC_STATS_USER(sock_net(sk), LINUX_MIB_TCPABORTONCLOSE);
                tcp_set_state(sk, TCP_CLOSE);
                tcp_send_active_reset(sk, sk->sk_allocation);
	}

The immediate effect then is that the client receives an abort before it
even gets the last data that were scheduled for being sent.

I've read RFC 2525 #2.17 and it shows quite interesting examples of what
it wanted to protect against. However, the recommendation did not consider
the fact that there could be some unacked pending data in the outgoing
buffers.

What is even more more embarrassing is that the HTTP working group is
trying to encourage browsers to enable pipelining by default. That means
that the situation above can become much more common, where two requests
will be pipeline, the first one will cause a short response followed by
a close(), and the simple presence of the second one will kill the first
one's data.

I tried to think about a finer way to process those unwanted data. Ideally,
we should just ignore until the ACK indicates that our last segment was
properly received. Then we could emit the RST.

I made a few attempts by first changing the test above like this :

-        if (data_was_unread) {
+        if (data_was_unread && !tcp_sk(sk)->packets_out) {

then fiddling a little bit in tcp_input.c:tcp_rcv_state_process() for
the TCP_FIN_WAIT1 state, but I'm not satisfied with my experimentations,
they were a bit too much experimental for the results to be considered
reliable.

What I was looking for was a way to only send an RST when the socket is
an orphan and all of its outgoing data has been ACKed. This would cover
the situations that RFC 2525 #2.17 tries to fix without rendering orphans
unusable.

Has anyone an opinion on this, or even could suggest a patch to relax
the conditions in which we send an RST ?

Thanks,
Willy


--MGYHOYXEY6WxJCY8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="abort-data.c"

#include <stdio.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

int port = 8000;
int one = 1;

struct sockaddr_in lst_a;
int lst_fd, srv_fd;
int lbuf;

char buf[1024];

void die_msg(const char *msg)
{
	if (msg)
		fprintf(stderr, "%s\n", msg);
	exit(1);
}

void die_err(const char *msg)
{
	perror(msg);
	exit(1);
}

int main(int argc, char **argv)
{
	if (argc > 1)
		port = atol(argv[1]);

	if ((lst_fd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP)) == -1)
		die_err("socket");

	if ((setsockopt(lst_fd, SOL_SOCKET, SO_REUSEADDR, &one, sizeof(one))) == -1)
		die_err("setsockopt");

	bzero((char *)&lst_a, sizeof(lst_a));
	lst_a.sin_family      = AF_INET;
	lst_a.sin_addr.s_addr = htonl(INADDR_ANY);
	lst_a.sin_port        = htons(port);
	if (bind(lst_fd, (struct sockaddr *)&lst_a, sizeof(lst_a)) == -1)
		die_err("bind");

	if (listen(lst_fd, 1) == -1)
		die_err("listen");

	if ((srv_fd = accept(lst_fd, NULL, NULL)) == -1)
		die_err("accept");

	fprintf(stderr, "accept() returns %d\n", srv_fd);

	if ((lbuf = recv(srv_fd, buf, sizeof(buf), 0)) == -1)
		die_err("recv");

	fprintf(stderr, "recv() returns %d\n", lbuf);

	/* now let's pretend some processing time. If the sender sends any more
	 * data during the sleep(), it causes the response to be truncated.
	 */
	sleep(1);

	send(srv_fd, "block1\n", 7, 0);
	send(srv_fd, "block2\n", 7, 0);
	//shutdown(srv_fd, SHUT_WR);
	close(srv_fd);
	return 0;
}


--MGYHOYXEY6WxJCY8--
