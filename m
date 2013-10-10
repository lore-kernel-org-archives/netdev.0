From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] openvswitch: fix vport-netdev unregister
Date: Thu, 10 Oct 2013 13:48:31 -0700
Message-ID: <CAMEtUuxH24G6pQtSFznrK7w5mdP3za4uQfKKEEaEngW4SJajbA@mail.gmail.com>
References: <1381288051-3607-1-git-send-email-ast@plumgrid.com>
	<CALnjE+p3MC7D9oYZ4VhH=fdOWSYcV6h9twnaZBocYnRdAEcpBg@mail.gmail.com>
	<CAMEtUuzVP0LQ_L2CrpoJgehP_bXwYhicW_HM2m-YOY6SN7RDxQ@mail.gmail.com>
	<CALnjE+pLon2DGc=MfrG7Tsu=p_uF9chK=TREJwK_TM2Um89p6Q@mail.gmail.com>
	<CAMEtUuzP1b_VNqP1texkrQ7kvCRxEukUoRz=Dj-pMX9gsO9AWw@mail.gmail.com>
	<CALnjE+oXJQoPG4io2JOn1zBbf7XtPKaBE+vHPNKXm2TBygvB5Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>, Jiri Pirko <jiri@resnulli.us>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:44517 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755996Ab3JJUsc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Oct 2013 16:48:32 -0400
Received: by mail-wi0-f169.google.com with SMTP id cb5so222556wib.4
        for <netdev@vger.kernel.org>; Thu, 10 Oct 2013 13:48:31 -0700 (PDT)
In-Reply-To: <CALnjE+oXJQoPG4io2JOn1zBbf7XtPKaBE+vHPNKXm2TBygvB5Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 10, 2013 at 11:21 AM, Pravin Shelar <pshelar@nicira.com> wrote:
> On Wed, Oct 9, 2013 at 11:26 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
>> On Wed, Oct 9, 2013 at 11:07 PM, Pravin Shelar <pshelar@nicira.com> wrote:
>>> On Wed, Oct 9, 2013 at 9:11 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
>>>> On Wed, Oct 9, 2013 at 8:02 PM, Pravin Shelar <pshelar@nicira.com> wrote:
>>>>> On Tue, Oct 8, 2013 at 8:07 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
>>>>>> The combination of two commits
>>>>>>
>>>>>> commit 8e4e1713e4
>>>>>> ("openvswitch: Simplify datapath locking.")
>>>>>>
>>>>>> and
>>>>>>
>>>>>> commit 2537b4dd0a
>>>>>> ("openvswitch:: link upper device for port devices")
>>>>>>
>>>>>> introduced a bug where upper_dev wasn't unlinked upon
>>>>>> netdev_unregister notification
>>>>>>
>>>>>> The following steps:
>>>>>>
>>>>>>   modprobe openvswitch
>>>>>>   ovs-dpctl add-dp test
>>>>>>   ip tuntap add dev tap1 mode tap
>>>>>>   ovs-dpctl add-if test tap1
>>>>>>   ip tuntap del dev tap1 mode tap
>>>>>>
>>>>>> are causing multiple warnings:
>>>>>> diff --git a/net/openvswitch/dp_notify.c b/net/openvswitch/dp_notify.c
>>>>>> index c323567..e9380bd 100644
>>>>>> --- a/net/openvswitch/dp_notify.c
>>>>>> +++ b/net/openvswitch/dp_notify.c
>>>>>> @@ -88,6 +88,11 @@ static int dp_device_event(struct notifier_block *unused, unsigned long event,
>>>>>>                 return NOTIFY_DONE;
>>>>>>
>>>>>>         if (event == NETDEV_UNREGISTER) {
>>>>>> +               /* rx_handler_unregister and upper_dev_unlink immediately */
>>>>>> +               if (dev->reg_state == NETREG_UNREGISTERING)
>>>>>> +                       ovs_netdev_unlink_dev(vport);
>>>>>> +
>>>>>
>>>>> Rather than doing vport destroy here, we can just unlink upper device
>>>>> and let workq do rest of work.
>>>>
>>>> isn't it what it's doing?
>>>
>>> I meant just call netdev_upper_dev_unlink() here in event handler and
>>> rest of vport destroy can be done in workq.
>>
>> netdev_upper_dev_unlink() without netdev_rx_handler_unregister() ?!
>> that's dangerous.
> why is it dangerous? ovs already had ref to net-device.

comment from dev.c:
                /* Notify protocols, that we are about to destroy
                   this device. They should clean all the things.
                */
                call_netdevice_notifiers(NETDEV_UNREGISTER, dev);

so here you're suggesting to just netdev_upper_dev_unlink() to silence
the warning,
but then do dev_set_promisc(-1) in workqueue?

well, as a minimum audit of promiscuity will be wrong.
ndo_change_rx_flags will be called after ndo_uninit,
all sorts of other cleanups are done.
I cannot track all possible scenarios, but it seems much safer to
cleanup everything possible
as soon as ovs received NETDEV_UNREGISTER event.

May be all these risks are worth taking, then please explain what is
the problem with the proposed patch?

Thanks
Alex
