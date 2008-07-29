From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: sendfile() behavior while troubleshooting netdevice
Date: Mon, 28 Jul 2008 19:07:07 -0500
Message-ID: <20080728190707.329d247b@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_/pUq/7Xvlqnbq+ZOMn.YswqC"
Cc: ian@jeffray.co.uk
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost01.isp.att.net ([204.127.217.101]:46467 "EHLO
	fmailhost01.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752928AbYG2AHK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2008 20:07:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--MP_/pUq/7Xvlqnbq+ZOMn.YswqC
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

I'm troubleshooting the problem reported here and I need some help:  
http://lkml.org/lkml/2008/7/15/325.  

Summary of problem:

sendfile() + TSO + atl1 driver == corrupted file at the receiver

According to the reporter, remove either sendfile() or TSO from the
equation and no corruption occurs.

In order to bound the scope of the problem, I wrote a little sendfile()
client/server program so I can control the data being transferred and
isolate the cause of the corruption, but I can't get the program to
work right no matter *what* NIC or kernel version I use.  I get
corrupted data at the receiver.  Where am I going wrong?

Basically, the server listens on port 5000.  The client connects and
sends the filename it wants to fetch from the server.  The server
responds with the size of the file first, then calls sendfile() to ship
the file proper.

At small file sizes (<10k ish), I get good copies most of the time.
At larger file sizes (e.g. 150k), I *never* get a good copy.

Here's an example.

The hosts:
server, petrel,  r8169, 192.168.1.6,   2.6.20-1.2320.fc5
client, sparrow, e100,  192.168.1.195, 2.6.25.6-27.fc8

(Note that neither of these hosts uses the atl1 driver, however I get
similar behavior whenever I employ a host that does.)

[jcliburn@petrel ~]$ ./sfsrv
sending file 'testfile' size 1600 bytes
1600 bytes sent
sending file 'testfile' size 1600 bytes
1600 bytes sent
sending file 'testfile' size 1600 bytes
1600 bytes sent


[jcliburn@sparrow ~]$ ./sfcli 192.168.1.6 testfile
connected...
file size is 1600 bytes
received 1600 bytes
[jcliburn@sparrow ~]$ ./sfcli 192.168.1.6 testfile
connected...
file size is 1600 bytes
received 1600 bytes
[jcliburn@sparrow ~]$ ./sfcli 192.168.1.6 testfile
connected...
file size is 1600 bytes
received 1592 bytes
error: expected 1600, received 1592

The last round came up short 8 bytes.  Any idea why?  Client and server
source code attached.

It doesn't matter which host is the server or client; data is lost
either way.

Thanks for any assistance.

Jay
--MP_/pUq/7Xvlqnbq+ZOMn.YswqC
Content-Type: text/x-csrc; name=sfclient.c
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=sfclient.c

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <arpa/inet.h>

int main(int argc, char **argv)
{
	int sock;
	int ret;
	unsigned int fsize;
	unsigned int count = 0;
	unsigned int prev;
	unsigned short port = 5000;
	char fname[128];
	char cfsize[12];
	char buf[65536];
	FILE* outf;
	struct sockaddr_in addr;

	if (argc != 3) {
		fprintf(stderr, "Usage: %s IP_addr filename\n", argv[0]);
		exit(1);
	}

	memset(&addr, 0, sizeof(addr));
	ret = inet_aton(argv[1], &addr.sin_addr);
	if (!ret) {
		fprintf(stderr, "invalid IP address %s\n", argv[1]);
		exit(1);
	}

	ret = sscanf(argv[2], "%s", fname);
	if (ret != 1) {
		fprintf(stderr, "filename error");
		exit(1);
	}

	addr.sin_family = AF_INET;
	addr.sin_port = htons(port);

	sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
	if (sock == -1) {
		perror("socket()");
		exit(1);
	}

	ret = connect(sock, (struct sockaddr *)&addr, sizeof(addr));
	if (ret == -1) {
		perror("connect()");
		fprintf(stderr, "connection failed\n");
		exit(1);
	}

	fprintf(stderr, "connected...\n");

	/* send the filename to the server */
	ret = send(sock, fname, strlen(fname), 0);
	if (ret == -1) {
		perror("send()");
		fprintf(stderr, "send failed\n");
		exit(1);
	}

	/* get the file size back from the server */
	ret = recv(sock, cfsize, sizeof(cfsize), 0);
	if (ret == -1) {
		perror("recv()");
		fprintf(stderr, "recv failed\n");
		exit(1);
	}
	fsize = atoi(cfsize);
	fprintf(stderr, "file size is %d bytes\n", fsize);

	/* open the output file */
	outf = fopen(fname, "w");
	if (!outf) {
		perror("fopen()");
		fprintf(stderr, "file open failed\n");
	}

	/* receive the incoming data and write it to the output file */
	while (count < fsize) {
		ret = recv(sock, buf, sizeof(buf), MSG_DONTWAIT);
		if (ret == -1) {
			perror("recv()");
			fprintf(stderr, "recv failed\n");
		}

		if (ret > 0) {
			fwrite(buf, sizeof(char), (size_t) ret, outf);
			fprintf(stderr, "received %d bytes\n", ret);
		}

		prev = count;
		count += ret;
		if (prev == count) {
			fprintf(stderr, "error: expected %d, received %d\n",
				fsize, count);
			exit(1);
		}
	}
	fclose(outf);
	exit(0);
}



--MP_/pUq/7Xvlqnbq+ZOMn.YswqC
Content-Type: text/x-csrc; name=sfserver.c
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=sfserver.c

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <sys/stat.h>
#include <sys/sendfile.h>

int main(int argc, char **argv)
{
	int sock;
	int ret;
	int desc;
	int fd;
	int len;
	unsigned short port = 5000;
	char fname[128];
	char fsize[12];
	off_t offset = 0;
	struct sockaddr_in addr;
	struct sockaddr_in addr2;
	struct stat stat_buf;

	sock = socket(AF_INET, SOCK_STREAM, 0);
	if (sock == -1) {
		perror("socket()");
		fprintf(stderr, "socket failed\n");
		exit(1);
	}

	memset(&addr, 0, sizeof(addr));
	addr.sin_family = AF_INET;
	addr.sin_addr.s_addr = INADDR_ANY;
	addr.sin_port = htons(port);

	ret =  bind(sock, (struct sockaddr *) &addr, sizeof(addr));
	if (ret) {
		perror("bind()");
		fprintf(stderr, "bind socket failed\n");
		exit(1);
	}

	/* listen for client */
	ret = listen(sock, 1);
	if (ret) {
		perror("listen()");
		fprintf(stderr, "listen failed\n");
		exit(1);
	}

	while (1) {
		len = sizeof(struct sockaddr);
		desc = accept(sock, (struct sockaddr *) &addr2, &len);
		if (desc == -1) {
			perror("accept()");
			fprintf(stderr, "accept failed\n");
			exit(1);
		}

		/* get the file name from the client and open it */
		ret = recv(desc, fname, sizeof(fname), 0);
		if (ret == -1) {
			perror("recv()");
			fprintf(stderr, "recv failed\n");
			exit(1);
		}
		fname[ret] = '\0';
		fd = open(fname, O_RDONLY);
		if (fd == -1) {
			perror("open()");
			fprintf(stderr, "unable to open '%s'\n", fname);
			exit(1);
		}

		/* get the size of the file and tell the client */
		fstat(fd, &stat_buf);
		sprintf(fsize, "%d", stat_buf.st_size);
		ret = send(desc, fsize, strlen(fsize), 0);
		if (ret == -1) {
			perror("send()");
			fprintf(stderr, "send failed\n");
			exit(1);
		}

		fprintf(stderr, "sending file '%s' size %d bytes\n",
			fname, stat_buf.st_size);

		/* send the file */
		offset = 0;
		ret = sendfile(desc, fd, &offset, stat_buf.st_size);
		if (ret == -1) {
			perror("sendfile()");
			fprintf(stderr, "sendfile failed\n");
			exit(1);
		}
		fprintf(stderr, "%d bytes sent\n", ret);

		/* did the whole file get sent? */
		if (ret != stat_buf.st_size) {
			fprintf(stderr, "error: %d of %d bytes transferred\n",
				ret, (int) stat_buf.st_size);
			exit(1);
		}
		close(fd);
		close(desc);
	}
	close(sock);
	exit(0);
}

--MP_/pUq/7Xvlqnbq+ZOMn.YswqC--
