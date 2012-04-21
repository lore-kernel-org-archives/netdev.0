From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next 04/14] net: Fix issue with netdev_tx_reset_queue not
 resetting queue from XOFF state
Date: Fri, 20 Apr 2012 20:24:33 -0700
Message-ID: <CAKgT0UcZZNOH=D5mJDaw3_6femW120ZG0cBc8Nz=-=8h6X17kg@mail.gmail.com>
References: <1331611432-30109-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1331611432-30109-5-git-send-email-jeffrey.t.kirsher@intel.com>
	<CA+mtBx-BWy=KANgSca9f2vxuu1Km_kPMJbQFa+Nq9q_YYvatBQ@mail.gmail.com>
	<4F91D5A2.2060300@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com, John Fastabend <john.r.fastabend@intel.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:59721 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752628Ab2DUDYe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 23:24:34 -0400
Received: by pbcun15 with SMTP id un15so1728549pbc.19
        for <netdev@vger.kernel.org>; Fri, 20 Apr 2012 20:24:34 -0700 (PDT)
In-Reply-To: <4F91D5A2.2060300@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 20, 2012 at 2:31 PM, John Fastabend
<john.r.fastabend@intel.com> wrote:
> On 4/20/2012 2:19 PM, Tom Herbert wrote:
>> Hi Jeff,
>>
>>> @@ -3244,7 +3246,6 @@ static void igb_clean_tx_ring(struct igb_ring=
 *tx_ring)
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0buffer_info =3D &tx_ring->tx_buffer_=
info[i];
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0igb_unmap_and_free_tx_resource(tx_ri=
ng, buffer_info);
>>> =A0 =A0 =A0 =A0}
>>> - =A0 =A0 =A0 netdev_tx_reset_queue(txring_txq(tx_ring));
>>>
>> Why is it necessary to remove this? =A0If rings are being freed with
>> going through completion path then we would need this reset. =A0Is t=
his
>> being done elsewhere maybe?
>>
>
> Alex moved this into the igb_configure_tx_ring() iirc to catch an eth=
tool
> test case. He assured me when I reviewed the patch that igb_configure=
_tx_ring()
> would always be called before netif_carrier_on() so I think(?) that s=
hould
> be OK.
>
> The above removed case was called after netif_carrier_off() anyways.

I don't recall the exact reason now, as John said I think it had to do
with the ethtool tests not using the same cleanup routine and leaving
us in a bad state.  I am pretty sure there was some path in which
where the call was didn't work but I do not recall the exact details
now.  Most of the reason for moving it is due to the fact that the
reset is now also clearing the bit, and from the driver perspective we
didn't need it in two places.  After looking it all over again, I
suppose this causes a cosmetic issue for the bql "inflight" statistic
in sysfs since the value will be retained until the interface is
brought back up with this change.  Is that an issue or something that
can be lived with since the interface isn't active anyway in this
case?

Thanks,

Alex
