From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC net-next v2 0/4] net/sched: cls_flower: avoid false matching of truncated packets
Date: Fri,  5 May 2017 14:47:02 +0200
Message-ID: <1493988426-22854-1-git-send-email-simon.horman@netronome.com>
Cc: Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com,
        Benjamin LaHaise <benjamin.lahaise@netronome.com>,
        Simon Horman <simon.horman@netronome.com>
To: Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:37232 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751754AbdEEMrQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 5 May 2017 08:47:16 -0400
Received: by mail-wm0-f49.google.com with SMTP id m123so5268173wma.0
        for <netdev@vger.kernel.org>; Fri, 05 May 2017 05:47:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this series is intended to avoid false-positives which match
truncated packets against flower classifiers which match on:
* zero L4 ports or;
* zero ICMP code or type

This requires updating the flow dissector to return an error in such cases
and updating flower to not match on the result of a failed dissection.

In the case of UDP this results in a behavioural change to users of
flow_keys_dissector_keys[] and flow_keys_dissector_symmetric_keys[] -
dissection will fail on truncated packets where the IP protocol of the
packets indicates ports should be present (according to skb_flow_get_ports()).

The last patch of the series builds on the above to allow users to specify
a policy for how to handle packets whose dissection fails.

I will separately provide RFC patches to iproute2 to allow exercising the
last patch.

Changes between RFCv1 and RFCv2
* Rename new attribute in last path TCA_FLOWER_META_TRUNCATED
  after discussion with Jamal.
* Update changelog for "flow dissector" patches to make it clearer what
  the before and after behaviours are.

Simon Horman (4):
  flow dissector: return error on port dissection under-run
  flow dissector: return error on icmp dissection under-run
  net/sched: cls_flower: do not match if dissection fails
  net/sched: cls_flower: allow control of tree traversal on packet parse
    errors

 include/linux/skbuff.h       |  11 +++--
 include/uapi/linux/pkt_cls.h |   2 +
 net/core/flow_dissector.c    | 105 ++++++++++++++++++++++++-------------------
 net/sched/cls_flower.c       |  46 ++++++++++++++-----
 4 files changed, 106 insertions(+), 58 deletions(-)

-- 
2.1.4
