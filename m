From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next] bridge: Fix incorrect judgment of promisc
Date: Thu, 5 Jun 2014 12:55:59 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D17257D43@AcuExch.aculab.com>
References: <1401965851-6449-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
 <063D6719AE5E284EB5DD2968C1650D6D17257C08@AcuExch.aculab.com>
 <539052C0.2090409@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Vlad Yasevich <vyasevic@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>
To: 'Toshiaki Makita' <makita.toshiaki@lab.ntt.co.jp>,
	"David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:48478 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751162AbaFEM41 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 08:56:27 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 06612-02 for <netdev@vger.kernel.org>;
 Thu,  5 Jun 2014 13:56:19 +0100 (BST)
In-Reply-To: <539052C0.2090409@lab.ntt.co.jp>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Toshiaki Makita
> (2014/06/05 20:03), David Laight wrote:
> > From: Toshiaki Makita
> >> br_manage_promisc() incorrectly expects br_auto_port() to return only 0
> >> or 1, while it actually returns flags, i.e., a subset of BR_AUTO_MASK.
> >>
> >> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> >> ---
> >>  net/bridge/br_if.c | 2 +-
> >>  1 file changed, 1 insertion(+), 1 deletion(-)
> >>
> >> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
> >> index a08d2b8..6a07a40 100644
> >> --- a/net/bridge/br_if.c
> >> +++ b/net/bridge/br_if.c
> >> @@ -153,7 +153,7 @@ void br_manage_promisc(struct net_bridge *br)
> >>  			 * This lets us disable promiscuous mode and write
> >>  			 * this config to hw.
> >>  			 */
> >> -			if (br->auto_cnt <= br_auto_port(p))
> >> +			if (br->auto_cnt <= !!br_auto_port(p))
> >>  				br_port_clear_promisc(p);
> >>  			else
> >>  				br_port_set_promisc(p);
> >
> > Why not the less confusing:
> > 			if (br->auto_cnt || br_auto_port(p))
> > and reverse the then/else lines?
> 
> I'm respecting the original style, but I'm not particular about this style.
> I'll make less confusing one, thanks :)
> 
> (Your suggested condition is not exactly the same as current one, even
> if reversing if/else. v2 will be different than it. Anyway, thanks.)

A quick truth table:
	auto_cnt	auto_port	set/clear
		0		0	clear
		0		1	clear
		1		0	set
		1		1	clear
		2+		0/1	clear

So you want:
	if (br->auto_cnt && !br_auto_port(p))
		br_port_set_promisc(p);
	else
		br_port_clear_promisc(p);

Does seem like a strange condition.

	David

	
