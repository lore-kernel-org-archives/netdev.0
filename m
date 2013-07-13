From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net] vxlan: add necessary locking on device removal
Date: Sat, 13 Jul 2013 12:21:52 -0700
Message-ID: <CALnjE+oDwU46NiK-AyB-dJZVrWT-pot_v+obv+MxgZU0xNwbRw@mail.gmail.com>
References: <1373493884-7915-1-git-send-email-pshelar@nicira.com>
	<20130710155840.73e8da09@nehalam.linuxnetplumber.net>
	<CALnjE+rO7Npw=rU_VL7T1pPDdFBKXB3KpVbpf_jQ0cJ6+ah1nQ@mail.gmail.com>
	<20130713101818.0d4fa8e0@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog113.obsmtp.com ([74.125.149.209]:39536 "HELO
	na3sys009aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1758224Ab3GMTVy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Jul 2013 15:21:54 -0400
Received: by mail-qe0-f49.google.com with SMTP id cz11so5638517qeb.8
        for <netdev@vger.kernel.org>; Sat, 13 Jul 2013 12:21:53 -0700 (PDT)
In-Reply-To: <20130713101818.0d4fa8e0@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 13, 2013 at 10:18 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> The socket management is now done in workqueue (outside of RTNL)
> and protected by vn->sock_lock. There were two possible bugs, first
> the vxlan device was removed from the VNI hash table per socket without
> holding lock. And there was a race when device is created and the workqueue
> could run after deletion.
>
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
>
> --- a/drivers/net/vxlan.c       2013-07-08 16:31:50.080744429 -0700
> +++ b/drivers/net/vxlan.c       2013-07-10 20:15:47.337653899 -0700
> @@ -1767,9 +1767,15 @@ static int vxlan_newlink(struct net *net
>
>  static void vxlan_dellink(struct net_device *dev, struct list_head *head)
>  {
> +       struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
>         struct vxlan_dev *vxlan = netdev_priv(dev);
>
> +       flush_workqueue(vxlan_wq);
> +
Doesn't this create dependency on sock_work thread while holding RTNL.
If so it can result in deadlock.

> +       spin_lock(&vn->sock_lock);
>         hlist_del_rcu(&vxlan->hlist);
> +       spin_unlock(&vn->sock_lock);
> +
>         list_del(&vxlan->next);
>         unregister_netdevice_queue(dev, head);
>  }
