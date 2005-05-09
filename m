From: Hans Henrik Happe <hhh@imada.sdu.dk>
Subject: PROBLEM: INET TCP socket communication through loopback
Date: Mon, 9 May 2005 15:07:50 +0200
Message-ID: <200505091507.50387.hhh@imada.sdu.dk>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_mC2fCmC2MLhfCfd"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--Boundary-00=_mC2fCmC2MLhfCfd
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

I have experienced some odd behavior when communicating between multiple 
processes through the loopback device using poll() to wait for input.

Attachment 'random-inet.c' is a program that shows the problem. Basically it 
starts a number of processes. Each process makes a connection to the each of 
the other processes (resembling MPI implementations such as lam-mpi). Now a 
given number of messages are sent to a pseudo-random destination. When a 
process receives one of the messages it forwards it to another randomly 
chosen destination. The program is run as follows:

./random-inet <# processes> <# messages>

Problem: One would expect that this program would use up all the available 
CPU-time, but this is not the case. Allready with 3 processes  and 1 message 
there is still some idle CPU-time and it becomes worse when more process are 
added.

As a sanity check i created the same program using UNIX socket created by 
socketpair() (random-spair.c). This makes the problem go away.

I have also attached the  MPI program 'random-mpi.c' showing the same problem 
with lam-mpi 7.0.6. 

Another MPI program that does NOT have the problem is 'ring-mpi.c'. This  
sends the messages around in a ring of processes. The controlled 
communication pattern somehow makes the problem go away.

I have attached the 'ver-linux' of the systems that I have tested. I know 
these are not mainline kernels but I have not found any mention of such a 
problem in the latest changelogs. I will gladly try it on the mainline if 
that would help.

I'm not on the list so please CC.

Hans Henrik Happe

--Boundary-00=_mC2fCmC2MLhfCfd
Content-Type: text/x-csrc;
  charset="us-ascii";
  name="random-inet.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="random-inet.c"

/* 
 * usage: random-inet <# processes> <# messages>
 */


#include <stdio.h>
#include <poll.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/tcp.h>
#include <fcntl.h>
#include <netdb.h>


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
        
                


int main(int argc, char *argv[]) {
    int i, j, n, cnt, pid, rank, dest;
    int lsock;
    char data = 'h';
    int port = 11100;
    
    /* # processes */
    cnt = atoi(argv[1]);
    
    /* # messages */
    n = atoi(argv[2]);

    {
        int socks[cnt-1];    
        struct pollfd pfds[cnt-1];
           
        /* Create processes */
        rank = 0;
        for (i=1; i<cnt; i++) {
            pid = fork();
            if (pid == 0) {
                rank=cnt-i;
                break;    
            }
        }

        /* Setup connections */
        
        lsock = start_listen(port+rank);
        
        for (i=0; i<rank; i++) {
            socks[i] = do_accept(lsock);
            pfds[i].fd = socks[i];
            pfds[i].events = POLLIN;
        }
        
        for (i=rank; i<cnt-1; i++) {
            socks[i] = do_connect(port+i+1);
            pfds[i].fd = socks[i];
            pfds[i].events = POLLIN;
        }
                
        srandom(rank);        
        
        /* Write startup messages */
        if (rank < n) {
            dest = random()%(cnt-1);
            write(socks[dest], &data, 1);
        }

        /* Receive and forward messages to random destinations */
        while (1) {
            poll(pfds, cnt-1, -1);
            j = 0;
            for (i=0; i<cnt-1; i++) {
                if (pfds[i].revents != 0) {
                    read(pfds[i].fd, &data, 1);
                    j++;
                }
            }
            
            for (i=0; i<j; i++) {
                dest = random()%(cnt-1);
                write(socks[dest], &data, 1);
            }
        }
    }    
    return 0;
}

--Boundary-00=_mC2fCmC2MLhfCfd
Content-Type: text/plain;
  charset="us-ascii";
  name="ver_linux.2.4.24"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="ver_linux.2.4.24"

If some fields are empty or look unusual you may have an old version.
Compare to the current minimal requirements in Documentation/Changes.
 
Linux n24 2.4.24 #2 Mon Jan 26 15:59:45 CET 2004 i686 GNU/Linux
 
Gnu C                  3.3.3
Gnu make               3.80
binutils               2.14.90.0.6
util-linux             2.12
mount                  2.11x
module-init-tools      0.9.15-pre2
e2fsprogs              1.35-WIP
jfsutils               1.1.2
reiserfsprogs          3.6.11
reiser4progs           line
xfsprogs               2.5.11
pcmcia-cs              3.2.5
PPP                    2.4.2b3
nfs-utils              1.0.5
Linux C Library        2.3.2
Dynamic linker (ldd)   2.3.2
Procps                 3.1.12
Net-tools              1.60
Console-tools          0.2.3
Sh-utils               5.0
Modules Loaded         e1000 ehci-hcd pcmcia_core nls_iso8859-1 ntfs msdos reiserfs ext3 jbd agpgart autofs4 i810_audio ac97_codec soundcore i810_rng serial usb-uhci usbcore rtc e100 crc32 nfs lockd sunrpc af_packet

--Boundary-00=_mC2fCmC2MLhfCfd
Content-Type: text/plain;
  charset="us-ascii";
  name="ver_linux.2.6.11-gentoo-r6"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="ver_linux.2.6.11-gentoo-r6"

If some fields are empty or look unusual you may have an old version.
Compare to the current minimal requirements in Documentation/Changes.
 
Linux haptop 2.6.11-gentoo-r6 #7 Sat May 7 18:07:07 CEST 2005 i686 Mobile Intel(R) Celeron(R) CPU 1.60GHz GenuineIntel GNU/Linux
 
Gnu C                  3.3.5-20050130
Gnu make               3.80
binutils               2.15.92.0.2
util-linux             2.12i
mount                  2.12i
module-init-tools      3.0
e2fsprogs              1.35
reiserfsprogs          3.6.19
reiser4progs           line
PPP                    2.4.2
Linux C Library        2.3.4
Dynamic linker (ldd)   2.3.4
Procps                 3.2.4
Net-tools              1.60
Kbd                    1.12
Sh-utils               5.2.1
udev                   045
Modules Loaded         usb_storage radeon ohci_hcd e100 orinoco_pci orinoco hermes yenta_socket rsrc_nonstatic pcmcia_core radeonfb i2c_algo_bit snd_intel8x0m i2c_i801 i2c_core snd_pcm_oss snd_mixer_oss snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_intel8x0 snd_ac97_codec snd_pcm snd_timer snd soundcore snd_page_alloc ehci_hcd uhci_hcd intel_agp rtc

--Boundary-00=_mC2fCmC2MLhfCfd
Content-Type: text/plain;
  charset="us-ascii";
  name="ver_linux.2.6.3-7mdk"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="ver_linux.2.6.3-7mdk"

If some fields are empty or look unusual you may have an old version.
Compare to the current minimal requirements in Documentation/Changes.
 
Linux mimi.imada.sdu.dk 2.6.3-7mdk #1 Wed Mar 17 15:56:42 CET 2004 i686 Intel(R) Celeron(R) CPU 2.40GHz unknown GNU/Linux
 
Gnu C                  3.4.1
Gnu make               3.80
binutils               2.15.90.0.3
util-linux             2.12a
mount                  2.12a
module-init-tools      3.0
e2fsprogs              1.35
reiserfsprogs          line
reiser4progs           line
nfs-utils              1.0.6
Linux C Library        2.3.3
Dynamic linker (ldd)   2.3.3
Procps                 3.2.3
Net-tools              1.60
Console-tools          0.2.3
Sh-utils               5.2.1
Modules Loaded         nls_iso8859-1 nls_cp850 vfat fat usb-storage ircomm-tty ircomm irda floppy raw sg st sr_mod sd_mod scsi_mod snd-seq-oss snd-seq-midi-event snd-seq snd-pcm-oss snd-mixer-oss snd-intel8x0 snd-ac97-codec snd-pcm snd-timer gameport snd-page-alloc snd-mpu401-uart snd-rawmidi snd-seq-device snd soundcore md5 ipv6 af_packet 8139too mii ide-cd cdrom loop intel-agp agpgart ehci-hcd uhci-hcd usbcore rtc ext3 jbd

--Boundary-00=_mC2fCmC2MLhfCfd
Content-Type: text/x-csrc;
  charset="us-ascii";
  name="random-mpi.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="random-mpi.c"

#include <stdio.h>
#include <mpi.h>

/* 
 * Sends 'n' messages between processes. When a process
 * receives a message it chooses a new destination at random.
 *
 * usage: random-mpi <n>
 */

main(int argc, char **argv)
{
    int n, i, data[1];
    int dest, size, rank;
    
    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD,&size);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);


    n = atoi(argv[1]);
  
    srandom(rank);
    
    /* Send 'n' startup messages. */
    if (rank < n) {
        while ((dest = (random()%size)) == rank);
        MPI_Send(data, 1, MPI_INT, dest, 0, MPI_COMM_WORLD);
    }
    
    while (1) {
        MPI_Recv(data, 1, MPI_INT, MPI_ANY_SOURCE, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
        
        /* Don't send to self. */
        while ((dest = (random()%size)) == rank);
        MPI_Send(data, 1, MPI_INT, dest, 0, MPI_COMM_WORLD);
    }
  
    MPI_Finalize();
}

--Boundary-00=_mC2fCmC2MLhfCfd
Content-Type: text/x-csrc;
  charset="us-ascii";
  name="random-spair.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="random-spair.c"

/* 
 * usage: random-spair <# processes> <# messages>
 */

#include <stdio.h>
#include <poll.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/tcp.h>
#include <fcntl.h>
#include <netdb.h>


int main(int argc, char *argv[]) {
    int i, j, n, cnt, pid, rank, dest;
    int lsock;
    char data;
    int port = 11100;
    
    cnt = atoi(argv[1]);
    n = atoi(argv[2]);

    {
        int socks[cnt-1];    
        struct pollfd pfds[cnt-1];
        int spairs[2*cnt*cnt];    
        
        
        for (i=0; i<2*cnt*cnt; i+=2) {
            socketpair(AF_UNIX, SOCK_STREAM, 0, spairs+i);
        }   
        
        /* Create processes */
        rank = 0;
        for (i=1; i<cnt; i++) {
            pid = fork();
            if (pid == 0) {
                rank=cnt-i;
                break;    
            }
        }

        
        /* Assign sockets */
        j=0;
        for (i=0; i<cnt; i++) {
            if (i != rank) {
                if (i < rank) {
                    socks[j] = spairs[2*(i*cnt+rank)];                
                } else {
                    socks[j] = spairs[2*(rank*cnt+i)+1];                
                }
                pfds[j].fd = socks[j];
                pfds[j].events = POLLIN;
                j++;
            }
        }
                
        srandom(rank);        
        
        /* Write startup messages */
        if (rank < n) {
            dest = random()%(cnt-1);
            if (write(socks[dest], &data, 1) == -1) {
                perror("write 1");                            
            }
        }

        /* Receive and forward messages to random destinations */
        while (1) {
            poll(pfds, cnt-1, -1);
            j = 0;
            for (i=0; i<cnt-1; i++) {
                if (pfds[i].revents != 0) {
                    if (read(pfds[i].fd, &data, 1) == -1) {
                        perror("read");                            
                    }
                    j++;
                }
            }
            
            for (i=0; i<j; i++) {
                dest = random()%(cnt-1);
                if (write(socks[dest], &data, 1) == -1) {
                    perror("write 2");                            
                }
            }
        }
    }    
    return 0;
}

--Boundary-00=_mC2fCmC2MLhfCfd
Content-Type: text/x-csrc;
  charset="us-ascii";
  name="ring-mpi.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="ring-mpi.c"

#include <stdio.h>
#include <mpi.h>

/* 
 * Sends 'n' messages in a ring of processes.
 *
 * usage: ring-mpi <n>
 */

main(int argc, char **argv)
{
    int n, i, data[1];
    int size, rank, dest;
    
    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD,&size);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);


    n = atoi(argv[1]);
  
    dest = (rank+1)%size;
    
    /* Send 'n' startup messages. */
    if (rank%(size/n) == 0) {
        MPI_Send(data, 1, MPI_INT, dest, 0, MPI_COMM_WORLD);
    }
    
    while (1) {
        MPI_Recv(data, 1, MPI_INT, MPI_ANY_SOURCE, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
        MPI_Send(data, 1, MPI_INT, dest, 0, MPI_COMM_WORLD);
    }
      
    MPI_Finalize();
}

--Boundary-00=_mC2fCmC2MLhfCfd--
