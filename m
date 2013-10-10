From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next] openvswitch: fix vport-netdev unregister
Date: Thu, 10 Oct 2013 11:21:26 -0700
Message-ID: <CALnjE+oXJQoPG4io2JOn1zBbf7XtPKaBE+vHPNKXm2TBygvB5Q@mail.gmail.com>
References: <1381288051-3607-1-git-send-email-ast@plumgrid.com>
	<CALnjE+p3MC7D9oYZ4VhH=fdOWSYcV6h9twnaZBocYnRdAEcpBg@mail.gmail.com>
	<CAMEtUuzVP0LQ_L2CrpoJgehP_bXwYhicW_HM2m-YOY6SN7RDxQ@mail.gmail.com>
	<CALnjE+pLon2DGc=MfrG7Tsu=p_uF9chK=TREJwK_TM2Um89p6Q@mail.gmail.com>
	<CAMEtUuzP1b_VNqP1texkrQ7kvCRxEukUoRz=Dj-pMX9gsO9AWw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>, Jiri Pirko <jiri@resnulli.us>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog125.obsmtp.com ([74.125.149.153]:32954 "HELO
	na3sys009aog125.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755602Ab3JJSV1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Oct 2013 14:21:27 -0400
Received: by mail-qe0-f41.google.com with SMTP id x7so1111074qeu.28
        for <netdev@vger.kernel.org>; Thu, 10 Oct 2013 11:21:26 -0700 (PDT)
In-Reply-To: <CAMEtUuzP1b_VNqP1texkrQ7kvCRxEukUoRz=Dj-pMX9gsO9AWw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 9, 2013 at 11:26 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> On Wed, Oct 9, 2013 at 11:07 PM, Pravin Shelar <pshelar@nicira.com> wrote:
>> On Wed, Oct 9, 2013 at 9:11 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
>>> On Wed, Oct 9, 2013 at 8:02 PM, Pravin Shelar <pshelar@nicira.com> wrote:
>>>> On Tue, Oct 8, 2013 at 8:07 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
>>>>> The combination of two commits
>>>>>
>>>>> commit 8e4e1713e4
>>>>> ("openvswitch: Simplify datapath locking.")
>>>>>
>>>>> and
>>>>>
>>>>> commit 2537b4dd0a
>>>>> ("openvswitch:: link upper device for port devices")
>>>>>
>>>>> introduced a bug where upper_dev wasn't unlinked upon
>>>>> netdev_unregister notification
>>>>>
>>>>> The following steps:
>>>>>
>>>>>   modprobe openvswitch
>>>>>   ovs-dpctl add-dp test
>>>>>   ip tuntap add dev tap1 mode tap
>>>>>   ovs-dpctl add-if test tap1
>>>>>   ip tuntap del dev tap1 mode tap
>>>>>
>>>>> are causing multiple warnings:
>>>>> diff --git a/net/openvswitch/dp_notify.c b/net/openvswitch/dp_notify.c
>>>>> index c323567..e9380bd 100644
>>>>> --- a/net/openvswitch/dp_notify.c
>>>>> +++ b/net/openvswitch/dp_notify.c
>>>>> @@ -88,6 +88,11 @@ static int dp_device_event(struct notifier_block *unused, unsigned long event,
>>>>>                 return NOTIFY_DONE;
>>>>>
>>>>>         if (event == NETDEV_UNREGISTER) {
>>>>> +               /* rx_handler_unregister and upper_dev_unlink immediately */
>>>>> +               if (dev->reg_state == NETREG_UNREGISTERING)
>>>>> +                       ovs_netdev_unlink_dev(vport);
>>>>> +
>>>>
>>>> Rather than doing vport destroy here, we can just unlink upper device
>>>> and let workq do rest of work.
>>>
>>> isn't it what it's doing?
>>
>> I meant just call netdev_upper_dev_unlink() here in event handler and
>> rest of vport destroy can be done in workq.
>
> netdev_upper_dev_unlink() without netdev_rx_handler_unregister() ?!
> that's dangerous.
why is it dangerous? ovs already had ref to net-device.

> If that is acceptable, then there was no reason to link them in the first place.
>
I do not see any harm in linking device hierarchy for ovs.

> notifier asks to unregister. imo the only acceptable deferred task
> here is to delay dev_put,
> since ovs structures are still referring to it.
