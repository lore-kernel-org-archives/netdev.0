From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH RFC v3 net 0/2] ipv6: Avoid restarting fib6_lookup() for RTF_CACHE hit
Date: Mon, 6 Oct 2014 17:05:13 -0700
Message-ID: <1412640315-22472-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:62326 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751827AbaJGAF2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 20:05:28 -0400
Received: from pps.filterd (m0044010 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id s9705Rnt016680
	for <netdev@vger.kernel.org>; Mon, 6 Oct 2014 17:05:27 -0700
Received: from mail.thefacebook.com (mailwest.thefacebook.com [173.252.71.148])
	by mx0a-00082601.pphosted.com with ESMTP id 1pv4xu01jb-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 06 Oct 2014 17:05:27 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.212.232.63) with ESMTP	id
 a3088bb24db511e48e1e0002c992ebde-d83ea3e0 for <netdev@vger.kernel.org>;	Mon,
 06 Oct 2014 17:05:25 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Notes: Same as the last two versions but fixed a title and missing
Signed-Off issue.

I am trying to understand why there is a need to restart fib6_lookup() after
getting rt with RTF_CACHE.

I have adapted davem's udpflood test
(https://urldefense.proofpoint.com/v1/url?u=https://git.kernel.org/pub/scm/linux/kernel/git/davem/net_test_tools.git&k=ZVNjlDMF0FElm4dQtryO4A%3D%3D%0A&r=%2Faj1ZOQObwbmtLwlDw3XzQ%3D%3D%0A&m=j4KoKiV%2FLl4Dx6wOKiDLZPDODlbMJ5UBybTiTzIRHTM%3D%0A&s=68cac2d1d239e23b104065419b4ad89ea80bc1401571034ccce3b4a52a98a8d3) to
support IPv6 and here is the result:

#root > time ./udpflood -l 20000000 -c 250 2401:db00:face:face::2

Before:
real    0m33.224s
user    0m2.941s
sys     0m30.232s

After:
real    0m31.517s
user    0m2.938s
sys     0m28.536s

/****************************** udpflood.c ******************************/
/* It is an adaptation of the Eric Dumazet's and David Miller's
 * udpflood tool, by adding IPv6  support.
 */

#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <malloc.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <stdint.h>
#include <assert.h>

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#define _GNU_SOURCE
#include <getopt.h>

typedef uint32_t u32;

static int debug = 0;

/* Allow -fstrict-aliasing */
typedef union sa_u {
	struct sockaddr_storage a46;
	struct sockaddr_in a4;
	struct sockaddr_in6 a6;
} sa_u;

static int usage(void)
{
	printf("usage: udpflood [ -l count ] [ -m message_size ] [ -c num_ip_addrs ] IP_ADDRESS\n");
	return -1;
}

static u32 get_last32h(const sa_u *sa)
{
	if (sa->a46.ss_family == PF_INET)
		return ntohl(sa->a4.sin_addr.s_addr);
	else
		return ntohl(sa->a6.sin6_addr.s6_addr32[3]);
}

static void set_last32h(sa_u *sa, u32 last32h)
{
	if (sa->a46.ss_family == PF_INET)
		sa->a4.sin_addr.s_addr = htonl(last32h);
	else
		sa->a6.sin6_addr.s6_addr32[3] = htonl(last32h);
}

static void print_saddr(const sa_u *sa, const char *msg)
{
	char buf[64];

	if (!debug)
		return;

	switch (sa->a46.ss_family) {
	case PF_INET:
		inet_ntop(PF_INET, &(sa->a4.sin_addr.s_addr), buf,
			  sizeof(buf));
		break;
	case PF_INET6:
		inet_ntop(PF_INET6, &(sa->a6.sin6_addr), buf, sizeof(buf));
		break;
	}

	printf("%s: %s\n", msg, buf);
}

static int send_packets(const sa_u *sa, size_t num_addrs, int count, int msg_sz)
{
	char *msg = malloc(msg_sz);
	sa_u saddr;
	u32 start_addr32h, end_addr32h, cur_addr32h;
	int fd, i, err;

	if (!msg)
		return -ENOMEM;

	memset(msg, 0, msg_sz);

	memcpy(&saddr, sa, sizeof(saddr));
	cur_addr32h = start_addr32h = get_last32h(&saddr);
	end_addr32h = start_addr32h + num_addrs;

	fd = socket(saddr.a46.ss_family, SOCK_DGRAM, 0);
	if (fd < 0) {
		perror("socket");
		err = fd;
		goto out_nofd;
	}

	/* connect to avoid the kernel spending time in figuring
	 * out the source address (i.e pin the src address)
	 */
	err = connect(fd, (struct sockaddr *) &saddr, sizeof(saddr));
	if (err < 0) {
		perror("connect");
		goto out;
	}

	print_saddr(&saddr, "start_addr");
	for (i = 0; i < count; i++) {
		print_saddr(&saddr, "sendto");
		err = sendto(fd, msg, msg_sz, 0, (struct sockaddr *)&saddr,
			     sizeof(saddr));
		if (err < 0) {
			perror("sendto");
			goto out;
		}

		if (++cur_addr32h >= end_addr32h)
			cur_addr32h = start_addr32h;
		set_last32h(&saddr, cur_addr32h);
	}

	err = 0;
out:
	close(fd);
out_nofd:
	free(msg);
	return err;
}

int main(int argc, char **argv, char **envp)
{
	int port, msg_sz, count, num_addrs, ret;

	sa_u start_addr;

	port = 6000;
	msg_sz = 32;
	count = 10000000;
	num_addrs = 1;

	while ((ret = getopt(argc, argv, "dl:s:p:c:")) >= 0) {
		switch (ret) {
		case 'l':
			sscanf(optarg, "%d", &count);
			break;
		case 's':
			sscanf(optarg, "%d", &msg_sz);
			break;
		case 'p':
			sscanf(optarg, "%d", &port);
			break;
		case 'c':
			sscanf(optarg, "%d", &num_addrs);
			break;
		case 'd':
			debug = 1;
			break;
		case '?':
			return usage();
		}
	}

	if (num_addrs < 1)
		return usage();

	if (!argv[optind])
		return usage();

	start_addr.a4.sin_port = htons(port);
	if (inet_pton(PF_INET, argv[optind], &start_addr.a4.sin_addr))
		start_addr.a46.ss_family = PF_INET;
	else if (inet_pton(PF_INET6, argv[optind], &start_addr.a6.sin6_addr.s6_addr))
		start_addr.a46.ss_family = PF_INET6;
	else
		return usage();

	return send_packets(&start_addr, num_addrs, count, msg_sz);
}
