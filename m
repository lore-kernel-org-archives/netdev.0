From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCHv2 net] i40e: Implement ndo_gso_check()
Date: Tue, 2 Dec 2014 10:26:31 -0800
Message-ID: <CAEP_g=9Yg-pZf9-Wb4qrZhAMSB=edqDxBXSRskWCturt-nnxTg@mail.gmail.com>
References: <1416525081-27779-1-git-send-email-joestringer@nicira.com>
 <CAEP_g=-VEWi2Qo6gcJGr2+NXWEhkuMyu7BiAke6H=x+PTLcNcg@mail.gmail.com>
 <CANr6G5zrA6NUtcyhX1cwEO1Hiq9jnarB36P6m5eoHUFqWWc26Q@mail.gmail.com>
 <CANr6G5xRbG=UnJEdBEN_5ZRjNikCjuUseb1VbQmjjfb36jDP0g@mail.gmail.com>
 <CA+mtBx-Q=Ebrx_8NVB5mWURj-oWB3gdNs5fSAL=Frr9sOmyvHw@mail.gmail.com>
 <CAEP_g=979u0baWXGmCxo61a-KYEUwkruqBNof_zQpsvJxRFqSA@mail.gmail.com> <CA+mtBx9RwkJ9b84d_OkCtOunFBsuqw276=5E+Qhoqq75utCR4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Joe Stringer <joestringer@nicira.com>,
	netdev <netdev@vger.kernel.org>,
	Shannon Nelson <shannon.nelson@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"linux.nics" <linux.nics@intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog028.obsmtp.com ([74.125.150.102]:35868 "HELO
	na6sys009bog028.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754386AbaLBS0x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 13:26:53 -0500
Received: by mail-qc0-f171.google.com with SMTP id r5so9993804qcx.30
        for <netdev@vger.kernel.org>; Tue, 02 Dec 2014 10:26:51 -0800 (PST)
In-Reply-To: <CA+mtBx9RwkJ9b84d_OkCtOunFBsuqw276=5E+Qhoqq75utCR4w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 1, 2014 at 4:09 PM, Tom Herbert <therbert@google.com> wrote:
> On Mon, Dec 1, 2014 at 3:53 PM, Jesse Gross <jesse@nicira.com> wrote:
>> On Mon, Dec 1, 2014 at 3:47 PM, Tom Herbert <therbert@google.com> wrote:
>>> On Mon, Dec 1, 2014 at 3:35 PM, Joe Stringer <joestringer@nicira.com> wrote:
>>>> On 21 November 2014 at 09:59, Joe Stringer <joestringer@nicira.com> wrote:
>>>>> On 20 November 2014 16:19, Jesse Gross <jesse@nicira.com> wrote:
>>>>>> I don't know if we need to have the check at all for IPIP though -
>>>>>> after all the driver doesn't expose support for it all (actually it
>>>>>> doesn't expose GRE either). This raises kind of an interesting
>>>>>> question about the checks though - it's pretty easy to add support to
>>>>>> the driver for a new GSO type (and I imagine that people will be
>>>>>> adding GRE soon) and forget to update the check.
>>>>>
>>>>> If the check is more conservative, then testing would show that it's
>>>>> not working and lead people to figure out why (and update the check).
>>>>
>>>> More concretely, one suggestion would be something like following at
>>>> the start of each gso_check():
>>>>
>>>> +       const int supported = SKB_GSO_TCPV4 | SKB_GSO_TCPV6 | SKB_GSO_FCOE |
>>>> +                             SKB_GSO_UDP | SKB_GSO_UDP_TUNNEL;
>>>> +
>>>> +       if (skb_shinfo(skb)->gso_type & ~supported)
>>>> +               return false;
>>>
>>> This should already be handled by net_gso_ok.
>>
>> My original point wasn't so much that this isn't handled at the moment
>> but that it's easy to add a supported GSO type but then forget to
>> update this check - i.e. if a driver already supports UDP_TUNNEL and
>> adds support for GRE with the same constraints. It seems not entirely
>> ideal that this function is acting as a blacklist rather than a
>> whitelist.
>
> Agreed, it would be nice to have all the checking logic in one place.
> If all the drivers end up implementing ndo_gso_check then we could
> potentially get rid of the GSO types as features. This probably
> wouldn't be a bad thing since we already know that the features
> mechanism doesn't scale (for instance there's no way to indicate that
> certain combinations of GSO types are supported by a device).

This crossed my mind and I agree that it's pretty clear that the
features mechanism isn't scaling very well. Presumably, the logical
extension of this is that each driver would have a function that looks
at a packet and returns a set of offload operations that it can
support rather than exposing a set of protocols. However, it seems
like it would probably result in a bunch of duplicate code in each
driver.
