From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: MD5 SG fix
Date: Thu, 3 Jul 2008 21:02:27 -0700
Message-ID: <20080703210227.0df5e80a@extreme>
References: <396556a20805301217k293e5718h6bbf02bfe0683152@europa>
	<396556a20805301217k293e5718h6bbf02bfe0683153@europa>
	<20080702045555.GB11252@2ka.mipt.ru>
	<396556a20807031707u26276f7dx8787f8b23d050087@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org
To: "Adam Langley" <agl@imperialviolet.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:41799 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750709AbYGDECg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jul 2008 00:02:36 -0400
In-Reply-To: <396556a20807031707u26276f7dx8787f8b23d050087@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 3 Jul 2008 17:07:54 -0700
"Adam Langley" <agl@imperialviolet.org> wrote:

> On Tue, Jul 1, 2008 at 9:55 PM, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> > Why dont't you want to iterate over all provided data/page pointers with
> > crypto_hash_update() and do not mess with huge scatterlist arrays?
> 
> You're right, it's easier that way. I was just stuck in the thinking
> of the original code.
> 
> Stephen: I managed to test the SG stuff by setting up lo in jumbo
> frames mode, so no need to test it on your BGP stuff.
> 
> 
> Cheers,
> 
> AGL


Here is patch to netcat which is one of the easier ways to test
this.  Should also make sure sendfile() a.k.a splice still works.

--- a/src/netcat.c	2008-06-25 16:35:25.000000000 -0700
+++ b/src/netcat.c	2008-06-25 16:35:25.000000000 -0700
@@ -59,7 +59,7 @@ int opt_wait = 0;		/* wait time */
 char *opt_outputfile = NULL;	/* hexdump output file */
 char *opt_exec = NULL;		/* program to exec after connecting */
 nc_proto_t opt_proto = NETCAT_PROTO_TCP; /* protocol to use for connections */
-
+char *opt_md5 = NULL;		/* signature to use on TCP connection */
 
 /* signal handling */
 
@@ -192,6 +192,7 @@ int main(int argc, char *argv[])
 	{ "help",	no_argument,		NULL, 'h' },
 	{ "interval",	required_argument,	NULL, 'i' },
 	{ "listen",	no_argument,		NULL, 'l' },
+	{ "md5",	required_argument,	NULL, 'M' },
 	{ "tunnel",	required_argument,	NULL, 'L' },
 	{ "dont-resolve", no_argument,		NULL, 'n' },
 	{ "output",	required_argument,	NULL, 'o' },
@@ -216,7 +217,7 @@ int main(int argc, char *argv[])
 	{ 0, 0, 0, 0 }
     };
 
-    c = getopt_long(argc, argv, "cde:g:G:hi:lL:no:p:P:rs:S:tTuvVxw:z",
+    c = getopt_long(argc, argv, "cde:g:G:hi:lM:L:no:p:P:rs:S:tTuvVxw:z",
 		    long_options, &option_index);
     if (c == -1)
       break;
@@ -247,6 +248,15 @@ int main(int argc, char *argv[])
 	ncprint(NCPRINT_ERROR | NCPRINT_EXIT,
 		_("Invalid interval time \"%s\""), optarg);
       break;
+    case 'M':			/* TCP MD5 */
+#ifdef TCP_MD5SIG
+      opt_md5 = strdup(optarg);
+#else
+      ncprint(NCPRINT_ERROR | NCPRINT_EXIT,
+	      _("This platform does not support TCP MD5 option"));
+#endif
+      break;
+
     case 'l':			/* mode flag: listen mode */
       if (netcat_mode != NETCAT_UNSPEC)
 	ncprint(NCPRINT_ERROR | NCPRINT_EXIT,
@@ -390,6 +400,13 @@ int main(int argc, char *argv[])
   debug_v(("Trying to parse non-args parameters (argc=%d, optind=%d)", argc,
 	  optind));
 
+#ifdef TCP_MD5SIG
+  if (opt_md5 && netcat_mode == NETCAT_LISTEN && optind == argc) {
+	  ncprint(NCPRINT_ERROR | NCPRINT_EXIT,
+		  _("Remote host required with MD5 option"));
+  }
+#endif
+
   /* try to get an hostname parameter */
   if (optind < argc) {
     char *myhost = argv[optind++];
--- a/src/network.c	2008-06-25 16:35:25.000000000 -0700
+++ b/src/network.c	2008-06-26 11:47:04.000000000 -0700
@@ -375,6 +375,27 @@ int netcat_socket_new(int domain, int ty
   return sock;
 }
 
+#ifdef TCP_MD5SIG
+int netcat_tcp_md5(int sock, int family, const struct in_addr *addr, in_port_t port)
+{
+	  struct sockaddr_in *remote;
+	  struct tcp_md5sig tcpm;
+
+	  memset(&tcpm, 0, sizeof(tcpm));
+
+	  remote = (struct sockaddr_in *) &tcpm.tcpm_addr;
+	  remote->sin_family = family;
+	  remote->sin_port = port;
+	  memcpy(&remote->sin_addr, addr, sizeof(*addr));
+
+	  tcpm.tcpm_keylen = strlen(opt_md5);
+	  memcpy(tcpm.tcpm_key, opt_md5, tcpm.tcpm_keylen);
+
+	  return setsockopt(sock, IPPROTO_TCP, TCP_MD5SIG,
+			    &tcpm, sizeof(tcpm));
+}
+#endif
+
 /* Creates a full outgoing async socket connection in the specified `domain'
    and `type' to the specified `addr' and `port'.  The connection is
    originated using the optionally specified `local_addr' and `local_port'.
@@ -432,6 +453,11 @@ int netcat_socket_new_connect(int domain
     }
   }
 
+#ifdef TCP_MD5SIG
+  if (opt_md5)
+    netcat_tcp_md5(sock, my_family, &rem_addr.sin_addr, rem_addr.sin_port);
+#endif
+
   /* add the non-blocking flag to this socket */
   if ((ret = fcntl(sock, F_GETFL, 0)) >= 0)
     ret = fcntl(sock, F_SETFL, ret | O_NONBLOCK);
--- a/src/proto.h	2008-06-25 16:35:25.000000000 -0700
+++ b/src/proto.h	2008-06-25 16:35:25.000000000 -0700
@@ -62,6 +62,7 @@ extern nc_proto_t opt_proto;
 extern FILE *output_fp;
 extern bool use_stdin, signal_handler, got_sigterm, got_sigint, got_sigusr1,
 	commandline_need_newline;
+extern char *opt_md5;
 
 /* network.c */
 bool netcat_resolvehost(nc_host_t *dst, const char *name);
@@ -77,6 +78,8 @@ int netcat_socket_new_connect(int domain
 int netcat_socket_new_listen(int domain, const struct in_addr *addr,
 			     in_port_t port);
 int netcat_socket_accept(int fd, int timeout);
+int netcat_tcp_md5(int fd, int family,
+		   const struct in_addr *addr, in_port_t port);
 
 /* telnet.c */
 void netcat_telnet_parse(nc_sock_t *ncsock);
--- a/src/misc.c	2008-06-25 16:35:25.000000000 -0700
+++ b/src/misc.c	2008-06-25 16:35:25.000000000 -0700
@@ -317,6 +317,9 @@ void netcat_printhelp(char *argv0)
 "  -G, --pointer=NUM          source-routing pointer: 4, 8, 12, ...\n"
 "  -h, --help                 display this help and exit\n"
 "  -i, --interval=SECS        delay interval for lines sent, ports scanned\n"
+#ifdef TCP_MD5SIG
+"  -M, --md5=PASSWD           use TCP MD5 option\n"
+#endif
 "  -l, --listen               listen mode, for inbound connects\n"));
   printf(_(""
 "  -L, --tunnel=ADDRESS:PORT  forward local port to remote address\n"
--- a/src/core.c	2008-06-25 16:35:25.000000000 -0700
+++ b/src/core.c	2008-06-26 11:45:49.000000000 -0700
@@ -420,6 +420,12 @@ static int core_tcp_listen(nc_sock_t *nc
     ncprint(NCPRINT_ERROR | NCPRINT_EXIT,
 	    _("Couldn't setup listening socket (err=%d)"), sock_listen);
 
+#ifdef TCP_MD5SIG
+  if (opt_md5)
+    netcat_tcp_md5(sock_listen, AF_INET,
+		   &ncsock->host.iaddrs[0], ncsock->port.netnum);
+#endif
+
   /* if the port was set to 0 this means that it is assigned randomly by the
      OS.  Find out which port they assigned to us. */
   if (ncsock->local_port.num == 0) {
--- a/src/netcat.h	2008-06-25 16:35:25.000000000 -0700
+++ b/src/netcat.h	2008-06-25 16:35:25.000000000 -0700
@@ -42,6 +42,7 @@
 #include <arpa/inet.h>		/* inet_ntop(), inet_pton() */
 
 /* other misc unchecked includes */
+#include <netinet/tcp.h>
 #if 0
 #include <netinet/in_systm.h>	/* misc crud that netinet/ip.h references */
 #include <netinet/ip.h>		/* IPOPT_LSRR, header stuff */
