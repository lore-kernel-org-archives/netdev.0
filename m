From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: fix tcp_md5_hash_skb_data()
Date: Tue, 14 May 2013 10:58:21 -0700
Message-ID: <1368554301.4519.20.camel@edumazet-glaptop>
References: <1368516352.32106.13.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Matt Schnall <mischnal@google.com>,
	Bernhard Beck <bbeck@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:35750 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757815Ab3ENR6Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 May 2013 13:58:24 -0400
Received: by mail-pb0-f45.google.com with SMTP id mc8so634818pbc.32
        for <netdev@vger.kernel.org>; Tue, 14 May 2013 10:58:23 -0700 (PDT)
In-Reply-To: <1368516352.32106.13.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-05-14 at 00:25 -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> TCP md5 communications fail [1] for some devices, because sg/crypto code
> assume page offsets are below PAGE_SIZE.
> 
> This was discovered using mlx4 driver [2], but I suspect loopback
> might trigger the same bug now we use order-3 pages in tcp_sendmsg()

Yes, I confirm I can trigger this bug on loopback, using following
program :

./tcp_md5 -s -m 127.0.0.1:somekey &
./tcp_md5 -c -m 127.0.0.1:somekey


/*
 * Copyright 2013 Google Inc. All Rights Reserved.
 * Author: edumazet@google.com (Eric Dumazet)
 *
 * tcp_md5
 * Usage :
 * server side : tcp_md5 -s -m ip_client:md5_key
 * client side : tcp_md5 -c -m ip_server:md5_key
 */
#include <pthread.h>
#include <stdio.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <netinet/in.h>
#include <stdlib.h>
#include <fcntl.h>
#include <string.h>
#include <errno.h>
#include <getopt.h>
#include <netdb.h>
#include <signal.h>
#include <unistd.h>
#include <time.h>
#include <netinet/tcp.h>


char *content;
size_t content_size = 4000000;

void content_init(void)
{
	size_t ui;

	content = malloc(content_size);
	if (!content) {
		perror("bind"); 
		exit(EXIT_FAILURE);
	}
	srandom(12345);
	for (ui = 0; ui < content_size; ui += sizeof(unsigned short))
		*(unsigned short *)(content + ui) = (unsigned short)random();
}



char buffer[4096];

int main(int argc, char *argv[])
{
	int fd, c;
	int sflg = 0, cflg = 0;
	char *mopt = NULL;
	struct tcp_md5sig sig;
	int one = 1;
	int port = 8080;
	struct sockaddr_in server_addr, addr;
	socklen_t len;

	while ((c = getopt(argc, argv, "scm:p:")) != -1) {
		if (c == 's') sflg++;
		else if (c == 'c') cflg++;
		else if (c == 'm') mopt = optarg;
		else if (c == 'p') port = atoi(optarg);
	}
	content_init();
  	memset(&sig, 0, sizeof(sig));
	if (mopt) {
		char *p = strchr(mopt, ':');

		if (!p) {
			fprintf(stderr, " Use -m ip:key\n");
			exit(EXIT_FAILURE);
		}
		*p++ = 0;
		sig.tcpm_keylen = strlen(p);
		memcpy(sig.tcpm_key, p, sig.tcpm_keylen);
		addr.sin_family = AF_INET;
		inet_pton(AF_INET, mopt, &addr.sin_addr);
		memcpy(&sig.tcpm_addr, &addr, sizeof(addr));
	}
	if (sflg + cflg != 1) {
		fprintf(stderr, "Use option -c or -s\n");
		exit(EXIT_FAILURE);
	}
	if (sflg) {
		int listener_fd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
		if (listener_fd == -1) {
			perror("socket");
			exit(EXIT_FAILURE);
		}
		if (setsockopt(listener_fd, SOL_SOCKET, SO_REUSEADDR,
			       &one, sizeof(one)) == -1) {
			perror("setsockopt");
			exit(EXIT_FAILURE);
		}
		memset(&server_addr, 0, sizeof(server_addr));
		server_addr.sin_family = AF_INET;
		server_addr.sin_port = htons(port);
		if (bind(listener_fd, (struct sockaddr *)&server_addr, sizeof(server_addr))) {
			perror("bind"); 
			exit(EXIT_FAILURE);
		}
		if (setsockopt(listener_fd, SOL_TCP,  TCP_MD5SIG, &sig, sizeof(sig)) == -1) {
			perror("TCP_MD5SIG");
			exit(EXIT_FAILURE);
		}
		if (listen(listener_fd, 255) == -1) {
			perror("listen");
			exit(EXIT_FAILURE);
		}
		while (1) {
			pid_t pid;
			off_t off;
			len = sizeof(addr);
			fd = accept(listener_fd, (struct sockaddr *)&addr, &len);
			if (fd == -1) {
				perror("accept");
				exit(EXIT_FAILURE); 
			}
			signal(SIGCLD, SIG_IGN);
			pid = fork();
			if (pid == -1) {
				close(fd);
				continue;
			}
			if (pid)
				continue;
//			sleep(1);
			for (off = 0; ;) {
				int lu = read(fd, buffer, 4096);
				if (lu <= 0) break;
				if (memcmp(content + off, buffer, lu)) {
					fprintf(stderr, "Mismatch at off %llu\n", (unsigned long long)off);
					break;
				}
				off += lu;
			}
			printf("read %llu bytes\n", (unsigned long long)off);
			close(fd);
			exit( off == content_size ? 0 : EXIT_FAILURE);
		}
	}
	if (cflg) {
		int fd1 = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
		int fd2 = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
		if (fd1 == -1) {
			perror("socket");
			exit(EXIT_FAILURE);
		}
		if (setsockopt(fd1, SOL_SOCKET, SO_REUSEADDR,
			       &one, sizeof(one)) == -1) {
			perror("setsockopt");
			exit(EXIT_FAILURE);
		}
		
		addr.sin_port = htons(port);
		if (setsockopt(fd1, SOL_TCP, TCP_MD5SIG,
			       &sig, sizeof(sig)) == -1) {
			perror("TCP_MD5SIG");
			exit(EXIT_FAILURE);
		}
		if (connect(fd1, (struct sockaddr *)&addr,
			    sizeof(addr))) {
			perror("connect"); 
			exit(EXIT_FAILURE);
		}
		if (fd2 == -1) {
			perror("socket");
			exit(EXIT_FAILURE);
		}
		if (setsockopt(fd2, SOL_SOCKET, SO_REUSEADDR,
			       &one, sizeof(one)) == -1) {
			perror("setsockopt");
			exit(EXIT_FAILURE);
		}
		
		addr.sin_port = htons(port);
		if (setsockopt(fd2, SOL_TCP, TCP_MD5SIG,
			       &sig, sizeof(sig)) == -1) {
			perror("TCP_MD5SIG");
			exit(EXIT_FAILURE);
		}
		if (connect(fd2, (struct sockaddr *)&addr,
			    sizeof(addr))) {
			perror("connect"); 
			exit(EXIT_FAILURE);
		}
		if (1) {
			size_t off1 = 0;
			size_t off2 = 0;
			srandom(12345);
			while (1) {
				if (off1 < content_size) {
					int res;
					int amount = random() % 10000;
					if (amount > content_size - off1)
						amount = content_size - off1;
					res = write(fd1, content + off1, amount);
					if (res == -1) {
						perror("write");
						exit(EXIT_FAILURE);
					}
					off1 += res;
				}
				if (off2 < content_size) {
					int res;
					int amount = random() % 10000;
					if (amount > content_size - off2)
						amount = content_size - off2;
					res = write(fd2, content + off2, amount);
					if (res == -1) {
						perror("write");
						exit(EXIT_FAILURE);
					}
					off2 += res;
				}
			if (off1 == content_size && off2 == content_size)
				break;
			}
		}
		close(fd1);
		close(fd2);
	}
	exit(0);
}
