From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: way of figuring out total number of retransmitted packets on a TCP socket?
Date: Tue, 26 Oct 2004 15:47:02 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041026134702.GA2891@xi.wantstofly.org>
References: <20041020130134.GC24757@xi.wantstofly.org> <20041020151448.51209278.davem@davemloft.net> <20041020223547.GJ29583@xi.wantstofly.org> <20041020213739.6e669fdd.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="St7VIuEGZ6dlpu13"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041020213739.6e669fdd.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--St7VIuEGZ6dlpu13
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Oct 20, 2004 at 09:37:39PM -0700, David S. Miller wrote:

> Please give this 2.6.x patch a spin:

Works quite nicely, thank you very much.  I've attached the sources
of the tools that we're using in combination with this -- basically
just a discard server and a client.  (You need the libivykis async
I/O lib installed to compile the server.)

A 1GB cross-atlantic transfer (~715kpackets) over a proper provider
typically shows something like this:  (Discard server is on a GbE
connection in LA, the transmitter on FastE in Amsterdam.)

	[...]
	tcpi_total_retrans      2


The same test done over a second-rate provider:

	[...]
	tcpi_total_retrans      3482


--L

--St7VIuEGZ6dlpu13
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="eat.c"

#include <stdio.h>
#include <stdlib.h>
#include <arpa/inet.h>
#include <iv.h>
#include <netinet/in.h>
#include <syslog.h>
#include <sys/socket.h>
#include <unistd.h>

struct iv_fd master_fd;

struct connection
{
	struct iv_fd		fd;
};

void connection_handler(void *_conn)
{
	struct connection *conn = (struct connection *)_conn;
	char buf[65536];
	int len;

	len = iv_read(&(conn->fd), buf, sizeof(buf));
	if (len <= 0) {
		if (len == 0 || errno != EAGAIN) {
			iv_unregister_fd(&(conn->fd));
			close(conn->fd.fd);
			free(conn);
		}
		return;
	}
}

void new_connection(void *_dummy)
{
	struct sockaddr_in addr;
	socklen_t addrlen;
	struct connection *conn;
	int fd;

	addrlen = sizeof(addr);
	fd = iv_accept(&master_fd, (struct sockaddr *)&addr, &addrlen);
	if (fd <= 0) {
		if (fd < 0 && errno == EAGAIN)
			return;
		perror("iv_accept");
		exit(-1);
	}

	conn = malloc(sizeof(*conn));
	if (conn == NULL) {
		syslog(LOG_ALERT, "new_connection: memory allocation error, dropping connection");
		close(fd);
		return;
	}

	INIT_IV_FD(&(conn->fd));
	conn->fd.fd = fd;
	conn->fd.cookie = (void *)conn;
	conn->fd.handler_in = connection_handler;
	iv_register_fd(&(conn->fd));
}

int main()
{
	struct sockaddr_in addr;
	int fd;

	fd = socket(AF_INET, SOCK_STREAM, 0);
	if (fd < 0) {
		perror("socket");
		exit(-1);
	}

	addr.sin_family = AF_INET;
	addr.sin_addr.s_addr = htonl(INADDR_ANY);
	addr.sin_port = htons(9);
	if (bind(fd, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
		perror("bind");
		exit(-1);
	}

	if (listen(fd, 1000) < 0) {
		perror("listen");
		exit(-1);
	}

	iv_init();

	INIT_IV_FD(&(master_fd));
	master_fd.fd = fd;
	master_fd.handler_in = new_connection;
	iv_register_fd(&(master_fd));

	iv_main();

	return 0;
}

--St7VIuEGZ6dlpu13
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="feed.c"

#include <stdio.h>
#include <stdlib.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <netinet/in.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

#include <linux/sockios.h>
#include <linux/tcp.h>

#ifndef SOL_TCP
#define SOL_TCP		6
#endif

struct tcp_info2
{
	u_int8_t	tcpi_state;
	u_int8_t	tcpi_ca_state;
	u_int8_t	tcpi_retransmits;
	u_int8_t	tcpi_probes;
	u_int8_t	tcpi_backoff;
	u_int8_t	tcpi_options;
	u_int8_t	tcpi_snd_wscale:4, tcpi_rcv_wscale:4;
 
	u_int32_t	tcpi_rto;
	u_int32_t	tcpi_ato;
	u_int32_t	tcpi_snd_mss;
	u_int32_t	tcpi_rcv_mss;
 
	u_int32_t	tcpi_unacked;
	u_int32_t	tcpi_sacked;
	u_int32_t	tcpi_lost;
	u_int32_t	tcpi_retrans;
	u_int32_t	tcpi_fackets;
 
	/* Times. */
	u_int32_t	tcpi_last_data_sent;
	u_int32_t	tcpi_last_ack_sent;	/* Not remembered, sorry. */
	u_int32_t	tcpi_last_data_recv;
	u_int32_t	tcpi_last_ack_recv;
 
	/* Metrics. */
	u_int32_t	tcpi_pmtu;
	u_int32_t	tcpi_rcv_ssthresh;
	u_int32_t	tcpi_rtt;
	u_int32_t	tcpi_rttvar;
	u_int32_t	tcpi_snd_ssthresh;
	u_int32_t	tcpi_snd_cwnd;
	u_int32_t	tcpi_advmss;
	u_int32_t	tcpi_reordering;
 
	u_int32_t	tcpi_rcv_rtt;
	u_int32_t	tcpi_rcv_space;
 
	u_int32_t	tcpi_total_retrans;
};

static unsigned char zeroes[65536];

static char *tcpi_state(int state)
{
	switch (state) {
	case TCP_ESTABLISHED:		return "ESTABLISHED";
	case TCP_SYN_SENT:		return "SYN_SENT";
	case TCP_SYN_RECV:		return "SYN_RECV";
	case TCP_FIN_WAIT1:		return "FIN_WAIT1";
	case TCP_FIN_WAIT2:		return "FIN_WAIT2";
	case TCP_TIME_WAIT:		return "TIME_WAIT";
	case TCP_CLOSE:			return "CLOSE";
	case TCP_CLOSE_WAIT:		return "CLOSE_WAIT";
	case TCP_LAST_ACK:		return "LAST_ACK";
	case TCP_LISTEN:		return "LISTEN";
	case TCP_CLOSING:		return "CLOSING";
	}

	return "invalid";
}

static char *tcpi_ca_state(int state)
{
	switch (state) {
	case TCP_CA_Open:		return "CA_Open";
	case TCP_CA_Disorder:		return "CA_Disorder";
	case TCP_CA_CWR:		return "CA_CWR";
	case TCP_CA_Recovery:		return "CA_Recovery";
	case TCP_CA_Loss:		return "CA_Loss";
	}

	return "invalid";
}

int main(int argc, char *argv[])
{
	struct sockaddr_in addr;
	struct tcp_info2 tcpi;
	struct hostent *he;
	int bytes;
	int port;
	int ret;
	int fd;

	if (argc <= 1) {
		fprintf(stderr, "syntax: %s <hostname> [port] [megs]\n", argv[0]);
		exit(-1);
	}

	he = gethostbyname(argv[1]);
	if (he == NULL) {
		herror("gethostbyname");
		exit(-1);
	}
	addr.sin_family = he->h_addrtype;
	memcpy(&(addr.sin_addr), he->h_addr_list[0], he->h_length);
	endhostent();

	port = 9;
	if (argc > 2 && sscanf(argv[2], "%d", &port) != 1) {
		fprintf(stderr, "%s: second argument not numeric\n", argv[0]);
		exit(-1);
	}
	addr.sin_port = htons(port);

	bytes = 1024;
	if (argc > 3 && sscanf(argv[3], "%d", &bytes) != 1) {
		fprintf(stderr, "%s: third argument not numeric\n", argv[0]);
		exit(-1);
	}
	bytes <<= 20;

	fd = socket(AF_INET, SOCK_STREAM, 0);
	if (fd < 0) {
		perror("socket");
		return 1;
	}

	ret = connect(fd, (struct sockaddr *)&addr, sizeof(addr));
	if (ret < 0) {
		perror("connect");
		return 1;
	}

	ret = sizeof(tcpi);
	if (getsockopt(fd, SOL_TCP, TCP_INFO, &tcpi, &ret) < 0) {
		perror("getsockopt(TCP_INFO)");
		return 1;
	}

	while (bytes) {
		int tosend;

		tosend = bytes;
		if (tosend > sizeof(zeroes))
			tosend = sizeof(zeroes);

		ret = write(fd, zeroes, tosend);
		if (ret < 0) {
			perror("write");
			break;
		}

		bytes -= ret;
	}

	shutdown(fd, SHUT_RDWR);
	sleep(1);

	tcpi.tcpi_total_retrans = 0xdeadbeef;

	ret = sizeof(tcpi);
	if (getsockopt(fd, SOL_TCP, TCP_INFO, &tcpi, &ret) < 0) {
		perror("getsockopt(TCP_INFO)");
		return 1;
	}

	printf("tcpi_state\t\t%d, %s\n", tcpi.tcpi_state, tcpi_state(tcpi.tcpi_state));
	printf("tcpi_ca_state\t\t%d, %s\n", tcpi.tcpi_ca_state, tcpi_ca_state(tcpi.tcpi_ca_state));
	printf("tcpi_retransmits\t%d\n", tcpi.tcpi_retransmits);
	printf("tcpi_probes\t\t%d\n", tcpi.tcpi_probes);
	printf("tcpi_backoff\t\t%d\n", tcpi.tcpi_backoff);
	printf("tcpi_options\t\t%d", tcpi.tcpi_options);
	if (tcpi.tcpi_options) {
		printf(" [");
		if (tcpi.tcpi_options & TCPI_OPT_TIMESTAMPS)
			printf("TIMESTAMPS ");
		if (tcpi.tcpi_options & TCPI_OPT_SACK)
			printf("SACK ");
		if (tcpi.tcpi_options & TCPI_OPT_WSCALE)
			printf("WSCALE ");
		if (tcpi.tcpi_options & TCPI_OPT_ECN)
			printf("ECN ");
		printf("]");
	}
	printf("\n");
	if (tcpi.tcpi_options & TCPI_OPT_WSCALE) {
		printf("tcpi_snd_wscale\t\t%d\n", tcpi.tcpi_snd_wscale);
		printf("tcpi_rcv_wscale\t\t%d\n", tcpi.tcpi_rcv_wscale);
	}
	printf("\n");

	printf("tcpi_rto\t\t%d\n", tcpi.tcpi_rto);
	printf("tcpi_ato\t\t%d\n", tcpi.tcpi_ato);
	printf("tcpi_snd_mss\t\t%d\n", tcpi.tcpi_snd_mss);
	printf("tcpi_rcv_mss\t\t%d\n", tcpi.tcpi_rcv_mss);
	printf("\n");

	printf("tcpi_unacked\t\t%d\n", tcpi.tcpi_unacked);
	printf("tcpi_sacked\t\t%d\n", tcpi.tcpi_sacked);
	printf("tcpi_lost\t\t%d\n", tcpi.tcpi_lost);
	printf("tcpi_retrans\t\t%d\n", tcpi.tcpi_retrans);
	printf("tcpi_fackets\t\t%d\n", tcpi.tcpi_fackets);
	printf("\n");

	printf("tcpi_last_data_sent\t%d\n", tcpi.tcpi_last_data_sent);
	printf("tcpi_last_ack_sent\t%d\n", tcpi.tcpi_last_ack_sent);
	printf("tcpi_last_data_recv\t%d\n", tcpi.tcpi_last_data_recv);
	printf("tcpi_last_ack_recv\t%d\n", tcpi.tcpi_last_ack_recv);
	printf("\n");

	printf("tcpi_pmtu\t\t%d\n", tcpi.tcpi_pmtu);
	printf("tcpi_rcv_sstresh\t%d\n", tcpi.tcpi_rcv_ssthresh);
	printf("tcpi_rtt\t\t%d\n", tcpi.tcpi_rtt);
	printf("tcpi_rttvar\t\t%d\n", tcpi.tcpi_rttvar);
	printf("tcpi_snd_sstresh\t%d\n", tcpi.tcpi_snd_ssthresh);
	printf("tcpi_snd_cwnd\t\t%d\n", tcpi.tcpi_snd_cwnd);
	printf("tcpi_advmss\t\t%d\n", tcpi.tcpi_advmss);
	printf("tcpi_reordering\t\t%d\n", tcpi.tcpi_reordering);
	printf("\n");

	printf("tcpi_rcv_rtt\t\t%d\n", tcpi.tcpi_rcv_rtt);
	printf("tcpi_rcv_space\t\t%d\n", tcpi.tcpi_rcv_space);
	printf("\n");

	if (tcpi.tcpi_total_retrans != 0xdeadbeef) {
		printf("tcpi_total_retrans\t%d\n", tcpi.tcpi_total_retrans);
		printf("\n");
	}

	close(fd);

	return 0;
}

--St7VIuEGZ6dlpu13--
