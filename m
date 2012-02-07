From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] skbuff: Add new tc classify variable
Date: Tue, 7 Feb 2012 11:05:22 -0800
Message-ID: <20120207110522.70663963@nehalam.linuxnetplumber.net>
References: <1328639948-25232-1-git-send-email-siwu@hrz.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38136 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753992Ab2BGTF0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Feb 2012 14:05:26 -0500
In-Reply-To: <1328639948-25232-1-git-send-email-siwu@hrz.tu-chemnitz.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  7 Feb 2012 19:39:08 +0100
Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de> wrote:

> The linux traffic control mechanism has different ways to select the
> correct class of a qdisc. A common way to do this is to use tc filters
> that are directly attached to a qdisc. Another approach is to use the
> iptables classify module. The latter one can reduce the amount of work
> necessary to process a packet when iptables is already involved in the
> packet classification.
> 
> The iptables module can be used in the postrouting chain of the mangle
> table.
> 
> # iptables -F -t mangle
> # iptables -X -t mangle
> # iptables -t mangle -I POSTROUTING -j CLASSIFY --set-class 1:1337
> 
> A simple qdisc with two classes will now route the traffic to 1:1337
> 
> # tc qdisc del dev eth0 root
> # tc qdisc add dev eth0 root handle 1: htb default 1
> # tc class add dev eth0 parent 1: classid 1:1 htb rate 15kbit burst 0kbit
> # tc class add dev eth0 parent 1: classid 1:1337 htb rate 250kbit burst 0kbit
> # tc -s class show dev eth0
> 
> A similar test with an ath9k device will show a complete different
> behavior. The default class 1:1 will be used and data is sent through.
> This problem seems to be related to the fact that the shared member
> variable sk_buff::priority is used to store the tc class id of an
> outgoing packet. This variable is also used in other places for
> different purposes. An example is the ieee80211_select_queue function
> which always overwrites the priority of an outgoing skb.
> 
> This conflict can be resolved by an additional member variable
> sk_buff::tc_class that is only used for the traffic control
> classification.
> 
> Signed-off-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
> Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: Jamal Hadi Salim <hadi@cyberus.ca>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Johannes Berg <johannes@sipsolutions.net>
> Cc: "John W. Linville" <linville@tuxdriver.com>
> Cc: Marek Lindner <lindner_marek@yahoo.de>
> Cc: Sven Eckelmann <sven@narfation.org>
> Cc: netfilter-devel@vger.kernel.org
> Cc: netfilter@vger.kernel.org
> Cc: coreteam@netfilter.org
> Cc: netdev@vger.kernel.org
> Cc: linux-wireless@vger.kernel.org

I don't understand why this is better, we already have mark to do this.
Your method saves adding a tc filter to map mark to classid, but that is hardly
a huge burden.
