From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf-next 0/4] netfilter: rework netfilter ipv6 defrag
Date: Sat, 17 Oct 2015 22:14:21 +0200
Message-ID: <1445112865-31523-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org, azhou@nicira.com, joestringer@nicira.com
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[ CC netdev since patch #2 isn't nf-specific.  Dave, if you want
  I can resubmit that one after the next nf-pull request; let me know if
  you would prefer that ].

Openvswitch seems broken wrt. to defragmentation, it doesn't call
nf_ct_frag6_consume_orig to free the original fragments.

Moreover, openvswitch design seems to require that it can reuse current
skb rather than work with a new skb pointer (it uses skb_morph for this).

Instead of OVS-side fix this series tries to alter netfilter ipv6 defrag
accordingly.

1. nf_ct_frag6_consume_orig is removed, since
commit 6aafeef03b9d9ecf ("netfilter: push reasm skb through instead of
original frag skbs") nothing needs the original fragments so there is no
reason why we need to clone+store original skb -- just stash original
skbs in the frag_list.

2. Use skb_morph to make the last skb processed (not necessarily last
fragment) the reassembled one.

3. remove the no-longer needed recursion into nf_iterate, we can now just
return ACCEPT/STOLEN as needed instead of NF_HOOK_THRESH()+NF_STOLEN.

Tested with flood-ping6+ fault-injection framework 'failslab' type.
