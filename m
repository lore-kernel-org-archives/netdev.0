From: Francesco Ruggeri <fruggeri@aristanetworks.com>
Subject: Re: [PATCH 1/1] net: race condition when removing virtual net_device
Date: Fri, 13 Sep 2013 10:54:26 -0700
Message-ID: <CA+HUmGjEC8eXT7BHm20uVOagJQbsqO9VZjmGSgmUvnrtEH-JYw@mail.gmail.com>
References: <1379008796-2121-1-git-send-email-fruggeri@aristanetworks.com>
	<87txhp249u.fsf@xmission.com>
	<CA+HUmGgyCsc-er6iB_mqg9whMyaquGWinkHOQEuEHbFCYVrXBw@mail.gmail.com>
	<871u4t1d9t.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f182.google.com ([209.85.128.182]:39560 "EHLO
	mail-ve0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751529Ab3IMRy2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Sep 2013 13:54:28 -0400
Received: by mail-ve0-f182.google.com with SMTP id oy12so1270463veb.13
        for <netdev@vger.kernel.org>; Fri, 13 Sep 2013 10:54:28 -0700 (PDT)
In-Reply-To: <871u4t1d9t.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 12, 2013 at 10:50 PM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
> Francesco Ruggeri <fruggeri@aristanetworks.com> writes:
>
>> That would be great. There would still be one scenario to take care of though:
>>
>> - veth interfaces v0 and v1 are in namespaces ns0 and ns1.
>> - process p0 unregisters v0, which also causes v1 to be unregistered.
>> When p0 enters netdev_run_todo both v0 and v1 are in net_todo_list and
>> have been unlisted from their namespaces.
>> - then in p0's netdev_run_todo:
>
> So I looked at this a little more and this problem appears largely
> specific to veth.  In the normal case the caller of dellink has to hold
> a reference to the network namespace to find the device to delete.
>
> So I think the solution is just to warp the interface of the second
> device into the network namespace of the device we are actually
> deleting.
>
> I will buy that similar situations can happen with other virtual devices
> that have one foot in two network namespaces, and I expect the same
> solution will apply.
>
> So the patch below looks like the solution.  If there is more than one
> device that needs this treatment perhaps the code should be moved
> into a helper function rather than expanded inline.
>
> Does this look like it will fix your issue?
>
> Eric
>

To summarize your proposal:
1) Remove re-broadcasting of NETDEV_UNREGISTER and
NETDEV_UNREGISTER_FINAL from netdev_wait_allrefs.
2) If unregistering a net_device causes unregistering of other virtual
devices (eg veth, macvlan, vlan) then move the virtual devices to the
namespace of the original net_device.

I do have some concerns about both correctness and feasibility of this approach.

About 2), namespace dependent operations triggered by unregistering
the virtual devices (eg rt_flush_dev, dst_dev_event/dst_ifdown and
probably more) would not be done in the namespaces where they should.

About the feasibility of 1), consider just as an example dst_dev_event
in NETDEV_UNREGISTER_FINAL. dst_dev_event will not process dst->dev
unless the dst_entry is already in dst_garbage.list, ie unless it has
already been dst_free'd or dst_release'd. But since destroying
resources is often delayed to workqueues or to one of several garbage
collection lists, can we guarantee that one broadcast of
NETDEV_UNREGISTER_FINAL is always enough? There may be similar cases
with NETDEV_UNREGISTER.

I do urge you to take a second look at the approach that I proposed.
All it does is make sure that a namespace loopback_dev is not removed
until any devices unlisted from that namespace are also disposed of.
That in turn prevents non-device pernet subsystems from exiting that
namespace in ops_exit_list.
Logically it is enforcing the right behavior (namely non-device pernet
subsystems should not exit a namespace until all devices in that
namespace - listed or unlisted - have been properly disposed of) and
it correctly supports existing code, such as rt_flush_dev and
dst_ifdown, which relies on the correct loopback_dev to be there.

Francesco
