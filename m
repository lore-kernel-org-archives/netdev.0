From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] PKT_SCHED: Prevent destroying via RTM_DELTFILTER while
 classifying
Date: Fri, 10 Dec 2004 03:08:10 +0100
Message-ID: <41B9050A.1060401@trash.net>
References: <20041210014322.GS1371@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041210014322.GS1371@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:

>The classify function of every cls is invoked under BH and 
>dev->queue_lock spinlock from dev_xmit. Hence to serialize destroying
>the destroy function must be called under the spinlock as well. There
>are 2 paths in which a classifier can be destroyed:
>
>1) via the qdisc destroy cb calling tcf_destroy under
>   qdisc_tree_lock from __qdisc_destroy (rcu callback)
>      
>2) via RTM_DELTFILTER in cls_api.c under no locks at all.
>
>The first path seems ok, the initial qdisc destroy attempt is called
>under the spinlock and thus serialized with the classify while
>the list unlinking takes place and dev_xmit takes care of
>the RCU callback, hence classify and all the callbacks needed
>from process context cannot be found anymore.
>
>The second path needs the spinlock to avoid destroying while
>a classification is in progress. 2.4 probably needs the same fix,
>I will cook one up if so.
>  
>
This is not correct. The classifier is unlinked in tc_ctl_tfilter
before it is destroyed, so it is not visible for classification anymore.

        if (fh == 0) {
                if (n->nlmsg_type == RTM_DELTFILTER && t->tcm_handle == 0) {
                        qdisc_lock_tree(dev);
                        *back = tp->next;
                        qdisc_unlock_tree(dev);

                        tfilter_notify(skb, n, tp, fh, RTM_DELTFILTER);
                        tcf_destroy(tp);
                        err = 0;
                        goto errout;
                }

Regards
Patrick
