From: Joe Harvell <joe.harvell@tekcomms.com>
Subject: [PATCH] iproute2: enhance addr label validation
Date: Sat, 21 Mar 2015 15:00:23 -0500
Message-ID: <550DCDD7.2030503@tekcomms.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemming@brocade.com>,
	Vadim Kochan <vadim4j@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0124.outbound.protection.outlook.com ([65.55.169.124]:8116
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751604AbbCUUBb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2015 16:01:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ip addr command today rejects address labels that would break 
ifconfig.  However, it allows some labels which still break it. Enhance
enforcement to reject all known incompatible labels, and allow the
existing -force option to allow someone to use a label even if it is not 
ifconfig compatible

Make existing -force option of ip addr add skip enforcement of ifconfig
compatible address labels.
Change enforcement to properly reject labels that do begin with 
<devname> but are followed by a string that does not begin with colon.

The following changes since commit 4612d04d6b8f07274bd5d0688f717ccc189499ad:

   tc class: Show class names from file (2015-03-15 12:27:40 -0700)

are available in the git repository at:

   git@github.com:jharvell/iproute2.git addr-label-noncompat

for you to fetch changes up to 44931a448ac2b375c703cb79fb814ec575fe253b:

   Signed-off-by: Joe Harvell <joe.harvell@tekcomms.com> (2015-03-21 
14:45:36 -0500)

----------------------------------------------------------------
Joe Harvell (6):
       Making -force option of ip command also allow address labels that 
are not     backward-compatible with ifconfig.  Note that even without 
this change     the ip command does allow some incompatible address 
labels to be created.     ifconfig depends on the labels beginning with 
<interface-name><colon>, but     the ip command (even before the changes 
in this commit) only requires the     prefix of the label to be 
<interface-name>.  Thus, if you add a label such     as eth0-media, it 
will be accepted by ip but ifconfig will barf on ifconfig -a.     The 
motivation for this change is that the lenght allowed for a lable is 
small,     so requiring a long prefix for ifconfig backwards 
compatibility limits the     usefulness of the label.  For embedded 
systems (or any system) where ifconfig     is not even installed, it is 
useful to be able to create longer labels.
       Enhancing enforcement of ifconfig compatible label.     Prior 
implementation allowed incompatible labels that started with dev but not 
dev:
       Adding parentheses for clarity     Removing code comment since it 
is now clearly spelled out in fprintf error message
       Using strncmp instead of matches for clarity and to avoid extra 
strlen calls
       Fixed indenting by replacing spaces with tabs     Minor re-word 
of man page text
       Signed-off-by: Joe Harvell <joe.harvell@tekcomms.com>

  include/utils.h |  1 +
  ip/ip.c         |  2 ++
  ip/ipaddress.c  | 12 +++++++++---
  man/man8/ip.8   |  2 ++
  4 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/include/utils.h b/include/utils.h
index 9151c4f..e8a5467 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -25,6 +25,7 @@ extern char * _SL_;
  extern int max_flush_loops;
  extern int batch_mode;
  extern bool do_all;
+extern bool require_ifconfig_compat;

  #ifndef IPPROTO_ESP
  #define IPPROTO_ESP    50
diff --git a/ip/ip.c b/ip/ip.c
index da16b15..78b0197 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -37,6 +37,7 @@ int force = 0;
  int max_flush_loops = 10;
  int batch_mode = 0;
  bool do_all = false;
+bool require_ifconfig_compat = true;

  struct rtnl_handle rth = { .fd = -1 };

@@ -246,6 +247,7 @@ int main(int argc, char **argv)
                         exit(0);
                 } else if (matches(opt, "-force") == 0) {
                         ++force;
+                       require_ifconfig_compat = false;
                 } else if (matches(opt, "-batch") == 0) {
                         argc--;
                         argv++;
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 99a6ab5..be027c6 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -1691,11 +1691,17 @@ static int ipaddr_modify(int cmd, int flags, int 
argc, char **argv)
                 fprintf(stderr, "Not enough information: \"dev\" 
argument is required.\n");
                 return -1;
         }
-       if (l && matches(d, l) != 0) {
-               fprintf(stderr, "\"dev\" (%s) must match \"label\" 
(%s).\n", d, l);
+       if ( require_ifconfig_compat && l) {
+               bool isCompat = false;
+               size_t dLen = strlen(d);
+               size_t lLen = strlen(l);
+               if(lLen >= dLen && strncmp(d, l, dLen) == 0)
+                       isCompat =  (dLen == lLen || l[dLen] == ':');
+               if( !isCompat ) {
+                       fprintf(stderr, "\"label\" (%s) must either be 
\"dev\" (%s) or start with \"dev\" followed by a colon (%s:).\n", l, d, d);
                 return -1;
+               }
         }
-
         if (peer_len == 0 && local_len) {
                 if (cmd == RTM_DELADDR && lcl.family == AF_INET && 
!(lcl.flags & PREFIXLEN_SPECIFIED)) {
                         fprintf(stderr,
diff --git a/man/man8/ip.8 b/man/man8/ip.8
index 016e8c6..f58241f 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -54,6 +54,8 @@ First failure will cause termination of ip.
  Don't terminate ip on errors in batch mode.
  If there were any errors during execution of the commands, the 
application return code will be non zero.

+This option also allows creation of address labels that may not be 
compatible with ifconfig.
+
  .TP
  .BR "\-s" , " \-stats" , " \-statistics"
  Output more information.  If the option
