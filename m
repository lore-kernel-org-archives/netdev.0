From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] openvswitch: fix vport-netdev unregister
Date: Fri, 11 Oct 2013 15:48:14 -0700
Message-ID: <CAMEtUuw1WgCi=D+sebumAaTaRNZEEh7Hqo-2RHVnCcpQnRL_DA@mail.gmail.com>
References: <1381288051-3607-1-git-send-email-ast@plumgrid.com>
	<CALnjE+p3MC7D9oYZ4VhH=fdOWSYcV6h9twnaZBocYnRdAEcpBg@mail.gmail.com>
	<CAMEtUuzVP0LQ_L2CrpoJgehP_bXwYhicW_HM2m-YOY6SN7RDxQ@mail.gmail.com>
	<CALnjE+pLon2DGc=MfrG7Tsu=p_uF9chK=TREJwK_TM2Um89p6Q@mail.gmail.com>
	<CAMEtUuzP1b_VNqP1texkrQ7kvCRxEukUoRz=Dj-pMX9gsO9AWw@mail.gmail.com>
	<CALnjE+oXJQoPG4io2JOn1zBbf7XtPKaBE+vHPNKXm2TBygvB5Q@mail.gmail.com>
	<CAMEtUuxH24G6pQtSFznrK7w5mdP3za4uQfKKEEaEngW4SJajbA@mail.gmail.com>
	<CALnjE+rgasL+XShQN20b9PkFNGq38+UoXX4uLogrZ2igAwfDew@mail.gmail.com>
	<CAMEtUuyEw81g8+68HUMpR1RERAA9rjL=WHRE58se83cdur67eg@mail.gmail.com>
	<CAEP_g=_meOUPrYc7S8rM4NwT_7qG1JZrHJkOg6CmbjDc-rFjAQ@mail.gmail.com>
	<CAMEtUuzf5UbZ_87DU+vSMbKzxLQgmuEfrf3NXQSz7vSF8LQTzw@mail.gmail.com>
	<CAEP_g=86Evh+U5NCOjtqPs-1kuwmkukPT9tmVNqbNxLPq7wZ4g@mail.gmail.com>
	<CAMEtUuwAJr0uMv4b_SfYG378p06os3bvT3kyvVGpKguAZbNcSw@mail.gmail.com>
	<CAEP_g=8JaTstBhpSSJnbFiLZ4V+jKwpomJy4ZSCe2trhYJBzTw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Pravin Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f52.google.com ([74.125.82.52]:48197 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752893Ab3JKWsQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Oct 2013 18:48:16 -0400
Received: by mail-wg0-f52.google.com with SMTP id m15so5009449wgh.31
        for <netdev@vger.kernel.org>; Fri, 11 Oct 2013 15:48:15 -0700 (PDT)
In-Reply-To: <CAEP_g=8JaTstBhpSSJnbFiLZ4V+jKwpomJy4ZSCe2trhYJBzTw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 11, 2013 at 3:02 PM, Jesse Gross <jesse@nicira.com> wrote:
> On Fri, Oct 11, 2013 at 1:03 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
>> On Fri, Oct 11, 2013 at 11:11 AM, Jesse Gross <jesse@nicira.com> wrote:
>>> On Thu, Oct 10, 2013 at 9:48 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
>>>> On Thu, Oct 10, 2013 at 8:56 PM, Jesse Gross <jesse@nicira.com> wrote:
>>>>> However, the check dev->reg_state in netdev_destroy() looks racy to
>>>>> me, as it could already be in NETREG_UNREGISTERED even if we already
>>>>> processed this device.
>>>>
>>>> you mean that netdev_destroy() will see reg_state == netreg_unregistered,
>>>> while dp_device_event() didn't see reg_state == netreg_unregistering yet?
>>>> or dp_device_event() saw it, proceeded to do unlink and
>>>> netdev_destroy() ran in parallel?
>>>> well, that's why reg_state == netreg_unregistering check in netdev_destroy()
>>>> is done with rtnl_lock() held.
>>>> reg_state cannot go into netreg_unregistered state skipping
>>>> netreg_unregistering and notifier.
>>>> therefore I don't think it's racy.
>>>>
>>>> In ovs_dp_notify_wq() you're checking for both unregistering and
>>>> unregistered and that makes
>>>> sense, since workq can run after unregistering notifier called and
>>>> netdev_run_todo()
>>>> already changed the state to unregistered.
>>>> But here it's not the case.
>>>
>>> ovs_dp_notify_wq() calls ovs_dp_detach_port(), which indirectly calls
>>> netdev_destroy() so it seems like it actually is the same case to me.
>>
>> yes. makes sense.
>> how about:
>> -       if (netdev_vport->dev->reg_state != NETREG_UNREGISTERING)
>> +       if (netdev_vport->dev->priv_flags & IFF_OVS_DATAPATH)
>
> Yes, this seems safer. Is the check for NETREG_UNREGISTERING in
> dp_device_event() still needed given that we are checking the event?

at least some check is needed, since NETDEV_UNREGISTER event can
be received again as rebroadcast with reg_state=netreg_unregistered
if wq got delayed.
Probably better to combine checks event == unreg and state == unregistering
under one 'if' to avoid unnecessary workq wakeup.
Or may be better to do it as
if (event == NETDEV_UNREGISTER && dev->priv_flags & IFF_OVS_DATAPATH) {
  ovs_netdev_detach_dev();
  queue_work();
}

since we're at it... what should be the behavior for namespace moves?
If dev attached to ovs and being moved into a different net namespace, I think
ovs should detach and forget the dev...

Today ovs ignores this notification and we may have ovs-dp in one net
and attached dev
in a different net.
So if you do:
   ovs-dpctl add-if test tap1
   ip link set tap1 netns 3512
and then try to remove tap1 inside the namespace:
   ip tuntap del dev tap1 mode tap
it will just hang:
[  852.572476] unregister_netdevice: waiting for tap1 to become free.
Usage count = 3
[  862.578769] unregister_netdevice: waiting for tap1 to become free.
Usage count = 3

>> ovs_netdev_destroy_dev() name instead ovs_netdev_unlink_dev() name?
>
> How about detach_dev?

that's better name indeed. Will respin V2.

Thanks
Alexei
