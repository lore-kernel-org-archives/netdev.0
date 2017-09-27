From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: tc H/W offload issue with vxlan tunnels [was: nfp: flower vxlan
 tunnel offload]
Date: Wed, 27 Sep 2017 11:17:00 +0200
Message-ID: <20170927091700.GC1944@nanopsycho.orion>
References: <1506500975.2867.19.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <gerlitz.or@gmail.com>, Jiri Benc <jbenc@redhat.com>,
        Simon Horman <simon.horman@netronome.com>,
        David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        oss-drivers@netronome.com, John Hurley <john.hurley@netronome.com>,
        Paul Blakey <paulb@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>, Roi Dayan <roid@mellanox.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f182.google.com ([209.85.128.182]:45495 "EHLO
        mail-wr0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752203AbdI0JRC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 05:17:02 -0400
Received: by mail-wr0-f182.google.com with SMTP id m18so15271814wrm.2
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 02:17:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1506500975.2867.19.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Sep 27, 2017 at 10:29:35AM CEST, pabeni@redhat.com wrote:
>Hi,
>
>Moving to a separate theread, since I think this is more related to the
>flower core infrastructure than to the netrome patches.
>
>On Wed, 2017-09-27 at 09:40 +0200, Jiri Pirko wrote:
>> This kind of hooks are giving me nightmares. The code is screwed up as
>> it is already. I'm currently working on conversion to callbacks. This
>> part is handled in:
>> https://github.com/jpirko/linux_mlxsw/commits/jiri_devel_egdevcb
>
>Thanks for the pointer.
>
>I skimmed quickly on the code and indeed it cleans this area a lot.
>If I read it correctly the ('good') command:
>
>tc filter add dev vxlan0 protocol ip parent ffff: flower enc_key_id 102 
>   enc_dst_port 4789 src_ip 3.4.5.6 skip_sw action [...]

I suppose "action mirred redirect eth0". Then yes, it will generate the
callpath you described below.

>
>will generate a call to:
>
>mlx5e_setup_tc(eth0, TC_SETUP_CLSFLOWER, &cls_flower) via:
>
>fl_hw_replace_filter() ->
>  tc_setup_cb_call() -> 
>    tc_exts_setup_cb_egdev_call() ->
>      tc_setup_cb_egdev_call() ->
>        tcf_action_egdev_cb_call() ->
>          mlx5e_rep_setup_tc_cb()
>
>and the 'bad' command:
>
>tc filter add dev eth0 protocol ip parent ffff: flower enc_key_id 102 \
>   enc_dst_port 4789 src_ip 3.4.5.6 skip_sw action [...]
>
>will also call:
>
>mlx5e_setup_tc(eth0, TC_SETUP_CLSFLOWER, &cls_flower) via:
>
>fl_hw_replace_filter() ->
>  ndo_setup_tc()

Sure. You are adding a rule to eth0, the call goes down to eth0 driver.
I'm missing why is it a problem? Why the call should not go down to the
eth0 driver?


>
>So it looks like the H/W offload hook will still be called with the
>same arguments in both case, and 'bad' rule will still be pushed to the
>H/W as the driver itself has no way to distinct between the two
>scenarios.

Why "bad"?

Regarding the distinction, driver knows if user add a rule directly to
the eth0, or if the eth0 is egress device in the action. Those are 2
separete driver entrypoints - of course, talking about code with my
changes.


>
>[ Note: I referred to the mlx hook just for convenience, should be the
>same with any driver implementing the same APIs ]
>
>Am I missing something?
>
>Thanks,
>
>Paolo
