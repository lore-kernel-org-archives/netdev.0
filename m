From: Andreas Henriksson <andreas@fatal.se>
Subject: Bug#776040: [PATCH] iproute2/ip: fix up filter when printing addresses
Date: Fri, 23 Jan 2015 13:10:33 +0100
Message-ID: <1422015033-14217-1-git-send-email-andreas@fatal.se>
Reply-To: Andreas Henriksson <andreas@fatal.se>, 776040@bugs.debian.org
Cc: netdev@vger.kernel.org,
	Andreas Henriksson <andreas@fatal.se>,
	776040@bugs.debian.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <bounce-debian-bugs-dist=glddb-debian-bugs-dist=m.gmane.org@lists.debian.org>
Resent-Message-ID: <handler.776040.B776040.142201520014900@bugs.debian.org>
List-URL: <http://lists.debian.org/debian-bugs-dist/>
List-Post: <mailto:debian-bugs-dist@lists.debian.org>
List-Help: <mailto:debian-bugs-dist-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=unsubscribe>
List-Id: netdev.vger.kernel.org

"ip addr show up" would exclude the interface (link), but include the
addresses of down interfaces (which looked like they where indented
under a different interface). This fixes the filtering.

For a full example see the original bug report at:
http://bugs.debian.org/776040

Reported-by: Paul Slootman <paul@debian.org>
CC: 776040@bugs.debian.org
Signed-off-by: Andreas Henriksson <andreas@fatal.se>
---
 ip/ipaddress.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index d5e863d..3730424 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -970,7 +970,8 @@ struct nlmsg_chain
 	struct nlmsg_list *tail;
 };
 
-static int print_selected_addrinfo(int ifindex, struct nlmsg_list *ainfo, FILE *fp)
+static int print_selected_addrinfo(struct ifinfomsg *ifi,
+				   struct nlmsg_list *ainfo, FILE *fp)
 {
 	for ( ;ainfo ;  ainfo = ainfo->next) {
 		struct nlmsghdr *n = &ainfo->h;
@@ -982,10 +983,13 @@ static int print_selected_addrinfo(int ifindex, struct nlmsg_list *ainfo, FILE *
 		if (n->nlmsg_len < NLMSG_LENGTH(sizeof(ifa)))
 			return -1;
 
-		if (ifa->ifa_index != ifindex ||
+		if (ifa->ifa_index != ifi->ifi_index ||
 		    (filter.family && filter.family != ifa->ifa_family))
 			continue;
 
+		if (filter.up && !(ifi->ifi_flags&IFF_UP))
+			continue;
+
 		print_addrinfo(NULL, n, fp);
 	}
 	return 0;
@@ -1446,7 +1450,7 @@ static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
 		if (no_link || (res = print_linkinfo(NULL, &l->h, stdout)) >= 0) {
 			struct ifinfomsg *ifi = NLMSG_DATA(&l->h);
 			if (filter.family != AF_PACKET)
-				print_selected_addrinfo(ifi->ifi_index,
+				print_selected_addrinfo(ifi,
 							ainfo.head, stdout);
 			if (res > 0 && !do_link && show_stats)
 				print_link_stats(stdout, &l->h);
-- 
2.1.4
