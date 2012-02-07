From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH] skbuff: Add new tc classify variable
Date: Tue, 7 Feb 2012 20:33:49 +0000
Message-ID: <CAA93jw7NPVm_YUFdnM1aD6bzz5vbmuF3osaHS5xE+-xCutiAbw@mail.gmail.com>
References: <1328639948-25232-1-git-send-email-siwu@hrz.tu-chemnitz.de>
	<20120207.135841.1753473725075272902.davem@davemloft.net>
	<20120207201633.GB26533@pandem0nium>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Sven Eckelmann <sven@narfation.org>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, linux-wireless@vger.kernel.org
To: Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:43352 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756777Ab2BGUdv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 15:33:51 -0500
In-Reply-To: <20120207201633.GB26533@pandem0nium>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 7, 2012 at 7:57 PM, Simon Wunderlich <
simon.wunderlich@s2003.tu-chemnitz.de> wrote:

> On Tue, Feb 07, 2012 at 11:05:22AM -0800, Stephen Hemminger wrote:
> > On Tue,  7 Feb 2012 19:39:08 +0100
> > Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de> wrote:
> >
> > I don't understand why this is better, we already have mark to do t=
his.
> > Your method saves adding a tc filter to map mark to classid, but th=
at i=3D
s
> hardly
> > a huge burden.
>
> Unfortunately, it is. We have previously built our trees by setting m=
arks
> with iptables
> and matching the masks with tc and the u32 matcher, but we got a rath=
er
> big performance
> impact as soon as the number of users grow. The target platform are W=
iFi
> access points.
> By using the proposed patch, the performance stays nearly constant at=
 a
> growing number
> of users.
>

To put things in more general terms, the overspecialized behavior and u=
se
of magic numbers in the wireless stack

=2E.. from net/wireless/util.c/*

Given a data frame determine the 802.1p/1d tag to use. */
unsigned int cfg80211_classify8021d(struct sk_buff *skb)
{
        unsigned int dscp;

        /* skb->priority values from 256->263 are magic values to
         * directly indicate a specific 802.1d priority.  This is used
         * to allow 802.1d priority to be passed directly in from VLAN
         * tags, etc.
         */
        if (skb->priority >=3D3D 256 && skb->priority <=3D3D 263)
                return skb->priority - 256;

        switch (skb->protocol) {
        case htons(ETH_P_IP):
                dscp =3D3D ipv4_get_dsfield(ip_hdr(skb)) & 0xfc;
                break;
        case htons(ETH_P_IPV6):
                dscp =3D3D ipv6_get_dsfield(ipv6_hdr(skb)) & 0xfc;
                break;
        default:
                return 0;
        }

        return dscp >> 5;
}


and the related select queue function calling this
which maps the 4 hardware queues wireless has, onto 4 mq subqdiscs...

overrides most anything you might want to do with iptables doing
classification directly, especially if you want to put things
into different hw queues.

and furthermore makes using other qdiscs than mq, such as the htb rate
limiter, problematic, as well as sch_mq has no ability to put in a top
level filter, anyway because stuff ends up in the 1:1,1:2,1:3,1:4
automagically...

Reducing the namespace to 'marks' vs classes is ok for some uses, I gue=
ss,
but how to handle the hw queues and the select_queue problem?

And while I'm at the problems that wireless has, having one (or 4) queu=
es
per actual end-point rather than 4 hardware queues would make it possib=
le
to address the bufferbloat problem with wireless and sanely calculating
aggregation values....

My thought on that was to be tossing a station identifier into the cb, =
but
that seems to alsobe a cross layer violation.

I like the idea of separating "priority" from "classification" and from
"hw queues" but a unifying metaphor and space in the skb seems
to be THE problem.




--
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
=46R Tel: 0638645374
http://www.bufferbloat.net
