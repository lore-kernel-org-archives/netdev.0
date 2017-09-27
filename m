From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH v2 net-next 0/2] net/sched: support tunnel options in cls_flower and act_tunnel_key
Date: Wed, 27 Sep 2017 10:16:32 +0200
Message-ID: <1506500194-17637-1-git-send-email-simon.horman@netronome.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
        oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>, Jiri Pirko <jiri@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f181.google.com ([209.85.216.181]:54859 "EHLO
        mail-qt0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751739AbdI0IQs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 04:16:48 -0400
Received: by mail-qt0-f181.google.com with SMTP id i13so12814800qtc.11
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 01:16:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow the flower classifier to match on tunnel options and the
tunnel key action to set them.

Tunnel options are a bytestring of up to 256 bytes.
The flower classifier matching with an optional bitwise mask.
Tunnel implementations may support more or less options,
or none at all.


Discussion stemming from review of RFC:

This feature is to be used in conjunction with tunnels in collect metadata
(external) mode. As I understand it there are three tunnel netdevs that use
options metadata in the kernel at this time.

* Geneve

  In the case of Geneve options are TLVs[1]. My reading is that in collect
  metadata mode the kernel does not appear to do anything other than pass
  them around as a bytestring.

  [1] https://tools.ietf.org/html/draft-ietf-nvo3-geneve-05#section-3.5

* VXLAN-GBP

  In the case of VXLAN-GBP on RX in collect metadata mode options are used
  to carry information parsed in vxlan_parse_gbp_hdr() from the VXLAN Group
  Based Policy Extension[2]. On RX the options data is used to create an
  extension (header) by vxlan_build_gbp_hdr().

  [2] https://tools.ietf.org/html/draft-smith-vxlan-group-policy-03#section-2.1

* ERSPAN (GRE)

  In the case of ERSPAN, which is a variant of GRE, on RX in collect
  metadata mode options are used to carry the index parsed from the ERSPAN
  Type II feature header[3] in erspan_rcv().  The converse is true on TX
  and is handled by erspan_fb_xmit().

  [3] https://tools.ietf.org/html/draft-foschiano-erspan-03#section-4.2

Users of options:

* There are eBPF hooks to allow getting on and setting tunnel metadata:
  bpf_skb_set_tunnel_opt, bpf_skb_get_tunnel_opt.

* Open vSwitch is able to match and set Geneve and VXLAN-GBP options.

Neither of the above appear to assume any structure for the data.


Changes since RFC:
* Drop RFC prefix
* Correct changelogs and enhance cover letter.


Simon Horman (2):
  net/sched: add tunnel option support to act_tunnel_key
  net/sched: allow flower to match tunnel options

 include/net/flow_dissector.h              | 13 ++++++++++++
 include/uapi/linux/pkt_cls.h              |  3 +++
 include/uapi/linux/tc_act/tc_tunnel_key.h |  1 +
 net/sched/act_tunnel_key.c                | 26 ++++++++++++++++++-----
 net/sched/cls_flower.c                    | 35 ++++++++++++++++++++++++++++++-
 5 files changed, 72 insertions(+), 6 deletions(-)

-- 
2.1.4
