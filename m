From: Stephen Hemminger <shemminger@osdl.org>
Subject: 2.6.10-rc3-mm1 FIONREAD breakge
Date: Fri, 17 Dec 2004 13:07:16 -0800
Message-ID: <20041217130716.1464a068@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@digeo.com>, cliff white <cliffw@osdl.org>,
        netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Latest -mm kernel broke FIONREAD on UDP sockets. This stopped STP in it's tracks
because then names don't resolve.

The following works on 2.6.10-rc3 but breaks on 2.6.10-rc3-mm1
=====================================
/* Did FIONREAD break on UDP? */
#include <stdio.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <netinet/in.h>
#include <arpa/inet.h>

int main(int argc, char **argv)
{
	int s;
	static struct sockaddr_in sin = { AF_INET };
	int len;

	s = socket(AF_INET, SOCK_DGRAM, 0);
	if (bind(s, (struct sockaddr *) &sin, sizeof(sin)) < 0) 
		perror("bind");

	len = sizeof(sin);
	getsockname(s, (struct sockaddr *) &sin, &len);
	printf("Bound to %s.%d\n", 
	       inet_ntoa(sin.sin_addr), ntohs(sin.sin_port));
	for(;;) {
		unsigned long count;
		fflush(stdout);
		if (ioctl(s, FIONREAD, &count) < 0)
			perror("ioctl(FIONREAD)");

		printf("nread = %ld\n", count);
		sleep(5);
	}
}
