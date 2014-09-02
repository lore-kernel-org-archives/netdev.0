From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] dev_ioctl: remove dev_load() CAP_SYS_MODULE message
Date: Tue,  2 Sep 2014 23:30:05 +0200
Message-ID: <1409693405-24671-1-git-send-email-dborkman@redhat.com>
Cc: marcel@holtmann.org, stephen@networkplumber.org,
	netdev@vger.kernel.org, Vasiliy Kulikov <segoon@openwall.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26962 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750820AbaIBVaZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Sep 2014 17:30:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marcel reported to see the following message when autoloading
is being triggered when adding nlmon device:

  Loading kernel module for a network device with
  CAP_SYS_MODULE (deprecated). Use CAP_NET_ADMIN and alias
  netdev-nlmon instead.

This false-positive happens despite with having correct
capabilities set, e.g. through issuing `ip link del dev nlmon`
more than once on a valid device with name nlmon, but Marcel
has also seen it on creation time when no nlmon module is
previously compiled-in or loaded as module and the device
name equals a link type name (e.g. nlmon, vxlan, team).

Stephen says:

  The netdev module alias is a hold over from the past. For
  normal devices, people used to create a alias eth0 to and
  point it to the type of network device used, that was back
  in the bad old ISA days before real discovery.

  Also, the tunnels create module alias for the control device
  and ip used to use this to autoload the tunnel device.

  The message is bogus and should just be removed, I also see
  it in a couple of other cases where tap devices are renamed
  for other usese.

As mentioned in 8909c9ad8ff0 ("net: don't allow CAP_NET_ADMIN
to load non-netdev kernel modules"), we nevertheless still
might want to leave the old autoloading behaviour in place
as it could break old scripts, so for now, lets just remove
the log message as Stephen suggests.

Reference: http://thread.gmane.org/gmane.linux.kernel/1105168
Reported-by: Marcel Holtmann <marcel@holtmann.org>
Suggested-by: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Vasiliy Kulikov <segoon@openwall.com>
---
 (Sending to net-next as I don't think it's very urgent.)

 net/core/dev_ioctl.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/core/dev_ioctl.c b/net/core/dev_ioctl.c
index cf999e0..72e899a 100644
--- a/net/core/dev_ioctl.c
+++ b/net/core/dev_ioctl.c
@@ -365,11 +365,8 @@ void dev_load(struct net *net, const char *name)
 	no_module = !dev;
 	if (no_module && capable(CAP_NET_ADMIN))
 		no_module = request_module("netdev-%s", name);
-	if (no_module && capable(CAP_SYS_MODULE)) {
-		if (!request_module("%s", name))
-			pr_warn("Loading kernel module for a network device with CAP_SYS_MODULE (deprecated).  Use CAP_NET_ADMIN and alias netdev-%s instead.\n",
-				name);
-	}
+	if (no_module && capable(CAP_SYS_MODULE))
+		request_module("%s", name);
 }
 EXPORT_SYMBOL(dev_load);
 
-- 
1.7.11.7
