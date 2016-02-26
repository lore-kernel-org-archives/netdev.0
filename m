From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 7/9] net: dsa: mv88e6xxx: restore VLANTable map control
Date: Fri, 26 Feb 2016 16:37:39 -0500
Message-ID: <87d1rj6tlo.fsf@ketchup.mtl.sfl>
References: <1456510568-13679-1-git-send-email-vivien.didelot@savoirfairelinux.com> <1456510568-13679-8-git-send-email-vivien.didelot@savoirfairelinux.com> <56D0B964.4090002@elecsyscorp.com> <20160226210419.GA1560@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"kernel\@savoirfairelinux.com" <kernel@savoirfairelinux.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Neil Armstrong <narmstrong@baylibre.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Russell King <rmk+kernel@arm.linux.org.uk>
To: Andrew Lunn <andrew@lunn.ch>,
	Kevin Smith <kevin.smith@elecsyscorp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160226210419.GA1560@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Kevin, Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> On Fri, Feb 26, 2016 at 08:45:28PM +0000, Kevin Smith wrote:
>> Hi Vivien,
>> 
>> On 02/26/2016 12:16 PM, Vivien Didelot wrote:
>> > +	/* allow CPU port or DSA link(s) to send frames to every port */
>> > +	if (dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port)) {
>> > +		output_ports = mask;
>> > +	} else {
>
>> Is this always correct?  Are there situations where a CPU or neighboring 
>> switch should not be allowed to access another port? (e.g. Figure 6 or 7 
>> in the 88E6352 functional specification).

Given Linux expectations (described below by Andrew) I'd say yes, this
is always correct. But I'd be curious to know if someone has counter
examples for this.

> What do these figures show?

The figure shows the following VLANTable config:

Port  0  1  2  3  4  5  6
  0   -  *  *  *  -  -  *
  1   *  -  *  *  -  -  *
  2   *  *  -  *  -  -  *
  3   *  *  *  -  -  -  *
  4   -  -  -  -  -  *  -
  5   -  -  -  -  *  -  -
  6   *  *  *  *  -  -  -

There is two independant groups: 0, 1, 2, 3, 6 (LAN, 6 is CPU/Router),
and 4, 5 (4 is WAN and 5 is CPU/Router):

Port #   Port Type     VLANTable Setting
0        LAN           0x4E
1        LAN           0x4D
2        LAN           0x4B
3        LAN           0x47
4        WAN           0x20
5        CPU           0x10
6        CPU           0x0F

> The CPU port needs to be able to send to each external port. The whole
> DSA concept is that Linux has a netdev per external port, and can send
> frames using the netdev out a specific port. Such frames have a DSA
> header indicating which port they are destined to.  When you have a
> multi chip setup, the frame needs to traverse DSA ports.

This current patch produces to following setup at setup:

Port  0  1  2  3  4  5  6
  0   -  -  -  -  -  *  *
  1   -  -  -  -  -  *  *
  2   -  -  -  -  -  *  *
  3   -  -  -  -  -  *  *
  4   -  -  -  -  -  *  *
  5   *  *  *  *  *  -  *
  6   *  *  *  *  *  *  -

Here, 5 is the CPU port and 6 is a DSA port.

After joining ports 0, 1, 2 in the same bridge, we end up with:

Port  0  1  2  3  4  5  6
  0   -  *  *  -  -  *  *
  1   *  -  *  -  -  *  *
  2   *  *  -  -  -  *  *
  3   -  -  -  -  -  *  *
  4   -  -  -  -  -  *  *
  5   *  *  *  *  *  -  *
  6   *  *  *  *  *  *  -

Thanks,
-v
