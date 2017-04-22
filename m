From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 195497] New: openvswitch: unchecked return value of
 nla_nest_start() in function queue_userspace_packet()
Date: Sat, 22 Apr 2017 09:49:00 -0700
Message-ID: <20170422094900.3c94692c@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f51.google.com ([209.85.214.51]:34368 "EHLO
        mail-it0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1425856AbdDVQtD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Apr 2017 12:49:03 -0400
Received: by mail-it0-f51.google.com with SMTP id 193so4234707itm.1
        for <netdev@vger.kernel.org>; Sat, 22 Apr 2017 09:49:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Sat, 22 Apr 2017 14:52:46 +0000
From: bugzilla-daemon@bugzilla.kernel.org
To: stephen@networkplumber.org
Subject: [Bug 195497] New: openvswitch: unchecked return value of nla_nest_start() in function queue_userspace_packet()


https://bugzilla.kernel.org/show_bug.cgi?id=195497

            Bug ID: 195497
           Summary: openvswitch: unchecked return value of
                    nla_nest_start() in function queue_userspace_packet()
           Product: Networking
           Version: 2.5
    Kernel Version: linux-4.11-rc7
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: stephen@networkplumber.org
          Reporter: bianpan2010@ruc.edu.cn
        Regression: No

Function nla_nest_start() may return a NULL pointer on error. However, in
function queue_userspace_packet(), the return value of nla_nest_start() is not
checked against NULL (see lines 489 and 496), and may result in bad memory
access. Related code snippets are shown as follows.

queue_userspace_packet @@ net/openvswitch/datapath.c:420
 420 static int queue_userspace_packet(struct datapath *dp, struct sk_buff
*skb,
 421                   const struct sw_flow_key *key,
 422                   const struct dp_upcall_info *upcall_info,
 423                   uint32_t cutlen)
 424 {
 425     struct ovs_header *upcall;
         ...
 468     len = upcall_msg_size(upcall_info, hlen - cutlen);
 469     user_skb = genlmsg_new(len, GFP_ATOMIC);
 470     if (!user_skb) {
 471         err = -ENOMEM;
 472         goto out;
 473     }
 474 
 475     upcall = genlmsg_put(user_skb, 0, 0, &dp_packet_genl_family,
 476                  0, upcall_info->cmd);
 477     upcall->dp_ifindex = dp_ifindex;
         ...
 487     if (upcall_info->egress_tun_info) {
 488         nla = nla_nest_start(user_skb, OVS_PACKET_ATTR_EGRESS_TUN_KEY);
 489         err = ovs_nla_put_tunnel_info(user_skb,
 490                           upcall_info->egress_tun_info);
 491         BUG_ON(err);
 492         nla_nest_end(user_skb, nla);
 493     }
 494 
 495     if (upcall_info->actions_len) {
 496         nla = nla_nest_start(user_skb, OVS_PACKET_ATTR_ACTIONS);
 497         err = ovs_nla_put_actions(upcall_info->actions,
 498                       upcall_info->actions_len,
 499                       user_skb);
 500         if (!err)
 501             nla_nest_end(user_skb, nla);
 502         else
 503             nla_nest_cancel(user_skb, nla);
 504     }
         ...
 545 out:
 546     if (err)
 547         skb_tx_error(skb);
 548     kfree_skb(user_skb);
 549     kfree_skb(nskb);
 550     return err;
 551 }

Generally, the return value of function nla_nest_start() should be checked
against NULL, as follows.
rtnetlink_put_metrics @@ net/core/rtnetlink.c: 
 686 int rtnetlink_put_metrics(struct sk_buff *skb, u32 *metrics)
 687 {
 688     struct nlattr *mx;
 689     int i, valid = 0;
 690 
 691     mx = nla_nest_start(skb, RTA_METRICS);
 692     if (mx == NULL)
 693         return -ENOBUFS;
         ...
 726     return nla_nest_end(skb, mx);
 727 
 728 nla_put_failure:
 729     nla_nest_cancel(skb, mx);
 730     return -EMSGSIZE;
 731 }


Thanks very much for your attention!

Pan Bian

-- 
You are receiving this mail because:
You are the assignee for the bug.
