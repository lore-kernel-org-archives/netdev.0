From: Martin Pool <mbp@samba.org>
Subject: FIN_WAIT1 / TCP_CORK / 2.2 -- reproducible bug and test case
Date: Wed, 18 Sep 2002 12:03:49 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020918020346.GA2285@samba.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="yrj/dFKFPuw6o+aM"
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, ak@muc.de, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
   Alan.Cox@linux.org
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--yrj/dFKFPuw6o+aM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

(Sorry for spamming people directly; my list message didn't get a
reply and it's a serious bug in some circumstances.)

I've discovered a bug in Linux 2.2 that allows TCP sockets to get
stuck in FIN_WAIT1 with no timeout or retransmissions.  Code to
demonstrate the problem, plus  a tcpdump of it happening, is
attached.  There are more details about what's going on, as I
understand it, in the headers.

I suspect there is a mishandling of sk->nonagle==2 in tcp_send_test(),
but I have not yet puzzled out the code enough to say exactly what it
is.  I think basically the handling of a closing socket that still has
corks set is broken.

You might argue that this is a security bug because it allows local
users to consume arbitrarily large (?)  kernel resources, and in some
cases the resources cannot be released without a reboot.  (Or perhaps
a spoofed RST packet would fix it too.)

-- 
Martin 



--yrj/dFKFPuw6o+aM
Content-Type: text/x-csrc; charset=us-ascii
Content-Disposition: attachment; filename="corked_demo.c"

/* -*- c-file-style: "java"; indent-tabs-mode: nil -*-
 *
 * corked_demo.c -- Demonstrate Linux 2.2 bug relating to TCP_CORKED sockets.
 *
 * Written 2002 by Martin Pool <mbp@sourcefrog.net>
 *
 * Build this, run it as root with something like "sudo ./corked_demo
 * SOMEHOST 9" to write to the discard port.  (It needs root access to
 * set SO_DEBUG.)  The other machine must be running the discard
 * service to accept the connection and data.
 *
 * Basically all it does is open a corked connection, and then drop it
 * while there is (possibly) data in the SendQ.  The socket gets
 * "stuck" in FIN_WAIT1 and doesn't seem to be able to flush the last
 * bit of data.
 *
 * If you have an affected version of the kernel, most times this is
 * run run you will get a socket stuck in FIN_WAIT1 state.  It looks
 * like this:
 *
 * tcp        0   3201 maudlin:1048            maudlin:discard         FIN_WAIT1   root       0          -                   off (0.00/0/0)
 *
 * This happens in 2.2.16, .18, and .21.
 *
 * It seems to me that this *has* to be incorrect, because there is
 * data waiting to go out, but no timer running.  The socket stays
 * stuck, chewing up kernel memory forever.
 *
 * Running a hundred iterations gives 36 stuck in this state.
 *
 * On the server the situation is almost as bad: the sockets end up in
 * ESTABLISHED state, but they'll never recieve more data.  Presumably
 * they'll hang around until the server gives up and terminates, or
 * until the TCP 2-hour timeout elapses.  
 *
 * Sometimes killing off the server makes the FIN_WAIT1 sockets go
 * away on the client, but it is not reliable.  However, neither side
 * seems to time out of its own accord -- I left the two machines
 * sitting overnight and all the sockets were still
 * FIN_WAIT1/ESTABLISHED in the morning.
 *
 * tcpdump shows that the FIN is not sent when the client program
 * closes the socket.  However, when the server program is killed, its
 * FIN gets things flowing again.
 *
 * I think that on the system where this was originally seen, both the
 * client and the server used corks, and so killing the server program
 * and closing its socket didn't send a FIN, and therefore things
 * stayed jammed indefinitely.
 *
 * Since this can be provoked with local unprivileged access, and
 * since the sockets apparently can't be cleared up without a reboot,
 * it could be considered a kind of resource exhaustion attack.  If it
 * happens inadvertently, it can cause problems on the server by
 * causing the remote machine to hang until it is killed off. */


#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <assert.h>
#include <string.h>
#include <fcntl.h>
#include <errno.h>
#include <signal.h>

#include <sys/stat.h>
#include <sys/types.h>
#include <sys/socket.h>

#include <netinet/in.h>
#include <netinet/tcp.h>

#include <netdb.h>


/**
 * Open a socket to a tcp remote host with the specified port.
 *
 * The socket is (if appropriate) corked on return, so that the third
 * handshake should be sent containing useful data.
 *
 * Stolen from rsync via distcc.
 *
 * @todo Don't try for too long to connect. 
 **/
int open_socket_out(const char *host, int port, int *p_fd)
{
    int type = SOCK_STREAM;
    struct sockaddr_in sock_out;
    int fd;
    struct hostent *hp;

    fd = socket(PF_INET, type, 0);
    if (fd == -1) {
	printf("failed to create socket: %s\n", strerror(errno));
	exit(1);
    }

    hp = gethostbyname(host);
    if (!hp) {
	fprintf(stderr, "unknown host: \"%s\"\n", host);
	(void) close(fd);
	exit(1);
    }

    memcpy(&sock_out.sin_addr, hp->h_addr, (size_t) hp->h_length);
    sock_out.sin_port = htons(port);
    sock_out.sin_family = PF_INET;

    if (connect(fd, (struct sockaddr *) &sock_out, (int) sizeof(sock_out))) {
        fprintf(stderr, "failed to connect to %s port %d: %s\n", host, port, 
                     strerror(errno));
	(void) close(fd);
	exit(1);
    }

    printf("client got connection to %s port %d on fd%d\n", host, port, fd);

    *p_fd = fd;
    return 0;
}


/**
 * Stick a TCP cork in the socket.  
 **/
int tcp_cork_sock(int fd, int corked)
{
    if (setsockopt(fd, SOL_TCP, TCP_CORK, &corked, sizeof corked) == -1) {
        fprintf(stderr, "setsockopt(corked=%d) failed: %s\n",
                corked, strerror(errno));
        exit(1);
    }

    printf("%scorked fd%d\n", corked ? "" : "un", fd);

    return 0;
}



int debug_sock(int fd, int debug_on)
{
    if (setsockopt(fd, SOL_SOCKET, SO_DEBUG, &debug_on, sizeof debug_on) == -1) {
        fprintf(stderr, "setsockopt(debug=%d) failed: %s\n",
                debug_on, strerror(errno));
        exit(1);
    }

    printf("%sdebug fd%d\n", debug_on ? "" : "un", fd);

    return 0;
}



int dcc_writex(int fd, const void *buf, size_t len)
{
    ssize_t r;
    
    while (len > 0) {
        r = write(fd, buf, len);
        if (r == -1) {
            fprintf(stderr, "failed to write: %s\n", strerror(errno));
            return -1;
        } else if (r == 0) {
            fprintf(stderr, "unexpected eof on fd%d\n", fd);
            return -1;
        } else {
            buf = &((char *) buf)[r];
            len -= r;
        }
    }

    return 0;
}


int send_junk(int fd)
{
    static char trash[100000];

    return dcc_writex(fd, trash, sizeof trash);
}



int main(int argc, char **argv)
{
    int fd;

    if (argc != 3) {
        fprintf(stderr, "usage: corked_demo HOST NUMERICPORT\n");
        return 1;
    }
    
    open_socket_out(argv[1], atoi(argv[2]), &fd);

    debug_sock(fd, 1);
    tcp_cork_sock(fd, 1);

    send_junk(fd);

    return 0;
}

--yrj/dFKFPuw6o+aM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="corked_tcpdump.txt"

tcpdump: listening on eth0
04:39:25.336746 maudlin.ozlabs.hp.com.1884 > nevada.aus.hp.com.discard: S 2229455302:2229455302(0) win 16060 <mss 1460,sackOK,timestamp 5592391[|tcp]> (DF)
04:39:25.336913 nevada.aus.hp.com.discard > maudlin.ozlabs.hp.com.1884: S 3652179257:3652179257(0) ack 2229455303 win 5792 <mss 1460,sackOK,timestamp 352437103[|tcp]> (DF)
04:39:25.337134 maudlin.ozlabs.hp.com.1884 > nevada.aus.hp.com.discard: . ack 1 win 16060 <nop,nop,timestamp 5592391 352437103> (DF)
04:39:25.343813 maudlin.ozlabs.hp.com.1884 > nevada.aus.hp.com.discard: P 1:1449(1448) ack 1 win 16060 <nop,nop,timestamp 5592392 352437103> (DF)
04:39:25.344057 maudlin.ozlabs.hp.com.1884 > nevada.aus.hp.com.discard: P 1449:2897(1448) ack 1 win 16060 <nop,nop,timestamp 5592392 352437103> (DF)
04:39:25.344012 nevada.aus.hp.com.discard > maudlin.ozlabs.hp.com.1884: . ack 1449 win 8688 <nop,nop,timestamp 352437103 5592392> (DF)
04:39:25.344160 nevada.aus.hp.com.discard > maudlin.ozlabs.hp.com.1884: . ack 2897 win 11584 <nop,nop,timestamp 352437103 5592392> (DF)
04:39:25.344657 maudlin.ozlabs.hp.com.1884 > nevada.aus.hp.com.discard: . 2897:4345(1448) ack 1 win 16060 <nop,nop,timestamp 5592392 352437103> (DF)
04:39:25.345093 maudlin.ozlabs.hp.com.1884 > nevada.aus.hp.com.discard: . 4345:5793(1448) ack 1 win 16060 <nop,nop,timestamp 5592392 352437103> (DF)
04:39:25.345299 maudlin.ozlabs.hp.com.1884 > nevada.aus.hp.com.discard: . 5793:7241(1448) ack 1 win 16060 <nop,nop,timestamp 5592392 352437103> (DF)
04:39:25.345407 maudlin.ozlabs.hp.com.1884 > nevada.aus.hp.com.discard: . 7241:8689(1448) ack 1 win 16060 <nop,nop,timestamp 5592392 352437103> (DF)
04:39:25.345059 nevada.aus.hp.com.discard > maudlin.ozlabs.hp.com.1884: . ack 4345 win 14480 <nop,nop,timestamp 352437103 5592392> (DF)
04:39:25.345210 nevada.aus.hp.com.discard > maudlin.ozlabs.hp.com.1884: . ack 5793 win 17376 <nop,nop,timestamp 352437104 5592392> (DF)
04:39:25.345389 nevada.aus.hp.com.discard > maudlin.ozlabs.hp.com.1884: . ack 7241 win 20272 <nop,nop,timestamp 352437104 5592392> (DF)
04:39:25.345499 nevada.aus.hp.com.discard > maudlin.ozlabs.hp.com.1884: . ack 8689 win 23168 <nop,nop,timestamp 352437104 5592392> (DF)
04:39:25.345686 maudlin.ozlabs.hp.com.1884 > nevada.aus.hp.com.discard: . 8689:10137(1448) ack 1 win 16060 <nop,nop,timestamp 5592392 352437103> (DF)
04:39:25.345880 maudlin.ozlabs.hp.com.1884 > nevada.aus.hp.com.discard: . 10137:11585(1448) ack 1 win 16060 <nop,nop,timestamp 5592392 352437103> (DF)
04:39:25.346046 maudlin.ozlabs.hp.com.1884 > nevada.aus.hp.com.discard: . 11585:13033(1448) ack 1 win 16060 <nop,nop,timestamp 5592392 352437104> (DF)
04:39:25.346230 maudlin.ozlabs.hp.com.1884 > nevada.aus.hp.com.discard: . 13033:14481(1448) ack 1 win 16060 <nop,nop,timestamp 5592392 352437104> (DF)
04:39:25.346424 maudlin.ozlabs.hp.com.1884 > nevada.aus.hp.com.discard: . 14481:15929(1448) ack 1 win 16060 <nop,nop,timestamp 5592392 352437104> (DF)
04:39:25.346534 maudlin.ozlabs.hp.com.1884 > nevada.aus.hp.com.discard: . 15929:17377(1448) ack 1 win 16060 <nop,nop,timestamp 5592392 352437104> (DF)
04:39:25.346651 maudlin.ozlabs.hp.com.1884 > nevada.aus.hp.com.discard: . 17377:18825(1448) ack 1 win 16060 <nop,nop,timestamp 5592392 352437104> (DF)
04:39:25.346759 maudlin.ozlabs.hp.com.1884 > nevada.aus.hp.com.discard: . 18825:20273(1448) ack 1 win 16060 <nop,nop,timestamp 5592392 352437104> (DF)
04:39:25.345806 nevada.aus.hp.com.discard > maudlin.ozlabs.hp.com.1884: . ack 10137 win 26064 <nop,nop,timestamp 352437104 5592392> (DF)
04:39:25.345970 nevada.aus.hp.com.discard > maudlin.ozlabs.hp.com.1884: . ack 11585 win 28960 <nop,nop,timestamp 352437104 5592392> (DF)
04:39:25.346208 nevada.aus.hp.com.discard > maudlin.ozlabs.hp.com.1884: . ack 13033 win 31856 <nop,nop,timestamp 352437104 5592392> (DF)
04:39:25.346323 nevada.aus.hp.com.discard > maudlin.ozlabs.hp.com.1884: . ack 14481 win 34752 <nop,nop,timestamp 352437104 5592392> (DF)
04:39:25.346516 nevada.aus.hp.com.discard > maudlin.ozlabs.hp.com.1884: . ack 15929 win 37648 <nop,nop,timestamp 352437104 5592392> (DF)
04:39:25.346624 nevada.aus.hp.com.discard > maudlin.ozlabs.hp.com.1884: . ack 17377 win 40544 <nop,nop,timestamp 352437104 5592392> (DF)
04:39:25.346742 nevada.aus.hp.com.discard > maudlin.ozlabs.hp.com.1884: . ack 18825 win 43440 <nop,nop,timestamp 352437104 5592392> (DF)
04:39:25.346849 nevada.aus.hp.com.discard > maudlin.ozlabs.hp.com.1884: . ack 20273 win 46336 <nop,nop,timestamp 352437104 5592392> (DF)
04:39:25.347261 nevada.aus.hp.com.discard > maudlin.ozlabs.hp.com.1884: . ack 21721 win 49232 <nop,nop,timestamp 352437104 5592392> (DF)


(now, kill the server)

04:39:43.795571 nevada.aus.hp.com.discard > maudlin.ozlabs.hp.com.1884: F 1:1(0) ack 99913 win 63712 <nop,nop,timestamp 352438965 5592393> (DF)
04:39:43.795643 maudlin.ozlabs.hp.com.1884 > nevada.aus.hp.com.discard: . ack 2 win 16060 <nop,nop,timestamp 5594236 352438965> (DF)
04:39:43.795801 maudlin.ozlabs.hp.com.1884 > nevada.aus.hp.com.discard: FP 99913:100001(88) ack 2 win 16060 <nop,nop,timestamp 5594236 352438965> (DF)
04:39:43.795890 nevada.aus.hp.com.discard > maudlin.ozlabs.hp.com.1884: R 3652179259:3652179259(0) win 0 (DF)

36 packets received by filter
0 packets dropped by kernel

--yrj/dFKFPuw6o+aM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=corked-out-20020917-2009

ev: 1.0 
  Type:   Direct-Access                      ANSI SCSI revision: 02
Detected scsi disk sda at scsi0, channel 0, id 0, lun 0
scsi0: Target 0: Queue Depth 28, Asynchronous
scsi : detected 1 SCSI disk total.
SCSI device sda: hdwr sector= 512 bytes. Sectors= 2097152 [1024 MB] [1.0 GB]
pcnet32.c: PCI bios is present, checking for devices...
PCI Master Bit has not been set. Setting...
Found PCnet/PCI at 0x10a0, irq 10.
eth0: PCnet/PCI II 79C970A at 0x10a0, 00 50 56 40 00 52 assigned IRQ 10.
pcnet32.c:v1.25kf 26.9.1999 tsbogend@alpha.franken.de
Partition check:
 sda: sda1 sda2 < sda5 >
IA-32 Microcode Update Driver: v1.08 <tigran@veritas.com>
VFS: Mounted root (ext2 filesystem) readonly.
Freeing unused kernel memory: 60k freed
scsi0: Tagged Queuing now active for Target 0
Adding Swap: 268264k swap-space (priority -1)
tcp_snd_test sk=c7977740, skb=c7a72ac0, tail=1
tcp_snd_test skb->flags=0x18, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 1
tcp_snd_test sk=c7977740, skb=c7a87a40, tail=1
tcp_snd_test skb->flags=0x18, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 1
tcp_snd_test sk=c7977740, skb=c7a877c0, tail=1
tcp_snd_test skb->flags=0x18, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 0
tcp_snd_test sk=c7977740, skb=c7a877c0, tail=0
tcp_snd_test skb->flags=0x18, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 0
tcp_snd_test sk=c7977740, skb=c7a877c0, tail=0
tcp_snd_test skb->flags=0x18, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 1
tcp_snd_test sk=c7977740, skb=c7a87680, tail=0
tcp_snd_test skb->flags=0x18, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 1
tcp_snd_test sk=c7977740, skb=c7a875e0, tail=0
tcp_snd_test skb->flags=0x18, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 0
tcp_snd_test sk=c7977740, skb=c7a875e0, tail=0
tcp_snd_test skb->flags=0x18, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 1
tcp_snd_test sk=c7977740, skb=c7a87540, tail=0
tcp_snd_test skb->flags=0x18, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 0
tcp_snd_test sk=c7977740, skb=c7a87540, tail=0
tcp_snd_test skb->flags=0x18, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 0
tcp_snd_test sk=c7977740, skb=c7a87540, tail=0
tcp_snd_test skb->flags=0x18, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 1
tcp_snd_test sk=c7977740, skb=c7a874a0, tail=0
tcp_snd_test skb->flags=0x18, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 0
tcp_snd_test sk=c7977740, skb=c7a874a0, tail=0
tcp_snd_test skb->flags=0x18, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 0
tcp_snd_test sk=c7977740, skb=c7a874a0, tail=0
tcp_snd_test skb->flags=0x18, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 1
tcp_snd_test sk=c7977740, skb=c7a87400, tail=0
tcp_snd_test skb->flags=0x18, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 0
tcp_snd_test sk=c7977740, skb=c7a87400, tail=0
tcp_snd_test skb->flags=0x18, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 0
tcp_snd_test sk=c7977740, skb=c7a87400, tail=0
tcp_snd_test skb->flags=0x18, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 1
tcp_snd_test sk=c7977740, skb=c7a87180, tail=0
tcp_snd_test skb->flags=0x18, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 0
tcp_snd_test sk=c7977740, skb=c7a87180, tail=0
tcp_snd_test skb->flags=0x18, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 1
tcp_snd_test sk=c7977740, skb=c7a87900, tail=0
tcp_snd_test skb->flags=0x10, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 0
tcp_snd_test sk=c7977740, skb=c7a87900, tail=0
tcp_snd_test skb->flags=0x10, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 1
tcp_snd_test sk=c7977740, skb=c7a870e0, tail=0
tcp_snd_test skb->flags=0x10, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 0
tcp_snd_test sk=c7977740, skb=c7a870e0, tail=0
tcp_snd_test skb->flags=0x10, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 1
tcp_snd_test sk=c7977740, skb=c7a87720, tail=0
tcp_snd_test skb->flags=0x10, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 0
tcp_snd_test sk=c7977740, skb=c7a87720, tail=0
tcp_snd_test skb->flags=0x10, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 1
tcp_snd_test sk=c7977740, skb=c7a87360, tail=0
tcp_snd_test skb->flags=0x10, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 0
tcp_snd_test sk=c7977740, skb=c7a87360, tail=0
tcp_snd_test skb->flags=0x10, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 1
tcp_snd_test sk=c7977740, skb=c7a877c0, tail=0
tcp_snd_test skb->flags=0x10, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 0
tcp_snd_test sk=c7977740, skb=c7a877c0, tail=0
tcp_snd_test skb->flags=0x10, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 1
tcp_snd_test sk=c7977740, skb=c7a875e0, tail=1
tcp_snd_test skb->flags=0x10, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 0
tcp_snd_test sk=c7977740, skb=c7a875e0, tail=1
tcp_snd_test skb->flags=0x10, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 1
tcp_snd_test sk=c7977740, skb=c7a72ac0, tail=1
tcp_snd_test skb->flags=0x18, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 1
tcp_snd_test sk=c7977740, skb=c7a87360, tail=1
tcp_snd_test skb->flags=0x18, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 1
tcp_snd_test sk=c7977740, skb=c7a870e0, tail=1
tcp_snd_test skb->flags=0x10, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 1
tcp_snd_test sk=c7977740, skb=c7a875e0, tail=1
tcp_snd_test skb->flags=0x10, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 1
tcp_snd_test sk=c7977740, skb=c7a87860, tail=1
tcp_snd_test skb->flags=0x10, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 0
tcp_snd_test sk=c7977740, skb=c7a87860, tail=0
tcp_snd_test skb->flags=0x10, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 0
tcp_snd_test sk=c7977740, skb=c7a87860, tail=0
tcp_snd_test skb->flags=0x10, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 1
tcp_snd_test sk=c7977740, skb=c7a872c0, tail=0
tcp_snd_test skb->flags=0x10, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 0
tcp_snd_test sk=c7977740, skb=c7a872c0, tail=0
tcp_snd_test skb->flags=0x10, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 1
tcp_snd_test sk=c7977740, skb=c7a87220, tail=0
tcp_snd_test skb->flags=0x10, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 0
tcp_snd_test sk=c7977740, skb=c7a87220, tail=0
tcp_snd_test skb->flags=0x10, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 0
tcp_snd_test sk=c7977740, skb=c7a87220, tail=0
tcp_snd_test skb->flags=0x10, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 1
tcp_snd_test sk=c7977740, skb=c7a87e00, tail=0
tcp_snd_test skb->flags=0x10, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 0
tcp_snd_test sk=c7977740, skb=c7a87e00, tail=0
tcp_snd_test skb->flags=0x10, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 1
tcp_snd_test sk=c7977740, skb=c7a87540, tail=0
tcp_snd_test skb->flags=0x10, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 0
tcp_snd_test sk=c7977740, skb=c7a87540, tail=0
tcp_snd_test skb->flags=0x10, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 1
tcp_snd_test sk=c7977740, skb=c7a877c0, tail=0
tcp_snd_test skb->flags=0x10, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 0
tcp_snd_test sk=c7977740, skb=c7a877c0, tail=0
tcp_snd_test skb->flags=0x10, sk->nonagle=2, nagle_check=1
tcp_snd_test returns 1
tcp_snd_test sk=c7977740, skb=c7a87900, tail=1
tcp_snd_test skb->flags=0x18, sk->nonagle=2, nagle_check=0
tcp_snd_test returns 0
tcp_snd_test sk=c7977740, skb=c7a87900, tail=1
tcp_snd_test skb->flags=0x18, sk->nonagle=2, nagle_check=0
tcp_snd_test returns 0
tcp_snd_test sk=c7977740, skb=c7a87900, tail=1
tcp_snd_test skb->flags=0x18, sk->nonagle=2, nagle_check=0
tcp_snd_test returns 0
tcp_snd_test sk=c7977740, skb=c7a87900, tail=1
tcp_snd_test skb->flags=0x18, sk->nonagle=2, nagle_check=0
tcp_snd_test returns 0

--yrj/dFKFPuw6o+aM--
