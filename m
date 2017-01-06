From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH net-next v4 0/4] Fix OdroidC2 Gigabit Tx link issue
Date: Fri, 6 Jan 2017 15:05:35 +0000
Message-ID: <20170106150534.GF14217@n2100.armlinux.org.uk>
References: <1480348229-25672-1-git-send-email-jbrunet@baylibre.com>
 <049b1efc-3bad-92e0-45ef-0563dc5d81de@gmail.com>
 <20170105232508.GU14217@n2100.armlinux.org.uk>
 <1483697496.28003.40.camel@baylibre.com>
 <20170106114226.GX14217@n2100.armlinux.org.uk>
 <1483710621.28003.74.camel@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, Florian Fainelli <f.fainelli@gmail.com>,
 Alexandre TORGUE <alexandre.torgue@st.com>,
 Neil Armstrong <narmstrong@baylibre.com>,
 Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 Yegor Yefremov <yegorslists@googlemail.com>,
 Julia Lawall <julia.lawall@lip6.fr>, devicetree@vger.kernel.org,
 Andre Roth <neolynx@gmail.com>, Kevin Hilman <khilman@baylibre.com>,
 Carlo Caione <carlo@caione.org>, Giuseppe Cavallaro <peppe.cavallaro@st.com>,
 linux-amlogic@lists.infradead.org,
 Andreas =?iso-8859-1?Q?F=E4rber?= <afaerber@suse.de>,
 linux-arm-kernel@lists.infradead.org
To: Jerome Brunet <jbrunet@baylibre.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <1483710621.28003.74.camel@baylibre.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

(quick reply...)

On Fri, Jan 06, 2017 at 02:50:21PM +0100, Jerome Brunet wrote:
> So I'm not sure I understand, are you against EEE integration in phylib
> entirely, or specifically against the test I added in set_eee to filter
> out broken modes ?

I'm happy to see EEE integrated into phylib, but I think the current
implementation is very buggy and needs a rewrite.

> > BTW, one of the problems (not caused by your patch) is that changing
> > the EEE advertisment does not (on all PHY drivers) cause the link to
> > be renegotiated - there's no call to phy_start_aneg() when the advert
> > changes, and even if there was, there's no guarantee that
> > phy_start_aneg() will even set the AN restart bit in the control
> > register.
> > 
> > However, given that you're hooking into the set_eee function, I'm not
> > sure why you placed your EEE advertisment thing into config_aneg() -
> > isn't it more an initialisation thing (so should be in
> > config_init()?)
> 
> What I change is what the PHY advertise, so it seems logical to do it
> where "genphy_config_advert" was called. Just taking the existing code
> as an example

You need to adjust the adverisment in two places:

1. On initialisation, when you need to change the default value.
2. Whenever the user requests a different EEE advertisment.

You don't need to do it each time config_aneg() is called - nothing's
going to change the EEE advertisment in that path.  Hence, to check
it each and every time seems like a waste of CPU cycles.

However, there's another path that needs to be considered, which the
current EEE code fails to do, and that is the resume path.  Nothing
at present saves and restores the EEE settings, they are completely
lost if the PHY is powered down.  This is just another symptom of the
current poor quality EEE implementation in phylib, and another reason
why I say above that the EEE code is in need of a rewrite... which is
something I will be looking at.

If the EEE settings are properly saved and restored over suspend/
resume, then the previously programmed EEE advertisment would also
be restored.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
