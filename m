From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: race in skb_splice_bits?
Date: Tue, 27 May 2008 15:53:49 +0300
Message-ID: <200805271553.50001.opurdila@ixiacom.com>
References: <200805270325.24323.opurdila@ixiacom.com> <20080527115206.GA30353@2ka.mipt.ru> <20080527115638.GB30353@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_dRAPIvmSYBf3Uak"
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:3691 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752262AbYE0My7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 08:54:59 -0400
In-Reply-To: <20080527115638.GB30353@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_dRAPIvmSYBf3Uak
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Tuesday 27 May 2008, Evgeniy Polyakov wrote:

> > > However, from Octavian's later mail it seems we can't let the skb go
> > > away at all.  So some wider changes seem to be required.
> >
> > Yes, I misread the original message.
> >
> > Octavian, could you please decode where bug occured via gdb:
> > gdb
> > $ l *(skb_splice_bits+0x130)
>
> It is lock_sock()?
>

Yes it is lock_sock(). The crash in lock_sock() occurs with the following 
sequence:

release_sock(__skb->sk);
ret = splice_to_pipe(pipe, &spd);
lock_sock(__skb->sk);

0x8010c94c is in skb_splice_bits (include/net/sock.h:837).
832
833     extern void lock_sock_nested(struct sock *sk, int subclass);
834
835     static inline void lock_sock(struct sock *sk)
836     {
837             lock_sock_nested(sk, 0);
838     }
839
840     extern void release_sock(struct sock *sk);
841


> And also please show what
> tcp_read_sock+0x108
> tcp_read_sock+0x138
>
> are.

This crash occurs with the following sequence:

struct sock *sk= __skb->sk;

release_sock(sk);
ret = splice_to_pipe(pipe, &spd);
lock_sock(sk);

0x8014d090 is in tcp_read_sock (net/ipv4/tcp.c:1225).
1220                            used = recv_actor(desc, skb, offset, len);
1221                            if (used < 0) {
1222                                    if (!copied)
1223                                            copied = used;
1224                                    break;
1225                            } else if (used <= len) {
1226                                    seq += used;
1227                                    copied += used;
1228                                    offset += used;
1229                            }

> And do you have a test case for that? 

Yes. I've attached my test program which triggers both crashes. To improve the 
reproducibility rate you need to use a relatively high buffer for splice (I 
used 16384) and a small MTU (I used 128). This will make the 1st splice on 
the receive side block (due to not enough PIPE_BUFFERS it seems), and will 
give plenty of time to the race condition to manifest itself. When you 
interrupt the program, the system will crash.

Thanks,
tavi


--Boundary-00=_dRAPIvmSYBf3Uak
Content-Type: text/x-csrc;
  charset="iso-8859-1";
  name="splice.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="splice.c"

#define _GNU_SOURCE
#include <stdlib.h>
#include <string.h>
#include <error.h>
#include <argp.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <sys/epoll.h>
#include <sys/fcntl.h>
#include <sys/wait.h>
#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <net/if.h>
#include <signal.h>
#include <sys/socket.h>
#include <netpacket/packet.h>
#include <net/ethernet.h>     /* the L2 protocols */
#include <assert.h>
#include <netinet/tcp.h>
#include <linux/unistd.h>

#ifdef __PPC__

#undef __syscall_nr
#define __syscall_nr(nr, type, name, args...)                          \
       unsigned long __sc_ret, __sc_err;                               \
       {                                                               \
               register unsigned long __sc_0  __asm__ ("r0");          \
               register unsigned long __sc_3  __asm__ ("r3");          \
               register unsigned long __sc_4  __asm__ ("r4");          \
               register unsigned long __sc_5  __asm__ ("r5");          \
               register unsigned long __sc_6  __asm__ ("r6");          \
               register unsigned long __sc_7  __asm__ ("r7");          \
               register unsigned long __sc_8  __asm__ ("r8");          \
                                                                       \
               __sc_loadargs_##nr(name, args);                         \
               __asm__ __volatile__                                    \
                       ("sc           \n\t"                            \
                        "mfcr %0      "                                \
                       : "=&r" (__sc_0),                               \
                         "=&r" (__sc_3),  "=&r" (__sc_4),              \
                         "=&r" (__sc_5),  "=&r" (__sc_6),              \
                         "=&r" (__sc_7),  "=&r" (__sc_8)               \
                       : __sc_asm_input_##nr                           \
                       : "cr0", "ctr", "memory",                       \
                         "r9", "r10","r11", "r12");                    \
               __sc_ret = __sc_3;                                      \
               __sc_err = __sc_0;                                      \
       }                                                               \
       if (__sc_err & 0x10000000)                                      \
       {                                                               \
               errno = __sc_ret;                                       \
               __sc_ret = -1;                                          \
       }                                                               \
       return (type) __sc_ret

#define __sc_loadargs_6(name, arg1, arg2, arg3, arg4, arg5, arg6)		\
	__sc_loadargs_5(name, arg1, arg2, arg3, arg4, arg5);			\
	__sc_8 = (unsigned long) (arg6)

#define __sc_asm_input_6 __sc_asm_input_5, "6" (__sc_8)

#define _syscall6(type,name,type1,arg1,type2,arg2,type3,arg3,type4,arg4,type5,arg5,type6,arg6) \
type name(type1 arg1, type2 arg2, type3 arg3, type4 arg4, type5 arg5, type6 arg6) \
{                                                                      \
       __syscall_nr(6, type, name, arg1, arg2, arg3, arg4, arg5, arg6); \
}

#define SPLICE_F_MOVE 0x01
#define SPLICE_F_NONBLOCK 0x02
#define SPLICE_F_MORE 0x04
#define SPLICE_F_GIFT 0x08
#define __NR_splice 283
_syscall6(int, splice, int, fd_in, loff_t*, off_in, int, fd_out, loff_t*, off_out, size_t, len, unsigned int, flags);
#endif

/* 
 * Command line parser
 */
const char *argp_program_version = "0.1";
const char *argp_program_bug_address = "opurdila@ixiacom.com";
static char doc[] = "";
static char args_doc[] = "";
static struct argp_option options[] = {
    {"interface", 'i', "string", 0, "interface"},
    {"dst", 'd', "string", 0, "dst"},
    {"src", 's', "string", 0, "src"},
    {"port", 'p', "string", 0, "port"},
    {"socket-buffer", 'S', "string", 0, "packet size"},
    {"interval", 'I', "int", 0, "interval between packet send operations"},
    {"count", 'c', "int", 0, "counter"},
    {0},
};

typedef struct {
	int size, ifindex, interval, count, port, so_size;
	struct sockaddr_in src, dst;
	const char *ifname;
} cl_args_t;

cl_args_t cla;

static error_t parse_opt(int key, char *arg, struct argp_state *state)
{
	cl_args_t *cla = state->input;
	switch (key) {
	case 'p':
	{
		cla->port=strtol(arg, NULL, 0);
		break;
	}
	case 'c':
	{
		cla->count=strtol(arg, NULL, 0);
		break;
	}
	case 'I':
	{
		cla->interval=strtol(arg, NULL, 0);
		break;
	}
	case 'S':
	{
		cla->so_size=strtol(arg, NULL, 0);
		break;
	}
	case 'd':
	{
		cla->dst.sin_family=AF_INET;
		if (inet_pton(AF_INET, arg, &cla->dst.sin_addr) < 0) {
			printf("bad address: %s\n", arg);
			return -1;
		}
		break;
	}
	case 's':
	{
		cla->src.sin_family=AF_INET;
		if (inet_pton(AF_INET, arg, &cla->src.sin_addr) < 0) {
			printf("bad address: %s\n", arg);
			return -1;
		}
		break;
	}
	case 'i':
	{
		cla->ifindex=if_nametoindex(arg);
		if (cla->ifindex == 0) {
			printf("invalid interface: %s\n", arg);
			return -1;
		}
		cla->ifname=arg;
		break;
	}
	case ARGP_KEY_ARG:
		break;
	default:
		return ARGP_ERR_UNKNOWN;
	}
	return 0;
}

int prepare_socket(void)
{
	int s=socket(PF_INET, SOCK_STREAM, 0);

	if (s < 0) {
		printf("failed to create socket: %s\n", strerror(errno));
		return -1;
	}
	
	if ((cla.src.sin_addr.s_addr || cla.src.sin_port)
	     && bind(s, (const struct sockaddr*)&cla.src, sizeof(cla.src)) < 0) {
		printf("failed to bind socket: %s\n", strerror(errno));
		return -1;
	}
	
	if (cla.ifname) {
		struct ifreq ifr;
		strcpy((char *)&ifr.ifr_name, cla.ifname);
		if (setsockopt(s, SOL_SOCKET, SO_BINDTODEVICE, &ifr, sizeof (ifr)) < 0) {
			printf("failed to bind to interface %s: %s\n", cla.ifname, strerror(errno));
			return -1;
		}
        }

	return s;
}

int do_server(int s)
{
	int error, s2;
	int pipefd[2];
    
	if (pipe(pipefd) < 0) {
	    perror("pipe error:");
	    return -1;
	}
	
	if (listen(s, 1) < 0) {
	    perror("listen error:");
	    return -1;
	}

	if ((s2=accept(s, NULL, NULL)) < 0) {
	    perror("accept error:");
	    return -1;
	}
	
	/* 6% improvement by _lowering_ the buffer size :O */
	if (cla.so_size && setsockopt(s2, SOL_SOCKET, SO_RCVBUF, &cla.so_size, sizeof cla.so_size) < 0) {
		perror("SO_RCVBUF");
	}

	while (1) {
		error=splice(s2, NULL, pipefd[1], NULL, 4*4096, SPLICE_F_MOVE);
		if (error <= 0) {
			perror("in splice");
			return -1;
		} 
		error=splice(pipefd[0], NULL, STDOUT_FILENO, NULL, error, SPLICE_F_MOVE);
		if (error <= 0) {
			perror("out splice");
			return -1;
		} 
	}
	return -1;
}

int do_client(int s)
{
	int error;
	int pipefd[2], fd=STDIN_FILENO;
	loff_t off=0;
    
	if (pipe(pipefd) < 0) {
	    perror("pipe error:");
	    return -1;
	}
	
	if (connect(s, (struct sockaddr*)&cla.dst, sizeof(cla.dst)) < 0) {
	    perror("connect error:");
	    return -1;
	}
	
	if (cla.so_size && setsockopt(s, SOL_SOCKET, SO_SNDBUF, &cla.so_size, sizeof cla.so_size) < 0) {
		perror("SO_RCVBUF");
	}

	while(1) {
		off=0;
		error=splice(fd, &off, pipefd[1], NULL, 4*4096, SPLICE_F_MOVE);
		if (error <= 0) {
			perror("in splice");
			return -1;
		} 
		error=splice(pipefd[0], NULL, s, NULL, error, SPLICE_F_MOVE);
		if (error <= 0) {
			perror("out splice");
			return -1;
		}
	}
	close(s);
	return -1;
}


static struct argp argp = { options, parse_opt, args_doc, doc };
int main(int argc, char **argv)
{
	int s;

	if (argp_parse(&argp, argc, argv, 0, 0, &cla) < 0)
		return -1;

	if (cla.dst.sin_addr.s_addr)
		cla.dst.sin_port=htons(cla.port);
	else
		cla.src.sin_port=htons(cla.port);

	if ((s=prepare_socket()) < 0)
		return -1;

	if (cla.dst.sin_addr.s_addr)
		return do_client(s);
	else
		return do_server(s);
}

--Boundary-00=_dRAPIvmSYBf3Uak--
