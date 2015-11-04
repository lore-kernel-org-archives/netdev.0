From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v2 2/4] e1000e: Do not read icr in Other interrupt
Date: Wed, 4 Nov 2015 15:26:22 -0800
Message-ID: <563A941E.1070209@gmail.com>
References: <1446226264-29660-1-git-send-email-bpoirier@suse.com>
 <1446226264-29660-3-git-send-email-bpoirier@suse.com>
 <5633C2A4.90002@gmail.com> <20151104231945.GA7111@f1.synalogic.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Frank Steiner <steiner-reg@bio.ifi.lmu.de>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Matthew Vick <matthew.vick@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Benjamin Poirier <bpoirier@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151104231945.GA7111@f1.synalogic.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/04/2015 03:19 PM, Benjamin Poirier wrote:
> On 2015/10/30 12:19, Alexander Duyck wrote:
>> On 10/30/2015 10:31 AM, Benjamin Poirier wrote:
>>> Using eiac instead of reading icr allows us to avoid interference with
>>> rx and tx interrupts in the Other interrupt handler.
>>>
>>> According to the 82574 datasheet section 10.2.4.1, interrupt causes that
>>> trigger the Other interrupt are
>>> 1) Link Status Change.
>>> 2) Receiver Overrun.
>>> 3) MDIO Access Complete.
>>> 4) Small Receive Packet Detected.
>>> 5) Receive ACK Frame Detected.
>>> 6) Manageability Event Detected.
>>>
>>> Causes 3, 4, 5 are related to features which are not enabled by the
>>> driver. Always assume that cause 1 is what triggered the Other interrupt
>>> and set get_link_status. Cause 2 and 6 should be rare enough that the
>>> extra cost of needlessly re-reading the link status is negligible.
>>>
>>> Signed-off-by: Benjamin Poirier <bpoirier@suse.com>
>> You might want to instead use a write of LSC to the ICR instead of just
>> using auto-clear and not enabling LSC.  My concern is that you might no
>> longer be getting link status change events at all.  An easy test is to just
>> unplug/plug the cable a few times, or run "ethtool -r" on the link partner
>> if connected back to back.  You should see messages appear in the dmesg log
>> indicating that the link state changed.
>>
>> In addition you should probably clear the IAME bit in the CTRL_EXT register
>> so that you don't risk masking the interrupts on the ICR read or write.
> Thanks, your concern about not getting LSC events was right. After more
> experimentation I noticed that in order for the Other interrupt to be
> raised for each of these six conditions, the IMS bit for that condition
> must also be set. I've restored setting LSC in IMS. OTOH, I don't see a
> need to clear LSC from ICR. Even without an ICR read or write-to-clear
> to clear the LSC bit, Other interrupts are raised to signal LSC events.
>
> I'll wait for net-next to reopen and send v3.

You probably don't need to wait.  The Intel-wired tree operates outside 
of Dave's merge window, and it will take some time for the patches to be 
validated before the Jeff can submit them to Dave.

- Alex
