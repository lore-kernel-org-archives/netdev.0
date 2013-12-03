From: Thomas Graf <tgraf@redhat.com>
Subject: [PATCH openvswitch v3] netlink: Implement & enable memory mapped netlink i/o
Date: Tue,  3 Dec 2013 12:19:02 +0100
Message-ID: <1d9af26b2798901c68ae9aef704d6313b71d3287.1386069453.git.tgraf@redhat.com>
Cc: dev@openvswitch.org, netdev@vger.kernel.org, dborkman@redhat.com,
	ffusco@redhat.com, fleitner@redhat.com, xiyou.wangcong@gmail.com
To: jesse@nicira.com, blp@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52707 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752836Ab3LCLTT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Dec 2013 06:19:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on the initial patch by Cong Wang posted a couple of months
ago.

This is the user space counterpart needed for the kernel patch
'[PATCH net-next 3/8] openvswitch: Enable memory mapped Netlink i/o'

Allows the kernel to construct Netlink messages on memory mapped
buffers and thus avoids copying. The functionality is enabled on
sockets used for unicast traffic.

Further optimizations are possible by avoiding the copy into the
ofpbuf after reading.

Signed-off-by: Thomas Graf <tgraf@redhat.com>
---
V3: - Provide __ALIGN_KERNEL in case <linux/kernel.h> is not available
    - Silence Clang alignment problem false positive
V2: - Provide required definitions in netlink-protocol.h if <linux/netlink.h>
      does not contain them.

 AUTHORS                |   1 +
 lib/dpif-linux.c       |   6 +-
 lib/netdev-linux.c     |   2 +-
 lib/netlink-notifier.c |   2 +-
 lib/netlink-protocol.h |  39 +++++++
 lib/netlink-socket.c   | 288 +++++++++++++++++++++++++++++++++++++++++++------
 lib/netlink-socket.h   |   2 +-
 utilities/nlmon.c      |   2 +-
 8 files changed, 304 insertions(+), 38 deletions(-)

diff --git a/AUTHORS b/AUTHORS
index 1c2d9ea..4d86f86 100644
--- a/AUTHORS
+++ b/AUTHORS
@@ -23,6 +23,7 @@ Bryan Phillippe         bp@toroki.com
 Casey Barker            crbarker@google.com
 Chris Wright            chrisw@sous-sol.org
 Chuck Short             zulcss@ubuntu.com
+Cong Wang               amwang@redhat.com
 Damien Millescamps      damien.millescamps@6wind.com
 Dan Carpenter           dan.carpenter@oracle.com
 Dan Wendlandt           dan@nicira.com
diff --git a/lib/dpif-linux.c b/lib/dpif-linux.c
index 25715f4..6c482d0 100644
--- a/lib/dpif-linux.c
+++ b/lib/dpif-linux.c
@@ -495,7 +495,7 @@ dpif_linux_port_add__(struct dpif *dpif_, struct netdev *netdev,
     int error;
 
     if (dpif->epoll_fd >= 0) {
-        error = nl_sock_create(NETLINK_GENERIC, &sock);
+        error = nl_sock_create(NETLINK_GENERIC, &sock, true);
         if (error) {
             return error;
         }
@@ -765,7 +765,7 @@ dpif_linux_port_poll(const struct dpif *dpif_, char **devnamep)
         struct nl_sock *sock;
         int error;
 
-        error = nl_sock_create(NETLINK_GENERIC, &sock);
+        error = nl_sock_create(NETLINK_GENERIC, &sock, false);
         if (error) {
             return error;
         }
@@ -1265,7 +1265,7 @@ dpif_linux_recv_set__(struct dpif *dpif_, bool enable)
             uint32_t upcall_pid;
             int error;
 
-            error = nl_sock_create(NETLINK_GENERIC, &sock);
+            error = nl_sock_create(NETLINK_GENERIC, &sock, true);
             if (error) {
                 return error;
             }
diff --git a/lib/netdev-linux.c b/lib/netdev-linux.c
index 3e0da48..3bb4618 100644
--- a/lib/netdev-linux.c
+++ b/lib/netdev-linux.c
@@ -478,7 +478,7 @@ netdev_linux_notify_sock(void)
     if (ovsthread_once_start(&once)) {
         int error;
 
-        error = nl_sock_create(NETLINK_ROUTE, &sock);
+        error = nl_sock_create(NETLINK_ROUTE, &sock, false);
         if (!error) {
             error = nl_sock_join_mcgroup(sock, RTNLGRP_LINK);
             if (error) {
diff --git a/lib/netlink-notifier.c b/lib/netlink-notifier.c
index 9aa185d..047ce75 100644
--- a/lib/netlink-notifier.c
+++ b/lib/netlink-notifier.c
@@ -109,7 +109,7 @@ nln_notifier_create(struct nln *nln, nln_notify_func *cb, void *aux)
         struct nl_sock *sock;
         int error;
 
-        error = nl_sock_create(nln->protocol, &sock);
+        error = nl_sock_create(nln->protocol, &sock, false);
         if (!error) {
             error = nl_sock_join_mcgroup(sock, nln->multicast_group);
         }
diff --git a/lib/netlink-protocol.h b/lib/netlink-protocol.h
index 3009fc5..d5b65ad 100644
--- a/lib/netlink-protocol.h
+++ b/lib/netlink-protocol.h
@@ -179,4 +179,43 @@ enum {
 #define CTRL_ATTR_MCAST_GRP_MAX (__CTRL_ATTR_MCAST_GRP_MAX - 1)
 #endif /* CTRL_ATTR_MCAST_GRP_MAX */
 
+#ifndef __ALIGN_KERNEL
+#define __ALIGN_KERNEL(x, a)		__ALIGN_KERNEL_MASK(x, (typeof(x))(a) - 1)
+#define __ALIGN_KERNEL_MASK(x, mask)	(((x) + (mask)) & ~(mask))
+#endif
+
+#ifndef NETLINK_RX_RING
+#define NETLINK_RX_RING		6
+#define NETLINK_TX_RING		7
+
+struct nl_mmap_req {
+	unsigned int	nm_block_size;
+	unsigned int	nm_block_nr;
+	unsigned int	nm_frame_size;
+	unsigned int	nm_frame_nr;
+};
+
+struct nl_mmap_hdr {
+	unsigned int	nm_status;
+	unsigned int	nm_len;
+	__u32		nm_group;
+	/* credentials */
+	__u32		nm_pid;
+	__u32		nm_uid;
+	__u32		nm_gid;
+};
+
+enum nl_mmap_status {
+	NL_MMAP_STATUS_UNUSED,
+	NL_MMAP_STATUS_RESERVED,
+	NL_MMAP_STATUS_VALID,
+	NL_MMAP_STATUS_COPY,
+	NL_MMAP_STATUS_SKIP,
+};
+
+#define NL_MMAP_MSG_ALIGNMENT		NLMSG_ALIGNTO
+#define NL_MMAP_MSG_ALIGN(sz)		__ALIGN_KERNEL(sz, NL_MMAP_MSG_ALIGNMENT)
+#define NL_MMAP_HDRLEN			NL_MMAP_MSG_ALIGN(sizeof(struct nl_mmap_hdr))
+#endif /* NETLINK_RX_RING */
+
 #endif /* netlink-protocol.h */
diff --git a/lib/netlink-socket.c b/lib/netlink-socket.c
index 4bd6d36..33fad09 100644
--- a/lib/netlink-socket.c
+++ b/lib/netlink-socket.c
@@ -21,6 +21,7 @@
 #include <stdlib.h>
 #include <sys/types.h>
 #include <sys/uio.h>
+#include <sys/mman.h>
 #include <unistd.h>
 #include "coverage.h"
 #include "dynamic-string.h"
@@ -40,7 +41,9 @@ VLOG_DEFINE_THIS_MODULE(netlink_socket);
 COVERAGE_DEFINE(netlink_overflow);
 COVERAGE_DEFINE(netlink_received);
 COVERAGE_DEFINE(netlink_recv_jumbo);
+COVERAGE_DEFINE(netlink_recv_mmap);
 COVERAGE_DEFINE(netlink_sent);
+COVERAGE_DEFINE(netlink_sent_mmap);
 
 /* Linux header file confusion causes this to be undefined. */
 #ifndef SOL_NETLINK
@@ -58,12 +61,22 @@ static void log_nlmsg(const char *function, int error,
 
 /* Netlink sockets. */
 
+struct nl_ring {
+    unsigned int head;
+    void *ring;
+};
+
 struct nl_sock {
     int fd;
     uint32_t next_seq;
     uint32_t pid;
     int protocol;
     unsigned int rcvbuf;        /* Receive buffer size (SO_RCVBUF). */
+    unsigned int frame_size;
+    unsigned int frame_nr;
+    size_t ring_size;
+    struct nl_ring tx_ring;
+    struct nl_ring rx_ring;
 };
 
 /* Compile-time limit on iovecs, so that we can allocate a maximum-size array
@@ -79,11 +92,51 @@ static int max_iovs;
 static int nl_pool_alloc(int protocol, struct nl_sock **sockp);
 static void nl_pool_release(struct nl_sock *);
 
+static int
+nl_sock_set_ring(struct nl_sock *sock)
+{
+    size_t block_size = 16 * getpagesize();
+    size_t ring_size;
+    void *ring;
+    struct nl_mmap_req req = {
+        .nm_block_size          = block_size,
+        .nm_block_nr            = 64,
+        .nm_frame_size          = 16384,
+    };
+
+    req.nm_frame_nr = req.nm_block_nr * block_size / req.nm_frame_size;
+
+    if (setsockopt(sock->fd, SOL_NETLINK, NETLINK_RX_RING, &req, sizeof(req)) < 0
+        || setsockopt(sock->fd, SOL_NETLINK, NETLINK_TX_RING, &req, sizeof(req)) < 0) {
+        VLOG_INFO("mmap netlink is not supported");
+        return 0;
+    }
+
+
+    ring_size = req.nm_block_nr * req.nm_block_size;
+    ring = mmap(NULL, 2 * ring_size, PROT_READ | PROT_WRITE,
+                MAP_SHARED, sock->fd, 0);
+    if (ring == MAP_FAILED) {
+        VLOG_ERR("netlink mmap: %s", ovs_strerror(errno));
+        return errno;
+    }
+
+    sock->frame_size = req.nm_frame_size;
+    sock->frame_nr = req.nm_frame_nr - 1;
+    sock->ring_size = ring_size;
+    sock->rx_ring.ring = ring;
+    sock->rx_ring.head = 0;
+    sock->tx_ring.ring = (char *) ring + ring_size;
+    sock->tx_ring.head = 0;
+
+    return 0;
+}
+
 /* Creates a new netlink socket for the given netlink 'protocol'
  * (NETLINK_ROUTE, NETLINK_GENERIC, ...).  Returns 0 and sets '*sockp' to the
  * new socket if successful, otherwise returns a positive errno value. */
 int
-nl_sock_create(int protocol, struct nl_sock **sockp)
+nl_sock_create(int protocol, struct nl_sock **sockp, bool use_mmap)
 {
     static struct ovsthread_once once = OVSTHREAD_ONCE_INITIALIZER;
     struct nl_sock *sock;
@@ -120,6 +173,7 @@ nl_sock_create(int protocol, struct nl_sock **sockp)
     }
     sock->protocol = protocol;
     sock->next_seq = 1;
+    sock->tx_ring.ring = sock->rx_ring.ring = NULL;
 
     rcvbuf = 1024 * 1024;
     if (setsockopt(sock->fd, SOL_SOCKET, SO_RCVBUFFORCE,
@@ -161,6 +215,11 @@ nl_sock_create(int protocol, struct nl_sock **sockp)
     }
     sock->pid = local.nl_pid;
 
+    if (use_mmap && (retval = nl_sock_set_ring(sock)) < 0) {
+        VLOG_ERR("failed to initialize memory mapped netlink socket");
+        goto error;
+    }
+
     *sockp = sock;
     return 0;
 
@@ -178,13 +237,19 @@ error:
     return retval;
 }
 
+static inline bool
+nl_sock_is_mapped(const struct nl_sock *sock)
+{
+   return sock->rx_ring.ring != NULL;
+}
+
 /* Creates a new netlink socket for the same protocol as 'src'.  Returns 0 and
  * sets '*sockp' to the new socket if successful, otherwise returns a positive
  * errno value.  */
 int
 nl_sock_clone(const struct nl_sock *src, struct nl_sock **sockp)
 {
-    return nl_sock_create(src->protocol, sockp);
+    return nl_sock_create(src->protocol, sockp, nl_sock_is_mapped(src));
 }
 
 /* Destroys netlink socket 'sock'. */
@@ -192,6 +257,9 @@ void
 nl_sock_destroy(struct nl_sock *sock)
 {
     if (sock) {
+        char *rx_ring = sock->rx_ring.ring;
+        if (rx_ring)
+            munmap(rx_ring, 2 * sock->ring_size);
         close(sock->fd);
         free(sock);
     }
@@ -242,6 +310,95 @@ nl_sock_leave_mcgroup(struct nl_sock *sock, unsigned int multicast_group)
     return 0;
 }
 
+enum ring_type {
+    RX_RING,
+    TX_RING,
+};
+
+static struct nl_ring *
+mmap_ring(struct nl_sock *sock, enum ring_type ring)
+{
+    return ring == RX_RING ? &sock->rx_ring : &sock->tx_ring;
+}
+
+static struct nl_mmap_hdr *
+mmap_frame(struct nl_sock *sock, enum ring_type ring)
+{
+    struct nl_ring *r = mmap_ring(sock, ring);
+    char *start = r->ring;
+
+    return (struct nl_mmap_hdr *)(void *)(start + r->head * sock->frame_size);
+}
+
+static void
+mmap_advance_ring(struct nl_sock *sock, enum ring_type ring)
+{
+    struct nl_ring *r = mmap_ring(sock, ring);
+
+    if (r->head != sock->frame_nr) {
+        r->head++;
+    } else {
+        r->head = 0;
+    }
+}
+
+static int
+nl_sock_send_linear(struct nl_sock *sock, const struct ofpbuf *msg,
+                    bool wait)
+{
+    int retval, error;
+
+    do {
+        retval = send(sock->fd, msg->data, msg->size, wait ? 0 : MSG_DONTWAIT);
+        error = retval < 0 ? errno : 0;
+    } while (error == EINTR);
+
+    return error;
+}
+
+static int
+nl_sock_send_mmap(struct nl_sock *sock, const struct ofpbuf *msg,
+                  bool wait)
+{
+    struct nl_mmap_hdr *hdr;
+    struct sockaddr_nl addr = {
+        .nl_family      = AF_NETLINK,
+    };
+    int retval, error;
+
+    if ((msg->size + NL_MMAP_HDRLEN) > sock->frame_size)
+        return nl_sock_send_linear(sock, msg, wait);
+
+    hdr = mmap_frame(sock, TX_RING);
+
+    if (hdr->nm_status != NL_MMAP_STATUS_UNUSED) {
+        /* No frame available. Block? */
+        if (wait) {
+            nl_sock_wait(sock, POLLOUT | POLLERR);
+            poll_block();
+        } else {
+            return EAGAIN;
+        }
+    }
+
+    memcpy((char *) hdr + NL_MMAP_HDRLEN, msg->data, msg->size);
+    hdr->nm_len     = msg->size;
+    hdr->nm_status  = NL_MMAP_STATUS_VALID;
+
+    mmap_advance_ring(sock, TX_RING);
+
+    do {
+        retval = sendto(sock->fd, NULL, 0, 0, (struct sockaddr *)&addr, sizeof(addr));
+        error = retval < 0 ? errno : 0;
+    } while (error == EINTR);
+
+    if (!error) {
+        COVERAGE_INC(netlink_sent_mmap);
+    }
+
+    return error;
+}
+
 static int
 nl_sock_send__(struct nl_sock *sock, const struct ofpbuf *msg,
                uint32_t nlmsg_seq, bool wait)
@@ -252,11 +409,13 @@ nl_sock_send__(struct nl_sock *sock, const struct ofpbuf *msg,
     nlmsg->nlmsg_len = msg->size;
     nlmsg->nlmsg_seq = nlmsg_seq;
     nlmsg->nlmsg_pid = sock->pid;
-    do {
-        int retval;
-        retval = send(sock->fd, msg->data, msg->size, wait ? 0 : MSG_DONTWAIT);
-        error = retval < 0 ? errno : 0;
-    } while (error == EINTR);
+
+    if (sock->tx_ring.ring) {
+        error = nl_sock_send_mmap(sock, msg, wait);
+    } else {
+        error = nl_sock_send_linear(sock, msg, wait);
+    }
+
     log_nlmsg(__func__, error, msg->data, msg->size, sock->protocol);
     if (!error) {
         COVERAGE_INC(netlink_sent);
@@ -297,26 +456,17 @@ nl_sock_send_seq(struct nl_sock *sock, const struct ofpbuf *msg,
 }
 
 static int
-nl_sock_recv__(struct nl_sock *sock, struct ofpbuf *buf, bool wait)
+nl_sock_recvmsg(struct nl_sock *sock, struct ofpbuf *buf, bool wait,
+                uint8_t *tail, size_t taillen)
 {
-    /* We can't accurately predict the size of the data to be received.  The
-     * caller is supposed to have allocated enough space in 'buf' to handle the
-     * "typical" case.  To handle exceptions, we make available enough space in
-     * 'tail' to allow Netlink messages to be up to 64 kB long (a reasonable
-     * figure since that's the maximum length of a Netlink attribute). */
-    struct nlmsghdr *nlmsghdr;
-    uint8_t tail[65536];
     struct iovec iov[2];
     struct msghdr msg;
-    ssize_t retval;
-
-    ovs_assert(buf->allocated >= sizeof *nlmsghdr);
-    ofpbuf_clear(buf);
+    int retval;
 
     iov[0].iov_base = buf->base;
     iov[0].iov_len = buf->allocated;
     iov[1].iov_base = tail;
-    iov[1].iov_len = sizeof tail;
+    iov[1].iov_len = taillen;
 
     memset(&msg, 0, sizeof msg);
     msg.msg_iov = iov;
@@ -342,21 +492,97 @@ nl_sock_recv__(struct nl_sock *sock, struct ofpbuf *buf, bool wait)
         return E2BIG;
     }
 
-    nlmsghdr = buf->data;
-    if (retval < sizeof *nlmsghdr
-        || nlmsghdr->nlmsg_len < sizeof *nlmsghdr
-        || nlmsghdr->nlmsg_len > retval) {
-        VLOG_ERR_RL(&rl, "received invalid nlmsg (%"PRIuSIZE"d bytes < %"PRIuSIZE")",
-                    retval, sizeof *nlmsghdr);
-        return EPROTO;
-    }
-
     buf->size = MIN(retval, buf->allocated);
     if (retval > buf->allocated) {
         COVERAGE_INC(netlink_recv_jumbo);
         ofpbuf_put(buf, tail, retval - buf->allocated);
     }
 
+    return 0;
+}
+
+static int
+nl_sock_recv_mmap(struct nl_sock *sock, struct ofpbuf *buf, bool wait,
+                  uint8_t *tail, size_t taillen)
+{
+    struct nl_mmap_hdr *hdr;
+    int retval = 0;
+
+restart:
+    hdr = mmap_frame(sock, RX_RING);
+
+    switch (hdr->nm_status) {
+    case NL_MMAP_STATUS_VALID:
+        if (hdr->nm_len == 0) {
+            /* error occured while constructing message */
+            hdr->nm_status = NL_MMAP_STATUS_UNUSED;
+            mmap_advance_ring(sock, RX_RING);
+            goto restart;
+        }
+
+        ofpbuf_put(buf, (char *) hdr + NL_MMAP_HDRLEN, hdr->nm_len);
+        COVERAGE_INC(netlink_recv_mmap);
+        break;
+
+    case NL_MMAP_STATUS_COPY:
+        retval = nl_sock_recvmsg(sock, buf, MSG_DONTWAIT, tail, taillen);
+        if (retval) {
+            return retval;
+        }
+        break;
+
+    case NL_MMAP_STATUS_UNUSED:
+    case NL_MMAP_STATUS_RESERVED:
+    default:
+        if (wait) {
+            nl_sock_wait(sock, POLLIN | POLLERR);
+            poll_block();
+            goto restart;
+        }
+
+        return EAGAIN;
+    }
+
+    hdr->nm_status = NL_MMAP_STATUS_UNUSED;
+    mmap_advance_ring(sock, RX_RING);
+
+    return retval;
+}
+
+static int
+nl_sock_recv__(struct nl_sock *sock, struct ofpbuf *buf, bool wait)
+{
+    /* We can't accurately predict the size of the data to be received.  The
+     * caller is supposed to have allocated enough space in 'buf' to handle the
+     * "typical" case.  To handle exceptions, we make available enough space in
+     * 'tail' to allow Netlink messages to be up to 64 kB long (a reasonable
+     * figure since that's the maximum length of a Netlink attribute). */
+    struct nlmsghdr *nlmsghdr;
+    uint8_t tail[65536];
+    int retval;
+
+    ovs_assert(buf->allocated >= sizeof *nlmsghdr);
+    ofpbuf_clear(buf);
+
+    if (sock->rx_ring.ring) {
+        retval = nl_sock_recv_mmap(sock, buf, wait, tail, sizeof(tail));
+    } else {
+        retval = nl_sock_recvmsg(sock, buf, wait, tail, sizeof(tail));
+    }
+
+    if (retval) {
+        return retval;
+    }
+
+    nlmsghdr = buf->data;
+    if (buf->size < sizeof *nlmsghdr
+        || nlmsghdr->nlmsg_len < sizeof *nlmsghdr
+        || nlmsghdr->nlmsg_len > buf->size) {
+        VLOG_ERR_RL(&rl, "received invalid nlmsg (%"PRIuSIZE"d bytes < %"PRIuSIZE")",
+                    buf->size, sizeof *nlmsghdr);
+        return EPROTO;
+    }
+
     log_nlmsg(__func__, 0, buf->data, buf->size, sock->protocol);
     COVERAGE_INC(netlink_received);
 
@@ -892,7 +1118,7 @@ do_lookup_genl_family(const char *name, struct nlattr **attrs,
     int error;
 
     *replyp = NULL;
-    error = nl_sock_create(NETLINK_GENERIC, &sock);
+    error = nl_sock_create(NETLINK_GENERIC, &sock, false);
     if (error) {
         return error;
     }
@@ -1028,7 +1254,7 @@ nl_pool_alloc(int protocol, struct nl_sock **sockp)
         *sockp = sock;
         return 0;
     } else {
-        return nl_sock_create(protocol, sockp);
+        return nl_sock_create(protocol, sockp, true);
     }
 }
 
diff --git a/lib/netlink-socket.h b/lib/netlink-socket.h
index 18db417..c85fd64 100644
--- a/lib/netlink-socket.h
+++ b/lib/netlink-socket.h
@@ -50,7 +50,7 @@ struct nl_sock;
 #endif
 
 /* Netlink sockets. */
-int nl_sock_create(int protocol, struct nl_sock **);
+int nl_sock_create(int protocol, struct nl_sock **, bool);
 int nl_sock_clone(const struct nl_sock *, struct nl_sock **);
 void nl_sock_destroy(struct nl_sock *);
 
diff --git a/utilities/nlmon.c b/utilities/nlmon.c
index 99b060c..cc6bc68 100644
--- a/utilities/nlmon.c
+++ b/utilities/nlmon.c
@@ -47,7 +47,7 @@ main(int argc OVS_UNUSED, char *argv[])
     set_program_name(argv[0]);
     vlog_set_levels(NULL, VLF_ANY_FACILITY, VLL_DBG);
 
-    error = nl_sock_create(NETLINK_ROUTE, &sock);
+    error = nl_sock_create(NETLINK_ROUTE, &sock, true);
     if (error) {
         ovs_fatal(error, "could not create rtnetlink socket");
     }
-- 
1.8.3.1
