From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: behaviour question for igb on nehalem box
Date: Fri, 09 Oct 2009 16:48:56 -0700
Message-ID: <4ACFCBE8.7060108@intel.com>
References: <4ACF8466.5030309@nortel.com>	<alpine.WNT.2.00.0910091250440.5328@jbrandeb-desk1.amr.corp.intel.com>	<4ACFB9DF.9080909@nortel.com>
	<4ACFC52F.4050509@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-list <e1000-devel@lists.sourceforge.net>,
	Linux Network Development list <netdev@vger.kernel.org>, "Allan,
	Bruce W" <bruce.w.allan@intel.com>, "Brandeburg,
	Jesse" <jesse.brandeburg@intel.com>, "Ronciak,
	John" <john.ronciak@intel.com>, "Kirsher,
	Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <4ACFC52F.4050509@intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Alexander Duyck wrote:
> Chris Friesen wrote:
>> On 10/09/2009 02:22 PM, Brandeburg, Jesse wrote:
>>> On Fri, 9 Oct 2009, Chris Friesen wrote:
>>>> I've got some general questions around the expected behaviour of the
>>>> 82576 igb net device.  (On a dual quad-core Nehalem box, if it matters.)
>>> the hardware you have only supports 8 
>>> queues (rx and tx) and the driver is configured to only set up 4 max.
>> The datasheet for the 82576 says 16 tx queues and 16 rx queues.  Is that
>> a typo or do we have the economy version?
> 
> Actually the limitation is due to the fact that there are only 10 
> interrupts available.  On kernels that support TX multi-queue the number 
> of queues would be 4 TX and 4 RX, which would consume 8 interrupts 
> leaving 1 for the link status change and one unused.
> 
> However on the kernel you are using I don't believe multi-queue NAPI is 
> enabled so you shouldn't have multiple RX queues either.  On a 2.6.18 
> kernel you should have only 1 RX and 1 TX queue unless you are using the 
> driver provided on e1000.sourceforge.net which uses fake netdevs to 
> support multi-queue NAPI.  I believe this may be a bug that was 
> introduced when SR-IOV support was back-ported from the 2.6.30 kernel.

Actually after looking closer at the Redhat source it looks like they 
have done the fake netdev workaround in their own code so I guess igb 
driver in the RHEL kernel does support multiple RX queues.

>>>> My second question is around how the rx queues are mapped to interrupts.
>>>>  According to /proc/interrupts there appears to be a 1:1 mapping between
>>>> queues and interrupts.  However, I've set up at test with a given amount
>>>> of traffic coming in to the device (from 4 different IP addresses and 4
>>>> ports).  Under this scenario, "ethtool -S" shows the number of packets
>>>> increasing for only rx queue 0, but I see the interrupt count going up
>>>> for two interrupts.
>>> one transmit interrupt and one receive interrupt?
>> No, two rx interrupts.  (Can't remember if the tx interrupt was going up
>> as well or no...was only looking at rx.)
> 
> This may be due to the bug I mentioned above.  Multiple RX queues 
> shouldn't be present on the 2.6.18 kernel as I do not believe 
> multi-queue NAPI has been back-ported and it could have negative effects.

The odds of any 2 flows overlapping when you are only using 4 flows is 
pretty high, especially if the addresses/ports are close in range.  You 
typically need something on the order of about 16 flows over a wide 
range of port numbers in order to get a good distribution.

Thanks,

Alex




------------------------------------------------------------------------------
Come build with us! The BlackBerry(R) Developer Conference in SF, CA
is the only developer event you need to attend this year. Jumpstart your
developing skills, take BlackBerry mobile applications to market and stay 
ahead of the curve. Join us from November 9 - 12, 2009. Register now!
http://p.sf.net/sfu/devconference
