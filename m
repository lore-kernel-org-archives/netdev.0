From: Cong Wang <cwang@twopensource.com>
Subject: Why do we prefer skb->priority to tc filters?
Date: Wed, 11 Mar 2015 10:34:00 -0700
Message-ID: <CAHA+R7Oz=Je_avfzjLib0YaQRUArEpt+sm1qNqcV_oEvUp3=eA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:40676 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750740AbbCKReA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 13:34:00 -0400
Received: by igal13 with SMTP id l13so42063159iga.5
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 10:34:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,


Not sure about classful Qdisc's, for classless ones like fq_codel, we
also prefer skb->priority value over tc filters:

        if (TC_H_MAJ(skb->priority) == sch->handle &&
            TC_H_MIN(skb->priority) > 0 &&
            TC_H_MIN(skb->priority) <= q->flows_cnt)
                return TC_H_MIN(skb->priority);

        filter = rcu_dereference_bh(q->filter_list);
        if (!filter)
                return fq_codel_hash(q, skb) + 1;

        *qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
        result = tc_classify(skb, filter, &res);

Given that skb->priority can be specified in user-space, doesn't this
mean some application can always override our rules specified by tc
filters? I think we should always respect tc filters over any
application setting.

For discussion, I mean something like below makes more sense for me:

        struct tcf_result res;
        int result;

-       if (TC_H_MAJ(skb->priority) == sch->handle &&
-           TC_H_MIN(skb->priority) > 0 &&
-           TC_H_MIN(skb->priority) <= q->flows_cnt)
-               return TC_H_MIN(skb->priority);
-
        filter = rcu_dereference_bh(q->filter_list);
-       if (!filter)
+       if (!filter) {
+               if (TC_H_MAJ(skb->priority) == sch->handle &&
+                   TC_H_MIN(skb->priority) > 0 &&
+                   TC_H_MIN(skb->priority) <= q->flows_cnt)
+                       return TC_H_MIN(skb->priority);
+
                return fq_codel_hash(q, skb) + 1;
+       }

        *qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
        result = tc_classify(skb, filter, &res);

What do you think?

Thanks.
