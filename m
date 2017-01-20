From: David Miller <davem@davemloft.net>
Subject: Re: [Xen-devel] xennet_start_xmit assumptions
Date: Fri, 20 Jan 2017 14:30:59 -0500 (EST)
Message-ID: <20170120.143059.1390682983473502518.davem@davemloft.net>
References: <20170119.113759.555556955190770932.davem@davemloft.net>
        <20170119184733.GJ22018@oracle.com>
        <20170119224123.GB19618@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Paul.Durrant@citrix.com, konrad.wilk@oracle.com,
        wei.liu2@citrix.com, netdev@vger.kernel.org,
        xen-devel@lists.xenproject.org
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36536 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752590AbdATTbB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 14:31:01 -0500
In-Reply-To: <20170119224123.GB19618@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Thu, 19 Jan 2017 17:41:23 -0500

> On (01/19/17 13:47), Sowmini Varadhan wrote:
>> > Specifically I'm talking about the dev_validate_header() check.
>> > That is supposed to protect us from these kinds of situations.
>> 
>> ah, but I run my pf_packet application as root, so I have 
>> capable(CAP_SYS_RAWIO), so I slip through the dev_validate_header()
>> check.
> 
> and in that light, should dev_validate_header()
> always return false if len == 0?
> 
> that will take care of all the send paths in af_packet.c
> but it impacts all drivers as well (even though it is the
> logically correct thing to do..)

I think dev_validate_header() almost does the correct thing in
the SYS_RAWIO case.

It clears out the not-provided hard header bytes, but it doesn't
adjust the skb->len.  I think that is a real requirement in this
situation.

CAP_SYS_RAWIO or not, the contract we have with the device is that
there will be at least enough bytes to cover a link layer header.

This probably requires a little bit of an adjustment to the calling
convention.  Perhaps:

	int dev_validate_header(const struct net_device *dev,
				char *ll_header, int len);

So then you can go:

	new_len = dev_validate_header(dev, skb->data, len);
	if (new_len < 0)
		goto out_cleanup_err;
	if (new_len > len)
		__skb_put(skb, new_len - len);

Or something like that.
