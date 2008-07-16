From: Andreas Henriksson <andreas@fatal.se>
Subject: Bug#489340: iproute2: no error message when link up command fails.
Date: Thu, 17 Jul 2008 00:00:58 +0200
Message-ID: <20080716220058.GA31425@amd64.fatal.se>
Reply-To: Andreas Henriksson <andreas@fatal.se>, 489340@bugs.debian.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>, 489340@bugs.debian.org,
	netdev@vger.kernel.org
To: stephen.hemminger@vyatta.com
Return-path: <bounce-debian-bugs-dist=glddb-debian-bugs-dist=m.gmane.org@lists.debian.org>
Resent-Message-ID: <handler.489340.B489340.121624544518281@bugs.debian.org>
Content-Disposition: inline
List-Post: <mailto:debian-bugs-dist@lists.debian.org>
List-Help: <mailto:debian-bugs-dist-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=unsubscribe>
List-Id: netdev.vger.kernel.org

Hi Stephen and co.!

Johannes Berg reported that iproute2 doesn't give any error message when
"ip link set ... up" failed for him (as opposed to ifconfig):
http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=489340

The ways he suggested didn't work for me to reproduce, but I found out
simply using the wmaster0 device works as a testcase.
(You'll need a wireless device, probably with a driver based on the new
mac80211 stack).

I've debugged this into a place in the bundled rtnetlink library where
if there's a netlink error - it is ignored if there's no errno, which
seems weird. I don't really understand the code, but this "proof of
concept" patch makes "ip link set dev wmaster0 up" spit out an error
message atleast. Could you please have a look at what's going on here?


diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index 5ae64f7..afa58fb 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -351,6 +351,7 @@ int rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n, pid_t peer,
 					if (errno == 0) {
 						if (answer)
 							memcpy(answer, h, h->nlmsg_len);
+						fprintf(stderr, "Unknown netlink error.\n");
 						return 0;
 					}
 					perror("RTNETLINK answers");



For the record, here's what ifconfig says:

$ sudo ifconfig wmaster0 up
SIOCSIFFLAGS: Operation not supported


--
Regards,
Andreas Henriksson
