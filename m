From: Philip Prindeville <philipp_subx@redfish-solutions.com>
Subject: Re: [PATCH 5/5] e1000e: Avoid receiver overrun interrupt bursts
Date: Fri, 11 Aug 2017 20:47:14 -0600
Message-ID: <C95AF637-ACAB-4EA9-A287-8DB99A83B830@redfish-solutions.com>
References: <20170721160937.GA22632@csclub.uwaterloo.ca>
 <20170721183627.13373-1-bpoirier@suse.com>
 <20170721183627.13373-5-bpoirier@suse.com>
 <20170721184848.GU18556@csclub.uwaterloo.ca>
 <49B1F3E9-2A99-4AD6-9574-FC3960E67A77@redfish-solutions.com>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: Benjamin Poirier <bpoirier@suse.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <49B1F3E9-2A99-4AD6-9574-FC3960E67A77@redfish-solutions.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> On Aug 11, 2017, at 8:13 PM, Philip Prindeville <philipp_subx@redfish-solutions.com> wrote:
> 
>> 
>> On Jul 21, 2017, at 12:48 PM, Lennart Sorensen <lsorense@csclub.uwaterloo.ca> wrote:
>> 
>> On Fri, Jul 21, 2017 at 11:36:27AM -0700, Benjamin Poirier wrote:
>>> When e1000e_poll() is not fast enough to keep up with incoming traffic, the
>>> adapter (when operating in msix mode) raises the Other interrupt to signal
>>> Receiver Overrun.
>>> 
>>> This is a double problem because 1) at the moment e1000_msix_other()
>>> assumes that it is only called in case of Link Status Change and 2) if the
>>> condition persists, the interrupt is repeatedly raised again in quick
>>> succession.
>>> 
>>> Ideally we would configure the Other interrupt to not be raised in case of
>>> receiver overrun but this doesn't seem possible on this adapter. Instead,
>>> we handle the first part of the problem by reverting to the practice of
>>> reading ICR in the other interrupt handler, like before commit 16ecba59bc33
>>> ("e1000e: Do not read ICR in Other interrupt"). Thanks to commit
>>> 0a8047ac68e5 ("e1000e: Fix msi-x interrupt automask") which cleared IAME
>>> from CTRL_EXT, reading ICR doesn't interfere with RxQ0, TxQ0 interrupts
>>> anymore. We handle the second part of the problem by not re-enabling the
>>> Other interrupt right away when there is overrun. Instead, we wait until
>>> traffic subsides, napi polling mode is exited and interrupts are
>>> re-enabled.
>>> 
>>> Reported-by: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
>>> Fixes: 16ecba59bc33 ("e1000e: Do not read ICR in Other interrupt")
>>> Signed-off-by: Benjamin Poirier <bpoirier@suse.com>
>> 
>> Any chance of this fix hitting -stable?  After all adapter reset under
>> load is not nice.
>> 
> 
> 
> I tried this patch sequence and I’m seeing a 2% drop in throughput.  CPU utilization at softIRQ is also about 8% higher.  The previous single patch that went out to fix this problem had better performance.
> 
> This is on an Atom D525 with an 82574L and running 2 GB streams across a pair of interfaces with iperf3.
> 
> -Philip


Actually, after turning off MSI-X mode (and using MSI mode instead), and setting InterruptRateThrottle to “4” (conservative dynamic mode) across all interfaces, I’m actually seeing slightly better throughput than the earlier patch… with comparable overall CPU utilization and SoftIRQ utilization.

So setting the module parameters correctly for routing (and not end-system parameters) makes a big difference when routing.

-Philip
