From: Francesco Ruggeri <fruggeri@aristanetworks.com>
Subject: Re: [PATCH 1/1] net: race condition when removing virtual net_device
Date: Mon, 9 Sep 2013 19:03:42 -0700
Message-ID: <CA+HUmGh1AH7afYu+V1nyXgAvtSRR48UJRz0D0NEEppdw3MN1KA@mail.gmail.com>
References: <1378768511-27866-1-git-send-email-fruggeri@aristanetworks.com>
	<20130909175706.39c1f210@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f176.google.com ([209.85.220.176]:34441 "EHLO
	mail-vc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753976Ab3IJCDn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Sep 2013 22:03:43 -0400
Received: by mail-vc0-f176.google.com with SMTP id lf11so4469495vcb.21
        for <netdev@vger.kernel.org>; Mon, 09 Sep 2013 19:03:42 -0700 (PDT)
In-Reply-To: <20130909175706.39c1f210@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 9, 2013 at 5:57 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
>
> On Mon,  9 Sep 2013 16:15:11 -0700
> Francesco Ruggeri <fruggeri@aristanetworks.com> wrote:
>
> > There is a race condition when removing a net_device while its net namespace
> > is also being removed.
> > This can result in a crash or other unpredictable behavior.
> > This is a sample scenario with veth, but the same applies to other virtual
> > devices such as vlan and macvlan.
> > veth pair v0-v1 is created, with v0 in namespace ns0 and v1 in ns1.
> > Process p0 deletes v0. v1 is also unregistered (in veth_dellink), so when p0
> > gets to netdev_run_todo both v0 and v1 are in net_todo_list, and they have both
> > been unlisted from their respective namespaces. If all references to v1 have not
> > already been dropped then netdev_run_todo/netdev_wait_allrefs will call netdev
> > notifiers for v1, releasing the rtnl lock between calls.
> > Now process p1 removes namespace ns1. v1 will not prevent this from happening
> > (in default_device_exit_batch) since it was already unlisted by p0.
> > Next time p0 invokes the notifiers for v1 any notifiers that use dev_net(v1)
> > will get a pointer to a namespace that has been or is being removed.
>
> Namespace's should be ref counted.


Namespaces are refcounted, but rollback_registered_many is also
invoked when a namespace is torn down. That is triggered in put_net
exactly by the namespace refcount dropping to 0, which then triggers
__put_net, cleanup_net, ops_exit_list, default_device_exit_batch and
unregister_netdevice_many. In that case using the namespace refcount
would not prevent the namespace from being deleted, since we already
passed the point (in put_net) where the refcount would have had that
effect. It would probably also not be straightforward to start using
again the namespace refcount in code that started under the premise
that the refcount had dropped to 0.
net_devices in a namespace do not seem to take references to the
namespace that they are in, and as far as I can tell the only thing
that prevents a namespace form being removed from under its
net_devices' feet is default_device_exit or default_device_exit_batch.
But unlist_netdevice creates a window where that logic fails.
In addition to this, in general we can have several instances of
netdev_run_todo running concurrently with any number of net_devices
from any number of net namespaces, possibly cross-referencing each
other. Some of these instances may be in the context of cleanup_net
and some may not.
Taking a refcount on the loopback_dev and making sure the looback_devs
are at the tail of net_todo_list in each of these instances was the
only way I could come up with to address all scenarios, but there may
be better ways to do it.

Thanks,
Francesco
