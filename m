From: Chen Gang <gang.chen@asianux.com>
Subject: [Suggestion] net/netfilter: strcpy for timeout->name
Date: Tue, 20 Nov 2012 16:47:02 +0800
Message-ID: <50AB4386.3080603@asianux.com>
References: <50AB0249.20802@asianux.com> <50AB12EE.6050802@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: Shan Wei <shanwei88@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Xue Ying <ying.xue0@gmail.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:38312 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750953Ab2KTIqJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2012 03:46:09 -0500
In-Reply-To: <50AB12EE.6050802@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Xue Ying, David Miller:

Please help checking net/netfilter/nfnetlink_cttimeout.c:
  I suggest, we use strncpy instead of strcpy at line 143. 
  just like we have already used strncmp at line 94.

  after checking the calling work flow:
    the length of nla_data(cda[CTA_TIMEOUT_NAME]) is not limited in server side.
    one of calling work flows is:
       netlink_unicast -> netlink_unicast_kernel -> nfnetlink_rcv -> netlink_rcv_skb
       -> nfnetlink_rcv_msg -> cttimeout_new_timeout

  thanks.

gchen.



 70 static int
 71 cttimeout_new_timeout(struct sock *ctnl, struct sk_buff *skb,
 72                       const struct nlmsghdr *nlh,
 73                       const struct nlattr * const cda[])
 74 {
 75         __u16 l3num;
 76         __u8 l4num;
 77         struct nf_conntrack_l4proto *l4proto;
 78         struct ctnl_timeout *timeout, *matching = NULL;
 79         struct net *net = sock_net(skb->sk);
 80         char *name;
 81         int ret;
 82 
 83         if (!cda[CTA_TIMEOUT_NAME] ||
 84             !cda[CTA_TIMEOUT_L3PROTO] ||
 85             !cda[CTA_TIMEOUT_L4PROTO] ||
 86             !cda[CTA_TIMEOUT_DATA])
 87                 return -EINVAL;
 88 
 89         name = nla_data(cda[CTA_TIMEOUT_NAME]);
 90         l3num = ntohs(nla_get_be16(cda[CTA_TIMEOUT_L3PROTO]));
 91         l4num = nla_get_u8(cda[CTA_TIMEOUT_L4PROTO]);
 92 
 93         list_for_each_entry(timeout, &cttimeout_list, head) {
 94                 if (strncmp(timeout->name, name, CTNL_TIMEOUT_NAME_MAX) != 0)
 95                         continue;
 96 
 97                 if (nlh->nlmsg_flags & NLM_F_EXCL)
 98                         return -EEXIST;
 99 
100                 matching = timeout;
101                 break;
102         }
103 
104         l4proto = nf_ct_l4proto_find_get(l3num, l4num);
105 
106         /* This protocol is not supportted, skip. */
107         if (l4proto->l4proto != l4num) {
108                 ret = -EOPNOTSUPP;
109                 goto err_proto_put;
110         }
111 
112         if (matching) {
113                 if (nlh->nlmsg_flags & NLM_F_REPLACE) {
114                         /* You cannot replace one timeout policy by another of
115                          * different kind, sorry.
116                          */
117                         if (matching->l3num != l3num ||
118                             matching->l4proto->l4proto != l4num) {
119                                 ret = -EINVAL;
120                                 goto err_proto_put;
121                         }
122 
123                         ret = ctnl_timeout_parse_policy(matching, l4proto, net,
124                                                         cda[CTA_TIMEOUT_DATA]);
125                         return ret;
126                 }
127                 ret = -EBUSY;
128                 goto err_proto_put;
129         }
130 
131         timeout = kzalloc(sizeof(struct ctnl_timeout) +
132                           l4proto->ctnl_timeout.obj_size, GFP_KERNEL);
133         if (timeout == NULL) {
134                 ret = -ENOMEM;
135                 goto err_proto_put;
136         }
137 
138         ret = ctnl_timeout_parse_policy(timeout, l4proto, net,
139                                         cda[CTA_TIMEOUT_DATA]);
140         if (ret < 0)
141                 goto err;
142 
143         strcpy(timeout->name, nla_data(cda[CTA_TIMEOUT_NAME]));
144         timeout->l3num = l3num;
145         timeout->l4proto = l4proto;
146         atomic_set(&timeout->refcnt, 1);
147         list_add_tail_rcu(&timeout->head, &cttimeout_list);
148 
149         return 0;
150 err:
151         kfree(timeout);
152 err_proto_put:
153         nf_ct_l4proto_put(l4proto);
154         return ret;
155 }
156 
