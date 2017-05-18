From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [RFC V1 1/1] net: cdc_ncm: Reduce memory use when kernel memory
 low
Date: Thu, 18 May 2017 12:01:52 +0200
Message-ID: <1495101712.6672.4.camel@suse.com>
References: <1494956480-6127-1-git-send-email-jim_baxter@mentor.com>
         <1494956480-6127-2-git-send-email-jim_baxter@mentor.com>
         <87shk4fynp.fsf@miraculix.mork.no>
         <20170517.141819.1307166900606639947.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: jim_baxter@mentor.com, linux-kernel@vger.kernel.org,
        linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, bjorn@mork.no
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170517.141819.1307166900606639947.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Mittwoch, den 17.05.2017, 14:18 -0400 schrieb David Miller:
> From: Bjørn Mork <bjorn@mork.no>
> Date: Tue, 16 May 2017 20:24:10 +0200
> 
> > Jim Baxter <jim_baxter@mentor.com> writes:
> > 
> >> The CDC-NCM driver can require large amounts of memory to create
> >> skb's and this can be a problem when the memory becomes fragmented.
> >>
> >> This especially affects embedded systems that have constrained
> >> resources but wish to maximise the throughput of CDC-NCM with 16KiB
> >> NTB's.
> >>
> >> The issue is after running for a while the kernel memory can become
> >> fragmented and it needs compacting.
> >> If the NTB allocation is needed before the memory has been compacted
> >> the atomic allocation can fail which can cause increased latency,
> >> large re-transmissions or disconnections depending upon the data
> >> being transmitted at the time.
> >> This situation occurs for less than a second until the kernel has
> >> compacted the memory but the failed devices can take a lot longer to
> >> recover from the failed TX packets.
> >>
> >> To ease this temporary situation I modified the CDC-NCM TX path to
> >> temporarily switch into a reduced memory mode which allocates an NTB
> >> that will fit into a USB_CDC_NCM_NTB_MIN_OUT_SIZE (default 2048 Bytes)
> >> sized memory block and only transmit NTB's with a single network frame
> >> until the memory situation is resolved.
> >> Once the memory is compacted the CDC-NCM data can resume transmitting
> >> at the normal tx_max rate once again.
> > 
> > I must say that I don't like the additional complexity added here.  If
> > there are memory issues and you can reduce the buffer size to
> > USB_CDC_NCM_NTB_MIN_OUT_SIZE, then why don't you just set a lower tx_max
> > buffer size in the first place?
> > 
> >   echo 2048 > /sys/class/net/wwan0/cdc_ncm/tx_max
> 
> When there isn't memory pressure this will hurt performance of
> course.
> 
> It is a quite common paradigm to back down to 0 order memory requests
> when higher order ones fail, so this isn't such a bad change from the
> perspective.
> 
> However, one negative about it is that when the system is under memory
> stress it doesn't help at all to keep attemping high order allocations
> when the system hasn't recovered yet.  In fact, this can make it
> worse.

This makes me wonder why there is no notifier chain for this.
Or am I just too stupid to find it?

	Regards
		Oliver
