From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [net-next.git 0/9] stmmac: update to March_2013 (adding PTP &
 RGMII/SGMII)
Date: Mon, 11 Mar 2013 08:11:22 +0100
Message-ID: <513D839A.8000009@st.com>
References: <1362653419-1047-1-git-send-email-peppe.cavallaro@st.com> <20130307.153456.83724032858548621.davem@davemloft.net> <51399048.3070505@st.com> <20130308.112219.1999774630969953487.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bh74.an@samsung.com,
	rayagond@vayavyalabs.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from beta.dmz-eu.st.com ([164.129.1.35]:50317 "EHLO
	beta.dmz-eu.st.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751638Ab3CKHXE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 03:23:04 -0400
In-Reply-To: <20130308.112219.1999774630969953487.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/8/2013 5:22 PM, David Miller wrote:
> From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
> Date: Fri, 08 Mar 2013 08:16:24 +0100
>
>> Hello David
>>
>> On 3/7/2013 9:34 PM, David Miller wrote:
>>> From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
>>> Date: Thu,  7 Mar 2013 11:50:10 +0100
>>>
>>>> The PTP support is quite intrusive because it needs to support the
>>>> extended
>>>> descriptors used for saving the HW timestamps.
>>>> These are available in new chip generations, only.
>>>> So we have actually found useful to use some Kconfig options to
>>>> surround PTP and extended descriptor support. This approach helped on
>>>> old platform (embeeded system) where PTP is not supported and where we
>>>> do not want to pay extra code and check in critical rx/tx paths.
>>>
>>> I would prefer run time handling of all of this.
>>>
>>> You do not need to put extra checks in the fast paths, instead you
>>> have different methods that get hooked up into the netdev_ops
>>> based upon chip capabilities/features/mode.
>   ...
>> Welcome advice.
>
> Exactly what I told you above.  You have two sets of routines,
> one that deal with the older descriptors and one set that deals
> with the new descriptors that can do PTP.
>
> And you hook up different interrupt handler, NAPI poll, and
> netdev_ops based upon the chip's capabilities.
>
> You need no runtime testing, only a test a probe time to setup
> things up properly.

> What is so hard about this to understand?

This is exactly what the driver does to manage different chip versions
w/o using any ifdef. So fortunately I had already understood this :-).

Unfortunately, just in this case, I've met some problems on
implementing the code because We have three cases:

  1- normal desc
  2- enhanced desc.
  3- enhanced desc + extended desc.
                     -------------
                          |_ Also used for PTPv2

To support extended desc (3) we have to modify the main descriptor
structure and it is not good for the case (2) where the DMA will expect
to use these descriptors:

-------------
|   des0    |    status / conf
-------------
|   des1    |    status / conf
-------------
|   des2    |    Buffer 1 Address [31:0]
-------------
|   des3    |    Buffer 2 Address [31:0] or Next Descriptor Addr
-------------

but we have added other 4 fields:
	struct des {
		unsigned int des0;
		unsigned int des1;
		unsigned int des2;
		unsigned int des3;
		unsigned int des4; |
		unsigned int des5; |_ extended
		unsigned int des6; |
		unsigned int des7; |
	}

and this structure cannot be used.
In fact, if the HW supports the  extended desc we have to program a
register to allow the DMA to walk through the new structure.

At any case, I'll arrange to change the code removing the Koption and
continuing (as done in the past) to setup at probe time the right
configuration. This will be in the next version of the patches.

Thx
Peppe
