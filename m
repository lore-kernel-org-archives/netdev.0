From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 1/2] igb: Allow extra 4 bytes on RX for vlan tags.
Date: Thu, 25 Aug 2011 11:51:05 -0700
Message-ID: <4E569999.8050006@candelatech.com>
References: <1297375149-18458-1-git-send-email-greearb@candelatech.com>	<AANLkTinsWRAJ2bepa1NjQ4f0Wz46DaxWO6f_nEbmBAB0@mail.gmail.com>	<4D5D5AD8.5000802@candelatech.com>	<CAEP_g=_o7nP2FCnPufyT44JZZ+Z+jkcVpSa8Qj3mjPn+MwRhXA@mail.gmail.com>	<4E277267.8090702@candelatech.com>	<1311211304.2401.9.camel@jtkirshe-mobl> <CAKgT0UfaEEvRTSpu-U+0_oj0KnEkyx5hRAwZDiCAAdtY4YhQUQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, Jesse Gross <jesse@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:41214 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753946Ab1HYSvK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 14:51:10 -0400
In-Reply-To: <CAKgT0UfaEEvRTSpu-U+0_oj0KnEkyx5hRAwZDiCAAdtY4YhQUQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/20/2011 11:35 PM, Alexander Duyck wrote:
> On Wed, Jul 20, 2011 at 6:21 PM, Jeff Kirsher
> <jeffrey.t.kirsher@intel.com>  wrote:
>> On Wed, 2011-07-20 at 17:27 -0700, Ben Greear wrote:
>>> On 07/20/2011 05:18 PM, Jesse Gross wrote:
>>>> On Thu, Feb 17, 2011 at 9:28 AM, Ben Greear<greearb@candelatech.com>    wrote:
>>>>> On 02/17/2011 03:04 AM, Jeff Kirsher wrote:
>>>>>>
>>>>>> On Thu, Feb 10, 2011 at 13:59,<greearb@candelatech.com>      wrote:
>>>>>>>
>>>>>>> From: Ben Greear<greearb@candelatech.com>
>>>>>>>
>>>>>>> This allows the NIC to receive 1518 byte (not counting
>>>>>>> FCS) packets when MTU is 1500, thus allowing 1500 MTU
>>>>>>> VLAN frames to be received.  Please note that no VLANs
>>>>>>> were actually configured on the NIC...it was just acting
>>>>>>> as pass-through device.
>>>>>>>
>>>>>>> Signed-off-by: Ben Greear<greearb@candelatech.com>
>>>>>>> ---
>>>>>>> :100644 100644 58c665b... 30c9cc6... M  drivers/net/igb/igb_main.c
>>>>>>>    drivers/net/igb/igb_main.c |    5 +++--
>>>>>>>    1 files changed, 3 insertions(+), 2 deletions(-)
>>>>>>>
>>>>>>> diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
>>>>>>> index 58c665b..30c9cc6 100644
>>>>>>> --- a/drivers/net/igb/igb_main.c
>>>>>>> +++ b/drivers/net/igb/igb_main.c
>>>>>>> @@ -2281,7 +2281,8 @@ static int __devinit igb_sw_init(struct igb_adapter
>>>>>>> *adapter)
>>>>>>>          adapter->rx_itr_setting = IGB_DEFAULT_ITR;
>>>>>>>          adapter->tx_itr_setting = IGB_DEFAULT_ITR;
>>>>>>>
>>>>>>> -       adapter->max_frame_size = netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
>>>>>>> +       adapter->max_frame_size = (netdev->mtu + ETH_HLEN + ETH_FCS_LEN
>>>>>>> +                                  + VLAN_HLEN);
>>>>>>>          adapter->min_frame_size = ETH_ZLEN + ETH_FCS_LEN;
>>>>>>>
>>>>>>>          spin_lock_init(&adapter->stats64_lock);
>>>>>>> @@ -4303,7 +4304,7 @@ static int igb_change_mtu(struct net_device
>>>>>>> *netdev, int new_mtu)
>>>>>>>    {
>>>>>>>          struct igb_adapter *adapter = netdev_priv(netdev);
>>>>>>>          struct pci_dev *pdev = adapter->pdev;
>>>>>>> -       int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN;
>>>>>>> +       int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;
>>>>>>>          u32 rx_buffer_len, i;
>>>>>>>
>>>>>>>          if ((new_mtu<      68) || (max_frame>      MAX_JUMBO_FRAME_SIZE)) {
>>>>>>
>>>>>> While testing this patch, validation found that the patch reduces the
>>>>>> maximum mtu size
>>>>>> by 4 bytes (reduces it from 9216 to 9212).  This is not a desired side
>>>>>> effect of this patch.
>>>>>
>>>>> You could add handling for that case and have it act as it used to when
>>>>> new_mtu is greater than 9212?
>>>>>
>>>>> I tested e1000e and it worked w/out hacking at 1500 MTU, so maybe
>>>>> check how it does it?
>>>>
>>>> I just wanted to bring this up again to see if any progress had been
>>>> made.  We were looking at this driver and trying to figure out the
>>>> best way to convert it to use the new vlan model but I'm not familiar
>>>
>>> I've been watching :)
>>>
>>>> enough with the hardware to know.  It seems that all of the other
>>>> Intel drivers unconditionally add space for the vlan tag to the
>>>> receive buffer (and would therefore have similar effects as this
>>>> patch), is there something different about this card?
>>>>
>>>> I believe that Alex was working on something in this area (in the
>>>> context of one of my patches from a long time ago) but I'm not sure
>>>> what came of that.
>>>
>>> Truth is, I don't really see why it's a problem to decrease the
>>> maximum MTU slightly in order to make it work with VLANs.
>>>
>>> I'm not sure if there is some way to make it work with VLANs
>>> and not decrease the maximum MTU.
>>
>> This was the reason this did not get accepted.  I was looking into what
>> could be done so that we did not decease the maximum MTU, but I got
>> side-tracked and have not done anything on it in several months.
>>
>
> I can take a look at fixing this most likely tomorrow.  I have some
> work planned for igb anyway over the next few days.
>
> Odds are it is just a matter of where the VLAN_HLEN is added.  As I
> recall for our drivers the correct spot is in the setting of
> rx_buffer_len since that is the area more concerned with maximum
> receive frame size versus the mtu section which is more concerned with
> the transmit side of things.

Did a patch for this ever get posted?  I'll be happy to test it
if so...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
