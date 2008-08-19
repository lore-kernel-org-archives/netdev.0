From: Li Yewang <lyw@cn.fujitsu.com>
Subject: [PATCH][iproute2/ss]distinguish the inet and inet6 domain when loading
 the tcp_diag module
Date: Tue, 19 Aug 2008 15:39:56 +0800
Message-ID: <48AA78CC.9030201@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'Netdev'" <netdev@vger.kernel.org>
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60967 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752062AbYHSHmQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Aug 2008 03:42:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When load the tcp_diag module, and use "ss -f inet" command to show the socket 
information of inet domain. But this command also shows the information of inet6 
domain, but not only inet domain. and "ss -f inet6", "ss -4", "ss -6" have the
same problem.


Signed-off-by: Li Yewang <lyw@cn.fujitsu.com>

diff --git a/misc/ss.c b/misc/ss.c
index 38eed29..dea90b6 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1503,6 +1503,7 @@ static int tcp_show_netlink(struct filter *f, FILE 
*dump_fp, int socktype)
  		h = (struct nlmsghdr*)buf;
  		while (NLMSG_OK(h, status)) {
  			int err;
+			struct inet_diag_msg *r = NLMSG_DATA(h);

  			if (/*h->nlmsg_pid != rth->local.nl_pid ||*/
  			    h->nlmsg_seq != 123456)
@@ -1521,6 +1522,10 @@ static int tcp_show_netlink(struct filter *f, FILE 
*dump_fp, int socktype)
  				return 0;
  			}
  			if (!dump_fp) {
+				if (!(f->families & (1<<r->idiag_family))) {
+					h = NLMSG_NEXT(h, status);
+					continue;
+				}
  				err = tcp_show_sock(h, NULL);
  				if (err < 0)
  					return err;

