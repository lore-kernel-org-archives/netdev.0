From: David Miller <davem@davemloft.net>
Subject: non-TCP tbench (was Re: tbench wrt. loopback TSO)
Date: Thu, 16 Oct 2008 20:49:03 -0700 (PDT)
Message-ID: <20081016.204903.113649388.davem@davemloft.net>
References: <20081015.171408.193701292.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zbr@ioremap.net, efault@gmx.de, mingo@elte.hu,
	a.p.zijlstra@chello.nl, herbert@gondor.apana.org.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57190
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752074AbYJQDt1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2008 23:49:27 -0400
In-Reply-To: <20081015.171408.193701292.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Just for fun, to continue my own investigations, I wrote two
more variants of tbench to try and eliminate and compare
possible influences to the changes.

First is a "nop" variant, it just does memcpy()'s of the size the TCP
transfers would have been.

Second is a "pipe" variant, the uses pipes instead of TCP sockets.

Here is a dbench patch:

diff -u --recursive --new-file vanilla/dbench-4.0/Makefile.in dbench-4.0/Makefile.in
--- vanilla/dbench-4.0/Makefile.in	2008-02-17 16:49:25.000000000 -0800
+++ dbench-4.0/Makefile.in	2008-10-16 20:47:57.000000000 -0700
@@ -17,9 +17,11 @@
 
 DB_OBJS = fileio.o util.o dbench.o child.o system.o snprintf.o
 TB_OBJS = sockio.o util.o dbench.o child.o socklib.o snprintf.o
+NOP_OBJS = nopio.o util.o dbench.o child.o socklib.o snprintf.o
+PIPE_OBJS = pipeio.o util.o dbench.o child.o snprintf.o
 SRV_OBJS = util.o tbench_srv.o socklib.o
 
-all: dbench tbench tbench_srv
+all: dbench tbench tbench_srv nop pbench
 
 dbench: $(DB_OBJS)
 	$(CC) -o $@ $(DB_OBJS) $(LIBS)
@@ -30,6 +32,12 @@
 tbench_srv: $(SRV_OBJS)
 	$(CC) -o $@ $(SRV_OBJS) $(LIBS)
 
+nop: $(NOP_OBJS)
+	$(CC) -o $@ $(NOP_OBJS) $(LIBS)
+
+pbench: $(PIPE_OBJS)
+	$(CC) -o $@ $(PIPE_OBJS) $(LIBS)
+
 # Careful here: don't install client.txt over itself.
 install: all
 	${INSTALLCMD} -d $(bindir) $(datadir) $(mandir)
@@ -40,7 +48,7 @@
 	ln -sf dbench.1 $(mandir)/tbench_srv.1
 
 clean:
-	rm -f *.o *~ dbench tbench tbench_srv
+	rm -f *.o *~ dbench tbench tbench_srv nop pbench
 
 proto:
 	./mkproto.pl *.c > proto.h
diff -u --recursive --new-file vanilla/dbench-4.0/nopio.c dbench-4.0/nopio.c
--- vanilla/dbench-4.0/nopio.c	1969-12-31 16:00:00.000000000 -0800
+++ dbench-4.0/nopio.c	2008-10-16 20:48:18.000000000 -0700
@@ -0,0 +1,197 @@
+#include "dbench.h"
+
+struct nopio {
+	char dstbuf[70000];
+	char srcbuf[70000];
+};
+
+static void do_packets(struct child_struct *child, int send_size, int recv_size)
+{
+	struct nopio *nopio = (struct nopio *) child->private;
+
+	/* Client --> Server */
+	memcpy(nopio->dstbuf, nopio->srcbuf, send_size);
+	memcpy(nopio->srcbuf, nopio->dstbuf, send_size);
+
+	/* Serer --> Client */
+	memcpy(nopio->srcbuf, nopio->dstbuf, recv_size);
+	memcpy(nopio->dstbuf, nopio->srcbuf, recv_size);
+}
+
+void nb_setup(struct child_struct *child)
+{
+	struct nopio *nopio;
+	nopio = calloc(1, sizeof(struct nopio));
+	child->private = nopio;
+	child->rate.last_time = timeval_current();
+	child->rate.last_bytes = 0;
+
+	do_packets(child, 8, 8);
+}
+
+void nb_unlink(struct child_struct *child, const char *fname, int attr, const char *status)
+{
+	(void)child;
+	(void)attr;
+	(void)status;
+        do_packets(child, 39+2+strlen(fname)*2+2, 39);
+}
+
+void nb_mkdir(struct child_struct *child, const char *dname, const char *status)
+{
+	(void)child;
+	(void)status;
+        do_packets(child, 39+2+strlen(dname)*2+2, 39);
+}
+
+void nb_rmdir(struct child_struct *child, const char *fname, const char *status)
+{
+	(void)child;
+	(void)status;
+        do_packets(child, 39+2+strlen(fname)*2+2, 39);
+}
+
+void nb_createx(struct child_struct *child, const char *fname, 
+		uint32_t create_options, uint32_t create_disposition, int fnum,
+		const char *status)
+{
+	(void)child;
+	(void)create_options;
+	(void)create_disposition;
+	(void)fnum;
+	(void)status;
+        do_packets(child, 70+2+strlen(fname)*2+2, 39+12*4);
+}
+
+void nb_writex(struct child_struct *child, int handle, int offset, 
+	       int size, int ret_size, const char *status)
+{
+	(void)child;
+	(void)handle;
+	(void)offset;
+	(void)ret_size;
+	(void)status;
+        do_packets(child, 39+20+size, 39+16);
+	child->bytes += size;
+}
+
+void nb_readx(struct child_struct *child, int handle, int offset, 
+	      int size, int ret_size, const char *status)
+{
+	(void)child;
+	(void)handle;
+	(void)offset;
+	(void)size;
+	(void)status;
+        do_packets(child, 39+20, 39+20+ret_size);
+	child->bytes += ret_size;
+}
+
+void nb_close(struct child_struct *child, int handle, const char *status)
+{
+	(void)child;
+	(void)handle;
+	(void)status;
+        do_packets(child, 39+8, 39);
+}
+
+void nb_rename(struct child_struct *child, const char *old, const char *new, const char *status)
+{
+	(void)child;
+	(void)status;
+        do_packets(child, 39+8+2*strlen(old)+2*strlen(new), 39);
+}
+
+void nb_flush(struct child_struct *child, int handle, const char *status)
+{
+	(void)child;
+	(void)handle;
+	(void)status;
+        do_packets(child, 39+2, 39);
+}
+
+void nb_qpathinfo(struct child_struct *child, const char *fname, int level, 
+		  const char *status)
+{
+	(void)child;
+	(void)level;
+	(void)status;
+        do_packets(child, 39+16+2*strlen(fname), 39+32);
+}
+
+void nb_qfileinfo(struct child_struct *child, int handle, int level, const char *status)
+{
+	(void)child;
+	(void)level;
+	(void)handle;
+	(void)status;
+        do_packets(child, 39+20, 39+32);
+}
+
+void nb_qfsinfo(struct child_struct *child, int level, const char *status)
+{
+	(void)child;
+	(void)level;
+	(void)status;
+        do_packets(child, 39+20, 39+32);
+}
+
+void nb_findfirst(struct child_struct *child, const char *fname, int level, int maxcnt, 
+		  int count, const char *status)
+{
+	(void)child;
+	(void)level;
+	(void)maxcnt;
+	(void)status;
+        do_packets(child, 39+20+strlen(fname)*2, 39+90*count);
+}
+
+void nb_cleanup(struct child_struct *child)
+{
+	(void)child;
+}
+
+void nb_deltree(struct child_struct *child, const char *dname)
+{
+	(void)child;
+	(void)dname;
+}
+
+void nb_sfileinfo(struct child_struct *child, int handle, int level, const char *status)
+{
+	(void)child;
+	(void)handle;
+	(void)level;
+	(void)status;
+        do_packets(child, 39+32, 39+8);
+}
+
+void nb_lockx(struct child_struct *child, int handle, uint32_t offset, int size, 
+	      const char *status)
+{
+	(void)child;
+	(void)handle;
+	(void)offset;
+	(void)size;
+	(void)status;
+        do_packets(child, 39+12, 39);
+}
+
+void nb_unlockx(struct child_struct *child,
+		int handle, uint32_t offset, int size, const char *status)
+{
+	(void)child;
+	(void)handle;
+	(void)offset;
+	(void)size;
+	(void)status;
+        do_packets(child, 39+12, 39);
+}
+
+void nb_sleep(struct child_struct *child, int usec, const char *status)
+{
+	(void)child;
+	(void)usec;
+	(void)status;
+	usleep(usec);
+}
diff -u --recursive --new-file vanilla/dbench-4.0/pipeio.c dbench-4.0/pipeio.c
--- vanilla/dbench-4.0/pipeio.c	1969-12-31 16:00:00.000000000 -0800
+++ dbench-4.0/pipeio.c	2008-10-16 20:42:31.000000000 -0700
@@ -0,0 +1,310 @@
+#include "dbench.h"
+
+static int pipe_read(int s, char *buf, int size)
+{
+	int total=0;
+
+	while (size) {
+		int r = read(s, buf, size);
+		if (r <= 0) {
+			if (r == -1) perror("pipe_read");
+			break;
+		}
+		buf += r;
+		size -= r;
+		total += r;
+	}
+	return total;
+}
+
+static int pipe_write(int s, char *buf, int size)
+{
+	int total=0;
+
+	while (size) {
+		int r = write(s, buf, size);
+		if (r <= 0) {
+			if (r == -1) perror("pipe_write");
+			break;
+		}
+		buf += r;
+		size -= r;
+		total += r;
+	}
+	return total;
+}
+
+struct pipeio {
+	char buf[70000];
+	int readfd, writefd;
+};
+
+static void do_packets(struct child_struct *child, int send_size, int recv_size)
+{
+	struct pipeio *pipeio = (struct pipeio *) child->private;
+	uint32 *ubuf = (uint32 *) pipeio->buf;
+
+	ubuf[0] = htonl(send_size-4);
+	ubuf[1] = htonl(recv_size-4);
+
+	if (pipe_write(pipeio->writefd, pipeio->buf, send_size) != send_size) {
+		printf("error writing %d bytes\n", (int)send_size);
+		exit(1);
+	}
+
+	if (pipe_read(pipeio->readfd, pipeio->buf, 4) != 4) {
+		printf("error reading header\n");
+		exit(1);
+	}
+
+	if (ntohl(ubuf[0]) != (unsigned)(recv_size-4)) {
+		printf("lost sync (%d %d)\n", 
+		       (int)recv_size-4, (int)ntohl(ubuf[0]));
+		exit(1);
+	}
+
+	if (pipe_read(pipeio->readfd, pipeio->buf, recv_size-4) != 
+	    recv_size-4) {
+		printf("error reading %d bytes\n", (int)recv_size-4);
+		exit(1);
+	}
+
+	if (ntohl(ubuf[0]) != (unsigned)(recv_size-4)) {
+		printf("lost sync (%d %d)\n", 
+		       (int)recv_size-4, (int)ntohl(ubuf[0]));
+	}
+}
+
+static void server(int readfd, int writefd)
+{
+	char buf[70000];
+	unsigned *ibuf = (unsigned *)buf;
+	uint32_t n;
+
+	signal(SIGPIPE, SIG_IGN);
+
+	printf("^"); fflush(stdout);
+
+	while (1) {
+		if (pipe_read(readfd, buf, 4) != 4)
+			break;
+		n = ntohl(ibuf[0]);
+		if (n+4 >= sizeof(buf)) {
+			printf("overflow in server!\n");
+			exit(1);
+		}
+		if (pipe_read(readfd, buf+4, n) != (int)n)
+			break;
+		n = ntohl(ibuf[1]);
+		ibuf[0] = htonl(n);
+		if (pipe_write(writefd, buf, n+4) != (int)(n+4))
+			break;
+	}
+}
+
+void nb_setup(struct child_struct *child)
+{
+	struct pipeio *pipeio;
+	int fds_one[2];
+	int fds_two[2];
+
+	if (pipe(fds_one) == -1) {
+		perror("pipe1");
+		exit(1);
+	}
+
+	if (pipe(fds_two) == -1) {
+		perror("pipe2");
+		exit(1);
+	}
+
+	if (fork() == 0) {
+		setpgrp();
+		close(fds_one[1]);
+		close(fds_two[0]);
+		server(fds_one[0], fds_two[1]);
+		close(fds_one[0]);
+		close(fds_two[1]);
+		exit(0);
+	}
+
+	close(fds_one[0]);
+	close(fds_two[1]);
+
+	pipeio = calloc(1, sizeof(struct pipeio));
+	pipeio->readfd = fds_two[0];
+	pipeio->writefd = fds_one[1];
+	child->private = pipeio;
+	child->rate.last_time = timeval_current();
+	child->rate.last_bytes = 0;
+
+	do_packets(child, 8, 8);
+}
+
+void nb_unlink(struct child_struct *child, const char *fname, int attr, const char *status)
+{
+	(void)child;
+	(void)attr;
+	(void)status;
+        do_packets(child, 39+2+strlen(fname)*2+2, 39);
+}
+
+void nb_mkdir(struct child_struct *child, const char *dname, const char *status)
+{
+	(void)child;
+	(void)status;
+        do_packets(child, 39+2+strlen(dname)*2+2, 39);
+}
+
+void nb_rmdir(struct child_struct *child, const char *fname, const char *status)
+{
+	(void)child;
+	(void)status;
+        do_packets(child, 39+2+strlen(fname)*2+2, 39);
+}
+
+void nb_createx(struct child_struct *child, const char *fname, 
+		uint32_t create_options, uint32_t create_disposition, int fnum,
+		const char *status)
+{
+	(void)child;
+	(void)create_options;
+	(void)create_disposition;
+	(void)fnum;
+	(void)status;
+        do_packets(child, 70+2+strlen(fname)*2+2, 39+12*4);
+}
+
+void nb_writex(struct child_struct *child, int handle, int offset, 
+	       int size, int ret_size, const char *status)
+{
+	(void)child;
+	(void)handle;
+	(void)offset;
+	(void)ret_size;
+	(void)status;
+        do_packets(child, 39+20+size, 39+16);
+	child->bytes += size;
+}
+
+void nb_readx(struct child_struct *child, int handle, int offset, 
+	      int size, int ret_size, const char *status)
+{
+	(void)child;
+	(void)handle;
+	(void)offset;
+	(void)size;
+	(void)status;
+        do_packets(child, 39+20, 39+20+ret_size);
+	child->bytes += ret_size;
+}
+
+void nb_close(struct child_struct *child, int handle, const char *status)
+{
+	(void)child;
+	(void)handle;
+	(void)status;
+        do_packets(child, 39+8, 39);
+}
+
+void nb_rename(struct child_struct *child, const char *old, const char *new, const char *status)
+{
+	(void)child;
+	(void)status;
+        do_packets(child, 39+8+2*strlen(old)+2*strlen(new), 39);
+}
+
+void nb_flush(struct child_struct *child, int handle, const char *status)
+{
+	(void)child;
+	(void)handle;
+	(void)status;
+        do_packets(child, 39+2, 39);
+}
+
+void nb_qpathinfo(struct child_struct *child, const char *fname, int level, 
+		  const char *status)
+{
+	(void)child;
+	(void)level;
+	(void)status;
+        do_packets(child, 39+16+2*strlen(fname), 39+32);
+}
+
+void nb_qfileinfo(struct child_struct *child, int handle, int level, const char *status)
+{
+	(void)child;
+	(void)level;
+	(void)handle;
+	(void)status;
+        do_packets(child, 39+20, 39+32);
+}
+
+void nb_qfsinfo(struct child_struct *child, int level, const char *status)
+{
+	(void)child;
+	(void)level;
+	(void)status;
+        do_packets(child, 39+20, 39+32);
+}
+
+void nb_findfirst(struct child_struct *child, const char *fname, int level, int maxcnt, 
+		  int count, const char *status)
+{
+	(void)child;
+	(void)level;
+	(void)maxcnt;
+	(void)status;
+        do_packets(child, 39+20+strlen(fname)*2, 39+90*count);
+}
+
+void nb_cleanup(struct child_struct *child)
+{
+	(void)child;
+}
+
+void nb_deltree(struct child_struct *child, const char *dname)
+{
+	(void)child;
+	(void)dname;
+}
+
+void nb_sfileinfo(struct child_struct *child, int handle, int level, const char *status)
+{
+	(void)child;
+	(void)handle;
+	(void)level;
+	(void)status;
+        do_packets(child, 39+32, 39+8);
+}
+
+void nb_lockx(struct child_struct *child, int handle, uint32_t offset, int size, 
+	      const char *status)
+{
+	(void)child;
+	(void)handle;
+	(void)offset;
+	(void)size;
+	(void)status;
+        do_packets(child, 39+12, 39);
+}
+
+void nb_unlockx(struct child_struct *child,
+		int handle, uint32_t offset, int size, const char *status)
+{
+	(void)child;
+	(void)handle;
+	(void)offset;
+	(void)size;
+	(void)status;
+        do_packets(child, 39+12, 39);
+}
+
+void nb_sleep(struct child_struct *child, int usec, const char *status)
+{
+	(void)child;
+	(void)usec;
+	(void)status;
+	fprintf(stderr, "%d: usleep(%d)\n", child->id, usec);
+	usleep(usec);
+}
