From: Patrick McHardy <kaber@trash.net>
Subject: More tc action mess
Date: Wed, 19 Jan 2005 06:09:43 +0100
Message-ID: <41EDEB97.3080503@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I probably found the reason for the problems with the ipt action you were
talking about. netfilter targets, like tc actions, expect a struct 
sk_buff **,
but the ipt action does:

        struct sk_buff *skb = *pskb;
...
        ret = p->t->u.kernel.target->target(&skb, skb->dev, NULL,

which of course doesn't make much sense. Unfortunately, tcf_action_exec
does the same nonsense:

int tcf_action_exec(struct sk_buff *skb, struct tc_action *act,
...
                        ret = a->ops->act(&skb, a);

This means we must convert all paths on which tcf_action_exec is called
to use struct sk_buff ** :(

On egress q->enqueue owns the skb, so for this path we must convert the
qdiscs classification function and all classifierts. On ingress the skb
is owned by netif_receive_skb, so we need to convert the ingress qdisc's
enqueue function to take a sk_buff **, or better add a ingress_filter
function to avoid changing all enqueue calls in other qdiscs.

I have an big, ugly, incomplete patch that does this, but teaching
classifiers to behave correctly when the packet changes under them in
the middle of classification is hard, so any other solutions are welcome.

Regards
Patrick
