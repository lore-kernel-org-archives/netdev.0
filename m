From: Andreas Henriksson <andreas@fatal.se>
Subject: Bug#526329: [PATCH] Bug#526329: iproute: Segfault on garbage lladdr
Date: Thu, 30 Apr 2009 16:50:50 +0200
Message-ID: <1241103050.19807.34.camel@amd64.fatal.se>
References: <20090430133251.7015.21654.reportbug@bfg.majoroak.f2s.com>
Reply-To: Andreas Henriksson <andreas@fatal.se>, 526329@bugs.debian.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Timothy Baldwin <T.E.Baldwin99@members.leeds.ac.uk>,  526329@bugs.debian.org, Stephen Hemminger <shemminger@vyatta.com>
Return-path: <bounce-debian-bugs-dist=glddb-debian-bugs-dist=m.gmane.org@lists.debian.org>
Resent-Message-ID: <handler.526329.B526329.12411028147901@bugs.debian.org>
In-Reply-To: <20090430133251.7015.21654.reportbug@bfg.majoroak.f2s.com>
List-Post: <mailto:debian-bugs-dist@lists.debian.org>
List-Help: <mailto:debian-bugs-dist-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=unsubscribe>
List-Id: netdev.vger.kernel.org

On tor, 2009-04-30 at 14:32 +0100, Timothy Baldwin wrote:
> Package: iproute
> Version: 20090324-1
> Severity: minor
> 
> 
> $ ip link set eth0 address help
> "help" is invalid lladdr.
> Segmentation fault
> 
> Desipte the invalid command line arguments it shouldn't crash.
> 

Callers need to check return value from ll_addr_a2n(). Patch below.

Signed-off-by: Andreas Henriksson <andreas@fatal.se>


diff --git a/ip/iplink.c b/ip/iplink.c
index 237ea82..55558e3 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -200,11 +200,15 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 		} else if (matches(*argv, "address") == 0) {
 			NEXT_ARG();
 			len = ll_addr_a2n(abuf, sizeof(abuf), *argv);
+			if (len < 0)
+				return -1;
 			addattr_l(&req->n, sizeof(*req), IFLA_ADDRESS, abuf, len);
 		} else if (matches(*argv, "broadcast") == 0 ||
 				strcmp(*argv, "brd") == 0) {
 			NEXT_ARG();
 			len = ll_addr_a2n(abuf, sizeof(abuf), *argv);
+			if (len < 0)
+				return -1;
 			addattr_l(&req->n, sizeof(*req), IFLA_BROADCAST, abuf, len);
 		} else if (matches(*argv, "txqueuelen") == 0 ||
 				strcmp(*argv, "qlen") == 0 ||
