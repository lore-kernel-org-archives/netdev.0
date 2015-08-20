From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Exporting obscene amounts of data in rtnl_link_ops->fill_info()
Date: Thu, 20 Aug 2015 02:47:50 +0200
Message-ID: <CAHmME9pps6BJwubBNgp294JKGkGXHUyb1kMdTGCEwok__aQjmw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:46552 "EHLO frisell.zx2c4.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751302AbbHTArw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2015 20:47:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi guys,

I have a new link driver that registers a rtnl_link_ops. For many
things, the rtnl interfaces are perfectly suited: I can use netlink in
userspace to check out packet counts, adjust interface parameters, and
all sorts of things. There is even the "fill_info" function exporting
interface-specific types of data to userspace through the standard
netlink interfaces. I'm glad this is here, because it's exactly what I
want.

Problem: sometimes I want to export a *lot* of data to userspace. When
this happens, even if I make the netlink socket receive buffer really
huge, this code path is still reached in rtnetlink.c:

                        err = rtnl_fill_ifinfo(skb, dev, RTM_NEWLINK,
                                               NETLINK_CB(cb->skb).portid,
                                               cb->nlh->nlmsg_seq, 0,
                                               NLM_F_MULTI,
                                               ext_filter_mask);
                        /* If we ran out of room on the first message,
                         * we're in trouble
                         */
                        WARN_ON((err == -EMSGSIZE) && (skb->len == 0));

That is -- it tries to fill the skb (for sending it back to
userspace), but doesn't have enough room, so it returns -EMSGSIZE.
That seems like reasonable behavior, but it doesn't really help me
obtain my goal. I'd like to send quite a bit of data back to userspace
for a network interface, and I'd like to do it using the standard
netlink APIs. Is this possible?

Thanks,
Jason
