From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/4] [NETLINK]: Handle NLM_F_ECHO in netlink_rcv_skb()
Date: Sat, 12 Aug 2006 13:19:08 +0200
Message-ID: <20060812111908.GP14627@postel.suug.ch>
References: <20060809204821.216122988@postel.suug.ch> <20060809205439.434010049@postel.suug.ch> <20060810155120.GA494@ms2.inr.ac.ru> <20060810190210.GH14627@postel.suug.ch> <20060810203252.GA6414@ms2.inr.ac.ru> <20060810211833.GK14627@postel.suug.ch> <20060811153549.GA16351@ms2.inr.ac.ru> <20060811214744.GO14627@postel.suug.ch> <20060812110331.GA31479@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:51843 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1750849AbWHLLSs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Aug 2006 07:18:48 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Content-Disposition: inline
In-Reply-To: <20060812110331.GA31479@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> 2006-08-12 15:03
> Actually, it was the idea. If requestor asked NLM_F_ECHO and subscribed
> to muticasts, it suppresses double notifications. If it did not ask
> NLM_F_ECHO, he is not interested in results, he knows what's going on
> without this.
> 
> F.e. it was used by my implementation in gated: it did not set either
> NLM_F_ECHO or even NLM_F_ACK. And when making massive batch updates,
> it received nothing back: only errors and updates made by someone else.

So we do something like this:

/**
 * nlmsg_notify - send a notification netlink message
 * @sk: netlink socket to use
 * @skb: notification message
 * @pid: destination netlink pid for reports or 0
 * @group: destination multicast group or 0
 * @report: 1 to report back, 0 to disable
 * @flags: allocation flags
 */
int nlmsg_notify(struct sock *sk, struct sk_buff *skb, u32 pid,
		 unsigned int group, int report, gfp_t flags)
{
	int err = 0;

	if (group) {
		int exclude_pid = 0;

		if (report) {
			atomic_inc(&skb->users);
			exclude_pid = pid;
		}

		/* errors reported via destination sk->sk_err */
		nlmsg_multicast(sk, skb, exclude_pid, group, flags);
	}

	if (report)
		err = nlmsg_unicast(sk, skb, pid);

	return err;
}
