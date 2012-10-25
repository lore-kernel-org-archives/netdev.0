From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 2/5] ss: Split inet_show_netlink into parts
Date: Thu, 25 Oct 2012 17:21:39 +0400
Message-ID: <50893CE3.8050707@parallels.com>
References: <50893BAF.7030500@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Stephen Hemminger <shemminger@vyatta.com>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:39604 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759022Ab2JYNVn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2012 09:21:43 -0400
In-Reply-To: <50893BAF.7030500@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The existing function inet_show_netlink sends tcp-diag request and
then receives back the response and prints it on the screen.

The sock-diag and legacy tcp-diag have different request types, but
report sockets in the same format. In order to support both it's
convenient to split the code into sending and receiving parts.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
---
 misc/ss.c |   27 +++++++++++++++++++++------
 1 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 3bceedf..27feeb8 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1495,9 +1495,8 @@ static int inet_show_sock(struct nlmsghdr *nlh, struct filter *f)
 	return 0;
 }
 
-static int inet_show_netlink(struct filter *f, FILE *dump_fp, int protocol)
+static int tcpdiag_send(int fd, int protocol, struct filter *f)
 {
-	int fd;
 	struct sockaddr_nl nladdr;
 	struct {
 		struct nlmsghdr nlh;
@@ -1507,12 +1506,8 @@ static int inet_show_netlink(struct filter *f, FILE *dump_fp, int protocol)
 	int	bclen;
 	struct msghdr msg;
 	struct rtattr rta;
-	char	buf[8192];
 	struct iovec iov[3];
 
-	if ((fd = socket(AF_NETLINK, SOCK_RAW, NETLINK_INET_DIAG)) < 0)
-		return -1;
-
 	memset(&nladdr, 0, sizeof(nladdr));
 	nladdr.nl_family = AF_NETLINK;
 
@@ -1563,6 +1558,26 @@ static int inet_show_netlink(struct filter *f, FILE *dump_fp, int protocol)
 		return -1;
 	}
 
+	return 0;
+}
+
+static int inet_show_netlink(struct filter *f, FILE *dump_fp, int protocol)
+{
+	int fd;
+	struct sockaddr_nl nladdr;
+	struct msghdr msg;
+	char	buf[8192];
+	struct iovec iov[3];
+
+	if ((fd = socket(AF_NETLINK, SOCK_RAW, NETLINK_INET_DIAG)) < 0)
+		return -1;
+
+	if (tcpdiag_send(fd, protocol, f))
+		return -1;
+
+	memset(&nladdr, 0, sizeof(nladdr));
+	nladdr.nl_family = AF_NETLINK;
+
 	iov[0] = (struct iovec){
 		.iov_base = buf,
 		.iov_len = sizeof(buf)
-- 
1.7.1
