From: Cong Wang <cwang@twopensource.com>
Subject: Re: [Patch net] igb: pass the correct maxlen for eth_get_headlen()
Date: Thu, 23 Apr 2015 12:30:06 -0700
Message-ID: <CAHA+R7OhbCSjggyb_Deq_jmoDWzEcR+=hhkKjyE9Pue7bXOmHg@mail.gmail.com>
References: <1429724760-10075-1-git-send-email-xiyou.wangcong@gmail.com>
	<5537F9F1.1080008@gmail.com>
	<CAHA+R7PVrxJ41WSqfO4mZSpCTGdJ++Gf757f_kq5z0UeMHXbXg@mail.gmail.com>
	<553802DA.4050709@gmail.com>
	<CAHA+R7PtzNd2asXFtiqsWyzCgeE1k_iF84358cvKg6ZCU-yVkQ@mail.gmail.com>
	<553815DF.4000109@gmail.com>
	<CAHA+R7MMrrBYbQALovxuhcXrbiWjD_XpgohPXxTvNkcd3-R3WA@mail.gmail.com>
	<553821E4.5010901@gmail.com>
	<CAHA+R7MJv7tbHwU_ECbJunXVJ8uo=eQv+Xmw42oR5sKEde35RQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	intel-wired-lan@lists.osuosl.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:35049 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030357AbbDWTaH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 15:30:07 -0400
Received: by widdi4 with SMTP id di4so227965408wid.0
        for <netdev@vger.kernel.org>; Thu, 23 Apr 2015 12:30:06 -0700 (PDT)
In-Reply-To: <CAHA+R7MJv7tbHwU_ECbJunXVJ8uo=eQv+Xmw42oR5sKEde35RQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Off-topic...)

On Wed, Apr 22, 2015 at 4:23 PM, Cong Wang <cwang@twopensource.com> wrote:
>
> The code looks correct to me now, except it is suspicious skb->len
> is not updated after skb_copy_to_linear_data() while skb->tail is
> advanced already. I need to think more before submitting a patch.

I feel like we need the following patch, maybe skb->len is updated somewhere
else by "skb->tail - skb->head", otherwise we are screwed?

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c
b/drivers/net/ethernet/intel/igb/igb_main.c
index a0a9b1f..66e6fb6 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -6843,7 +6843,6 @@ static void igb_pull_tail(struct igb_ring *rx_ring,
                skb_frag_size_sub(frag, IGB_TS_HDR_LEN);
                frag->page_offset += IGB_TS_HDR_LEN;
                skb->data_len -= IGB_TS_HDR_LEN;
-               skb->len -= IGB_TS_HDR_LEN;

                /* move va to start of packet data */
                va += IGB_TS_HDR_LEN;
@@ -6856,12 +6855,12 @@ static void igb_pull_tail(struct igb_ring *rx_ring,

        /* align pull length to size of long to optimize memcpy performance */
        skb_copy_to_linear_data(skb, va, ALIGN(pull_len, sizeof(long)));
+       __skb_put(skb, pull_len);

        /* update all of the pointers */
        skb_frag_size_sub(frag, pull_len);
        frag->page_offset += pull_len;
        skb->data_len -= pull_len;
-       skb->tail += pull_len;
 }

 /**
