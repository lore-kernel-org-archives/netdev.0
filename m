From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net-next] cdc_ether: Improve ZTE MF823/831/910 handling
Date: Mon, 08 Aug 2016 14:44:08 +0200
Message-ID: <87y4475t2f.fsf@miraculix.mork.no>
References: <1468844691-8222-1-git-send-email-kristian.evensen@gmail.com>
	<1468846886.2280.6.camel@suse.com>
	<CAKfDRXiqDmJadXL4+v7saM431vPAp_8m8F0wvTkkYt-3tNjYyw@mail.gmail.com>
	<1468849802.2280.11.camel@suse.com>
	<CAKfDRXjaSz25_b8Na46DJEDvGUsZ-Xye+Rn2+o6Hy0EcuOopkA@mail.gmail.com>
	<1468851242.2280.14.camel@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: Kristian Evensen <kristian.evensen@gmail.com>,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	Network Development <netdev@vger.kernel.org>
To: Oliver Neukum <oneukum@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:34026 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752007AbcHHMoU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 08:44:20 -0400
In-Reply-To: <1468851242.2280.14.camel@suse.com> (Oliver Neukum's message of
	"Mon, 18 Jul 2016 16:14:02 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Neukum <oneukum@suse.com> writes:
> On Mon, 2016-07-18 at 16:10 +0200, Kristian Evensen wrote:
>> On Mon, Jul 18, 2016 at 3:50 PM, Oliver Neukum <oneukum@suse.com> wrote:
>> > No, you misunderstand me. I don't want quirks if we can avoid it.
>> > But if you need to do this for rndis_host and cdc_ether and maybe other
>> > drivers you should not be touching drivers. This belongs into the core
>> > ethernet code. Your code is good, but you are putting it in the wrong
>> > places.
>> 
>> Ok, sounds good. So far, I have only seen the random MAC issue with
>> the three previously mentioned devices, but who knows how many else is
>> out there with the same error ... I don't think it should be in the
>> core ethernet code, at least not yet, but I agree it would make sense
>> to move it to for example usbnet_core(). If you agree, I can prepare a
>> patch for it.
>
> I don't see how it would be specific for a subsystem. If the patch
> is correct, it belongs into the networking core.

The bug is in the firmware implementation of the "read unique vendor
assigned mac address" functions, and should therefore be fixed there.
It cannot be put into the networking core because "read unique vendor
assigned mac address" is a hardware dependent function.  It's
implemented in each ethernet driver based of whatever interface the
firmware provides to that register.

IMHO, usbnet_get_ethernet_addr() would be the most appropriate place for
cdc_ether and other CDC drivers. And generic_rndis_bind() is the correct
place for rndis_host.

Putting this in usbnet_get_ethernet_addr() will also fix the XMM7160
based devices having an FF:FF:FF:FF:FF:FF mac address (sic).  I'm pretty
sure there are other examples too.  There is no end to the creative
crazyness of firmware engineers...

An lsusb snippet example:

    Interface Descriptor:
      bLength                 9
      bDescriptorType         4
      bInterfaceNumber        0
      bAlternateSetting       0
      bNumEndpoints           1
      bInterfaceClass         2 Communications
      bInterfaceSubClass     13 
      bInterfaceProtocol      0 
      iInterface              5 Sierra Wireless EM7345 4G LTE (NCM)
      CDC Header:
        bcdCDC               1.20
      CDC Union:
        bMasterInterface        0
        bSlaveInterface         1 
      CDC NCM:
        bcdNcmVersion        1.00
        bmNetworkCapabilities 0x00
      CDC Ethernet:
        iMacAddress                      6 FFFFFFFFFFFF
        bmEthernetStatistics    0x00000000
        wMaxSegmentSize               1514
        wNumberMCFilters            0x0000
        bNumberPowerFilters              0


FWIW, putting the fix in usbnet_get_ethernet_addr() will not be a
problem for qmi_wwan.  It will further fix up the resulting random
address if required.


Bjørn
