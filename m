From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/1] net: race condition when removing virtual net_device
Date: Thu, 12 Sep 2013 22:50:06 -0700
Message-ID: <871u4t1d9t.fsf@xmission.com>
References: <1379008796-2121-1-git-send-email-fruggeri@aristanetworks.com>
	<87txhp249u.fsf@xmission.com>
	<CA+HUmGgyCsc-er6iB_mqg9whMyaquGWinkHOQEuEHbFCYVrXBw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org
To: Francesco Ruggeri <fruggeri@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:60269 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751781Ab3IMFuR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Sep 2013 01:50:17 -0400
In-Reply-To: <CA+HUmGgyCsc-er6iB_mqg9whMyaquGWinkHOQEuEHbFCYVrXBw@mail.gmail.com>
	(Francesco Ruggeri's message of "Thu, 12 Sep 2013 14:48:19 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francesco Ruggeri <fruggeri@aristanetworks.com> writes:

> That would be great. There would still be one scenario to take care of though:
>
> - veth interfaces v0 and v1 are in namespaces ns0 and ns1.
> - process p0 unregisters v0, which also causes v1 to be unregistered.
> When p0 enters netdev_run_todo both v0 and v1 are in net_todo_list and
> have been unlisted from their namespaces.
> - then in p0's netdev_run_todo:

So I looked at this a little more and this problem appears largely
specific to veth.  In the normal case the caller of dellink has to hold
a reference to the network namespace to find the device to delete.

So I think the solution is just to warp the interface of the second
device into the network namespace of the device we are actually
deleting.

I will buy that similar situations can happen with other virtual devices
that have one foot in two network namespaces, and I expect the same
solution will apply.

So the patch below looks like the solution.  If there is more than one
device that needs this treatment perhaps the code should be moved
into a helper function rather than expanded inline.

Does this look like it will fix your issue?

Eric


diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index da86652..5922066 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -423,6 +423,19 @@ static void veth_dellink(struct net_device *dev, struct list_head *head)
        unregister_netdevice_queue(dev, head);
 
        if (peer) {
+               struct net *net = dev_net(dev);
+               if (dev_net(peer) != net) {
+                       /* Move the peer to the same net to avoid teardown races */
+                       char peer_name[IFNAMSIZ];
+                       int err;
+                       snprintf(fb_name, IFNAMSIZ, "dev%d", peer->ifindex);
+                       err = dev_change_net_namespace(peer, net, peer_name);
+                       if (err) {
+                               pr_emerg("%s: failed to move %s to peers net: %d\n",
+                                        __func__, peer->name, err);
+                               BUG();
+                       }
+               }
                priv = netdev_priv(peer);
                RCU_INIT_POINTER(priv->peer, NULL);
                unregister_netdevice_queue(peer, head);
