From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: vxlan: error handling and error messages during vxlan_init
Date: Fri, 31 Oct 2014 16:11:11 -0200
Message-ID: <5453D0BF.9040404@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: stephen@networkplumber.org, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46032 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751417AbaJaSLU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Oct 2014 14:11:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen, Pravin,

Before Stephen's commit 1c51a9159ddefa5119724a4c7da3fd3ef44b68d5 (vxlan: fix 
race caused by dropping rtnl_unlock), if we failed to create the UDP socket 
for any reason, for example, the user would be informed right away. After that 
commit, the only option is to delete the vxlan and create it again, right? 
Because by simply calling ip link set vxlanX up is not enough:

/* Setup stats when device is created */
static int vxlan_init(struct net_device *dev)
{
     struct vxlan_dev *vxlan = netdev_priv(dev);
     struct vxlan_net *vn = net_generic(vxlan->net, vxlan_net_id);
     struct vxlan_sock *vs;

     dev->tstats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
     if (!dev->tstats)
         return -ENOMEM;

     spin_lock(&vn->sock_lock);
     vs = vxlan_find_sock(vxlan->net, (vxlan->flags & VXLAN_F_IPV6) ? AF_INET6 
: AF_INET, vxlan->dst_port);
     if (vs) {
         /* If we have a socket with same port already, reuse it */
         atomic_inc(&vs->refcnt);
         vxlan_vs_add_dev(vs, vxlan);
     } else {
         /* otherwise make new socket outside of RTNL */
         dev_hold(dev);
         queue_work(vxlan_wq, &vxlan->sock_work);       <--
     }
     spin_unlock(&vn->sock_lock);

     return 0;
}

Error is just ignored:

/* Scheduled at device creation to bind to a socket */
static void vxlan_sock_work(struct work_struct *work)
{
     struct vxlan_dev *vxlan = container_of(work, struct vxlan_dev, sock_work);
     struct net *net = vxlan->net;
     struct vxlan_net *vn = net_generic(net, vxlan_net_id);
     __be16 port = vxlan->dst_port;
     struct vxlan_sock *nvs;

     nvs = vxlan_sock_add(net, port, vxlan_rcv, NULL, false, vxlan->flags);
     spin_lock(&vn->sock_lock);
     if (!IS_ERR(nvs))
         vxlan_vs_add_dev(nvs, vxlan);
     spin_unlock(&vn->sock_lock);

     dev_put(vxlan->dev);
}

And we can't bring it up:

/* Start ageing timer and join group when device is brought up */
static int vxlan_open(struct net_device *dev)
{
         struct vxlan_dev *vxlan = netdev_priv(dev);
         struct vxlan_sock *vs = vxlan->vn_sock;

         /* socket hasn't been created */
         if (!vs)
                 return -ENOTCONN;      <---

And making this to retry the initialization doesn't seem a good idea.
Can we improve that error handling, somehow? As far as I could track, VXLAN is 
the only one that currently defers some initialization code during ndo_init.

Together with that, that initial commit did put some good error messages on 
this part of the code, like:

+       nvs = vxlan_socket_create(net, port);
+       if (IS_ERR(nvs)) {
+               netdev_err(vxlan->dev, "Can not create UDP socket, %ld\n",
+                          PTR_ERR(nvs));
+               goto out;
+       }

But Pravin's 9c2e24e16fbccf6cc1102442acc4a629f79615a7 commit removed them all. 
The only error message that is currently available is:

[root@localhost ~]# ip link set vxlan7 up
RTNETLINK answers: Transport endpoint is not connected

Nothing else is logged, dmesg or anywhere. (The actual error on this case was 
that it failed to create the UDP socket because the port was already in use..)

May we put them back? :) doesn't seem it would hurt OVS..

Thanks,
Marcelo
