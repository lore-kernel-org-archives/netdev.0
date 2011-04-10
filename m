From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: extending feature word.
Date: Sun, 10 Apr 2011 12:19:54 +0200
Message-ID: <20110410101954.GA23753@rere.qmqm.pl>
References: <BANLkTin52LqjxtVT+_y+gGam-QxeLq_iOA@mail.gmail.com> <20110408100535.GB10565@rere.qmqm.pl> <BANLkTik4+P3GU+NzZ6JkKPgXhwip-+PM5w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-netdev <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:58286 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755826Ab1DJKT4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Apr 2011 06:19:56 -0400
Content-Disposition: inline
In-Reply-To: <BANLkTik4+P3GU+NzZ6JkKPgXhwip-+PM5w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 08, 2011 at 11:17:41AM -0700, Mahesh Bandewar wrote:
> On Fri, Apr 8, 2011 at 3:05 AM, Micha=B3 Miros=B3aw <mirq-linux@rere.=
qmqm.pl> wrote:
> > On Fri, Apr 01, 2011 at 07:07:05PM -0700, Mahesh Bandewar wrote:
> >> Thanks for your comments on my loop-back patch. I was looking at t=
he
> >> code today from the perspective of extending various "features" fo=
r
> >> word to an array of words and as Michael has pointed out, it's a h=
uge
> >> change. So I'm thinking on the following lines
> >> (include/linux/netdevice.h)
> >>
> >> +#define DEV_FEATURE_WORDS =A0 =A0 =A02
> >> +#define LEGACY_FEATURE_WORD =A0 =A00
> >> =A0 =A0 =A0 =A0/* currently active device features */
> >> - =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 features=
;
> >> + =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 features=
[DEV_FEATURE_WORDS];
> >> =A0 =A0 =A0 =A0/* user-changeable features */
> >> - =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 hw_featu=
res;
> >> + =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 hw_featu=
res[DEV_FEATURE_WORDS];
> >> =A0 =A0 =A0 =A0/* user-requested features */
> >> - =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wanted_f=
eatures;
> >> + =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wanted_f=
eatures[DEV_FEATURE_WORDS];
> >> =A0 =A0 =A0 =A0/* VLAN feature mask */
> >> - =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vlan_fea=
tures;
> >> + =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vlan_fea=
tures[DEV_FEATURE_WORDS];
> >
> > Hmm. There might be no point in making features field an array.
> > This gives us nothing really. Maybe just add features_2 or similar?
> > If we ever get to the point there need to be more than two words fo=
r
> > features we can think of some abstraction layer then.
> >
> That is right! making it an array doesn't really buy us anything
> unless there is a uniform way of managing all the bits spread across
> multiple words inside that array. This was the reason why I have
> changed that array into a bitmap in the patch that I have posted
> earlier. This way the upper limit (currently only 32 bits) will be
> removed and we'll have a long term solution. There will be little bit
> of work involved but 'doing-things-right' has cost associated.

I really don't like the bitmap idea. It multiplies the amount of code
needed to manipulate multiple bits at once --- and that's a common
thing for drivers to do. Almost every driver that needs ndo_fix_feature=
s
will clear sets --- checkumming set, TSO set, all TX offloads set, ...

As a first step just add another set of words:

union {
	struct {
		u32 features;
		u32 features_2;
	} /* anonymous struct */;
	u32 features_array[2];
} /* anonymous union */;

This allows to change drivers after core supporting code gets implement=
ed.

Best Regards,
Micha=B3 Miros=B3aw
