From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/1] net: race condition when removing virtual net_device
Date: Fri, 13 Sep 2013 18:46:08 -0700
Message-ID: <87d2ocrx9b.fsf@xmission.com>
References: <1379008796-2121-1-git-send-email-fruggeri@aristanetworks.com>
	<87txhp249u.fsf@xmission.com>
	<CA+HUmGgyCsc-er6iB_mqg9whMyaquGWinkHOQEuEHbFCYVrXBw@mail.gmail.com>
	<871u4t1d9t.fsf@xmission.com>
	<CA+HUmGjEC8eXT7BHm20uVOagJQbsqO9VZjmGSgmUvnrtEH-JYw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org
To: Francesco Ruggeri <fruggeri@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:56644 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756038Ab3INBqQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Sep 2013 21:46:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francesco Ruggeri <fruggeri@aristanetworks.com> writes:

> On Thu, Sep 12, 2013 at 10:50 PM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:

> To summarize your proposal:
> 1) Remove re-broadcasting of NETDEV_UNREGISTER and
> NETDEV_UNREGISTER_FINAL from netdev_wait_allrefs.

Forget that it isn't needed.  It would be nice but since it doesn't
solve the entire problem let's not go there.

> 2) If unregistering a net_device causes unregistering of other virtual
> devices (eg veth, macvlan, vlan) then move the virtual devices to the
> namespace of the original net_device.
>
> I do have some concerns about both correctness and feasibility of this approach.
>
> About 2), namespace dependent operations triggered by unregistering
> the virtual devices (eg rt_flush_dev, dst_dev_event/dst_ifdown and
> probably more) would not be done in the namespaces where they should.

Yes they will.  That is what dev_change_net_namespace does.
dev_change_net_namespace would not be correct if it did not do that.

Now dev_change_net_namespace is comparitively expensive so it may not be the
best approach but it is an approach that will work.

> I do urge you to take a second look at the approach that I proposed.
> All it does is make sure that a namespace loopback_dev is not removed
> until any devices unlisted from that namespace are also disposed of.
> That in turn prevents non-device pernet subsystems from exiting that
> namespace in ops_exit_list.

It was worth a second look.  I can not find anything wrong with your
patch but I can not convince myself that it is correct either.  The
moving around the loopback device in the net dev todo list to prevent
deadlock I can't imagine why you are doing that.

I think I would prefer something more explicit and less likely to break.
Perhaps something that keeps a network namespace from exiting while we
delete devices.  Using the loopback device like that looks fragile.
However it is very true that we require the loopback device to stay
around until all of the dst_ifdown calls in a network namespace are
made.

At least my original concern that you could be incrementing the count on
the loop back device when it had already reached zero can't be the case.

It would be very nice to have something that I could think through
easily and was robust to change.

Eric
