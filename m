From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [IPv6] Update setsockopt(IPV6_MULTICAST_IF) to support RFC 3493
Date: Wed, 10 Oct 2007 14:48:38 -0700
Message-ID: <OFDBC968FC.CAF6E192-ON88257370.0075A79A-88257370.0077B875@us.ibm.com>
References: <470D422D.5070403@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:33718 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758310AbXJJVso (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 17:48:44 -0400
In-Reply-To: <470D422D.5070403@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brian Haley <brian.haley@hp.com> wrote on 10/10/2007 02:20:45 PM:

> David Stevens wrote:
> > What about just checking for 0 in the later test?
> > 
> >         if (val && __dev_get_by_index(val) == NULL) {
> 
> We could fail the next check right before that though:

        Right, the semantics there would be "if we have a bound
dev if, that's the only legal value here." Setting it to '0' in
that case doesn't really do anythng, anyway. But I don't care
about that semantic difference-- could even add "val &&" to the
bound_dev_if check.
        What I don't like is that your "if" creates an identical
duplicate code path for the functional part of it. In this case
it's trivial (the asignment), but makes the code look more
complex than it really is. If v4 does it that way, I don't
like that either. :-)
        I agree with it in general, and may not be worth the
trouble, but I'd personally prefer something like:

        if (sk->sk_type == SOCK_STREAM)
                goto e_inval;
        if (val && sk->sk_bound_dev_if && sk->sk_bound_dev_if != val)
                goto e_inval;

        if (val && __dev_get_by_index(val) != NULL) {
                retv = -ENODEV;
                break;
        }
[at this point all validity checks are done and we're following
        one code path to do the work; each check is easily
        identifiable.]

        np->mcast_oif = val;
        retv = 0;
        break;

Or maybe:

        if (sk->sk_type == SOCK_STREAM)
                goto e_inval;

        if (val) {
                if (sk->sk_bound_dev_if && sk->sk_bound_dev_if != val)
                        goto e_inval;
                if (__dev_get_by_index(val != NULL) {
                        retv = -ENODEV;
                        break;
                }
        }
        np->mcast_oif = val;
        retv = 0;
        break;

But anyway, I made the comment; I think some form of it
should go in. :-) If you like the original better, that's
ok with me, too.

                                                +-DLS

