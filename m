From: "Christopher Hall" <christopher.s.hall@intel.com>
Subject: Re: [PATCH v4 1/4] Produce system time from correlated clocksource
Date: Wed, 14 Oct 2015 19:34:03 -0700
Message-ID: <op.x6iz21fw1774gr@chall-mobl2.amr.corp.intel.com>
References: <1444675522-4198-1-git-send-email-christopher.s.hall@intel.com>
 <1444675522-4198-2-git-send-email-christopher.s.hall@intel.com>
 <20151013045832.GA2437@netboy> <alpine.DEB.2.11.1510130944520.6097@nanos>
 <20151013083113.GA1931@localhost.localdomain>
 <alpine.DEB.2.11.1510132113470.25029@nanos> <20151013211224.GA19242@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, hpa@zytor.com, mingo@redhat.com,
	john.stultz@linaro.org, peterz@infradead.org, x86@kernel.org,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kevin.b.stanton@intel.com
To: "Thomas Gleixner" <tglx@linutronix.de>,
	"Richard Cochran" <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151013211224.GA19242@netboy>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Richard,

On Tue, 13 Oct 2015 14:12:24 -0700, Richard Cochran  
<richardcochran@gmail.com> wrote:
> On Tue, Oct 13, 2015 at 09:15:51PM +0200, Thomas Gleixner wrote:

> Can we at least have a explanation of how the firmware operates?  How
> are (ART,sys) pairs are generated, and how they are supposed to get
> into the DSP?

I'll give it a try. The audio controller has a set of registers almost  
exactly like those on the network device. The e1000e patch adds the  
e1000e_phc_get_ts() function. It writes a register to start the  
cross-timestamp process and some time later the hardware sets a bit  
indicating that it's finished.

In the case of the network, the host polls for this bit to be set,  
indicating the cross-timestamp registers have valid data.  In the audio  
DSP case, it is the DSP that's doing the polling and it can only poll once  
per millisecond.

The transfers look like:

Host -PCI (write request) -> DSP

[Transaction started from host]

DSP -PCI (write to initiate)-> Audio controller

[Transaction started from DSP]

DSP <-PCI (read to poll status)- Audio Controller

[Transaction Complete from DSP perspective]

DSP <-PCI (read (ART,device) pair)- Audio Controller

DSP -PCI (write notification) -> Host

[Transaction complete from Host perspective]

Host <-PCI read (ART,device) pair- DSP


I hope this is helpful. Thanks.

Chris
