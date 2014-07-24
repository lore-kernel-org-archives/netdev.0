From: Tom Herbert <therbert@google.com>
Subject: Re: [net-next 00/10] Add Geneve
Date: Thu, 24 Jul 2014 15:03:52 -0700
Message-ID: <CA+mtBx9QK9i7rC+AHXGRE4eB1nFexTTstKQwR5mz+4nj+3Hb=Q@mail.gmail.com>
References: <1406024393-6778-1-git-send-email-azhou@nicira.com>
	<CAJZOPZ+APJZsECj3D_rFFPw82k3u6jgkbGzYnwaVmTUcrH5xiQ@mail.gmail.com>
	<CA+mtBx95N+6Z+CzkAc-YD+Yx7_PVVLzC_t_P0=2M51fSFsS3Aw@mail.gmail.com>
	<CACzMAJKyXaO0CL5XOnH7cHOk3voz_shVaK6Jmd0mx0h2NBtn-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <or.gerlitz@gmail.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andy Zhou <azhou@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:55313 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750795AbaGXWDw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2014 18:03:52 -0400
Received: by mail-ig0-f177.google.com with SMTP id hn18so29162igb.10
        for <netdev@vger.kernel.org>; Thu, 24 Jul 2014 15:03:52 -0700 (PDT)
In-Reply-To: <CACzMAJKyXaO0CL5XOnH7cHOk3voz_shVaK6Jmd0mx0h2NBtn-w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 24, 2014 at 2:03 PM, Andy Zhou <azhou@nicira.com> wrote:
> @or.gerlitz@gmail.com:  Yes, this is the logical order of the patch
> series. I can improve the cover letter to make it clearer.
>
Please send patches in two different patch sets.

>
> @therbert@google.com: I will add L2TP refactor to the series in the
> next version. Given that port number and associated protocol is still
> required
> by NIC device driver for advanced offloads, we may still need to
> define the protocol types. Are you O.K. with this, if not, any other
> suggestions?
>
If you really need this, then put the constants for this should moved
this to their own header file. Also, something needs to be added to
the hw_features to have control over the feature-- for instance if I
discovered that my VXLAN device was incorrectly ignoring UDP
checksums, I'd want the ability to turn off checksum offload of VXLAN
without needing to disable checksum offload for everyone else. I'm not
sure what goes into features since what the device actually does with
port seems undefined, maybe the features would be purposely generic
(e.g. NETIF_F_VXLAN_RX_PARSING). Also, we should not blindly be
telling devices port information for things it doesn't support or need
to know about, to do so would be a security risk.

Also, L2TP (and probably LISP) are interesting use cases since
encapsulated protocol does not appear in the header and can only be
determined from the tunnel context. Telling devices about L2TP ports
probably isn't enough to do anything meaningful.

> On Thu, Jul 24, 2014 at 10:40 AM, Tom Herbert <therbert@google.com> wrote:
>> On Wed, Jul 23, 2014 at 11:58 PM, Or Gerlitz <or.gerlitz@gmail.com> wrote:
>>> On Tue, Jul 22, 2014 at 1:19 PM, Andy Zhou <azhou@nicira.com> wrote:
>>>> Following patches adds initial support for Geneve tunnel protocol
>>>
>>> Just to make this a bit more clear, would it be correct to say that
>>> the logical ordering here is as follows:
>>>
>> Agreed, improvements to the general infrastructure to support UDP
>> tunneling should be done first. This was already begun with
>> introduction of udp_tunnel.[ch] and the udp_tunnel_xmit functions seem
>> like a nice addition at least.
>>
>> Also, we have at least two instances of UDP tunneling in the code that
>> should addressed when interface improvements: VXLAN and L2TP. Please
>> make sure *both* of these are considered with such patches (also the
>> needs for Geneve, GUE, LISP, etc. should be considered, but please no
>> protocol specific stuff in the common infrastructure code!)
>>
>>>> 1. Add common UDP tunnel code into UDP tunnel support function
>>>> 2. Refactor vxlan driver to make use of the UDP tunnel support
>>>> 3. Add Geneve driver.
>>>
>>> implemented by patches 1-5 below)
>>>
>>>> Andy Zhou (5):
>>>>   net: Rename ndo_add_vxlan_port to ndo_add_udp_tunnel_port.
>>>>   udp: Expand UDP tunnel common APIs
>>>>   vxlan: Remove vxlan_get_rx_port()
>>>>   net: Refactor vxlan driver to make use of common UDP tunnel functions
>>>>   net: Add Geneve tunneling protocol driver
>>>
>>> and on top of that
>>>
>>>> 4. Refactor Openvswitch  in preparation for #5
>>>> 5. Add Geneve support to Openvswitch.
>>>
>>> implemented by patches 6-10 (below)
>>>
>>>> Jesse Gross (5):
>>>>   openvswitch: Eliminate memset() from flow_extract.
>>>>   openvswitch: Add support for matching on OAM packets.
>>>>   openvswitch: Wrap struct ovs_key_ipv4_tunnel in a new structure.
>>>>   openvswitch: Factor out allocation and verification of actions.
>>>>   openvswitch: Add support for Geneve tunneling.
>>>
>>> I understand the wish to eventually have something that goes beyond
>>> refactoring of
>>> the vxlan and tunneling code plus Geneve basics. However, isn't the
>>> 1st part of the series
>>> (patches 1-5) have something is common to Tom's GUE work, which is
>>> currently under review
>>> too? I think we need first see how the basic elements from your series
>>> go along together with GUE.
>>>
>>> Or.
