From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Subject: Re: [PATCH net-2.6.25] Add packet filtering based on process\'s security context.
Date: Wed, 23 Jan 2008 10:26:40 +0900
Message-ID: <200801230126.m0N1QeVb090477@www262.sakura.ne.jp>
References: <634344.24836.qm@web36604.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: linux-security-module@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
To: casey@schaufler-ca.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <634344.24836.qm@web36604.mail.mud.yahoo.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

Casey Schaufler wrote:
> Do you have a real situation where two user processes with different
> security contexts share a socket? How do you get into that situation,
> and is it appropriate to have that situation in your security scheme?
> Can this occur without using privilege?

I hope such situation won't occur, as I have mentioned in the previous
posting.

| Precautions: This approach has a side effect which unlikely occurs.
| 
| If a socket is shared by multiple processes with differnt policy,
| the process who should be able to accept this connection
| will not be able to accept this connection
| because socket_post_accept() aborts this connection.
| But if socket_post_accept() doesn't abort this connection,
| the process who must not be able to accept this connection
| will repeat accept() forever, which is a worse side effect.
| 
| Similarly, if a socket is shared by multiple processes with differnt policy,
| the process who should be able to pick up this datagram
| will not be able to pick up this datagram
| because socket_post_recv_datagram() discards this datagram.
| But if socket_post_recv_datagram() doesn't discard this datagram,
| the process who must not be able to pick up this datagram
| will repeat recvmsg() forever, which is a worse side effect.
| 
| So, don't give different permissions between processes who shares one socket.
| Otherwise, some connections/datagrams cannot be delivered to intended process.

But it is possible to write a code like

---------- app3.c start ----------
/* gcc -Wall -O2 -o /tmp/app3 app3.c */
#include <fcntl.h>
#include <netinet/in.h>
#include <stdio.h>
#include <string.h>
#include <sys/select.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
	const int fd1 = socket(PF_INET, SOCK_DGRAM, 0), fd2 = socket(PF_INET, SOCK_DGRAM, 0);
	struct sockaddr_in addr;
	char buf[16];
	memset(&addr, 0, sizeof(addr));
	addr.sin_family = AF_INET;
	addr.sin_addr.s_addr = htonl(INADDR_ANY);
	addr.sin_port = htons(10000);
	fprintf(stderr, "%s started.\n", argv[0]);
	if (bind(fd1, (struct sockaddr *) &addr, sizeof(addr))) {
		fprintf(stderr, "Can't bind()\n");
		return 1;
	}
	if (sendto(fd2, "hello\n", 6, 0, (struct sockaddr *) &addr, sizeof(addr)) != 6 ||
	    sendto(fd2, "world\n", 6, 0, (struct sockaddr *) &addr, sizeof(addr)) != 6) {
		fprintf(stderr, "Can't sendto()\n");
		return 1;
	}
	while (1) {
		fd_set rfds;
		FD_ZERO(&rfds);
		FD_SET(fd1, &rfds);
		select(fd1 + 1, &rfds, NULL, NULL, NULL);
		if (FD_ISSET(fd1, &rfds)) break;
		fprintf(stderr, "Can't select()\n");
		return 1;
	}
	if (fcntl(fd1, FD_CLOEXEC, 0)) {
		fprintf(stderr, "Can't fcntl()\n");
		return 1;
	}
	snprintf(buf, sizeof(buf), "%d", fd1);
	execlp("/tmp/app4", "app4", buf, NULL);
	fprintf(stderr, "Can't execve()\n");
	return 1;
}
---------- app3.c end ----------

---------- app4.c start ----------
/* gcc -Wall -O2 -o /tmp/app4 app4.c */
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
	int fd;
	if (argc != 2) {
		fprintf(stderr, "Bad parameter.\n");
		return 1;
	}
	fprintf(stderr, "%s started.\n", argv[0]);
	fd = atoi(argv[1]);
	while (1) {
		struct sockaddr_in addr;
		socklen_t size = sizeof(addr);
		char buffer[1024];
		int len;
		len = recvfrom(fd, buffer, sizeof(buffer), 0, (struct sockaddr *) &addr, &size);
		if (len == EOF) {
			fprintf(stderr, "Can't recvfrom()\n");
			return 1;
		}
		write(1, buffer, len);
	}
	return 0;
}
---------- app4.c end ----------

and assign different policy to /tmp/app1 and /tmp/app2 .
Therefore, I want to check at sys_recvmsg() time.

(Usage: Compile app3 and app4 and run /tmp/app3 .)
For TCP's case, see http://www.mail-archive.com/linux-security-module@vger.kernel.org/msg02531.html

What I want to do is perform connection/packet filtering
with the recipient of the incoming connection/packet known.
My security scheme controls based on the recipient of the incoming connection/packet.
In this case, not /tmp/app1 or /tmp/app3 , but /tmp/app2 or /tmp/app4.
This case occurs without using privilege.

Regards.
