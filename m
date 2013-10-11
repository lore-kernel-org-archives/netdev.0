From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] openvswitch: fix vport-netdev unregister
Date: Fri, 11 Oct 2013 13:03:05 -0700
Message-ID: <CAMEtUuwAJr0uMv4b_SfYG378p06os3bvT3kyvVGpKguAZbNcSw@mail.gmail.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Pravin Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:36024 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759272Ab3JKUDH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Oct 2013 16:03:07 -0400
Received: by mail-wi0-f170.google.com with SMTP id l12so1714167wiv.3
        for <netdev@vger.kernel.org>; Fri, 11 Oct 2013 13:03:06 -0700 (PDT)
In-Reply-To: <CAEP_g=86Evh+U5NCOjtqPs-1kuwmkukPT9tmVNqbNxLPq7wZ4g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 11, 2013 at 11:11 AM, Jesse Gross <jesse@nicira.com> wrote:
> On Thu, Oct 10, 2013 at 9:48 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
>> On Thu, Oct 10, 2013 at 8:56 PM, Jesse Gross <jesse@nicira.com> wrote:
>>> However, the check dev->reg_state in netdev_destroy() looks racy to
>>> me, as it could already be in NETREG_UNREGISTERED even if we already
>>> processed this device.
>>
>> you mean that netdev_destroy() will see reg_state == netreg_unregistered,
>> while dp_device_event() didn't see reg_state == netreg_unregistering yet?
>> or dp_device_event() saw it, proceeded to do unlink and
>> netdev_destroy() ran in parallel?
>> well, that's why reg_state == netreg_unregistering check in netdev_destroy()
>> is done with rtnl_lock() held.
>> reg_state cannot go into netreg_unregistered state skipping
>> netreg_unregistering and notifier.
>> therefore I don't think it's racy.
>>
>> In ovs_dp_notify_wq() you're checking for both unregistering and
>> unregistered and that makes
>> sense, since workq can run after unregistering notifier called and
>> netdev_run_todo()
>> already changed the state to unregistered.
>> But here it's not the case.
>
> ovs_dp_notify_wq() calls ovs_dp_detach_port(), which indirectly calls
> netdev_destroy() so it seems like it actually is the same case to me.

yes. makes sense.
how about:
-       if (netdev_vport->dev->reg_state != NETREG_UNREGISTERING)
+       if (netdev_vport->dev->priv_flags & IFF_OVS_DATAPATH)

or you would prefer (state != unregistering && state != unregistered)
check instead?

ovs_netdev_destroy_dev() name instead ovs_netdev_unlink_dev() name?

Thanks
Alexei
