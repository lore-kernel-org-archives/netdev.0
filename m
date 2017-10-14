From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [OpenWrt-Devel] [PATCH v3 0/6] staging: Introduce DPAA2 Ethernet
 Switch driver
Date: Sat, 14 Oct 2017 11:52:30 -0700
Message-ID: <f8b49089-f2db-f7d7-f615-1e4b5082127d@gmail.com>
References: <1507194974-12050-1-git-send-email-razvan.stefanescu@nxp.com>
 <CACRpkdYJCzu9Ph8XMYXt=SSAX+ZaiwXqUGgWX5UvTabmMxmBNQ@mail.gmail.com>
 <CACRpkdazUB_XLv2jYnSiGe9CeVTgjOQ4HfPDL8+CNUVxs-LcLA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>,
 Andrew Lunn <andrew@lunn.ch>, Arnd Bergmann <arnd@arndb.de>,
 Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
 Greg KH <gregkh@linuxfoundation.org>, alexandru.marginean@nxp.com,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Alexander Graf <agraf@suse.de>, stuyoder@gmail.com, bogdan.purcareata@nxp.com,
 laurentiu.tudor@nxp.com
To: Linus Walleij <linus.walleij@linaro.org>,
 Razvan Stefanescu <razvan.stefanescu@nxp.com>,
 OpenWrt Development List <openwrt-devel@lists.openwrt.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <CACRpkdazUB_XLv2jYnSiGe9CeVTgjOQ4HfPDL8+CNUVxs-LcLA@mail.gmail.com>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Hi,

On 10/14/2017 04:09 AM, Linus Walleij wrote:
> Top posting and resending since netdev@vger.kernel.org
> is the right mail address for this. Mea culpa.
> 
> Linus Walleij
> 
> On Sat, Oct 14, 2017 at 11:35 AM, Linus Walleij
> <linus.walleij@linaro.org> wrote:
>> On Thu, Oct 5, 2017 at 11:16 AM, Razvan Stefanescu
>> <razvan.stefanescu@nxp.com> wrote:
>>
>>> This patchset introduces the Ethernet Switch Driver for Freescale/NXP SoCs
>>> with DPAA2 (DataPath Acceleration Architecture v2). The driver manages
>>> switch objects discovered on the fsl-mc bus. A description of the driver
>>> can be found in the associated README file.
>>>
>>> The patchset consists of:
>>> * A set of libraries containing APIs for configuring and controlling
>>>   Management Complex (MC) switch objects
>>> * The DPAA2 Ethernet Switch driver
>>> * Patch adding ethtool support
>>
>> So it appears that ethernet switches is a class of device that need their own
>> subsystem in Linux, before this driver can move out of staging.

FWIW, I think the biggest dependency on this driver is not a switch
driver model because that exists but it's actually the specific bus (MC
AFAICT) that it depends on. More on the Ethernet switch device model below.

We do actually have a pretty good model for Ethernet switches now, in
fact, we got several options:

- Distributed Switching Architecture (DSA) should be used when the
CPU/management Ethernet controller is a traditional Ethernet MAC that is
either internally or externally attached to a switch. This usually comes
with the Ethernet switch capable of providing per-packet metadata (tag)
to indicate to the management interface why the packet is transmitted.
For older/dumber switches, using no management tag, but separating with
802.1Q tags is definitively an option that brings in the same
requirements for DSA. DSA does make use of switchdev to get notified
from the networking stack when there is an opportunity to offload
objects: VLAN, FDB, MDB, etc. DSA is both a device driver model and a
switch device abstraction model.

- switchdev should be used when the management interface is tightly
coupled with the switching hardware, such that, per-packet information
is obtained via DMA/PIO descriptors for instance. switchdev is not a
device driver model so the switch driver is responsible for creating its
own net_device instances and feeding the appropriate netdev_ops,
ethtool_ops and switchdev_ops, this is what is being done here, and this
is also perfectly fine.

>>
>> I ran into the problem in OpenWRT that has these out-of-tree patches for
>> off-chip ethernet switches, conveniently placed under net/phy:
>> https://github.com/openwrt/openwrt/tree/master/target/linux/generic/files/drivers/net/phy
>>
>> These are some 12 different ethernet switches. It is used in more or
>> less every home router out there.

The most deployed switch device drivers have been converted to DSA
already: b53, qca8k (ar83xx in OpenWrt/LEDE) and mtk7530 are all in
tree, and now we are getting new submissions from Michrochip to support
their pretty large KSZ series. Converting from swconfig to DSA is
actually quite simple, but like anything requires time and testing, and
access to hardware and ideally datasheet.

>>
>> It's not really working to have all of this out-of-tree, there must have been
>> discussions about the requirements for a proper ethernet switch subsystem.
>>
>> I'm not a good net developers, just a grumpy user having to deal with all
>> of this out-of-tree code that's not helpful with changing interfaces like
>> device tree and so on.
>>
>> Can you people who worked on this over the years pit in with your
>> requirements for an ethernet switch subsystem so we can house these
>> drivers in a proper way?
>>
>> What we need AFAICT:
>>
>> - Consensus on userspace ABI
>> - Consensus on ethtool extenstions
>> - Consensus on where in drivers/net this goes
>>
>> You can kick me for not knowing what I'm talking about and how complex the
>> problem is now.

Kicking you would not be fair, but you are about 3 years late ;) We had
such discussions in 2014 after a failed attempt at submitting swconfig
as a possible model. 3 years later we have 1 major switchdev driver:
mlxsw and quite a few active DSA drivers. The paradigms that apply are:

- normal Linux tools keep working: bridge, iproute2, ethtool
- every user-visible port has a corresponding network device, in order
to meet the first paradigm
- for every other part of the switch that does not have a net_device
representor, devlink can/should be used.
-- 
Florian
