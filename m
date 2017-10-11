From: Florian Fainelli <f.fainelli@gmail.com>
Subject: act_skbedit unable to check queue_mapping at init time
Date: Wed, 11 Oct 2017 12:02:35 -0700
Message-ID: <c48c8af5-d4c6-d2f7-cc0f-6cb50f2a865e@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org, jhs@mojatatu.com, jiri@resnulli.us,
        alexander.h.duyck@intel.com, xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f181.google.com ([209.85.216.181]:52161 "EHLO
        mail-qt0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752534AbdJKTCk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 15:02:40 -0400
Received: by mail-qt0-f181.google.com with SMTP id q4so8313460qtq.8
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 12:02:40 -0700 (PDT)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

It is perfectly possible for the following to happen:

# ls /sys/class/net/gphy/queues
rx-0  tx-0  tx-1  tx-2  tx-3
# tc qdisc add dev gphy root handle 1: multiq
# tc filter add dev gphy parent 1: protocol ip prio 1 u32
 match ip dst 192.168.1.1 action skbedit queue_mapping 5

that specifies a queue_mapping value that exceeds what the underlying
device supports. There is a check for dev->real_num_tx_queue >
d->queue_mapping in tcf_skbedit() which makes sure we won't overflow the
queue space, but this will essentially render the action inactive.

I can't find a way to get a reference on a network device from a
tc_action_ops->init function in order to validate that the queue_mapping
is valid at ->init() time and return an appropriate error if we are
exceeding what the device does. This is an action chained to a match and
a filter, so somehow one would think it would be possible to obtain a
reference on the network device the filter was installed on...

Any clues how we could fix that?
-- 
Florian
