From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch net/stable v2] br: fix use of ->rx_handler_data in code
 executed on non-rx_handler path
Date: Thu, 5 Dec 2013 08:55:14 -0800
Message-ID: <20131205085514.4c079747@nehalam.linuxnetplumber.net>
References: <1386257257-25258-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, davem@davemloft.net, jtluka@redhat.com,
	zhiguohong@tencent.com, bridge@lists.linux-foundation.org,
	edumazet@google.com, laine@redhat.com, mst@redhat.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:41619 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756857Ab3LEQzT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 11:55:19 -0500
Received: by mail-pd0-f182.google.com with SMTP id v10so25149158pde.27
        for <netdev@vger.kernel.org>; Thu, 05 Dec 2013 08:55:19 -0800 (PST)
In-Reply-To: <1386257257-25258-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  5 Dec 2013 16:27:37 +0100
Jiri Pirko <jiri@resnulli.us> wrote:

> br_stp_rcv() is reached by non-rx_handler path. That means there is no
> guarantee that dev is bridge port and therefore simple NULL check of
> ->rx_handler_data is not enough. There is need to check if dev is really
> bridge port and since only rcu read lock is held here, do it by checking
> ->rx_handler pointer.
> 
> Note that synchronize_net() in netdev_rx_handler_unregister() ensures
> this approach as valid.
> 


I think this patch is simpler/better, it restores the old logic.

Ps. submitting patches to bugzilla is a good way to have them ignored.

>From Stephen Hemminger <stephen@networkplumber.org>

Check that incoming STP packet is received on a port assigned to bridge
before processing. It is possible to receive packet on non-bridge port
because they are multicast.

See:
 https://bugzilla.kernel.org/show_bug.cgi?id=64911


Regression introduced by:
commit 716ec052d2280d511e10e90ad54a86f5b5d4dcc2
Author: Hong Zhiguo <zhiguohong@tencent.com>
Date:   Sat Sep 14 22:42:28 2013 +0800

    bridge: fix NULL pointer deref of br_port_get_rcu


Reported-by: Alexander Y. Fomichev
Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/net/bridge/br_stp_bpdu.c	2013-06-11 09:50:21.522919061 -0700
+++ b/net/bridge/br_stp_bpdu.c	2013-12-05 08:46:56.090463702 -0800
@@ -153,6 +153,9 @@ void br_stp_rcv(const struct stp_proto *
 	if (buf[0] != 0 || buf[1] != 0 || buf[2] != 0)
 		goto err;
 
+	if (!br_port_exists(dev))
+		goto err;
+
 	p = br_port_get_rcu(dev);
 	if (!p)
 		goto err;
