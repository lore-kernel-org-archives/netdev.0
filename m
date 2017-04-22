From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 195503] New: tipc: unchecked return value of nlmsg_new()
 in function tipc_nl_node_get_monitor()
Date: Sat, 22 Apr 2017 09:48:27 -0700
Message-ID: <20170422094827.4aaa0fc4@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jon.maloy@ericsson.com, ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:35655 "EHLO
        mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1425132AbdDVQsb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Apr 2017 12:48:31 -0400
Received: by mail-io0-f178.google.com with SMTP id r16so141720429ioi.2
        for <netdev@vger.kernel.org>; Sat, 22 Apr 2017 09:48:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Sat, 22 Apr 2017 14:56:25 +0000
From: bugzilla-daemon@bugzilla.kernel.org
To: stephen@networkplumber.org
Subject: [Bug 195503] New: tipc: unchecked return value of nlmsg_new() in function tipc_nl_node_get_monitor()


https://bugzilla.kernel.org/show_bug.cgi?id=195503

            Bug ID: 195503
           Summary: tipc: unchecked return value of nlmsg_new() in
                    function tipc_nl_node_get_monitor()
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

Function nlmsg_new() will return a NULL pointer if there is no enough memory.
In function tipc_nl_node_get_monitor(), the return value of nlmsg_new() is not
checked (see line 2100), which may result in bad memory access. 
tipc_nl_node_get_monitor @@ net/tipc/node.c
2094 int tipc_nl_node_get_monitor(struct sk_buff *skb, struct genl_info *info)
2095 {
2096     struct net *net = sock_net(skb->sk);
2097     struct tipc_nl_msg msg;
2098     int err;
2099 
2100     msg.skb = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
2101     msg.portid = info->snd_portid;
2102     msg.seq = info->snd_seq;
2103 
2104     err = __tipc_nl_add_monitor_prop(net, &msg);
2105     if (err) {
2106         nlmsg_free(msg.skb);
2107         return err;
2108     }
2109 
2110     return genlmsg_reply(msg.skb, info);
2111 }

Generally, the return value of nlmsg_new() should be checked against NULL, as
follows.
nfc_genl_target_lost @@ net/nfc/netlink.c: 
 213 int nfc_genl_target_lost(struct nfc_dev *dev, u32 target_idx)
 214 {
 215     struct sk_buff *msg;
 216     void *hdr;
 217 
 218     msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
 219     if (!msg)
 220         return -ENOMEM;
         ...
 237 nla_put_failure:
 238     genlmsg_cancel(msg, hdr);
 239 free_msg:
 240     nlmsg_free(msg);
 241     return -EMSGSIZE;
 242 }


Thanks very much for your attention!

Pan Bian

-- 
You are receiving this mail because:
You are the assignee for the bug.
