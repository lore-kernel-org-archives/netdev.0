From: Alexander Vodomerov <alex@sectorb.msk.ru>
Subject: high latency with TCP connections
Date: Wed, 30 Aug 2006 14:07:34 +0400
Message-ID: <20060830100734.GA22235@isil.ipib.msu.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from isil.ipib.msu.ru ([212.192.237.15]:49551 "EHLO isil.ipib.msu.ru")
	by vger.kernel.org with ESMTP id S1750820AbWH3KHm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2006 06:07:42 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

I'm writing an application that is working over TCP. Total traffic is
very low (~ 10 kb/sec), but performance is very bad. I've tried to
investigate problem with tcpdump and strace, and it shows that
application does multiple writes, but TCP buffers them and send after
some delay (about 40 msec). Due to nature of my application, it is
essential to send any available data ASAP (decreased bandwidth is not
important). I've set TCP_NODELAY option on socket, but it doesn't help.

We've written a simple program to reproduce the effect. It sends 10
small packets, then sleeps for 0.1 sec. Another node tries to receive
data. Strace shows that 2 packets are sent immediately and other 8 are
grouped together and delayed by 40 msec.

It is interesting that this effect can be seen not only on Ethernet
links, but on loopback also (with the same magic constant of 40 msec).

Here is a test run:
  server (should be run first):
$ ./a.out 1 5000
Server: begin send_all
Server: total time 14.216441
  client:
$ ./a.out 2 5000 localhost
Client: connected to localhost:5000
Client: begin receive_all
Client: total time 14.223265

Expected time is 10.0 sec (instead of 14.0 sec).
If packets are received more often (DELIM constant is set to 1 or 2)
then effect disappear.

Is this a desired behaviour? How can I specify that packets should be
sent really immediately after write?

Some people reported that this program runs in 9.997 sec when run on
FreeBSD.

Please cc me on replies, as I'm not subscribed to mailing list.

With best regards, 
   Alexander.

Listing follows:

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <assert.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <netdb.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <time.h>

int TOTAL_SENDS = 1000;
int DELIM = 10;

int sock = -1;

int init_server(int port)
{
	struct sockaddr_in sin;
	struct sockaddr_in new_sin;
	int new_sock;
	int val;
	int sockaddrlen;

	sock = socket(PF_INET, SOCK_STREAM, 0);
	if (sock == -1) return -1;

	val = 1;
	if (setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &val, sizeof(val)) < 0) return -1;

	memset(&sin,0,sizeof(struct sockaddr_in));
        sin.sin_family = AF_INET;
	sin.sin_port = htons(port);
	
	if (-1 == bind(sock,(struct sockaddr*)&sin,sizeof(sin))) return -2;
	if (-1 == listen(sock,1)) return -3;

	sockaddrlen = sizeof(struct sockaddr_in);
        new_sock = accept(sock,(struct sockaddr*)&new_sin,(socklen_t*)&sockaddrlen);
	if (new_sock == -1) return -4;

	sock = new_sock;
	val = 1;
	if (setsockopt(sock, IPPROTO_TCP, TCP_NODELAY, &val, sizeof(val)) != 0) return -5;
	return 0;
}

int init_client(char* hostname, int port)
{
	int val;
	int res;
	struct sockaddr_in sin;

	sock = socket(PF_INET, SOCK_STREAM, 0);

	memset(&sin, 0, sizeof(sin));
	sin.sin_family = AF_INET;
	sin.sin_port = htons(port);
	memcpy(&sin.sin_addr, gethostbyname(hostname)->h_addr, 4);
  
	val = 1;
	setsockopt(sock, IPPROTO_TCP, TCP_NODELAY, &val, sizeof(val));

	res = connect(sock, (struct sockaddr*)&sin, sizeof(sin));
	printf("Client: connected to %s:%d\n", hostname, port);
	if (res == -1) return -1;
        setsockopt(sock, IPPROTO_TCP, TCP_NODELAY, &val, sizeof(val));
	return 0;
}

void send_all(unsigned long delay)
{
	int i;
	char buf[1024];
	printf("Server: begin send_all\n");
	for (i = 1; i < TOTAL_SENDS; ++i) {
                write(sock, buf, 1);
		if (i % DELIM == 0) read(sock, buf, 1);
		if (i % 10 == 0) usleep(delay);
	}
}

void receive_all(unsigned long delay)
{
	int i;
	char buf[1024];
	printf("Client: begin receive_all\n");
	for (i = 1; i < TOTAL_SENDS; ++i) {
		read(sock, buf, 1);
		if (i % DELIM == 0) write(sock, buf, 1);
		if (i % 10 == 0) usleep(delay);
	}
}

int main(int argc, char* argv[])
{
	int port;
	char* host;
	int me;
	struct timeval tv1, tv2;
	double tt;

	assert(argc > 2);
	me = atoi(argv[1]);
	switch (me) {
		case 1:
			port = atoi(argv[2]);
			if (init_server(port)) {
				printf("Server initialization failed!\n");
				return 1;
			}
			gettimeofday(&tv1, 0);
			send_all(100000);
			gettimeofday(&tv2, 0);
			tt = tv2.tv_sec - tv1.tv_sec + (tv2.tv_usec - tv1.tv_usec) * 0.000001;
			printf("Server: total time %f\n", tt);
			break;
		case 2:
			assert(argc == 4);
			port = atoi(argv[2]);
			host = argv[3];
			if (init_client(host, port)) {
				printf("Client initialization failed!\n");
				return 1;
			}
			gettimeofday(&tv1, 0);
			receive_all(100000);
			gettimeofday(&tv2, 0);
			tt = tv2.tv_sec - tv1.tv_sec + (tv2.tv_usec - tv1.tv_usec) * 0.000001;
			printf("Client: total time %f\n", tt);

			break;
		default:
			printf("Wrong parameter\n");
			return 1;
	}
	shutdown(sock, SHUT_RDWR);
	close(sock);
	return 0;
}

