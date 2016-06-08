From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] net, cls: allow for deleting all filters for
 given parent
Date: Wed, 08 Jun 2016 23:30:14 +0200
Message-ID: <57588E66.8070509@iogearbox.net>
References: <cd8455dfef0cccec5ef0a1ca2d1f678e9397d66e.1465056745.git.daniel@iogearbox.net> <CAM_iQpWDc1JAa9MhcSAOdJVVRoG52Z+p47CD-rd81LzN28zk1A@mail.gmail.com> <5755CE3A.7050002@iogearbox.net> <CAM_iQpXJAa5B=4ez9z+-Q66rFj+EUTGwrYWMhYoCK=3rp65gYw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	john fastabend <john.fastabend@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	tgraf@suug.ch
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:52593 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751366AbcFHVaT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 17:30:19 -0400
In-Reply-To: <CAM_iQpXJAa5B=4ez9z+-Q66rFj+EUTGwrYWMhYoCK=3rp65gYw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/06/2016 09:52 PM, Cong Wang wrote:
> On Mon, Jun 6, 2016 at 12:25 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
[...]
> This is fundamental for libnl to update caches.
>
> I don't understand why it should be separated, since notification is
> not a feature, we already have notifications in other paths.
>
>> Looking into this, I would probably make this a single notification that
>> denotes this 'wild-card' removal for that parent instead of calling
>> tfilter_notify() for each filter separately (which allocs skb, dumps it,
>> etc), qdisc del doesn't loop through it either, so probably fine this way.
>
> Makes sense.

I've been playing around with both options and am actually currently
leaning towards the tfilter_notify() for each proto for the reason
that user space tc monitors can simply stay as is. F.e., if someone
keeps an older libnl binary that wouldn't understand such a wildcard
message, then elements in libnl cache won't receive updates since the
meta data won't match on them (average case, there probably are only
one up to a handful of classifiers per parent) ... hm, different topic
but still wondering whether libnl relying on such messages is a good
idea in general since under stress tfilter_notify() can also fail and
user space won't get the updates (except for queries with RTM_GETTFILTER).

Thanks,
Daniel

  net/sched/cls_api.c | 37 +++++++++++++++++++++++++++++++++----
  1 file changed, 33 insertions(+), 4 deletions(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index a75864d..f873bbc 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -103,6 +103,17 @@ static int tfilter_notify(struct net *net, struct sk_buff *oskb,
  			  struct nlmsghdr *n, struct tcf_proto *tp,
  			  unsigned long fh, int event);

+static void tfilter_notify_chain(struct net *net, struct sk_buff *oskb,
+				 struct nlmsghdr *n,
+				 struct tcf_proto __rcu **chain, int event)
+{
+	struct tcf_proto __rcu **it_chain;
+	struct tcf_proto *tp;
+
+	for (it_chain = chain; (tp = rtnl_dereference(*it_chain)) != NULL;
+	     it_chain = &tp->next)
+		tfilter_notify(net, oskb, n, tp, 0, event);
+}

  /* Select new prio value from the range, managed by kernel. */

@@ -156,11 +167,23 @@ replay:
  	cl = 0;

  	if (prio == 0) {
-		/* If no priority is given, user wants we allocated it. */
-		if (n->nlmsg_type != RTM_NEWTFILTER ||
-		    !(n->nlmsg_flags & NLM_F_CREATE))
+		switch (n->nlmsg_type) {
+		case RTM_DELTFILTER:
+			if (protocol || t->tcm_handle)
+				return -ENOENT;
+			break;
+		case RTM_NEWTFILTER:
+			/* If no priority is provided by the user,
+			 * we allocate one.
+			 */
+			if (n->nlmsg_flags & NLM_F_CREATE) {
+				prio = TC_H_MAKE(0x80000000U, 0U);
+				break;
+			}
+			/* fall-through */
+		default:
  			return -ENOENT;
-		prio = TC_H_MAKE(0x80000000U, 0U);
+		}
  	}

  	/* Find head of filter chain. */
@@ -200,6 +223,12 @@ replay:
  	err = -EINVAL;
  	if (chain == NULL)
  		goto errout;
+	if (n->nlmsg_type == RTM_DELTFILTER && prio == 0) {
+		tfilter_notify_chain(net, skb, n, chain, RTM_DELTFILTER);
+		tcf_destroy_chain(chain);
+		err = 0;
+		goto errout;
+	}

  	/* Check the chain for existence of proto-tcf with this priority */
  	for (back = chain;
-- 
1.9.3
