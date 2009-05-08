From: Octavian Purdila <opurdila@ixiacom.com>
Subject: ports beeing reused too fast
Date: Fri, 8 May 2009 23:11:09 +0300
Message-ID: <200905082311.09414.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_dHJBKIr9YeBkm6H"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:23279 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754092AbZEHUMT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2009 16:12:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_dHJBKIr9YeBkm6H
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


Hi,

We've been running into an issue where a firewall would drop packets when an 
moderate (~360) connection rate was going through it. It looks like the 
firewall is dropping the SYNs that reuse ports "too fast". 

We have no issues with Linux 2.6.7, so I guess the behavior changed because of 
this this commit:

commit 6df716340da3a6fdd33d73d7ed4c6f7590ca1c42
Author: Stephen Hemminger <shemminger@osdl.org>
Date:   Thu Nov 3 16:33:23 2005 -0800

    [TCP/DCCP]: Randomize port selection


Now, I did some tests to confirm my suspicion. Basically, I am simulating a 
connection rate test (I've attached the .c to this email) by opening up 
connections and closing them - one at a time, and noting down the ports used, 
then looking for duplicate ports and printing the distance between the 
connection no.

Here is one of the runs, which make 1000 iterations:

listening (port 1242)
 port reused: 38203: distance 578 (624,46)
 port reused: 55693: distance 85 (147,62)
 port reused: 38269: distance 803 (872,69)
 port reused: 46239: distance 249 (344,95)
 port reused: 40981: distance 215 (319,104)
 port reused: 46246: distance 524 (641,117)
 port reused: 43990: distance 378 (498,120)
 port reused: 53766: distance 52 (232,180)
 port reused: 44199: distance 194 (383,189)
 port reused: 59464: distance 173 (384,211)
 port reused: 44417: distance 264 (492,228)
 port reused: 56989: distance 229 (553,324)
 port reused: 60117: distance 69 (394,325)
 port reused: 44549: distance 179 (566,387)
 port reused: 39213: distance 300 (801,501)
 port reused: 60166: distance 152 (671,519)
 port reused: 44178: distance 108 (712,604)
 port reused: 46516: distance 6 (792,786)
 port reused: 55754: distance 95 (969,874)
19 ports were being reused

Running the same test on 2.6.7 yields a "0 ports were being reused" on all 
tests that I've ran (10 or so).

Isn't it desirable to have the behavior from 2.6.7? 

I've looked over the  code and it looks right, so maybe net_random() is not 
random enough? Or maybe there are side effects because of the % port_range?

Thanks,
tavi


--Boundary-00=_dHJBKIr9YeBkm6H
Content-Type: text/x-csrc;
  charset="UTF-8";
  name="port-reuse.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="port-reuse.c"

#include <stdio.h>
#include <sys/types.h>
#include <netinet/ip.h>
#include <sys/socket.h>
#include <unistd.h>

#define N 1000
int ports[N], listen_port = 1234;

/* find duplicate ports and show distance between them */
int analyze(void)
{
	int i, j, n = 0;

	for(i = 0; i < N; i++) {
		for(j = i + 1; j < N; j++) {
			if (ports[i] != ports[j])
				continue;
			printf(" port reused: %d: distance %d (%d,%d)\n", ports[i], j-i, j, i);
			n++;
		}
	}

	printf("%d ports were being reused\n", n);

	return 0;
}

int client(void)
{
	int sock, i = 0;
	size_t tmp;
	struct sockaddr_in addr_bind = {
		.sin_family = AF_INET,
		.sin_addr.s_addr = INADDR_ANY,
		.sin_port = 0,
	}, addr_connect = {
		.sin_family = AF_INET,
		.sin_addr.s_addr = htonl(0x7f000001),
		.sin_port = htons(listen_port),
	}, addr_sockname;

	sleep(1);

 loop:
	sock = socket(AF_INET, SOCK_STREAM, 0);
	if (!sock) {
		perror("client: failed to create socket");
		return -1;
	}

	if (bind(sock, (struct sockaddr*)&addr_bind, sizeof(addr_bind)) < 0) {
		perror("client: failed to bind");
		return -1;
	}

	tmp = sizeof(addr_sockname);
	if (getsockname(sock, (struct sockaddr*)&addr_sockname, &tmp) < 0) {
		perror("client: getsockname failed");
		return -1;
	}

	ports[i] = ntohs(addr_sockname.sin_port);

	if (connect(sock, (struct sockaddr*)&addr_connect, sizeof(addr_connect)) < 0) {
		perror("client: failed to connect");
		return -1;
	}
	

	if (read(sock, &tmp, sizeof(tmp)) != 0) {
		perror("read failed");
		return -1;
	}

	close(sock);

	if (++i < N)
		goto loop;


	return analyze();
}


int server(void)
{
	int sock = socket(AF_INET, SOCK_STREAM, 0), sock2;
	struct sockaddr_in addr = {
		.sin_family = AF_INET,
		.sin_addr.s_addr = INADDR_ANY,
	};

 again:
	addr.sin_port = htons(listen_port);

	if (!sock) {
		perror("server: failed to create socket");
		return -1;
	}

	if (bind(sock, (struct sockaddr*)&addr, sizeof(addr)) < 0) {
		perror("server: failed to bind");
		listen_port++;
		goto again;
	}

	if (listen(sock, 128) < 0) {
		perror("server: failed to listen");
		return -1;
	}

	printf("listening (port %d)\n", listen_port);

	switch (fork()) {
	case -1:
		return -1;
	case 0:
		return client();
	}

 loop:
	sock2 = accept(sock, NULL, NULL);
	if (sock2 < 0) {
		perror("server: accept failed\n");
		return -1;
	}

	close(sock2);
	goto loop;
}


int main()
{

	return server();

}

--Boundary-00=_dHJBKIr9YeBkm6H--
