From: Paolo Abeni <pabeni@redhat.com>
Subject: tc H/W offload issue with vxlan tunnels [was: nfp: flower vxlan
 tunnel offload]
Date: Wed, 27 Sep 2017 10:29:35 +0200
Message-ID: <1506500975.2867.19.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <gerlitz.or@gmail.com>, Jiri Benc <jbenc@redhat.com>,
        Simon Horman <simon.horman@netronome.com>,
        David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        oss-drivers@netronome.com, John Hurley <john.hurley@netronome.com>,
        Paul Blakey <paulb@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>, Roi Dayan <roid@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41700 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752007AbdI0I3i (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 27 Sep 2017 04:29:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Moving to a separate theread, since I think this is more related to the
flower core infrastructure than to the netrome patches.

On Wed, 2017-09-27 at 09:40 +0200, Jiri Pirko wrote:
> This kind of hooks are giving me nightmares. The code is screwed up as
> it is already. I'm currently working on conversion to callbacks. This
> part is handled in:
> https://github.com/jpirko/linux_mlxsw/commits/jiri_devel_egdevcb

Thanks for the pointer.

I skimmed quickly on the code and indeed it cleans this area a lot.
If I read it correctly the ('good') command:

tc filter add dev vxlan0 protocol ip parent ffff: flower enc_key_id 102 
   enc_dst_port 4789 src_ip 3.4.5.6 skip_sw action [...]

will generate a call to:

mlx5e_setup_tc(eth0, TC_SETUP_CLSFLOWER, &cls_flower) via:

fl_hw_replace_filter() ->
  tc_setup_cb_call() -> 
    tc_exts_setup_cb_egdev_call() ->
      tc_setup_cb_egdev_call() ->
        tcf_action_egdev_cb_call() ->
          mlx5e_rep_setup_tc_cb()

and the 'bad' command:

tc filter add dev eth0 protocol ip parent ffff: flower enc_key_id 102 \
   enc_dst_port 4789 src_ip 3.4.5.6 skip_sw action [...]

will also call:

mlx5e_setup_tc(eth0, TC_SETUP_CLSFLOWER, &cls_flower) via:

fl_hw_replace_filter() ->
  ndo_setup_tc()

So it looks like the H/W offload hook will still be called with the
same arguments in both case, and 'bad' rule will still be pushed to the
H/W as the driver itself has no way to distinct between the two
scenarios.

[ Note: I referred to the mlx hook just for convenience, should be the
same with any driver implementing the same APIs ]

Am I missing something?

Thanks,

Paolo
