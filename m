From: jamal <hadi@cyberus.ca>
Subject: [RFC] SPD basic actions per netdev
Date: Wed, 31 Mar 2010 12:37:58 -0400
Message-ID: <1270053478.26743.111.camel@bigi>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>,
	Timo Teras <timo.teras@iki.fi>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.26]:45199 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757759Ab0CaQiE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 12:38:04 -0400
Received: by ey-out-2122.google.com with SMTP id d26so22871eyd.19
        for <netdev@vger.kernel.org>; Wed, 31 Mar 2010 09:38:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This may be oversight in current implementation and possibly
nobody has needed it before - hence it is not functional.

I want to have a drop-all policy on a per-interface level
for incoming packets and add exceptions as i need them.
[using the flow table is cheap if you have xfrm built in].
i.e something along the lines of:

#eth0, wild-card drop all
ip xfrm policy add src 0.0.0.0/0 dst 0.0.0.0/0 dev eth0 \
       dir in ptype main action block priority $SOME-HIGH-value
#eth0, exception
ip xfrm policy add blah blah dev eth0 \
dir in ptype main action allow priority $SOME-small-value
#eth1, wild-card drop all
ip xfrm policy add src 0.0.0.0/0 dst 0.0.0.0/0 dev eth1 \
       dir in ptype main action block priority $SOME-HIGH-value
#eth1 exception ...

The problem is this works as long as i dont specify an interface.
i.e, this would work in the in-direction:

ip xfrm policy add src 0.0.0.0/0 dst 0.0.0.0/0 \
        dir in ptype main action block priority $SOME-HIGH-value

This would not work:
ip xfrm policy add src 0.0.0.0/0 dst 0.0.0.0/0 dev eth0 \
       dir in ptype main action block priority $SOME-HIGH-value


The checks in the selector matching is the culprit, example for v4:

__xfrm4_selector_match(struct xfrm_selector *sel, struct flowi *fl)
{
        return  .... &&
                .... &&
                (fl->oif == sel->ifindex || !sel->ifindex);
}

i.e in the second case i have a non-zero sel->ifindex but
a zero fl->oif; so it wont match.

One approach to fix this is to pass the direction then i can do
in the function call, then i can do something along the lines of
matching if:
(fl_dir == FLOW_DIR_IN && (fl->iif == sel->ifindex || !sel->ifindex) ||
(fl->oif == sel->ifindex || !sel->ifindex);

Is there any reason the selector matching only assumes fl->oif?
Are there any unforeseen issues/breakages if i added a check for the
above.

cheers,
jamal

