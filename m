From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [OpenWrt-Devel] [RFC TRY#2][PATCH] bgmac: pass received packet to
 the netif instead of copying it
Date: Tue, 29 Oct 2013 07:59:57 +0100
Message-ID: <CACna6rzUN1fcpdWV=U9WX9_8DNO3g5EJOgkqxyFqcQk6Z5799Q@mail.gmail.com>
References: <1382982142-16876-1-git-send-email-zajec5@gmail.com>
	<BLU0-SMTP122B5D616AD665A29B9DDEFAC090@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: OpenWrt Development List <openwrt-devel@lists.openwrt.org>,
	Network Development <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Nathan Hintz <nlhintz@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:43119 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751497Ab3J2G76 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 02:59:58 -0400
Received: by mail-ob0-f176.google.com with SMTP id uy5so4724703obc.7
        for <netdev@vger.kernel.org>; Mon, 28 Oct 2013 23:59:58 -0700 (PDT)
In-Reply-To: <BLU0-SMTP122B5D616AD665A29B9DDEFAC090@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/10/29 Nathan Hintz <nlhintz@hotmail.com>:
> On Mon, 28 Oct 2013 18:42:22 +0100
> Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com> wrote:
>
> Hi:
>
> A few questions/comments inline...
>
> Nathan
>
>> Copying whole packets with skb_copy_from_linear_data_offset is a pre=
tty
>> bad idea. CPU was spending time in __copy_user_common and network
>> performance was lower. With the new solution iperf-measured speed
>> increased from 116Mb/s to 134Mb/s.
>>
>> Another way to improve performance could be switching to build_skb. =
It
>> is cache-specific, so will require testing of various devices.
>>
>> Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
>> ---
>>  drivers/net/ethernet/broadcom/bgmac.c |   71 ++++++++++++++++++++--=
-----------
>>  1 file changed, 44 insertions(+), 27 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/eth=
ernet/broadcom/bgmac.c
>> index 6b7541f..fde9a11 100644
>> --- a/drivers/net/ethernet/broadcom/bgmac.c
>> +++ b/drivers/net/ethernet/broadcom/bgmac.c
>> @@ -307,7 +307,6 @@ static int bgmac_dma_rx_read(struct bgmac *bgmac=
, struct bgmac_dma_ring *ring,
>>               struct device *dma_dev =3D bgmac->core->dma_dev;
>>               struct bgmac_slot_info *slot =3D &ring->slots[ring->st=
art];
>>               struct sk_buff *skb =3D slot->skb;
>> -             struct sk_buff *new_skb;
>>               struct bgmac_rx_header *rx;
>>               u16 len, flags;
>>
>> @@ -320,38 +319,56 @@ static int bgmac_dma_rx_read(struct bgmac *bgm=
ac, struct bgmac_dma_ring *ring,
>>               len =3D le16_to_cpu(rx->len);
>>               flags =3D le16_to_cpu(rx->flags);
>>
>> -             /* Check for poison and drop or pass the packet */
>> -             if (len =3D=3D 0xdead && flags =3D=3D 0xbeef) {
>> -                     bgmac_err(bgmac, "Found poisoned packet at slo=
t %d, DMA issue!\n",
>> -                               ring->start);
>> -             } else {
>> +             do {
>
> "old_skb" duplicates "skb" stored above, can that one be used (rename=
d) instead of creating a new one here?

I've focused on clean code too much. That won't be needed anyway when
I rebase my patch on top of yours.


>> +                     struct sk_buff *old_skb =3D slot->skb;
>> +                     dma_addr_t old_dma_addr =3D slot->dma_addr;
>> +                     int err;
>> +
>> +                     /* Check for poison and drop or pass the packe=
t */
>> +                     if (len =3D=3D 0xdead && flags =3D=3D 0xbeef) =
{
>> +                             bgmac_err(bgmac, "Found poisoned packe=
t at slot %d, DMA issue!\n",
>> +                                       ring->start);
>> +                             dma_sync_single_for_device(dma_dev,
>> +                                                        slot->dma_a=
ddr,
>> +                                                        BGMAC_RX_BU=
=46_SIZE,
>> +                                                        DMA_FROM_DE=
VICE);
>
> Nothing in the buffer has been changed by the cpu yet, so is this syn=
c necessary?

I've moved your comment a line below, so it comments the code *above*.

I'm using LDD3 to understand DMA and it contains this explanation:

> void dma_sync_single_for_cpu(struct device *dev, dma_handle_t bus_add=
r,
> size_t size, enum dma_data_direction direction);
>
> This function should be called before the processor accesses a stream=
ing DMA buffer. Once the call has been made, the CPU =E2=80=9Cowns=E2=80=
=9D the DMA buffer and can work with it as needed. Before the device ac=
cesses the buffer, however, ownership should be transferred back to it =
with:
>
> void dma_sync_single_for_device(struct device *dev, dma_handle_t bus_=
addr,
> size_t size, enum dma_data_direction direction);

So even if I didn't change anything in the buffer, I believe we still
need to "sync" it back to make it accessible to the hardware.


> I've sent a separate patch against "bgmac_dma_rx_skb_for_slot" to not=
 corrupt the slot at all if an
> error occurs (skb alloc or dma mapping), and free the skb that was al=
located if a dma mapping error
> occurs.  Assuming that patch is accepted, then the following two line=
s would not be needed.
> With "bgmac_dma_rx_skb_for_slot" as it currently exists, this would l=
eak an skb for a dma mapping
> error (this was pre-existing to the changes in this patch).

Thanks, I'll rebase my patch.
