From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] vxlan: Fix vs->vni_list locking.
Date: Wed, 10 Jul 2013 16:25:09 -0700
Message-ID: <20130710162509.75bbb922@nehalam.linuxnetplumber.net>
References: <1373493884-7915-1-git-send-email-pshelar@nicira.com>
	<20130710155840.73e8da09@nehalam.linuxnetplumber.net>
	<CALnjE+rO7Npw=rU_VL7T1pPDdFBKXB3KpVbpf_jQ0cJ6+ah1nQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:63615 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753834Ab3GJXZN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jul 2013 19:25:13 -0400
Received: by mail-pa0-f54.google.com with SMTP id kx10so7255419pab.27
        for <netdev@vger.kernel.org>; Wed, 10 Jul 2013 16:25:13 -0700 (PDT)
In-Reply-To: <CALnjE+rO7Npw=rU_VL7T1pPDdFBKXB3KpVbpf_jQ0cJ6+ah1nQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 10 Jul 2013 16:08:38 -0700
Pravin Shelar <pshelar@nicira.com> wrote:

> On Wed, Jul 10, 2013 at 3:58 PM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:
> > On Wed, 10 Jul 2013 15:04:44 -0700
> > Pravin B Shelar <pshelar@nicira.com> wrote:
> >
> >> Use rtnl lock to protect vs->vni_list updates.
> >>
> >> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> >> ---
> >
> > I don't think this is necessary. I intentionally changed the
> > locking when socket management was moved to a work queue.
> > The vxlan_net socket lock is held there already, and finer grain.
> 
> what abt vxlan_dellink()?
> it is deleting vxlan-dev from hash table without lock.

Ok, then this should fix it.

--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1768,8 +1768,12 @@ static int vxlan_newlink(struct net *net
 static void vxlan_dellink(struct net_device *dev, struct list_head *head)
 {
        struct vxlan_dev *vxlan = netdev_priv(dev);
+       struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
 
+       spin_lock(&vn->sock_lock);
        hlist_del_rcu(&vxlan->hlist);
+       spin_unlock(&vn->sock_lock);
+
        list_del(&vxlan->next);
        unregister_netdevice_queue(dev, head);
 }
