From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 00/10] net: dsa: add generic debugfs interface
Date: Tue, 29 Aug 2017 22:27:17 +0200
Message-ID: <20170829202717.GE24049@lunn.ch>
References: <20170828191748.19492-1-vivien.didelot@savoirfairelinux.com>
 <20170828195332.GB1950@nanopsycho.orion>
 <20170828200834.GA1870@lunn.ch>
 <20170829062523.GA1977@nanopsycho.orion>
 <20170829125004.GB22093@lunn.ch>
 <8e6fa7ea-fb7b-3026-b9c0-417ef2efae27@mellanox.com>
 <9dd804f2-8d40-2a76-e692-a60b10182834@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arkadi Sharshevsky <arkadis@mellanox.com>,
        Jiri Pirko <jiri@resnulli.us>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Egil Hjelmeland <privat@egil-hjelmeland.no>,
        John Crispin <john@phrozen.org>,
        Woojung Huh <Woojung.Huh@microchip.com>,
        Sean Wang <sean.wang@mediatek.com>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        Chris Healy <cphealy@gmail.com>, mlxsw@mellanox.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <9dd804f2-8d40-2a76-e692-a60b10182834@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 29, 2017 at 12:19:08PM -0700, Florian Fainelli wrote:
> On 08/29/2017 12:05 PM, Arkadi Sharshevsky wrote:
> > 
> > 
> > On 08/29/2017 03:50 PM, Andrew Lunn wrote:
> >> On Tue, Aug 29, 2017 at 08:25:23AM +0200, Jiri Pirko wrote:
> >>> Mon, Aug 28, 2017 at 10:08:34PM CEST, andrew@lunn.ch wrote:
> >>>>> I see this overlaps a lot with DPIPE. Why won't you use that to expose
> >>>>> your hw state?
> >>>>
> >>>> We took a look at dpipe and i talked to you about using it for this
> >>>> sort of thing at netconf/netdev. But dpipe has issues displaying the
> >>>> sort of information we have. I never figured out how to do two
> >>>> dimensional tables. The output of the dpipe command is pretty
> >>>> unreadable. A lot of the information being dumped here is not about
> >>>> the data pipe, etc.
> >>>
> >>> So improve it. No problem. Also, we extend it to support what you neede.
> >>
> >> Will i did try to do this back in March. And i failed.
> >>
> >> Lets start with stats. Vivien gives an example on the cover letter:
> >>
> >>     # pr -mt switch0/port{5,6}/stats
> >>     in_good_octets      : 0             in_good_octets      : 13824
> >>     in_bad_octets       : 0             in_bad_octets       : 0
> >>     in_unicast          : 0             in_unicast          : 0
> >>     in_broadcasts       : 0             in_broadcasts       : 216
> >>     in_multicasts       : 0             in_multicasts       : 0
> >>     in_pause            : 0             in_pause            : 0
> >>     in_undersize        : 0             in_undersize        : 0
> >>
> >> This is what i tried to implement using dpipe. It is a simple two
> >> dimensional table. First column is a string, second a u64. In debugfs
> >> we have such a table per port. That fits with the hierarchy that each
> >> port is a directory in debugfs. But it could also be implemented as
> >> one table with N+1 columns, for N switch ports.
> >>
> > 
> > Hi Andrew,
> > 
> > This looks to me like basic L2 statistics that are obtained via
> > ethtool, I remember you had this problem with the DSA and CPU port.
> > Is this still the case?
> 
> Yes, there are no net_device representors for CPU and DSA ports because
> if we did that, it would be confusing as we would be creating two
> network devices for both ends of the pipe. For DSA (inter-switch)
> interfaces you would have one "dsa" netdev for each adjacent switch so
> two DSA interface represent the inter switch link.
> 
> For the "CPU" port, you have the master network device (e.g: eth0) and
> the "cpu" network device, this is confusing. "cpu" is not usable, since
> it does not make sense for the "cpu" to send traffic via this interface,
> the model is to terminate user-facing ports and use a tag to deliver
> packets to the right interfaces. For "dsa" it's pretty much the same story.

The point of the story is that ethtool does not cover this use
case. We need a different way to expose these statistics for
debugging, and ideally the statistics for all the ports, not just DSA
and CPU.

> > I remembered we wanted to use dpipe for the DSA routing table
> > and IP priority table.

No, we wanted to use dpipe as a generic mechanism to get debug tables
out of the switch. The DSA routing table and the IP priority tables
could be candidates sometime in the future. But since most switches
don't actually have these, we are not so interested in them at the
moment. We are concentrating on tables that all DSA switches are
likely to have. Stuff we can implement once, and it works for all DSA
switches.

> > I think both those processes really look like match/action table
> > , thus they can be modeled successfully by dpipe.

And this is probably the core of the problem with dpipe. Very little
in an average switch is a match/action. We need a generic table. The
table is well specified, in that i can tell you the types of the
columns. We know the number of columns in the table at runtime, but
maybe not the number of rows until we reach the end of the table.  And
ideally, we don't want to have to change the user space tool every
time we add a new table. The type info and the number of columns
should be enough for the user space tool to print it.

       Andrew
