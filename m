From: Jakub =?UTF-8?B?S2ljacWEc2tp?= <moorray3@wp.pl>
Subject: Re: [PATCH 3/3] gianfar: remove faulty filer optimizer
Date: Tue, 11 Aug 2015 16:51:09 +0200
Message-ID: <20150811165109.0601035b@north>
References: <1439237540-11302-1-git-send-email-moorray3@wp.pl>
	<1439237540-11302-4-git-send-email-moorray3@wp.pl>
	<BY2PR0301MB0727FA3B33977F2E64975F839C7F0@BY2PR0301MB0727.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jakub Kicinski <kubakici@wp.pl>
To: Manoil Claudiu <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.9]:32593 "EHLO mx3.wp.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964954AbbHKOvM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Aug 2015 10:51:12 -0400
In-Reply-To: <BY2PR0301MB0727FA3B33977F2E64975F839C7F0@BY2PR0301MB0727.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 11 Aug 2015 14:00:23 +0000, Manoil Claudiu wrote:
> >-----Original Message-----
> >From: Jakub Kicinski [mailto:moorray3@wp.pl]
> >Sent: Monday, August 10, 2015 11:12 PM
> >To: David S. Miller; Manoil Claudiu-B08782
> >Cc: netdev@vger.kernel.org; Jakub Kicinski
> >Subject: [PATCH 3/3] gianfar: remove faulty filer optimizer
> >
> >From: Jakub Kicinski <kubakici@wp.pl>
> >
> >Current filer rule optimization is broken in several ways:
> > (1) It destroys rule ordering.
> > (2) It performs reads/writes beyond end of allocated tables.
> > (3) It breaks badly for rules with more than 2 specifiers
> >     (e.g. matching ip, port, tos).
> > (4) We observed that the masking rules it generates do not
> >     play well with clustering on P2020.  Only first rule
> >     of the cluster would ever fire.  Given that optimizer
> >     relies heavily on masking this is very hard to fix.
> >
> >The fact that nobody noticed (1), (3) or (4) makes me think
> >that this feature is not very widely used and we should just
> >remove it.
> 
> I'm not familiar with this filer classification code and its
> author is no longer active apparently.   There is not much of a
> choice here since this optimization feature is too complex and
> poorly documented to be reviewed and validated in a reasonable
> time span.
> An example, a simple use case showing expected behavior vs.
> actual behavior would help.

Sure, sorry, should be part of the submission quite honestly...
Quick note: I'm using virtual queues hence the high action numbers.

(1) Is actually false, I misread the code.

(2) To my eye calculation at gianfar_ethtool.c:1326 should be:
    tab->index - begin + 1, haven't tested this though.

(3) Example looks like this:

# ethtool -N eth2 flow-type udp4 dst-ip 10.0.0.1 dst-port 1 tos 1 action 1
Added rule with ID 254
# ethtool -N eth2 flow-type udp4 dst-ip 10.0.0.2 dst-port 2 tos 2 action 9
Added rule with ID 253
# ethtool -N eth2 flow-type udp4 dst-ip 10.0.0.3 dst-port 3 tos 3 action 17
Added rule with ID 252
# ./filer_decode /sys/kernel/debug/gfar1/filer_raw 
00: MASK == 00000210 AND         Q:00           ctrl:00000080 prop:00000210
01: FPR  == 00000210 AND CLE     Q:00           ctrl:00000281 prop:00000210
02: MASK == ffffffff AND         Q:00           ctrl:00000080 prop:ffffffff
03: DPT  == 00000003 AND         Q:00           ctrl:0000008e prop:00000003
04: TOS  == 00000003 AND         Q:00           ctrl:0000008a prop:00000003
05: DIA  == 0a000003 AND         Q:11           ctrl:0000448c prop:0a000003
06: DPT  == 00000002 AND         Q:00           ctrl:0000008e prop:00000002
07: TOS  == 00000002 AND         Q:00           ctrl:0000008a prop:00000002
08: DIA  == 0a000002 AND         Q:09           ctrl:0000248c prop:0a000002
09: DIA  == 0a000001 AND         Q:00           ctrl:0000008c prop:0a000001
0a: DPT  == 00000001 AND         Q:00           ctrl:0000008e prop:00000001
0b: TOS  == 00000001     CLE     Q:01           ctrl:0000060a prop:00000001
ff: MASK >= 00000000             Q:00           ctrl:00000020 prop:00000000

You can see that all rules are AND-ed together for no reason.  I found
this one during code inspections but can't recall where the bug was now...

(4) Example:

# ethtool -N eth2 flow-type udp4 dst-ip 10.0.0.1 dst-port 1  action 1
Added rule with ID 254
# ethtool -N eth2 flow-type udp4 dst-ip 10.0.0.2 dst-port 2  action 9
Added rule with ID 253
# ethtool -N eth2 flow-type udp4 dst-ip 10.0.0.3 dst-port 3  action 17
Added rule with ID 252
# ./filer_decode /sys/kernel/debug/gfar1/filer_raw 
00: MASK == 00000210 AND         Q:00           ctrl:00000080 prop:00000210
01: FPR  == 00000210 AND CLE     Q:00           ctrl:00000281 prop:00000210
02: MASK == ffffffff AND         Q:00           ctrl:00000080 prop:ffffffff
03: DPT  == 00000003 AND         Q:00           ctrl:0000008e prop:00000003
04: DIA  == 0a000003             Q:11           ctrl:0000440c prop:0a000003
05: DPT  == 00000002 AND         Q:00           ctrl:0000008e prop:00000002
06: DIA  == 0a000002             Q:09           ctrl:0000240c prop:0a000002
07: DIA  == 0a000001 AND         Q:00           ctrl:0000008c prop:0a000001
08: DPT  == 00000001     CLE     Q:01           ctrl:0000060e prop:00000001
ff: MASK >= 00000000             Q:00           ctrl:00000020 prop:00000000

Which looks correct according to the spec but only the first (eth id 252)/
last added rule for 10.0.0.3 will ever trigger.  As if filer did not treat
the AND CLE as cluster start but also kept AND-ing the rules.
