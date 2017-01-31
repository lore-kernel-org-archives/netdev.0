From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH net-next 10/10] bnxt_en: Add support for XDP_TX action.
Date: Mon, 30 Jan 2017 23:19:40 -0800
Message-ID: <CACKFLikzA0zyFwAatnKXUVc2jMzA3qGnTv70ubbUCVJ3c6kb2g@mail.gmail.com>
References: <1485827375-20421-1-git-send-email-michael.chan@broadcom.com>
 <1485827375-20421-11-git-send-email-michael.chan@broadcom.com> <20170130212727.69e9b646@cakuba>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f50.google.com ([209.85.213.50]:33215 "EHLO
        mail-vk0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750837AbdAaH1w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 02:27:52 -0500
Received: by mail-vk0-f50.google.com with SMTP id k127so231164141vke.0
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 23:27:52 -0800 (PST)
In-Reply-To: <20170130212727.69e9b646@cakuba>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 30, 2017 at 9:27 PM, Jakub Kicinski <kubakici@wp.pl> wrote:
> On Mon, 30 Jan 2017 20:49:35 -0500, Michael Chan wrote:
>> +static int bnxt_xmit_xdp(struct bnxt *bp, struct bnxt_napi *bnapi,
>> +                      struct page *page, dma_addr_t mapping, u32 offset,
>> +                      u32 len)
>> +{
>> +     struct bnxt_tx_ring_info *txr = bnapi->tx_ring;
>> +     struct bnxt_sw_tx_bd *tx_buf;
>> +     struct tx_bd_ext *txbd1;
>> +     struct tx_bd *txbd;
>> +     u32 flags;
>> +     u16 prod;
>> +
>> +     if (bnxt_tx_avail(bp, txr) < 2)
>> +             return -ENOSPC;
>> +
>> +     prod = txr->tx_prod;
>> +     txbd = &txr->tx_desc_ring[TX_RING(prod)][TX_IDX(prod)];
>> +
>> +     tx_buf = &txr->tx_buf_ring[prod];
>> +     tx_buf->page = page;
>> +     dma_unmap_addr_set(tx_buf, mapping, mapping);
>> +     flags = (len << TX_BD_LEN_SHIFT) | TX_BD_TYPE_LONG_TX_BD |
>> +             (2 << TX_BD_FLAGS_BD_CNT_SHIFT) | TX_BD_FLAGS_PACKET_END |
>> +             bnxt_lhint_arr[len >> 9];
>> +     txbd->tx_bd_len_flags_type = cpu_to_le32(flags);
>> +     txbd->tx_bd_opaque = prod;
>> +     txbd->tx_bd_haddr = cpu_to_le64(mapping + offset);
>> +
>> +     prod = NEXT_TX(prod);
>> +     txbd1 = (struct tx_bd_ext *)
>> +             &txr->tx_desc_ring[TX_RING(prod)][TX_IDX(prod)];
>> +
>> +     txbd1->tx_bd_hsize_lflags = cpu_to_le32(0);
>> +     txbd1->tx_bd_mss = cpu_to_le32(0);
>> +     txbd1->tx_bd_cfa_action = cpu_to_le32(0);
>> +     txbd1->tx_bd_cfa_meta = cpu_to_le32(0);
>> +
>> +     prod = NEXT_TX(prod);
>> +     txr->tx_prod = prod;
>> +     return 0;
>> +}
>
> Are you not lacking DMA syncs in general?  You map the buffers
> bidirectionally, but I failed to find any dma_syncs.  I would expect
> one before you run xdp and one before you TX because packet could have
> been modified.  What am I missing?

You are right.  I missed the DMA syncs.
