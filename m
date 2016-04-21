From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH] ixgbevf: Fix relaxed order settings in VF driver
Date: Thu, 21 Apr 2016 14:00:46 -0700
Message-ID: <CAKgT0UcEYva0oDX0ZOz97hrmrF=t1Lv7sqq1Ut4bQ2p7GLkeDQ@mail.gmail.com>
References: <1461259276-54151-1-git-send-email-babu.moger@oracle.com>
	<CAKgT0UeU+Q1HDvR8pK3kxYofjEqk8jVeh5xONoUpD34MsPZCCA@mail.gmail.com>
	<CAKgT0UdEP9ZMnNjSSqh-vZvaEc9N8_X_KWvykChxRv1bretYtw@mail.gmail.com>
	<57192C7D.9080507@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	shannon nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	Bruce W Allan <bruce.w.allan@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: Babu Moger <babu.moger@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <57192C7D.9080507@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 21, 2016 at 12:39 PM, Babu Moger <babu.moger@oracle.com> wrote:
> Hi Alex,
>
> On 4/21/2016 2:22 PM, Alexander Duyck wrote:
>> On Thu, Apr 21, 2016 at 11:13 AM, Alexander Duyck
>> <alexander.duyck@gmail.com> wrote:
>>> On Thu, Apr 21, 2016 at 10:21 AM, Babu Moger <babu.moger@oracle.com> wrote:
>>>> Current code writes the tx/rx relaxed order without reading it first.
>>>> This can lead to unintended consequences as we are forcibly writing
>>>> other bits.
>>>
>>> The consequences were very much intended as there are situations where
>>> enabling relaxed ordering can lead to data corruption.
>>>
>>>> We noticed this problem while testing VF driver on sparc. Relaxed
>>>> order settings for rx queue were all messed up which was causing
>>>> performance drop with VF interface.
>>>
>>> What additional relaxed ordering bits are you enabling on Sparc?  I'm
>>> assuming it is just the Rx data write back but I want to verify.
>>>
>>>> Fixed it by reading the registers first and setting the specific
>>>> bit of interest. With this change we are able to match the bandwidth
>>>> equivalent to PF interface.
>>>>
>>>> Signed-off-by: Babu Moger <babu.moger@oracle.com>
>>>
>>> Fixed is a relative term here since you are only chasing performance
>>> from what I can tell.  We need to make certain that this doesn't break
>>> the driver on any other architectures by leading to things like data
>>> corruption.
>>>
>>> - Alex
>>
>> It occurs to me that what might be easier is instead of altering the
>> configuration on all architectures you could instead wrap the write so
>> that on SPARC you include the extra bits you need and on all other
>> architectures you leave the write as-is similar to how the code in the
>> ixgbe_start_hw_gen2 only clears the bits if CONFIG_SPARC is not
>> defined.
>
>
> Here are the default values that I see when testing on Sparc.
>
> Default tx value 0x2a00
>
> All below 3 set
> #define IXGBE_DCA_TXCTRL_DESC_RRO_EN (1 << 9) /* Tx rd Desc Relax Order */
> #define IXGBE_DCA_TXCTRL_DESC_WRO_EN (1 << 11) /* Tx Desc writeback RO bit */
> #define IXGBE_DCA_TXCTRL_DATA_RRO_EN (1 << 13) /* Tx rd data Relax Order */
>
> I am not too worried about tx values. I can keep it as it is. It did not
> seem to cause any problems right now.
>
>
> Default rx value 0xb200
>
> All below 3 set plus one more
>
> #define IXGBE_DCA_RXCTRL_DESC_RRO_EN (1 << 9) /* DCA Rx rd Desc Relax Order */
> #define IXGBE_DCA_RXCTRL_DATA_WRO_EN (1 << 13) /* Rx wr data Relax Order */
> #define IXGBE_DCA_RXCTRL_HEAD_WRO_EN (1 << 15) /* Rx wr header RO */

So that looks like the register defaults.  Which based on the released
data-sheet for 82599 are a bit off.  The "one more" bit that is set is
supposed to be written as 0 as per the 82599 datasheet, but it
defaults to 1 for some reason.  On the x540 data-sheet that appears to
be a no-snoop bit that you are enabling which should not be enabled.
It won't necessarily hurt things either though as I believe the
no-snoop bit is not being set in the descriptors.

> Is there a reason to disable IXGBE_DCA_RXCTRL_DATA_WRO_EN and
> IXGBE_DCA_RXCTRL_HEAD_WRO_EN for RX?

In the case of HEAD_WRO_EN it doesn't give us anything because we
don't have packet split/replication enabled anyway.  That feature is
broken on the 82599, and was deprecated some time ago in the ixgbe
driver.

I don't have the fully history on the data writeback but I believe
there was an issue of where some x86 chipsets had issues when the
device enabled relaxed ordering.  That was why relaxed ordering was
disabled on all writes for the device.  I was the one that went
through and re-enabled relaxed ordering on reads from the device so we
at least allowed that much on most architectures.

You would probably only need to add IXGBE_DCA_RXCTRL_DATA_WRO_EN to
the write in the case of CONFIG_SPARC being defined.  Another approach
might be to have a define value that you end up passing that is
defined one way if SPARC and another if a different architecture.

> I would think CONFIG_SPARC should be our last option. What do you think?

I was thinking CONFIG_SPARC would allow us to have feature parity with
the PF.  If you look that is how this issue is solved there in
function ixgbe_start_hw_gen2().  That was why I was thinking that may
be the approach we want to take.  Otherwise we have to write up some
complicated setup where we would have to use the API in order to
determine if the PF has already taken care of this for us which I
would prefer not to have to do.

- Alex
