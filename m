From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: Improving OCTEON II 10G Ethernet performance
Date: Thu, 25 Aug 2016 09:50:15 -0700
Message-ID: <57BF21C7.5070709@caviumnetworks.com>
References: <CAO_EM_nrb0M49YwU+gjL+bqT4V1rFj4z7DQ8juTYXgaoKet0mg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-mips <linux-mips@linux-mips.org>,
        driverdev-devel <devel@driverdev.osuosl.org>,
        netdev <netdev@vger.kernel.org>,
        Aaro Koskinen <aaro.koskinen@nokia.com>
To: Ed Swierk <eswierk@skyportsystems.com>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <CAO_EM_nrb0M49YwU+gjL+bqT4V1rFj4z7DQ8juTYXgaoKet0mg@mail.gmail.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

On 08/24/2016 06:29 PM, Ed Swierk wrote:
> I'm trying to migrate from the Octeon SDK to a vanilla Linux 4.4
> kernel for a Cavium OCTEON II (CN6880) board running in 64-bit
> little-endian mode. So far I've gotten most of the hardware features I
> need working, including XAUI/RXAUI, USB, boot bus and I2C, with a
> fairly small set of patches.
> https://github.com/skyportsystems/linux/compare/master...octeon2
>

It is unclear what your motivations for doing this are, so I can think 
of several things you could do:

A) Get v4.4 based SDK from Cavium.

B) Major rewrite of octeon-ethernet driver.

C) Live with current staging driver.

> The biggest remaining hurdle is improving 10G Ethernet performance:
> iperf -P 10 on the SDK kernel gets close to 10 Gbit/sec throughput,
> while on my 4.4 kernel, it tops out around 1 Gbit/sec.
>
> Comparing the octeon-ethernet driver in the SDK
> (http://git.yoctoproject.org/cgit/cgit.cgi/linux-yocto-contrib/tree/drivers/net/ethernet/octeon?h=apaliwal/octeon)
> against the one in 4.4, the latter appears to utilize only a single
> CPU core for the rx path. It's not clear to me if there is a similar
> issue on the tx side, or other bottlenecks.

The main limiting factor to performance is single threaded RX 
processing.  The main manner this is handled in the out-of-tree vendor 
driver is to have multiple NAPI processing threads running against the 
same RX queue when there is a queue backlog.  The disadvantage of doing 
this is that packets may be received out of order due to 
non-synchronization across multiple CPUs.

On the TX side, the locks on the queuing discipline can become contended 
leading to cache line bouncing.  In the TX code of the driver itself, 
there should be no impediments to parallel TX operations.

Ideally we would configure the packet classifiers on the RX side to 
create multiple RX queues based on a hash of the TCP 5-tuple, and handle 
each queue with a single NAPI instance.  That should result in better 
performance while maintaining packet ordering.


>
> I started trying to port multi-CPU rx from the SDK octeon-ethernet
> driver, but had trouble teasing out just the necessary bits without
> following a maze of dependencies on unrelated functions. (Dragging
> major parts of the SDK wholesale into 4.4 defeats the purpose of
> switching to a vanilla kernel, and doesn't bring us closer to getting
> octeon-ethernet out of staging.)

Yes, you have identified the main problem with this code.

All the code managing the SerDes and other MAC functions needs a 
complete rewrite.  One main problem is that all the SerDes/MACs in the 
system are configured simultaneously instead of on a per device basis. 
There are also a plethora of different SerDes technologies in use: 
(RGMII, SGMII, QSGMII, XFI, XAUI, RXAUI, SPI-4.1, XLAUI, KR, ...)  The 
code that handles all of these is mixed together with huge case 
statements switching on interface mode all over the place.

There is also code to handle target-mode PCI/PCIe packet engines mixed 
in as well.  This stuff should probably be removed.


>
> Has there been any work on the octeon-ethernet driver since this patch
> set? https://www.linux-mips.org/archives/linux-mips/2015-08/msg00338.html
>
> Any hints on what to pick out of the SDK code to improve 10G
> performance would be appreciated.
>
> --Ed
>
