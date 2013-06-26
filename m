From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH vxlan v2 1/8] vxlan: Fix module cleanup.
Date: Wed, 26 Jun 2013 14:48:40 -0700
Message-ID: <20130626144840.05ff8c80@nehalam.linuxnetplumber.net>
References: <1372277609-17467-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:40748 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752733Ab3FZVso (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jun 2013 17:48:44 -0400
Received: by mail-pd0-f180.google.com with SMTP id 10so1683162pdi.39
        for <netdev@vger.kernel.org>; Wed, 26 Jun 2013 14:48:44 -0700 (PDT)
In-Reply-To: <1372277609-17467-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 26 Jun 2013 13:13:29 -0700
Pravin B Shelar <pshelar@nicira.com> wrote:

> vxlan private per net object can be accessed in device unregister.
> therefore unregister pernet device at the end.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> ---
>  drivers/net/vxlan.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 227b54a..0ba1e7e 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -1916,9 +1916,9 @@ late_initcall(vxlan_init_module);
>  
>  static void __exit vxlan_cleanup_module(void)
>  {
> -	unregister_pernet_device(&vxlan_net_ops);
>  	rtnl_link_unregister(&vxlan_link_ops);
>  	destroy_workqueue(vxlan_wq);
> +	unregister_pernet_device(&vxlan_net_ops);
>  	rcu_barrier();
>  }
>  module_exit(vxlan_cleanup_module);

No. This won't work.
The problem is that:
  rtnl_link_unregister calls __rtnl_kill_links which calls
  vxlan_dellink

vxlan_dellink assumes link is last thing and that the vxlan
device is already down. vxlan_dellink will unregister the device
and schedule work queue for closing socket.

When you call unregister_pernet_device last, nothing happens.
Since all vxlan device's are unregistered, the per-net vxlan
device list would be empty. And since vxlan_stop was never called.
The age_timer would never be stopped, and the multicast group
would never left, and the forwarding table will leak memory.


commit b7153984074e51a50dad905871b705e0d67aa147
Author: Stephen Hemminger <stephen@networkplumber.org>
Date:   Mon Jun 17 14:16:09 2013 -0700

    vxlan: fix out of order operation on module removal
    
    If vxlan is removed with active vxlan's it would crash because
    rtnl_link_unregister (which calls vxlan_dellink), was invoked
    before unregister_pernet_device (which calls vxlan_stop).
    
    Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 284c6c0..d3005d3 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1771,8 +1771,8 @@ late_initcall(vxlan_init_module);
 
 static void __exit vxlan_cleanup_module(void)
 {
-	rtnl_link_unregister(&vxlan_link_ops);
 	unregister_pernet_device(&vxlan_net_ops);
+	rtnl_link_unregister(&vxlan_link_ops);
 	rcu_barrier();
 }
 module_exit(vxlan_cleanup_module);
