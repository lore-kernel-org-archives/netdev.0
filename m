From: Steve Rago <sar@nec-labs.com>
Subject: bug in passing file descriptors
Date: Mon, 7 Oct 2013 14:27:55 -0400
Message-ID: <5252FD2B.5040800@nec-labs.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="------------000209060300020406090507"
Cc: David Miller <davem@davemloft.net>, <mtk.manpages@gmail.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Eric Biederman <ebiederm@xmission.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.nec-labs.com ([138.15.200.209]:52042 "EHLO
	mail.nec-labs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750954Ab3JGTJh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 15:09:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--------------000209060300020406090507
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit

Sending this to a larger group at mtk's suggestion.

I recently found a bug with passing file descriptors over Unix domain sockets.  The attached program illustrates the 
problem.  I believe the source of the problem is in net/core/scm.c.  In put_cmsg(), cmlen is calculated as 
CMSG_SPACE(len) for the purposes of setting msg_controllen, but it probably should be CMSG_LEN(len), at least in this 
particular case (I didn't investigate other use cases).  On a 32-bit platform, a long is a 4-byte quantity and the file 
descriptor is already aligned to a 4-byte quantity by placing it after the cmsghdr structure.  On a 64-byte platform, 
however, a long is an 8-byte quantity, and CMSG_SPACE() assumes that len is aligned on an 8-byte boundary, which isn't a 
requirement for passing file descriptors (which are 4-byte quantities; see scm_fp_copy() to verify).  Anyway, the end 
result is that recvmsg(2) returns with msg_controllen 4 bytes larger than it should be on a 64-bit platform.  The 
attached program prints out a warning message when this happens.

I've tried this on kernels as old as 2.6.18, so it appears this bug has been around for a while.  I originally found it 
on a 3.2.0 kernel.  Michael verified it still exists on a 3.11 kernel.

Let me know if you need any more information

Steve Rago
sar@nec-labs.com

--------------000209060300020406090507
Content-Type: text/x-csrc; name="passfdtest.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="passfdtest.c"

#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <string.h>
#include <errno.h>
#include <sys/socket.h>
#include <sys/stat.h>

void
sendfd(int sockfd, int fd)
{
	char dummybuf;
	struct iovec iov;
	struct msghdr mh;
	struct cmsghdr *cmp = malloc(CMSG_LEN(sizeof(int)));

	if (cmp == NULL) {
		fprintf(stderr, "can't malloc: %s\n", strerror(errno));
		exit(1);
	}
	iov.iov_base = &dummybuf;
	iov.iov_len = 1;
	mh.msg_iov = &iov;
	mh.msg_iovlen = 1;
	mh.msg_name = NULL;
	mh.msg_namelen = 0;
	mh.msg_control = cmp;
	mh.msg_controllen = CMSG_LEN(sizeof(int));
	cmp->cmsg_level = SOL_SOCKET;
	cmp->cmsg_type = SCM_RIGHTS;
	cmp->cmsg_len = CMSG_LEN(sizeof(int));
	*(int *)CMSG_DATA(cmp) = fd;
	if (sendmsg(sockfd, &mh, 0) < 0) {
		fprintf(stderr, "sendmsg failed: %s\n", strerror(errno));
		exit(1);
	}
	free(cmp);
}

int
recvfd(int sockfd)
{
	struct msghdr mh;
	int nfd;
	char dummybuf;
	struct iovec iov;
	long csz = CMSG_LEN(sizeof(int));
	struct cmsghdr *cmp = malloc(csz);

	if (cmp == NULL) {
		fprintf(stderr, "can't malloc: %s\n", strerror(errno));
		exit(1);
	}
	iov.iov_base = &dummybuf;
	iov.iov_len = 1;
	mh.msg_iov = &iov;
	mh.msg_iovlen = 1;
	mh.msg_name = NULL;
	mh.msg_namelen = 0;
	mh.msg_control = cmp;
	mh.msg_controllen = csz;
	if (recvmsg(sockfd, &mh, 0) < 0) {
		fprintf(stderr, "recvmsg failed: %s\n", strerror(errno));
		exit(1);
	}
	if (mh.msg_controllen == 0) {
		fprintf(stderr, "no control data in message\n");
		exit(1);
	}
	if (mh.msg_controllen != csz)
		fprintf(stderr, "WARNING: controllen %ld, should be %ld\n", mh.msg_controllen, csz);
	nfd = *(int *)CMSG_DATA(cmp);
	free(cmp);
	return(nfd);
}

int
main()
{
	int nfd, nfd2;
	int fd[2];
	struct stat sbuf[2];

	printf("sizeof(int) = %d\n", (int)sizeof(int));
	printf("sizeof(long) = %d\n", (int)sizeof(long));
	printf("sizeof(size_t) = %d\n", (int)sizeof(size_t));
	printf("CMSG_LEN(sizeof(int)) = %d\n", (int)CMSG_LEN(sizeof(int)));
	printf("CMSG_SPACE(sizeof(int)) = %d\n", (int)CMSG_SPACE(sizeof(int)));
	if (socketpair(AF_UNIX, SOCK_STREAM, 0, fd) < 0) {
		fprintf(stderr, "can't create socket pair: %s\n", strerror(errno));
		exit(1);
	}
	if ((nfd = open("/etc/services", O_RDONLY)) < 0) {
		fprintf(stderr, "can't open /etc/services: %s", strerror(errno));
		exit(1);
	}
	sendfd(fd[0], nfd);
	nfd2 = recvfd(fd[1]);
	if (fstat(nfd, &sbuf[0]) < 0 || fstat(nfd2, &sbuf[1]) < 0) {
		fprintf(stderr, "fstat failed: %s\n", strerror(errno));
		exit(1);
	}
	if (sbuf[0].st_dev == sbuf[1].st_dev && sbuf[0].st_ino == sbuf[1].st_ino)
		printf("the files are the same\n");
	else
		printf("the files are different\n");
	exit(0);
}

--------------000209060300020406090507--
