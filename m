From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] [IPv6]: IPV6_MULTICAST_IF setting is ignored on link-local
 connect()
Date: Tue, 18 Dec 2007 15:56:22 -0800
Message-ID: <OF7B1ADDCA.711DCE7B-ON882573B5.00820D67-882573B5.0083AEF8@us.ibm.com>
References: <47684AE3.7080007@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:36068 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754179AbXLRX4m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2007 18:56:42 -0500
In-Reply-To: <47684AE3.7080007@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian,

OK, I see what you're trying to fix now.

I think the scope_id checks are not quite right-- they
should be something like this:

if (addr_type&IPV6_ADDR_LINKLOCAL) {
        if (addr_len >= sizeof(struct sockaddr_in6)) {
                if (sk->sk_bound_dev_if && usin->sin6_scope_id &&
                    sk->sk_bound_dev_if != usin->sin6_scope_id) {
                        err = -EINVAL;
                        goto out;
                }
                if (usin->sin6_scope_id)
                        sk->sk_bound_dev_if = usin->sin6_scope_id;
                if (!sk->sk_bound_dev_if &&
                     (addr_type & IPV6_ADDR_MULTICAST))
                        fl.oif = np->mcast_oif;
        }

        /* connect to the link-local addres requires an interface */
        if (!sk->sk_bound_dev_if) {
                err = -EINVAL;
                goto out;
        }
}

        That is (in English):

        If I did an SO_BINDTODEVICE and specified sin6_scope_id,
then they better agree.
        If I specified sin6_scope_id without SO_BINDTODEVICE, set
the device to that.
        If I get this far without a device and it's multicast, use 
mcast_oif
        If I get all through that and don't have a device, EINVAL.

        Does that work for you?

                                        +-DLS

