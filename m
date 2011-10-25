From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [RFC PATCH 05/17] phy_driver: Make .read_status()/.config_aneg() optional
Date: Tue, 25 Oct 2011 03:06:15 -0400
Message-ID: <CAJaTeTpZ4s3s1Xiy1Ng-hMiuGVTmJepRUHD-Cx4ruxBf+X7MzA@mail.gmail.com>
References: <1319144425-15547-1-git-send-email-Kyle.D.Moffett@boeing.com>
 <1319144425-15547-6-git-send-email-Kyle.D.Moffett@boeing.com>
 <201110201710.17519.vapier@gentoo.org> <201110201714.36533.vapier@gentoo.org> <CAGZ=bqJNRCiiT6KvQBkZ5fs6b=RQG92xtmf1cGe1s9mdcbcDFA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
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
To: Kyle Moffett <kyle@moffetthome.net>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <CAGZ=bqJNRCiiT6KvQBkZ5fs6b=RQG92xtmf1cGe1s9mdcbcDFA@mail.gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 21, 2011 at 01:13, Kyle Moffett wrote:
> On Thu, Oct 20, 2011 at 17:14, Mike Frysinger wrote:
>> On Thursday 20 October 2011 17:10:12 Mike Frysinger wrote:
>>> On Thursday 20 October 2011 17:00:12 Kyle Moffett wrote:
>>> > Approximately 90% of the PHY drivers follow the PHY layer docs an=
d
>>> > simply use &genphy_read_status and &genphy_config_aneg. =A0There =
would
>>> > seem to be little point in requiring them all to manually specify=
 those
>>> > functions.
>>>
>>> well, it does make sense if you think about the compile vs build ti=
me
>>> overhead. =A0yes, your patch does make things much nicer to read, a=
nd a
>>> little easier to maintain the source. =A0however, it adds runtime o=
verhead
>>> (checking the func pointers) while the func pointer storage is unch=
anged
>>> (it's now a NULL pointer instead of pointing to the genphy funcs).
>>> personally, i think the savings in runtime and smaller compiled cod=
e is
>>> more important. =A0so i'm going to NAK this. =A0sorry.
>>
>> ah, sorry, i was thinking this was u-boot since we were just having
>> conversations there.
>>
>> since this is Linux, and i don't have real standing in the general n=
etdev
>> community, i can't really NAK here. =A0but i think my comment still =
stands in
>> that this patch makes things much worse than the minor code style im=
provement.
>
> I would argue that the PHY layer itself is not remotely a hot-path,
> especially not to the level of caring about an extra if statement. =A0=
A
> single phy_read() is a sleeping call which goes over a slow serial
> bus, so code maintainability is much more important.

i disagree.  ignoring that, what you ultimately desire can be
accomplished without bloating the kernel.

option 1: this can be done in the registration func just like the mtd
layer.  if (!func_pointer) func_pointer =3D default;

option 2: introduce a new macro in the common phy header similar to:
  #define PHY_DRIVER_DEFAULT_FUNCS \
    .config_aneg =3D genphy_config_aneg, \
    .read_status =3D genphy_read_status
and then use that in the phy_driver init structs:
  struct phy_driver bcm5411_driver =3D {
    PHY_DRIVER_DEFAULT_FUNCS,
    .config_aneg =3D bcm5411_config_aneg,
    ...

however, imo, these func pointer arrays really should be in the
=2Erodata section with proper const markers.  this would require
breaking out into a new phy_driver_opts struct since the phy_driver
struct has read/write fields (like the list structure).  option 2
should allow this to work.
-mike
