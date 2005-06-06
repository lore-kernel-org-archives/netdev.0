From: Hans Henrik Happe <hhh@imada.sdu.dk>
Subject: PROBLEM: High TCP latency
Date: Mon, 6 Jun 2005 11:35:09 +0200
Message-ID: <200506061135.09869.hhh@imada.sdu.dk>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_NjBpCAIVJaMD5eg"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--Boundary-00=_NjBpCAIVJaMD5eg
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Short: TCP puts the system into the idle state even though there are data in
transit.

During coding a distributed application I discovered a TCP latency issue. The 
application does a lot of request forwarding like P2P protocols.

I have tried to track down the problem and have written a small program 
(random-tcp.c) that shows the long latencies. In this program one message is 
passed round between a number om processes. Each time a process receives the 
message it randomly chooses a process to forward to next. 

This I have compared to a program that doesn't give long latencies 
(ring-tcp.c). In this program each process always forwards to the same 
process (ring topology).

I have also made the same programs using SCTP and this protocol has no issue 
in the random case.

The following is a test with 16 processes forwarding the message 100000 times. 
The avg. forwarding time from process to process is messured.

$ ./random-tcp 16 100000
avg forwarding time: 0.000326

$ ./ring-tcp 16 100000
avg forwarding time: 0.000044

$ ./random-sctp 16 100000
avg forwarding time: 0.000068

$ ./ring-sctp 16 100000
avg forwarding time: 0.000067

Using 'top' i have observed that the system spends time in the idle state when 
running 'random-tcp'. This I have observed with just 3 processes. With 16 
processes the CPU is only 20% loaded on my Mobile Intel(R) Celeron(R) CPU 
1.60GHz.

I have also tried with socketpair()'s which didn't have the problem. Therefore 
my conclusion is that it must be a TCP issue.

Now this local use of TCP is not that usefull. Therefore, I tried a MPI 
version and tested this in a 16 node cluster. Here the random case is 5 times 
slower than the ring.

I have tested on many kernel versions from 2.4.25 up until 2.6.12-rc5 and all 
had this issue.

A few people on lkml also confirmed it, but I have not got any reply from 
someone with a greater knowledge of the inner working of Linux TCP (at least 
they didn't tell me that they had this knowledge :-).

I hope this is helpfull.

Regards
Hans Henrik Happe

--Boundary-00=_NjBpCAIVJaMD5eg
Content-Type: text/x-csrc;
  charset="us-ascii";
  name="random-sctp.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="random-sctp.c"

/* By Hans Henrik Happe
 *
 * compile: gcc -o random-sctp random-sctp.c -lsctp
 *
 * usage: random-sctp <# processes> <# forwards>
 */

#include <asm/msr.h>

#include <stdio.h>
#include <poll.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/tcp.h>
#include <fcntl.h>
#include <netdb.h>

#include <netinet/sctp.h>
#include <sys/time.h>


double second() {


  struct timeval tv;
  struct timezone tz;
  double t;

  gettimeofday(&tv,&tz);

  t= (double)(tv.tv_sec)+(double)(tv.tv_usec/1.0e6);

  return t;
}

typedef struct {
    struct sockaddr sockadr;
    int len;    
} adr_t;

int get_adr(adr_t *adr, int port) {
   int n;
   struct addrinfo hints, *res;
   char str[6];
    
   memset(&hints, 0, sizeof(struct addrinfo));
    
   hints.ai_flags    = AI_PASSIVE;
   hints.ai_family   = PF_UNSPEC;
   hints.ai_socktype = SOCK_STREAM;

   sprintf(str, "%d", port);
   n = getaddrinfo("localhost", str, &hints, &res);

   if (n != 0) {
       fprintf(stderr,
               "getaddrinfo error: [%s]\n",
               gai_strerror(n));
       return -1;    
   }
   
   memcpy(&adr->sockadr, res->ai_addr, sizeof(*res->ai_addr));
   adr->len = sizeof(*res->ai_addr);
      
   freeaddrinfo(res);

   return 0;
}

int init_listen(int port) {
    int n, on=1;
    int sock;    
    struct sockaddr_in name;
   
        
    sock = socket(PF_INET, SOCK_SEQPACKET, IPPROTO_SCTP);
    if (sock == -1) {
        perror("socket");
        return -1;
    }
    
    name.sin_family = PF_INET;
    name.sin_port = htons (port);
    name.sin_addr.s_addr = htonl (INADDR_ANY);
    
    if (bind (sock, (struct sockaddr *) &name, sizeof (name)) == -1) {
        perror("bind");
        return -1;
    }      
    
    if (listen(sock, 10) == -1) {
        perror("listen");
        return -1;
    }

    return sock;  
}

int do_recv(int sock, void *buf, int n) {
    struct sockaddr sa;
    struct sctp_sndrcvinfo info;
    int slen, flags, res;
    slen = sizeof(sa);
    
    res = sctp_recvmsg(sock, buf, n, &sa, &slen, &info, &flags);
    if (res == -1) {
        perror("recv");    
    }
    if (res != n) {
        fprintf(stderr, "recv incomplete\n");    
    }
    return res;
}

int do_send(int sock, adr_t *adr, void *buf, int n) {
    int res;
    
    res = sctp_sendmsg(sock, buf, n, &adr->sockadr, adr->len, 666, MSG_ADDR_OVER, 0, 0, 444);
    if (res == -1) {
        perror("send");    
    }
    if (res != n) {
        fprintf(stderr, "send incomplete\n");    
    }
    return res;
}


int main(int argc, char *argv[]) {
    int i, cnt, pid, src, dest, its;
    int lsock;
    char id, rank, data;
    int port = 11100;
    double t0, t1;
        
    /* # processes */
    cnt = atoi(argv[1]);
    
    /* # forwards */
    its = atoi(argv[2]);

    {
        adr_t dests[cnt];
           
        /* Create processes */
        rank = 0;
        for (i=1; i<cnt; i++) {
            pid = fork();
            if (pid == 0) {
                rank=cnt-i;
                break;    
            }
        }

        /* Listen */
        lsock = init_listen(port+rank);

        
        sleep(2); /* "Ensure" that all processes are listening, HACK!!! */
                
        
        for (i=0; i<cnt; i++) {
            get_adr(dests+i, port+i);
        }
                
                
        srandom(666);        
        src = 0;
        dest = 1;
        
        /* Send startup message */
        if (rank == src) {
            do_send(lsock, &dests[dest], &data, 1);
        }
        
        
        /* Receive message and forward to a random destination */
        
        t0 = second();
        for (i=0; i < its; i++) {
                    
            if (rank == dest) {
                do_recv(lsock, &data, 1);
            }

            src = dest;                    
                    
            dest = random()%cnt;
                    
            /* Do not send to self */           
            if (dest == src) {
                dest = (dest+1)%cnt;    
            }
                    
            if (src == rank) {                   
                do_send(lsock, &dests[dest], &data, 1);
            }
        }
        
        if (rank == 0) {
            for (i=1; i<cnt; i++) {
                wait(&dest);    
            }
            t1 = second();
            printf("avg forwarding time: %lf\n", ((t1-t0)/its));
        }
    }    
    
    return 0;
}

--Boundary-00=_NjBpCAIVJaMD5eg
Content-Type: text/x-csrc;
  charset="us-ascii";
  name="random-tcp.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="random-tcp.c"

/* By Hans Henrik Happe
 * 
 * usage: random-tcp <# processes> <# forwards>
 */

#include <asm/msr.h>

#include <stdio.h>
#include <poll.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/tcp.h>
#include <fcntl.h>
#include <netdb.h>
#include <sys/time.h>
#include <sys/wait.h>

double second() {

  struct timeval tv;
  struct timezone tz;
  double t;

  gettimeofday(&tv,&tz);

  t= (double)(tv.tv_sec)+(double)(tv.tv_usec/1.0e6);

  return t;
}


int do_connect(int port) {
   int n, sock, on=1;
   struct addrinfo hints, *res;
   char str[6];
   void *adr;
    
   memset(&hints, 0, sizeof(struct addrinfo));
    
   hints.ai_flags    = AI_PASSIVE;
   hints.ai_family   = PF_UNSPEC;
   hints.ai_socktype = SOCK_STREAM;

   sprintf(str, "%d", port);
   n = getaddrinfo("localhost", str, &hints, &res);

   if (n != 0) {
       fprintf(stderr,
               "getaddrinfo error: [%s]\n",
               gai_strerror(n));
       return -1;    
   }
   
   sock = socket(AF_INET, SOCK_STREAM, 0);
   if (sock == -1) {
       perror("socket");
       return -1;
   }

    
   if (setsockopt(sock, SOL_TCP, TCP_NODELAY, &on, sizeof(on)) == -1) {
       perror("setsockopt");
       return -1;
   }
   
   if (connect(sock, (struct sockaddr *)res->ai_addr, sizeof(*res->ai_addr)) == -1) {
       perror("connect");
       return -1;
   }
   
   freeaddrinfo(res);

   return sock;
}

int start_listen(int port) {
    int n, on=1;
    int sock;    
    struct sockaddr_in name;
   
        
    sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock == -1) {
        perror("socket");
        return -1;
    }

    if (setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on)) == -1) {
        perror("setsockopt");
        return -1;
    }
        
    name.sin_family = AF_INET;
    name.sin_port = htons (port);
    name.sin_addr.s_addr = htonl (INADDR_ANY);
    
    if (bind (sock, (struct sockaddr *) &name, sizeof (name)) == -1) {
        perror("bind");
        return -1;
    }      
    
    if (listen(sock, 10) == -1) {
        perror("listen");
        return -1;
    }
    
    return sock;  
}
        
int do_accept(int lsock) {
    struct sockaddr addr;
    socklen_t len = sizeof(addr);
    int sock, on=1;


    if ((sock = accept(lsock, &addr, &len)) == -1) {
        perror("accept");
        return -1;
    }

    if (setsockopt(sock, SOL_TCP, TCP_NODELAY, &on, sizeof(on)) == -1) {
        perror("setsockopt");
        return -1;
    }
        
    return sock;
}

int do_read(int fd, void *buf, int n) {
    int res;
    
    res = read(fd, buf, n);
    if (res == -1) {
        perror("read");    
    }
    if (res != n) {
        fprintf(stderr, "read incomplete\n");    
    }
    
    return res;
}

int do_write(int fd, void *buf, int n) {
    int res;
    
    res = write(fd, buf, n);
    if (res == -1) {
        perror("write");    
    }
    if (res != n) {
        fprintf(stderr, "write incomplete\n");    
    }
    return res;
}


int main(int argc, char *argv[]) {
    int i, cnt, pid, dest, src, its;
    int lsock, sock;
    char id, rank, data;
    int port = 11100;
    double t0, t1;
        
    /* # processes */
    cnt = atoi(argv[1]);
    
    /* # forwards */
    its = atoi(argv[2]);
    
    {
        int socks[cnt];    
           
        /* Create processes */
        rank = 0;
        for (i=1; i<cnt; i++) {
            pid = fork();
            if (pid == 0) {
                rank=i;
                break;    
            }
        }

        /* Listen */
        lsock = start_listen(port+rank);

        
        sleep(2); /* "Ensure" that all processes are listening, HACK!!! */
                
        for (i=0; i<rank; i++) {
            sock = do_accept(lsock);
            
            do_read(sock, &id, 1);
            do_write(sock, &rank, 1);

            socks[id] = sock;
        }
        
        for (i=rank; i<cnt-1; i++) {
            sock = do_connect(port+i+1);
            
            do_write(sock, &rank, 1);
            do_read(sock, &id, 1);
            
            socks[id] = sock;
        }
                
        srandom(666);        
        src = 0;
        dest = 1;
        
        /* Write startup message */
        if (rank == src) {
            do_write(socks[dest], &data, 1);
        }
        
        
        /* Receive message and forward to a random destination */
        
        t0 = second();
        for (i=0; i < its; i++) {
                    
            if (rank == dest) {
                do_read(socks[src], &data, 1);
            }

            src = dest;                    
                    
            dest = random()%cnt;
                    
            /* Do not send to self */           
            if (dest == src) {
                dest = (dest+1)%cnt;    
            }
                    
            if (src == rank) {                   
               do_write(socks[dest], &data, 1);
            }
        }
        
        if (rank == 0) {
            for (i=1; i<cnt; i++) {
                wait(&dest);    
            }
            t1 = second();
            printf("avg forwarding time: %lf\n", ((t1-t0)/its));
        }
    }    
    
    
    return 0;
}

--Boundary-00=_NjBpCAIVJaMD5eg
Content-Type: text/x-csrc;
  charset="us-ascii";
  name="ring-sctp.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="ring-sctp.c"

/* By Hans Henrik Happe
 *
 * compile: gcc -o ring-sctp ring-sctp.c -lsctp
 *
 * usage: ring-sctp <# processes> <# forwards>
 */

#include <asm/msr.h>

#include <stdio.h>
#include <poll.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/tcp.h>
#include <fcntl.h>
#include <netdb.h>

#include <netinet/sctp.h>
#include <sys/time.h>


double second() {


  struct timeval tv;
  struct timezone tz;
  double t;

  gettimeofday(&tv,&tz);

  t= (double)(tv.tv_sec)+(double)(tv.tv_usec/1.0e6);

  return t;
}

typedef struct {
    struct sockaddr sockadr;
    int len;    
} adr_t;

int get_adr(adr_t *adr, int port) {
   int n;
   struct addrinfo hints, *res;
   char str[6];
    
   memset(&hints, 0, sizeof(struct addrinfo));
    
   hints.ai_flags    = AI_PASSIVE;
   hints.ai_family   = PF_UNSPEC;
   hints.ai_socktype = SOCK_STREAM;

   sprintf(str, "%d", port);
   n = getaddrinfo("localhost", str, &hints, &res);

   if (n != 0) {
       fprintf(stderr,
               "getaddrinfo error: [%s]\n",
               gai_strerror(n));
       return -1;    
   }
   
   memcpy(&adr->sockadr, res->ai_addr, sizeof(*res->ai_addr));
   adr->len = sizeof(*res->ai_addr);
      
   freeaddrinfo(res);

   return 0;
}

int init_listen(int port) {
    int n, on=1;
    int sock;    
    struct sockaddr_in name;
   
        
    sock = socket(PF_INET, SOCK_SEQPACKET, IPPROTO_SCTP);
    if (sock == -1) {
        perror("socket");
        return -1;
    }
    
    name.sin_family = PF_INET;
    name.sin_port = htons (port);
    name.sin_addr.s_addr = htonl (INADDR_ANY);
    
    if (bind (sock, (struct sockaddr *) &name, sizeof (name)) == -1) {
        perror("bind");
        return -1;
    }      
    
    if (listen(sock, 10) == -1) {
        perror("listen");
        return -1;
    }

    return sock;  
}

int do_recv(int sock, void *buf, int n) {
    struct sockaddr sa;
    struct sctp_sndrcvinfo info;
    int slen, flags, res;
    slen = sizeof(sa);
    
    res = sctp_recvmsg(sock, buf, n, &sa, &slen, &info, &flags);
    if (res == -1) {
        perror("recv");    
    }
    if (res != n) {
        fprintf(stderr, "recv incomplete\n");    
    }
    return res;
}

int do_send(int sock, adr_t *adr, void *buf, int n) {
    int res;
    
    res = sctp_sendmsg(sock, buf, n, &adr->sockadr, adr->len, 666, MSG_ADDR_OVER, 0, 0, 444);
    if (res == -1) {
        perror("send");    
    }
    if (res != n) {
        fprintf(stderr, "send incomplete\n");    
    }
    return res;
}


int main(int argc, char *argv[]) {
    int i, cnt, pid, src, dest, its;
    int lsock;
    char id, rank, data;
    int port = 11100;
    double t0, t1;
        
    /* # processes */
    cnt = atoi(argv[1]);
    
    /* # forwards */
    its = atoi(argv[2]);

    {
        adr_t dests[cnt];
           
        /* Create processes */
        rank = 0;
        for (i=1; i<cnt; i++) {
            pid = fork();
            if (pid == 0) {
                rank=cnt-i;
                break;    
            }
        }

        /* Listen */
        lsock = init_listen(port+rank);

        
        sleep(2); /* "Ensure" that all processes are listening, HACK!!! */
                
        
        for (i=0; i<cnt; i++) {
            get_adr(dests+i, port+i);
        }
                
                
        srandom(666);        
        src = 0;
        dest = 1;
        
        /* Send startup message */
        if (rank == src) {
            do_send(lsock, &dests[dest], &data, 1);
        }
        
        
        /* Receive message and forward to a random destination */
        
        t0 = second();
        for (i=0; i < its; i++) {
                    
            if (rank == dest) {
                do_recv(lsock, &data, 1);
            }

            src = dest;                    
                    
            dest = (dest+1)%cnt;    
                    
            if (src == rank) {                   
                do_send(lsock, &dests[dest], &data, 1);
            }
        }
        
        if (rank == 0) {
            for (i=1; i<cnt; i++) {
                wait(&dest);    
            }
            t1 = second();
            printf("avg forwarding time: %lf\n", ((t1-t0)/its));
        }
    }    
    
    return 0;
}

--Boundary-00=_NjBpCAIVJaMD5eg
Content-Type: text/x-csrc;
  charset="us-ascii";
  name="ring-tcp.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="ring-tcp.c"

/* By Hans Henrik Happe
 *
 * usage: ring-tcp <# processes> <# forwards>
 */

#include <asm/msr.h>

#include <stdio.h>
#include <poll.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/tcp.h>
#include <fcntl.h>
#include <netdb.h>
#include <sys/time.h>
#include <sys/wait.h>

double second() {

  struct timeval tv;
  struct timezone tz;
  double t;

  gettimeofday(&tv,&tz);

  t= (double)(tv.tv_sec)+(double)(tv.tv_usec/1.0e6);

  return t;
}


int do_connect(int port) {
   int n, sock, on=1;
   struct addrinfo hints, *res;
   char str[6];
   void *adr;
    
   memset(&hints, 0, sizeof(struct addrinfo));
    
   hints.ai_flags    = AI_PASSIVE;
   hints.ai_family   = PF_UNSPEC;
   hints.ai_socktype = SOCK_STREAM;

   sprintf(str, "%d", port);
   n = getaddrinfo("localhost", str, &hints, &res);

   if (n != 0) {
       fprintf(stderr,
               "getaddrinfo error: [%s]\n",
               gai_strerror(n));
       return -1;    
   }
   
   sock = socket(AF_INET, SOCK_STREAM, 0);
   if (sock == -1) {
       perror("socket");
       return -1;
   }

    
   if (setsockopt(sock, SOL_TCP, TCP_NODELAY, &on, sizeof(on)) == -1) {
       perror("setsockopt");
       return -1;
   }
   
   if (connect(sock, (struct sockaddr *)res->ai_addr, sizeof(*res->ai_addr)) == -1) {
       perror("connect");
       return -1;
   }
   
   freeaddrinfo(res);

   return sock;
}

int start_listen(int port) {
    int n, on=1;
    int sock;    
    struct sockaddr_in name;
   
        
    sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock == -1) {
        perror("socket");
        return -1;
    }

    if (setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on)) == -1) {
        perror("setsockopt");
        return -1;
    }
        
    name.sin_family = AF_INET;
    name.sin_port = htons (port);
    name.sin_addr.s_addr = htonl (INADDR_ANY);
    
    if (bind (sock, (struct sockaddr *) &name, sizeof (name)) == -1) {
        perror("bind");
        return -1;
    }      
    
    if (listen(sock, 10) == -1) {
        perror("listen");
        return -1;
    }
    
    return sock;  
}
        
int do_accept(int lsock) {
    struct sockaddr addr;
    socklen_t len = sizeof(addr);
    int sock, on=1;


    if ((sock = accept(lsock, &addr, &len)) == -1) {
        perror("accept");
        return -1;
    }

    if (setsockopt(sock, SOL_TCP, TCP_NODELAY, &on, sizeof(on)) == -1) {
        perror("setsockopt");
        return -1;
    }
        
    return sock;
}

int do_read(int fd, void *buf, int n) {
    int res;
    
    res = read(fd, buf, n);
    if (res == -1) {
        perror("read");    
    }
    if (res != n) {
        fprintf(stderr, "read incomplete\n");    
    }
    return res;
}

int do_write(int fd, void *buf, int n) {
    int res;
    
    res = write(fd, buf, n);
    if (res == -1) {
        perror("write");    
    }
    if (res != n) {
        fprintf(stderr, "write incomplete\n");    
    }
    return res;
}


int main(int argc, char *argv[]) {
    int i, cnt, pid, dest, src, its;
    int lsock, sock;
    char id, rank, data;
    int port = 11100;
    double t0, t1;
        
    /* # processes */
    cnt = atoi(argv[1]);
    
    /* # forwards */
    its = atoi(argv[2]);
    
    {
        int socks[cnt];    
           
        /* Create processes */
        rank = 0;
        for (i=1; i<cnt; i++) {
            pid = fork();
            if (pid == 0) {
                rank=i;
                break;    
            }
        }

        /* Listen */
        lsock = start_listen(port+rank);

        
        sleep(2); /* "Ensure" that all processes are listening, HACK!!! */
                
        for (i=0; i<rank; i++) {
            sock = do_accept(lsock);
            
            do_read(sock, &id, 1);
            do_write(sock, &rank, 1);

            socks[id] = sock;
        }
        
        for (i=rank; i<cnt-1; i++) {
            sock = do_connect(port+i+1);
            
            do_write(sock, &rank, 1);
            do_read(sock, &id, 1);
            
            socks[id] = sock;
        }
                
        srandom(666);        
        src = 0;
        dest = 1;
        
        /* Write startup message */
        if (rank == src) {
            do_write(socks[dest], &data, 1);
        }
        
        
        /* Receive message and forward to a random destination */
        
        t0 = second();
        for (i=0; i < its; i++) {
                    
            if (rank == dest) {
                do_read(socks[src], &data, 1);
            }

            src = dest;                    
                    
            dest = (dest+1)%cnt;    
                    
            if (src == rank) {                   
               do_write(socks[dest], &data, 1);
            }
        }
        
        if (rank == 0) {
            for (i=1; i<cnt; i++) {
                wait(&dest);    
            }
            t1 = second();
            printf("avg forwarding time: %lf\n", ((t1-t0)/its));
        }
    }    
    
    
    return 0;
}

--Boundary-00=_NjBpCAIVJaMD5eg--
