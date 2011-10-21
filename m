From: Kyle Moffett <kyle@moffetthome.net>
Subject: Re: [RFC PATCH 05/17] phy_driver: Make .read_status()/.config_aneg() optional
Date: Fri, 21 Oct 2011 01:13:30 -0400
Message-ID: <CAGZ=bqJNRCiiT6KvQBkZ5fs6b=RQG92xtmf1cGe1s9mdcbcDFA@mail.gmail.com>
References: <1319144425-15547-1-git-send-email-Kyle.D.Moffett@boeing.com>
 <1319144425-15547-6-git-send-email-Kyle.D.Moffett@boeing.com>
 <201110201710.17519.vapier@gentoo.org> <201110201714.36533.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kyle Moffett <Kyle.D.Moffett@boeing.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Randy Dunlap <rdunlap@xenotime.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	Greg Dietsche <Gregory.Dietsche@cuw.edu>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	David Daney <ddaney@caviumnetworks.com>,
	Arnaud Patard <arnaud.patard@rtp-net.org>,
	Grant Likely <grant.likely@secretlab.ca>,
	Baruch Siach <baruch@tkos.co.il>,
	Thorsten Schubert <tshu@msc-ge.com>,
	David Decotigny <decot@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Lucas De Marchi <lucas.demarchi@profusion.mobi>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	linux-doc@vger.kernel.org
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <201110201714.36533.vapier@gentoo.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oops, I just realized that I may have misused
scripts/get_maintainer.pl... it seems to have added about 20 CCs to
this email, sorry!

On Thu, Oct 20, 2011 at 17:14, Mike Frysinger <vapier@gentoo.org> wrote=
:
> On Thursday 20 October 2011 17:10:12 Mike Frysinger wrote:
>> On Thursday 20 October 2011 17:00:12 Kyle Moffett wrote:
>> > Approximately 90% of the PHY drivers follow the PHY layer docs and
>> > simply use &genphy_read_status and &genphy_config_aneg. =C2=A0Ther=
e would
>> > seem to be little point in requiring them all to manually specify =
those
>> > functions.
>>
>> well, it does make sense if you think about the compile vs build tim=
e
>> overhead. =C2=A0yes, your patch does make things much nicer to read,=
 and a
>> little easier to maintain the source. =C2=A0however, it adds runtime=
 overhead
>> (checking the func pointers) while the func pointer storage is uncha=
nged
>> (it's now a NULL pointer instead of pointing to the genphy funcs).
>> personally, i think the savings in runtime and smaller compiled code=
 is
>> more important. =C2=A0so i'm going to NAK this. =C2=A0sorry.
>
> ah, sorry, i was thinking this was u-boot since we were just having
> conversations there.
>
> since this is Linux, and i don't have real standing in the general ne=
tdev
> community, i can't really NAK here. =C2=A0but i think my comment stil=
l stands in
> that this patch makes things much worse than the minor code style imp=
rovement.

I would argue that the PHY layer itself is not remotely a hot-path,
especially not to the level of caring about an extra if statement.  A
single phy_read() is a sleeping call which goes over a slow serial
bus, so code maintainability is much more important.

At the higher level, the reason for this change is that currently
genphy_config_aneg() is currently responsible both for configuring
auto-negotiation *AND* counterintuitively for configuring forced-mode
links.  A lot of PHY drivers need to override just one or the other,
which results in either a lot of copy-pasted code in individual PHY
drivers or in a duplicate test for autoneg-vs-fixed-mode before
calling the primary genphy_config_aneg() function.

In order to split that up and refactor it, I would like to minimize
the number of callers and references to config_aneg() to minimize the
number of places that have to be changed to match.  Since all the rest
of the PHY functions are already conditionals, making these two also
conditional didn't seem to be a big deal.

Cheers,
Kyle Moffett

--=20
Curious about my work on the Debian powerpcspe port?
I'm keeping a blog here: http://pureperl.blogspot.com/
