From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [Patch net-next] vxlan: do not use vxlan_net before checking
 event type
Date: Fri, 17 Jan 2014 09:39:46 +0100
Message-ID: <52D8EC52.6040707@redhat.com>
References: <1389932410-21080-1-git-send-email-xiyou.wangcong@gmail.com> <52D8B17A.6030301@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16683 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751064AbaAQIjw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jan 2014 03:39:52 -0500
In-Reply-To: <52D8B17A.6030301@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/17/2014 05:28 AM, Fan Du wrote:
> Hi, Cong
>
> On 2014=E5=B9=B401=E6=9C=8817=E6=97=A5 12:20, Cong Wang wrote:
>> When cloning a netns, loopback device will be registered
>> and therefore an event will be notified. Of course
>> vxlan doesn't care about it, therefore should check if it
>> is NETDEV_UNREGISTER before getting the vxlan_net struct.
>> Otherwise, vxlan_net is probably not initialized yet at
>> this point.
>
> I'm bit new to vxlan, but in vxlan_init_module
>
> register_pernet_device is called before register_netdevice_notifier.
> By my understanding once register_pernet_device is called,
> then subsequent vxlan_notifier_block callback see a valid vxlan_net_i=
d.
> I mean execute vxlan_notifier_block callback indicates a valid vxlan_=
net_id,
> or I miss somewhere else.

That was also my understanding, but apparently I missed that.
Very sorry. Then, it would have been enough to just provide this:

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index a2dee80..d6ec71f 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2681,10 +2681,12 @@ static int vxlan_lowerdev_event(struct notifier=
_block *unused,
  				unsigned long event, void *ptr)
  {
  	struct net_device *dev =3D netdev_notifier_info_to_dev(ptr);
-	struct vxlan_net *vn =3D net_generic(dev_net(dev), vxlan_net_id);
+	struct vxlan_net *vn;

-	if (event =3D=3D NETDEV_UNREGISTER)
+	if (event =3D=3D NETDEV_UNREGISTER) {
+		vn =3D net_generic(dev_net(dev), vxlan_net_id);
  		vxlan_handle_lowerdev_unregister(vn, dev);
+	}

  	return NOTIFY_DONE;
  }
