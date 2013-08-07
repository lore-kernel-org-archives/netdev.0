From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [Patch net-next] vxlan: fix a soft lockup in vxlan module
 removal
Date: Wed, 7 Aug 2013 08:31:50 -0700
Message-ID: <20130807083150.02a3d3c4@nehalam.linuxnetplumber.net>
References: <1375865002-8732-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:59108 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753666Ab3HGPbz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 11:31:55 -0400
Received: by mail-pd0-f174.google.com with SMTP id 10so1513387pdc.5
        for <netdev@vger.kernel.org>; Wed, 07 Aug 2013 08:31:55 -0700 (PDT)
In-Reply-To: <1375865002-8732-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  7 Aug 2013 16:43:22 +0800
Cong Wang <amwang@redhat.com> wrote:

> From: Cong Wang <amwang@redhat.com>
> 
> This is a regression introduced by:
> 
> 	commit fe5c3561e6f0ac7c9546209f01351113c1b77ec8
> 	Author: stephen hemminger <stephen@networkplumber.org>
> 	Date:   Sat Jul 13 10:18:18 2013 -0700
> 
> 	    vxlan: add necessary locking on device removal
> 
> The problem is that vxlan_dellink(), which is called with RTNL lock
> held, tries to flush the workqueue synchronously, but apparently
> igmp_join and igmp_leave work need to hold RTNL lock too, therefore we
> have a soft lockup! 
> 
> As suggested by Stephen, probably the flush_workqueue can just be
> removed and let the normal refcounting work. The workqueue has a
> reference to device and socket, therefore the cleanups should work
> correctly.
> 
> Suggested-by: Stephen Hemminger <stephen@networkplumber.org>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: David S. Miller <davem@davemloft.net>
> Tested-by: Cong Wang <amwang@redhat.com>
> Signed-off-by: Cong Wang <amwang@redhat.com>
> 
> ---
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 8bf31d9..c51ef9b 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -1837,8 +1837,6 @@ static void vxlan_dellink(struct net_device *dev, struct list_head *head)
>  	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
>  	struct vxlan_dev *vxlan = netdev_priv(dev);
>  
> -	flush_workqueue(vxlan_wq);
> -
>  	spin_lock(&vn->sock_lock);
>  	hlist_del_rcu(&vxlan->hlist);
>  	spin_unlock(&vn->sock_lock);

Thanks for testing this.

Acked-by: Stephen Hemminger <stephen@networkplumber.org>
