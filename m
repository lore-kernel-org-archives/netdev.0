From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Subject: Re: UDP sockets bound to ANY send answers with wrong src ip address
Date: Sun, 13 Jun 2004 01:08:51 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406130108.51225.vda@port.imtp.ilyichevsk.odessa.ua>
References: <Pine.LNX.4.44.0406111651370.2763-100000@l>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_z73yAPd94fdhgZl"
Cc: Herbert Xu <herbert@gondor.apana.org.au>, <yoshfuji@linux-ipv6.org>,
        <netdev@oss.sgi.com>, <linux-net@vger.kernel.org>, <davem@redhat.com>,
        <pekkas@netcore.fi>, <jmorris@redhat.com>,
        <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>, Henrik Nordstrom <hno@marasystems.com>
In-Reply-To: <Pine.LNX.4.44.0406111651370.2763-100000@l>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary-00=_z73yAPd94fdhgZl
Content-Type: text/plain;
  charset="windows-1251"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Friday 11 June 2004 16:53, Julian Anastasov wrote:
> 	Hello,
>
> On Fri, 11 Jun 2004, Denis Vlasenko wrote:
> > Hmmm... do I have to set a *routing dest address* field
> > to set src ip address of my UDP packet?
>
> 	Try such function:
>
> [snip]

Thanks for your excellent help Julian.
It helped me to finally make my code work.

Pity I did not keep it that way, because 
it wouldn't be portable. I converted it
to 'man cmsg' compliant way.

On Friday 11 June 2004 17:14, Henrik Nordstrom wrote:
> [snip]
> > I am trying to figure it out, currently I'm getting
> > -EINVAL in sendmsg in this code:
> >
> > # define SRCADDR_SOCKOPT IP_PKTINFO
> > # define SRCADDR_DATASIZE (CMSG_SPACE(sizeof(struct in_pktinfo)))
> > # define srcaddr(x) (&(((struct in_pktinfo
> > *)(CMSG_DATA(x)))->ipi_spec_dst))
>
> Drop the defines. These are only obfuscating your code and the source to
> your error. You need to pass a in_pktinfo structure in the message, and

They were there in the example recv code from the Net. That code tried
to use IP_DSTADDR (IIRC) option (a BSDism or something) if it is #defined.

Dropped #defines.

I ended up with following patch for djbdns. Run tested.

Thanks again for your help guys.
--
vda

--Boundary-00=_z73yAPd94fdhgZl
Content-Type: text/x-diff;
  charset="windows-1251";
  name="d.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="d.diff"

diff -u djbdns-1.05.orig/dnscache.c djbdns-1.05.new/dnscache.c
--- djbdns-1.05.orig/dnscache.c	Sun Feb 11 23:11:45 2001
+++ djbdns-1.05.new/dnscache.c	Sun Jun 13 00:51:52 2004
@@ -62,6 +62,7 @@
   iopause_fd *io;
   char ip[4];
   uint16 port;
+  char myip[4];
   char id[2];
 } u[MAXUDP];
 int uactive = 0;
@@ -78,7 +79,7 @@
   if (!u[j].active) return;
   response_id(u[j].id);
   if (response_len > 512) response_tc();
-  socket_send4(udp53,response,response_len,u[j].ip,u[j].port);
+  socket_send4_from(udp53,response,response_len,u[j].ip,u[j].port,u[j].myip);
   log_querydone(&u[j].active,response_len);
   u[j].active = 0; --uactive;
 }
@@ -109,7 +110,7 @@
   x = u + j;
   taia_now(&x->start);
 
-  len = socket_recv4(udp53,buf,sizeof buf,x->ip,&x->port);
+  len = socket_recv4_rememberdst(udp53,buf,sizeof buf,x->ip,&x->port,x->myip);
   if (len == -1) return;
   if (len >= sizeof buf) return;
   if (x->port < 1024) if (x->port != 53) return;
diff -u djbdns-1.05.orig/socket.h djbdns-1.05.new/socket.h
--- djbdns-1.05.orig/socket.h	Sun Feb 11 23:11:45 2001
+++ djbdns-1.05.new/socket.h	Sun Jun 13 00:51:44 2004
@@ -8,8 +8,8 @@
 
 extern int socket_connect4(int,const char *,uint16);
 extern int socket_connected(int);
-extern int socket_bind4(int,char *,uint16);
-extern int socket_bind4_reuse(int,char *,uint16);
+extern int socket_bind4(int,const char *,uint16);
+extern int socket_bind4_reuse(int,const char *,uint16);
 extern int socket_listen(int,int);
 extern int socket_accept4(int,char *,uint16 *);
 extern int socket_recv4(int,char *,int,char *,uint16 *);
@@ -18,5 +18,8 @@
 extern int socket_remote4(int,char *,uint16 *);
 
 extern void socket_tryreservein(int,int);
+
+int socket_recv4_rememberdst(int s,char *buf,int len,char ip[4],uint16 *port, char ipdst[4]);
+int socket_send4_from(int s,const char *buf,int len,const char ip[4],uint16 port,const char from[4]);
 
 #endif
diff -u djbdns-1.05.orig/socket_bind.c djbdns-1.05.new/socket_bind.c
--- djbdns-1.05.orig/socket_bind.c	Sun Feb 11 23:11:45 2001
+++ djbdns-1.05.new/socket_bind.c	Fri Jun 11 12:49:45 2004
@@ -5,7 +5,7 @@
 #include "byte.h"
 #include "socket.h"
 
-int socket_bind4(int s,char ip[4],uint16 port)
+int socket_bind4(int s,const char ip[4],uint16 port)
 {
   struct sockaddr_in sa;
 
@@ -17,7 +17,7 @@
   return bind(s,(struct sockaddr *) &sa,sizeof sa);
 }
 
-int socket_bind4_reuse(int s,char ip[4],uint16 port)
+int socket_bind4_reuse(int s,const char ip[4],uint16 port)
 {
   int opt = 1;
   setsockopt(s,SOL_SOCKET,SO_REUSEADDR,&opt,sizeof opt);
diff -u djbdns-1.05.orig/socket_recv.c djbdns-1.05.new/socket_recv.c
--- djbdns-1.05.orig/socket_recv.c	Sun Feb 11 23:11:45 2001
+++ djbdns-1.05.new/socket_recv.c	Sun Jun 13 00:51:48 2004
@@ -2,6 +2,7 @@
 #include <sys/param.h>
 #include <sys/socket.h>
 #include <netinet/in.h>
+#include <string.h>	/* memset() */
 #include "byte.h"
 #include "socket.h"
 
@@ -16,6 +17,57 @@
 
   byte_copy(ip,4,(char *) &sa.sin_addr);
   uint16_unpack_big((char *) &sa.sin_port,port);
+
+  return r;
+}
+
+int socket_recv4_rememberdst(int s,char *buf,int len,char ip[4],uint16 *port, char ipdst[4])
+{
+  int r;
+
+  struct iovec iov[1];
+  struct sockaddr_in remote;
+  char cmsg[CMSG_SPACE(sizeof(struct in_pktinfo))];
+  struct cmsghdr *cmsgptr;
+  struct msghdr msg;
+
+  iov[0].iov_base = buf;
+  iov[0].iov_len = len;
+
+  memset(&msg, 0, sizeof(msg));
+  msg.msg_name = &remote;
+  msg.msg_namelen = sizeof(remote);
+  msg.msg_iov = iov;
+  msg.msg_iovlen = 1;
+  msg.msg_control = &cmsg;
+  msg.msg_controllen = sizeof(cmsg);
+
+  { // FIXME: do it only once
+    int sockopt;
+    sockopt = 1;
+    if (setsockopt(s, SOL_IP, IP_PKTINFO, &sockopt, sizeof sockopt) == -1)
+      return -1;
+  }
+
+  r = recvmsg(s, &msg, 0);
+  if (r == -1) return -1;
+
+  byte_copy(ip, 4, (char*)&remote.sin_addr);
+  uint16_unpack_big((char*)&remote.sin_port, port);
+
+  /* Here we try to retrieve destination IP and memorize it */
+  byte_copy(ipdst, 4, "\0\0\0" ); /* 4th '\0' char is also there */
+  for (cmsgptr = CMSG_FIRSTHDR(&msg);
+  cmsgptr != NULL;
+  cmsgptr = CMSG_NXTHDR(&msg, cmsgptr)) {
+    if (cmsgptr->cmsg_level == SOL_IP
+    && cmsgptr->cmsg_type == IP_PKTINFO) {
+
+#define pktinfo(cmsgptr) ( (struct in_pktinfo*)(CMSG_DATA(cmsgptr)) )
+
+      byte_copy(ipdst, 4, (char*)(&pktinfo(cmsgptr)->ipi_addr) );
+    }
+  }
 
   return r;
 }
diff -u djbdns-1.05.orig/socket_send.c djbdns-1.05.new/socket_send.c
--- djbdns-1.05.orig/socket_send.c	Sun Feb 11 23:11:45 2001
+++ djbdns-1.05.new/socket_send.c	Sun Jun 13 00:46:40 2004
@@ -2,6 +2,7 @@
 #include <sys/param.h>
 #include <sys/socket.h>
 #include <netinet/in.h>
+#include <string.h>	/* memset() */
 #include "byte.h"
 #include "socket.h"
 
@@ -15,4 +16,53 @@
   byte_copy((char *) &sa.sin_addr,4,ip);
 
   return sendto(s,buf,len,0,(struct sockaddr *) &sa,sizeof sa);
+}
+
+int socket_send4_from(int s,const char *buf,int len,const char ip[4],uint16 port,const char from[4])
+{
+  /* man recvmsg and man cmsg is needed to make sense of code below */
+
+  struct sockaddr_in remote;
+  struct iovec iov[1];
+  struct msghdr msg;
+  char cbuf[CMSG_SPACE(sizeof(struct in_pktinfo))];
+  struct cmsghdr* cmsgptr;
+  struct in_pktinfo* pktptr;
+
+  memset(&remote, 0, sizeof(remote));
+  remote.sin_family = AF_INET;
+  uint16_pack_big( (char*)&remote.sin_port, port);
+  byte_copy( (char*)&remote.sin_addr, 4, ip);
+
+  iov[0].iov_base = buf;
+  iov[0].iov_len = len;
+
+  memset(cbuf, 0, sizeof(cbuf));
+
+  memset(&msg, 0, sizeof(msg));
+  msg.msg_name = &remote;
+  msg.msg_namelen = sizeof(remote);
+  msg.msg_iov = iov;
+  msg.msg_iovlen = 1;
+  msg.msg_control = cbuf;
+  msg.msg_controllen = sizeof(cbuf);
+
+  cmsgptr = CMSG_FIRSTHDR(&msg);
+  cmsgptr->cmsg_level = SOL_IP;
+  cmsgptr->cmsg_type = IP_PKTINFO;
+  cmsgptr->cmsg_len = CMSG_LEN(sizeof(struct in_pktinfo));
+
+#define pktinfo(cmsgptr) ((struct in_pktinfo *)(CMSG_DATA(cmsgptr)))
+
+  pktptr = pktinfo(cmsgptr);
+  /* pktptr->ipi_ifindex = 0;   -- already done by memset(cbuf...) */
+  byte_copy( (char*)(&pktptr->ipi_spec_dst), 4, from);
+
+  { // FIXME: do it only once
+    int sockopt = 1;
+    if (setsockopt(s, SOL_IP, IP_PKTINFO, &sockopt, sizeof sockopt) == -1)
+      return -1;
+  }
+
+  return sendmsg(s, &msg, 0);
 }

--Boundary-00=_z73yAPd94fdhgZl--
