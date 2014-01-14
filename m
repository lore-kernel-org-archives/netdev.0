From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next] net: make dev_set_mtu() honor notification
 return code
Date: Tue, 14 Jan 2014 13:13:54 +0100
Message-ID: <20140114121354.GI4132@redhat.com>
References: <1389358097-5396-1-git-send-email-vfalico@redhat.com>
 <20140113.151855.1046745397621207165.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, jiri@resnulli.us, edumazet@google.com,
	alexander.h.duyck@intel.com, nicolas.dichtel@6wind.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29155 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751874AbaANMRE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 07:17:04 -0500
Content-Disposition: inline
In-Reply-To: <20140113.151855.1046745397621207165.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 13, 2014 at 03:18:55PM -0800, David Miller wrote:
>From: Veaceslav Falico <vfalico@redhat.com>
>Date: Fri, 10 Jan 2014 13:48:17 +0100
>
>> Currently, after changing the MTU for a device, dev_set_mtu() calls
>> NETDEV_CHANGEMTU notification, however doesn't verify it's return code -
>> which can be NOTIFY_BAD - i.e. some of the net notifier blocks refused this
>> change, and continues nevertheless.
>>
>> To fix this, verify the return code, and if it's an error - then revert the
>> MTU to the original one, and pass the error code.
>>
>> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
>
>This is really a precariously designed code path.
>
>If one of the notifiers says NOTIFY_BAD, well we've already changed
>dev->mtu, therefore what if a packet got sent during this time?
>
>Whoever the NOTIFY_BAD signaller is, obviously cannot handle an MTU
>setting which we've already set in the netdev.  So allowing it's a
>terribly idea to allow visibility of the new MTU value until we can be
>sure everyone can handle it.
>
>The problem is that we really need a transaction of some sort to fix
>this properly.  First, we'd need to ask all the notifiers if they
>can handle the new MTU, then we somehow atomically set netdev->mtu
>and have the notifiers commit their own state changes.

Yeah, but I can't think of a method to atomically set it for both netdev
and its notifiers... As in, for example, bridge (but not only) takes the
lowest MTU of its ports.

>
>Then we'll have the stick issue of what to do if a notifier is
>unregistered between the check and the commit. :-)

Maybe you've meant 'registered between ...' ? :-) Anyway, I guess
dev_set_mtu() should always be called under RTNL, and this way we won't
have these problems. Though I might be wrong, everyone seems playing with
MTU the way they want.

>
>Your patch is an improvement so I will apply it, this stuff really
>is full of holes still.

One (least intrusive) approach would be to add NETDEV_PRECHANGEMTU, which
would be used to verify if the notifiers all agree with changing, and leave
the NETDEV_CHANGEMTU fail only when something really bad happened. That's
your idea, basically.

As, currently, only team can signal NOTIFY_BAD on mtu change, it's really
easy to implement. What do you think?

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 736050d..4e50e04 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -2850,7 +2850,7 @@ static int team_device_event(struct notifier_block *unused,
  	case NETDEV_FEAT_CHANGE:
  		team_compute_features(port->team);
  		break;
-	case NETDEV_CHANGEMTU:
+	case NETDEV_PRECHANGEMTU:
  		/* Forbid to change mtu of underlaying device */
  		return NOTIFY_BAD;
  	case NETDEV_PRE_TYPE_CHANGE:
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a2a70cc..7e023c4 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1731,6 +1731,7 @@ struct pcpu_sw_netstats {
  #define NETDEV_JOIN		0x0014
  #define NETDEV_CHANGEUPPER	0x0015
  #define NETDEV_RESEND_IGMP	0x0016
+#define NETDEV_PRECHANGEMTU	0x0017
  
  int register_netdevice_notifier(struct notifier_block *nb);
  int unregister_netdevice_notifier(struct notifier_block *nb);
diff --git a/net/core/dev.c b/net/core/dev.c
index 87312dc..096d4dd 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5332,6 +5332,10 @@ int dev_set_mtu(struct net_device *dev, int new_mtu)
  	if (!netif_device_present(dev))
  		return -ENODEV;
  
+	err = call_netdevice_notifiers(NETDEV_PRECHANGEMTU, dev);
+	if (!err)
+		return notifier_to_errno(err);
+
  	orig_mtu = dev->mtu;
  	err = __dev_set_mtu(dev, new_mtu);
  

>
>Thanks.
>
