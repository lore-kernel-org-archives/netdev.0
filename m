From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: igb and bnx2: "NETDEV WATCHDOG: transmit queue
 timed out" when skb has huge linear buffer
Date: Thu, 6 Feb 2014 09:58:25 +0000
Message-ID: <52F35CC1.60401@citrix.com>
References: <52EAA31B.1090606@schaman.hu>	
	<1391114048.4804.2.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>	
	<52EBA51E.808@citrix.com>
	<1391543271.4804.44.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	<52F29DDC.7010908@citrix.com> <52F2A282.5040502@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Carolyn, Tushar,
	e1000-devel@lists.sourceforge.net, Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	John Ronciak <john.ronciak@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>, Peter
To: Andrew Cooper <andrew.cooper3@citrix.com>, Michael Chan
	<mchan@broadcom.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <52F2A282.5040502@citrix.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 05/02/14 20:43, Andrew Cooper wrote:
> On 05/02/2014 20:23, Zoltan Kiss wrote:
>> On 04/02/14 19:47, Michael Chan wrote:
>>> On Fri, 2014-01-31 at 14:29 +0100, Zoltan Kiss wrote:
>>>> [ 5417.275472] WARNING: at net/sched/sch_generic.c:255
>>>> dev_watchdog+0x156/0x1f0()
>>>> [ 5417.275474] NETDEV WATCHDOG: eth1 (bnx2): transmit queue 2 timed out
>>>
>>> The dump shows an internal IRQ pending on MSIX vector 2 which matches
>>> the the queue number that is timing out.  I don't know what happened to
>>> the MSIX and why the driver is not seeing it.  Do you see an IRQ error
>>> message from the kernel a few seconds before the tx timeout message?
>>
>> I haven't seen any IRQ related error message. Note, this is on Xen
>> 4.3.1. Now I have new results with a reworked version of the patch,
>> unfortunately it still has this issue. Here is a bnx2 dump, lspci
>> output and some Xen debug output (MSI and interrupt bindings, I have
>> more if needed).
>
> You need debug-keys 'Q' as well to map between the PCI devices and Xen IRQs
>
> ~Andrew
>

I could have it after reboot:

(XEN) [2014-02-06 09:44:34] 0000:02:00.0 - dom 0   - MSIs < 64 65 66 67 
68 69 >

So the relevant MSI informations:

(XEN) [2014-02-05 20:15:20]  MSI-X   64 vec=d7  fixed  edge   assert 
phys    cpu dest=00000022 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI-X   65 vec=ba  fixed  edge   assert 
phys    cpu dest=00000000 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI-X   66 vec=92  fixed  edge   assert 
phys    cpu dest=00000022 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI-X   67 vec=3a  fixed  edge   assert 
phys    cpu dest=00000021 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI-X   68 vec=b8  fixed  edge   assert 
phys    cpu dest=00000022 mask=1/0/0
(XEN) [2014-02-05 20:15:20]  MSI-X   69 vec=2a  fixed  edge   assert 
phys    cpu dest=00000020 mask=1/1/1
...
(XEN) [2014-02-05 20:15:22]    IRQ:  64 affinity:00000004 vec:d7 
type=PCI-MSI/-X      status=00000030 in-flight=0 domain-list=0:304(---),
(XEN) [2014-02-05 20:15:22]    IRQ:  65 affinity:00000100 vec:ba 
type=PCI-MSI/-X      status=00000010 in-flight=0 domain-list=0:303(---),
(XEN) [2014-02-05 20:15:22]    IRQ:  66 affinity:00000004 vec:92 
type=PCI-MSI/-X      status=00000010 in-flight=0 domain-list=0:302(---),
(XEN) [2014-02-05 20:15:22]    IRQ:  67 affinity:00000002 vec:3a 
type=PCI-MSI/-X      status=00000010 in-flight=0 domain-list=0:301(---),
(XEN) [2014-02-05 20:15:22]    IRQ:  68 affinity:00000004 vec:b8 
type=PCI-MSI/-X      status=00000030 in-flight=0 domain-list=0:300(---),
(XEN) [2014-02-05 20:15:22]    IRQ:  69 affinity:00000001 vec:2a 
type=PCI-MSI/-X      status=00000002 mapped, unbound


Zoli

------------------------------------------------------------------------------
Managing the Performance of Cloud-Based Applications
Take advantage of what the Cloud has to offer - Avoid Common Pitfalls.
Read the Whitepaper.
http://pubads.g.doubleclick.net/gampad/clk?id=121051231&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
