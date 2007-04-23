From: "Laurent Chavey" <chavey@google.com>
Subject: is CONFIG_NET_CLS_ACT always set ?
Date: Mon, 23 Apr 2007 14:19:41 -0700
Message-ID: <97949e3e0704231419o21062b6cl5b8cf38e1b412b05@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.13]:8908 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754238AbXDWVTs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2007 17:19:48 -0400
Received: from zps75.corp.google.com (zps75.corp.google.com [172.25.146.75])
	by smtp-out.google.com with ESMTP id l3NLJl7J025074
	for <netdev@vger.kernel.org>; Mon, 23 Apr 2007 14:19:47 -0700
Received: from wr-out-0506.google.com (wrai31.prod.google.com [10.54.60.31])
	by zps75.corp.google.com with ESMTP id l3NLJeB1002992
	for <netdev@vger.kernel.org>; Mon, 23 Apr 2007 14:19:41 -0700
Received: by wr-out-0506.google.com with SMTP id i31so1739939wra
        for <netdev@vger.kernel.org>; Mon, 23 Apr 2007 14:19:41 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

if CONFIG_NET_CLS_ACT is not defined, then is the
code below correct ?


netif_receive_skb()
---------------------------
	list_for_each_entry_rcu(ptype, &ptype_all, list) {
		if (!ptype->dev || ptype->dev == skb->dev) {
			if (pt_prev)
				ret = deliver_skb(skb, pt_prev);
			pt_prev = ptype;
		}
	}

#ifdef CONFIG_NET_CLS_ACT
	if (pt_prev) {
		ret = deliver_skb(skb, pt_prev);
		pt_prev = NULL; /* noone else should process this after*/
	} else {
		skb->tc_verd = SET_TC_OK2MUNGE(skb->tc_verd);
	}

	ret = ing_filter(skb);

	if (ret == TC_ACT_SHOT || (ret == TC_ACT_STOLEN)) {
		kfree_skb(skb);
		goto out;
	}

	skb->tc_verd = 0;
ncls:
#endif
handle_diverter(skb);

if (handle_bridge(&skb, &pt_prev, &ret))
	goto out;
