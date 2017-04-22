From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 195495] New: unchecked return value of nla_nest_start() in
 function lwtunnel_fill_encap()
Date: Sat, 22 Apr 2017 09:49:49 -0700
Message-ID: <20170422094949.6bd88297@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:33371 "EHLO
        mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1425587AbdDVQtw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Apr 2017 12:49:52 -0400
Received: by mail-io0-f181.google.com with SMTP id k87so148928984ioi.0
        for <netdev@vger.kernel.org>; Sat, 22 Apr 2017 09:49:51 -0700 (PDT)
Received: from xeon-e3 (76-14-206-252.or.wavecable.com. [76.14.206.252])
        by smtp.gmail.com with ESMTPSA id t71sm22335529pfk.29.2017.04.22.09.49.50
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 22 Apr 2017 09:49:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Sat, 22 Apr 2017 14:49:46 +0000
From: bugzilla-daemon@bugzilla.kernel.org
To: stephen@networkplumber.org
Subject: [Bug 195495] New: unchecked return value of nla_nest_start() in function lwtunnel_fill_encap()


https://bugzilla.kernel.org/show_bug.cgi?id=195495

            Bug ID: 195495
           Summary: unchecked return value of nla_nest_start() in function
                    lwtunnel_fill_encap()
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
function lwtunnel_fill_encap(), the return value of nla_nest_start() is not
checked against NULL (see line 218), and may result in bad memory access.
Related code snippets are shown as follows.

lwtunnel_fill_encap @@ net/core/lwtunnel.c: 204
204 int lwtunnel_fill_encap(struct sk_buff *skb, struct lwtunnel_state
*lwtstate)
205 {
206     const struct lwtunnel_encap_ops *ops;
207     struct nlattr *nest;
208     int ret = -EINVAL;
209 
210     if (!lwtstate)
211         return 0;
212 
213     if (lwtstate->type == LWTUNNEL_ENCAP_NONE ||
214         lwtstate->type > LWTUNNEL_ENCAP_MAX)
215         return 0;
216 
217     ret = -EOPNOTSUPP;
218     nest = nla_nest_start(skb, RTA_ENCAP);
219     rcu_read_lock();
220     ops = rcu_dereference(lwtun_encaps[lwtstate->type]);
221     if (likely(ops && ops->fill_encap))
222         ret = ops->fill_encap(skb, lwtstate);
223     rcu_read_unlock();
224 
225     if (ret)
226         goto nla_put_failure;
227     nla_nest_end(skb, nest);
228     ret = nla_put_u16(skb, RTA_ENCAP_TYPE, lwtstate->type);
229     if (ret)
230         goto nla_put_failure;
231 
232     return 0;
233 
234 nla_put_failure:
235     nla_nest_cancel(skb, nest);
236 
237     return (ret == -EOPNOTSUPP ? 0 : ret);
238 }

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
