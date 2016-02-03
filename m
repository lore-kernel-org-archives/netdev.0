From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next 2/4] net: dev: add batching to net_device
 notifiers
Date: Wed, 3 Feb 2016 10:08:26 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1602030950280.1736@ja.home.ssi.bg>
References: <1454365952-10324-1-git-send-email-noureddine@arista.com> <1454365952-10324-3-git-send-email-noureddine@arista.com> <alpine.LFD.2.11.1602022219010.2006@ja.home.ssi.bg> <CAO7SqHBKrPvaEhLeEJsCrjYEiPcZ6MpyfwY43NwhGLWhW4VTNQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Network Development <netdev@vger.kernel.org>
To: Salam Noureddine <noureddine@arista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:58437 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754466AbcBCIJE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Feb 2016 03:09:04 -0500
In-Reply-To: <CAO7SqHBKrPvaEhLeEJsCrjYEiPcZ6MpyfwY43NwhGLWhW4VTNQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 2 Feb 2016, Salam Noureddine wrote:

> On Tue, Feb 2, 2016 at 12:55 PM, Julian Anastasov <ja@ssi.bg> wrote:
> >
> >                         If the rule is once per net, the above call...
> >
> >>               }
> >
> >                 should be here:
> >
> >                 call_netdevice_notifier(nb, NETDEV_UNREGISTER_BATCH,
> >                                         net->loopback_dev);
> >
> >         and also once after outroll label?:
> 
> That's a good optimization to add. I was mostly focusing on the device
> unregister path.

	Yes, the idea is to avoid NETDEV_UNREGISTER_BATCH for
every dev. And not to forget to call it for every net.
In this case it is a cleanup path after failure.

> >>                       call_netdevice_notifier(nb, NETDEV_UNREGISTER, dev);
> >> +                     call_netdevice_notifier(nb, NETDEV_UNREGISTER_BATCH,
> >> +                                             dev);
> >
> >                         Above call...
> >
> >>               }
> >
> >                 should be here, for net->loopback_dev?
> > Also, is it ok to call NETDEV_DOWN_BATCH many times, as result,
> > sometimes after NETDEV_UNREGISTER?
> 
> Same here, I can add this optimization. I think it is fine to call the
> BATCH notifiers
> for every interface. It is just better to do it for many interfaces at
> the same time.

	Agreed

> >> +     list_for_each_entry_safe(net, net_tmp, &net_head, event_list) {
> >> +             call_netdevice_notifiers(NETDEV_UNREGISTER_BATCH,
> >> +                                      net->loopback_dev);
> >> +             net_del_event_list(net);
> >> +     }
> >> +
> >
> >         NETDEV_UNREGISTER* should not be called before
> > following synchronize_net and NETDEV_UNREGISTER. May be
> > we should split the loop: loop (dev_shutdown+NETDEV_UNREGISTER)
> > followed by above NETDEV_UNREGISTER_BATCH then again the
> > loop for all remaining calls
> >
> >>       synchronize_net();
> 
> The call to NETDEV_UNREGISTER_BATCH is actually after NETDEV_UNREGISTER,
> it seems the other way around in the patch because it is showing part
> of netdev_wait_allrefs
> and not rollback_registered_may.

	Aha, I see, it is after NETDEV_UNREGISTER but may be
the above loop should be changed to two loops so that
NETDEV_UNREGISTER_BATCH is called exactly after all
NETDEV_UNREGISTER and before all dev_*_flush and
ndo_uninit calls to avoid any risks. I mean:

        synchronize_net();

	First part of loop:

        list_for_each_entry(dev, head, unreg_list) {
                /* Shutdown queueing discipline. */
                dev_shutdown(dev);

                /* Notify protocols, that we are about to destroy
                   this device. They should clean all the things.
                */
                call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
	}

	This is the same NETDEV_UNREGISTER_BATCH logic:

+       list_for_each_entry(dev, head, unreg_list) {
+               net_add_event_list(&net_head, dev_net(dev));
+       }
+       list_for_each_entry_safe(net, net_tmp, &net_head, event_list) {
+               call_netdevice_notifiers(NETDEV_UNREGISTER_BATCH,
+                                        net->loopback_dev);
+               net_del_event_list(net);
+       }

	Second part of the loop:

        list_for_each_entry(dev, head, unreg_list) {
                struct sk_buff *skb = NULL;

		if (!dev->rtnl_link_ops ||
		...

Regards
