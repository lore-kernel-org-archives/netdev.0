From: Nir Tzachar <nir.tzachar@gmail.com>
Subject: Re: [RFCv4 PATCH 2/2] net: Allow protocols to provide an
	unlocked_recvmsg socket method
Date: Thu, 17 Sep 2009 17:09:19 +0300
Message-ID: <9b2db90b0909170709n400859c6q13514b315970dde9@mail.gmail.com>
References: <20090916170745.GD7699@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Linux Networking Development Mailing List
	<netdev@vger.kernel.org>,
	Caitlin Bestler <caitlin.bestler@gmail.com>,
	Chris Van Hoof <vanhoof@redhat.com>,
	Clark Williams <williams@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Nivedita Singhvi <niv@us.ibm.com>,
	Paul Moore <paul.moore@hp.com>,
	=?ISO-8859-1?Q?R=E9mi_Denis=2DCourmont?=
	<remi.denis-courmont@nokia.com>,
	Steven Whitehouse <steve@chygwyn.com>,
	Ziv Ayalon <zivayalon@gmail.com>
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:51976 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758200AbZIQOJR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2009 10:09:17 -0400
Received: by fxm17 with SMTP id 17so50278fxm.37
        for <netdev@vger.kernel.org>; Thu, 17 Sep 2009 07:09:19 -0700 (PDT)
In-Reply-To: <20090916170745.GD7699@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

Below are some test results with the patch (only part 1, as I did not
manage to apply part 2).
The test application is attached below, and works as follows:

I set out to measure the latency which can be saved by this patch, and
the application is designed accordingly. It is composed of three
parts: a producer, which time-stamps packets and sends them as fast as
possible, a mirror, which receives messages and bounces them to a
remote destination and finally, a consumer, which receives messages as
fast as possible and measures latency and throughout.

Both the produce and consumer are executed on the same host and the
mirror on a remote host. Both hosts are running linux 2.6.31 with v4
of the patch (but, as I said before, only part 1, with the unlocked_*
stuff). All processes are executed under SCHED_FIFO. Both hosts are
connected by a switched 1G Ethernet network. The mirror is executed on
a 8-core nahelem beast, and the producer and consumer on my desktop,
which is a quad. /proc/cpuinfo and lspcis and .configs can be supplied
if needed. Network cards are Intel Corporation 82566DM-2 Gigabit
Network and Broadcom Corporation NetXtreme II BCM5709 Gigabit
Ethernet.

The results (which follow below) clearly show the advantages of using
recvmmsg over recvmsg both latency wise and throughput wise. The
addition of a sendmmsg would also have a huge impact, IMO.
Receiving batches of 30 packets, each of 1024 bytes, results with no
latency improvements, but with a ~55% throughput improvement, from 72
megabytes per second to  111. Repeating the same test, but with
batches of 3000, displays the same behaviour. The more interesting
result (to me, at least :) is when using small packets. Sending
packets of size 100 and receiving in batches of 30  gives 470 micro
latency and 244669 packets per second. On the other hand, without
recvmmsg we get 750 micro latency and 210818 packets per second. A
huge improvement here.

I think that with a bit more tinkering we can even stretch these results a bit.

Cheers.

The results:

(a sample execution)
Usage:
	       	-n do not use recvmmsg
	       	-r producer/consumer/mirror [producer]
	       	-b recv_batch_size          [8]
	       	-l master_listen_port       [5001]
	       	-t send_to_host              [localhost]
	       	-p slave_listen_port        [5002]
	       	-s packet_size                [256]
	       	-f run in sched fifo
	       	-m use mlockall
10.0.0.1:
sudo ./recvmmsg -r consumer -b 3000 -f -s 1024
sudo ./recvmmsg -r producer -t 10.0.0.2 -f -s 1024 -b 1

10.0.0.2
sudo ./recvmmsg -t 10.0.0.1 -r mirror -b 3000 -f -s 1024

-f -s 1024 -b 30

packets num: 569203, mean: 942.69, max: 1551, stddev: 128.48
packets per second: 113839.96, bytes per second: 116572774
packets num: 569214, mean: 942.61, max: 1385, stddev: 126.55
packets per second: 113841.62, bytes per second: 116575027
packets num: 569210, mean: 943.76, max: 1443, stddev: 127.41
packets per second: 113840.36, bytes per second: 116574208
packets num: 569209, mean: 942.34, max: 1363, stddev: 126.72
packets per second: 113840.18, bytes per second: 116574003
packets num: 569202, mean: 943.43, max: 1495, stddev: 127.88
packets per second: 113839.85, bytes per second: 116572569

-f -s 1024 -b 30 -n

packets num: 373461, mean: 950.15, max: 1351, stddev: 122.45
packets per second: 74691.80, bytes per second: 76484812
packets num: 373494, mean: 954.28, max: 1538, stddev: 125.60
packets per second: 74697.81, bytes per second: 76491571
packets num: 373786, mean: 952.16, max: 1505, stddev: 124.79
packets per second: 74756.24, bytes per second: 76551372
packets num: 373564, mean: 953.37, max: 1500, stddev: 125.18
packets per second: 74712.34, bytes per second: 76505907

-f -s 100 -b 30

packets num: 1208114, mean: 474.45, max: 1849, stddev: 117.70
packets per second: 241616.37, bytes per second: 24162280
packets num: 1223365, mean: 475.24, max: 2273, stddev: 117.12
packets per second: 244669.28, bytes per second: 24467300
packets num: 1231103, mean: 470.03, max: 2509, stddev: 107.01
packets per second: 246219.42, bytes per second: 24622060
packets num: 1242466, mean: 467.69, max: 2753, stddev: 114.55
packets per second: 248488.53, bytes per second: 24849320


-f -s 100 -b 30 -n

packets num: 1044677, mean: 785.11, max: 3635, stddev: 417.51
packets per second: 208933.60, bytes per second: 20893540
packets num: 1054100, mean: 765.59, max: 3259, stddev: 399.20
packets per second: 210818.74, bytes per second: 21082000
packets num: 1051835, mean: 726.04, max: 3403, stddev: 369.04
packets per second: 210365.91, bytes per second: 21036700
packets num: 1048108, mean: 743.42, max: 3440, stddev: 390.79
packets per second: 209620.38, bytes per second: 20962160



-b 3000 -f -s 1024

packets num: 569200, mean: 948.99, max: 1507, stddev: 130.52
packets per second: 113838.77, bytes per second: 116572160
packets num: 569204, mean: 940.57, max: 1307, stddev: 125.34
packets per second: 113840.28, bytes per second: 116572979
packets num: 569193, mean: 957.70, max: 1545, stddev: 138.00
packets per second: 113836.62, bytes per second: 116570726
packets num: 569205, mean: 947.59, max: 1505, stddev: 130.55
packets per second: 113839.91, bytes per second: 116573184
packets num: 569205, mean: 943.81, max: 1395, stddev: 126.93
packets per second: 113840.36, bytes per second: 116573184


-b 3000 -f -s 1024 -n:

packets num: 373661, mean: 952.37, max: 1509, stddev: 131.57
packets per second: 74731.71, bytes per second: 76525772
packets num: 373678, mean: 951.38, max: 1525, stddev: 130.43
packets per second: 74734.52, bytes per second: 76529254
packets num: 373717, mean: 947.87, max: 1499, stddev: 127.31
packets per second: 74742.53, bytes per second: 76537241
packets num: 373727, mean: 944.58, max: 1491, stddev: 125.06
packets per second: 74744.29, bytes per second: 76539289


-f -s 100 -b 3000

packets num: 1380128, mean: 1345.93, max: 4422, stddev: 164.48
packets per second: 276023.28, bytes per second: 27602560
packets num: 1430723, mean: 1379.40, max: 2498, stddev: 45.08
packets per second: 286138.19, bytes per second: 28614460
packets num: 1450128, mean: 1353.45, max: 2589, stddev: 52.73
packets per second: 290024.56, bytes per second: 29002560
packets num: 1422040, mean: 1392.20, max: 2539, stddev: 50.48
packets per second: 284404.25, bytes per second: 28440800
packets num: 1391757, mean: 1422.72, max: 2604, stddev: 50.74
packets per second: 278349.79, bytes per second: 27835140


-f -s 100 -n -b 3000

packets num: 1088358, mean: 828.90, max: 20103, stddev: 660.55
packets per second: 217668.99, bytes per second: 21767160
packets num: 1225010, mean: 1018.98, max: 10186, stddev: 538.93
packets per second: 245000.28, bytes per second: 24500200
packets num: 1090276, mean: 899.01, max: 5032, stddev: 562.04
packets per second: 218001.96, bytes per second: 21805520


recvmmsg.c:

#include "linux/arch/x86/include/asm/unistd.h"

#include <stdlib.h>
#include <syscall.h>
#include <stdio.h>
#include <sys/socket.h>
#include <unistd.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <poll.h>
#include <string.h>
#include <sys/time.h>
#include <time.h>
#include <math.h>
#include <sched.h>
#include <fcntl.h>
#include <sys/mman.h>


struct mmsghdr {
	struct msghdr	msg_hdr;
	unsigned	msg_len;
};


#ifndef NSEC_PER_MSEC
#define NSEC_PER_MSEC	1000000UL
#endif

/* Set a fd into nonblocking mode. */
int set_nonblocking(int fd)
{
	int val;

	if ((val = fcntl(fd, F_GETFL)) == -1)
		return -1;
	if (!(val & O_NONBLOCK)) {
		val |= O_NONBLOCK;
		return fcntl(fd, F_SETFL, val);
	}
	return 0;
}


static int recvmmsg(int fd, struct mmsghdr *mmsg,
			   unsigned vlen, unsigned flags,
			   struct timespec *timeout)
{
	return syscall(__NR_recvmmsg, fd, mmsg, vlen, flags, timeout);
}

static int reg_recvmsg(int fd, struct mmsghdr *mmsg,
			   unsigned vlen, unsigned flags,
			   struct timespec *timeout)
{
	int i;
	int ret = -1;

	for (i=0; i<vlen; i++){
		int tmp = recvmsg(fd, &mmsg[i].msg_hdr, flags);
		if (tmp < 0)
			break;
		mmsg[i].msg_len = tmp;
		ret++;
	}
	return ret;
}

static int reg_sendmsg(int fd, struct mmsghdr *mmsg,
			   unsigned vlen, unsigned flags,
			   struct timespec *timeout)
{
	int i;
	int ret = 0;

	for (i=0; i<vlen; i++){
		int tmp = sendmsg(fd, &mmsg[i].msg_hdr, flags);
		if (tmp <= 0){
			ret = tmp;
			break;
		}
		mmsg[i].msg_len = tmp;
		ret++;
	}
	return ret;
}

static unsigned long long micro_time()
{
	struct timeval tv;
	gettimeofday(&tv, NULL);
	return tv.tv_sec*NSEC_PER_MSEC+tv.tv_usec;
}

typedef int (*send_packets_f)(int fd, struct mmsghdr *mmsg, unsigned vlen,
			    unsigned flags, struct timespec *timeout);
typedef int (*recv_packets_f)(int fd, struct mmsghdr *mmsg, unsigned vlen,
			    unsigned flags, struct timespec *timeout);

//sockets must be bound/connected
static void producer(const int batch_size,
		     const int packet_size,
		     int send_sock,
		     send_packets_f send_f)
{
	char buf[batch_size][packet_size];
	struct iovec iovec[batch_size];
	struct mmsghdr datagrams[batch_size];
	int i;

	for (i = 0; i < batch_size; ++i) {
		memset(&datagrams[i].msg_hdr, 0, sizeof(datagrams[i].msg_hdr));
		iovec[i].iov_base = buf[i];
		iovec[i].iov_len  = sizeof(buf[i]);
		datagrams[i].msg_hdr.msg_iov	 = &iovec[i];
		datagrams[i].msg_hdr.msg_iovlen	 = 1;
	}

	while (1){
		//generate batch_size packets of packet_size, stamp them, and send
		int send_num = 0;
		for (i = 0; i < batch_size; ++i) {
			unsigned long long *stamp =
				(unsigned long long *) &buf[i][0];
			*stamp = micro_time();
		}
		
		send_num = send_f(send_sock, datagrams, batch_size, 0, 0);
		if (send_num < batch_size){
			printf("could not send entire batch: %d %m\n", send_num);
			continue;
		}
	}
}

//sockets must be bound/connected
static void consumer(const int batch_size,
		     const int packet_size,
		     int recv_sock,
		     recv_packets_f recv_f)
{
	char buf[batch_size][packet_size];
	struct iovec iovec[batch_size];
	struct mmsghdr datagrams[batch_size];
	int i;
	unsigned long long start_time = micro_time();
	unsigned long long max = 0;
	double mean = 0;
	double m2 = 0;
	int n = 0;

	if (set_nonblocking(recv_sock) != 0)
		printf("recv socket is in blocking mode\n");
	else
		printf("recv socket is in non-blocking mode\n");

	for (i = 0; i < batch_size; ++i) {
		memset(&datagrams[i].msg_hdr, 0, sizeof(datagrams[i].msg_hdr));
		iovec[i].iov_base = buf[i];
		iovec[i].iov_len  = sizeof(buf[i]);
		datagrams[i].msg_hdr.msg_iov	 = &iovec[i];
		datagrams[i].msg_hdr.msg_iovlen	 = 1;
	}

	struct pollfd pfds[1] = {
		[0] = {
			.fd = recv_sock,
			.events = POLLIN,
		},
	};

	while (1){
		unsigned long long now;

		if (poll(pfds, 1, -1) < 0) {
			perror("poll: ");
			exit(0);
		}

		int ret = recv_f(recv_sock, &datagrams[0], batch_size, 0, 0);
		if (ret < 0){
			perror("consumer recv: ");
			exit(0);
		}

		//go over all received packets, and count latency:
		now = micro_time();
		for (i = 0; i < ret; ++i) {
			double delta;
			unsigned long long *stamp =
				(unsigned long long *) &buf[i];
			unsigned long long sample =
				now - *stamp;
			n++;
			delta = sample - mean;
			mean += delta/n;
			m2 += delta*(sample-mean);

			if (max < sample)
				max = sample;
		}

		if (micro_time() - start_time >= 5000000){
			printf("packets num: %d, mean: %.2f, max: %llu, stddev: %.2f\n",
			       n, mean, max, sqrt(m2/(n-1)));
			printf("packets per second: %.2f, bytes per second: %lld\n",
			       n / ((micro_time() - start_time)/1000000.0),
			       n*packet_size / ((micro_time() - start_time)/1000000));

			start_time = micro_time();
			n = 0;
			mean = 0;
			m2 = 0;
			max = 0;
		}
	}
}

//sockets must be bound/connected
static void mirror(const int batch_size,
	   const int packet_size,
	   int send_sock,
	   int recv_sock,
	   send_packets_f send_f,
	   recv_packets_f recv_f)
{
	char buf[batch_size][packet_size];
	struct iovec iovec[batch_size];
	struct mmsghdr datagrams[batch_size];
	int i;

	if (set_nonblocking(recv_sock) != 0)
		printf("recv socket is in blocking mode\n");
	else
		printf("recv socket is in non-blocking mode\n");

	for (i = 0; i < batch_size; ++i) {
		memset(&datagrams[i].msg_hdr, 0, sizeof(datagrams[i].msg_hdr));
		iovec[i].iov_base = buf[i];
		iovec[i].iov_len  = sizeof(buf[i]);
		datagrams[i].msg_hdr.msg_iov	 = &iovec[i];
		datagrams[i].msg_hdr.msg_iovlen	 = 1;
		datagrams[i].msg_hdr.msg_name	 = NULL;
	}

	while (1){
		int send_num = 0;
		int recv_num = 0;

		struct pollfd pfds[1] = {
			[0] = {
				.fd = recv_sock,
				.events = POLLIN,
			},
		};

		if (poll(pfds, 1, -1) < 0) {
			perror("poll: ");
			exit(0);
		}


		//printf("slave recv...\n");
		recv_num = recv_f(recv_sock, &datagrams[recv_num],
				 batch_size-recv_num, 0, 0);
		if (recv_num < 0) {
			perror("mirror recv");
			exit(0);
		}
		//printf("recv %d packets\n", recv_num);

		while (send_num < recv_num){
			int ret = send_f(send_sock, &datagrams[send_num], recv_num-send_num, 0, 0);
			if (ret < 0){
				perror("mirror send");
				exit(0);
			}
			send_num += ret;
			//printf("sent %d packets\n", ret);
		}
	}
}

static void usage(char *app)
{
	printf("Usage: %s\n"
	       "	-n do not use recvmmsg\n"
	       "	-r producer/consumer/mirror [producer]\n"
	       "	-b recv_batch_size          [8]\n"
	       "	-l master_listen_port       [5001]\n"
	       "	-t send_to_host             [localhost]\n"
	       "	-p slave_listen_port        [5002]\n"
	       "	-s packet_size              [256]\n"
	       "	-f run in sched fifo\n"
	       "	-m use mlockall\n"
	       "	-h this help\n",
	       app);
}

int create_recv_sock(const char *port)
{
	struct addrinfo *host;
	struct addrinfo hints;
	int fd = -1;
	int err;

	memset(&hints, 0, sizeof(struct addrinfo));
	hints.ai_flags = AI_PASSIVE;    /* For wildcard IP address */
	hints.ai_family = AF_INET;
	hints.ai_socktype = SOCK_DGRAM; /* Datagram socket */
	hints.ai_protocol = 0;          /* Any protocol */
	hints.ai_canonname = NULL;
	hints.ai_addr = NULL;
	hints.ai_next = NULL;

	err = getaddrinfo(NULL, port, &hints, &host);
	if (err != 0) {
		fprintf(stderr, "error using getaddrinfo: %s\n",
			gai_strerror(err));
		goto out;
	}
	
	fd = socket(host->ai_family, host->ai_socktype, host->ai_protocol);
	if (fd < 0) {
		perror("recv_sock: ");
		goto out_freeaddrinfo;
	}
	
	if (bind(fd, host->ai_addr, host->ai_addrlen) < 0) {
		perror("recv_sock bind");
		close(fd);
	}

out_freeaddrinfo:
	freeaddrinfo(host);
out:
	return fd;
}

int create_send_sock(const char *host, const char *port)
{
	int fd = -1;
	struct addrinfo *send_host;
	struct addrinfo hints;
	int err;

	memset(&hints, 0, sizeof(struct addrinfo));
	hints.ai_flags = AI_PASSIVE;    /* For wildcard IP address */
	hints.ai_family = AF_INET;
	hints.ai_socktype = SOCK_DGRAM; /* Datagram socket */
	hints.ai_protocol = 0;          /* Any protocol */
	hints.ai_canonname = NULL;
	hints.ai_addr = NULL;
	hints.ai_next = NULL;

	err = getaddrinfo(host, port, &hints, &send_host);
	if (err != 0) {
		fprintf(stderr, "error using getaddrinfo: %s\n",
			gai_strerror(err));
		goto out;
	}
	
	fd = socket(send_host->ai_family, send_host->ai_socktype,
send_host->ai_protocol);
	if (fd < 0) {
		perror("send_sock");
		goto out_freeaddrinfo;
	}

	if (connect(fd, send_host->ai_addr, send_host->ai_addrlen) != 0) {
		perror("send_sock connect");
		close(fd);
	}

out_freeaddrinfo:
	freeaddrinfo(send_host);
out:
	return fd;
}

int main(int argc, char *argv[])
{
	const char *master_listen_port = "5001";
	const char *slave_listen_port = "5002";
	const char *listen_port;
	const char *send_port;
	const char *target_host = "localhost";
	const char *role = "producer";
	int batch_size = 8;
	int packet_size = 256;
	int use_mmsg = 1;
	int s_fifo = 0;
	int lock_mem = 0;
	char c;

	while ( (c=getopt(argc, argv, "mfhr:b:nl:t:p:s:")) != -1){
		switch(c){
		case 'r':
			role = optarg;
			break;
		case 'b':
			batch_size = atoi(optarg);
			break;
		case 'l':
			master_listen_port = optarg;
			break;
		case 't':
			target_host = optarg;
			break;
		case 'p':
			slave_listen_port = optarg;
			break;
		case 'n':
			use_mmsg = 0;
			break;
		case 'm':
			lock_mem = 1;
			break;
		case 'f':
			s_fifo = 1;
			break;
		case 's':
			packet_size = atoi(optarg);
			break;
		case 'h':
		default:
			usage(argv[0]);
			exit(0);
		}
	}
	//set scheduling to SCHED_FIFO
	struct sched_param params;
	params.sched_priority = 99;
	
	if (s_fifo && sched_setscheduler(getpid(), SCHED_FIFO, &params) != 0){
		perror("sched_setscheduler");
	}

	if (sched_getscheduler(getpid()) != SCHED_FIFO)
		printf("not running in SCHED_FIFO\n");
	else
		printf("running in SCHED_FIFO\n");

	if (lock_mem){
		if (mlockall(MCL_CURRENT|MCL_FUTURE) != 0)
			perror("mlockall failed");
		else
			printf("memory is locked\n");
	}

	if (strcmp(role, "producer") == 0 ||
	    strcmp(role, "consumer") == 0){
		listen_port = master_listen_port;
		send_port = slave_listen_port;
	} else {
		listen_port = slave_listen_port;
		send_port = master_listen_port;
	}

	if (strcmp(role, "producer") == 0){
		int send_sock = create_send_sock(target_host, send_port);
		if (send_sock < 0){
			perror("send sock");
			goto out;
		}
		if (use_mmsg){
			printf("starting producer with mmsg\n");
			producer(batch_size,
			       packet_size,
			       send_sock,
			       reg_sendmsg);
		} else {
			printf("starting producer without mmsg\n");
			producer(batch_size,
			       packet_size,
			       send_sock,
			       reg_sendmsg);
		}
	} else if (strcmp(role, "consumer") == 0){
		int recv_sock = create_recv_sock(listen_port);
		if (recv_sock < 0){
			perror("recv_sock ");
			goto out;
		}
		if (use_mmsg){
			printf("starting consumer with mmsg\n");
			consumer(batch_size,
			       packet_size,
			       recv_sock,
			       recvmmsg);
		} else {
			printf("starting consumer without mmsg\n");
			consumer(batch_size,
			       packet_size,
			       recv_sock,
			       reg_recvmsg);
		}
	} else if (strcmp(role, "mirror") == 0){
		int recv_sock = create_recv_sock(listen_port);
		int send_sock = create_send_sock(target_host, send_port);
		if (send_sock < 0){
			perror("send sock");
			goto out;
		}
		if (recv_sock < 0){
			perror("recv_sock ");
			goto out;
		}
		if (use_mmsg){
			printf("starting mirror with mmsg\n");
			mirror(batch_size,
			       packet_size,
			       send_sock,
			       recv_sock,
			       reg_sendmsg,
			       recvmmsg);

		} else {
			printf("starting mirror without mmsg\n");
			mirror(batch_size,
			       packet_size,
			       send_sock,
			       recv_sock,
			       reg_sendmsg,
			       reg_recvmsg);
		}

	} else {
		printf("please specify role as either master or slave\n");
	}

out:
	return 0;
}
