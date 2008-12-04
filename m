From: Michal Soltys <soltys@ziu.info>
Subject: Question - size tables implementation
Date: Thu, 04 Dec 2008 14:55:38 +0100
Message-ID: <4937E15A.9090909@ziu.info>
References: <49292F54.4020803@ziu.info> <4929632F.3050200@trash.net> <492AB29A.3010601@ziu.info> <492AB60A.9050606@trash.net> <492DD399.4040801@ziu.info> <492E7B0B.8000601@trash.net> <492F2A9B.2050903@ziu.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.ppgk.com.pl ([80.53.243.36]:33578 "EHLO relay.ppgk.com.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751795AbYLDNzX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Dec 2008 08:55:23 -0500
Received: from localhost.ppgk.com.pl (localhost [127.0.0.1])
	by relay.ppgk.com.pl (Postfix) with ESMTP id D395337619
	for <netdev@vger.kernel.org>; Thu,  4 Dec 2008 14:55:17 +0100 (CET)
Received: from relay.ppgk.com.pl ([127.0.0.1])
	by localhost.ppgk.com.pl (relay.ppgk.com.pl [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id haTXI4W2SRr1 for <netdev@vger.kernel.org>;
	Thu,  4 Dec 2008 14:55:17 +0100 (CET)
Received: from [192.168.100.249] (shodan.ppgk.com.pl [192.168.100.249])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	by relay.ppgk.com.pl (Postfix) with ESMTPS id 3588C375E5
	for <netdev@vger.kernel.org>; Thu,  4 Dec 2008 14:55:17 +0100 (CET)
In-Reply-To: <492F2A9B.2050903@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

This is a followup question, continuing from:

http://marc.info/?l=linux-netdev&m=122782976032316&w=2

Well, at least this is what I'm seeing from looking at the code. Perhaps 
I missed something.

Assuming I didn't - an example of a flow in a simple example (let's say 
- hypothetical "outer" as a root qdisc, and "inner" as a leaf qdisc - 
both using different size tables):

1) qdisc_enqueue_root() will set pkt_len in cb area to skb->len, call 
qdisc_enqueue(), then

2) qdisc_calculate_pkt_len() will set pkt_len in cb area using "outer"'s 
size table, and

3) outer_enqueue() will be will be called. This one will classify the 
packet and

4) qdisc_enqueue() it to the "inner" qdisc, but that function will 
qdisc_calculate_pkt_len() overwriting pkt_len in cb area using "inner"'s 
size table

Later, whenever the time comes to e.g. dequeue or peek at the packet, 
"outer" will see packet size set in (4) whenever it calls qdisc_pkt_len().

For now, as far as I can see, the stab functionality is ready to be 
used, but no scheduler actually uses it - so the whole chain ends at 
setting ((struct qdisc_skb_cb*)skb->cb)->pkt_len during 
qdisc_enqueue_root() to skb->len.

If I was to add atm adaptation to HFSC using size tables (as suggested 
by Patrick), I'd like to know which direction to choose:

1) be prepared for it (e.g. save pkt_len, rerun 
qdisc_calculate_pkt_len() every time adjusted length is needed, restore 
the previous pkt_len afterwards) - but it's ugly and bloaty, and causes 
plenty of unnecessary calls to the calculate function.

2) change size table implementation, e.g.

- add depth field in struct Qdisc {} - 0 for root, and parent's
sch->depth+1 for any deeper qdisc, during qdisc creation
- make qdisc_calculate_pkt_len() and qdisc_pkt_len() use that as an
index, so instead of

struct qdisc_skb_cb {
         unsigned int            pkt_len;
         char                    data[];
};

we would have something like:

struct qdisc_skb_cb {
         unsigned int            pkt_len[QDISC_MAX_DEPTH];
         char                    data[];
};

static inline unsigned int qdisc_pkt_len(struct sk_buff *skb, struct
Qdisc *sch)
{
         return qdisc_skb_cb(skb)->pkt_len[sch->depth];
}

etc.

3) Ignore ? Aka assume only outer (or non-work conserving) qdisc may use 
size tables, but that's just wrong...


