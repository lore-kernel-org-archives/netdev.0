From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: e1000 and PBA
Date: Mon, 24 Nov 2008 13:23:43 -0800
Message-ID: <F169D4F5E1F1974DBFAFABF47F60C10A1714B109@orsmsx507.amr.corp.intel.com>
References: <1d380c73ba9296d4277c279e9808e84a.webmail@www.varna.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "nik-lists@varna.net" <nik-lists@varna.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1d380c73ba9296d4277c279e9808e84a.webmail@www.varna.net>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

nik-lists@varna.net wrote:
> I am experiencing rx_missed_errors with Intel 82541 based gige and
> e1000 
> 8.0.6  on 32Bbit 33MHz PCI. In my opinion, the network load is not so
> heavy - 15 kpps and 90 Mbit/s at peaktimes. CPU load is no more than
> 30%. I know it is old hardware (Athlon@1725), but sill, it should be

what other devices do you have on the PCI bus?  Since there are different
versions of this part having a device ID here in the discussion would
help.  Also, you may want to try setting InterruptThrottleRate=8000 at
driver load time to set the interrupt rate, if and only if you're also
seeing rx_no_buffer errors.  If the packets are being dropped due to
too low an interrupt rate, then both counters will go.

> able to handle this amount of traffic - here is no shaping, and there
> is hardly any firewall rules. After lot of reading in maillists and
> forums, my conclusion is that the bottleneck is in the RX FIFO
> buffers. Therefore, I want to try increasing the RX PBA size. How can
> I check how much is the overall PBS, which is split for TX/RX buffers

The total size is 64KB or 48KB, but see below.

> by the driver? According to the source, PBA is read from the card
> registers in the e1000_reset function. Can I check this value somehow
> with ethtool ? Maybe after I know how much PBS is available, I will
> be able to calculate how much RX FIFO will be left if I need only 4K
> TX FIFO (pretty enough for full wire-speed transmitting according to
> the tdriver source). 

the upper 16 bits is always the transmit space and is automatically 
configured by subtracting the lower 16 bits value from the maximum
value.  so, if you have 64KB (0x40), and you want to have 4KB transmit 
fifo, E1000_WRITE_REG(hw, E1000_PBA, 0x3C)

so the upper and lower 16 bits added together gives you the size in KB
of the total FIFO.

Hope this helps, and maybe you can take a look at the reference manuals 
at e1000.sourceforge.net

I also suggest that you can download the ethregs utility and try it as
well, it outputs this:
# ethregs -s 4:2.0|grep PBA
        PBA            00100030

I suggest you change the line
    560         switch (mac->type) {
    561         case e1000_82542:
    562         case e1000_82543:
    563         case e1000_82544:
    564         case e1000_82540:
    565         case e1000_82541:
    566         case e1000_82541_rev_2:
    567                 legacy_pba_adjust = TRUE;
>>>>568                 pba = E1000_PBA_48K;
    569                 break;

to pba = 60;

you may need to try using 56 instead of 60 because there may be an 8K boundary
requirement but I didn't see it in the manual when I quickly looked.

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
